#!/bin/bash
# TDD-6 RED Phase: First-turn injection fires on first user message (SC-10)
#
# RED condition: opencode-cli run with single-turn prompt shows no
# session context injection in first-turn context (remaining injection
# content — session triggers, guidelines index, skill index — should
# still fire but is missing).
#
# Test FAILS (exit 1) when injection is missing = RED condition confirmed.
# Test PASSES (exit 0) when injection IS working = GREEN state.
#
# See .opencode/.issues/1308-spec-clean-up-session-enforcement-ts/spec.md SC-10

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
ARTIFACT_DIR="$PROJECT_ROOT/tmp/1308/artifacts/tdd-6-red"
mkdir -p "$ARTIFACT_DIR"

echo "=== TDD-6 RED: First-turn injection fires on first user message (SC-10) ==="
echo ""

bash "$PROJECT_ROOT/.opencode/tests/with-test-home" --clean-all 2>/dev/null || true

echo "Running: opencode-cli run 'hello' --log-level INFO --print-logs"
bash "$PROJECT_ROOT/.opencode/tests/with-test-home" opencode-cli run "hello" --log-level INFO --print-logs \
  > "$ARTIFACT_DIR/stdout.log" \
  2>"$ARTIFACT_DIR/stderr.log" \
  || true

echo "--- Checking for first-turn session context injection in agent stdout ---"

STDOUT=$(cat "$ARTIFACT_DIR/stdout.log")

# Evidence of session context injection: agent references its branch, repo info,
# project information — injected via session-init and guidelines/skill index blocks
# These are the REMAINING first-turn injection blocks (not removed by TDD-4).
INJECTION_FOUND=false

if echo "$STDOUT" | grep -qiE "(feature/1308|branch|opencode|cwd=|project|repo|working directory)"; then
    echo "  INJECTION EVIDENCE: Agent output references session context information"
    INJECTION_FOUND=true
fi

echo ""
echo "--- Stdout (first 20 lines) ---"
head -20 "$ARTIFACT_DIR/stdout.log"
echo ""
echo "--- Stderr plugin session-enforcement traces ---"
grep -i "session.enforcement\|plugin\|session-init\|session_context" "$ARTIFACT_DIR/stderr.log" | tail -10 || echo "  (no plugin traces in stderr)"
echo ""

echo "--- Result ---"
if [ "$INJECTION_FOUND" = true ]; then
    echo "RESULT: PASS (injection evidence found — first-turn injection IS working)"
    echo "EXIT CODE: 0"
    rm -rf "$ARTIFACT_DIR"
    exit 0
else
    echo "RESULT: FAIL (no injection evidence found — first-turn injection IS missing)"
    echo "EXIT CODE: 1 (RED condition confirmed)"
    exit 1
fi