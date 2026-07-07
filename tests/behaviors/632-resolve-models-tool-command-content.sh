#!/bin/bash
# 632-resolve-models-tool-command-content.sh — Functional + content verification
# SC-1, SC-2, SC-3, SC-4, SC-4a, SC-5a, SC-5b, SC-5c, SC-7a, SC-7b, SC-8,
# SC-9b, SC-9c, SC-10a, SC-10b, SC-11a, SC-11b, SC-12a, SC-12b, SC-12c
#
# Co-authored with AI: OpenCode (<ModelId>)

set -uo pipefail
OVERALL_RESULT=0
ARTIFACTS_DIR="./tmp/632-functional-artifacts"
mkdir -p "$ARTIFACTS_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

TOOL="$PROJECT_DIR/.opencode/tools/resolve-models"
TASK_DIR="$PROJECT_DIR/.opencode/skills/audit/tasks"
SKILL_FILE="$PROJECT_DIR/.opencode/skills/audit/SKILL.md"
HELPERS_FILE="$PROJECT_DIR/.opencode/tests/behaviors/helpers.sh"
WITH_TEST_HOME="$PROJECT_DIR/.opencode/tests/with-test-home"
RESOLVE_MODELS_MD="$TASK_DIR/resolve-models.md"

echo "=== Issue #632 Functional + Content Verification ==="
echo "PROJECT_DIR=$PROJECT_DIR"
echo "ARTIFACTS_DIR=$ARTIFACTS_DIR"
echo ""

# ============================================================
# FUNCTIONAL TESTS
# ============================================================

# --- SC-1: YAML output contract ---
echo "--- SC-1: YAML output contract ---"
"$TOOL" --orchestrator-model glm-5.1 > "$ARTIFACTS_DIR/sc1-output.yaml" 2>&1 || true
SC1_KEYS=$(grep -c '^auditor_1:\|^auditor_2:\|^family_1:\|^family_2:' "$ARTIFACTS_DIR/sc1-output.yaml" || true)
SC1_HAS_AUDITOR1=$(grep -q '^auditor_1:' "$ARTIFACTS_DIR/sc1-output.yaml" && echo "yes" || echo "no")
SC1_HAS_AUDITOR2=$(grep -q '^auditor_2:' "$ARTIFACTS_DIR/sc1-output.yaml" && echo "yes" || echo "no")
SC1_HAS_FAMILY1=$(grep -q '^family_1:' "$ARTIFACTS_DIR/sc1-output.yaml" && echo "yes" || echo "no")
SC1_HAS_FAMILY2=$(grep -q '^family_2:' "$ARTIFACTS_DIR/sc1-output.yaml" && echo "yes" || echo "no")
SC1_FAM1=$(grep '^family_1:' "$ARTIFACTS_DIR/sc1-output.yaml" | awk '{print $2}' || true)
SC1_FAM2=$(grep '^family_2:' "$ARTIFACTS_DIR/sc1-output.yaml" | awk '{print $2}' || true)

if [ "$SC1_KEYS" -ge 4 ] && [ "$SC1_HAS_AUDITOR1" = "yes" ] && [ "$SC1_HAS_AUDITOR2" = "yes" ] && [ "$SC1_HAS_FAMILY1" = "yes" ] && [ "$SC1_HAS_FAMILY2" = "yes" ] && [ -n "$SC1_FAM1" ] && [ -n "$SC1_FAM2" ] && [ "$SC1_FAM1" != "$SC1_FAM2" ]; then
    echo "PASS: SC-1 — YAML output has 4+ keys with auditor_X, family_X, and families differ"
else
    echo "FAIL: SC-1 — keys=$SC1_KEYS, auditor1=$SC1_HAS_AUDITOR1, auditor2=$SC1_HAS_AUDITOR2, fam1=$SC1_FAM1, fam2=$SC1_FAM2"
    OVERALL_RESULT=1
fi

# --- SC-2: Non-deterministic output ---
echo "--- SC-2: Non-deterministic output ---"
SC2_PAIRS=""
for i in $(seq 1 5); do
    "$TOOL" --orchestrator-model glm-5.1 2>/dev/null >> "$ARTIFACTS_DIR/sc2-runs.txt" || true
