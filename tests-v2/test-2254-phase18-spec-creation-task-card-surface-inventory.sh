#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Phase 18 — RED enforcement test: spec-creation task-card surface inventory.
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
#
# Asserts that the surface inventory artifact confirming the spec-creation
# task cards are well-formed exists and is complete, covering:
#   (1) headings match filenames,
#   (2) no internal sub-agent dispatch (each card records the
#       "No internal sub-agent dispatch performed" exit criterion),
#   (3) role/name consistency.
#
# This is a content-verification (string) test. It FAILs on the current code
# because the surface inventory artifact does not yet exist (Phase 18 produces
# it as a prep deliverable).
#
# Usage: bash .opencode/tests-v2/test-2254-phase18-spec-creation-task-card-surface-inventory.sh
# Exit:  0 if the surface inventory artifact is complete (GREEN),
#        1 if it is missing or incomplete (RED).
#
# Co-authored with AI: OpenCode (deepseek-ai/DeepSeek-V4-Flash-0731)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

ARTIFACT="$PROJECT_DIR/.opencode/.issues/2254/artifacts/spec-creation-task-card-surface-inventory.yaml"

PASSED=0
FAILED=0

pass() { echo "  PASS: $1"; PASSED=$((PASSED + 1)); }
fail() { echo "  FAIL: $1"; FAILED=$((FAILED + 1)); }

echo ""
echo "=== Phase 18 — spec-creation task-card surface inventory (Spec .opencode#2254) ==="
echo ""
echo "Target task cards: spec-creation/tasks/*.md"
echo "Artifact:    $ARTIFACT"
echo ""
echo "Surface facts to inventory:"
echo "  task cards            -> analyze, create, reconcile-push, revise, validate (5)"
echo "  headings match filenames -> # Task: <name> matches <name>.md for all 5 cards"
echo "  no internal sub-agent dispatch exit criterion:"
echo "    present in  -> create, reconcile-push"
echo "    missing in  -> analyze, revise, validate"
echo ""

# --- (a): surface inventory artifact exists ---
if [ -f "$ARTIFACT" ]; then
  pass "Phase 18: surface inventory artifact exists at $ARTIFACT"
else
  fail "Phase 18: surface inventory artifact exists at $ARTIFACT"
fi

# --- (b): artifact declares the task-card count and list ---
if [ -f "$ARTIFACT" ]; then
  if grep -q "task_card_count: 5" "$ARTIFACT"; then
    pass "Phase 18: artifact declares task_card_count 5"
  else
    fail "Phase 18: artifact declares task_card_count 5"
  fi

  if grep -q "task_cards:" "$ARTIFACT"; then
    pass "Phase 18: artifact declares a task_cards list"
  else
    fail "Phase 18: artifact declares a task_cards list"
  fi

  for card in analyze create reconcile-push revise validate; do
    if grep -q -- "- $card" "$ARTIFACT"; then
      pass "Phase 18: artifact enumerates task card $card"
    else
      fail "Phase 18: artifact enumerates task card $card"
    fi
  done

  # --- (c): artifact records headings match filenames ---
  if grep -q "headings_match_filenames: true" "$ARTIFACT"; then
    pass "Phase 18: artifact records headings_match_filenames: true"
  else
    fail "Phase 18: artifact records headings_match_filenames: true"
  fi

  if grep -q "heading_mismatch_count: 0" "$ARTIFACT"; then
    pass "Phase 18: artifact records heading_mismatch_count 0"
  else
    fail "Phase 18: artifact records heading_mismatch_count 0"
  fi

  # --- (d): artifact records no-internal-sub-agent-dispatch coverage ---
  if grep -q "no_internal_subagent_dispatch:" "$ARTIFACT"; then
    pass "Phase 18: artifact declares no_internal_subagent_dispatch"
  else
    fail "Phase 18: artifact declares no_internal_subagent_dispatch"
  fi

  if grep -q "has_exit_criterion:" "$ARTIFACT"; then
    pass "Phase 18: artifact declares has_exit_criterion"
  else
    fail "Phase 18: artifact declares has_exit_criterion"
  fi

  for card in create reconcile-push; do
    if grep -q -- "- $card" "$ARTIFACT"; then
      pass "Phase 18: artifact records $card as having the no-internal-dispatch exit criterion"
    else
      fail "Phase 18: artifact records $card as having the no-internal-dispatch exit criterion"
    fi
  done

  if grep -q "missing_exit_criterion:" "$ARTIFACT"; then
    pass "Phase 18: artifact declares missing_exit_criterion"
  else
    fail "Phase 18: artifact declares missing_exit_criterion"
  fi

  for card in analyze revise validate; do
    if grep -q -- "- $card" "$ARTIFACT"; then
      pass "Phase 18: artifact records $card as missing the no-internal-dispatch exit criterion"
    else
      fail "Phase 18: artifact records $card as missing the no-internal-dispatch exit criterion"
    fi
  done

  # --- (e): artifact records role/name consistency ---
  if grep -q "role_name_consistency: true" "$ARTIFACT"; then
    pass "Phase 18: artifact records role_name_consistency: true"
  else
    fail "Phase 18: artifact records role_name_consistency: true"
  fi
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASSED"
echo "FAILED: $FAILED"

if [ "$FAILED" -eq 0 ]; then
  echo ""
  echo "Phase 18 is GREEN — the spec-creation task-card surface inventory"
  echo "artifact confirms the task cards are well-formed (headings match"
  echo "filenames, no internal sub-agent dispatch, role/name consistency)."
  exit 0
else
  echo ""
  echo "Phase 18 is RED — the spec-creation task-card surface inventory"
  echo "artifact does not yet exist (or is incomplete). Expected FAIL on"
  echo "current code."
  exit 1
fi
