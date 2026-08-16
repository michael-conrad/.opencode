#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: Phase 15 — spec-creation SKILL.md
# link inventory
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan.md Phase 15 — spec-creation SKILL.md link inventory (prep),
#        target `.opencode/skills/spec-creation/SKILL.md`.
#
# Phase 15 (preparation, no SC): Produce the link inventory artifact
#   enumerating the markdown links in spec-creation/SKILL.md and their
#   resolution status (prep for SC-38). SC-38 requires that the non-existent
#   `docs/specs/how-to-write-good-spec-ai-agents.md` reference be removed or
#   repointed, and that every markdown link in the file resolve to an existing
#   path.
#
# The link inventory artifact SHALL:
#   (a) exist at `.opencode/.issues/2254/artifacts/spec-creation-link-inventory.yaml`;
#   (b) declare the number of inventoried links in spec-creation/SKILL.md
#       (`link_count`) matching the on-disk count, and enumerate each link
#       (`links_list`), where each enumerated link records its link text
#       (`link_text`), its target (`target`), and its resolution status
#       (`resolution_status`);
#   (c) cover all 6 inventoried links in spec-creation/SKILL.md
#       (`link_count: 6`) — the 5 markdown links plus the broken backtick
#       reference `docs/specs/how-to-write-good-spec-ai-agents.md`.
#
# On-disk markdown links in spec-creation/SKILL.md (5):
#   1. `[spec-creation/tasks/analyze.md](.opencode/skills/spec-creation/tasks/analyze.md)`
#   2. `[spec-creation/tasks/create.md](.opencode/skills/spec-creation/tasks/create.md)`
#   3. `[spec-creation/tasks/reconcile-push.md](.opencode/skills/spec-creation/tasks/reconcile-push.md)`
#   4. `[spec-creation/tasks/revise.md](.opencode/skills/spec-creation/tasks/revise.md)`
#   5. `[spec-creation/tasks/validate.md](.opencode/skills/spec-creation/tasks/validate.md)`
#
# Broken backtick reference in spec-creation/SKILL.md (1, unresolved):
#   6. `` `docs/specs/how-to-write-good-spec-ai-agents.md` `` — the target
#      file does not exist on disk (SC-38).
#
# RED state: the link inventory artifact does not exist yet.
#   Assertions (a), (b), (c), and (d) FAIL because the artifact file is absent.
#   GREEN produces the artifact at the declared path enumerating the 6 links
#   and their resolution status.
#
# Evidence type: preparation phase (no SC). This content-verification test
#   checks the existence and completeness of the link inventory artifact.
#   It is the RED/GREEN gate for the Phase 15 inventory deliverable.
#
# Usage: bash .opencode/tests-v2/test-2254-phase15-spec-creation-link-inventory.sh
# Exit:  0 if the link inventory artifact is complete (GREEN),
#        1 if it is missing or incomplete (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILL_FILE="$PROJECT_DIR/.opencode/skills/spec-creation/SKILL.md"
ARTIFACT="$PROJECT_DIR/.opencode/.issues/2254/artifacts/spec-creation-link-inventory.yaml"

# The broken backtick reference target that SC-38 requires to be inventoried
# (and later removed or repointed). It is not a `[text](path)` markdown link;
# it appears as a backtick code reference in the Plan Audit Code Deep Dive
# section.
BROKEN_REF_TARGET="docs/specs/how-to-write-good-spec-ai-agents.md"

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

# Extract the on-disk markdown links in spec-creation/SKILL.md, independent
# of the artifact. A markdown link is `[text](target)` where the target is a
# real project-relative path beginning with `.opencode/`. Returns the sorted
# unique links, one per line.
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
echo "=== Phase 15 — spec-creation SKILL.md link inventory (Spec .opencode#2254) ==="
echo ""
echo "Target file: $SKILL_FILE"
echo "Artifact:    $ARTIFACT"
echo ""

# ---------------------------------------------------------------------------
# On-disk reference: the markdown links and the broken backtick reference in
# spec-creation/SKILL.md, independent of the artifact.
# ---------------------------------------------------------------------------
LINKS="$(on_disk_links)"
MARKDOWN_LINK_COUNT="$(printf '%s\n' "$LINKS" | sed '/^$/d' | wc -l)"

# The broken backtick reference is present on disk if its target string
# appears in the file.
if grep -qF "$BROKEN_REF_TARGET" "$SKILL_FILE"; then
    BROKEN_REF_PRESENT=1
else
    BROKEN_REF_PRESENT=0
fi
LINK_COUNT=$((MARKDOWN_LINK_COUNT + BROKEN_REF_PRESENT))

echo "On-disk: $MARKDOWN_LINK_COUNT markdown links + $BROKEN_REF_PRESENT broken"
echo "         backtick reference = $LINK_COUNT inventoried links in"
echo "         spec-creation/SKILL.md."
echo ""

# ---------------------------------------------------------------------------
# (a) The link inventory artifact exists at the declared path.
# ---------------------------------------------------------------------------
echo "--- (a): link inventory artifact exists ---"

