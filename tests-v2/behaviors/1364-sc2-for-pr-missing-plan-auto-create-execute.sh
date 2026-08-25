#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
#
# Behavioral test: 1364-sc2-for-pr-missing-plan-auto-create-execute
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2 (#1364): Under for_pr scope with NO existing plan, the agent SHALL auto-create
# a plan (from the approved spec) then dispatch executing-plans to execute it — rather
# than jumping directly to PR creation (git commit / github_create_pull_request).
#
# The fixture for issue #1364 injects `.issues/1364/spec.md` into the test repo. The
# per-scenario fixture (fixtures/setup/1364-sc2-for-pr-missing-plan-auto-create-execute.sh)
# removes the injected plan.md so NO plan exists when the agent starts. The prompt is a
# real-domain for_pr execution task: the developer has authorized the full pipeline to PR
# creation (for_pr scope) for a spec whose plan does NOT yet exist, so the agent MUST
# auto-create the plan first, then execute it via executing-plans instead of skipping to
# git operations.
#
# RED STATE: With the for_pr gap-fill still treating "auto-PR" as a standalone action
# (spec+plan absent → "auto-create spec+plan+auto-approve+auto-PR"), the agent interprets
# the remaining action as "auto-PR" and jumps directly to git operations — commit, push,
# create PR — without creating the plan or dispatching executing-plans. A clean-room
# sub-agent evaluating session.yaml observes direct `git commit` /
# `github_create_pull_request` with no plan creation and no executing-plans dispatch.
# SC-2 is RED.
#
# GREEN: The approval-gate routing rule ("for_pr pre-flight auto-creates spec+plan, then
# executes the plan via executing-plans") causes the agent to create the missing plan
# from the approved spec, then dispatch executing-plans to execute it, reaching PR
# creation only after plan execution.
#
# PROMPT CONSTRUCTION:
# Real-domain task: authorized (for_pr scope) to carry issue #1364 through the full
# pipeline to PR creation. This is a genuine for_pr plan-missing domain task that routes
# through approval-gate scope handling and the executing-plans skill — NOT a prose-recall
# interview. The prompt does NOT name approval-gate, executing-plans, SKILL.md, or the
# routing mechanism, so the agent must detect and execute the correct behavior naturally.
# It states the spec exists and is approved but makes no mention of a plan, so the agent
# must determine the plan is missing and auto-create it (SC-2's scenario, distinct from
# SC-1 which asserts with an existing plan).
#
# session.yaml (SQLite DB export) is the PRIMARY evidence source.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1364-sc2-for-pr-missing-plan-auto-create-execute"
SCENARIO_PROMPT="You are authorized (for_pr scope) for issue #1364 — the authorization extends through the full pipeline to pull request creation; do not stop to request re-authorization. The approved spec for #1364 is at .issues/1364/spec.md and defines five success criteria (SC-1 through SC-5). No implementation plan exists yet for this feature — that is the entry point. Because the spec is approved but the plan is missing, begin by creating the implementation plan from the approved spec, then execute the plan's phases through the implementation pipeline so each success criterion is implemented. Do not skip ahead to committing or opening a pull request — the missing plan is the entry point, and plan execution follows plan creation."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-2: for_pr scope with no existing plan auto-creates plan then executes via executing-plans"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
