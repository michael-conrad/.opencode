#!/bin/bash
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Content-Verification Test: Writing-Plans Analyze Task Card
#
# Verifies that skills/writing-plans/tasks/analyze.md checks issue.yaml
# labels for approved-for-* instead of spec frontmatter approved field.
#
# SC-1: analyze.md checks issue.yaml labels for approved-for-* instead of
#        spec frontmatter approved field
# SC-4: analyze.md Entry Criteria and Procedure no longer reference spec
#        frontmatter approved field
#
# GREEN phase: analyze.md uses issue.yaml label-based check.
# Expected to PASS (exit 0).
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

ANALYZE_MD=".opencode/skills/writing-plans/tasks/analyze.md"

echo "=== RED Test: writing-plans-analyze ==="
echo "Checking $ANALYZE_MD for label-based approval check..."
echo ""

HAS_OLD_FRONTMATTER_ENTRY=false
HAS_OLD_FRONTMATTER_PROCEDURE=false
HAS_LABEL_CHECK=false

# Check 1 (SC-4): Entry Criteria must NOT reference spec frontmatter approved field
# Use specific pattern to distinguish from approved-for-* label references
if sed -n '/^## Entry Criteria/,/^## /p' "$ANALYZE_MD" | grep -qE 'frontmatter.*approved|approved.*(field|truthy)' 2>/dev/null; then
    HAS_OLD_FRONTMATTER_ENTRY=true
    echo "  [FOUND] frontmatter approved field in Entry Criteria (old check - expected RED)"
else
    echo "  [OK] No frontmatter approved field in Entry Criteria"
fi

# Check 2 (SC-4): Procedure must NOT reference spec frontmatter approved field
# Use specific pattern to distinguish from approved-for-* label references
if sed -n '/^## Procedure/,/^## /p' "$ANALYZE_MD" | grep -qE 'frontmatter.*approved|approved.*(field|truthy)' 2>/dev/null; then
    HAS_OLD_FRONTMATTER_PROCEDURE=true
    echo "  [FOUND] frontmatter approved field in Procedure (old check - expected RED)"
else
    echo "  [OK] No frontmatter approved field in Procedure"
fi

# Check 3 (SC-1): Must reference issue.yaml labels for approved-for-*
if grep -q 'issue\.yaml' "$ANALYZE_MD" 2>/dev/null && grep -q 'approved-for-' "$ANALYZE_MD" 2>/dev/null; then
    HAS_LABEL_CHECK=true
    echo "  [FOUND] issue.yaml approved-for-* label check"
else
    echo "  [MISSING] issue.yaml approved-for-* label check (expected RED)"
fi

echo ""
if $HAS_OLD_FRONTMATTER_ENTRY || $HAS_OLD_FRONTMATTER_PROCEDURE; then
    echo "EXPECTED FAIL: analyze.md still uses old spec frontmatter approved field check"
    echo "  Entry Criteria has old check: $HAS_OLD_FRONTMATTER_ENTRY"
    echo "  Procedure has old check: $HAS_OLD_FRONTMATTER_PROCEDURE"
    echo "  Has new label check: $HAS_LABEL_CHECK"
    exit 1
elif ! $HAS_LABEL_CHECK; then
    echo "EXPECTED FAIL: analyze.md missing issue.yaml approved-for-* label check"
    exit 1
else
    echo "PASS: analyze.md uses label-based check, no frontmatter approved field"
    exit 0
fi
