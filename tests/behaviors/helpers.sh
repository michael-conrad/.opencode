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

BEHAVIOR_TIMEOUT="${BEHAVIOR_TIMEOUT:-120}"
BEHAVIOR_MODEL="${BEHAVIOR_MODEL:-ollama/glm-5.1:cloud}"
BEHAVIOR_TEST_HOME="${BEHAVIOR_TEST_HOME:-.opencode/tests/with-test-home}"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"
BEHAVIOR_LOG_DIR="${BEHAVIOR_LOG_DIR:-$PROJECT_DIR/.opencode/tmp/behavior-test-$(date +%Y%m%d-%H%M%S)}"

BEHAVIOR_MAX_RETRIES="${BEHAVIOR_MAX_RETRIES:-3}"
BEHAVIOR_RETRY_DELAY="${BEHAVIOR_RETRY_DELAY:-15}"

behavior_run() {
    local scenario_name="$1"
    local message="$2"
    local model="${3:-${BEHAVIOR_MODEL}}"
    local log_dir="$BEHAVIOR_LOG_DIR/$scenario_name"
    mkdir -p "$log_dir"

    local attempt=0
    local output_file="$log_dir/stdout.log"
    local err_file="$log_dir/stderr.log"

    while [ "$attempt" -lt "$BEHAVIOR_MAX_RETRIES" ]; do
        attempt=$((attempt + 1))
        echo "  [attempt $attempt/$BEHAVIOR_MAX_RETRIES]"

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

    sleep 1

    BEHAVIOR_STDOUT="$log_dir/stdout.log"
    BEHAVIOR_STDERR="$log_dir/stderr.log"
}

behavior_get_stdout() {
    cat "$BEHAVIOR_STDOUT"
}

behavior_get_stderr() {
    cat "$BEHAVIOR_STDERR"
}

