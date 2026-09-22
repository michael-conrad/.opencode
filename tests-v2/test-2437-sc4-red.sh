#!/usr/bin/env bash
# RED test for issue .opencode#2437 item 4, SC-4 (semantic evidence type).
#
# SC-4: Each nested `pr-creation/*.md` sub-task card (`enforcement-gate.md`,
# `squash-push.md`, `create-pr.md`) is classified as a `task-card` dispatch
# point in `tasks/pr-creation.md`.
#
# Verification method (spec): clean-room sub-agent reads the task card and
# confirms each of the three sub-task files is listed as a `task-card`
# dispatch point. This file is the structural (grep-level) enforcement check
# that models that read: for each of the three sub-task route references in
# the task card, it verifies the reference is classified `task-card`.
#
# Span model: the task card is split into heading-bounded spans at `##` and
# `###` headings. A sub-task is "listed as a task-card dispatch point" when a
# span that references the sub-task (`pr-creation/<name>`) also carries the
# `task-card` classification token. The `## Context Required` section is
# excluded from classification scanning — its "Related tasks" line is a
# cross-reference list, not a dispatch-point classification surface.
#
# RED expectation: this test FAILS (exit non-zero) against the current file
# because all three sub-task route references carry only the
# `orchestrator-direct` step-group classification (or bare "Route to" prose)
# and the token `task-card` does not appear anywhere in the task card.
# GREEN: after each nested sub-task reference is classified `task-card`,
# all assertions pass and the test exits 0.

set -u

TASK_CARD="$(cd "$(dirname "$0")/.." && pwd)/skills/git-workflow-pr/tasks/pr-creation.md"
TASK_DIR="$(dirname "$TASK_CARD")"
FAILURES=0

fail() {
  echo "FAIL: $1" >&2
  FAILURES=$((FAILURES + 1))
}

if [ ! -f "$TASK_CARD" ]; then
  fail "task card not found: $TASK_CARD"
  echo "EXIT: 1"
  exit 1
fi

# Precondition: the three nested sub-task card files named by SC-4 exist.
for name in enforcement-gate squash-push create-pr; do
  if [ ! -f "$TASK_DIR/pr-creation/$name.md" ]; then
    fail "SC-4: nested sub-task card file not found: tasks/pr-creation/$name.md"
  fi
done

# SC-4: each nested sub-task card is listed as a `task-card` dispatch point.
# For each sub-task, every heading-bounded span of the task card that
# references `pr-creation/<name>` (outside the excluded Context Required
# section) must co-carry the `task-card` classification token in at least one
# such span. The awk program prints CLASSIFIED when at least one referencing
# span carries `task-card`, UNREFERENCED when the route token is absent from
# all admissible spans, and UNCLASSIFIED when referenced but never classified.
for name in enforcement-gate squash-push create-pr; do
  VERDICT=$(awk -v token="pr-creation/$name" '
    /^## Context Required/    { inctx=1; next }
    /^## / && !/Context Required/ { inctx=0 }
    /^#{2,3} /                { span++ }
    index($0, token) && !inctx { hit[span]=1 }
    index($0, "task-card")    { tc[span]=1 }
    END {
      listed=0; classified=0
      for (s in hit) {
        listed++
        if (s in tc) classified++
      }
      if (listed == 0)      print "UNREFERENCED"
      else if (classified > 0) print "CLASSIFIED"
      else                  print "UNCLASSIFIED"
    }
  ' "$TASK_CARD")
  case "$VERDICT" in
    CLASSIFIED)
      echo "PASS: SC-4: pr-creation/$name listed as a task-card dispatch point"
      ;;
    UNREFERENCED)
      fail "SC-4: pr-creation/$name not referenced in tasks/pr-creation.md (no route listing found)"
      ;;
    UNCLASSIFIED)
      fail "SC-4: pr-creation/$name referenced but never classified as a task-card dispatch point"
      ;;
  esac
done

if [ "$FAILURES" -gt 0 ]; then
  echo "EXIT: 1"
  exit 1
fi
echo "EXIT: 0"
exit 0
