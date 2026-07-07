#!/bin/bash
# Behavioral test: 1160-sc5-auditor-no-identity-deliberation
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5 from .opencode#1160: dispatched auditor sub-agent given a task file
# with role header + no task() blocks + no Dispatch Mandate produces a verdict
# without identity deliberation.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1160-sc5-auditor-no-identity-deliberation"

# Simulate an auditor sub-agent dispatch: task the agent with evaluating
# a spec criterion, which is the auditor's actual job. The prompt mimics
# what the orchestrator would pass to an auditor sub-agent.
SCENARIO_PROMPT="You are the DISPATCHED AUDITOR SUB-AGENT. Your role is to evaluate criteria and produce findings. You do NOT dispatch sub-agents, call skill(), or orchestrate pipeline routing.

Evaluate this criterion:
- criterion_id: SPEC-QUALITY-1
- description: Spec has a clear Problem Statement section
- evidence_type: string
- verification_method: grep for '## Problem Statement'

Task file at .opencode/skills/audit/tasks/spec-audit.md contains evaluation criteria and procedure you should use.

Proceed with the evaluation and return your verdict."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0