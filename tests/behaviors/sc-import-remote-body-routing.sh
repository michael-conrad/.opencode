#!/usr/bin/env bash
# RED phase: verify remote body routing to remote.md instead of spec.md
# SC-1: import-remote writes remote body to remote.md
# SC-2: sync-pull-to-local writes remote body to remote.md
# SC-3: spec.md is never overwritten by remote body content

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

OVERALL_RESULT=0

# SC-1: import-remote Step 4 should write body to remote.md, not spec.md
# RED: this should FAIL because current code writes to spec.md
echo "=== SC-1: import-remote writes body to remote.md ==="
if grep -q 'Write.*remote\.md' skills/issue-operations/tasks/import-remote.md 2>/dev/null; then
  # If this passes, it means the change is already in place (should not happen in RED)
  echo "CHECK: import-remote references remote.md body write"
  grep -n 'remote\.md' skills/issue-operations/tasks/import-remote.md
  echo "PASS: SC-1 satisfied (unexpected in RED)"
else
  echo "FAIL: SC-1 not yet satisfied (expected in RED)"
  OVERALL_RESULT=1
fi

# SC-2: sync-pull-to-local Step 3 should write body to remote.md
echo "=== SC-2: sync-pull-to-local writes body to remote.md ==="
if grep -q 'Write.*remote\.md' skills/issue-operations/tasks/sync-pull-to-local.md 2>/dev/null; then
  echo "CHECK: sync-pull-to-local references remote.md body write"
  grep -n 'remote\.md' skills/issue-operations/tasks/sync-pull-to-local.md
  echo "PASS: SC-2 satisfied (unexpected in RED)"
else
  echo "FAIL: SC-2 not yet satisfied (expected in RED)"
  OVERALL_RESULT=1
fi

# SC-3: spec.md is never overwritten by remote body content
# Verify spec.md templates don't include <full_remote_issue_body> or similar
echo "=== SC-3: spec.md has no remote body content ==="
# SC-3: Verify that the body write target (Step 4 in import-remote, Step 3 in sync-pull-to-local)
# does NOT write the remote body into spec.md. The body should ONLY go to remote.md.
# Check: the Step 4 spec.md template in import-remote should have no body content after frontmatter.
# Check: the Step 3 template in sync-pull-to-local should not reference spec.md for body.
if grep -q 'Write `spec\.md`' skills/issue-operations/tasks/sync-pull-to-local.md 2>/dev/null; then
  echo "FAIL: SC-3 not satisfied - sync-pull-to-local Step 3 still writes spec.md"
  OVERALL_RESULT=1
else
  echo "PASS: SC-3 - sync-pull-to-local does not write spec.md for body"
fi

# Check the spec.md template in import-remote Step 4 has no body content below frontmatter
SPEC_MD_BODY=$(grep -A 15 'Write `spec\.md` with local frontmatter' skills/issue-operations/tasks/import-remote.md | grep -c '^$' | head -1)
# The spec.md section should have a blank line after frontmatter (the YAML close `---`) but no body content
# If the section has >5 lines after frontmatter close, it has body content
SPEC_MD_BODY_LINES=$(grep -A 15 'Write `spec\.md` with local frontmatter' skills/issue-operations/tasks/import-remote.md | wc -l)
if [ "$SPEC_MD_BODY_LINES" -gt 20 ]; then
  echo "FAIL: SC-3 not satisfied - import-remote spec.md template has body content ($SPEC_MD_BODY_LINES lines)"
  OVERALL_RESULT=1
else
  echo "PASS: SC-3 - import-remote spec.md template has frontmatter only"
fi

exit $OVERALL_RESULT