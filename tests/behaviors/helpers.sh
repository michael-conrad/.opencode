#!/bin/bash
# Behavioral assertion functions for enforcement tests.
# Source this file in behavioral test scripts.
#
# Usage:
#   source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"
#
# These helpers verify agent BEHAVIOR (tool calls, response patterns)
# rather than just content presence in guideline files.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

BEHAVIOR_TIMEOUT="${BEHAVIOR_TIMEOUT:-420}"
BEHAVIOR_MODEL="${BEHAVIOR_MODEL:-ollama/glm-5.1:cloud}"
BEHAVIOR_TEST_HOME="${BEHAVIOR_TEST_HOME:-.opencode/tests/with-test-home}"
BEHAVIOR_FIXTURE_ISSUES="${BEHAVIOR_FIXTURE_ISSUES:-1}"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"
BEHAVIOR_LOG_DIR="${BEHAVIOR_LOG_DIR:-$PROJECT_DIR/tmp/behavior-test-$(date +%Y%m%d-%H%M%S)}"

BEHAVIOR_MAX_RETRIES="${BEHAVIOR_MAX_RETRIES:-2}"
BEHAVIOR_RETRY_DELAY="${BEHAVIOR_RETRY_DELAY:-30}"

behavior_run() {
    local scenario_name="$1"
    local message="$2"
    local model="${3:-${BEHAVIOR_MODEL}}"
    local workdir="${4:-}"
    local log_dir="$BEHAVIOR_LOG_DIR/$scenario_name"
    mkdir -p "$log_dir"

    local attempt=0
    local output_file="$log_dir/stdout.log"
    local err_file="$log_dir/stderr.log"

    # If no workdir provided, create an isolated git-init test repo
    # with .opencode as a proper git submodule (mirrors real project structure).
    #
    # IMPORTANT: .opencode is set up as a git submodule via clone + submodule add,
    # NOT by file copy. This ensures:
    #   1. Full isolation from the live submodule (no alternates, no shared objects)
    #   2. Proper .gitmodules configuration for opencode-cli session-init
    #   3. Ability to checkout specific fixture commits for behavioral tests
    #   4. Test repo is discarded after test completion
    if [ -z "$workdir" ]; then
        workdir=$(mktemp -d "$PROJECT_DIR/tmp/behavior-isolated-XXXXXX")
        git init -q "$workdir"
        git -C "$workdir" config user.email "test@test.dev"
        git -C "$workdir" config user.name "Test"

        # Determine submodule commit to check out.
        # BEHAVIOR_SUBMODULE_COMMIT overrides the default (current submodule HEAD).
        # This allows tests to run against specific fixture states (e.g., pre-redesign).
        local submodule_commit="${BEHAVIOR_SUBMODULE_COMMIT:-}"
        if [ -z "$submodule_commit" ]; then
            # Default: use the current submodule commit from the real project
            submodule_commit=$(git -C "$PROJECT_DIR" submodule status .opencode 2>/dev/null | awk '{print $1}' | sed 's/^[-+]//' || true)
        fi

        # Determine the submodule remote URL from the real project.
        # Uses HTTPS by default to avoid SSH dependency in CI environments.
        local submodule_remote_url=""
        if [ -f "$PROJECT_DIR/.gitmodules" ]; then
            submodule_remote_url=$(git -C "$PROJECT_DIR" config --get submodule..opencode.url 2>/dev/null || true)
        fi
        if [ -z "$submodule_remote_url" ]; then
            submodule_remote_url="https://github.com/michael-conrad/.opencode.git"
        fi
        # Ensure HTTPS (not SSH) for CI portability
        submodule_remote_url=$(echo "$submodule_remote_url" | sed 's|^git@github.com:|https://github.com/|' | sed 's|\.git$||')

        # Step 1: Clone .opencode as independent repo (full clone for commit checkout)
        git clone -q "$submodule_remote_url" "$workdir/.opencode" 2>/dev/null || {
            echo "FATAL: git clone failed for .opencode from $submodule_remote_url" >&2
            echo "Check network connectivity and repository access" >&2
            exit 1
        }

        # Step 2: Add as submodule (registers in .gitmodules, makes opencode-cli happy)
        git -C "$workdir" submodule add -q "$submodule_remote_url" .opencode 2>/dev/null || {
            echo "FATAL: git submodule add failed for .opencode" >&2
            exit 1
        }

        # Step 3: Checkout the desired fixture commit if specified
        if [ -n "$submodule_commit" ]; then
            git -C "$workdir/.opencode" checkout -q "$submodule_commit" 2>/dev/null || {
                echo "FATAL: could not checkout submodule commit $submodule_commit" >&2
                exit 1
            }
        fi

        git -C "$workdir" add -A 2>/dev/null || true
        git -C "$workdir" commit -q --allow-empty -m "init"

        # Inject fixture .issues/ entries if BEHAVIOR_FIXTURE_ISSUES is enabled.
        # This creates realistic local issue data that behavioral tests can reference.
        if [ "${BEHAVIOR_FIXTURE_ISSUES:-1}" = "1" ]; then
            FIXTURE_SETUP="$(dirname "${BASH_SOURCE[0]}")/fixtures/setup-fixture-issues.sh"
            if [ -f "$FIXTURE_SETUP" ]; then
                # shellcheck disable=SC1090
                source "$FIXTURE_SETUP"
                setup_fixture_issues "$workdir"
            fi
        fi

        # Inject AI-generated story fixtures for behavioral tests that use them.
        STORY_SETUP="$(dirname "${BASH_SOURCE[0]}")/fixtures/setup-story-fixtures.sh"
        if [ -f "$STORY_SETUP" ]; then
            # shellcheck disable=SC1090
            source "$STORY_SETUP"
            setup_story_fixtures "$workdir"
        fi
    fi

    while [ "$attempt" -lt "$BEHAVIOR_MAX_RETRIES" ]; do
        attempt=$((attempt + 1))
        echo "  [attempt $attempt/$BEHAVIOR_MAX_RETRIES]"

        TEST_WORKDIR="$workdir" \
        timeout "$BEHAVIOR_TIMEOUT" bash "$PROJECT_DIR/$BEHAVIOR_TEST_HOME" \
            opencode-cli run "$message" \
            --model "$model" \
            > "$output_file" 2> "$err_file" \
            || true

        local output
        output=$(cat "$output_file" 2>/dev/null || true)
        local word_count
        word_count=$(echo "$output" | wc -w | tr -d ' ')
        # Accept any non-empty output with word count > 0 as a valid response.
        # Short responses (1-3 words) are valid — the agent may produce concise output.
        # Only retry on truly empty output or explicit harness failure.
        if [ -n "$output" ] && [ "${word_count:-0}" -gt 0 ]; then
            break
        fi

        if grep -qi 'sse.*timeout\|unexpected EOF\|connection reset\|ProviderModelNotFoundError\|model not found' "$err_file" 2>/dev/null; then
            if [ "$attempt" -lt "$BEHAVIOR_MAX_RETRIES" ]; then
                echo "  retry in ${BEHAVIOR_RETRY_DELAY}s (transient error)..."
                sleep "$BEHAVIOR_RETRY_DELAY"
                continue
            fi
        fi

        # Only retry if output is truly empty (word count = 0).
        # Short-but-valid output is NOT a retry condition.
        if [ -z "$output" ] || [ "${word_count:-0}" -eq 0 ]; then
            if [ "$attempt" -lt "$BEHAVIOR_MAX_RETRIES" ]; then
                echo "  retry in ${BEHAVIOR_RETRY_DELAY}s (empty output)..."
                sleep "$BEHAVIOR_RETRY_DELAY"
                continue
            fi
        fi
    done

    local output
    output=$(cat "$output_file" 2>/dev/null || true)
    local word_count
    word_count=$(echo "$output" | wc -w | tr -d ' ')
    if [ -z "$output" ] || [ "${word_count:-0}" -eq 0 ]; then
        if grep -qi 'sse.*timeout\|unexpected EOF\|connection reset\|ProviderModelNotFoundError\|model not found' "$err_file" 2>/dev/null; then
            echo "HARNESS_FAILURE: model dispatch failed (timeout or provider error)"
            echo "HARNESS_FAILURE: model dispatch failed (timeout or provider error)" >> "$output_file"
            export BEHAVIOR_DISPATCH_FAILED=1
        else
            echo "HARNESS_FAILURE: behavior_run produced empty output after all retries"
            echo "  BEHAVIOR_TIMEOUT=$BEHAVIOR_TIMEOUT, BEHAVIOR_MODEL=$model"
            echo "  stdout: empty, stderr word count: $(wc -w < "$err_file" 2>/dev/null || echo 0)"
            echo "HARNESS_FAILURE: empty output" >> "$output_file"
        fi
    elif [ "${word_count:-0}" -le 3 ]; then
        # Short but non-empty output — likely valid but brief. Log diagnostics for debugging.
        echo "  NOTE: behavior_run produced short output (${word_count} words). Consider increasing BEHAVIOR_TIMEOUT if this is unexpected."
        echo "  BEHAVIOR_TIMEOUT=$BEHAVIOR_TIMEOUT, BEHAVIOR_MODEL=$model"
    fi

    sleep 1

    BEHAVIOR_STDOUT="$log_dir/stdout.log"
    BEHAVIOR_STDERR="$log_dir/stderr.log"
    export BEHAVIOR_DISPATCH_FAILED="${BEHAVIOR_DISPATCH_FAILED:-0}"
}

