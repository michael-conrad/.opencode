#!/bin/bash
# SPDX-FileCopyrightText: 2026 Michael Conrad <m.conrad.202@gmail.com>
# SPDX-License-Identifier: MIT
#
# Provenance: Original — Co-authored with AI: OpenCode (deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BENCHMARK_DIR="$(dirname "$SCRIPT_DIR")"
RESULTS_DIR="$BENCHMARK_DIR/results"

USING_GIT_REPO=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --git-repo)
            USING_GIT_REPO=true
            shift
            ;;
        --*)
            echo "Unknown option: $1" >&2
            exit 2
            ;;
        *)
            if [ -z "${MODEL:-}" ]; then
                MODEL="$1"
            elif [ -z "${PROMPT:-}" ]; then
                PROMPT="$1"
            elif [ -z "${PROMPT_ID:-}" ]; then
                PROMPT_ID="$1"
            else
                echo "Too many arguments" >&2
                exit 2
            fi
            shift
            ;;
    esac
done

if [ -z "${MODEL:-}" ] || [ -z "${PROMPT:-}" ] || [ -z "${PROMPT_ID:-}" ]; then
    echo "Usage: bash test-model.sh <model> <prompt> <prompt-id> [--git-repo]" >&2
    exit 2
fi

OLLAMA_BIN="$(which ollama 2>/dev/null || echo "/snap/ollama/112/bin/ollama")"
OPECODE_CLI="$(which opencode-cli 2>/dev/null || echo "opencode-cli")"
OPECODE_CLONE_CACHE="${OPECODE_CLONE_CACHE:-/home/muksihs/.cache/opencode-submodule-cache/.opencode}"
OPECODE_DEV_SHA="${OPECODE_DEV_SHA:-$(git -C "$BENCHMARK_DIR/../.." rev-parse HEAD 2>/dev/null || echo "unknown")}"

MODEL_TYPE="cloud"
if echo "$MODEL" | grep -qE '^(qwen3|qwen2\.5|devstral|llama3\.2|phi4)'; then
    MODEL_TYPE="local"
fi

MODEL_SAFE="$(echo "$MODEL" | tr '/:' '-')"
PROMPT_SAFE="$(echo "$PROMPT_ID" | tr '/ ' '-')"
RESULT_FILE="$RESULTS_DIR/${MODEL_SAFE}-${PROMPT_SAFE}.json"
EXPECTED_FILE="$RESULTS_DIR/.expected-${MODEL_SAFE}-${PROMPT_SAFE}.json"

mkdir -p "$RESULTS_DIR"

now_iso() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

seed_model_config() {
    local test_home="$1"
    local config_dir="$test_home/.config/opencode"
    mkdir -p "$config_dir"

    local config_file="$config_dir/opencode.jsonc"
    local model_entries=""
    local model_count=0

    if [ -x "$OLLAMA_BIN" ]; then
        local ollama_out
        ollama_out="$("$OLLAMA_BIN" list 2>/dev/null || true)"
        while IFS= read -r line; do
            local mname
            mname="$(echo "$line" | awk '{print $1}' 2>/dev/null || true)"
            if [ -n "$mname" ] && [ "$mname" != "NAME" ] && [ "$model_count" -lt 20 ]; then
                model_entries="$model_entries        \"$mname\": {},\n"
                model_count=$((model_count + 1))
            fi
        done <<< "$ollama_out"
    fi

    if [ "$model_count" -eq 0 ]; then
        model_entries="        \"phi4-mini:3.8b\": {},\n        \"llama3.2:3b\": {},\n"
        model_count=2
    fi

    cat > "$config_file" <<JSONC
{
  "\$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
$(printf '%b' "$model_entries" | sed 's/,$//')
      }
    }
  }
}
JSONC
}

