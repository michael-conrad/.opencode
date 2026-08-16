#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: Phase 13 — audit SKILL.md link inventory
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan.md Phase 13 — audit SKILL.md link inventory (prep),
#        target `.opencode/skills/audit/SKILL.md`.
#
# Phase 13 (preparation, no SC): Produce the link inventory artifact
#   enumerating the markdown links in audit/SKILL.md and their resolution
#   status (prep). Depends on Phase 10 (the audit workflow inventory artifact
#   enumerating the `Run an audit` Workflows steps).
#
# The link inventory artifact SHALL:
#   (a) exist at `.opencode/.issues/2254/artifacts/audit-link-inventory.yaml`;
#   (b) declare the number of markdown links in audit/SKILL.md
#       (`link_count`) matching the on-disk count, and enumerate each link
#       (`links_list`), where each enumerated link records its link text
#       (`link_text`), its target (`target`), and its resolution status
#       (`resolution_status`);
#   (c) cover all 5 markdown links in audit/SKILL.md (`link_count: 5`).
#
# On-disk markdown links in audit/SKILL.md (5):
#   1. `[audit/tasks/<task>-investigator.md](.opencode/skills/audit/tasks/<task>-investigator.md)`
#   2. `[audit/tasks/<task>-validator.md](.opencode/skills/audit/tasks/<task>-validator.md)`
#   3. `[audit/tasks/<task>-evaluator.md](.opencode/skills/audit/tasks/<task>-evaluator.md)`
#   4. `[audit/tasks/<task>-arbiter.md](.opencode/skills/audit/tasks/<task>-arbiter.md)`
#   5. `[audit skill](.opencode/skills/audit/SKILL.md)`
#
# RED state: the link inventory artifact does not exist yet.
#   Assertions (a), (b), and (c) FAIL because the artifact file is absent.
#   GREEN produces the artifact at the declared path enumerating the 5 markdown
#   links and their resolution status.
#
# Evidence type: preparation phase (no SC). This content-verification test
#   checks the existence and completeness of the link inventory artifact.
#   It is the RED/GREEN gate for the Phase 13 inventory deliverable.
#
# Usage: bash .opencode/tests-v2/test-2254-phase13-audit-link-inventory.sh
# Exit:  0 if the link inventory artifact is complete (GREEN),
#        1 if it is missing or incomplete (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILL_FILE="$PROJECT_DIR/.opencode/skills/audit/SKILL.md"
ARTIFACT="$PROJECT_DIR/.opencode/.issues/2254/artifacts/audit-link-inventory.yaml"

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

# Extract the on-disk markdown links in audit/SKILL.md, independent of the
# artifact. A markdown link is `[text](target)` where the target is a real
# project-relative path beginning with `.opencode/`. The literal
# `[Text](path)` pattern reference is excluded because its target `path` is a
# placeholder, not a real path. Returns the sorted unique links, one per line.
on_disk_links() {
    grep -oE '\[[^]]*\]\(\.opencode/[^)]*\)' "$SKILL_FILE" | sort -u
}

# Extract the link_text recorded for a given target in the artifact's
# links_list. Returns the text on the first matching entry.
artifact_link_text() {
    local target="$1"
    awk -v t="$target" '
        $0 ~ "^  - target: " t "$" { in_link=1; next }
        in_link && /^    link_text:/ {
            line=$0
            sub(/^[[:space:]]*link_text:[[:space:]]*/, "", line)
            print line
            in_link=0
        }
    ' "$ARTIFACT"
}

# Extract the resolution_status recorded for a given target in the artifact's
# links_list. Returns the status on the first matching entry.
artifact_link_status() {
    local target="$1"
    awk -v t="$target" '
        $0 ~ "^  - target: " t "$" { in_link=1; next }
        in_link && /^    resolution_status:/ {
            line=$0
            sub(/^[[:space:]]*resolution_status:[[:space:]]*/, "", line)
            print line
            in_link=0
        }
    ' "$ARTIFACT"
}

echo ""
echo "=== Phase 13 — audit SKILL.md link inventory (Spec .opencode#2254) ==="
echo ""
echo "Target file: $SKILL_FILE"
echo "Artifact:    $ARTIFACT"
echo ""

# ---------------------------------------------------------------------------
# On-disk reference: the markdown links in audit/SKILL.md, independent of the
# artifact.
# ---------------------------------------------------------------------------
LINKS="$(on_disk_links)"
LINK_COUNT="$(printf '%s\n' "$LINKS" | sed '/^$/d' | wc -l)"

echo "On-disk: $LINK_COUNT markdown links in audit/SKILL.md."
echo ""

# ---------------------------------------------------------------------------
# (a) The link inventory artifact exists at the declared path.
# ---------------------------------------------------------------------------
echo "--- (a): link inventory artifact exists ---"

if [ -f "$ARTIFACT" ]; then
    check_pass "Phase 13: link inventory artifact exists at $ARTIFACT"
else
    check_fail "Phase 13: link inventory artifact exists" \
        "missing $ARTIFACT (GREEN must produce the audit link inventory artifact)"
