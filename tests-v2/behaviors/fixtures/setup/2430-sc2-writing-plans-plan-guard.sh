#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Per-scenario fixture for 2430-sc2-writing-plans-plan-guard.
# Seeds the structure artifact, spec, and issue record required by
# writing-plans/tasks/create.md Entry Criteria into the test workdir at
# .issues/2430/ so the agent reaches plan emission instead of stalling on
# missing dispatch context.
#
# SC-2 (.opencode#2430): every plan produced by `writing-plans` embeds the
# canonical guard with `ORCHESTRATOR_ONLY_PLAN`. The seeded spec is a small
# self-contained test spec unrelated to the guard work — the scenario measures
# the emitted plan's structure, not the spec's subject matter.
#
# Usage: sourced by helpers.sh with the workdir path as $1.

setup_sc2_plan_guard_fixture() {
    local wd="$1"
    local issue_dir="$wd/.issues/2430"
    mkdir -p "$issue_dir/artifacts"

    # Seed the structure artifact so create.md Entry Criteria passes.
    cat > "$issue_dir/artifacts/structure.yaml" <<'YAML'
# Structure — Issue 2430: Repo greeting banner utility
spec: .issues/2430/spec.md
generated: 2026-09-06

phases:
  - id: phase_1
    name: "Greeting banner utility"
    scs:
      - SC-1
      - SC-2
    skill: test-driven-development
    task: red
    target: "bin/greet"
    depends_on: []

dependency_dag:
  edges: []
  independent:
    - phase_1

skill_task_selection:
  per_sc_cycle: "Each SC maps to one item with its own RED/GREEN/verify/commit cycle per implementation-workflow reference card"
  red: "test-driven-development --task red"
  green: "test-driven-development --task green"
  verify: "verification-before-completion --task verify"
  commit: "orchestrator inline git add + commit"
YAML

    # Seed the spec file so create.md Entry Criteria passes.
    if [ ! -f "$issue_dir/spec.md" ]; then
        cat > "$issue_dir/spec.md" <<'YAML'
# [SPEC] Repo greeting banner utility

## Problem Statement

New contributors have no quick way to confirm their checkout is wired correctly.
A tiny greeting utility that prints the repository name and current branch makes
onboarding verification a one-command check.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | A `greet` shell utility prints the repository name and current branch on one line | structural |
| SC-2 | Running `greet` in a non-git directory exits non-zero with a clear message | behavioral |
YAML
    fi

    # Seed the local issue record so create.md has a canonical local target.
    if [ ! -f "$issue_dir/issue.yaml" ]; then
        cat > "$issue_dir/issue.yaml" <<'YAML'
issue_number: 2430
title: '[SPEC] Repo greeting banner utility'
state: open
labels:
- SPEC
- approved-for-plan
created_at: '2026-09-06T00:00:00Z'
updated_at: '2026-09-06T00:00:00Z'
owner: michael-conrad
repo: opencode-config
YAML
    fi

    git -C "$wd" add .issues/ 2>/dev/null || true
    git -C "$wd" commit -q --allow-empty -m "seed sc2 plan-guard fixture" 2>/dev/null || true
}

setup_sc2_plan_guard_fixture "$1"