behavior_get_stdout() {
    cat "$BEHAVIOR_STDOUT"
}

behavior_get_stderr() {
    cat "$BEHAVIOR_STDERR"
}

assert_tool_calls_made() {
    if [ "${BEHAVIOR_DISPATCH_FAILED:-0}" = "1" ]; then
        echo "INCONCLUSIVE: assert_tool_calls_made — model dispatch failed, no behavioral evidence"
        return 2
    fi
    local min_count="$1"
    shift
    local tool_patterns="$*"
    local log_file="${BEHAVIOR_STDOUT:-/dev/null}"
    local total=0
    for pattern in $tool_patterns; do
        local count
        count=$(grep -cE "$pattern" "$log_file" 2>/dev/null || true)
        count=${count:-0}
        count=$(echo "$count" | head -1 | tr -d '[:space:]')
        total=$((total + count))
    done
    if [ "$total" -lt "$min_count" ]; then
        echo "FAIL: assert_tool_calls_made — expected at least $min_count tool call(s) matching [$tool_patterns], found $total"
        return 1
    fi
    echo "PASS: assert_tool_calls_made — found $total tool call(s) matching [$tool_patterns] (>= $min_count)"
    return 0
}

assert_forbidden_pattern_absent() {
    if [ "${BEHAVIOR_DISPATCH_FAILED:-0}" = "1" ]; then
        echo "INCONCLUSIVE: assert_forbidden_pattern_absent — model dispatch failed, no behavioral evidence"
        return 2
    fi
    local pattern="$1"
    local description="${2:-forbidden pattern}"
    local log_file="${BEHAVIOR_STDOUT:-/dev/null}"
    local count
    count=$(grep -cE "$pattern" "$log_file" 2>/dev/null || true)
    count=${count:-0}
    count=$(echo "$count" | head -1 | tr -d '[:space:]')
    if [ "$count" -gt 0 ]; then
        echo "FAIL: assert_forbidden_pattern_absent — found $count occurrence(s) of $description in agent output"
        return 1
    fi
    echo "PASS: assert_forbidden_pattern_absent — $description not found in agent output"
    return 0
}

