#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
#
# Per-scenario fixture: 1364-sc1-for-pr-existing-plan-executing-plans
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-1 (#1364): Under for_pr scope with an EXISTING approved plan, the agent SHALL route
# through executing-plans (read the plan, dispatch each phase through the implementation
# pipeline in sequence) rather than jumping directly to PR creation (git commit /
# github_create_pull_request).
#
# The shared issue fixture .issues/1364/ injects BOTH spec.md and plan.md. SC-1 requires
# the plan to EXIST, so this setup applies only the harness-noise remediations (legacy
# dirs, dirty tree, editor MCP, no-remote, submodule feature-branch contamination, branch
# pre-work) shared with SC-2 and centralized in 1364-for-pr-common.sh. The plan stays in
# place; the agent's first concrete action must be reading the plan and dispatching its
# phases via executing-plans.
#
# RED STATE: With the for_pr gap-fill still treating "auto-PR" as a standalone action,
# an agent under for_pr scope with spec+plan already present interprets the remaining
# action as "auto-PR" and jumps directly to git operations (commit, push, create PR)
# without reading the plan or dispatching executing-plans. A clean-room sub-agent
# evaluating session.yaml observes direct git operations with no executing-plans
# dispatch. SC-1 is RED.
#
# GREEN: The approval-gate routing rule ("for_pr with an existing plan MUST dispatch
# executing-plans before any PR creation") causes the agent to read the plan and dispatch
# each phase through the implementation pipeline in sequence, reaching PR creation only
# after plan execution.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=1364-for-pr-common.sh
source "$SCRIPT_DIR/1364-for-pr-common.sh"

wd="$1"
for_pr_apply_common_remediations "$wd"
