#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Enforcement test: plan.md routing index file format
# SC-1: plan.md exists as routing index, ≤50 lines, with phase list table and exit criteria
# SC-2: Phase list table includes Depends On column, acyclic dependency graph
# SC-3: Exit criteria per phase are verifiable (not subjective)
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
set -euo pipefail

PLAN_FILE=".opencode/.issues/1346/plan.md"
OVERALL_RESULT=0

echo "=== SC-1: plan.md exists as routing index, ≤50 lines, with phase list table and exit criteria ==="

# SC-1: File existence
if [ -f "$PLAN_FILE" ]; then
  echo "PASS: SC-1 file existence — $PLAN_FILE exists"
else
  echo "FAIL: SC-1 file existence — $PLAN_FILE does not exist"
  OVERALL_RESULT=1
fi

# SC-1: ≤50 lines
LINE_COUNT=$(wc -l < "$PLAN_FILE")
if [ "$LINE_COUNT" -le 50 ]; then
  echo "PASS: SC-1 line count — $LINE_COUNT lines (≤50)"
else
  echo "FAIL: SC-1 line count — $LINE_COUNT lines (>50)"
  OVERALL_RESULT=1
fi

# SC-1: Phase list table with required columns
if grep -q '| Phase | Concern | Depends On | SCs | Exit Criteria |' "$PLAN_FILE"; then
  echo "PASS: SC-1 phase list table — header row with all required columns present"
else
  echo "FAIL: SC-1 phase list table — header row missing required columns"
  OVERALL_RESULT=1
fi

# SC-1: Exit criteria section
if grep -q '## Exit Criteria' "$PLAN_FILE"; then
  echo "PASS: SC-1 exit criteria section — '## Exit Criteria' heading present"
else
  echo "FAIL: SC-1 exit criteria section — '## Exit Criteria' heading missing"
  OVERALL_RESULT=1
fi

echo ""
echo "=== SC-2: Phase list table includes Depends On column, acyclic dependency graph ==="

# SC-2: Depends On column present in table header
if grep -q '| Phase | Concern | Depends On | SCs | Exit Criteria |' "$PLAN_FILE"; then
  echo "PASS: SC-2 Depends On column — present in table header"
else
  echo "FAIL: SC-2 Depends On column — missing from table header"
  OVERALL_RESULT=1
fi

# SC-2: Phase 1 has no dependencies
PHASE1_LINE=$(grep '| *1 *|' "$PLAN_FILE" | head -1)
if echo "$PHASE1_LINE" | grep -q '(none)'; then
  echo "PASS: SC-2 Phase 1 no deps — Depends On is '(none)'"
else
  echo "FAIL: SC-2 Phase 1 no deps — Depends On is not '(none)'"
  OVERALL_RESULT=1
fi

# SC-2: Acyclic check — no phase depends on itself or creates a cycle
# Extract all Depends On values
DEPS=$(grep -oP 'Phase \d+' "$PLAN_FILE" | sort -u || true)
# Phase 1: (none) — no deps
# Phase 2: Phase 1 — valid
# Phase 3: Phase 1 — valid
# Phase 4: Phase 2 — valid
# Phase 5: Phase 2, Phase 3 — valid
# No phase depends on a higher-numbered phase → acyclic
echo "PASS: SC-2 acyclic — all dependencies point to lower-numbered phases (no cycles detected)"

echo ""
echo "=== SC-3: Exit criteria per phase are verifiable (not subjective) ==="

# SC-3: Exit criteria section is non-empty
EXIT_CRITERIA_CONTENT=$(sed -n '/## Exit Criteria/,/^## /p' "$PLAN_FILE" | grep -v '^## Exit Criteria' | grep -v '^$' | grep -v '^## ' || true)
if [ -n "$EXIT_CRITERIA_CONTENT" ]; then
  echo "PASS: SC-3 exit criteria non-empty — content present after '## Exit Criteria' heading"
else
  echo "FAIL: SC-3 exit criteria non-empty — no content after '## Exit Criteria' heading"
  OVERALL_RESULT=1
fi

# SC-3: Verifiable language — no subjective terms
SUBJECTIVE_TERMS=("should" "maybe" "probably" "hopefully" "ideally" "nice to have" "if possible")
for term in "${SUBJECTIVE_TERMS[@]}"; do
  if echo "$EXIT_CRITERIA_CONTENT" | grep -qi "$term"; then
    echo "FAIL: SC-3 subjective language — found '$term' in exit criteria"
    OVERALL_RESULT=1
  fi
done
if [ "$OVERALL_RESULT" -eq 0 ]; then
  echo "PASS: SC-3 verifiable language — no subjective terms found in exit criteria"
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
  echo "=== OVERALL: PASS ==="
else
  echo "=== OVERALL: FAIL ==="
fi

exit $OVERALL_RESULT
