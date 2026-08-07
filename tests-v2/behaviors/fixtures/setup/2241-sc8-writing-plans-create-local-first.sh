#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Per-scenario fixture for 2241-sc8-writing-plans-create-local-first.
# Seeds the structure artifact and spec required by writing-plans create.md Entry
# Criteria into the test workdir at .issues/2241/ so the agent reaches Step 9
# (the spec-cleared label write) instead of stalling on missing dispatch context.
#
# SC-8: `writing-plans/tasks/create.md` SHALL write `spec-cleared` to local
# `{issues_prefix}/{N}/issue.yaml` as primary canonical source; remote write SHALL
# be best-effort/secondary only. Currently create.md Step 9 applies the
# `spec-cleared` label via the platform label API (remote-first) as primary.
#
# Usage: sourced by helpers.sh with the workdir path as $1.

setup_sc8_structure_artifact() {
    local wd="$1"
    local issue_dir="$wd/.issues/2241"
    mkdir -p "$issue_dir/artifacts"

    # Seed the structure artifact so create.md Entry Criteria passes.
    cat > "$issue_dir/artifacts/structure.yaml" <<'YAML'
# Structure — Issue 2241: Local issue.yaml is canonical source for authorization tracking
spec: .issues/2241/spec.md
generated: 2026-08-06

phases:
  - id: phase_1
    name: "Local-first label writes"
    scs:
      - SC-8
    skill: test-driven-development
    task: red
    target: "writing-plans/create.md"
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
# [SPEC] Authorization tracking: local issue.yaml is canonical source, not remote API labels

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-8 | `writing-plans/tasks/create.md` SHALL write `spec-cleared` to local `issue.yaml` as primary; remote secondary | semantic |
YAML
    fi

    # Ensure the local issue.yaml record exists so create.md Step 9 has a local
    # target to write spec-cleared to as the canonical source.
    if [ ! -f "$issue_dir/issue.yaml" ]; then
        cat > "$issue_dir/issue.yaml" <<'YAML'
issue_number: 2241
title: '[SPEC] Authorization tracking: local issue.yaml is canonical source, not remote API labels'
state: open
labels:
- needs-approval
created_at: '2026-08-03T15:31:00Z'
updated_at: '2026-08-06T20:25:25+00:00'
owner: michael-conrad
repo: .opencode
YAML
    fi

    git -C "$wd" add .issues/ 2>/dev/null || true
    git -C "$wd" commit -q --allow-empty -m "seed sc8 structure artifact" 2>/dev/null || true
}

setup_sc8_structure_artifact "$1"
