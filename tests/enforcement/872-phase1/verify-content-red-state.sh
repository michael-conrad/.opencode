#!/bin/bash
# Content-Verification Test: #872 Phase 1 RED State Verification
#
# Verifies the current dev baseline state matches expected RED state
# for the constraint tooling project (Phase 1: engine migration + rules dispatcher + solve tool).
#
# RED phase — all checks for NEW artifacts SHOULD FAIL (don't exist yet).
# GREEN phase — same checks should PASS.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

OVERALL_RESULT=0

echo "=== #872 Phase 1 RED State Content-Verification ==="
echo ""

# ============================================================
# SC-1: `rules` dispatcher at .opencode/tools/rules
# ============================================================
echo "--- SC-1: rules dispatcher ---"
if [ -f "$PROJECT_DIR/.opencode/tools/rules" ]; then
    echo "PASS: SC-1 — .opencode/tools/rules exists"
else
    echo "FAIL: SC-1 — .opencode/tools/rules does NOT exist (expected — RED state)"
    OVERALL_RESULT=1
fi

# ============================================================
# SC-4: `solve` tool at .opencode/tools/solve
# ============================================================
echo "--- SC-4: solve tool ---"
if [ -f "$PROJECT_DIR/.opencode/tools/solve" ]; then
    echo "PASS: SC-4 — .opencode/tools/solve exists"
else
    echo "FAIL: SC-4 — .opencode/tools/solve does NOT exist (expected — RED state)"
    OVERALL_RESULT=1
fi

# ============================================================
# SC-7: Direct invocation guard on impl scripts
# Check that sym-* impl scripts have OPENCODE_TOOLS_DISPATCHER guard
# (not the symbolic dispatcher itself, which already has the guard from PEP 723)
# ============================================================
echo "--- SC-7: sym-* impl scripts have OPENCODE_TOOLS_DISPATCHER guard ---"
SYM_GUARD_OK=0
SYM_GUARD_MISSING=0
for script in "$PROJECT_DIR/.opencode/tools/impl/sym-"*; do
    if [ -f "$script" ]; then
        if grep -q "OPENCODE_TOOLS_DISPATCHER" "$script" 2>/dev/null; then
            SYM_GUARD_OK=$((SYM_GUARD_OK + 1))
        else
            echo "  MISSING: $(basename "$script") has no OPENCODE_TOOLS_DISPATCHER guard"
            SYM_GUARD_MISSING=$((SYM_GUARD_MISSING + 1))
        fi
    fi
done
if [ "$SYM_GUARD_MISSING" -gt 0 ]; then
    echo "PASS: SC-7 — $SYM_GUARD_MISSING sym-* scripts lack OPENCODE_TOOLS_DISPATCHER guard (correct RED state)"
elif [ "$SYM_GUARD_OK" -gt 0 ]; then
    echo "NOTE: SC-7 — $SYM_GUARD_OK sym-* scripts already have the guard (may already be satisfied)"
fi

# ============================================================
# SC-8: Global constraints auto-load (global-constraints.yaml)
# Located at .issues/artifacts/global-constraints.yaml per spec artifact layout
# ============================================================
echo "--- SC-8: .issues/artifacts/global-constraints.yaml ---"
GC_FILE="$PROJECT_DIR/.opencode/.issues/artifacts/global-constraints.yaml"
if [ -f "$GC_FILE" ]; then
    echo "PASS: SC-8 — global-constraints.yaml exists"
else
    echo "FAIL: SC-8 — global-constraints.yaml does NOT exist (spec claims already created)"
    OVERALL_RESULT=1
fi

# ============================================================
# SC-11: Multi-constraint YAML parsing (solve tool doesn't exist)
# ============================================================
echo "--- SC-11: solve tool capability (proxy: solve tool existence) ---"
if [ -f "$PROJECT_DIR/.opencode/tools/solve" ]; then
    echo "PASS: SC-11 — solve tool exists (capable of multi-constraint YAML parsing)"
else
    echo "FAIL: SC-11 — solve tool does NOT exist (no multi-constraint YAML parsing available — RED state)"
    OVERALL_RESULT=1
fi

# ============================================================
# SC-12: sym-* scripts still reference sympy (regression guard)
# ============================================================
echo "--- SC-12: sym-* sympy references (regression guard) ---"
SYMPY_FOUND=0
for script in "$PROJECT_DIR/.opencode/tools/impl/sym-"*; do
    if [ -f "$script" ]; then
        if grep -q "sympy" "$script" 2>/dev/null; then
            echo "  FOUND sympy reference in $(basename "$script")"
            SYMPY_FOUND=1
        fi
    fi
done
if [ "$SYMPY_FOUND" -eq 1 ]; then
    echo "PASS: SC-12 — sym-* scripts still reference sympy (correct RED state — no migration done)"
