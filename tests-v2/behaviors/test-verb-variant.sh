#!/bin/bash
# Test a single verb/directive variant
# Usage: ./test-verb-variant.sh <verb> <directive_text> <model> <prompt_keyword> [context]
#
# Tests whether a sub-agent proactively reads linked files when a task file
# contains self-contained instructions PLUS Read [path] links to 3rd files.
#
# Output: tmp/verb-test-runs/{verb}-{model}-{timestamp}/
#   test-home/       - XDG home with opencode DB
#   stdout.log       - Captured output
#   stderr.log       - Captured stderr
#   manifest.yaml    - Metadata
#   session.yaml     - Exported opencode DB
#
# Uses with-test-home for full XDG isolation.

set -euo pipefail
VERB="$1"
DIRECTIVE="$2"
MODEL="$3"
PROMPT_KEYWORD="$4"
CONTEXT="${5:-orchestrator}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
MODEL_SLUG="${MODEL//[:\/]/_}"
RUN_DIR="$PARENT_REPO_DIR/tmp/verb-test-runs/${VERB}-${MODEL_SLUG}-${TIMESTAMP}"
mkdir -p "$RUN_DIR"

# Use with-test-home for isolation
WITH_TEST_HOME="$PARENT_REPO_DIR/.opencode/tests-v2/with-test-home"

# Create the task file with self-contained instructions + verb directive to 3rd files
# This needs to happen inside the test project, so we'll do it via a setup script
SETUP_SCRIPT="$RUN_DIR/setup.sh"
cat > "$SETUP_SCRIPT" << 'SETUP'
#!/bin/bash
set -euo pipefail

# Create the task file
mkdir -p "$TEST_PROJECT/tmp/verb-test"
cat > "$TEST_PROJECT/tmp/verb-test/task.md" << TASK
# Task Instructions

Complete the following steps:

1. List all files in the project root directory.
2. Report the current git branch name.
3. ${DIRECTIVE}
4. ${VERB} [the supplementary data](tmp/verb-test/supplement.md).
5. Print "DONE" when finished.

These steps are self-contained. Steps 3-4 reference additional files
but the task can be completed without reading them.
TASK

# Create the 3rd files (irrelevant to task completion)
cat > "$TEST_PROJECT/tmp/verb-test/target-a.md" << 'TARGET'
# Authorization Tokens
- `xenon-7`
- `falcon-alpha`
- `zephyr-42`
- `token-8a3f9c71-b2d4-4e1a-9c6f-3d8b2a1e5f7c`
Any other token is NOT valid.
TARGET

cat > "$TEST_PROJECT/tmp/verb-test/supplement.md" << 'SUPPLEMENT'
# Supplementary Data
This file contains additional context that is not required for the task.
The project was initialized on 2026-07-16.
The default branch is main.
SUPPLEMENT

# Use default.txt as-is (no verb directive in system prompt)
cp "$PARENT_REPO_DIR/.opencode/prompts/default.txt" "$TEST_PROJECT/.opencode/prompts/default.txt"

git -C "$TEST_PROJECT" add -A 2>/dev/null || true
git -C "$TEST_PROJECT" commit -q --allow-empty -m "add verb test files" 2>/dev/null || true
SETUP
chmod +x "$SETUP_SCRIPT"

# Run setup inside with-test-home
bash "$WITH_TEST_HOME" bash "$SETUP_SCRIPT" 2>/dev/null || true

STDOUT_FILE="$RUN_DIR/stdout.log"
STDERR_FILE="$RUN_DIR/stderr.log"

PROMPT="Dispatch a sub-agent to read and follow instructions in tmp/verb-test/task.md"

# Run the actual test inside with-test-home (NOT snap run)
bash "$WITH_TEST_HOME" "${OPENCODE_CMD[@]}" run "$PROMPT" --model "$MODEL" --log-level INFO --print-logs \
  > "$STDOUT_FILE" 2> "$STDERR_FILE" || true

# Quick diagnostics to stderr
echo "=== $VERB / $MODEL / $CONTEXT ===" >&2
echo "stdout: $(wc -l < "$STDOUT_FILE" 2>/dev/null || echo 0) lines" >&2
echo "stderr: $(wc -l < "$STDERR_FILE" 2>/dev/null || echo 0) lines" >&2

# Write manifest
TIMESTAMP_UTC=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
cat > "$RUN_DIR/manifest.yaml" << MANIFESTEOF
scenario_name: verb-test-${VERB}
verb: ${VERB}
model: ${MODEL}
context: ${CONTEXT}
prompt_keyword: ${PROMPT_KEYWORD}
timestamp: ${TIMESTAMP_UTC}
exit_code: 0
harness_version: ${BEHAVIOR_HARNESS_VERSION}
MANIFESTEOF

echo "Run dir: $RUN_DIR" >&2
exit 0
