#!/bin/bash
# Behavioral test helper functions for artifact-only generator scripts.
# Source this file in behavioral test scripts.
#
# Usage:
#   source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"
#
# These helpers generate model-run artifacts only — they do NOT evaluate.
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# All paths are relative to the project root, discovered by walking up from
# the helper's own location until a directory containing .opencode/ is found.
# This works identically in isolated test repos and the live repo.
#
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  MANDATORY: BASH TOOL TIMEOUT MUST BE >= 600 SECONDS (timeout: 600000ms)   ║
# ║                                                                              ║
# ║  DO NOT omit the bash tool `timeout` parameter — NEVER use default 120s.     ║
# ║  This script spawns `opencode run` which can take 5+ minutes. Default       ║
# ║  bash tool timeout (120s) WILL kill this script mid-execution, leaving        ║
# ║  orphaned processes, orphaned test homes, corrupted lock files, and zombie    ║
# ║  opencode processes.                                                          ║
# ║                                                                              ║
# ║  Always pass `timeout: 600000` (600 seconds, milliseconds) to the bash tool  ║
# ║  when invoking any script in tests-v2/behaviors/.                            ║
# ║                                                                              ║
# ║  FORBIDDEN: The `timeout` command (GNU timeout) MUST NOT appear in any      ║
# ║  test script. The bash tool `timeout` parameter is the ONLY kill signal.     ║
# ║  GNU timeout does NOT forward SIGTERM to its children — orphaned opencode    ║
# ║  processes hold the flock lock and hang all subsequent test runs.            ║
# ║                                                                              ║
# ║  On SSE read timeout or transient model error: resume the session via         ║
# ║  `opencode run "continue" --task_id <id>` — NEVER kill and restart.           ║
# ║                                                                              ║
# ║  Violation = orphaned processes = hang = manual kill -9 required.            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../default-model.sh"
BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-GREEN}"
BEHAVIOR_TEST_HOME="${BEHAVIOR_TEST_HOME:-.opencode/tests-v2/with-test-home}"
BEHAVIOR_FIXTURE_ISSUES="${BEHAVIOR_FIXTURE_ISSUES:-1}"
BEHAVIOR_HARNESS_VERSION="${BEHAVIOR_HARNESS_VERSION:-1}"

# Discover project root by walking up from helpers location
BEHAVIOR_HELPERS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

__find_project_root() {
    local dir="$1"
    while [ ! -d "$dir/.opencode" ]; do
        dir="$(dirname "$dir")"
        if [ "$dir" = "/" ]; then
            echo "FATAL: Could not find project root (no .opencode/ directory found)" >&2
            exit 1
        fi
    done
    echo "$dir"
}

PARENT_REPO_DIR="$(__find_project_root "$BEHAVIOR_HELPERS_DIR")"

# Prepend .tools/opencode/ to PATH so the standalone binary is found before /snap/bin/opencode.
# The snap binary hardcodes SNAP_USER_DATA=~/snap/opencode/ and ignores XDG env vars,
# making it impossible to isolate test runs from production state.
if [ -x "$PARENT_REPO_DIR/.tools/opencode/opencode" ]; then
    export PATH="$PARENT_REPO_DIR/.tools/opencode:$PATH"
fi

if command -v opencode &>/dev/null; then
    OPENCODE_CMD=("$(command -v opencode)")
elif [ -x /usr/bin/opencode-cli ]; then
    echo "WARNING: opencode not in PATH, falling back to opencode-cli" >&2
    OPENCODE_CMD=(/usr/bin/opencode-cli)
else
    echo "FATAL: no opencode binary found" >&2
    exit 1
fi
BEHAVIOR_LOG_DIR="${BEHAVIOR_LOG_DIR:-$PARENT_REPO_DIR/tmp/behavior-test-$(date +%Y%m%d-%H%M%S)}"

BEHAVIOR_MAX_RETRIES="${BEHAVIOR_MAX_RETRIES:-2}"
BEHAVIOR_RETRY_DELAY="${BEHAVIOR_RETRY_DELAY:-30}"

__model_slug() {
    local model="$1"
    echo "$model" | tr '/:@' '-'
}