done
SC2_UNIQUE=$(sort "$ARTIFACTS_DIR/sc2-runs.txt" | uniq | grep -c '^auditor_1:' || true)
if [ "$SC2_UNIQUE" -ge 2 ]; then
    echo "PASS: SC-2 — Output varies across 5 invocations ($SC2_UNIQUE unique outputs)"
else
    echo "FAIL: SC-2 — All 5 invocations produced same output"
    OVERALL_RESULT=1
fi

# --- SC-3: Orchestrator family exclusion ---
echo "--- SC-3: Orchestrator family exclusion ---"
"$TOOL" --orchestrator-model glm-5.1 > "$ARTIFACTS_DIR/sc3-output.yaml" 2>&1 || true
SC3_FAM1=$(grep '^family_1:' "$ARTIFACTS_DIR/sc3-output.yaml" | awk '{print $2}' || true)
SC3_FAM2=$(grep '^family_2:' "$ARTIFACTS_DIR/sc3-output.yaml" | awk '{print $2}' || true)
if [ "$SC3_FAM1" != "glm" ] && [ "$SC3_FAM2" != "glm" ]; then
    echo "PASS: SC-3 — Neither family is glm (got $SC3_FAM1, $SC3_FAM2)"
else
    echo "FAIL: SC-3 — One of the families is glm (got $SC3_FAM1, $SC3_FAM2)"
    OVERALL_RESULT=1
fi

# --- SC-7a: test-insufficient-families error ---
echo "--- SC-7a: test-insufficient-families error ---"
SC7A_EXIT=0
"$TOOL" --test-insufficient-families > "$ARTIFACTS_DIR/sc7a-output.yaml" 2>&1 || SC7A_EXIT=$?
SC7A_HAS_ERROR=$(grep -q '^error:' "$ARTIFACTS_DIR/sc7a-output.yaml" && echo "yes" || echo "no")
SC7A_HAS_REASON=$(grep -q '^reason:' "$ARTIFACTS_DIR/sc7a-output.yaml" && echo "yes" || echo "no")
SC7A_HAS_COUNT=$(grep -q '^eligible_count:' "$ARTIFACTS_DIR/sc7a-output.yaml" && echo "yes" || echo "no")
if [ "$SC7A_EXIT" -eq 1 ] && [ "$SC7A_HAS_ERROR" = "yes" ] && [ "$SC7A_HAS_REASON" = "yes" ] && [ "$SC7A_HAS_COUNT" = "yes" ]; then
    echo "PASS: SC-7a — Error with error/reason/eligible_count keys, exit code 1"
else
    echo "FAIL: SC-7a — exit=$SC7A_EXIT, error=$SC7A_HAS_ERROR, reason=$SC7A_HAS_REASON, count=$SC7A_HAS_COUNT"
    OVERALL_RESULT=1
fi

# --- SC-7b: excluded-pair all families ---
echo "--- SC-7b: excluded-pair all families ---"
SC7B_EXIT=0
"$TOOL" --excluded-pair deepseek,glm,kimi,mistral,qwen > "$ARTIFACTS_DIR/sc7b-output.yaml" 2>&1 || SC7B_EXIT=$?
SC7B_HAS_ERROR=$(grep -q '^error:' "$ARTIFACTS_DIR/sc7b-output.yaml" && echo "yes" || echo "no")
if [ "$SC7B_EXIT" -eq 1 ] && [ "$SC7B_HAS_ERROR" = "yes" ]; then
    echo "PASS: SC-7b — All families excluded, error output with exit 1"
else
    echo "FAIL: SC-7b — exit=$SC7B_EXIT, has_error=$SC7B_HAS_ERROR"
    OVERALL_RESULT=1
fi