assert_required_pattern_present() {
    if [ "${BEHAVIOR_DISPATCH_FAILED:-0}" = "1" ]; then
        echo "INCONCLUSIVE: assert_required_pattern_present — model dispatch failed, no behavioral evidence"
        return 2
    fi
    local pattern="$1"
    local description="${2:-required pattern}"
    local log_file="${BEHAVIOR_STDOUT:-/dev/null}"
    local count
    count=$(grep -cE "$pattern" "$log_file" 2>/dev/null || true)
    count=${count:-0}
    count=$(echo "$count" | head -1 | tr -d '[:space:]')
    if [ "$count" -eq 0 ]; then
        echo "FAIL: assert_required_pattern_present — $description not found in agent output"
        return 1
    fi
    echo "PASS: assert_required_pattern_present — $description found $count time(s) in agent output"
    return 0
}

assert_skill_called() {
    if [ "${BEHAVIOR_DISPATCH_FAILED:-0}" = "1" ]; then
        echo "INCONCLUSIVE: assert_skill_called — model dispatch failed, no behavioral evidence"
        return 2
    fi
    local expected_skill="$1"
    local log_file="${BEHAVIOR_STDERR:-/dev/null}"
    local found
    found=$(grep -c "Skill \"$expected_skill\"" "$log_file" 2>/dev/null || true)
    found=${found:-0}
    found=$(echo "$found" | head -1 | tr -d '[:space:]')
    if [ "$found" -eq 0 ]; then
        echo "FAIL: assert_skill_called — expected skill '$expected_skill' was not called (no Skill \"$expected_skill\" in stderr)"
        return 1
    fi
    echo "PASS: assert_skill_called — skill '$expected_skill' was called"
    return 0
}

assert_skill_not_called() {
    if [ "${BEHAVIOR_DISPATCH_FAILED:-0}" = "1" ]; then
        echo "INCONCLUSIVE: assert_skill_not_called — model dispatch failed, no behavioral evidence"
        return 2
    fi
    local forbidden_skill="$1"
    local log_file="${BEHAVIOR_STDERR:-/dev/null}"
    local found
    found=$(grep -c "Skill \"$forbidden_skill\"" "$log_file" 2>/dev/null || true)
    found=${found:-0}
    found=$(echo "$found" | head -1 | tr -d '[:space:]')
    if [ "$found" -gt 0 ]; then
        echo "FAIL: assert_skill_not_called — forbidden skill '$forbidden_skill' was called ($found time(s))"
        return 1
    fi
    echo "PASS: assert_skill_not_called — skill '$forbidden_skill' was not called"
    return 0
}

