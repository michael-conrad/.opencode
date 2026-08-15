#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: no non-actionable historical records (V-SC-6 checklist)
# Maps to SC-6 from issue #2134: the rewritten
# .opencode/guidelines/117-session-trigger-behavior.md SHALL NOT contain
# non-actionable historical records — content that describes past state,
# removed features, or historical context without prescribing current agent
# behavior.
#
# The four V-SC-6 checks are absence checks: the purged-triggers list, the spec
# #426 historical reference, the per-turn guard reference, and any section
# lacking a normative instruction must all be absent.
#
# RED phase: the guideline still carries the purged-triggers list, the spec
# #426 reference, and the per-turn guard reference — so this test FAILS.
# GREEN phase: after the non-actionable historical records are removed, this
# test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2134-sc6-no-non-actionable-records.sh
# Exit: 0 if all checks pass, 1 if any check fails

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

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
echo "=== No Non-Actionable Historical Records -- SC-6 (V-SC-6, #2134) ==="
echo ""

GUIDELINE_FILE="$PROJECT_DIR/.opencode/guidelines/117-session-trigger-behavior.md"

# V-SC-6 #1: the list of purged triggers is absent from the guideline.
PURGED_TRIGGERS=(
    "on_main_branch"
    "protected_branch_with_changes"
    "dev_branch_with_changes"
    "uncommitted_work_warning"
    "stale_stash"
    "stale_submodule"
    "merge_conflict"
    "unpushed_commits"
    "orphaned_worktrees"
    "local_only_repo"
    "detect_check_prs_intent"
)
purged_found=0
for t in "${PURGED_TRIGGERS[@]}"; do
    if grep -q "$t" "$GUIDELINE_FILE"; then
        echo "    (purged trigger still present: $t)"
        purged_found=1
    fi
done
if [ "$purged_found" -eq 0 ]; then
    check_pass "V-SC-6 #1: purged triggers list absent"
else
    check_fail "V-SC-6 #1: purged triggers list absent" "one or more purged trigger names (on_main_branch, protected_branch_with_changes, etc.) still present in the guideline"
fi

# V-SC-6 #2: any reference to spec #426 as a historical event is absent.
if grep -q "#426" "$GUIDELINE_FILE"; then
    check_fail "V-SC-6 #2: spec #426 historical reference absent" "reference to spec #426 still present in the guideline"
else
    check_pass "V-SC-6 #2: spec #426 historical reference absent"
fi

# V-SC-6 #3: any reference to the removed per-turn protected branch edit guard is absent.
if grep -qiE "per-turn|per turn" "$GUIDELINE_FILE"; then
    check_fail "V-SC-6 #3: per-turn guard reference absent" "reference to the removed per-turn protected branch edit guard still present in the guideline"
else
    check_pass "V-SC-6 #3: per-turn guard reference absent"
fi

# V-SC-6 #4: every remaining section contains at least one MUST, MUST NOT, or
# SHOULD instruction for the agent. Sections are split on '## ' headings.
non_actionable_section=""
current_section=""
while IFS= read -r line; do
    if [[ "$line" =~ ^##\  ]]; then
        if [ -n "$current_section" ] && ! echo "$current_section" | grep -qiE "MUST|MUST NOT|SHOULD"; then
            non_actionable_section="$non_actionable_section $current_section"
        fi
        current_section="$line"
    else
        current_section="$current_section"$'\n'"$line"
    fi
done < "$GUIDELINE_FILE"
if [ -n "$current_section" ] && ! echo "$current_section" | grep -qiE "MUST|MUST NOT|SHOULD"; then
    non_actionable_section="$non_actionable_section $current_section"
fi

if [ -z "$non_actionable_section" ]; then
    check_pass "V-SC-6 #4: every remaining section contains a normative instruction"
else
    check_fail "V-SC-6 #4: every remaining section contains a normative instruction" "a section lacks any MUST/MUST NOT/SHOULD instruction for the agent"
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
