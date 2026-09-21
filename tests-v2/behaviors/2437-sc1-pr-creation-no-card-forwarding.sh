#!/bin/bash
# Behavioral test: 2437-sc1-pr-creation-no-card-forwarding
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1 (.opencode#2437, behavioral): the orchestrator does NOT dispatch the
# git-workflow-pr skill card's pr-creation routing content to a sub-agent.
#
# Real-domain prompt: an orchestrator-level PR-creation request. The expected
# (GREEN) behavior is that the orchestrator, after loading the git-workflow-pr
# skill card, executes the pr-creation workflow step in its own context per the
# card's Mandatory Task Discipline clause (Architecture B) and does NOT forward
# the pr-creation routing content ("You are a sub-agent. Follow the
# instructions in ... pr-creation.md ...") into a task() prompt.
#
# RED expectation: the git-workflow-pr SKILL.md pr-creation step still carries
# `Execution mode: sub-agent dispatch` and its task() prompt, so the
# orchestrator forwards the routing content to a sub-agent — the criterion is
# violated and the scenario FAILS (evidence: task() call in session.yaml whose
# prompt contains the pr-creation routing content).
#
# Evaluation is a separate clean-room inspection of session.yaml agent actions
# (tests-v2/AGENTS.md §2, §6a) — stderr/stdout helpers are FORBIDDEN.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2437-sc1-pr-creation-no-card-forwarding"
SCENARIO_PROMPT="Create a pull request for the branch feature/payment-gateway targeting main. branch_name: feature/payment-gateway, spec_summary: add payment gateway integration, is_release: false. Follow the project's PR workflow skill. Work only inside this repository — do not ask for authorization; proceed with the workflow steps using the local branch state as-is (a local dry-run of the routing is acceptable)."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