else
    echo "FAIL: SC-12 — no sympy references found in sym-* scripts (unexpected — should still be sympy in RED)"
    OVERALL_RESULT=1
fi

# ============================================================
# SC-13: Guideline 092 does NOT exist
# ============================================================
echo "--- SC-13: guideline 092 ---"
GL92_FILE="$PROJECT_DIR/.opencode/guidelines/092-spec-reasoning-tools.md"
if [ -f "$GL92_FILE" ]; then
    echo "FAIL: SC-13 — 092-spec-reasoning-tools.md ALREADY exists (expected RED — doesn't exist yet)"
    OVERALL_RESULT=1
else
    echo "PASS: SC-13 — 092-spec-reasoning-tools.md does NOT exist (correct RED state)"
fi

# ============================================================
# INDEX.md has no 092- entry
# ============================================================
echo "--- INDEX.md 092 entry ---"
INDEX_FILE="$PROJECT_DIR/.opencode/guidelines/INDEX.md"
if [ -f "$INDEX_FILE" ]; then
    if grep -q "092-" "$INDEX_FILE" 2>/dev/null; then
        echo "FAIL: INDEX.md already has 092- entry (expected RED — no entry yet)"
        OVERALL_RESULT=1
    else
        echo "PASS: INDEX.md has NO 092- entry (correct RED state)"
    fi
else
    echo "FAIL: INDEX.md not found"
    OVERALL_RESULT=1
fi

# ============================================================
# skildeck ANALYSIS dict references sym-* script names
# ============================================================
echo "--- skildeck ANALYSIS dict sym-* references ---"
SKILDECK_FILE="$PROJECT_DIR/.opencode/tools/skildeck"
SYM_REFS=0
if [ -f "$SKILDECK_FILE" ]; then
    while IFS= read -r line; do
        if echo "$line" | grep -q '"sym-'; then
            SYM_REFS=$((SYM_REFS + 1))
            echo "  FOUND sym- reference: $(echo "$line" | xargs)"
        fi
    done < <(grep '"sym-' "$SKILDECK_FILE" 2>/dev/null || true)
    if [ "$SYM_REFS" -ge 6 ]; then
        echo "PASS: skildeck ANALYSIS dict references $SYM_REFS sym-* scripts (correct RED state)"
    else
        echo "FAIL: skildeck ANALYSIS dict has $SYM_REFS sym-* references, expected 6 (ANALYSIS dict has 6 entries)"
        OVERALL_RESULT=1
    fi
else
    echo "FAIL: skildeck tool not found"
    OVERALL_RESULT=1
fi

# ============================================================
# symbolic dispatcher still exists
# ============================================================
echo "--- symbolic dispatcher existence ---"
if [ -f "$PROJECT_DIR/.opencode/tools/symbolic" ]; then
    echo "PASS: symbolic dispatcher still exists (correct RED state)"
else
    echo "FAIL: symbolic dispatcher does NOT exist (expected RED — should still exist)"
    OVERALL_RESULT=1
fi

# ============================================================
# sym-* impl scripts still exist
# ============================================================
echo "--- sym-* impl scripts existence ---"
SYM_COUNT=0
for script in "$PROJECT_DIR/.opencode/tools/impl/sym-"*; do
    if [ -f "$script" ]; then
        SYM_COUNT=$((SYM_COUNT + 1))
    fi
done
if [ "$SYM_COUNT" -ge 10 ]; then
    echo "PASS: $SYM_COUNT sym-* impl scripts exist (correct RED state)"
else
    echo "FAIL: Only $SYM_COUNT sym-* impl scripts found, expected 15 (unexpected RED state)"
    OVERALL_RESULT=1
fi

# ============================================================
# README.md references `symbolic`
# ============================================================
echo "--- README.md symbolic reference ---"
README_FILE="$PROJECT_DIR/.opencode/README.md"
if [ -f "$README_FILE" ]; then
    if grep -q "symbolic" "$README_FILE" 2>/dev/null; then
        echo "PASS: README.md references 'symbolic' (correct RED state)"
    else
        echo "FAIL: README.md does NOT reference 'symbolic' (unexpected — should still reference it in RED)"
        OVERALL_RESULT=1
    fi
else
    echo "FAIL: README.md not found"
    OVERALL_RESULT=1
fi

# ============================================================
# Summary
# ============================================================
echo ""
echo "=== RESULTS ==="
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "ALL PASS: Current baseline matches complete RED state"
    echo "NOTE: This is unexpected for RED phase — all new artifacts would already exist."
else
    echo "RED FAILURES DETECTED: Some GREEN artifacts are missing (expected — RED phase)"
    echo "These checks will PASS after GREEN implementation."
fi

exit $OVERALL_RESULT
