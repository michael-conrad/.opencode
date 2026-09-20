#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: rule-text placement for the One-Dispatch-One-Step Gate
# Maps to SC-7 from issue #2451: a content-verification enforcement test SHALL
# assert rule-text placement only:
#   (a) guidelines/257-procedural-discipline-reference.md contains p-dis-007
#       (One-Dispatch-One-Step Gate).
#   (b) guidelines/091-incremental-build.md contains the dispatch-level bright-line.
#   (c) guidelines/022-orchestrator-context-discipline.md contains the
#       critical-rules-034 dispatch-level extension.
#   (d) task cards contain NO multi-step dispatch template text.
#
# This test asserts PLACEMENT ONLY. It does not duplicate, redefine, or evaluate
# the semantic content of any rule text — each assertion is a presence/absence
# check against the canonical source file.
#
# Pre-change state note (documented for the RED phase record): items 1-3 of
# issue #2451 (the 257, 091, and 022 rule-text insertions) were committed
# BEFORE this scenario was authored, so this scenario validates against content
# that already contains the three rule texts and therefore PASSES on first run.
# Had it been authored before items 1-3 (the true RED state), assertions (a),
# (b), and (c) would have FAILED because the rule texts did not exist yet, and
# assertion (d) would have PASSED (absence holds either way).
#
# Usage: bash .opencode/tests-v2/test-2451-sc7-rule-text-placement.sh
# Exit: 0 if all checks pass, 1 if any check fails

# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

G257="$PROJECT_DIR/.opencode/guidelines/257-procedural-discipline-reference.md"
G091="$PROJECT_DIR/.opencode/guidelines/091-incremental-build.md"
G022="$PROJECT_DIR/.opencode/guidelines/022-orchestrator-context-discipline.md"
TASK_CARDS_DIR="$PROJECT_DIR/.opencode/skills"

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
    echo "  FAIL: $label -- $detail" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

echo ""
echo "=== Rule-text placement -- SC-7 (#2451) ==="
echo ""
echo "Target files: $G257"
echo "              $G091"
echo "              $G022"
echo "Task cards:   $TASK_CARDS_DIR/*/tasks/*.md"
echo ""

# (a) 257 contains p-dis-007 (One-Dispatch-One-Step Gate).
if [ -f "$G257" ] && grep -qF 'p-dis-007' "$G257"; then
    check_pass "257 contains p-dis-007"
else
    check_fail "257 contains p-dis-007" "p-dis-007 not found in 257-procedural-discipline-reference.md"
fi

# (b) 091 contains the dispatch-level bright-line.
if [ -f "$G091" ] && grep -qF 'one dispatch = one discrete step' "$G091" && grep -qF 'multi-step dispatch' "$G091"; then
    check_pass "091 contains the dispatch-level bright-line"
else
    check_fail "091 contains the dispatch-level bright-line" "dispatch-level bright-line text not found in 091-incremental-build.md"
fi

# (c) 022 contains the critical-rules-034 dispatch-level extension.
if [ -f "$G022" ] && grep -qF 'critical-rules-034' "$G022" && grep -qF 'task()' "$G022"; then
    check_pass "022 contains the critical-rules-034 dispatch-level extension"
else
    check_fail "022 contains the critical-rules-034 dispatch-level extension" "critical-rules-034 dispatch-level extension not found in 022-orchestrator-context-discipline.md"
fi

# (d) Task cards contain NO multi-step dispatch template text.
TASK_CARD_TEMPLATE_TEXT=$(grep -rlF 'one dispatch = one discrete step' \
    "$TASK_CARDS_DIR" --include='*.md' 2>/dev/null | grep '/tasks/' || true)
if [ -n "$TASK_CARD_TEMPLATE_TEXT" ]; then
    check_fail "task cards contain no multi-step dispatch template text" \
        "found template text in: $TASK_CARD_TEMPLATE_TEXT"
else
    check_pass "task cards contain no multi-step dispatch template text"
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
