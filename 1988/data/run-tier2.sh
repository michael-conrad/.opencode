#!/bin/bash
# Tier 2 test runner — cross-reference form comparison (issue #1988)
# Tests whether the reference pattern survives the orchestrator→sub-agent handoff.
#
# Usage:
#   bash tmp/1988/run-tier2.sh <fixture> <form> <run_number>
#
# Parameters:
#   fixture:     a | c
#   form:        a | b3 | c
#   run_number:  positive integer
#
# Artifact-only generator — does NOT evaluate model output.
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# MANDATORY: bash tool timeout >= 600000ms (600s) when invoking this script.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"
MEASUREMENTS_FILE="$SCRIPT_DIR/measurements-tier2.jsonl"

# --- Parameter validation ---
FIXTURE="${1:-}"
FORM="${2:-}"
RUN_NUMBER="${3:-}"

if [ -z "$FIXTURE" ] || [ -z "$FORM" ] || [ -z "$RUN_NUMBER" ]; then
    echo "Usage: bash tmp/1988/run-tier2.sh <fixture> <form> <run_number>" >&2
    echo "  fixture: a | c" >&2
    echo "  form:    a | b3 | c" >&2
    echo "  run_number: positive integer" >&2
    exit 2
fi

case "$FIXTURE" in
    a|c) ;;
    *) echo "ERROR: fixture must be 'a' or 'c', got '$FIXTURE'" >&2; exit 2 ;;
esac

case "$FORM" in
    a|b3|c) ;;
    *) echo "ERROR: form must be 'a', 'b3', or 'c', got '$FORM'" >&2; exit 2 ;;
esac

if ! [ "$RUN_NUMBER" -gt 0 ] 2>/dev/null; then
    echo "ERROR: run_number must be a positive integer, got '$RUN_NUMBER'" >&2
    exit 2
fi

# --- Resolve paths ---
TASK_FILE="$FIXTURES_DIR/fixture-$FIXTURE/task-$FORM.md"
REF_DIR="$FIXTURES_DIR/fixture-$FIXTURE/references"

if [ ! -f "$TASK_FILE" ]; then
    echo "ERROR: task file not found: $TASK_FILE" >&2
    exit 1
fi
if [ ! -d "$REF_DIR" ]; then
    echo "ERROR: references directory not found: $REF_DIR" >&2
    exit 1
fi

# --- Read task card content (strip YAML frontmatter) ---
TASK_CONTENT=$(sed '1{/^---$/!q;}; /^---$/,/^---$/d' "$TASK_FILE")
if [ -z "$TASK_CONTENT" ]; then
    echo "ERROR: task content is empty after stripping frontmatter" >&2
    exit 1
fi

# --- Determine relevant reference file for this fixture ---
case "$FIXTURE" in
    a) RELEVANT_REF="references/TimeoutConfig.md" ;;
    c) RELEVANT_REF="references/ErrorHandling.md" ;;
esac

# --- Set up isolated test project ---
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
TEST_HOME="$PROJECT_DIR/tmp/test-home-tier2-$TIMESTAMP"
mkdir -p "$TEST_HOME"

TEST_PROJECT="$TEST_HOME/project"
mkdir -p "$TEST_PROJECT"

# Init git repo
git init -q "$TEST_PROJECT"
git -C "$TEST_PROJECT" config user.email "test@example.com"
git -C "$TEST_PROJECT" config user.name "Test"

# Clone .opencode submodule
SUBMODULE_REMOTE_URL="https://github.com/michael-conrad/.opencode.git"
if [ -f "$PROJECT_DIR/.gitmodules" ]; then
    SUBMODULE_REMOTE_URL=$(git -C "$PROJECT_DIR" config --get submodule..opencode.url 2>/dev/null || echo "https://github.com/michael-conrad/.opencode.git")
fi
SUBMODULE_REMOTE_URL=$(echo "$SUBMODULE_REMOTE_URL" | sed 's|^git@github.com:|https://github.com/|' | sed 's|\.git$||')

git clone -q "$SUBMODULE_REMOTE_URL" "$TEST_PROJECT/.opencode" 2>/dev/null || {
    echo "HARNESS_FAILURE: git clone failed for .opencode from $SUBMODULE_REMOTE_URL" >&2
    exit 1
}