behavior_adversarial_eval() {
    local scenario_name="$1"
    local test_prompt="$2"
    local eval_criteria="$3"
    local test_model="${BEHAVIOR_ADVERSARIAL_TEST_MODEL:-ollama/glm-5.1:cloud}"
    local auditor_pool="${BEHAVIOR_ADVERSARIAL_AUDITOR_POOL:-}"
    local log_dir="$BEHAVIOR_LOG_DIR/$scenario_name"
    mkdir -p "$log_dir"

    echo "--- Phase 1: Running test prompt against $test_model ---"
    local test_output=""
    local test_attempt=0
    while [ "$test_attempt" -lt "$BEHAVIOR_MAX_RETRIES" ]; do
        test_attempt=$((test_attempt + 1))
        echo "  [test attempt $test_attempt/$BEHAVIOR_MAX_RETRIES]"

        timeout "$BEHAVIOR_TIMEOUT" bash "$PROJECT_DIR/$BEHAVIOR_TEST_HOME" \
            opencode-cli run "$test_prompt" \
            --model "$test_model" \
            > "$log_dir/test-stdout.log" 2> "$log_dir/test-stderr.log" \
            || true

        test_output=$(cat "$log_dir/test-stdout.log" 2>/dev/null || true)
        if [ -n "$test_output" ] && [ "$(echo "$test_output" | wc -w | tr -d ' ')" -gt 3 ]; then
            break
        fi
        if grep -qi 'sse.*timeout\|unexpected EOF\|connection reset\|model not found' "$log_dir/test-stderr.log" 2>/dev/null; then
            if [ "$test_attempt" -lt "$BEHAVIOR_MAX_RETRIES" ]; then
                echo "  retry in ${BEHAVIOR_RETRY_DELAY}s (transient error)..."
                sleep "$BEHAVIOR_RETRY_DELAY"
            fi
        elif [ "$(echo "$test_output" | wc -w | tr -d ' ')" -le 3 ] && [ "$test_attempt" -lt "$BEHAVIOR_MAX_RETRIES" ]; then
            echo "  retry in ${BEHAVIOR_RETRY_DELAY}s (short output)..."
            sleep "$BEHAVIOR_RETRY_DELAY"
        fi
    done

    if [ -z "$test_output" ] || [ "$(echo "$test_output" | wc -w | tr -d ' ')" -le 3 ]; then
        echo "FAIL: test model produced insufficient output after $test_attempt attempt(s) — cannot evaluate"
        return 1
    fi

    echo "--- Phase 2: Dual adversarial audit via adversarial-audit skill ---"

    local cross_validate_message
    cross_validate_message="Invoke adversarial-audit --task cross-validate with evaluation_criteria as a JSON array.
Each criterion has: id (short label), description, expected_result, source_reference.

Test prompt:
<test_prompt>
${test_prompt}
</test_prompt>

Agent response under audit (evidence_payload):
<agent_response>
${test_output}
</agent_response>

Evaluation criteria (pass as evaluation_criteria JSON array):
${eval_criteria}

Return the cross-validation result table with per-criterion consensus tracking."

    local validate_attempt=0
    while [ "$validate_attempt" -lt "$BEHAVIOR_MAX_RETRIES" ]; do
        validate_attempt=$((validate_attempt + 1))
        echo "  [cross-validate attempt $validate_attempt/$BEHAVIOR_MAX_RETRIES]"

        timeout "$BEHAVIOR_TIMEOUT" bash "$PROJECT_DIR/$BEHAVIOR_TEST_HOME" \
            opencode-cli run "$cross_validate_message" \
            --model "$test_model" \
            > "$log_dir/cross-validate-stdout.log" 2> "$log_dir/cross-validate-stderr.log" \
            || true

        local validate_output
        validate_output=$(cat "$log_dir/cross-validate-stdout.log" 2>/dev/null || true)
        if [ -n "$validate_output" ] && [ "$(echo "$validate_output" | wc -w | tr -d ' ')" -gt 10 ]; then
            if grep -qi 'cross.validation\|overall_consensus\|auditor_1.*auditor_2' "$log_dir/cross-validate-stdout.log" 2>/dev/null; then
                break
            fi
        fi
        if grep -qi 'sse.*timeout\|unexpected EOF\|connection reset\|model not found' "$log_dir/cross-validate-stderr.log" 2>/dev/null; then
            if [ "$validate_attempt" -lt "$BEHAVIOR_MAX_RETRIES" ]; then
                echo "  retry in ${BEHAVIOR_RETRY_DELAY}s (transient error)..."
                sleep "$BEHAVIOR_RETRY_DELAY"
            fi
        elif [ "$(echo "$validate_output" | wc -w | tr -d ' ')" -le 10 ] && [ "$validate_attempt" -lt "$BEHAVIOR_MAX_RETRIES" ]; then
            echo "  retry in ${BEHAVIOR_RETRY_DELAY}s (short output)..."
            sleep "$BEHAVIOR_RETRY_DELAY"
        fi
    done

    if [ ! -s "$log_dir/cross-validate-stdout.log" ] || [ "$(cat "$log_dir/cross-validate-stdout.log" | wc -w | tr -d ' ')" -le 10 ]; then
        echo "FAIL: cross-validate produced insufficient output — cannot extract verdicts"
        return 1
    fi

    python3 -c "
import json, os, sys, re

log_dir = '$log_dir'
f = os.path.join(log_dir, 'cross-validate-stdout.log')

try:
    with open(f) as fh:
        raw = fh.read().strip()
except OSError:
    print(json.dumps({'error': 'CROSS_VALIDATE_OUTPUT_MISSING', 'status': 'FAIL'}))
    sys.exit(0)

if not raw:
    print(json.dumps({'error': 'CROSS_VALIDATE_OUTPUT_EMPTY', 'status': 'FAIL'}))
    sys.exit(0)

def extract_json(raw):
    raw = re.sub(r'^\`\`\`(?:json)?\s*', '', raw, flags=re.MULTILINE)
    raw = re.sub(r'\s*\`\`\`$', '', raw, flags=re.MULTILINE)
    raw = raw.strip()
    start = raw.find('{')
    end = raw.rfind('}')
    if start != -1 and end != -1 and end > start:
        return raw[start:end+1]
    return raw

try:
    cleaned = extract_json(raw)
    data = json.loads(cleaned)
except (json.JSONDecodeError, ValueError):
    print(json.dumps({'error': 'CROSS_VALIDATE_PARSE_ERROR', 'status': 'FAIL', 'raw': raw[:500]}))
    sys.exit(0)

if not isinstance(data, dict):
    print(json.dumps({'error': 'UNEXPECTED_FORMAT', 'status': 'FAIL', 'received_type': str(type(data))}))
    sys.exit(0)

cross_validation = data.get('cross_validation', [])
output = []
for item in cross_validation:
    output.append({
        'id': item.get('criterion_id', 'unknown'),
        'result': item.get('consensus', 'FAIL'),
        'cross_validated': item.get('agreement', False),
        'auditor_1_result': item.get('auditor_1_result'),
        'auditor_2_result': item.get('auditor_2_result'),
        'auditor_1_evidence': item.get('auditor_1_evidence'),
        'auditor_2_evidence': item.get('auditor_2_evidence'),
    })

meta = {
    'overall_consensus': data.get('overall_consensus', 'FAIL'),
    'auditor_1_type': (data.get('auditor_1') or {}).get('type', 'unknown'),
    'auditor_2_type': (data.get('auditor_2') or {}).get('type', 'unknown'),
    'disagreements': data.get('disagreements', []),
}
output.append({'id': '__meta__', 'meta': meta})

print(json.dumps(output, indent=2))
" 
}

