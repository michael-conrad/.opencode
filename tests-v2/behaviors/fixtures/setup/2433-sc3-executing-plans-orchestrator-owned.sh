#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Per-scenario fixture: 2433-sc3-executing-plans-orchestrator-owned
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-3 (#2433): executing-plans routes plan execution to the orchestrator.
# Seeds a tiny two-step approved plan at tmp/plans/small-plan.md in the test
# project so the scenario prompt ("execute the plan") has a concrete target.
# Step 1 writes a file; Step 2 appends to it — both confined to the test
# project's tmp/ tree (no production writes, no auth-sensitive operations).
#
# The plan intentionally marks NO step for task-card dispatch (both steps are
# plain file operations an orchestrator executes in its own context), so the
# GREEN condition is: zero task() calls during plan execution, all steps
# performed with orchestrator-own tool calls. Under the old read-plan/
# dispatch-phase routing the agent instead forwards the whole plan into a
# task() prompt — the RED signal.
#
# Usage: sourced by helpers.sh with the workdir path as $1.

seed_small_plan() {
    local wd="$1"
    mkdir -p "$wd/tmp/plans"
    cat > "$wd/tmp/plans/small-plan.md" <<'EOF'
# Approved Plan — small-plan (fixture for SC-3 probe #2433)

Status: APPROVED (fixture plan; scope confined to tmp/ scratch)

## Phase 1 — Create scratch record

## Step-by-step

- [ ] 1. (**direct**) Create the directory tmp/small-plan-output/ and write the
  file tmp/small-plan-output/step1.txt containing exactly the line:
  `small-plan step 1 executed`
- [ ] 2. (**direct**) Verify step 1: confirm the file exists and contains the
  expected line; then append the line `small-plan step 2 executed` to the same
  file.

## Phase Completion

- Both steps completed with own-context tool calls; report the file path and
  final content.
EOF
    git -C "$wd" add tmp/plans/small-plan.md 2>/dev/null || true
    git -C "$wd" commit -q --allow-empty -m "seed small-plan fixture" 2>/dev/null || true
}

seed_small_plan "$1"