# --- Place task card and references in the test project ---
mkdir -p "$TEST_PROJECT/references"
cp "$TASK_FILE" "$TEST_PROJECT/task.md"
cp "$REF_DIR"/*.md "$TEST_PROJECT/references/"

git -C "$TEST_PROJECT" add -A 2>/dev/null || true
git -C "$TEST_PROJECT" commit -q --allow-empty -m "init" 2>/dev/null || true

# --- Seed model config ---
mkdir -p "$TEST_HOME/.config/opencode"
cat > "$TEST_HOME/.config/opencode/opencode.jsonc" << JSONC
{
  "\$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "qwen3.6:35b-256k": {}
      }
    }
  }
}
JSONC

# --- Set up standalone opencode binary ---
STANDALONE_BINARY="$PROJECT_DIR/.tools/opencode/opencode"
if [ ! -f "$STANDALONE_BINARY" ]; then
    echo "HARNESS_FAILURE: standalone opencode binary not found at $STANDALONE_BINARY" >&2
    exit 1
fi

mkdir -p "$TEST_HOME/bin"
cp "$STANDALONE_BINARY" "$TEST_HOME/bin/opencode"

# --- Run opencode with the task card content as the message ---
MODEL="ollama/qwen3.6:35b-256k"
START_TIME=$(date +%s)

STDOUT_FILE="$TEST_HOME/stdout.log"
STDERR_FILE="$TEST_HOME/stderr.log"

RC=0
(
    cd "$TEST_PROJECT"
    export PATH="$TEST_HOME/bin:$PATH"
    export XDG_CONFIG_HOME="$TEST_HOME/.config"
    export XDG_CACHE_HOME="$TEST_HOME/.cache"
    export XDG_RUNTIME_DIR="$TEST_HOME/.runtime"
    export XDG_DATA_HOME="$TEST_HOME/.local/share"
    export XDG_STATE_HOME="$TEST_HOME/.local/state"
    export USER="opencode-test-user"
    export GIT_CONFIG_NOSYSTEM=1

    opencode run "$TASK_CONTENT" --model "$MODEL" --log-level INFO --print-logs
) > "$STDOUT_FILE" 2> "$STDERR_FILE" || RC=$?

END_TIME=$(date +%s)
TIME_SECONDS=$((END_TIME - START_TIME))

# --- Parse stderr for file read tool calls ---
# Detect read_file, editor_read_file, or read tool invocations on reference files
FILE_ACCESS=false
READ_SELECTION="none"
READ_DEPTH="none"

# Check if any reference file was read
if grep -q 'references/' "$STDERR_FILE" 2>/dev/null; then
    FILE_ACCESS=true
fi

# Determine read selection: did the agent read the relevant reference?
if [ "$FILE_ACCESS" = true ]; then
    if grep -q "$RELEVANT_REF" "$STDERR_FILE" 2>/dev/null; then
        READ_SELECTION="relevant"
    else
        READ_SELECTION="irrelevant"
    fi
fi

# Determine read depth: full file read vs partial
if [ "$FILE_ACCESS" = true ]; then
    # Count unique reference files accessed
    REF_COUNT=$(grep -oP 'references/[a-zA-Z]+\.md' "$STDERR_FILE" 2>/dev/null | sort -u | wc -l)
    if [ "$REF_COUNT" -ge 1 ]; then
        READ_DEPTH="full"
    fi
fi

# --- Capture stderr snippet (last 500 chars) ---
STDERR_SNIPPET=$(tail -c 500 "$STDERR_FILE" 2>/dev/null || true)
# Escape for JSON
STDERR_SNIPPET=$(echo "$STDERR_SNIPPET" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null || echo "\"\"")

# --- Append JSON line to measurements file ---
mkdir -p "$(dirname "$MEASUREMENTS_FILE")"
export FIXTURE FORM RUN_NUMBER FILE_ACCESS READ_SELECTION READ_DEPTH TIME_SECONDS STDERR_SNIPPET MEASUREMENTS_FILE
python3 -c "
import json, os
d = {
    'fixture': os.environ['FIXTURE'],
    'form': os.environ['FORM'],
    'run': int(os.environ['RUN_NUMBER']),
    'file_access': os.environ.get('FILE_ACCESS','false').lower() == 'true',
    'read_selection': os.environ.get('READ_SELECTION','none'),
    'read_depth': os.environ.get('READ_DEPTH','none'),
    'time_seconds': float(os.environ.get('TIME_SECONDS',0)),
    'stderr_snippet': os.environ.get('STDERR_SNIPPET','')
}
with open(os.environ['MEASUREMENTS_FILE'], 'a') as f:
    f.write(json.dumps(d) + chr(10))
"

# --- Cleanup test home ---
rm -rf "$TEST_HOME"

exit 0
