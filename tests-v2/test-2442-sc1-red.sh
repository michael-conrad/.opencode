#!/usr/bin/env bash
# RED test for issue .opencode#2442 SC-1 (structural grep).
#
# SC-1: The ".issues/ Is a Worktree — NOT a Regular Directory" section of
# .opencode/AGENTS.md must state the corrected two-part rule:
#   Part 1 (git axis): use `git -C <tree>/.issues/` for any git operations
#   against `.issues/` (it is a git worktree).
#   Part 2 (file axis): standard file access tools
#   (`read`/`write`/`edit`/`glob`/`grep`) are permitted for `.issues/` files.
#
# RED expectation: this test FAILS (exit non-zero) against the current file
# because the section currently PROHIBITS standard file tools.
# GREEN: after the section rewrite, both assertions pass and the test exits 0.

set -u

AGENTS_MD="$(cd "$(dirname "$0")/.." && pwd)/AGENTS.md"
FAILURES=0

fail() {
  echo "FAIL: $1" >&2
  FAILURES=$((FAILURES + 1))
}

# Extract the worktree section only (from the section header to the next '---').
SECTION=$(sed -n '/^### `\.issues\/` Is a Worktree/,/^---$/p' "$AGENTS_MD")
if [ -z "$SECTION" ]; then
  fail "worktree section not found in $AGENTS_MD"
  echo "EXIT: 1"
  exit 1
fi

# Part 2 (file axis): standard file tools are permitted for .issues/ files.
# The corrected rule must state the tool list and that use is permitted.
# SC-1: standard file access tools permitted for .issues/ files
if ! grep -q 'read`/`write`/`edit`/`glob`/`grep`' <<<"$SECTION"; then
  fail "SC-1: corrected rule text with file-tool list (read/write/edit/glob/grep) not present in worktree section"
elif ! grep -Eq 'permitted[^`]*for[[:space:]]*`?\.issues/' <<<"$SECTION"; then
  fail "SC-1: worktree section does not state file tools are PERMITTED for .issues/ files (current text prohibits them)"
fi

# Part 1 (git axis): git operations must be scoped with git -C.
# SC-1 (two-part rule, part 1): git -C required for .issues/ git operations
if ! grep -q 'git -C' <<<"$SECTION"; then
  fail "SC-1 part 1: git -C guidance for .issues/ git operations not present in worktree section"
fi

if [ "$FAILURES" -gt 0 ]; then
  echo "EXIT: 1"
  exit 1
fi
echo "EXIT: 0"
exit 0