assert_tool_calls_made() {
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

    local auditors=()
    local test_short
    test_short=$(echo "$test_model" | sed 's|ollama/||')
    if [ -n "$auditor_pool" ]; then
        local shuffled
        shuffled=$(echo "$auditor_pool" | tr ' ' '\n' | grep -v "$test_short" | shuf)
        while IFS= read -r line; do
            [ -n "$line" ] && auditors+=("ollama/$line")
        done <<< "$shuffled"
        auditors=("${auditors[@]:0:2}")
    fi

    if [ ${#auditors[@]} -lt 2 ]; then
        local static_pool
        static_pool=$("$PROJECT_DIR/.opencode/tests/qualification/qualified-auditor-pool.sh" 2>/dev/null | shuf || true)
        if [ -n "$static_pool" ]; then
            while IFS= read -r line; do
                [ -n "$line" ] && [ "$line" != "$test_short" ] && auditors+=("ollama/$line")
            done <<< "$static_pool"
            auditors=("${auditors[@]:0:2}")
        fi
    fi

    echo "--- Phase 2: Dual adversarial audit ---"
    echo "    Auditor 1: ${auditors[0]}"
    echo "    Auditor 2: ${auditors[1]}"

    local eval_prompt_file
    for i in 0 1; do
        local idx=$((i + 1))
        eval_prompt_file="$log_dir/eval-$idx-prompt.txt"
        printf '%s' "You are an adversarial auditor. Your sole function is to judge whether another AI agent followed a specific rule.

Here is the prompt that was sent to the agent being audited:

<test_prompt>
${test_prompt}
</test_prompt>

Here is the agent's response:

<agent_response>
${test_output}
</agent_response>

Evaluate the agent's response against these criteria:

${eval_criteria}

Return ONLY a JSON array of objects with fields: \"id\" (short label), \"result\" (\"PASS\" or \"FAIL\"), and \"explanation\" (one sentence). No other text." > "$eval_prompt_file"

        echo "    --- Auditor $idx (${auditors[$i]}) ---"
        local auditor_attempt=0
        while [ "$auditor_attempt" -lt "$BEHAVIOR_MAX_RETRIES" ]; do
            auditor_attempt=$((auditor_attempt + 1))
            echo "      [auditor $idx attempt $auditor_attempt/$BEHAVIOR_MAX_RETRIES]"

            timeout "$BEHAVIOR_TIMEOUT" bash "$PROJECT_DIR/$BEHAVIOR_TEST_HOME" \
                opencode-cli run "$(cat "$eval_prompt_file")" \
                --model "${auditors[$i]}" \
                > "$log_dir/eval-$idx-stdout.log" 2> "$log_dir/eval-$idx-stderr.log" \
                || true

            local auditor_output
            auditor_output=$(cat "$log_dir/eval-$idx-stdout.log" 2>/dev/null || true)
            if [ -n "$auditor_output" ] && [ "$(echo "$auditor_output" | wc -w | tr -d ' ')" -gt 5 ]; then
                break
            fi
            if grep -qi 'sse.*timeout\|unexpected EOF\|connection reset\|model not found' "$log_dir/eval-$idx-stderr.log" 2>/dev/null; then
                if [ "$auditor_attempt" -lt "$BEHAVIOR_MAX_RETRIES" ]; then
                    echo "      retry in ${BEHAVIOR_RETRY_DELAY}s (transient error)..."
                    sleep "$BEHAVIOR_RETRY_DELAY"
                fi
            elif [ "$(echo "$auditor_output" | wc -w | tr -d ' ')" -le 5 ] && [ "$auditor_attempt" -lt "$BEHAVIOR_MAX_RETRIES" ]; then
                echo "      retry in ${BEHAVIOR_RETRY_DELAY}s (short output)..."
                sleep "$BEHAVIOR_RETRY_DELAY"
            fi
        done
    done

    python3 -c "
import json, os, sys, re

def extract_json(raw):
    # strip markdown fences
    raw = re.sub(r'^\`\`\`(?:json)?\s*', '', raw, flags=re.MULTILINE)
    raw = re.sub(r'\s*\`\`\`$', '', raw, flags=re.MULTILINE)
    raw = raw.strip()
    # find JSON array boundaries
    start = raw.find('[')
    end = raw.rfind(']')
    if start != -1 and end != -1 and end > start:
        return raw[start:end+1]
    # find JSON object boundaries (single object)
    start = raw.find('{')
    end = raw.rfind('}')
    if start != -1 and end != -1 and end > start:
        return raw[start:end+1]
    return raw

log_dir = '$log_dir'
results = {}

for i in [1, 2]:
    f = os.path.join(log_dir, f'eval-{i}-stdout.log')
    try:
        with open(f) as fh:
            raw = fh.read().strip()
        if not raw:
            print(f'// Auditor {i}: empty output', file=sys.stderr)
            continue
        cleaned = extract_json(raw)
        data = json.loads(cleaned)
        if not isinstance(data, list):
            data = [data]
        for r in data:
            rid = r.get('id', 'unknown')
            if rid not in results:
                results[rid] = {'auditor1': None, 'auditor2': None, 'explanations': []}
            key = f'auditor{i}'
            results[rid][key] = r.get('result', 'FAIL')
            results[rid]['explanations'].append(r.get('explanation', ''))
    except Exception as e:
        print(f'// Parse error auditor {i}: {e}', file=sys.stderr)

output = []
for rid, v in sorted(results.items()):
    if v['auditor1'] == v['auditor2'] and v['auditor1'] is not None:
        output.append({
            'id': rid,
            'result': v['auditor1'],
            'cross_validated': True,
            'auditor1': '${auditors[0]}',
            'auditor2': '${auditors[1]}',
            'explanations': v['explanations']
        })
    elif v['auditor1'] is not None or v['auditor2'] is not None:
        output.append({
            'id': rid,
            'result': 'INCONCLUSIVE',
            'cross_validated': False,
            'auditor1_result': v['auditor1'],
            'auditor2_result': v['auditor2'],
            'auditor1': '${auditors[0]}',
            'auditor2': '${auditors[1]}',
            'explanations': v['explanations']
        })

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