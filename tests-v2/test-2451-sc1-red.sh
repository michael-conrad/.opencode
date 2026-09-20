#!/usr/bin/env bash
# RED test for issue .opencode#2451 SC-1 (string grep — content-verification).
#
# SC-1: `.opencode/guidelines/257-procedural-discipline-reference.md` contains
# canonical pattern p-dis-007 "One-Dispatch-One-Step Gate," added per that
# card's §11 add-pattern procedure:
#   - catalog row (Section 1 Pattern ID Allocation)
#   - selection matrix entry (Section 2)
#   - canonical formula (Section 3)
#   - co-application with 250/255 (Section 4)
#   - auto-detection trigger (Section 10)
#   - version tracking (Section 9)
#   - research basis (Section 13)
# Bright-line content: one dispatch = one discrete step; enumerated violation
# shapes (two task cards, run+verify, multi-SC verification, Task A/Task B
# shapes, "combined effectiveness run"); a dispatch carrying more than one
# discrete step is a violation NO MATTER THE REASONING; the rule is
# structural, not reasoning-classification.
#
# RED expectation: this test FAILS (exit non-zero) against the current file
# because the pattern catalog currently ends at p-dis-006 and p-dis-007 is
# absent. GREEN: after the pattern is added per §11, all assertions pass and
# the test exits 0.

set -u

CARD="$(cd "$(dirname "$0")/.." && pwd)/guidelines/257-procedural-discipline-reference.md"
FAILURES=0

fail() {
  echo "FAIL: $1" >&2
  FAILURES=$((FAILURES + 1))
}

if [ ! -f "$CARD" ]; then
  fail "reference card not found: $CARD"
  echo "EXIT: 1"
  exit 1
fi

# SC-1: pattern ID p-dis-007 present with the canonical pattern name
if ! grep -q 'p-dis-007' "$CARD"; then
  fail "SC-1: pattern ID p-dis-007 absent from 257 reference card"
fi
if ! grep -qi 'One-Dispatch-One-Step Gate' "$CARD"; then
  fail "SC-1: pattern name 'One-Dispatch-One-Step Gate' absent from 257 reference card"
fi

# SC-1 (§11 artifact): catalog row in Section 1 Pattern ID Allocation table
SECTION1=$(sed -n '/^## Section 1:/,/^## Section 2:/p' "$CARD")
if ! grep -q 'p-dis-007' <<<"$SECTION1"; then
  fail "SC-1 §11: catalog row for p-dis-007 absent from Section 1 (Pattern ID Allocation)"
fi

# SC-1 (§11 artifact): selection matrix entry in Section 2
SECTION2=$(sed -n '/^## Section 2:/,/^## Section 3:/p' "$CARD")
if ! grep -q 'p-dis-007' <<<"$SECTION2"; then
  fail "SC-1 §11: selection matrix entry for p-dis-007 absent from Section 2"
fi

# SC-1 (§11 artifact): canonical formula entry in Section 3
SECTION3=$(sed -n '/^## Section 3:/,/^## Section 4:/p' "$CARD")
if ! grep -q 'p-dis-007' <<<"$SECTION3"; then
  fail "SC-1 §11: canonical formula entry for p-dis-007 absent from Section 3"
fi

# SC-1 (§11 artifact): co-application with 250 and 255 in Section 4
SECTION4=$(sed -n '/^## Section 4:/,/^## Section 5:/p' "$CARD")
if ! grep -q 'p-dis-007' <<<"$SECTION4"; then
  fail "SC-1 §11: co-application reference for p-dis-007 absent from Section 4"
fi

# SC-1 (§11 artifact): auto-detection trigger in Section 10
SECTION10=$(sed -n '/^## Section 10:/,/^## Section 11:/p' "$CARD")
if ! grep -q 'p-dis-007' <<<"$SECTION10"; then
  fail "SC-1 §11: auto-detection trigger for p-dis-007 absent from Section 10"
fi

# SC-1 (§11 artifact): version tracking updated in Section 9
SECTION9=$(sed -n '/^## Section 9:/,/^## Section 10:/p' "$CARD")
if ! grep -q 'p-dis-007' <<<"$SECTION9"; then
  fail "SC-1 §11: version tracking entry for p-dis-007 absent from Section 9"
fi

# SC-1 (§11 artifact): research basis coverage in Section 13
SECTION13=$(sed -n '/^## Section 13:/,/^______/p' "$CARD")
if ! grep -q 'p-dis-007' <<<"$SECTION13"; then
  fail "SC-1 §11: research basis reference for p-dis-007 absent from Section 13"
fi

# SC-1 (bright-line): one dispatch = one discrete step
if ! grep -Eq 'one dispatch[[:space:]]*=[[:space:]]*one discrete step' "$CARD"; then
  fail "SC-1: bright-line 'one dispatch = one discrete step' absent from 257"
fi

# SC-1 (bright-line): enumerated violation shapes
for shape in 'two task cards' 'run+verify' 'multi-SC verification' 'Task A/Task B' 'combined effectiveness run'; do
  if ! grep -q "$shape" "$CARD"; then
    fail "SC-1: enumerated violation shape '$shape' absent from 257"
  fi
done

# SC-1 (bright-line): no-matter-the-reasoning clause
if ! grep -qi 'no matter the reasoning' "$CARD"; then
  fail "SC-1: no-matter-the-reasoning clause absent from 257"
fi

# SC-1 (bright-line): structural, not reasoning-classification
if ! grep -qi 'structural, not reasoning-classification' "$CARD"; then
  fail "SC-1: 'structural, not reasoning-classification' characterization absent from 257"
fi

if [ "$FAILURES" -gt 0 ]; then
  echo "EXIT: 1"
  exit 1
fi
echo "EXIT: 0"
exit 0
