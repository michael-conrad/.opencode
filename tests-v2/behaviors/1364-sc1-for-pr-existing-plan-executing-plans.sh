#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 1364-sc1-for-pr-existing-plan-executing-plans
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1 (#1364): Under for_pr scope with an existing approved plan, the agent SHALL
# route through executing-plans (read the plan, dispatch each phase through the
# implementation pipeline in sequence) rather than jumping directly to PR creation
# (git commit / github_create_pull_request).
#
# The fixture for issue #1364 injects `.issues/1364/spec.md` and
# `.issues/1364/plan.md` into the test repo. The spec defines SC-1..SC-5 and the
# plan covers exactly those SCs across three phases. The prompt is a real-domain
# for_pr execution task: the developer has authorized the full pipeline to PR
# creation (for_pr scope), and an approved plan already exists, so the agent MUST
# execute the plan via executing-plans instead of skipping to git operations.
#
# RED STATE: With the routing rule absent (a for_pr scope whose gap-fill still
# treats "auto-PR" as a standalone action), the agent interprets the remaining
# action as "auto-PR" and jumps directly to git operations — commit, push, create
# PR — without reading the plan or dispatching executing-plans. A clean-room
# sub-agent evaluating session.yaml observes direct `git commit` /
# `github_create_pull_request` with no executing-plans dispatch. SC-1 is RED.
#
# GREEN: The approval-gate routing rule ("Under for_pr scope with an existing plan,
# the agent MUST dispatch executing-plans before any PR creation") and the
# executing-plans skill cause the agent to read the plan and dispatch each phase
# through the implementation pipeline in sequence, reaching PR creation only after
# plan execution.
#
# PROMPT CONSTRUCTION:
# Real-domain task: authorized (for_pr scope) to EXECUTE the approved plan for #1364.
# This is a genuine for_pr plan-execution domain task — the developer points the agent
# at the approved plan and asks it to begin executing the plan's phases. The task SCOPE
# is the plan-execution step: read the approved plan, then dispatch its phases through
# the implementation pipeline in sequence. That is exactly what the executing-plans
# skill does, so a correct agent dispatches executing-plans (read-plan then dispatch
# phase-by-phase). The prompt is NOT a prose-recall interview, and it does NOT name
# executing-plans, approval-gate, SKILL.md, or the routing mechanism — the agent must
# detect and execute the correct behavior naturally.
#
# The prompt deliberately does NOT say "execute the plan to completion and then create
# the PR." The prior prompt's full-pipeline framing invited the model to narrate a
# completed RED/GREEN/REFACTOR/COMMIT cycle and a PR with ZERO tool calls (fabrication
# observed in clean-room VbC). Instead the prompt names the concrete first step — begin
# executing the approved plan by reading it and dispatching its first phase — which a
# real agent responds to by dispatching executing-plans and starting actual phase work.
# It states the plan already exists so the agent does not re-create it (SC-2's scenario).
#
# session.yaml (SQLite DB export) is the PRIMARY evidence source.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1364-sc1-for-pr-existing-plan-executing-plans"
SCENARIO_PROMPT="You are authorized (for_pr scope) for issue #1364 — the authorization extends through the full pipeline to pull request creation; do not stop to request re-authorization. The approved implementation plan for #1364 already exists at .issues/1364/plan.md and the approved spec is at .issues/1364/spec.md. Begin executing the approved plan: read the plan file to inventory its phases and their dependency order, then dispatch the plan's phases through the implementation pipeline in that order, implementing each phase's success criteria. Do not skip ahead to creating a branch, committing, or opening a pull request — start with the plan's execution."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-1: for_pr scope with existing plan routes through executing-plans, not direct PR creation"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
