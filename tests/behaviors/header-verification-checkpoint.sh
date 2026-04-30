#!/bin/bash
# Behavioral Enforcement Test: Header Verification Checkpoint
#
# Verifies that the verification-before-completion skill includes a
# header-verification checkpoint that checks new files for required
# SPDX/Provenance/Byline headers per 080-code-standards.md.
#
# Issue #118: SC-3 and SC-6 — Missing copyright headers on new files
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="header-verification-checkpoint"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

WORKTREE_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Verify 1: 080-code-standards.md includes Scala header format
# SC-1: Scala header format under "Header Format by File Type"
STDARDS_FILE="$WORKTREE_ROOT/.opencode/guidelines/080-code-standards.md"
if ! grep -qi "Scala Files" "$STDARDS_FILE"; then
    echo "FAIL: $SCENARIO_NAME — SC-1: 080-code-standards.md missing Scala header format section"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — SC-1: 080-code-standards.md has Scala header format section"
fi

# Verify 2: 080-code-standards.md includes fallback rule for unlisted languages
# SC-2: Fallback rule for unlisted languages
if ! grep -qi "Other Languages.*Fallback\|Fallback Rule" "$STDARDS_FILE"; then
    echo "FAIL: $SCENARIO_NAME — SC-2: 080-code-standards.md missing fallback rule for unlisted languages"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — SC-2: 080-code-standards.md has fallback rule for unlisted languages"
fi

# Verify 3: verification-before-completion verify task includes header-verification checkpoint
# SC-3: Header-verification checkpoint in verification-before-completion
VERIFY_TASK="$WORKTREE_ROOT/.opencode/skills/verification-before-completion/tasks/verify.md"
if [ ! -f "$VERIFY_TASK" ]; then
    echo "FAIL: $SCENARIO_NAME — SC-3: verify.md task file not found"
    OVERALL_RESULT=1
elif ! grep -qi "Header Verification Checkpoint\|header-verification" "$VERIFY_TASK"; then
    echo "FAIL: $SCENARIO_NAME — SC-3: verify.md missing header-verification checkpoint"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — SC-3: verify.md has header-verification checkpoint"
fi

# Verify 4: The header-verification checkpoint references 080-code-standards.md
if [ -f "$VERIFY_TASK" ]; then
    if ! grep -qi "080-code-standards.md" "$VERIFY_TASK"; then
        echo "FAIL: $SCENARIO_NAME — SC-3: verify.md header checkpoint does not reference 080-code-standards.md"
        OVERALL_RESULT=1
    else
        echo "PASS: $SCENARIO_NAME — SC-3: verify.md header checkpoint references 080-code-standards.md"
    fi
fi

# Verify 5: The header-verification checkpoint checks for SPDX, Provenance, and Byline
if [ -f "$VERIFY_TASK" ]; then
    if ! grep -qi "SPDX" "$VERIFY_TASK" || ! grep -qi "Provenance" "$VERIFY_TASK" || ! grep -qi "byline\|Co-authored" "$VERIFY_TASK"; then
        echo "FAIL: $SCENARIO_NAME — SC-3: verify.md header checkpoint missing SPDX/Provenance/Byline checks"
        OVERALL_RESULT=1
    else
        echo "PASS: $SCENARIO_NAME — SC-3: verify.md header checkpoint includes SPDX/Provenance/Byline checks"
    fi
fi

# Verify 6: This behavioral test file exists (meta-verification for SC-6)
if [ ! -f "$SCRIPT_DIR/header-verification-checkpoint.sh" ]; then
    echo "FAIL: $SCENARIO_NAME — SC-6: Behavioral enforcement test file does not exist"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — SC-6: Behavioral enforcement test file exists"
fi

if [ $OVERALL_RESULT -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME — all checks passed"
else
    echo "FAIL: $SCENARIO_NAME — one or more checks failed"
fi

exit $OVERALL_RESULT