fi

# ---------------------------------------------------------------------------
# (b) The artifact declares the link count matching the on-disk count, and
#     enumerates each link with its link text, target, and resolution status.
# ---------------------------------------------------------------------------
echo "--- (b): artifact enumerates the markdown links ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "link_count:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 13: artifact declares a link_count"
    else
        check_fail "Phase 13: artifact declares a link_count" \
            "no 'link_count:' key in $ARTIFACT"
    fi

    if grep -q "links_list:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 13: artifact declares a links_list"
    else
        check_fail "Phase 13: artifact declares a links_list" \
            "no 'links_list:' key in $ARTIFACT"
    fi

    while IFS= read -r link; do
        [ -n "$link" ] || continue
        target="$(printf '%s' "$link" | grep -oE '\(\.opencode/[^)]*\)' | tr -d '()')"
        text="$(printf '%s' "$link" | grep -oE '^\[[^]]*\]' | tr -d '[]')"

        if grep -q "^  - target: $target$" "$ARTIFACT" 2>/dev/null; then
            check_pass "Phase 13: artifact enumerates link target $target"
        else
            check_fail "Phase 13: artifact enumerates link target $target" \
                "no '  - target: $target' entry in links_list in $ARTIFACT"
            continue
        fi

        actual_text="$(artifact_link_text "$target")"
        if [ "$actual_text" = "$text" ]; then
            check_pass "Phase 13: link $target records link_text '$text'"
        else
            check_fail "Phase 13: link $target records link_text" \
                "expected '$text', artifact has '$actual_text'"
        fi

        if artifact_link_status "$target" | grep -qE '^(resolved|unresolved)$'; then
            check_pass "Phase 13: link $target records a resolution_status"
        else
            check_fail "Phase 13: link $target records a resolution_status" \
                "no '    resolution_status: resolved|unresolved' under link $target in $ARTIFACT"
        fi
    done <<< "$LINKS"
else
    check_fail "Phase 13: artifact enumerates the markdown links" \
        "artifact missing — cannot verify the $LINK_COUNT markdown links are inventoried"
fi

# ---------------------------------------------------------------------------
# (c) The artifact covers all 5 markdown links in audit/SKILL.md.
# ---------------------------------------------------------------------------
echo "--- (c): artifact covers all $LINK_COUNT markdown links ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "link_count: $LINK_COUNT" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 13: artifact records link_count $LINK_COUNT"
    else
        check_fail "Phase 13: artifact records link_count $LINK_COUNT" \
            "expected 'link_count: $LINK_COUNT' in $ARTIFACT"
    fi
else
    check_fail "Phase 13: artifact covers all $LINK_COUNT markdown links" \
        "artifact missing — cannot verify link coverage"
fi

# ---------------------------------------------------------------------------
# (d) The artifact parses as valid YAML. Defect guard: links_list must be
#     well-formed YAML mappings (each item a {link_text, target,
#     resolution_status} mapping), not scalar items mixed with mapping keys at
#     the same indentation. This assertion uses a real YAML parser so this
#     defect class cannot recur.
# ---------------------------------------------------------------------------
echo "--- (d): artifact parses as valid YAML ---"

if [ -f "$ARTIFACT" ]; then
    if python3 -c "
import sys, yaml
try:
    with open('$ARTIFACT') as f:
        data = yaml.safe_load(f)
except Exception as e:
    print('YAML parse error: %s' % e, file=sys.stderr)
    sys.exit(1)
if not isinstance(data, dict):
    print('YAML root is not a mapping', file=sys.stderr)
    sys.exit(1)
lst = data.get('links_list')
if not isinstance(lst, list):
    print('links_list is not a list', file=sys.stderr)
    sys.exit(1)
for item in lst:
    if not isinstance(item, dict):
        print('links_list item is not a mapping: %r' % (item,), file=sys.stderr)
        sys.exit(1)
    for field in ('link_text', 'target', 'resolution_status'):
        if field not in item:
            print('links_list item missing field %r: %r' % (field, item), file=sys.stderr)
            sys.exit(1)
sys.exit(0)
"; then
        check_pass "Phase 13: artifact parses as valid YAML (links_list is well-formed {link_text, target, resolution_status} mappings)"
    else
        check_fail "Phase 13: artifact parses as valid YAML" \
            "artifact is not valid YAML — links_list must be well-formed {link_text, target, resolution_status} mappings (see stderr)"
    fi
else
    check_fail "Phase 13: artifact parses as valid YAML" \
        "artifact missing — cannot validate YAML"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 13 (audit SKILL.md link inventory) not yet"
    echo "implemented. The link inventory artifact at $ARTIFACT is missing"
    echo "or incomplete. GREEN produces the artifact enumerating the $LINK_COUNT"
    echo "markdown links in audit/SKILL.md and their resolution status"
    echo "(resolved/unresolved)."
    echo ""
    exit 1
fi
echo "Phase 13 is GREEN — the audit link inventory artifact enumerates the"
echo "$LINK_COUNT markdown links in audit/SKILL.md and their resolution status."
echo ""
exit 0