# Populate from opencode-cli models (authoritative — only models the
# opencode config actually knows about). Filter to ollama cloud models.
# Use shuf to prevent model selection bias from skewing test results.
HELPERS_OC_MODELS=$(opencode-cli models 2>/dev/null | grep '^ollama/.*:cloud' | shuf | head -2 || true)
mapfile -t BEHAVIORAL_MODEL_POOL <<< "$HELPERS_OC_MODELS"
unset HELPERS_OC_MODELS
if [ ${#BEHAVIORAL_MODEL_POOL[@]} -eq 0 ]; then
    echo "WARNING: no cloud models found via 'opencode-cli models' — BEHAVIORAL_MODEL_POOL empty" >&2
fi

# ============================================================
# Semantic assertion helpers
# Use an AI inspector model (different from test subject) to
# evaluate whether agent output semantically meets or violates
# a criterion, rather than pattern-matching on specific words.
#
# Inspector model must differ from test subject model to avoid
# same-model bias. Default inspector pool is configured below.
# ============================================================

BEHAVIOR_SEMANTIC_INSPECTOR_MODEL="${BEHAVIOR_SEMANTIC_INSPECTOR_MODEL:-}"
BEHAVIOR_SEMANTIC_TIMEOUT="${BEHAVIOR_SEMANTIC_TIMEOUT:-240}"

__semantic_inspector_prompt() {
    # Build the inspector prompt for semantic evaluation.
    # $1 = criterion_id (e.g., "SC-7a")
    # $2 = criterion_description (natural language description of expected behavior)
    # $3 = assertion_type ("required" or "forbidden")
    # $4 = agent_output (the test subject's response to evaluate)
    #
    # Returns a prompt string that asks the inspector to evaluate
    # whether the agent output semantically satisfies or violates
    # the criterion.
    local criterion_id="$1"
    local criterion_description="$2"
    local assertion_type="$3"
    local agent_output="$4"

    local type_instruction=""
    if [ "$assertion_type" = "forbidden" ]; then
        type_instruction="The agent's output MUST NOT semantically convey the forbidden meaning. If the agent expresses the forbidden concept in different words, it still fails. However, if the agent explicitly rejects or declines the forbidden concept (e.g., 'I must not report PASS' or 'I decline to verify with grep'), that is acceptable — the agent is describing what it refuses to do, not doing the forbidden thing."
    else
        type_instruction="The agent's output MUST semantically convey the required meaning. If the agent expresses the required concept in different words, that still passes. The criterion describes the MEANING, not specific keywords."
    fi

    cat <<SEOF
You are a semantic compliance evaluator for AI agent behavioral tests.

CRITERION: ${criterion_id}
DESCRIPTION: ${criterion_description}
ASSERTION TYPE: ${assertion_type}

${type_instruction}

AGENT OUTPUT TO EVALUATE:
---
${agent_output}
---

Evaluate whether the agent's output semantically satisfies or violates the criterion.

Respond with EXACTLY this format:
VERDICT: PASS or FAIL
REASONING: <one sentence explaining why>

Important rules:
- Focus on SEMANTIC MEANING, not keyword matching
- A prohibited concept expressed in different words still fails
- An explicit rejection or decline of a prohibited concept is acceptable (the agent is describing what it refuses to do)
- A required concept expressed in different words still passes
- Do NOT match keywords — evaluate MEANING
SEOF
}

assert_semantic() {
    # Evaluate whether agent output semantically meets or violates a criterion.
    # Uses a CLEAN-ROOM AI inspector model to avoid same-model bias.
    #
    # This is the ONLY valid assertion type for verifying agent actions, decisions,
    # and reasoning in behavioral tests (EVIDENCE_TYPE_MISMATCH per 080-code-standards.md
    # §Rule 5). grep/string assertions on agent output prose are FORBIDDEN as primary
    # evidence for behavioral SCs — they can only be used as secondary structural
    # corroboration for tool dispatch strings in stderr.
    #
    # The semantic inspector is a different model reading the output cold — no context
    # preloading, no orchestrator hints, no cached results. This is clean-room
    # behavioral verification.
    #
    # Usage:
    #   assert_semantic "SC-7a" "Agent must NOT report PASS based on file existence" "forbidden"
    #   assert_semantic "SC-7b" "Agent must report FAIL when test cannot execute" "required"
    #
    # Parameters:
    #   $1 = criterion_id (e.g., "SC-7a")
    #   $2 = criterion_description (natural language description)
    #   $3 = assertion_type ("required" or "forbidden")
    #
    # Environment variables:
    #   BEHAVIOR_SEMANTIC_INSPECTOR_MODEL - inspector model (defaults to first available cloud model different from test subject)
    #   BEHAVIOR_SEMANTIC_TIMEOUT - timeout for inspector call (default 120s)
    #   BEHAVIOR_STDOUT - path to agent output (set by behavior_run)
    #   BEHAVIOR_MODEL - test subject model (used to select different inspector)
    #
    # Returns:
    #   0 = PASS (agent output satisfies the semantic criterion)
    #   1 = FAIL (agent output violates the semantic criterion)
    #   2 = INCONCLUSIVE (model dispatch failed)
    local criterion_id="$1"
    local criterion_description="$2"
    local assertion_type="$3"

    if [ "${BEHAVIOR_DISPATCH_FAILED:-0}" = "1" ]; then
        echo "INCONCLUSIVE: assert_semantic ${criterion_id} — model dispatch failed, no behavioral evidence"
        return 2
    fi

    # Read agent output — MUST include both stdout (prose) and stderr (actions).
    # Per 080-code-standards.md §Rule 5, behavioral evidence is in stderr
    # (skill dispatches, git commands, tool calls), not just prose in stdout.
    # The inspector needs both to judge agent ACTIONS, not just narration.
    local stdout_content=""
    local stderr_content=""
    if [ -f "${BEHAVIOR_STDOUT:-/dev/null}" ]; then
        stdout_content=$(cat "$BEHAVIOR_STDOUT" 2>/dev/null || true)
    fi
    if [ -f "${BEHAVIOR_STDERR:-/dev/null}" ]; then
        stderr_content=$(cat "$BEHAVIOR_STDERR" 2>/dev/null || true)
    fi
    local agent_output=""
    if [ -n "$stderr_content" ]; then
        agent_output="=== AGENT PROSE (stdout) ===
${stdout_content}

=== AGENT ACTIONS (stderr) ===
${stderr_content}"
    else
        agent_output="${stdout_content}"
    fi

    if [ -z "$agent_output" ] || [ "$(echo "$agent_output" | wc -w | tr -d ' ')" -le 3 ]; then
        echo "INCONCLUSIVE: assert_semantic ${criterion_id} — agent output is empty or too short"
        return 2
    fi

    # Select inspector model — must differ from test subject model
    local inspector_model="${BEHAVIOR_SEMANTIC_INSPECTOR_MODEL}"
    if [ -z "$inspector_model" ]; then
        # Try to pick a model from the pool that differs from the test subject
        local test_model="${BEHAVIOR_MODEL:-ollama/glm-5.1:cloud}"
        for candidate in "${BEHAVIORAL_MODEL_POOL[@]}"; do
            if [ "$candidate" != "$test_model" ]; then
                inspector_model="$candidate"
                break
            fi
        done
        # If pool is empty or all match, fall back to a different model specification
        if [ -z "$inspector_model" ]; then
            # Use the opposite of the default: if default is cloud, use local; if local, use cloud
            case "$test_model" in
                *cloud*) inspector_model="${test_model%%:cloud}:local" ;;
                *local*) inspector_model="${test_model%%:local}:cloud" ;;
                *) inspector_model="ollama/glm-5.1:cloud" ;;
            esac
        fi
    fi

    local log_dir="$BEHAVIOR_LOG_DIR/semantic_${criterion_id}"
    mkdir -p "$log_dir"

    # Build inspector prompt
    local inspector_prompt
    inspector_prompt=$(__semantic_inspector_prompt "$criterion_id" "$criterion_description" "$assertion_type" "$agent_output")

    # Write prompt to file for debugging
    echo "$inspector_prompt" > "$log_dir/inspector-prompt.txt"

    # Run inspector model
    local attempt=0
    local max_attempts="${BEHAVIOR_MAX_RETRIES:-2}"
    local inspector_output=""

    while [ "$attempt" -lt "$max_attempts" ]; do
        attempt=$((attempt + 1))
        echo "  [semantic inspector attempt $attempt/$max_attempts, model: ${inspector_model##*/}]"

        timeout "$BEHAVIOR_SEMANTIC_TIMEOUT" bash "$PROJECT_DIR/$BEHAVIOR_TEST_HOME" \
            opencode-cli run "$inspector_prompt" \
            --model "$inspector_model" \
            > "$log_dir/inspector-stdout.log" 2> "$log_dir/inspector-stderr.log" \
            || true

        inspector_output=$(cat "$log_dir/inspector-stdout.log" 2>/dev/null || true)

        # Check for usable output
        if [ -n "$inspector_output" ] && [ "$(echo "$inspector_output" | wc -w | tr -d ' ')" -gt 5 ]; then
            # Check for verdict in output
            if echo "$inspector_output" | grep -qi 'VERDICT:*\(PASS\|FAIL\)'; then
                break
            fi
        fi

        # Check for transient errors
        if grep -qi 'sse.*timeout\|unexpected EOF\|connection reset\|ProviderModelNotFoundError\|model not found' "$log_dir/inspector-stderr.log" 2>/dev/null; then
            if [ "$attempt" -lt "$max_attempts" ]; then
                echo "  retry in ${BEHAVIOR_RETRY_DELAY}s (transient error)..."
                sleep "${BEHAVIOR_RETRY_DELAY:-15}"
                continue
            fi
        fi

        # Short output — retry
        if [ "$attempt" -lt "$max_attempts" ]; then
            echo "  retry in ${BEHAVIOR_RETRY_DELAY:-15}s (short/empty output)..."
            sleep "${BEHAVIOR_RETRY_DELAY:-15}"
        fi
    done

    # Parse inspector verdict
    local verdict=""
    verdict=$(echo "$inspector_output" | grep -i 'VERDICT:' | head -1 | sed 's/.*VERDICT://' | tr -d ' ' | tr '[:lower:]' '[:upper:]' | head -c 4)

    if [ -z "$verdict" ]; then
        # Fallback: try to detect PASS/FAIL anywhere in output
        if echo "$inspector_output" | grep -qi 'VERDICT:.*PASS'; then
            verdict="PASS"
        elif echo "$inspector_output" | grep -qi 'VERDICT:.*FAIL'; then
            verdict="FAIL"
        else
            echo "INCONCLUSIVE: assert_semantic ${criterion_id} — inspector model did not produce a VERDICT"
            echo "  Inspector model: ${inspector_model##*/}"
            echo "  Inspector output (first 200 chars): $(echo "$inspector_output" | head -c 200)"
            return 2
        fi
    fi

    # Evaluate result based on assertion type
    # For "forbidden": inspector PASS = agent did NOT express the forbidden concept = test PASS
    # For "required": inspector PASS = agent DID express the required concept = test PASS
    # For "forbidden": inspector FAIL = agent DID express the forbidden concept = test FAIL
    # For "required": inspector FAIL = agent did NOT express the required concept = test FAIL
    local test_result=""
    if [ "$verdict" = "PASS" ]; then
        if [ "$assertion_type" = "forbidden" ]; then
            # Inspector says agent output does NOT contain the forbidden concept — good
            test_result="PASS"
        else
            # Inspector says agent output DOES contain the required concept — good
            test_result="PASS"
        fi
    else
        if [ "$assertion_type" = "forbidden" ]; then
            # Inspector says agent output DOES contain the forbidden concept — bad
            test_result="FAIL"
        else
            # Inspector says agent output does NOT contain the required concept — bad
            test_result="FAIL"
        fi
    fi

    local reasoning=""
    reasoning=$(echo "$inspector_output" | grep -i 'REASONING:' | head -1 | sed 's/.*REASONING://' | sed 's/^ *//')

    if [ "$test_result" = "PASS" ]; then
        echo "PASS: assert_semantic ${criterion_id} — ${assertion_type} criterion satisfied (inspector: ${inspector_model##*/})"
        echo "  Reasoning: ${reasoning:-inspector validated semantic compliance}"
        return 0
    else
        echo "FAIL: assert_semantic ${criterion_id} — ${assertion_type} criterion violated (inspector: ${inspector_model##*/})"
        echo "  Criterion: ${criterion_description}"
        echo "  Reasoning: ${reasoning:-inspector flagged semantic violation}"
        return 1
    fi
}

