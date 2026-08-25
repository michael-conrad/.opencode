#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
#
# Per-scenario fixture: 1364-sc2-for-pr-missing-plan-auto-create-execute
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-2 (#1364): Under for_pr scope with NO existing plan, the agent SHALL auto-create
# a plan (from the approved spec) then dispatch executing-plans to execute it —
# rather than jumping directly to PR creation (git commit / github_create_pull_request).
#
# The shared issue fixture .issues/1364/ injects BOTH spec.md and plan.md. SC-2 requires
# the plan to be ABSENT so the agent must auto-create it. This setup removes the injected
# plan.md from the isolated test repo's flat .issues/1364/ path and the open
# .issues/open/1364/ path, leaving the approved spec present.
#
# The harness-noise remediations (legacy dirs, dirty tree, editor MCP, no-remote,
# submodule feature-branch contamination, branch pre-work) are shared with SC-1 and
# centralized in 1364-for-pr-common.sh. This script sources that common fixture, then
# applies the two SC-2-specific deltas: remove the plan and copy the 7 analytical
# artifacts so the writing-plans analyze gate passes.
#
# RED STATE: With the for_pr gap-fill still treating "auto-PR" as a standalone action,
# an agent under for_pr scope with a spec but NO plan interprets the remaining action
# as "auto-PR" and jumps to git operations (commit, push, create PR) without ever
# creating a plan or dispatching executing-plans. A clean-room sub-agent evaluating
# session.yaml observes direct git operations with no plan creation and no
# executing-plans dispatch. SC-2 is RED.
#
# GREEN: The approval-gate routing rule ("for_pr pre-flight auto-creates spec+plan,
# then executes the plan via executing-plans") causes the agent to create the missing
# plan first, then dispatch executing-plans to execute it.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=1364-for-pr-common.sh
source "$SCRIPT_DIR/1364-for-pr-common.sh"

# SC-2-specific: remove the injected plan so NO plan exists when the agent starts.
remove_plan_for_sc2() {
    local wd="$1"
    rm -f "$wd/.issues/1364/plan.md"
    rm -f "$wd/.issues/open/1364/plan.md"
    rm -f "$wd/.issues/closed/1364/plan.md"
    git -C "$wd" add .issues/ 2>/dev/null || true
}

# SC-2-specific: the writing-plans analyze gate BLOCKs plan creation when the 7 analytical
# artifacts are missing. setup-fixture-issues.sh does not copy the artifacts/ subdir, so the
# agent's analyze sub-agent returns BLOCKED (MISSING_SPEC_ARTIFACT) and the model loops
# instead of creating the plan. Copy the 7 artifacts so the analyze gate passes.
copy_analytical_artifacts() {
    local wd="$1"
    local fixture_artifacts="$SCRIPT_DIR/../issues/1364/artifacts"
    if [ -d "$fixture_artifacts" ]; then
        mkdir -p "$wd/.issues/1364/artifacts"
        cp "$fixture_artifacts"/*.yaml "$wd/.issues/1364/artifacts/" 2>/dev/null || true
        git -C "$wd" add .issues/1364/artifacts/ 2>/dev/null || true
        echo "  [fixture] copied 7 analytical artifacts to .issues/1364/artifacts/" >&2
    else
        echo "  [fixture] WARNING: fixture artifacts dir not found at $fixture_artifacts" >&2
    fi
}

# SC-2-specific: the research sub-agent stalls searching for the issue-root sc-summary.yaml
# (research step 5 reads it to map SCs to items) and the dependency-contract.yaml (research
# step 9 extracts it, steps 10-12 feed it to solve/plan). In runs -9/-10 the research/create
# sub-agents burned the window on `cat .issues/1364/sc-summary.yaml` -> NOT_FOUND, glob
# `.sc-summary*` -> "No files found", and re-running `solve model --query sat` /
# `plan plan --output` (whose CLI signatures reject those flags) while re-extracting a
# missing dependency-contract. Pre-seed both so research step 5 + step 9-13 pass immediately
# and proceed to the structure/solve-output writes then the create/plan.md-write step instead
# of looping on artifact discovery and CLI probing. This does NOT weaken the SC-2 assertion:
# plan.md is still ABSENT (auto-create is the behavior under test), only the spec-derived
# analytical inputs needed to build that plan are pre-seeded.
copy_research_inputs() {
    local wd="$1"
    local fixture_dir="$SCRIPT_DIR/../issues/1364"
    cp "$fixture_dir/sc-summary.yaml" "$wd/.issues/1364/sc-summary.yaml" 2>/dev/null || true
    cp "$fixture_dir/dependency-contract.yaml" "$wd/.issues/1364/dependency-contract.yaml" 2>/dev/null || true
    git -C "$wd" add .issues/1364/sc-summary.yaml .issues/1364/dependency-contract.yaml 2>/dev/null || true
    echo "  [fixture] pre-seeded sc-summary.yaml + dependency-contract.yaml at .issues/1364/" >&2
}

wd="$1"
remove_plan_for_sc2 "$wd"
copy_analytical_artifacts "$wd"
copy_research_inputs "$wd"
for_pr_apply_common_remediations "$wd"
