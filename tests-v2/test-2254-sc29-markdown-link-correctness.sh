#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-29a / SC-29b / SC-29c — markdown
# link correctness in spec-creation/SKILL.md, audit/SKILL.md, the reference
# docs, and issue-operations-core/tasks/creation.md.
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: 25 — markdown link correctness (SC-29a, SC-29b, SC-29c).
#
# SC-29a (string): All markdown links in the target files SHALL resolve to
#   real targets.
# SC-29b (string): All markdown links SHALL use correct relative paths.
# SC-29c (string): All markdown links SHALL be worded per the
#   `Read [Text](path)` cross-reference pattern.
#
# Canonical relative-path convention: project-root-relative with `.opencode/`
# prefix. This matches the skildeck linter R5 resolution (base_dir.parent) and
# the accepted dispatch links in spec-creation/SKILL.md
# (`.opencode/skills/spec-creation/tasks/<task>.md`).
#
# RED state: audit/SKILL.md links `skills/audit/SKILL.md` (non-prefixed),
# creation.md links `guidelines/...` (non-prefixed), and
# task-card-structure-standards.md links `reference/...` and `guidelines/...`
# (non-prefixed) — all fail to resolve from the project root. The assertions
# below FAIL on this content. GREEN prefixes every non-prefixed `.md` link
# with `.opencode/` so it resolves to a real target with a correct relative
# path, worded per the `Read [Text](path)` pattern.
#
# Evidence type: SC-29a/b/c are `string` SCs. This content-verification test
# extracts real markdown links and verifies target existence, relative-path
# correctness, and `Read [Text](path)` wording. It is the primary gate for
# these content-only SCs (no runtime behavior is changed).
#
# Usage: bash .opencode/tests-v2/test-2254-sc29-markdown-link-correctness.sh
# Exit:  0 if all markdown links in the target files resolve to real targets
#         with correct relative paths and `Read [Text](path)` wording (GREEN),
#        1 otherwise (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

# PROJECT_DIR resolves to the git repo root (the directory that contains the
# .opencode/ submodule). Markdown links in the target files resolve relative
# to this root, and the canonical form is `.opencode/`-prefixed.
ROOT_DIR="$PROJECT_DIR"

TARGET_FILES=(
    ".opencode/skills/spec-creation/SKILL.md"
    ".opencode/skills/audit/SKILL.md"
    ".opencode/reference/skill-card-description-standards.md"
    ".opencode/reference/task-card-structure-standards.md"
    ".opencode/reference/spec-structure-standards.md"
    ".opencode/reference/plan-structure-standards.md"
    ".opencode/reference/cost-model-standards.md"
    ".opencode/reference/skill-card-schema.md"
    ".opencode/skills/issue-operations-core/tasks/creation.md"
)

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
echo "=== SC-29a/b/c — markdown link correctness (Spec .opencode#2254, Phase 25) ==="
echo ""
echo "Project root: $ROOT_DIR"
echo ""

# ---------------------------------------------------------------------------
# For each target file, extract real markdown links and verify:
#   SC-29a: the target resolves to a real file
#   SC-29b: the target uses the correct `.opencode/`-prefixed relative path
#   SC-29c: the link is worded per the `Read [Text](path)` pattern
# ---------------------------------------------------------------------------

for rel in "${TARGET_FILES[@]}"; do
    file="$ROOT_DIR/$rel"
    if [ ! -f "$file" ]; then
        check_fail "SC-29a: target file exists" "$rel not found"
        continue
    fi
    check_pass "SC-29a: target file exists ($rel)"

    # Track the current line for context (dispatch directives vs cross-references).
    line_no=0
    while IFS= read -r line; do
        line_no=$((line_no + 1))
        # Skip lines that are dispatch directives: these legitimately use the
        # `Follow the instructions in [<task>.md](...)` form, NOT the
        # `Read [Text](path)` cross-reference form. SC-29c wording applies only
        # to cross-reference links.
        if [[ "$line" == *"Follow the instructions in"* ]]; then
            continue
        fi

        # Extract markdown links `[text](target)` on this line into an array
        # (avoids a subshell so PASS/FAIL counters persist).
        mapfile -t line_links < <(grep -oE '\[[^]]+\]\([^)]+\)' <<< "$line" 2>/dev/null || true)
        for full in "${line_links[@]}"; do
            # Extract the link text and the target.
            text=$(echo "$full" | sed -E 's/^\[([^]]+)\]\(.*\)$/\1/')
            target=$(echo "$full" | grep -oE '\]\([^)]*\)' | sed -E 's/^\]\(//; s/\)$//')

            # Skip non-file targets, template placeholders, and the literal
            # pattern illustration `Read [Text](path)`.
            case "$target" in
                http*|'#'*|''|'path') continue ;;
                *'<*'*) continue ;;
            esac

            label="$rel:$line_no: $full"

            # --- SC-29b: correct relative path (`.opencode/`-prefixed) ---
            if [[ "$target" != ".opencode/"* ]]; then
                check_fail "SC-29b: correct relative path" "$label (target '$target' lacks .opencode/ prefix)"
                continue
            fi

            # --- SC-29a: target resolves to a real file ---
            if [ ! -e "$ROOT_DIR/$target" ]; then
                check_fail "SC-29a: link resolves to real target" "$label (target '$target' does not exist)"
                continue
            fi

            # --- SC-29c: `Read [Text](path)` wording ---
            # The `Read [Text](path)` pattern means the word "Read" immediately
            # precedes the link in the prose. Check that the text before the
            # link's opening bracket ends with `Read `.
            prefix="${line%%"$full"*}"
            if [[ "$prefix" != *"Read " ]]; then
                check_fail "SC-29c: Read [Text](path) wording" "$label (link '$full' is not preceded by a Read [Text](path) directive)"
                continue
            fi

            check_pass "SC-29a/b/c: link resolves with correct relative path and Read wording ($label)"
        done
    done < "$file"
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-29a/b/c (markdown link correctness) not yet implemented."
    echo "The following links do not resolve from the project root because they lack the"
    echo "canonical '.opencode/' prefix, or are not worded per the Read [Text](path) pattern:"
    echo "  - audit/SKILL.md: 'skills/audit/SKILL.md'"
    echo "  - issue-operations-core/tasks/creation.md: 'guidelines/...' (000/141/065)"
    echo "  - task-card-structure-standards.md: 'reference/spec-structure-standards.md'"
    echo "    and 'guidelines/080-code-standards.md'"
    echo "GREEN prefixes every non-prefixed '.md' link with '.opencode/' so it resolves to a"
    echo "real target with a correct relative path, worded per the Read [Text](path) pattern."
    echo ""
    exit 1
fi
echo "SC-29a/b/c is GREEN — every markdown link in the target files resolves to a real"
echo "target, uses the correct '.opencode/'-prefixed relative path, and is worded per the"
echo "Read [Text](path) cross-reference pattern."
echo ""
exit 0
