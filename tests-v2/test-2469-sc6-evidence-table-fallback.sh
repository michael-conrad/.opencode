#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# RED test for issue 2469 SC-6:
# Evidence-table behavioral row MUST carry a primary instrument AND a fallback
# instrument, aligned to SC-5 semantics (fallback = "strongest available
# execution-based evidence" / "strongest available in-repo execution-based
# instrument", Read-link to the tests-v2 Scope Anchor).
#
# GREEN state: behavioral row in .opencode/reference/spec-structure-standards.md
# Evidence Type Taxonomy contains both:
#   - primary instrument: `opencode run` (deck-repo scope)
#   - fallback instrument: strongest available execution-based evidence
#     (non-deck-repo scope), Read-linked to SC-5 semantics

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

REF_FILE="$REPO_ROOT/.opencode/reference/spec-structure-standards.md"
fail() {
  echo "FAIL SC-6: $1" >&2
  exit 1
}

[ -f "$REF_FILE" ] || fail "reference file missing: $REF_FILE"

# Behavioral row of the Evidence Type Taxonomy table
BEHAVIORAL_ROW="$(grep -E '^\| `behavioral`' "$REF_FILE")"
[ -n "$BEHAVIORAL_ROW" ] || fail "behavioral row not found in Evidence Type Taxonomy"

# 1. Primary instrument present (deck repo: opencode run)
echo "$BEHAVIORAL_ROW" | grep -q 'opencode run' \
  || fail "behavioral row missing primary instrument: opencode run"

# 2. Fallback instrument present (non-deck-repo scope: strongest available
#    execution-based evidence)
echo "$BEHAVIORAL_ROW" | grep -Eq 'strongest available (in-repo )?execution-based (evidence|instrument)' \
  || fail "behavioral row missing fallback instrument: 'strongest available execution-based evidence'"

# 3. Fallback aligned to SC-5 semantics via Read-link (Scope Anchor)
SC5_LINK="$(grep -n 'SC-5' "$REF_FILE" | grep -i 'Read' || true)"
if [ -z "$SC5_LINK" ]; then
  # Accept a Read-link whose target encodes SC-5 semantics (Scope Anchor)
  SC5_LINK="$(grep -n 'scope-anchor\|Scope Anchor' "$REF_FILE" | grep -i 'Read' || true)"
fi
[ -n "$SC5_LINK" ] \
  || fail "fallback instrument not aligned to SC-5 semantics via Read-link in reference file"

# 4. Reference file not modified by this test
[ -z "$(git -C "$REPO_ROOT" status --porcelain .opencode/reference/spec-structure-standards.md)" ] \
  || fail "reference file was modified"

echo "PASS SC-6: behavioral row carries primary + fallback instrument, Read-linked to SC-5 semantics"
exit 0