#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-4 — audit placeholder dispatch links
# use semantic templates in [text].
#
# Issue: .opencode#2296 — placeholder template semantics.
# SC-4: The audit skill's 4 placeholder dispatch links MUST use semantic
#       templates in [text] (not path templates), with URL path templates
#       unchanged and the 4 DiMo roles distinguishable.
#
# Target: `.opencode/skills/audit/SKILL.md` — the "Run an audit" Workflows
#         section (4 dispatch links).
#
# The 4 dispatch links (already semantic after SC-1's condensation rewrite,
# commit 9660e118):
#   1. `[investigate audit findings](.opencode/skills/audit/tasks/<audit-type>-investigator.md)`
#   2. `[validate audit findings](.opencode/skills/audit/tasks/<audit-type>-validator.md)`
#   3. `[evaluate audit findings](.opencode/skills/audit/tasks/<audit-type>-evaluator.md)`
#   4. `[arbitrate audit consensus](.opencode/skills/audit/tasks/<audit-type>-arbiter.md)`
#
# This is a REGRESSION test, not a RED test for absent work. SC-1 already
# converted the 4 links from path templates to semantic templates. This test
# asserts the SC-4 requirement holds in the current state and guards against
# future regression to path templates. It MUST PASS (exit 0) now.
#
# Assertions:
#   (a) The 4 audit dispatch links use semantic templates in [text] — the
#       [text] does NOT restate the path (e.g., not
#       `[audit/tasks/<audit-type>-investigator.md]`).
#   (b) The URL path templates are unchanged
#       (`audit/tasks/<audit-type>-{investigator|validator|evaluator|arbiter}.md`).
#   (c) The 4 DiMo roles remain distinguishable
#       (investigate/validate/evaluate/arbitrate are distinct).
#
# Evidence type: structural (content-verification). This test greps the
#   on-disk SKILL.md for the 4 dispatch links and asserts their [text] and
#   URL target forms.
#
# Usage: bash .opencode/tests-v2/test-2296-sc4-audit-placeholder-semantic.sh
# Exit:  0 if all SC-4 assertions hold (GREEN),
#        1 if any assertion fails (regression to path templates).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILL_FILE="$PROJECT_DIR/.opencode/skills/audit/SKILL.md"

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

# The 4 DiMo roles and their expected semantic [text] and URL path template.
# verb: the DiMo role verb (distinguishable).
# text: the expected semantic [text] template.
# suffix: the URL path template file suffix (noun form, unchanged).
declare -a ROLES=(
    "investigate|investigate audit findings|investigator"
    "validate|validate audit findings|validator"
    "evaluate|evaluate audit findings|evaluator"
    "arbitrate|arbitrate audit consensus|arbiter"
)

echo ""
echo "=== SC-4 — audit placeholder dispatch links use semantic [text] (Spec .opencode#2296) ==="
echo ""
echo "Target file: $SKILL_FILE"
echo ""

# ---------------------------------------------------------------------------
# (a) The 4 audit dispatch links use semantic templates in [text] — the [text]
#     does NOT restate the path.
# ---------------------------------------------------------------------------
echo "--- (a): dispatch links use semantic [text] templates ---"

for entry in "${ROLES[@]}"; do
    IFS='|' read -r verb text suffix <<< "$entry"

    # The link must exist with the semantic [text] and the unchanged URL path.
    # Match against the on-disk form (project-relative path in the target).
    on_disk_link="[$text](.opencode/skills/audit/tasks/<audit-type>-${suffix}.md)"

    if grep -qF "$on_disk_link" "$SKILL_FILE"; then
        check_pass "SC-4: dispatch link uses semantic [text] '$text' with unchanged path 'audit/tasks/<audit-type>-${suffix}.md'"
    else
        check_fail "SC-4: dispatch link uses semantic [text] '$text'" \
            "expected on-disk link '$on_disk_link' not found in $SKILL_FILE"
    fi

    # The [text] MUST NOT restate the path (path-template regression guard).
    # A path-template [text] would be `[audit/tasks/<audit-type>-${suffix}.md]`.
    path_text="audit/tasks/<audit-type>-${suffix}.md"
    if grep -qF "[$path_text]" "$SKILL_FILE"; then
        check_fail "SC-4: [text] does not restate the path" \
            "found path-template [text] '[$path_text]' in $SKILL_FILE — regression to path template"
    else
        check_pass "SC-4: [text] does not restate the path (no '[$path_text]' present)"
    fi
done

# ---------------------------------------------------------------------------
# (b) The URL path templates are unchanged
#     (`audit/tasks/<audit-type>-{investigator|validator|evaluator|arbiter}.md`).
# ---------------------------------------------------------------------------
echo "--- (b): URL path templates unchanged ---"

for entry in "${ROLES[@]}"; do
    IFS='|' read -r verb text suffix <<< "$entry"

    if grep -qF "(.opencode/skills/audit/tasks/<audit-type>-${suffix}.md)" "$SKILL_FILE"; then
        check_pass "SC-4: URL path template unchanged 'audit/tasks/<audit-type>-${suffix}.md'"
    else
        check_fail "SC-4: URL path template unchanged" \
            "expected '(.opencode/skills/audit/tasks/<audit-type>-${suffix}.md)' not found in $SKILL_FILE"
    fi
done

# ---------------------------------------------------------------------------
# (c) The 4 DiMo roles remain distinguishable
#     (investigate/validate/evaluate/arbitrate are distinct).
# ---------------------------------------------------------------------------
echo "--- (c): 4 DiMo roles distinguishable ---"

# The 4 role verbs must be distinct.
distinct_roles="$(printf '%s\n' "${ROLES[@]}" | cut -d'|' -f1 | sort -u | wc -l)"
if [ "$distinct_roles" -eq 4 ]; then
    check_pass "SC-4: 4 DiMo roles are distinct (investigate/validate/evaluate/arbitrate)"
else
    check_fail "SC-4: 4 DiMo roles are distinct" \
        "expected 4 distinct role verbs, found $distinct_roles"
fi

# Each role verb must appear in the SKILL.md dispatch section.
for entry in "${ROLES[@]}"; do
    IFS='|' read -r verb text suffix <<< "$entry"
    if grep -qF "$text" "$SKILL_FILE"; then
        check_pass "SC-4: role '$verb' present via semantic text '$text'"
    else
        check_fail "SC-4: role '$verb' present" \
            "semantic text '$text' not found in $SKILL_FILE"
    fi
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "SC-4 regression detected: one or more audit dispatch links have"
    echo "regressed from semantic [text] templates to path templates, or the"
    echo "URL path templates changed, or the 4 DiMo roles are no longer"
    echo "distinguishable. Restore the semantic [text] templates in"
    echo "$SKILL_FILE"
    echo ""
    exit 1
fi
echo "SC-4 holds — the 4 audit dispatch links use semantic [text] templates,"
echo "the URL path templates are unchanged, and the 4 DiMo roles are"
echo "distinguishable."
echo ""
exit 0