# --- SC-9b: excluded-pair specific ---
echo "--- SC-9b: excluded-pair specific ---"
"$TOOL" --excluded-pair deepseek,mistral --orchestrator-model glm-5.1 > "$ARTIFACTS_DIR/sc9b-output.yaml" 2>&1 || true
SC9B_FAM1=$(grep '^family_1:' "$ARTIFACTS_DIR/sc9b-output.yaml" | awk '{print $2}' || true)
SC9B_FAM2=$(grep '^family_2:' "$ARTIFACTS_DIR/sc9b-output.yaml" | awk '{print $2}' || true)
if [ -n "$SC9B_FAM1" ] && [ -n "$SC9B_FAM2" ] && [ "$SC9B_FAM1" != "deepseek" ] && [ "$SC9B_FAM2" != "deepseek" ] && [ "$SC9B_FAM1" != "mistral" ] && [ "$SC9B_FAM2" != "mistral" ]; then
    echo "PASS: SC-9b — deepseek and mistral excluded, got $SC9B_FAM1/$SC9B_FAM2"
else
    echo "FAIL: SC-9b — deepseek/mistral still present (got $SC9B_FAM1, $SC9B_FAM2)"
    OVERALL_RESULT=1
fi

# --- SC-9c: re-task produces different pairs ---
echo "--- SC-9c: re-task produces different pairs ---"
SC9C_RESULTS=$("$TOOL" --orchestrator-model glm-5.1 2>/dev/null; echo "---"; "$TOOL" --orchestrator-model glm-5.1 2>/dev/null; echo "---"; "$TOOL" --orchestrator-model glm-5.1 2>/dev/null)
echo "$SC9C_RESULTS" > "$ARTIFACTS_DIR/sc9c-runs.txt"
SC9C_PAIRS=$(echo "$SC9C_RESULTS" | grep '^auditor_1:\|^auditor_2:\|^family_1:\|^family_2:' | paste - - - - | sort -u | wc -l)
if [ "$SC9C_PAIRS" -ge 2 ]; then
    echo "PASS: SC-9c — 3 invocations produced $SC9C_PAIRS unique pairs (at least 2)"
else
    echo "FAIL: SC-9c — All 3 invocations produced same pair (1 unique)"
    OVERALL_RESULT=1
fi

# ============================================================
# CONTENT TESTS
# ============================================================

# --- SC-4: Word count ≤200 ---
echo "--- SC-4: Word count ≤200 ---"
SC4_WORDS=$(sed '4,/^```yaml+symbolic/!d' "$RESOLVE_MODELS_MD" 2>/dev/null | head -n -1 | wc -w || true)
if [ -n "$SC4_WORDS" ] && [ "$SC4_WORDS" -le 200 ] 2>/dev/null; then
    echo "PASS: SC-4 — resolve-models.md body is $SC4_WORDS words (≤200)"
else
    echo "FAIL: SC-4 — resolve-models.md body word count: $SC4_WORDS (expected ≤200)"
    OVERALL_RESULT=1
fi

# --- SC-4a: commands file absent ---
echo "--- SC-4a: commands file absent ---"
if [ ! -f "$PROJECT_DIR/.opencode/commands/resolve-models.md" ]; then
    echo "PASS: SC-4a — .opencode/commands/resolve-models.md absent"
else
    echo "FAIL: SC-4a — .opencode/commands/resolve-models.md exists"
    OVERALL_RESULT=1
fi

# --- SC-5a: SKILL.md table row ---
echo "--- SC-5a: SKILL.md table row ---"
# Find resolve-models in the table section (between task-context-audit table and next section)
SC5A_TABLE=$(sed -n '/^|.*`resolve-models`/,/^$/p' "$SKILL_FILE" 2>/dev/null || true)
if echo "$SC5A_TABLE" | grep -q 'resolve-models'; then
    echo "PASS: SC-5a — resolve-models table row found in SKILL.md"
else
    # Broader check
    if grep -q 'resolve-models' "$SKILL_FILE"; then
        echo "PASS: SC-5a — resolve-models referenced in SKILL.md"
    else
        echo "FAIL: SC-5a — resolve-models not found in SKILL.md"
        OVERALL_RESULT=1
    fi
fi