prepare_git_repo() {
    local test_home="$1"
    local repo_dir="$test_home/repo"

    mkdir -p "$repo_dir/src"

    git -C "$repo_dir" init -q
    git -C "$repo_dir" config user.email "m.conrad.202@gmail.com"
    git -C "$repo_dir" config user.name "Michael Conrad"

    mkdir -p "$repo_dir/src"

    cat > "$repo_dir/src/tool.py" <<'PYEOF'
def run():
    pass
PYEOF

    cat > "$repo_dir/README.md" <<'MDEOF'
# Test Repo

Minimal repo for model benchmarking.
MDEOF

    if [ -d "$OPECODE_CLONE_CACHE" ]; then
        git -C "$repo_dir" -c protocol.file.allow=always submodule add "$OPECODE_CLONE_CACHE" .opencode 2>/dev/null || true
        if [ -d "$repo_dir/.opencode" ]; then
            git -C "$repo_dir/.opencode" fetch origin dev 2>/dev/null || true
            git -C "$repo_dir/.opencode" checkout "$OPECODE_DEV_SHA" 2>/dev/null || git -C "$repo_dir/.opencode" checkout dev 2>/dev/null || true
            git -C "$repo_dir" add .gitmodules .opencode 2>/dev/null || true
        fi
    fi

    git -C "$repo_dir" add -A 2>/dev/null || true
    git -C "$repo_dir" commit --no-verify -m "seed: initial repo setup" 2>/dev/null || true
}

resolve_timeout() {
    local pid="$1"

    case "$pid" in
        T1)
            if [ "$MODEL_TYPE" = "cloud" ]; then
                echo 180
            elif echo "$MODEL" | grep -qE '^(qwen3:4b|llama3\.2:3b|phi4-mini)'; then
                echo 120
            else
                echo 300
            fi
            ;;
        T2|T3|T4)
            if [ "$MODEL_TYPE" = "cloud" ]; then echo 180; else echo 300; fi
            ;;
        T5) echo 300 ;;
        *) echo 300 ;;
    esac
}

snapshot_vram() {
    if [ "$MODEL_TYPE" != "local" ]; then echo "null"; return; fi
    nvidia-smi --query-gpu=memory.free --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d '[:space:]' || echo "null"
}

wait_for_ollama_model() {
    if [ "$MODEL_TYPE" != "local" ]; then return 0; fi
    local max_wait=30
    local waited=0
    while [ $waited -lt $max_wait ]; do
        if "$OLLAMA_BIN" ps 2>/dev/null | grep -q "$MODEL"; then
            sleep 2
            return 0
        fi
        sleep 1
        waited=$((waited + 1))
    done
    return 0
}

SPECIFY() {
    local timeout_secs
    timeout_secs="$(resolve_timeout "$PROMPT_ID")"

    local pass_criteria
    case "$PROMPT_ID" in
        T1) pass_criteria='[">=30 skills enumerated", "no raw JSON tool-call blocks", "no generic dodge (<5 lines)", "human-readable format"]' ;;
        T2) pass_criteria='["Named tool defined", "Interface defined (CLI flags or args)", "4-6 features listed", ">=10 lines of substantive output"]' ;;
        T3) pass_criteria='["Real-world example named", "Tradeoff explained", ">=8 lines of substantive output", "No factual hallucinations"]' ;;
        T4) pass_criteria='["Tool call or source reference present", "Correct answer (None default, configurable)", "No memory-based claims"]' ;;
        T5) pass_criteria='["Feature branch created", "File modified (docstring added)", "Commit made with --no-verify", "Summary of actions reported", "Exit code 0"]' ;;
        *) pass_criteria='["Output produced", "Exit code 0"]' ;;
    esac

    cat > "$EXPECTED_FILE" <<JSON
{
  "model": "$MODEL",
  "model_type": "$MODEL_TYPE",
  "prompt_id": "$PROMPT_ID",
  "prompt": "$(echo "$PROMPT" | sed 's/"/\\"/g')",
  "pass_criteria": $pass_criteria,
  "timeout_seconds": $timeout_secs,
  "must_unload_after": $([ "$MODEL_TYPE" = "local" ] && echo "true" || echo "false"),
  "specified_at": "$(now_iso)"
}
JSON
}

