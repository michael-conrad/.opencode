#!/usr/bin/env bash
# RED enforcement test — .opencode#2469 SC-5
# SC-5: TDD SKILL.md §Evidence Type Taxonomy prose separates universal
# evidence-type rigor from deck-repo instrument mechanics; taxonomy types,
# precedence, and EVIDENCE_TYPE_MISMATCH semantics remain unchanged.
# RED condition: grep for deck/non-deck instrument separation prose returns no match.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_MD="$REPO_ROOT/.opencode/skills/test-driven-development/SKILL.md"

FAILURES=0

fail() {
  echo "FAIL: $1" >&2
  FAILURES=$((FAILURES + 1))
}

if [ ! -f "$SKILL_MD" ]; then
  fail "SKILL.md not found at $SKILL_MD"
  echo "EXIT: 1"
  exit 1
fi

# Isolate the §Evidence Type Taxonomy + §Evidence Type Enforcement Matrix
# subsections (taxonomy heading through the next top-level-ish section,
# '### SC-to-Test Traceability'), so regression guards see the full block.
SECTION=$(sed -n '/^### Evidence Type Taxonomy/,/^### SC-to-Test Traceability/p' "$SKILL_MD" | sed '$d')
if [ -z "$SECTION" ]; then
  fail "Evidence Type Taxonomy section not found in $SKILL_MD"
  echo "EXIT: 1"
  exit 1
fi

# SC-5 assertion 1: separation prose must exist.
if ! grep -qE '(\.opencode.{0,20}targeted|deck.repo).{0,250}(instrument|opencode run)|(instrument|opencode run).{0,250}(\.opencode.{0,20}targeted|deck.repo)|universal.{0,120}(rigor|evidence)' <<<"$SECTION"; then
  fail "SC-5: no prose in Evidence Type Taxonomy separating universal evidence-type rigor from deck-repo instrument mechanics (RED: change not yet implemented)"
fi

# SC-5 assertion 2 (regression guard): taxonomy type table unchanged.
for TYPE in behavioral semantic string structural; do
  if ! grep -qE '^[| ]*`'"$TYPE"'`' <<<"$SECTION"; then
    fail "SC-5 regression: taxonomy row for '$TYPE' missing (table must remain unchanged)"
  fi
done

# SC-5 assertion 3 (regression guard): EVIDENCE_TYPE_MISMATCH semantics remain.
if ! grep -q 'EVIDENCE_TYPE_MISMATCH' <<<"$SECTION"; then
  fail "SC-5 regression: EVIDENCE_TYPE_MISMATCH semantics missing (precedence must remain unchanged)"
fi

if [ "$FAILURES" -gt 0 ]; then
  echo "EXIT: 1"
  exit 1
fi
echo "EXIT: 0"