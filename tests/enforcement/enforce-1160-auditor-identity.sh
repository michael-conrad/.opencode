#!/bin/bash
# Content-Verification Test: Auditor Identity Fix — spec-fix for #1160
#
# Verifies SC-1 through SC-4 from .opencode#1160:
#   SC-1: All 10 task files have role-anchoring header
#   SC-2: Zero `task()` code blocks (cross-validate dispatch patterns)
#   SC-3: Dispatch Mandate sections removed from all files
#   SC-4: Zero "Invoke.*cross-validate" imperative language
#
# RED-phase test: MUST FAIL before implementation changes (all patterns absent/incorrect).
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$SCRIPT_DIR")" != ".opencode" ]; do
    SCRIPT_DIR="$(dirname "$SCRIPT_DIR")"
done
TASKS_DIR="$SCRIPT_DIR/skills/adversarial-audit/tasks"

AUDITOR_FILES=(
    "spec-audit.md"
    "verification-audit.md"
    "guideline-audit.md"
    "plan-fidelity.md"
    "concern-separation.md"
    "closure-verification.md"
    "coherence-maintenance.md"
    "coherence-extraction.md"
    "spec-summary.md"
    "drift-detection.md"
)

FAILURES=0
FILE_COUNT=${#AUDITOR_FILES[@]}

echo "=== Content-Verification: Auditor Identity Fix (SC-1 through SC-4) ==="
echo "Target: $FILE_COUNT auditor task files"
echo ""

# --- SC-1: Role-anchoring header ---
echo "--- SC-1: Role-anchoring header present in all $FILE_COUNT files ---"
SC1_MATCHES=0
for f in "${AUDITOR_FILES[@]}"; do
    FILE="$TASKS_DIR/$f"
    if grep -qai "DISPATCHED AUDITOR SUB-AGENT" "$FILE" 2>/dev/null; then
        SC1_MATCHES=$((SC1_MATCHES + 1))
    fi
done
if [ "$SC1_MATCHES" -eq "$FILE_COUNT" ]; then
    echo "PASS: SC-1 — All $FILE_COUNT files have role-anchoring header"
else
    echo "FAIL: SC-1 — Expected $FILE_COUNT files with header, found $SC1_MATCHES"
    FAILURES=1
fi
echo ""

# --- SC-2: Zero task() code blocks ---
echo "--- SC-2: Zero task() code blocks (cross-validate dispatch patterns) ---"
SC2_BLOCKS=0
for f in "${AUDITOR_FILES[@]}"; do
    FILE="$TASKS_DIR/$f"
    # Count task(` calls inside python code fences
    IN_FENCE=0
    while IFS= read -r line; do
        if [[ "$line" == '```python' ]]; then
            IN_FENCE=1
        elif [[ "$line" == '```'* ]] && [ "$IN_FENCE" -eq 1 ]; then
            IN_FENCE=0
        elif [ "$IN_FENCE" -eq 1 ] && [[ "$line" =~ task\( ]]; then
            SC2_BLOCKS=$((SC2_BLOCKS + 1))
        fi
    done < "$FILE"
done
if [ "$SC2_BLOCKS" -eq 0 ]; then
    echo "PASS: SC-2 — Zero task() code blocks in auditor files"
else
    echo "FAIL: SC-2 — Found $SC2_BLOCKS task() code block(s) in auditor files"
    FAILURES=1
fi
echo ""

# --- SC-3: Dispatch Mandate sections removed from all files ---
echo "--- SC-3: Dispatch Mandate sections removed from all $FILE_COUNT files ---"
SC3_MATCHES=0
for f in "${AUDITOR_FILES[@]}"; do
    FILE="$TASKS_DIR/$f"
    HAS_DM=$(grep -c "^## Dispatch Mandate" "$FILE" 2>/dev/null || true)
    SC3_MATCHES=$((SC3_MATCHES + HAS_DM))
done
if [ "$SC3_MATCHES" -eq 0 ]; then
    echo "PASS: SC-3 — Zero Dispatch Mandate sections in all $FILE_COUNT files"
else
    echo "FAIL: SC-3 — Found $SC3_MATCHES Dispatch Mandate section(s)"
    FAILURES=1
fi
echo ""

# --- SC-4: Zero "Invoke.*cross-validate" imperative language ---
echo "--- SC-4: Zero \"Invoke.*cross-validate\" imperative language ---"
SC4_MATCHES=0
for f in "${AUDITOR_FILES[@]}"; do
    FILE="$TASKS_DIR/$f"
    COUNT=$(grep -ci "invoke.*cross-validate" "$FILE" 2>/dev/null || true)
    SC4_MATCHES=$((SC4_MATCHES + COUNT))
done
if [ "$SC4_MATCHES" -eq 0 ]; then
    echo "PASS: SC-4 — Zero \"Invoke.*cross-validate\" patterns found"
else
    echo "FAIL: SC-4 — Found $SC4_MATCHES \"Invoke.*cross-validate\" imperative pattern(s)"
    FAILURES=1
fi

echo ""
if [ "$FAILURES" -eq 0 ]; then
    echo "=== RESULT: PASS ==="
    exit 0
else
    echo "=== RESULT: FAIL ==="
    exit 1
fi
