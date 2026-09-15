#!/usr/bin/env bash
# Issue 2442 — SC-2 RED content-verification test (string evidence type)
# Asserts the ".issues/ file-content read/write/edit/glob/grep prohibition"
# sentence is ABSENT from .opencode/AGENTS.md.
#
# GREEN target state: AGENTS.md no longer contains the prohibition on using
# read/write/edit/glob/grep against .issues/ FILE CONTENT (the sentence
# "silently targets the wrong repository and corrupts git state" and the
# FORBIDDEN table rows listing read/write/edit/glob on .issues/ paths).
#
# Expected NOW (RED): the prohibition text is still present → assertions fail
# → non-zero exit.

set -u
TARGET=".opencode/AGENTS.md"
FAILURES=0

check_absent() {
  # SC-2: prohibition pattern must be ABSENT
  local desc="$1" pattern="$2"
  if grep -qF -- "$pattern" "$TARGET"; then
    echo "FAIL (prohibition still present): $desc"
    grep -nF -- "$pattern" "$TARGET" | head -3
    FAILURES=$((FAILURES + 1))
  else
    echo "PASS (absent): $desc"
  fi
}

# SC-2 assertion 1: the prohibition sentence
check_absent "prohibition sentence 'silently targets the wrong repository and corrupts git state'" \
  "silently targets the wrong repository and corrupts git state"

# SC-2 assertion 2: FORBIDDEN table entry for read on .issues/ path
check_absent "FORBIDDEN table entry: read(filePath='.issues/..." \
  "read(filePath='.issues/46/spec.md')"

# SC-2 assertion 3: FORBIDDEN table entry for write on .issues/ path
check_absent "FORBIDDEN table entry: write(filePath='.issues/..." \
  "write(filePath='.issues/46/spec.md')"

# SC-2 assertion 4: blanket sentence naming read/write/edit/glob/grep on .issues/ paths
check_absent "sentence: read(), write(), edit(), glob(), grep() on .issues/ paths" \
  "Using \`read()\`, \`write()\`, \`edit()\`, \`glob()\`, or \`grep()\` on \`.issues/\` paths"

echo "---"
if [ "$FAILURES" -gt 0 ]; then
  echo "VERDICT: FAIL — $FAILURES prohibition pattern(s) still present in $TARGET (RED confirmed)"
  exit 1
fi
echo "VERDICT: PASS — prohibition absent (GREEN state reached)"
exit 0