if [ -f "$ARTIFACT" ]; then
    check_pass "Phase 15: link inventory artifact exists at $ARTIFACT"
else
    check_fail "Phase 15: link inventory artifact exists" \
        "missing $ARTIFACT (GREEN must produce the spec-creation link inventory artifact)"
fi

# ---------------------------------------------------------------------------
# (b) The artifact declares the link count matching the on-disk count, and
#     enumerates each link with its link text, target, and resolution status.
# ---------------------------------------------------------------------------
echo "--- (b): artifact enumerates the links ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "link_count:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 15: artifact declares a link_count"
    else
        check_fail "Phase 15: artifact declares a link_count" \
            "no 'link_count:' key in $ARTIFACT"
    fi

    if grep -q "links_list:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 15: artifact declares a links_list"
    else
        check_fail "Phase 15: artifact declares a links_list" \
            "no 'links_list:' key in $ARTIFACT"
    fi

    while IFS= read -r link; do
        [ -n "$link" ] || continue
        target="$(printf '%s' "$link" | grep -oE '\(\.opencode/[^)]*\)' | tr -d '()')"
        text="$(printf '%s' "$link" | grep -oE '^\[[^]]*\]' | tr -d '[]')"

        if grep -q "^  - target: $target$" "$ARTIFACT" 2>/dev/null; then
            check_pass "Phase 15: artifact enumerates link target $target"
        else
            check_fail "Phase 15: artifact enumerates link target $target" \
                "no '  - target: $target' entry in links_list in $ARTIFACT"
            continue
        fi

        actual_text="$(artifact_link_text "$target")"
        if [ "$actual_text" = "$text" ]; then
            check_pass "Phase 15: link $target records link_text '$text'"
        else
            check_fail "Phase 15: link $target records link_text" \
                "expected '$text', artifact has '$actual_text'"
        fi

        if artifact_link_status "$target" | grep -qE '^(resolved|unresolved)$'; then
            check_pass "Phase 15: link $target records a resolution_status"
        else
            check_fail "Phase 15: link $target records a resolution_status" \
                "no '    resolution_status: resolved|unresolved' under link $target in $ARTIFACT"
        fi
    done <<< "$LINKS"

    # The broken backtick reference must be inventoried as an unresolved link
    # (SC-38). Its target is `docs/specs/how-to-write-good-spec-ai-agents.md`.
    if [ "$BROKEN_REF_PRESENT" = "1" ]; then
        if grep -q "^  - target: $BROKEN_REF_TARGET$" "$ARTIFACT" 2>/dev/null; then
            check_pass "Phase 15: artifact enumerates broken reference target $BROKEN_REF_TARGET"
        else
            check_fail "Phase 15: artifact enumerates broken reference target $BROKEN_REF_TARGET" \
                "no '  - target: $BROKEN_REF_TARGET' entry in links_list in $ARTIFACT"
        fi

        if artifact_link_status "$BROKEN_REF_TARGET" | grep -qE '^unresolved$'; then
            check_pass "Phase 15: broken reference $BROKEN_REF_TARGET records resolution_status 'unresolved'"
        else
            check_fail "Phase 15: broken reference $BROKEN_REF_TARGET records resolution_status" \
                "expected 'unresolved' (target file does not exist on disk per SC-38)"
        fi
    fi
else
    check_fail "Phase 15: artifact enumerates the links" \
        "artifact missing — cannot verify the $LINK_COUNT links are inventoried"
fi

# ---------------------------------------------------------------------------
# (c) The artifact covers all inventoried links in spec-creation/SKILL.md.
# ---------------------------------------------------------------------------
echo "--- (c): artifact covers all $LINK_COUNT inventoried links ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "link_count: $LINK_COUNT" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 15: artifact records link_count $LINK_COUNT"
    else
        check_fail "Phase 15: artifact records link_count $LINK_COUNT" \
            "expected 'link_count: $LINK_COUNT' in $ARTIFACT"
    fi
else
    check_fail "Phase 15: artifact covers all $LINK_COUNT inventoried links" \
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
        check_pass "Phase 15: artifact parses as valid YAML (links_list is well-formed {link_text, target, resolution_status} mappings)"
    else
        check_fail "Phase 15: artifact parses as valid YAML" \
            "artifact is not valid YAML — links_list must be well-formed {link_text, target, resolution_status} mappings (see stderr)"
    fi
else
    check_fail "Phase 15: artifact parses as valid YAML" \
        "artifact missing — cannot validate YAML"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 15 (spec-creation SKILL.md link inventory) not yet"
    echo "implemented. The link inventory artifact at $ARTIFACT is missing"
    echo "or incomplete. GREEN produces the artifact enumerating the $LINK_COUNT"
    echo "links in spec-creation/SKILL.md and their resolution status"
    echo "(resolved/unresolved), including the broken"
    echo "$BROKEN_REF_TARGET reference (SC-38)."
    echo ""
    exit 1
fi
echo "Phase 15 is GREEN — the spec-creation link inventory artifact enumerates"
echo "the $LINK_COUNT links in spec-creation/SKILL.md and their resolution status."
echo ""
exit 0
