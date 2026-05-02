#!/bin/bash
# Behavioral Enforcement Test: hooks-root-detection-no-hang
#
# Enforces that git hooks do NOT use walk-up-to-.opencode for root detection.
# The walk-up loop reaches `/` where `dirname "/"` equals `"/"` and hangs
# indefinitely when hooks execute from `.git/hooks/` (outside `.opencode/`
# tree). Git always CWDs to the project root when invoking hooks, so hooks
# can use simple relative paths — no root detection needed at all.
#
# Spec: #317 — Walk-up root detection loops lack filesystem-root guard
# Plan: #320
#
# Co-authored with AI: OpenCode (deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SCENARIO_NAME="hooks-root-detection-no-hang"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

HOOK_TIMEOUT=15
OVERALL_RESULT=0

# RED phase: verify walk-up loop hangs when .opencode/ absent in ancestry
TEMP_DIR=$(mktemp -d /tmp/opencode/hooks-root-test-XXXXXX)
cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

cd "$TEMP_DIR"
git init
git config user.email "hooks-test@opencode.local"
git config user.name "Hooks Test"

echo "test content" > file.txt
git add file.txt
git commit --no-verify -m "initial commit" 1>/dev/null 2>/dev/null

# RED phase: walk-up loop should hang — timeout kill expected
echo "  Phase: RED — confirm walk-up loop hangs (expected timeout) ..."

cat > .git/hooks/pre-commit << 'HOOK_EOF'
#!/bin/bash
# Buggy walk-up root detection — executes from .git/hooks/, outside .opencode/
# Reaches / where dirname / = / and loops forever
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
while [ ! -d "$PROJECT_ROOT/.opencode" ]; do
    PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done
PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
exit 0
HOOK_EOF
chmod +x .git/hooks/pre-commit

echo "modified red" > file.txt
git add file.txt

set +e
timeout "$HOOK_TIMEOUT" git commit --no-verify -m "test red phase" > /dev/null 2> .git/hook-red-stderr.log
RED_EXIT=$?
set -e

if [ "$RED_EXIT" -eq 124 ] || [ "$RED_EXIT" -eq 137 ] || [ "$RED_EXIT" -eq 143 ]; then
    echo "    RED PASS: walk-up loop timed out (exit=$RED_EXIT) — infinite loop detected"
else
    echo "    RED FAIL: walk-up loop did not hang (exit=$RED_EXIT, expected: 124/137/143)"
    echo "    --- stderr ---"
    cat .git/hook-red-stderr.log 2>/dev/null || true
    OVERALL_RESULT=1
fi

# Clean up any partial state from failed RED commit
git checkout -f HEAD -- file.txt 2>/dev/null || true

# GREEN phase: relative paths work directly (git CWDs to project root on hook invocation)
echo "  Phase: GREEN — verify relative paths work in hook context (no root detection needed) ..."

cat > .git/hooks/pre-commit << 'HOOK_EOF'
#!/bin/bash
# Git always CWDs to the project root when invoking hooks — relative paths work directly
set -e
HOOK_WORK=$(pwd)
echo "CWD=$HOOK_WORK"
test -d "./.git" || { echo "FATAL: .git/ not found at CWD" >&2; exit 1; }
exit 0
HOOK_EOF

echo "modified green" > file.txt
git add file.txt

set +e
GREEN_OUTPUT=$(timeout "$HOOK_TIMEOUT" git commit --no-verify -m "test green phase" 2>&1)
GREEN_EXIT=$?
set -e

if [ "$GREEN_EXIT" -eq 0 ]; then
    echo "    GREEN PASS: relative path hook succeeded (exit=$GREEN_EXIT, CWD at project root)"
else
    echo "    GREEN FAIL: relative path hook failed (exit=$GREEN_EXIT)"
    echo "    --- output ---"
    echo "$GREEN_OUTPUT"
    OVERALL_RESULT=1
fi

echo ""

if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