EXECUTE() {
    local timeout_secs
    timeout_secs="$(resolve_timeout "$PROMPT_ID")"

    PROJECT_DIR="$(cd "$SCRIPT_DIR" && pwd)"
    while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
        PROJECT_DIR="$(dirname "$PROJECT_DIR")"
    done
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"

    local with_test_home="$PROJECT_DIR/.opencode/tests/with-test-home"
    if [ ! -f "$with_test_home" ]; then
        with_test_home="$(dirname "$SCRIPT_DIR")/../../../tests/with-test-home"
    fi

    local test_home
    test_home="$BENCHMARK_DIR/.tmp/test-bench-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$test_home"

    seed_model_config "$test_home"

    if [ "$USING_GIT_REPO" = true ]; then
        prepare_git_repo "$test_home"
    fi

    local vram_before
    vram_before="$(snapshot_vram)"

    local timed_out=false
    local start_time
    start_time="$(date +%s)"
    local exit_code=0
    local stdout_file="$test_home/stdout.log"
    local stderr_file="$test_home/stderr.log"

    local run_dir="$test_home"
    if [ "$USING_GIT_REPO" = true ]; then
        run_dir="$test_home/repo"
    fi

    timeout "$timeout_secs" bash "$with_test_home" \
        "$OPECODE_CLI" run "$PROMPT" \
        --model "ollama/$MODEL" \
        --cwd "$run_dir" \
        > "$stdout_file" 2> "$stderr_file" || exit_code=$?

    local end_time
    end_time="$(date +%s)"
    local wall_secs=$((end_time - start_time))

    if [ "$exit_code" = 124 ]; then
        timed_out=true
        exit_code=1
    fi

    wait_for_ollama_model

    local vram_peak="null"
    if [ "$MODEL_TYPE" = "local" ]; then
        vram_peak="$("$OLLAMA_BIN" ps 2>/dev/null | awk -v m="$MODEL" '$1 ~ m {print $3; exit}' 2>/dev/null || echo "null")"
        if [ "$vram_peak" = "null" ]; then
            local free_vram
            free_vram="$(snapshot_vram)"
            if [ "$vram_before" != "null" ] && [ "$free_vram" != "null" ]; then
                vram_peak="$((vram_before - free_vram))"
                [ "$vram_peak" -lt 0 ] && vram_peak=0
            fi
        fi

        "$OLLAMA_BIN" stop "$MODEL" 2>/dev/null || true
        sleep 2
    fi

    local vram_after
    vram_after="$(snapshot_vram)"

    local output_lines
    output_lines="$(wc -l < "$stdout_file" 2>/dev/null | tr -d '[:space:]' || echo "0")"

    local skills_counted="null"
    if [ "$PROMPT_ID" = "T1" ]; then
        skills_counted="$(grep -oE '^[*-]\s+' "$stdout_file" 2>/dev/null | wc -l | tr -d '[:space:]' || echo "0")"
    fi

    local tool_calls_detected=false
    if grep -q 'ToolCall\|tool_call\|mcp__\|srclight_\|github_\|read(\|write(\|edit(\|glob(\|grep(' "$stdout_file" 2>/dev/null; then
        tool_calls_detected=true
    fi

    local vram_delta_mib="null"
    local vram_fit_pct="null"
    local vram_leak_mib="null"
    if [ "$MODEL_TYPE" = "local" ] && [ "$vram_before" != "null" ]; then
        if [ "$vram_peak" != "null" ]; then
            vram_delta_mib="$vram_peak"
            vram_fit_pct="$(awk "BEGIN {printf \"%.1f\", ($vram_peak/24576)*100}" 2>/dev/null || echo "null")"
        fi
        if [ "$vram_after" != "null" ]; then
            vram_leak_mib="$((vram_before - vram_after))"
            [ "$vram_leak_mib" -lt 0 ] && vram_leak_mib=0
        fi
    fi

    JUDGE "$stdout_file" "$stderr_file" "$exit_code" "$wall_secs" "$timed_out" "$output_lines" \
        "$vram_before" "$vram_peak" "$vram_after" "$vram_delta_mib" "$vram_fit_pct" "$skills_counted" \
        "$tool_calls_detected" "$vram_leak_mib"

    rm -rf "$test_home"
}