assert_semantic_all_models() {
    # Variant that runs assert_semantic against each model in the behavioral pool.
    # Returns 0 only if ALL models pass the semantic criterion.
    # Returns 1 if ANY model fails.
    # Returns 2 if ALL model dispatches failed (INCONCLUSIVE).
    local criterion_id="$1"
    local criterion_description="$2"
    local assertion_type="$3"

    if [ "${BEHAVIOR_DISPATCH_FAILED:-0}" = "1" ]; then
        echo "INCONCLUSIVE: assert_semantic_all_models ${criterion_id} — all model dispatches failed"
        return 2
    fi

    local overall=0
    for model in "${BEHAVIORAL_MODEL_POOL[@]}"; do
        local log_file="${BEHAVIOR_POOL_OUTPUTS[$model]:-/dev/null}"
        # Temporarily set BEHAVIOR_STDOUT to this model's output
        local saved_stdout="${BEHAVIOR_STDOUT}"
        export BEHAVIOR_STDOUT="$log_file"

        assert_semantic "$criterion_id" "$criterion_description" "$assertion_type" || overall=1

        export BEHAVIOR_STDOUT="$saved_stdout"
    done

    return $overall
}

# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

behavior_run_pool() {
    # Run a behavioral prompt against every model in BEHAVIORAL_MODEL_POOL.
    # Usage: behavior_run_pool "$scenario_name" "$prompt"
    # Stores outputs per model in BEHAVIOR_POOL_OUTPUTS[model_name]=stdout_path
    # Returns 0 if ANY model produced usable output, 1 if ALL failed.
    local scenario_name="$1"
    local message="$2"

    declare -gA BEHAVIOR_POOL_OUTPUTS
    declare -gA BEHAVIOR_POOL_STDERRS
    local any_success=0

    for model in "${BEHAVIORAL_MODEL_POOL[@]}"; do
        local safe_model_name
        safe_model_name=$(echo "$model" | tr '/:' '_')
        local model_scenario="${scenario_name}_${safe_model_name}"

        local display_name="${model#ollama/}"
        echo "  === Testing with model: $display_name ==="
        behavior_run "$model_scenario" "$message" "$model" "$PROJECT_DIR"

        BEHAVIOR_POOL_OUTPUTS["$model"]="$BEHAVIOR_STDOUT"
        BEHAVIOR_POOL_STDERRS["$model"]="$BEHAVIOR_STDERR"

        if [ "${BEHAVIOR_DISPATCH_FAILED:-0}" = "0" ]; then
            any_success=1
        fi
    done

    export BEHAVIOR_POOL_OUTPUTS BEHAVIOR_POOL_STDERRS
    return $((1 - any_success))
}

