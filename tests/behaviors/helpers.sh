#!/bin/bash
# Behavioral test helper functions for artifact-only generator scripts.
# Source this file in behavioral test scripts.
#
# Usage:
#   source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"
#
# These helpers generate model-run artifacts only — they do NOT evaluate.
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
#
# Kept functions:
#   - behavior_run (with artifact preservation)
#   - behavior_run_pool
#   - behavior_get_stdout / behavior_get_stderr
#   - Helper variables
#
# Removed (evaluation is orchestrator's job):
#   - All assert_* functions
#   - behavior_adversarial_eval
#   - __semantic_inspector_prompt

set -euo pipefail

BEHAVIOR_TIMEOUT="${BEHAVIOR_TIMEOUT:-420}"
BEHAVIOR_MODEL="${BEHAVIOR_MODEL:-ollama/deepseek-v4-flash:cloud}"
BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-GREEN}"
BEHAVIOR_TEST_HOME="${BEHAVIOR_TEST_HOME:-.opencode/tests/with-test-home}"
BEHAVIOR_FIXTURE_ISSUES="${BEHAVIOR_FIXTURE_ISSUES:-1}"
BEHAVIOR_HARNESS_VERSION="${BEHAVIOR_HARNESS_VERSION:-1}"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"
BEHAVIOR_LOG_DIR="${BEHAVIOR_LOG_DIR:-$PROJECT_DIR/tmp/behavior-test-$(date +%Y%m%d-%H%M%S)}"

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
    local base="$PROJECT_DIR/tmp/behavioral-evidence-${scenario_name}-${phase}-${slug}"
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

    # Extract test home path from with-test-home stderr output
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

    # Fallback: hardcoded paths on caller's host
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
    local model="${3:-${BEHAVIOR_MODEL}}"
    local workdir="${4:-}"
    local agent="${5:-}"
    # NOTE: Agent 5th arg is EXPERIMENTAL. Not all test scripts set it.
    # When empty, the default agent (build) is used, which is correct for
    # most behavioral tests that test prompt-response behavior.
    local log_dir="$BEHAVIOR_LOG_DIR/$scenario_name"
    mkdir -p "$log_dir"

    local attempt=0
    local output_file="$log_dir/stdout.log"
    local err_file="$log_dir/stderr.log"

    local did_create_workdir=0
    if [ -z "$workdir" ]; then
        workdir=$(mktemp -d "$PROJECT_DIR/tmp/behavior-isolated-XXXXXX")
        git init -q "$workdir"
        git -C "$workdir" config user.email "test@test.dev"
        git -C "$workdir" config user.name "Test"
        did_create_workdir=1
    fi

    local submodule_remote_url=""
    if [ -f "$PROJECT_DIR/.gitmodules" ]; then
        submodule_remote_url=$(git -C "$PROJECT_DIR" config --get submodule..opencode.url 2>/dev/null || true)
    fi
    if [ -z "$submodule_remote_url" ]; then
        submodule_remote_url="https://github.com/michael-conrad/.opencode.git"
    fi
    submodule_remote_url=$(echo "$submodule_remote_url" | sed 's|^git@github.com:|https://github.com/|' | sed 's|\.git$||')

    if [ ! -d "$workdir/.opencode" ]; then
        git clone -q "$submodule_remote_url" "$workdir/.opencode" 2>/dev/null || {
            echo "FATAL: git clone failed for .opencode from $submodule_remote_url" >&2
            echo "Check network connectivity and repository access" >&2
            exit 1
        }
    fi

    local submodule_commit="${BEHAVIOR_SUBMODULE_COMMIT:-}"
    if [ -z "$submodule_commit" ]; then
        submodule_commit=$(git -C "$PROJECT_DIR" submodule status .opencode 2>/dev/null | awk '{print $1}' | sed 's/^[-+]//' || true)
    fi
    if [ -n "$submodule_commit" ]; then
        git -C "$workdir/.opencode" checkout -q "$submodule_commit" 2>/dev/null || {
            echo "FATAL: could not checkout submodule commit $submodule_commit" >&2
            exit 1
        }
    fi

    if [ ! -f "$workdir/.gitmodules" ] || ! grep -q '.opencode' "$workdir/.gitmodules" 2>/dev/null; then
        git -C "$workdir" submodule add -q "$submodule_remote_url" .opencode 2>/dev/null || true
    fi

    git -C "$workdir" add -A 2>/dev/null || true
    git -C "$workdir" commit -q --allow-empty -m "init" 2>/dev/null || true

    # --- Worktree setup (optional, for SC-3 worktree tests) ---
    # Create an orphan "issues" branch with initial commit so the local-issues tool
    # can create a worktree from it. If anything fails, fall back to plain .issues/ dir.
    if [ "${BEHAVIOR_SETUP_WORKTREE:-0}" = "1" ]; then
        # Create orphan branch with a single empty commit
        if git -C "$workdir" checkout -q --orphan issues 2>/dev/null; then
            git -C "$workdir" rm -rf . 2>/dev/null || true
            git -C "$workdir" commit -q --allow-empty -m "init issues branch" 2>/dev/null || true
            git -C "$workdir" checkout -q - 2>/dev/null || true
            echo "  [harness] issues orphan branch created for worktree tests"
        else
            mkdir -p "$workdir/.issues"
            echo "  [harness] issues branch setup failed — created plain .issues/ fallback"
        fi
    else
        mkdir -p "$workdir/.issues"
    fi

    if [ "${BEHAVIOR_FIXTURE_ISSUES:-1}" = "1" ]; then
        FIXTURE_SETUP="$(dirname "${BASH_SOURCE[0]}")/fixtures/setup-fixture-issues.sh"
        if [ -f "$FIXTURE_SETUP" ]; then
            source "$FIXTURE_SETUP"
            setup_fixture_issues "$workdir"
        fi
    fi

    STORY_SETUP="$(dirname "${BASH_SOURCE[0]}")/fixtures/setup-story-fixtures.sh"
    if [ -f "$STORY_SETUP" ]; then
        source "$STORY_SETUP"
        setup_story_fixtures "$workdir"
    fi

    # File-based mutex: sequentialize opencode-cli runs to prevent backend overload.
    if [ "${BEHAVIOR_CONCURRENT:-false}" != "true" ]; then
        LOCK_FILE="$PROJECT_DIR/tmp/.behavior-run.lock"
        mkdir -p "$(dirname "$LOCK_FILE")"
        exec 200>"$LOCK_FILE"
        flock -x 200
    fi

    while [ "$attempt" -lt "$BEHAVIOR_MAX_RETRIES" ]; do
        attempt=$((attempt + 1))
        echo "  [attempt $attempt/$BEHAVIOR_MAX_RETRIES]"

        TEST_WORKDIR="$workdir" \
        timeout "$BEHAVIOR_TIMEOUT" bash "$PROJECT_DIR/$BEHAVIOR_TEST_HOME" \
            opencode-cli run "$message" \
            --model "$model" \
            --log-level INFO \
            --print-logs \
            ${agent:+--agent "$agent"} \
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
            echo "  BEHAVIOR_TIMEOUT=$BEHAVIOR_TIMEOUT, BEHAVIOR_MODEL=$model"
            echo "  stdout: empty, stderr word count: $(wc -w < "$err_file" 2>/dev/null || echo 0)"
            echo "HARNESS_FAILURE: empty output" >> "$output_file"
            exit_code=1
        fi
    elif [ "${word_count:-0}" -le 3 ]; then
        echo "  NOTE: behavior_run produced short output (${word_count} words). Consider increasing BEHAVIOR_TIMEOUT if this is unexpected."
        echo "  BEHAVIOR_TIMEOUT=$BEHAVIOR_TIMEOUT, BEHAVIOR_MODEL=$model"
    fi

    sleep 1

    BEHAVIOR_STDOUT="$log_dir/stdout.log"
    BEHAVIOR_STDERR="$log_dir/stderr.log"
    export BEHAVIOR_DISPATCH_FAILED="${BEHAVIOR_DISPATCH_FAILED:-0}"

    # --- Artifact preservation ---
    local artifact_dir
    artifact_dir=$(__artifact_dir "$scenario_name" "$model")
    mkdir -p "$artifact_dir"

    # Copy stdout and stderr
    cp "$output_file" "$artifact_dir/stdout.log" 2>/dev/null || true
    cp "$err_file" "$artifact_dir/stderr.log" 2>/dev/null || true

    # Write exit_code
    echo "$exit_code" > "$artifact_dir/exit_code"

    # Write manifest.yaml
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

    # Write session.yaml from SQLite export
    # Pass stderr file path so the function can extract the isolated test home
    # (where opencode.db lives) instead of searching the caller's $HOME.
    __export_sqlite_to_yaml "$artifact_dir/session.yaml" "$err_file"

    # Write timeline.yaml from session.yaml (tool call summary)
    TIMELINE_TOOL="$PROJECT_DIR/tools/session-to-timeline"
    if [ -f "$TIMELINE_TOOL" ] && [ -f "$artifact_dir/session.yaml" ]; then
        uv run "$TIMELINE_TOOL" "$artifact_dir/session.yaml" "$artifact_dir/timeline.yaml" 2>/dev/null || true
    fi

    # Export artifact directory for caller
    BEHAVIOR_ARTIFACT_DIR="$artifact_dir"
    export BEHAVIOR_ARTIFACT_DIR
}

behavior_get_stdout() {
    cat "$BEHAVIOR_STDOUT"
}

behavior_get_stderr() {
    cat "$BEHAVIOR_STDERR"
}

# Populate from opencode-cli models
HELPERS_OC_MODELS=$(opencode-cli models 2>/dev/null | grep '^ollama/.*:cloud' | shuf | head -2 || true)
mapfile -t BEHAVIORAL_MODEL_POOL <<< "$HELPERS_OC_MODELS"
unset HELPERS_OC_MODELS
if [ ${#BEHAVIORAL_MODEL_POOL[@]} -eq 0 ]; then
    echo "WARNING: no cloud models found via 'opencode-cli models' — BEHAVIORAL_MODEL_POOL empty" >&2
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

# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)
