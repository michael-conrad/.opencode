#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Phase 17 — RED enforcement test: spec-creation task-card Procedure-format
# inventory.
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
#
# Asserts that the Procedure-format inventory artifact enumerating the
# spec-creation task cards whose Procedure sections use plain numbered lists
# (instead of the canonical numbered-checkbox lists) exists and is complete,
# including create.md's plain-numbered-list sub-steps (Step 3, Step 3.1,
# Step 3.2, Step 6, Step 7) per SC-25.
#
# SC-25: Every task card Procedure section in `spec-creation` and `audit`
# SHALL use numbered checkbox lists (`- [ ] N.`), including the Procedure
# sub-steps of `spec-creation/tasks/create.md` (Step 3, Step 3.1, Step 3.2,
# Step 6, Step 7 currently use plain numbered lists).
#
# This is a content-verification (string) test. It FAILs on the current code
# because the Procedure-format inventory artifact does not yet exist (Phase 17
# produces it).
#
# Usage: bash .opencode/tests-v2/test-2254-phase17-spec-creation-procedure-format-inventory.sh
# Exit:  0 if the Procedure-format inventory artifact is complete (GREEN),
#        1 if it is missing or incomplete (RED).
#
# Co-authored with AI: OpenCode (deepseek-ai/DeepSeek-V4-Flash-0731)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

ARTIFACT="$PROJECT_DIR/.opencode/.issues/2254/artifacts/spec-creation-procedure-format-inventory.yaml"

PASSED=0
FAILED=0

pass() { echo "  PASS: $1"; PASSED=$((PASSED + 1)); }
fail() { echo "  FAIL: $1"; FAILED=$((FAILED + 1)); }

echo ""
echo "=== Phase 17 — spec-creation task-card Procedure-format inventory (Spec .opencode#2254) ==="
echo ""
echo "Target task cards: spec-creation/tasks/*.md"
echo "Artifact:    $ARTIFACT"
echo ""
echo "Plain-numbered-list Procedure sub-steps to inventory (SC-25):"
echo "  create.md -> Step 3, Step 3.1, Step 3.2, Step 6, Step 7 (plain numbered lists)"
echo ""

# --- (a): Procedure-format inventory artifact exists ---
if [ -f "$ARTIFACT" ]; then
  pass "Phase 17: Procedure-format inventory artifact exists at $ARTIFACT"
else
  fail "Phase 17: Procedure-format inventory artifact exists at $ARTIFACT"
fi

# --- (b): artifact declares the inventory structure ---
if [ -f "$ARTIFACT" ]; then
  if grep -q "plain_numbered_list_count:" "$ARTIFACT"; then
    pass "Phase 17: artifact declares a plain_numbered_list_count"
  else
    fail "Phase 17: artifact declares a plain_numbered_list_count"
  fi

  if grep -q "plain_numbered_lists:" "$ARTIFACT"; then
    pass "Phase 17: artifact declares a plain_numbered_lists list"
  else
    fail "Phase 17: artifact declares a plain_numbered_lists list"
  fi

  # --- (c): artifact identifies create.md as the card with plain-numbered-list sub-steps ---
  if grep -q "spec-creation/tasks/create.md" "$ARTIFACT"; then
    pass "Phase 17: artifact enumerates spec-creation/tasks/create.md"
  else
    fail "Phase 17: artifact enumerates spec-creation/tasks/create.md"
  fi

  # --- (d): artifact identifies create.md's plain-numbered-list sub-steps per SC-25 ---
  for step in "Step 3" "Step 3.1" "Step 3.2" "Step 6" "Step 7"; do
    if grep -q "$step" "$ARTIFACT"; then
      pass "Phase 17: artifact identifies create.md $step as a plain-numbered-list sub-step"
    else
      fail "Phase 17: artifact identifies create.md $step as a plain-numbered-list sub-step"
    fi
  done

  # --- (e): artifact records the 5 plain-numbered-list sub-steps ---
  if grep -q "plain_numbered_list_count: 5" "$ARTIFACT"; then
    pass "Phase 17: artifact records plain_numbered_list_count 5"
  else
    fail "Phase 17: artifact records plain_numbered_list_count 5"
  fi
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASSED"
echo "FAILED: $FAILED"

if [ "$FAILED" -eq 0 ]; then
  echo ""
  echo "Phase 17 is GREEN — the Procedure-format inventory artifact enumerates"
  echo "the spec-creation task cards whose Procedure sections use plain"
  echo "numbered lists and identifies create.md's plain-numbered-list sub-steps"
  echo "(Step 3, Step 3.1, Step 3.2, Step 6, Step 7) per SC-25."
  exit 0
else
  echo ""
  echo "Phase 17 is RED — the Procedure-format inventory artifact does not"
  echo "yet enumerate the plain-numbered-list Procedure sub-steps (or is"
  echo "absent). Expected FAIL on current code."
  exit 1
fi
