#!/bin/bash
# run-verb-test.sh — Test verb variants in Tier 2 (sub-agent) context for issue #1988
# Usage: bash tmp/1988/run-verb-test.sh <verb> <run_number>
#   verb: see|read|load|open|check|must-read|fetch|consult
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures/fixture-a/verb-test"
MEASUREMENTS_FILE="$SCRIPT_DIR/measurements-verb-test.jsonl"
STANDALONE_BINARY="$PROJECT_DIR/.tools/opencode/opencode"

VERB="${1:-}"
RUN_NUMBER="${2:-1}"

if [ -z "$VERB" ]; then
    echo "Usage: bash tmp/1988/run-verb-test.sh <verb> <run_number>" >&2
    echo "  verb: see|read|load|open|check|must-read|fetch|consult" >&2
    exit 2
fi

case "$VERB" in
    see|read|load|open|check|must-read|fetch|consult) ;;
    *) echo "ERROR: invalid verb '$VERB'" >&2; exit 2 ;;
esac

TASK_FILE="$FIXTURES_DIR/task-$VERB.md"
REF_DIR="$FIXTURES_DIR/references"

if [ ! -f "$TASK_FILE" ]; then echo "ERROR: task file not found: $TASK_FILE" >&2; exit 1; fi
if [ ! -d "$REF_DIR" ]; then echo "ERROR: references not found: $REF_DIR" >&2; exit 1; fi
if [ ! -f "$STANDALONE_BINARY" ]; then echo "ERROR: standalone binary not found" >&2; exit 1; fi

# Read task content (strip YAML frontmatter)
TASK_CONTENT=$(sed '1{/^---$/!q;}; /^---$/,/^---$/d' "$TASK_FILE")
if [ -z "$TASK_CONTENT" ]; then echo "ERROR: empty task content" >&2; exit 1; fi

# Set up test project
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
TEST_HOME="$PROJECT_DIR/tmp/test-home-verb-$TIMESTAMP"
mkdir -p "$TEST_HOME"
TEST_PROJECT="$TEST_HOME/project"
mkdir -p "$TEST_PROJECT"

git init -q "$TEST_PROJECT"
git -C "$TEST_PROJECT" config user.email "test@test.com"
git -C "$TEST_PROJECT" config user.name "Test"

# Clone .opencode submodule
SUBMODULE_URL="https://github.com/michael-conrad/.opencode.git"
git clone -q "$SUBMODULE_URL" "$TEST_PROJECT/.opencode" 2>/dev/null || {
    echo "HARNESS_FAILURE: git clone failed" >&2; exit 1
}

# Place task card and references
mkdir -p "$TEST_PROJECT/references"
cp "$TASK_FILE" "$TEST_PROJECT/task.md"
cp "$REF_DIR"/*.md "$TEST_PROJECT/references/"

git -C "$TEST_PROJECT" add -A 2>/dev/null || true
git -C "$TEST_PROJECT" commit -q --allow-empty -m "init" 2>/dev/null || true

# Seed model config
mkdir -p "$TEST_HOME/.config/opencode"
cat > "$TEST_HOME/.config/opencode/opencode.jsonc" << JSONC
{
  "\$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "options": { "baseURL": "http://localhost:11434/v1" },
      "models": { "qwen3.6:35b-256k": {} }
    }
  }
}
JSONC

# Set up standalone binary
mkdir -p "$TEST_HOME/bin"
cp "$STANDALONE_BINARY" "$TEST_HOME/bin/opencode"

# Run
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

# Parse stderr
FILE_ACCESS=false
READ_SELECTION="none"
READ_DEPTH="none"

if grep -q 'references/' "$STDERR_FILE" 2>/dev/null; then
    FILE_ACCESS=true
fi

if [ "$FILE_ACCESS" = true ]; then
    if grep -q 'references/TimeoutConfig.md' "$STDERR_FILE" 2>/dev/null; then
        READ_SELECTION="relevant"
    else
        READ_SELECTION="irrelevant"
    fi
    REF_COUNT=$(grep -oP 'references/[a-zA-Z]+\.md' "$STDERR_FILE" 2>/dev/null | sort -u | wc -l)
    if [ "$REF_COUNT" -ge 1 ]; then
        READ_DEPTH="full"
    fi
fi

# Append JSON line
mkdir -p "$(dirname "$MEASUREMENTS_FILE")"
export VERB RUN_NUMBER FILE_ACCESS READ_SELECTION READ_DEPTH TIME_SECONDS MEASUREMENTS_FILE
python3 -c "
import json, os
d = {
    'verb': os.environ['VERB'],
    'run': int(os.environ['RUN_NUMBER']),
    'file_access': os.environ.get('FILE_ACCESS','false').lower() == 'true',
    'read_selection': os.environ.get('READ_SELECTION','none'),
    'read_depth': os.environ.get('READ_DEPTH','none'),
    'time_seconds': float(os.environ.get('TIME_SECONDS',0))
}
with open(os.environ['MEASUREMENTS_FILE'], 'a') as f:
    f.write(json.dumps(d) + chr(10))
"

rm -rf "$TEST_HOME"
echo "OK: verb=$VERB run=$RUN_NUMBER access=$FILE_ACCESS sel=$READ_SELECTION depth=$READ_DEPTH time=${TIME_SECONDS}s"
exit 0
