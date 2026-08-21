#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral Enforcement Test: 2310-sc1-dynamic-trunk
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# Issue: .opencode#2310 — scripts/session_context_triggers.py hardcodes
# 'origin/dev' in the pair-mode resume diff stat.
#
# SC-1: `build_pair_mode_resume()` computes the diff stat against the dynamically
#       resolved trunk branch (e.g. `origin/master..HEAD` or `origin/main..HEAD`),
#       never the hardcoded `origin/dev`, and falls back to `main` when the remote
#       HEAD branch cannot be resolved.
#
# Evidence type: behavioral — the test sets up a controlled git remote whose HEAD
# branch is `master`, creates a pair-mode branch with a commit ahead of the trunk,
# INVOKES the real `build_pair_mode_resume()` function, and asserts the produced
# trigger includes a diff-stat summary computed against the resolved trunk (so the
# output contains a "Changes:" line) and does NOT reference the hardcoded
# `origin/dev`. This is runtime-output verification of the actual Python function.
# (bash test.sh behavioral testing per the evidence type taxonomy).
#
# RED state: `build_pair_mode_resume()` currently runs `git diff --stat origin/dev..HEAD`
# (line 70). In a repo whose remote HEAD branch is `master`, `origin/dev` does not
# exist, so `run_git()` returns None and the diff-stat summary is empty — the output
# has no "Changes:" line. The assertion that the output contains a "Changes:" line
# (computed against the resolved trunk) FAILS. The test is RED until the GREEN change
# adds `get_default_branch()` and computes the diff stat against the resolved trunk.
#
# Usage: bash .opencode/tests-v2/test-2310-sc1-dynamic-trunk.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED).

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done

SCT_SCRIPT="$PROJECT_DIR/scripts/session_context_triggers.py"

PASS_COUNT=0
FAIL_COUNT=0

check_pass() {
    local label="$1"
    echo "  PASS: $label"
    PASS_COUNT=$((PASS_COUNT + 1))
}

check_fail() {
    local label="$1"
    local detail="$2"
    echo "  FAIL: $label — $detail" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

echo ""
echo "=== SC-1: build_pair_mode_resume computes diff stat against resolved trunk, not 'origin/dev' ==="
echo ""
echo "Target file: $SCT_SCRIPT"
echo ""

# Set up a controlled git remote whose HEAD branch is `master`, then invoke the
# real build_pair_mode_resume() and assert the produced trigger includes a
# diff-stat summary computed against the resolved trunk.
SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT

git init --bare -b master "$SANDBOX/remote.git" >/dev/null 2>&1
git init -q "$SANDBOX/work"
git -C "$SANDBOX/work" config user.email "test@test.dev"
git -C "$SANDBOX/work" config user.name "Test"
git -C "$SANDBOX/work" commit --allow-empty -q -m "init"
git -C "$SANDBOX/work" branch -M master
git -C "$SANDBOX/work" remote add origin "$SANDBOX/remote.git"
git -C "$SANDBOX/remote.git" symbolic-ref HEAD refs/heads/master
git -C "$SANDBOX/work" push -q -u origin master
git -C "$SANDBOX/work" checkout -q -b pair-feature/123-xyz
echo "change" > "$SANDBOX/work/foo.txt"
git -C "$SANDBOX/work" add foo.txt
git -C "$SANDBOX/work" commit -q -m "pair change"

# Verify the sandbox remote HEAD branch resolves to master.
HEAD_BRANCH="$(git -C "$SANDBOX/work" remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')"
if [ "$HEAD_BRANCH" = "master" ]; then
    check_pass "SC-1: sandbox remote HEAD branch resolves to 'master'"
else
    check_fail "SC-1: sandbox remote HEAD branch resolves to 'master'" \
        "got '$HEAD_BRANCH' (expected 'master')"
fi

# Invoke the real build_pair_mode_resume() from within the work repo.
OUTPUT="$(cd "$SANDBOX/work" && python3 -c "
import importlib.util
spec = importlib.util.spec_from_file_location('sct', '$SCT_SCRIPT')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
print(m.build_pair_mode_resume('pair-feature/123-xyz'))
" 2>&1)" || true

# SC-1: the trigger MUST include a diff-stat summary ("Changes:" line) computed
# against the resolved trunk. At baseline the diff stat targets the non-existent
# 'origin/dev', so the summary is empty and this assertion FAILS (RED).
if printf '%s' "$OUTPUT" | grep -q 'Changes:'; then
    check_pass "SC-1: trigger includes a diff-stat summary computed against the resolved trunk"
else
    check_fail "SC-1: trigger includes a diff-stat summary computed against the resolved trunk" \
        "no 'Changes:' line — diff stat targets non-existent 'origin/dev' (RED: hardcoded ref)"
fi

# SC-1: the trigger MUST NOT reference the hardcoded 'origin/dev'.
if printf '%s' "$OUTPUT" | grep -q 'origin/dev'; then
    check_fail "SC-1: trigger does NOT reference hardcoded 'origin/dev'" \
        "output references 'origin/dev' (RED: hardcoded ref)"
else
    check_pass "SC-1: trigger does NOT reference hardcoded 'origin/dev'"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-1 (dynamic trunk resolution) not yet applied."
    echo "Line 70 of .opencode/scripts/session_context_triggers.py still hardcodes"
    echo "'git diff --stat origin/dev..HEAD', so the diff stat targets the non-existent"
    echo "'dev' branch instead of the resolved trunk (master)."
    echo ""
    exit 1
fi
exit 0
