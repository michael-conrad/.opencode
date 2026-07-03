#!/bin/bash
# Behavioral test: 1178-phase1-red
# Phase 1 — RED test for evidence gate removal.
#
# Verifies the baseline state: buildEvidenceGateBlock function and Evidence Gate
# injection both exist. MUST FAIL in RED phase because the gate still exists
# (GREEN phase will remove it).
#
# SC-1: grep -c "buildEvidenceGateBlock" returns > 0 (function exists)
# SC-2: grep -c "Evidence Gate\|state.*closed" returns > 0 (injection exists)
# SC-3: PATH=.node/bin:$PATH npx tsc --noEmit returns 0 (codebase compiles)
#
# Co-authored with AI: deepseek-v4-flash (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

SCENARIO_NAME="1178-phase1-red"
OVERALL_RESULT=0

echo "=== RED Phase Test: Evidence Gate Removal (SC-1, SC-2, SC-3) ==="

# ============================================================
# SC-1: buildEvidenceGateBlock function exists
# ============================================================
echo ""
echo "--- SC-1: buildEvidenceGateBlock function exists ---"

SC1_COUNT=$(grep -c "buildEvidenceGateBlock" "$PROJECT_DIR/.opencode/plugins/session-enforcement.ts" 2>/dev/null || true)

if [ "$SC1_COUNT" -gt 0 ]; then
    echo "  FOUND: buildEvidenceGateBlock appears $SC1_COUNT time(s) — gate function exists"
    echo "  RESULT: FAIL (expected RED — gate function still present)"
    SC1_RESULT=1
    OVERALL_RESULT=1
else
    echo "  NOT FOUND: buildEvidenceGateBlock has zero matches"
    echo "  RESULT: PASS (gate function already removed — unexpected for RED)"
    SC1_RESULT=0
fi

# ============================================================
# SC-2: Evidence Gate injection exists
# ============================================================
echo ""
echo "--- SC-2: Evidence Gate injection exists ---"

SC2_COUNT=$(grep -c "Evidence Gate\|state.*closed" "$PROJECT_DIR/.opencode/plugins/session-enforcement.ts" 2>/dev/null || true)

if [ "$SC2_COUNT" -gt 0 ]; then
    echo "  FOUND: Evidence Gate patterns appear $SC2_COUNT time(s) — injection exists"
    echo "  RESULT: FAIL (expected RED — injection still present)"
    SC2_RESULT=1
    OVERALL_RESULT=1
else
    echo "  NOT FOUND: Evidence Gate patterns have zero matches"
    echo "  RESULT: PASS (injection already removed — unexpected for RED)"
    SC2_RESULT=0
fi

# ============================================================
# SC-3: TypeScript compilation check
# ============================================================
echo ""
echo "--- SC-3: TypeScript compilation check ---"

# Determine tsc path
TSC_PATH=""
NODE_PATH=""
if [ -f "$PROJECT_DIR/.node/bin/tsc" ]; then
    TSC_PATH="$PROJECT_DIR/.node/bin"
    NODE_PATH="$PROJECT_DIR/.node/bin"
elif [ -f "$PROJECT_DIR/.tools/node/bin/tsc" ]; then
    TSC_PATH="$PROJECT_DIR/.tools/node/bin"
    NODE_PATH="$PROJECT_DIR/.tools/node/bin"
elif [ -f "$PROJECT_DIR/.opencode/node_modules/.bin/tsc" ] && [ -f "$PROJECT_DIR/.opencode/.node/bin/node" ]; then
    TSC_PATH="$PROJECT_DIR/.opencode/node_modules/.bin"
    NODE_PATH="$PROJECT_DIR/.opencode/.node/bin"
fi

TSCONFIG="$PROJECT_DIR/.opencode/tsconfig.json"
if [ -n "$TSC_PATH" ] && [ -n "$NODE_PATH" ]; then
    echo "  Using tsc at: $TSC_PATH/tsc with node at: $NODE_PATH/node"
    if PATH="$NODE_PATH:$TSC_PATH:$PATH" tsc --project "$TSCONFIG" --noEmit 2>/dev/null; then
        echo "  RESULT: PASS — TypeScript compilation successful"
        SC3_RESULT=0
    else
        echo "  RESULT: FAIL — TypeScript compilation error (expected RED if code changes broke it)"
        SC3_RESULT=1
        OVERALL_RESULT=1
    fi
else
    echo "  WARNING: tsc not found — using npx fallback"
    if PATH="$PROJECT_DIR/.opencode/.node/bin:$PROJECT_DIR/.opencode/node_modules/.bin:$PATH" npx --yes tsc --project "$TSCONFIG" --noEmit 2>/dev/null; then
        echo "  RESULT: PASS — TypeScript compilation successful (via npx)"
        SC3_RESULT=0
    else
        echo "  RESULT: FAIL — TypeScript compilation error (via npx)"
        SC3_RESULT=1
        OVERALL_RESULT=1
    fi
fi

# ============================================================
# Report
# ============================================================
echo ""
echo "=== RED Phase Results ==="
echo "SC-1: $([ "$SC1_RESULT" -eq 0 ] && echo "PASS (gate function removed)" || echo "FAIL (gate function present — expected RED)")"
echo "SC-2: $([ "$SC2_RESULT" -eq 0 ] && echo "PASS (injection removed)" || echo "FAIL (injection present — expected RED)")"
echo "SC-3: $([ "$SC3_RESULT" -eq 0 ] && echo "PASS (compiles)" || echo "FAIL (compilation error)")"

# Write artifact output
mkdir -p "$PROJECT_DIR/tmp/1178/artifacts"
cat > "$PROJECT_DIR/tmp/1178/artifacts/phase1-test-output.log" << EOF
=== RED Phase Test: Evidence Gate Removal ===
SC-1 (buildEvidenceGateBlock exists):
  grep count: $SC1_COUNT
  result: $([ "$SC1_RESULT" -eq 0 ] && echo "PASS" || echo "FAIL")

SC-2 (Evidence Gate injection exists):
  grep count: $SC2_COUNT
  result: $([ "$SC2_RESULT" -eq 0 ] && echo "PASS" || echo "FAIL")

SC-3 (TypeScript compilation):
  tsc_path: ${TSC_PATH:-npx fallback}
  result: $([ "$SC3_RESULT" -eq 0 ] && echo "PASS" || echo "FAIL")

OVERALL: $([ "$OVERALL_RESULT" -eq 0 ] && echo "PASS" || echo "FAIL (expected RED — gate still present)")
EOF

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME (all SCs pass — unexpected for RED phase)"
else
    echo "FAIL: $SCENARIO_NAME (expected RED behavior — gate still present)"
fi

exit $OVERALL_RESULT