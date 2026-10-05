#!/bin/bash
# Trunk-protection hook behavior test (.opencode#2490 SC-6).
# Outcome-asserting: exercises the actual hook scripts against scratch repos
# and asserts block/allow behavior — no model, no prose-recall.
#
# Covers:
#   1. pre-commit BLOCKS a direct commit on the trunk branch.
#   2. pre-commit ALLOWS a commit on a feature branch.
#   3. pre-push BLOCKS a push that updates the trunk ref.
#   4. pre-push ALLOWS a push to a non-trunk ref.
#   5. Hook scripts contain no hardcoded branch names (property-based trunk).
#
# Usage: bash .opencode/tests-v2/test-trunk-hook.sh
# Exit: 0 if all checks pass, 1 if any check fails

set -uo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

HOOKS_DIR="$PROJECT_DIR/.opencode/hooks"
PASS_COUNT=0
FAIL_COUNT=0

check_pass() {
    echo "  PASS: $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

check_fail() {
    echo "  FAIL: $1 -- $2" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/trunk-hook-test.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT

# Build a scratch repo whose origin/HEAD points at 'main' (property-derived,
# arbitrary name — proves the hook does not hardcode a branch name).
git init -q --bare "$SCRATCH/origin.git"
git init -q -b main "$SCRATCH/work"
git -C "$SCRATCH/work" config user.email "hook-test@example.invalid"
git -C "$SCRATCH/work" config user.name "Hook Test"
git -C "$SCRATCH/work" remote add origin "$SCRATCH/origin.git"
git -C "$SCRATCH/work" commit -q --allow-empty -m init
git -C "$SCRATCH/work" push -q origin main 2>/dev/null
git -C "$SCRATCH/work" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main 2>/dev/null
# emulate the installed hook environment
mkdir -p "$SCRATCH/work/.git/hooks"
cp "$HOOKS_DIR/pre-commit" "$HOOKS_DIR/pre-push" "$SCRATCH/work/.git/hooks/"
chmod +x "$SCRATCH/work/.git/hooks/"pre-commit "$SCRATCH/work/.git/hooks/"pre-push

# 1. pre-commit BLOCKS direct commit on trunk
OUT=$(git -C "$SCRATCH/work" commit -q --allow-empty -m "direct to trunk" 2>&1)
RC=$?
if [ $RC -ne 0 ] && echo "$OUT" | grep -q "BLOCKED"; then
    check_pass "pre-commit blocks direct trunk commit"
else
    check_fail "pre-commit blocks direct trunk commit" "exit=$RC out=$OUT"
fi

# 2. pre-commit ALLOWS commit on feature branch
git -C "$SCRATCH/work" checkout -q -b feature/probe
OUT=$(git -C "$SCRATCH/work" commit -q --allow-empty -m "on feature branch" 2>&1)
RC=$?
if [ $RC -eq 0 ]; then
    check_pass "pre-commit allows feature-branch commit"
else
    check_fail "pre-commit allows feature-branch commit" "exit=$RC out=$OUT"
fi

# 3. pre-push BLOCKS push updating the trunk ref
OUT=$(git -C "$SCRATCH/work" push origin HEAD:refs/heads/main 2>&1)
RC=$?
if [ $RC -ne 0 ] && echo "$OUT" | grep -q "BLOCKED"; then
    check_pass "pre-push blocks push to trunk ref"
else
    check_fail "pre-push blocks push to trunk ref" "exit=$RC out=$OUT"
fi

# 4. pre-push ALLOWS push to a non-trunk ref
OUT=$(git -C "$SCRATCH/work" push origin HEAD:refs/heads/feature/probe 2>&1)
RC=$?
if [ $RC -eq 0 ]; then
    check_pass "pre-push allows push to non-trunk ref"
else
    check_fail "pre-push allows push to non-trunk ref" "exit=$RC out=$OUT"
fi

# 5. no hardcoded branch names in the hook scripts
if sed 's|/dev/null||g' "$HOOKS_DIR/pre-commit" "$HOOKS_DIR/pre-push" | grep -qE '\b(main|master|dev)\b'; then
    check_fail "hooks are branch-name-free" "hardcoded branch name found in hook script"
else
    check_pass "hooks are branch-name-free (property-based trunk)"
fi

# 6. pre-commit BLOCKS a staged file referencing an issue-store path (.opencode#2506)
# the reference string is built dynamically so this test file does not itself
# carry a literal issue-store path (the gate would block the test's own commit)
printf 'see the spec at .issues/%d/spec.md for details\n' 2490 > "$SCRATCH/work/store-ref.md"
git -C "$SCRATCH/work" add store-ref.md
OUT=$(git -C "$SCRATCH/work" commit -q -m "store path reference" 2>&1)
RC=$?
if [ $RC -ne 0 ] && echo "$OUT" | grep -q "issue-store path"; then
    check_pass "pre-commit blocks staged issue-store path reference"
else
    check_fail "pre-commit blocks staged issue-store path reference" "exit=$RC out=$OUT"
fi
git -C "$SCRATCH/work" reset -q store-ref.md

# 7. pre-commit ALLOWS store content and fixture files (excluded from the gate)
mkdir -p "$SCRATCH/work/tests-v2/behaviors/fixtures/issues/1234"
echo "fixture spec content (exclusion is by path, not content)" > "$SCRATCH/work/tests-v2/behaviors/fixtures/issues/1234/spec.md"
echo "ordinary content" > "$SCRATCH/work/clean.md"
git -C "$SCRATCH/work" add tests-v2/behaviors/fixtures/issues/1234/spec.md clean.md
OUT=$(git -C "$SCRATCH/work" commit -q -m "fixture and clean content" 2>&1)
RC=$?
if [ $RC -eq 0 ]; then
    check_pass "pre-commit allows fixture-excluded and clean content"
else
    check_fail "pre-commit allows fixture-excluded and clean content" "exit=$RC out=$OUT"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0