__artifact_dir() {
    local scenario_name="$1"
    local model="$2"
    local phase="${BEHAVIOR_PHASE:-GREEN}"
    local slug
    slug=$(__model_slug "$model")
    local base="$PARENT_REPO_DIR/tmp/behavioral-evidence-${scenario_name}-${phase}-${slug}"
    local dir="$base"
    local suffix=0
    while [ -d "$dir" ]; do
        suffix=$((suffix + 1))
        dir="${base}-${suffix}"
    done
    echo "$dir"
}

__export_sqlite_to_yaml() {
    local output_file="$1"
    local stderr_file="${2:-}"
    local db_found=0
    local db_path=""

    if [ -n "$stderr_file" ] && [ -f "$stderr_file" ]; then
        local test_home
        test_home=$(grep '^Test home: ' "$stderr_file" | head -1 | sed 's/^Test home: //')
        if [ -n "$test_home" ]; then
            local candidate="$test_home/.local/share/opencode/opencode.db"
            if [ -f "$candidate" ]; then
                db_path="$candidate"
                db_found=1
            fi
        fi
    fi

    if [ "$db_found" -eq 0 ]; then
        local db_candidates=(
            "${XDG_DATA_HOME:-$HOME/.local/share}/opencode/opencode.db"
            "${XDG_STATE_HOME:-$HOME/.config}/opencode/opencode.db"
            "$HOME/.local/share/opencode/opencode.db"
            "$HOME/.config/opencode/opencode.db"
        )
        for candidate in "${db_candidates[@]}"; do
            if [ -f "$candidate" ]; then
                db_path="$candidate"
                db_found=1
                break
            fi
        done
    fi

    if [ "$db_found" -eq 0 ]; then
        echo "source_db: null" > "$output_file"
        return
    fi

    python3 -c "
import json, os, sqlite3, sys

db_path = '$db_path'
output_file = '$output_file'

try:
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    cursor.execute(\"SELECT name FROM sqlite_master WHERE type='table' ORDER BY name\")
    tables = [row['name'] for row in cursor.fetchall()]

    result = {
        'source_db': db_path,
        'harness_version': ${BEHAVIOR_HARNESS_VERSION},
        'tables': {}
    }

    for table_name in tables:
        cursor.execute(f'PRAGMA table_info(\"{table_name}\")')
        columns = [row['name'] for row in cursor.fetchall()]
        cursor.execute(f'SELECT * FROM \"{table_name}\"')
        rows = [dict(row) for row in cursor.fetchall()]
        result['tables'][table_name] = {
            'columns': columns,
            'rows': rows
        }

    conn.close()

    with open(output_file, 'w') as f:
        json.dump(result, f, indent=2, default=str)

except Exception as e:
    with open(output_file, 'w') as f:
        json.dump({
            'source_db': db_path,
            'harness_version': ${BEHAVIOR_HARNESS_VERSION},
            'export_error': str(e)
        }, f, indent=2)
" 2>/dev/null || echo "source_db: ${db_path}" > "$output_file"
}

behavior_run() {
    local scenario_name="$1"
    local message="$2"
    local model="${3:-$DEFAULT_TEST_MODEL}"
    local workdir="${4:-}"
    local agent="${5:-}"
    local log_dir="$BEHAVIOR_LOG_DIR/$scenario_name"
    mkdir -p "$log_dir"

    local submodule_remote_url=""
    if [ -f "$PARENT_REPO_DIR/.gitmodules" ]; then
        submodule_remote_url=$(git -C "$PARENT_REPO_DIR" config --get submodule..opencode.url 2>/dev/null || true)
    fi
    if [ -z "$submodule_remote_url" ]; then
        submodule_remote_url="https://github.com/michael-conrad/.opencode.git"
    fi
    submodule_remote_url=$(echo "$submodule_remote_url" | sed 's|^git@github.com:|https://github.com/|' | sed 's|\.git$||')

    local submodule_commit="${BEHAVIOR_SUBMODULE_COMMIT:-}"
    # Default to trunk tip (remote default branch). Only pin to a specific commit
    # when BEHAVIOR_SUBMODULE_COMMIT is explicitly set. Using local HEAD is wrong —
    # it may be a feature branch or uncommitted state not yet pushed to remote.
    if [ -z "$submodule_commit" ]; then
        submodule_commit=""  # let clone use remote default branch
    fi

    local attempt=0
    local output_file="$log_dir/stdout.log"
    local err_file="$log_dir/stderr.log"

    LOCK_FILE="$PARENT_REPO_DIR/tmp/.behavior-run.lock"
    mkdir -p "$(dirname "$LOCK_FILE")"
    exec 200>"$LOCK_FILE"
    flock -x -w 30 200 || {
        echo "HARNESS_FAILURE: lock contention — another test is running (waited 30s)" >&2
        return 1
    }

    while [ "$attempt" -lt "$BEHAVIOR_MAX_RETRIES" ]; do
        attempt=$((attempt + 1))
        echo "  [attempt $attempt/$BEHAVIOR_MAX_RETRIES]"

        # Create a fresh workdir per attempt — with-test-home moves it into the test home.
        local attempt_workdir
        attempt_workdir=$(mktemp -d "$PARENT_REPO_DIR/tmp/behavior-isolated-XXXXXX")
        git init -q "$attempt_workdir"
        git -C "$attempt_workdir" config user.email "test@test.dev"
        git -C "$attempt_workdir" config user.name "Test"

        git clone -q "$submodule_remote_url" "$attempt_workdir/.opencode" 2>/dev/null || {
            echo "FATAL: git clone failed for .opencode from $submodule_remote_url" >&2
            exit 1
        }

        if [ -n "$submodule_commit" ]; then
            git -C "$attempt_workdir/.opencode" checkout -q "$submodule_commit" 2>/dev/null || {
                echo "FATAL: could not checkout submodule commit $submodule_commit" >&2
                exit 1
            }
        fi

        if [ ! -f "$attempt_workdir/.gitmodules" ] || ! grep -q '.opencode' "$attempt_workdir/.gitmodules" 2>/dev/null; then
            git -C "$attempt_workdir" submodule add -q "$submodule_remote_url" .opencode 2>/dev/null || true
        fi

        git -C "$attempt_workdir" add -A 2>/dev/null || true
        git -C "$attempt_workdir" commit -q --allow-empty -m "init" 2>/dev/null || true

        mkdir -p "$attempt_workdir/.issues"

        if [ "${BEHAVIOR_FIXTURE_ISSUES:-1}" = "1" ]; then
            FIXTURE_SETUP="$(dirname "${BASH_SOURCE[0]}")/fixtures/setup-fixture-issues.sh"
            if [ -f "$FIXTURE_SETUP" ]; then
                source "$FIXTURE_SETUP"
                setup_fixture_issues "$attempt_workdir"
            fi
        fi

        STORY_SETUP="$(dirname "${BASH_SOURCE[0]}")/fixtures/setup-story-fixtures.sh"
        if [ -f "$STORY_SETUP" ]; then
            source "$STORY_SETUP"
            setup_story_fixtures "$attempt_workdir"
        fi

        if [ "${BEHAVIOR_SET_BARE_REMOTE:-0}" = "1" ]; then
            local bare_repo="$attempt_workdir/../origin.git"
            git init --bare "$bare_repo" 2>/dev/null || true
            git -C "$attempt_workdir" remote add origin "$bare_repo" 2>/dev/null || true
            echo "  [harness] bare remote set up at $bare_repo"
        fi

        if [ "${BEHAVIOR_SETUP_STALE_WORKTREE:-0}" = "1" ]; then
            (cd "$attempt_workdir" && ./.opencode/tools/local-issues create --title "stale-test" 2>/dev/null) || true
            rm -rf "$attempt_workdir/.issues"
            echo "  [harness] stale worktree state set up (issue created, .issues/ deleted)"
        fi

        TEST_WORKDIR="$attempt_workdir" \
        bash "$PARENT_REPO_DIR/$BEHAVIOR_TEST_HOME" "${OPENCODE_CMD[@]}" run "$message" --model "$model" --log-level INFO --print-logs ${agent:+--agent "$agent"} \
            > "$output_file" 2> "$err_file" \
            || true

        local output
        output=$(cat "$output_file" 2>/dev/null || true)
        local word_count
        word_count=$(echo "$output" | wc -w | tr -d ' ')
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
    local exit_code=0
    if [ -z "$output" ] || [ "${word_count:-0}" -eq 0 ]; then
        if grep -qi 'sse.*timeout\|unexpected EOF\|connection reset\|ProviderModelNotFoundError\|model not found' "$err_file" 2>/dev/null; then
            echo "HARNESS_FAILURE: model dispatch failed (timeout or provider error)"
            echo "HARNESS_FAILURE: model dispatch failed (timeout or provider error)" >> "$output_file"
            exit_code=1
        else
            echo "HARNESS_FAILURE: behavior_run produced empty output after all retries"
            echo "  BEHAVIOR_MODEL=$model"
            echo "  stdout: empty, stderr word count: $(wc -w < "$err_file" 2>/dev/null || echo 0)"
            echo "HARNESS_FAILURE: empty output" >> "$output_file"
            exit_code=1
        fi
    elif [ "${word_count:-0}" -le 3 ]; then
        echo "  NOTE: behavior_run produced short output (${word_count} words)."
        echo "  BEHAVIOR_MODEL=$model"
    fi

    sleep 1

    BEHAVIOR_STDOUT="$log_dir/stdout.log"
    BEHAVIOR_STDERR="$log_dir/stderr.log"
    export BEHAVIOR_DISPATCH_FAILED="${BEHAVIOR_DISPATCH_FAILED:-0}"

    local artifact_dir
    artifact_dir=$(__artifact_dir "$scenario_name" "$model")
    mkdir -p "$artifact_dir"

    cp "$output_file" "$artifact_dir/stdout.log" 2>/dev/null || true
    cp "$err_file" "$artifact_dir/stderr.log" 2>/dev/null || true

    echo "$exit_code" > "$artifact_dir/exit_code"

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")
    local phase="${BEHAVIOR_PHASE:-GREEN}"
    cat > "$artifact_dir/manifest.yaml" <<MANIFESTEOF
scenario_name: ${scenario_name}
phase: ${phase}
model: ${model}
timestamp: ${timestamp}
exit_code: ${exit_code}
harness_version: ${BEHAVIOR_HARNESS_VERSION}
MANIFESTEOF

    __export_sqlite_to_yaml "$artifact_dir/session.yaml" "$err_file"

    local timeline_tool="$PARENT_REPO_DIR/.opencode/tools/session-to-timeline"
    if [ -f "$timeline_tool" ] && [ -f "$artifact_dir/session.yaml" ]; then
        uv run "$timeline_tool" "$artifact_dir/session.yaml" "$artifact_dir/timeline.yaml" 2>/dev/null || true
    fi

    BEHAVIOR_ARTIFACT_DIR="$artifact_dir"
    export BEHAVIOR_ARTIFACT_DIR
}

behavior_get_stdout() {
    cat "$BEHAVIOR_STDOUT"
}

behavior_get_stderr() {
    cat "$BEHAVIOR_STDERR"
}

HELPERS_OC_MODELS=$("${OPENCODE_CMD[@]}" models 2>/dev/null | grep '^ollama/.*:cloud' | shuf | head -2 || true)
mapfile -t BEHAVIORAL_MODEL_POOL <<< "$HELPERS_OC_MODELS"
unset HELPERS_OC_MODELS
if [ ${#BEHAVIORAL_MODEL_POOL[@]} -eq 0 ]; then
    echo "WARNING: no cloud models found via 'opencode models' — BEHAVIORAL_MODEL_POOL empty" >&2
fi

behavior_run_pool() {
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
        behavior_run "$model_scenario" "$message" "$model" "$PARENT_REPO_DIR"

        BEHAVIOR_POOL_OUTPUTS["$model"]="$BEHAVIOR_STDOUT"
        BEHAVIOR_POOL_STDERRS["$model"]="$BEHAVIOR_STDERR"

        if [ "${BEHAVIOR_DISPATCH_FAILED:-0}" = "0" ]; then
            any_success=1
        fi
    done

    export BEHAVIOR_POOL_OUTPUTS BEHAVIOR_POOL_STDERRS
    return $((1 - any_success))
}

# --- Assertion helpers (for orchestrator evaluation, NOT for scripts) ---

assert_tool_calls_made() {
    local stderr_file="$1"
    local tool_name="$2"
    local min_count="${3:-1}"
    local count
    count=$(grep -c "Tool:.*$tool_name" "$stderr_file" 2>/dev/null || true)
    if [ "$count" -ge "$min_count" ]; then
        return 0
    fi
    return 1
}

assert_forbidden_pattern_absent() {
    local file="$1"
    local pattern="$2"
    local label="${3:-}"
    if grep -q "$pattern" "$file" 2>/dev/null; then
        if [ -n "$label" ]; then
            echo "  FAIL: $label — forbidden pattern '$pattern' found" >&2
        fi
        return 1
    fi
    return 0
}

assert_required_pattern_present() {
    local file="$1"
    local pattern="$2"
    local label="${3:-}"
    if grep -q "$pattern" "$file" 2>/dev/null; then
        return 0
    fi
    if [ -n "$label" ]; then
        echo "  FAIL: $label — required pattern '$pattern' not found" >&2
    fi
    return 1
}

assert_skill_called() {
    local stderr_file="$1"
    local skill_name="$2"
    if grep -q "Skill \"$skill_name\"" "$stderr_file" 2>/dev/null; then
        return 0
    fi
    return 1
}

assert_no_skill_called() {
    local stderr_file="$1"
    local skill_name="$2"
    if grep -q "Skill \"$skill_name\"" "$stderr_file" 2>/dev/null; then
        return 1
    fi
    return 0
}

assert_stderr_pattern_present() {
    local stderr_file="$1"
    local pattern="$2"
    local label="${3:-}"
    if grep -q "$pattern" "$stderr_file" 2>/dev/null; then
        return 0
    fi
    if [ -n "$label" ]; then
        echo "  FAIL: $label — pattern '$pattern' not found in stderr" >&2
    fi
    return 1
}

assert_stderr_pattern_absent() {
    local stderr_file="$1"
    local pattern="$2"
    local label="${3:-}"
    if grep -q "$pattern" "$stderr_file" 2>/dev/null; then
        if [ -n "$label" ]; then
            echo "  FAIL: $label — pattern '$pattern' found in stderr" >&2
        fi
        return 1
    fi
    return 0
}

assert_stderr_pattern_present_all_models() {
    local -n _outputs="$1"
    local -n _stderrs="$2"
    local pattern="$3"
    local label="${4:-}"
    for model in "${!_outputs[@]}"; do
        local stderr="${_stderrs[$model]}"
        if ! grep -q "$pattern" "$stderr" 2>/dev/null; then
            if [ -n "$label" ]; then
                echo "  FAIL: $label — pattern '$pattern' not found in stderr for model $model" >&2
            fi
            return 1
        fi
    done
    return 0
}

assert_stderr_pattern_absent_all_models() {
    local -n _outputs="$1"
    local -n _stderrs="$2"
    local pattern="$3"
    local label="${4:-}"
    for model in "${!_outputs[@]}"; do
        local stderr="${_stderrs[$model]}"
        if grep -q "$pattern" "$stderr" 2>/dev/null; then
            if [ -n "$label" ]; then
                echo "  FAIL: $label — pattern '$pattern' found in stderr for model $model" >&2
            fi
            return 1
        fi
    done
    return 0
}

assert_semantic() {
    local artifact_dir="$1"
    local sc_id="$2"
    local description="$3"
    local model="${4:-ollama/ornith:35b-256k}"

    local stdout_file="$artifact_dir/stdout.log"
    local stderr_file="$artifact_dir/stderr.log"

    if [ ! -f "$stdout_file" ] || [ ! -f "$stderr_file" ]; then
        echo "  FAIL: $sc_id — artifact files not found in $artifact_dir" >&2
        return 1
    fi

    local stdout_content
    stdout_content=$(cat "$stdout_file")
    local stderr_content
    stderr_content=$(cat "$stderr_file")

    local inspector_prompt="You are a clean-room semantic inspector. Evaluate the following agent output and determine if the agent's actions and decisions satisfy this criterion:

CRITERION: $description

STDOUT (agent prose):
$stdout_content

STDERR (tool dispatch trace):
$stderr_content

Respond with exactly one word: PASS or FAIL. Then on a new line, provide a one-sentence justification."

    local inspector_output
    inspector_output=$("${OPENCODE_CMD[@]}" run "$inspector_prompt" --model "$model" 2>/dev/null || true)

    if echo "$inspector_output" | grep -q '^PASS'; then
        return 0
    fi
    echo "  FAIL: $sc_id — semantic inspector returned FAIL" >&2
    echo "  Inspector output: $inspector_output" >&2
    return 1
}