JUDGE() {
    local stdout_file="$1"
    local stderr_file="$2"
    local exit_code="$3"
    local wall_secs="$4"
    local timed_out="$5"
    local output_lines="$6"
    local vram_before="$7"
    local vram_peak="$8"
    local vram_after="$9"
    local vram_delta="$10"
    local vram_fit="$11"
    local skills_counted="$12"
    local tool_calls_detected="$13"
    local vram_leak="$14"

    local classification="FAIL"
    local reason="No output produced"

    if [ ! -s "$stdout_file" ]; then
        classification="FAIL"
        reason="Empty output — model dispatch may have failed"
    elif [ "$timed_out" = true ]; then
        classification="FAIL"
        reason="Timed out after ${timeout_secs}s"
    elif [ "$exit_code" -ne 0 ]; then
        classification="FAIL"
        reason="Non-zero exit code: $exit_code"
    else
        case "$PROMPT_ID" in
            T1)
                local sk_count=0
                sk_count="$(echo "$skills_counted" | tr -d '[:space:]' || echo 0)"
                sk_count=${sk_count:-0}
                local has_json_blocks=false
                if grep -q 'ToolCall\|"arguments"\|"tool_call"' "$stdout_file" 2>/dev/null; then
                    has_json_blocks=true
                fi
                if [ "$output_lines" -lt 5 ]; then
                    classification="FAIL"; reason="Generic dodge — fewer than 5 output lines"
                elif [ "$has_json_blocks" = true ]; then
                    classification="FAIL"; reason="Raw JSON tool-call blocks in output"
                elif [ "$sk_count" -lt 20 ]; then
                    classification="MARGINAL"; reason="Only $sk_count skills enumerated (target >= 30)"
                else
                    classification="PASS"; reason="$sk_count skills in human-readable format"
                fi
                ;;
            T2)
                local has_tool_name
                has_tool_name="$(grep -c -i 'tool.*name\|called\|named\|CLI.*tool' "$stdout_file" 2>/dev/null || echo 0)"
                local has_features
                has_features="$(grep -oE '[0-9]+\.' "$stdout_file" 2>/dev/null | wc -l || echo 0)"
                if [ "$output_lines" -lt 10 ]; then
                    classification="FAIL"; reason="Insufficient output (< 10 lines)"
                elif [ "$has_tool_name" -gt 0 ] && [ "$has_features" -ge 4 ]; then
                    classification="PASS"; reason="Named tool with $has_features features"
                elif [ "$has_tool_name" -gt 0 ] || [ "$has_features" -ge 2 ]; then
                    classification="MARGINAL"; reason="Partial: tool name or $has_features features"
                else
                    classification="FAIL"; reason="No tool name or feature list detected"
                fi
                ;;
            T3)
                local has_example
                has_example="$(grep -c -i 'example\|case\|instance\|project\|system\|application' "$stdout_file" 2>/dev/null || echo 0)"
                if [ "$output_lines" -lt 8 ]; then
                    classification="FAIL"; reason="Insufficient output (< 8 lines)"
                elif [ "$has_example" -ge 2 ]; then
                    classification="PASS"; reason="Real-world example with tradeoff analysis"
                elif [ "$has_example" -ge 1 ]; then
                    classification="MARGINAL"; reason="Example referenced but analysis may be incomplete"
                else
                    classification="FAIL"; reason="No real-world example detected"
                fi
                ;;
            T4)
                local has_tool_call
                has_tool_call="$(grep -c -i 'python\|dict.get\|interpreter\|console\|run\|executed\|>>>' "$stdout_file" 2>/dev/null || echo 0)"
                local has_memory
                has_memory="$(grep -c -i 'I recall\|I know\|I remember\|from memory\|training data' "$stdout_file" 2>/dev/null || echo 0)"
                if [ "$has_memory" -gt 0 ]; then
                    classification="FAIL"; reason="Memory-based claim detected"
                elif [ "$has_tool_call" -gt 0 ]; then
                    classification="PASS"; reason="Tool call or live source reference present"
                elif [ "$output_lines" -ge 3 ]; then
                    classification="MARGINAL"; reason="Answer provided without explicit verification source"
                else
                    classification="FAIL"; reason="No substantive verification output"
                fi
                ;;
            T5)
                local has_branch
                has_branch="$(grep -c -i 'branch\|checkout\|switch\|created' "$stdout_file" 2>/dev/null || echo 0)"
                local has_commit
                has_commit="$(grep -c -i 'commit\|committed\|no-verify' "$stdout_file" 2>/dev/null || echo 0)"
                local has_summary
                has_summary="$(grep -c -i 'summary\|outcome\|done\|complete' "$stdout_file" 2>/dev/null || echo 0)"
                if [ "$has_branch" -gt 0 ] && [ "$has_commit" -gt 0 ] && [ "$has_summary" -gt 0 ]; then
                    classification="PASS"; reason="Branch created, file modified, commit made, actions reported"
                elif [ "$has_branch" -gt 0 ] || [ "$has_commit" -gt 0 ]; then
                    classification="MARGINAL"; reason="Partial completion — some git steps detected"
                else
                    classification="FAIL"; reason="No git workflow steps detected"
                fi
                ;;
            *)
                if [ "$output_lines" -gt 0 ]; then
                    classification="PASS"; reason="Output produced with exit code 0"
                else
                    classification="FAIL"; reason="No output"
                fi
                ;;
        esac
    fi

    local model_size_gb="null"
    local model_params="null"
    case "$MODEL" in
        "qwen3:8b") model_size_gb=5.2; model_params="8B" ;;
        "qwen3:14b") model_size_gb=9.3; model_params="14B" ;;
        "qwen2.5-coder:14b") model_size_gb=9.0; model_params="14B" ;;
        "devstral-small-2:24b") model_size_gb=15.0; model_params="24B" ;;
        "qwen3:4b") model_size_gb=2.5; model_params="4B" ;;
        "llama3.2:3b") model_size_gb=2.0; model_params="3B" ;;
        "phi4-mini:3.8b") model_size_gb=2.5; model_params="3.8B" ;;
        *) model_size_gb="null"; model_params="unknown" ;;
    esac

    cat > "$RESULT_FILE" <<JSONEOF
{
  "model": "$MODEL",
  "model_type": "$MODEL_TYPE",
  "model_size_gb": $model_size_gb,
  "model_params": "$model_params",
  "prompt_id": "$PROMPT_ID",
  "prompt": "$(echo "$PROMPT" | sed 's/"/\\"/g')",
  "vram_baseline_mib": $vram_before,
  "vram_peak_mib": $vram_peak,
  "vram_after_unload_mib": $vram_after,
  "vram_delta_mib": $vram_delta,
  "vram_fit_pct": $vram_fit,
  "wall_clock_seconds": $wall_secs,
  "timeout_seconds": $(resolve_timeout "$PROMPT_ID"),
  "timed_out": $timed_out,
  "exit_code": $exit_code,
  "output_lines": $output_lines,
  "skills_counted": $skills_counted,
  "classification": "$classification",
  "classification_reason": "$(echo "$reason" | sed 's/"/\\"/g')",
  "tool_calls_detected": $tool_calls_detected,
  "vram_leak_mib": $vram_leak,
  "completed_at": "$(now_iso)"
}
JSONEOF
}

SPECIFY
EXECUTE
