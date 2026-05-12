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

BEHAVIOR_TIMEOUT="${BEHAVIOR_TIMEOUT:-300}"
BEHAVIOR_MODEL="${BEHAVIOR_MODEL:-ollama/glm-5.1:cloud}"
BEHAVIOR_TEST_HOME="${BEHAVIOR_TEST_HOME:-.opencode/tests/with-test-home}"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"
BEHAVIOR_LOG_DIR="${BEHAVIOR_LOG_DIR:-$PROJECT_DIR/tmp/behavior-test-$(date +%Y%m%d-%H%M%S)}"

BEHAVIOR_MAX_RETRIES="${BEHAVIOR_MAX_RETRIES:-2}"
BEHAVIOR_RETRY_DELAY="${BEHAVIOR_RETRY_DELAY:-15}"

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
    if [ -z "$workdir" ]; then
        workdir=$(mktemp -d "$PROJECT_DIR/tmp/behavior-isolated-XXXXXX")
        git init -q "$workdir"
        git -C "$workdir" config user.email "test@test.dev"
        git -C "$workdir" config user.name "Test"
        git -C "$workdir" commit -q --allow-empty -m "init"
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
        if [ -n "$output" ]; then
            local word_count
            word_count=$(echo "$output" | wc -w | tr -d ' ')
            if [ "${word_count:-0}" -gt 3 ]; then
                break
            fi
        fi

        if grep -qi 'sse.*timeout\|unexpected EOF\|connection reset\|ProviderModelNotFoundError\|model not found' "$err_file" 2>/dev/null; then
            if [ "$attempt" -lt "$BEHAVIOR_MAX_RETRIES" ]; then
                echo "  retry in ${BEHAVIOR_RETRY_DELAY}s (transient error)..."
                sleep "$BEHAVIOR_RETRY_DELAY"
                continue
            fi
        fi

        if [ "${word_count:-0}" -le 3 ]; then
            if [ "$attempt" -lt "$BEHAVIOR_MAX_RETRIES" ]; then
                echo "  retry in ${BEHAVIOR_RETRY_DELAY}s (empty/short output)..."
                sleep "$BEHAVIOR_RETRY_DELAY"
                continue
            fi
        fi
    done

    local output
    output=$(cat "$output_file" 2>/dev/null || true)
    local word_count
    word_count=$(echo "$output" | wc -w | tr -d ' ')
    if [ -z "$output" ] || [ "${word_count:-0}" -le 3 ]; then
        if grep -qi 'sse.*timeout\|unexpected EOF\|connection reset\|ProviderModelNotFoundError\|model not found' "$err_file" 2>/dev/null; then
            echo "HARNESS_FAILURE: model dispatch failed (timeout or provider error)"
            echo "HARNESS_FAILURE: model dispatch failed (timeout or provider error)" >> "$output_file"
            export BEHAVIOR_DISPATCH_FAILED=1
        fi
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
        count=$(grep -c "$pattern" "$log_file" 2>/dev/null || true)
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
    count=$(grep -c "$pattern" "$log_file" 2>/dev/null || true)
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
    count=$(grep -c "$pattern" "$log_file" 2>/dev/null || true)
    count=${count:-0}
    count=$(echo "$count" | head -1 | tr -d '[:space:]')
    if [ "$count" -eq 0 ]; then
        echo "FAIL: assert_required_pattern_present — $description not found in agent output"
        return 1
    fi
    echo "PASS: assert_required_pattern_present — $description found $count time(s) in agent output"
    return 0
}

assert_skill_invoked() {
    if [ "${BEHAVIOR_DISPATCH_FAILED:-0}" = "1" ]; then
        echo "INCONCLUSIVE: assert_skill_invoked — model dispatch failed, no behavioral evidence"
        return 2
    fi
    local expected_skill="$1"
    local log_file="${BEHAVIOR_STDERR:-/dev/null}"
    local found
    found=$(grep -c "Skill \"$expected_skill\"" "$log_file" 2>/dev/null || true)
    found=${found:-0}
    found=$(echo "$found" | head -1 | tr -d '[:space:]')
    if [ "$found" -eq 0 ]; then
        found=$(grep -oi "$expected_skill" "$BEHAVIOR_STDOUT" 2>/dev/null | head -1 | wc -l || echo "0")
    fi
    if [ "$found" -eq 0 ]; then
        echo "FAIL: assert_skill_invoked — expected skill '$expected_skill' was not invoked"
        return 1
    fi
    echo "PASS: assert_skill_invoked — skill '$expected_skill' was invoked"
    return 0
}

assert_no_skill_invoked() {
    if [ "${BEHAVIOR_DISPATCH_FAILED:-0}" = "1" ]; then
        echo "INCONCLUSIVE: assert_no_skill_invoked — model dispatch failed, no behavioral evidence"
        return 2
    fi
    local forbidden_skill="$1"
    local log_file="${BEHAVIOR_STDERR:-/dev/null}"
    local found
    found=$(grep -c "Skill \"$forbidden_skill\"" "$log_file" 2>/dev/null || true)
    found=${found:-0}
    found=$(echo "$found" | head -1 | tr -d '[:space:]')
    if [ "$found" -gt 0 ]; then
        echo "FAIL: assert_no_skill_invoked — forbidden skill '$forbidden_skill' was invoked ($found time(s))"
        return 1
    fi
    found=$(grep -ci "$forbidden_skill" "$BEHAVIOR_STDOUT" 2>/dev/null || true)
    found=${found:-0}
    found=$(echo "$found" | head -1 | tr -d '[:space:]')
    if [ "$found" -gt 0 ]; then
        echo "FAIL: assert_no_skill_invoked — forbidden skill '$forbidden_skill' found in output ($found time(s))"
        return 1
    fi
    echo "PASS: assert_no_skill_invoked — skill '$forbidden_skill' was not invoked"
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

behavior_resolve_model() {
    local resolve_tool="$PROJECT_DIR/.opencode/tools/ollama-model-resolve"
    if [ -x "$resolve_tool" ]; then
        local model_info
        model_info=$("$resolve_tool" --target enforcement 2>/dev/null || true)
        if [ -n "$model_info" ]; then
            BEHAVIOR_LOCAL_MODEL=$(echo "$model_info" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('selected',{}).get('name','ollama-cloud/glm-5.1'))" 2>/dev/null || echo "ollama-cloud/glm-5.1")
            BEHAVIOR_CLOUD_MODEL=$(echo "$model_info" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('fallback',{}).get('name','ollama-cloud/deepseek-v4-pro'))" 2>/dev/null || echo "ollama-cloud/deepseek-v4-pro")
            export BEHAVIOR_LOCAL_MODEL BEHAVIOR_CLOUD_MODEL
        else
            BEHAVIOR_LOCAL_MODEL="${BEHAVIOR_LOCAL_MODEL:-ollama-cloud/glm-5.1}"
            BEHAVIOR_CLOUD_MODEL="${BEHAVIOR_CLOUD_MODEL:-ollama-cloud/deepseek-v4-pro}"
            export BEHAVIOR_LOCAL_MODEL BEHAVIOR_CLOUD_MODEL
        fi
    else
        BEHAVIOR_LOCAL_MODEL="${BEHAVIOR_LOCAL_MODEL:-ollama-cloud/glm-5.1}"
        BEHAVIOR_CLOUD_MODEL="${BEHAVIOR_CLOUD_MODEL:-ollama-cloud/deepseek-v4-pro}"
        export BEHAVIOR_LOCAL_MODEL BEHAVIOR_CLOUD_MODEL
    fi
}