assert_forbidden_pattern_absent_all_models() {
    # Assert that a forbidden pattern is absent in ALL model outputs.
    # Returns 0 only if ALL models pass (no forbidden pattern found).
    # Returns 1 if ANY model output contains the forbidden pattern.
    local pattern="$1"
    local description="${2:-forbidden pattern}"

    if [ "${BEHAVIOR_DISPATCH_FAILED:-0}" = "1" ]; then
        echo "INCONCLUSIVE: assert_forbidden_pattern_absent_all_models — all model dispatches failed"
        return 2
    fi

    local overall=0
    for model in "${BEHAVIORAL_MODEL_POOL[@]}"; do
        local log_file="${BEHAVIOR_POOL_OUTPUTS[$model]:-/dev/null}"
        local count
        count=$(grep -cE "$pattern" "$log_file" 2>/dev/null || true)
        count=${count:-0}
        count=$(echo "$count" | head -1 | tr -d '[:space:]')
        if [ "$count" -gt 0 ]; then
            echo "FAIL: [$model] — found $count occurrence(s) of $description in agent output"
            overall=1
        else
            echo "PASS: [$model] — $description not found in agent output"
        fi
    done

    return $overall
}

assert_required_pattern_present_all_models() {
    # Assert that a required pattern is present in ALL model outputs.
    # Returns 0 only if ALL models have at least one match.
    # Returns 1 if ANY model output is missing the pattern.
    local pattern="$1"
    local description="${2:-required pattern}"

    if [ "${BEHAVIOR_DISPATCH_FAILED:-0}" = "1" ]; then
        echo "INCONCLUSIVE: assert_required_pattern_present_all_models — all model dispatches failed"
        return 2
    fi

    local overall=0
    for model in "${BEHAVIORAL_MODEL_POOL[@]}"; do
        local log_file="${BEHAVIOR_POOL_OUTPUTS[$model]:-/dev/null}"
        local count
        count=$(grep -cE "$pattern" "$log_file" 2>/dev/null || true)
        count=${count:-0}
        count=$(echo "$count" | head -1 | tr -d '[:space:]')
        if [ "$count" -eq 0 ]; then
            echo "FAIL: [$model] — $description not found in agent output"
            overall=1
        else
            echo "PASS: [$model] — $description found $count time(s) in agent output"
        fi
    done

    return $overall
}


