#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Phase 16 — RED enforcement test: spec-creation task-card reference inventory.
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
#
# Asserts that the task-card reference inventory artifact enumerating the
# references in spec-creation task cards to issue-operations task files
# exists and is complete, including the missing `skills/` prefix per SC-39.
#
# SC-39: The Procedure steps of `spec-creation/tasks/create.md` and
# `spec-creation/tasks/revise.md` that reference
# `issue-operations-core/tasks/creation.md` and
# `issue-operations/platforms/local/tasks/push-artifacts.md` SHALL carry the
# correct `skills/` prefix so they resolve to
# `.opencode/skills/issue-operations-core/tasks/creation.md` and
# `.opencode/skills/issue-operations/platforms/local/tasks/push-artifacts.md`.
#
# This is a content-verification (string) test. It FAILs on the current code
# because the inventory artifact does not yet exist (Phase 16 produces it).
#
# Usage: bash .opencode/tests-v2/test-2254-phase16-spec-creation-task-card-reference-inventory.sh
# Exit:  0 if the task-card reference inventory artifact is complete (GREEN),
#        1 if it is missing or incomplete (RED).
#
# Co-authored with AI: OpenCode (deepseek-ai/DeepSeek-V4-Flash-0731)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

ARTIFACT="$PROJECT_DIR/.opencode/.issues/2254/artifacts/spec-creation-task-card-reference-inventory.yaml"

PASSED=0
FAILED=0

pass() { echo "  PASS: $1"; PASSED=$((PASSED + 1)); }
fail() { echo "  FAIL: $1"; FAILED=$((FAILED + 1)); }

echo ""
echo "=== Phase 16 — spec-creation task-card reference inventory (Spec .opencode#2254) ==="
echo ""
echo "Target task cards: spec-creation/tasks/create.md, spec-creation/tasks/revise.md"
echo "Artifact:    $ARTIFACT"
echo ""
echo "On-disk references from spec-creation task cards to issue-operations task files:"
echo "  create.md   -> issue-operations-core/tasks/creation.md (missing skills/ prefix, SC-39)"
echo "  create.md   -> issue-operations/platforms/local/tasks/push-artifacts.md (missing skills/ prefix, SC-39)"
echo "  revise.md   -> issue-operations-core/tasks/creation.md (missing skills/ prefix, SC-39)"
echo ""

# --- (a): task-card reference inventory artifact exists ---
if [ -f "$ARTIFACT" ]; then
  pass "Phase 16: task-card reference inventory artifact exists at $ARTIFACT"
else
  fail "Phase 16: task-card reference inventory artifact exists at $ARTIFACT"
fi

# --- (b): artifact enumerates the references ---
if [ -f "$ARTIFACT" ]; then
  if grep -q "reference_count:" "$ARTIFACT"; then
    pass "Phase 16: artifact declares a reference_count"
  else
    fail "Phase 16: artifact declares a reference_count"
  fi

  if grep -q "references_list:" "$ARTIFACT"; then
    pass "Phase 16: artifact declares a references_list"
  else
    fail "Phase 16: artifact declares a references_list"
  fi

  # create.md -> issue-operations-core/tasks/creation.md
  if grep -q "spec-creation/tasks/create.md" "$ARTIFACT"; then
    pass "Phase 16: artifact enumerates a reference from spec-creation/tasks/create.md"
  else
    fail "Phase 16: artifact enumerates a reference from spec-creation/tasks/create.md"
  fi
  if grep -q "issue-operations-core/tasks/creation.md" "$ARTIFACT"; then
    pass "Phase 16: artifact enumerates link_text issue-operations-core/tasks/creation.md"
  else
    fail "Phase 16: artifact enumerates link_text issue-operations-core/tasks/creation.md"
  fi
  if grep -q ".opencode/skills/issue-operations-core/tasks/creation.md" "$ARTIFACT"; then
    pass "Phase 16: artifact records target .opencode/skills/issue-operations-core/tasks/creation.md"
  else
    fail "Phase 16: artifact records target .opencode/skills/issue-operations-core/tasks/creation.md"
  fi

  # create.md -> issue-operations/platforms/local/tasks/push-artifacts.md
  if grep -q "issue-operations/platforms/local/tasks/push-artifacts.md" "$ARTIFACT"; then
    pass "Phase 16: artifact enumerates link_text issue-operations/platforms/local/tasks/push-artifacts.md"
  else
    fail "Phase 16: artifact enumerates link_text issue-operations/platforms/local/tasks/push-artifacts.md"
  fi
  if grep -q ".opencode/skills/issue-operations/platforms/local/tasks/push-artifacts.md" "$ARTIFACT"; then
    pass "Phase 16: artifact records target .opencode/skills/issue-operations/platforms/local/tasks/push-artifacts.md"
  else
    fail "Phase 16: artifact records target .opencode/skills/issue-operations/platforms/local/tasks/push-artifacts.md"
  fi

  # revise.md -> issue-operations-core/tasks/creation.md
  if grep -q "spec-creation/tasks/revise.md" "$ARTIFACT"; then
    pass "Phase 16: artifact enumerates a reference from spec-creation/tasks/revise.md"
  else
    fail "Phase 16: artifact enumerates a reference from spec-creation/tasks/revise.md"
  fi

  # --- (c): artifact flags the missing skills/ prefix per SC-39 ---
  if grep -q "has_skills_prefix: false" "$ARTIFACT"; then
    pass "Phase 16: artifact flags has_skills_prefix: false (missing skills/ prefix per SC-39)"
  else
    fail "Phase 16: artifact flags has_skills_prefix: false (missing skills/ prefix per SC-39)"
  fi

  # --- (d): artifact covers all 3 references ---
  if grep -q "reference_count: 3" "$ARTIFACT"; then
    pass "Phase 16: artifact records reference_count 3"
  else
    fail "Phase 16: artifact records reference_count 3"
  fi
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASSED"
echo "FAILED: $FAILED"

if [ "$FAILED" -eq 0 ]; then
  echo ""
  echo "Phase 16 is GREEN — the task-card reference inventory artifact"
  echo "enumerates the references in spec-creation task cards to"
  echo "issue-operations task files and flags the missing skills/ prefix (SC-39)."
  exit 0
else
  echo ""
  echo "Phase 16 is RED — the task-card reference inventory artifact does not"
  echo "yet enumerate the references (or is absent). Expected FAIL on current code."
  exit 1
fi
