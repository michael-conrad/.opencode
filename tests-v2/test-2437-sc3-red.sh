#!/usr/bin/env bash
# RED test for issue .opencode#2437 item 3, SC-3 (semantic evidence type).
#
# SC-3: `tasks/pr-creation.md` states the dispatch classification for each
# procedure step group (Steps 0-1: orchestrator-direct; Steps 2-4:
# orchestrator-direct; Steps 5-7: orchestrator-direct).
#
# Verification method (spec): clean-room sub-agent reads the task card and
# confirms each of the three step groups carries exactly one stated
# classification. This file is the structural (grep-level) enforcement check
# that models that read: it extracts each step-group's body from the task card
# and verifies the group carries exactly one stated `orchestrator-direct`
# classification statement.
#
# Step-group spans (the group includes its trailing subsections, e.g. the
# Pre-Push Submodule Pointer Verification subsection belongs to the Steps 0-1
# group because pointer verification happens before squash):
#   Steps 0-1: from `### Step 0-1:` heading up to (not incl.) `### Step 2-4:`
#   Steps 2-4: from `### Step 2-4:` heading up to (not incl.) `### Step 5-7:`
#   Steps 5-7: from `### Step 5-7:` heading up to (not incl.) `### Step 8:`
#
# RED expectation: this test FAILS (exit non-zero) against the current file
# because the three step groups carry only ambiguous "Route to" prose with no
# explicit per-step dispatch classification. GREEN: after each step group
# carries exactly one stated `orchestrator-direct` classification, all
# assertions pass and the test exits 0.

set -u

TASK_CARD="$(cd "$(dirname "$0")/.." && pwd)/skills/git-workflow-pr/tasks/pr-creation.md"
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

# Extract a step-group body: lines after the group's heading, up to (not
# including) the next group's heading. Body excludes the heading line itself.
GROUP_01=$(awk '/^### Step 0-1:/{f=1;next} /^### Step 2-4:/{f=0} f' "$TASK_CARD")
GROUP_24=$(awk '/^### Step 2-4:/{f=1;next} /^### Step 5-7:/{f=0} f' "$TASK_CARD")
GROUP_57=$(awk '/^### Step 5-7:/{f=1;next} /^### Step 8:/{f=0} f' "$TASK_CARD")

# SC-3: each step-group section must exist in the task card
if [ -z "$GROUP_01" ]; then
  fail "SC-3: Steps 0-1 group body not found (no '### Step 0-1:' heading)"
fi
if [ -z "$GROUP_24" ]; then
  fail "SC-3: Steps 2-4 group body not found (no '### Step 2-4:' heading)"
fi
if [ -z "$GROUP_57" ]; then
  fail "SC-3: Steps 5-7 group body not found (no '### Step 5-7:' heading)"
fi

# SC-3: each step group carries EXACTLY ONE stated orchestrator-direct
# classification statement (line count of the classification token == 1)
for group in "0-1" "2-4" "5-7"; do
  case "$group" in
    "0-1") BODY="$GROUP_01" ;;
    "2-4") BODY="$GROUP_24" ;;
    "5-7") BODY="$GROUP_57" ;;
  esac
  COUNT=$(grep -c 'orchestrator-direct' <<<"$BODY" || true)
  if [ "$COUNT" -ne 1 ]; then
    fail "SC-3: Steps $group group carries $COUNT 'orchestrator-direct' classification statements (required: exactly 1)"
  fi
done

if [ "$FAILURES" -gt 0 ]; then
  echo "EXIT: 1"
  exit 1
fi
echo "EXIT: 0"
exit 0

# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