# ============================================================
# Stderr-based assertion helpers
# Behavioral evidence = agent actions visible in stderr (skill
# dispatches, file reads, sub-agent task() calls, tool invocations).
# Prose recall (what the agent says in stdout when asked to describe
# a procedure) is NOT behavioral evidence.
# ============================================================

# EVIDENCE TYPE: string — ONLY valid as SECONDARY structural corroboration
# for behavioral SCs (confirms a tool dispatch occurred). NEVER use as
# primary evidence for behavioral SCs — use assert_semantic instead.
# For string/structural SCs, this assertion IS sufficient as primary evidence.
# See 080-code-standards.md §Rule 5 for the evidence type hierarchy.
assert_stderr_pattern_present() {
    if [ "${BEHAVIOR_DISPATCH_FAILED:-0}" = "1" ]; then
        echo "INCONCLUSIVE: assert_stderr_pattern_present — model dispatch failed, no behavioral evidence"
        return 2
    fi
    local pattern="$1"
    local description="${2:-required stderr pattern}"
    local log_file="${BEHAVIOR_STDERR:-/dev/null}"
    local count
    count=$(grep -cE "$pattern" "$log_file" 2>/dev/null || true)
    count=${count:-0}
    count=$(echo "$count" | head -1 | tr -d '[:space:]')
    if [ "$count" -eq 0 ]; then
        echo "FAIL: assert_stderr_pattern_present — $description not found in stderr"
        return 1
    fi
    echo "PASS: assert_stderr_pattern_present — $description found $count time(s) in stderr"
    return 0
}

# EVIDENCE TYPE: string — ONLY valid as SECONDARY structural corroboration
# for behavioral SCs (confirms a prohibited tool dispatch did NOT occur).
# NEVER use as primary evidence for behavioral SCs — use assert_semantic instead.
# For string/structural SCs, this assertion IS sufficient as primary evidence.
# See 080-code-standards.md §Rule 5 for the evidence type hierarchy.
assert_stderr_pattern_absent() {
    if [ "${BEHAVIOR_DISPATCH_FAILED:-0}" = "1" ]; then
        echo "INCONCLUSIVE: assert_stderr_pattern_absent — model dispatch failed, no behavioral evidence"
        return 2
    fi
    local pattern="$1"
    local description="${2:-forbidden stderr pattern}"
    local log_file="${BEHAVIOR_STDERR:-/dev/null}"
    local count
    count=$(grep -cE "$pattern" "$log_file" 2>/dev/null || true)
    count=${count:-0}
    count=$(echo "$count" | head -1 | tr -d '[:space:]')
    if [ "$count" -gt 0 ]; then
        echo "FAIL: assert_stderr_pattern_absent — found $count occurrence(s) of $description in stderr"
        return 1
    fi
    echo "PASS: assert_stderr_pattern_absent — $description not found in stderr"
    return 0
}

assert_stderr_pattern_present_all_models() {
    local pattern="$1"
    local description="${2:-required stderr pattern}"
    if [ "${BEHAVIOR_DISPATCH_FAILED:-0}" = "1" ]; then
        echo "INCONCLUSIVE: assert_stderr_pattern_present_all_models — all model dispatches failed"
        return 2
    fi
    local overall=0
    for model in "${BEHAVIORAL_MODEL_POOL[@]}"; do
        local log_file="${BEHAVIOR_POOL_STDERRS[$model]:-/dev/null}"
        local count
        count=$(grep -cE "$pattern" "$log_file" 2>/dev/null || true)
        count=${count:-0}
        count=$(echo "$count" | head -1 | tr -d '[:space:]')
        if [ "$count" -eq 0 ]; then
            echo "FAIL: [$model] — $description not found in stderr"
            overall=1
        else
            echo "PASS: [$model] — $description found $count time(s) in stderr"
        fi
    done
    return $overall
}

assert_stderr_pattern_absent_all_models() {
    local pattern="$1"
    local description="${2:-forbidden stderr pattern}"
    if [ "${BEHAVIOR_DISPATCH_FAILED:-0}" = "1" ]; then
        echo "INCONCLUSIVE: assert_stderr_pattern_absent_all_models — all model dispatches failed"
        return 2
    fi
    local overall=0
    for model in "${BEHAVIORAL_MODEL_POOL[@]}"; do
        local log_file="${BEHAVIOR_POOL_STDERRS[$model]:-/dev/null}"
        local count
        count=$(grep -cE "$pattern" "$log_file" 2>/dev/null || true)
        count=${count:-0}
        count=$(echo "$count" | head -1 | tr -d '[:space:]')
        if [ "$count" -gt 0 ]; then
            echo "FAIL: [$model] — found $count occurrence(s) of $description in stderr"
            overall=1
        else
            echo "PASS: [$model] — $description not found in stderr"
        fi
    done
    return $overall
}

# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)