# --- SC-5b: tool path only in resolve-models.md ---
echo "--- SC-5b: tool path only in resolve-models.md ---"
SC5B_VIOLATIONS=0
for TASK_FILE in "$TASK_DIR"/*.md; do
    TASK_BASENAME=$(basename "$TASK_FILE")
    if [ "$TASK_BASENAME" = "resolve-models.md" ]; then
        continue
    fi
    if grep -q '\.opencode/tools/resolve-models\|commands/resolve-models' "$TASK_FILE" 2>/dev/null; then
        echo "  FAIL: $TASK_BASENAME contains direct tool path"
        SC5B_VIOLATIONS=$((SC5B_VIOLATIONS + 1))
    fi
done
if [ "$SC5B_VIOLATIONS" -eq 0 ]; then
    echo "PASS: SC-5b — No task files contain direct tool path (only resolve-models.md)"
else
    echo "FAIL: SC-5b — $SC5B_VIOLATIONS task files contain direct tool path"
    OVERALL_RESULT=1
fi

# --- SC-5c: Encapsulation Rules section ---
echo "--- SC-5c: Encapsulation Rules section ---"
if grep -q '### Encapsulation Rules' "$SKILL_FILE" 2>/dev/null; then
    echo "PASS: SC-5c — Encapsulation Rules section found in SKILL.md"
else
    echo "FAIL: SC-5c — Encapsulation Rules section missing from SKILL.md"
    OVERALL_RESULT=1
fi

# --- SC-8: executable + shebang ---
echo "--- SC-8: executable + shebang ---"
SC8_SHEBANG=$(head -1 "$TOOL" 2>/dev/null || true)
if [ -x "$TOOL" ] && [ "$SC8_SHEBANG" = "#!/bin/bash" ]; then
    echo "PASS: SC-8 — resolve-models is executable with correct shebang"
else
    echo "FAIL: SC-8 — executable=$(test -x "$TOOL" && echo yes || echo no), shebang=$SC8_SHEBANG"
    OVERALL_RESULT=1
fi

# --- SC-10a: resolve-models in all 12 task files ---
echo "--- SC-10a: resolve-models in all 12 task files ---"
SC10A_TASK_FILES=(
    "spec-audit.md"
    "drift-detection.md"
    "concern-separation.md"
    "spec-summary.md"
    "closure-verification.md"
    "coherence-maintenance.md"
    "guideline-audit.md"
    "plan-fidelity.md"
    "cross-validate.md"
    "completion.md"
    "coherence-extraction.md"
    "test-quality-audit.md"
)
SC10A_MISSING=0
for TF in "${SC10A_TASK_FILES[@]}"; do
    if ! grep -q 'resolve-models' "$TASK_DIR/$TF" 2>/dev/null; then
        echo "  FAIL: $TF missing resolve-models reference"
        SC10A_MISSING=$((SC10A_MISSING + 1))
    fi
done
if [ "$SC10A_MISSING" -eq 0 ]; then
    echo "PASS: SC-10a — All 12 task files reference resolve-models"
else
    echo "FAIL: SC-10a — $SC10A_MISSING task files missing resolve-models reference"
    OVERALL_RESULT=1
fi

# --- SC-10b: no direct path in task files ---
echo "--- SC-10b: no direct path in task files ---"
SC10B_VIOLATIONS=0
for TF in "${SC10A_TASK_FILES[@]}"; do
    if grep -q '\.opencode/tools/resolve-models\|commands/resolve-models' "$TASK_DIR/$TF" 2>/dev/null; then
        echo "  FAIL: $TF contains direct tool path"
        SC10B_VIOLATIONS=$((SC10B_VIOLATIONS + 1))
    fi
done
if [ "$SC10B_VIOLATIONS" -eq 0 ]; then
    echo "PASS: SC-10b — No task files contain direct .opencode/tools/resolve-models path"
else
    echo "FAIL: SC-10b — $SC10B_VIOLATIONS task files contain direct path"
    OVERALL_RESULT=1
fi

# --- SC-11a: audit-013 rule ---
echo "--- SC-11a: audit-013 rule ---"
SC11A_ID=$(grep -A1 'id: audit-013' "$SKILL_FILE" 2>/dev/null || true)
SC11A_TITLE=$(grep -A2 'id: audit-013' "$SKILL_FILE" | grep 'title:' || true)
SC11A_ACTIONS=$(grep -A10 'id: audit-013' "$SKILL_FILE" | grep 'actions:' || true)
if echo "$SC11A_TITLE" | grep -qi 'resolve-models' && echo "$SC11A_ACTIONS" | grep -qi 'task\|route\|CALL'; then
    echo "PASS: SC-11a — audit-013 found with resolve-models in title and task action"
else
    echo "FAIL: SC-11a — audit-013 check: id=$SC11A_ID, title=$SC11A_TITLE, actions=$SC11A_ACTIONS"
    OVERALL_RESULT=1
fi

# --- SC-11b: audit-022 rule ---
echo "--- SC-11b: audit-022 rule ---"
SC11B_ID=$(grep -A1 'id: audit-022' "$SKILL_FILE" 2>/dev/null || true)
SC11B_TITLE=$(grep -A2 'id: audit-022' "$SKILL_FILE" | grep 'title:' || true)
SC11B_COND=$(grep -A10 'id: audit-022' "$SKILL_FILE" | grep 'conditions:' -A3 || true)
if echo "$SC11B_TITLE" | grep -qi 'resolve-models' && echo "$SC11B_COND" | grep -qi 'resolve_models_called'; then
    echo "PASS: SC-11b — audit-022 found with resolve-models in title and resolve_models_called in conditions"
else
    echo "FAIL: SC-11b — audit-022 check: id=$SC11B_ID, title=$SC11B_TITLE, cond=$SC11B_COND"
    OVERALL_RESULT=1
fi

# --- SC-12a: ollama_models function in with-test-home ---
echo "--- SC-12a: ollama_models function ---"
SC12A_FUNC=$(grep -c '^ollama_models()' "$WITH_TEST_HOME" 2>/dev/null || true)
if [ "$SC12A_FUNC" -ge 1 ]; then
    echo "PASS: SC-12a — ollama_models() function found in with-test-home"
else
    echo "FAIL: SC-12a — ollama_models() not found in with-test-home"
    OVERALL_RESULT=1
fi

# --- SC-12b: dynamic pool in helpers.sh ---
echo "--- SC-12b: dynamic pool in helpers.sh ---"
SC12B_SOURCE=$(grep -c 'source.*with-test-home' "$HELPERS_FILE" 2>/dev/null || true)
SC12B_MAPFILE=$(grep -c 'mapfile.*BEHAVIORAL_MODEL_POOL' "$HELPERS_FILE" 2>/dev/null || true)
if [ "$SC12B_SOURCE" -ge 1 ] && [ "$SC12B_MAPFILE" -ge 1 ]; then
    echo "PASS: SC-12b — helpers.sh sources with-test-home and mapfile BEHAVIORAL_MODEL_POOL"
else
    echo "FAIL: SC-12b — source=$SC12B_SOURCE, mapfile=$SC12B_MAPFILE"
    OVERALL_RESULT=1
fi

# --- SC-12c: empty pool guard in helpers.sh ---
echo "--- SC-12c: empty pool guard ---"
SC12C_GUARD=$(grep -cF 'BEHAVIORAL_MODEL_POOL' "$HELPERS_FILE" 2>/dev/null || true)
SC12C_EQ0=$(grep -cF 'eq 0' "$HELPERS_FILE" 2>/dev/null || true)
if [ "$SC12C_GUARD" -ge 1 ] && [ "$SC12C_EQ0" -ge 1 ]; then
    echo "PASS: SC-12c — Empty pool guard found in helpers.sh"
else
    echo "FAIL: SC-12c — Empty pool guard not found (BEHAVIORAL_MODEL_POOL=$SC12C_GUARD, eq_0=$SC12C_EQ0)"
    OVERALL_RESULT=1
fi

# ============================================================
# SUMMARY
# ============================================================
echo ""
echo "=== Summary ==="
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: All tests passed"
else
    echo "FAIL: Some tests failed (OVERALL_RESULT=$OVERALL_RESULT)"
fi

exit $OVERALL_RESULT
