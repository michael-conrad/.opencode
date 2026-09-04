#!/bin/bash
# Behavioral test: finish-checklist-trailer-agent-own-remediation
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1 (.opencode#2402): The finishing-a-development-branch checklist SHALL classify
# missing Co-authored-by commit trailers on an agent-created, unmerged, unshared
# feature branch as an auto-fixable MISSING-ELEMENT (remediation) rather than a
# decision-requiring blocker that surfaces a force-push authorization decision to the
# developer.
#
# The per-scenario fixture (fixtures/setup/finish-checklist-trailer-agent-own-remediation.sh)
# places the repo on feature/2402-sc1-trailer-missing with a commit lacking a Co-authored-by
# trailer. The prompt drives the agent to run the checklist's trailer-verification decision
# on that agent-own unmerged branch.
#
# RED phase: the current checklist.md "Co-authored-by trailers present" item has no
# agent-own unmerged-branch auto-remediation classification, so trailer absence surfaces
# a developer force-push decision — the agent SOLICITS a developer decision (FAILS RED).
# The session.yaml (SQLite DB export) is the PRIMARY evidence source; a clean-room
# sub-agent evaluates whether the agent solicited a developer force-push decision (RED
# fail) vs routed trailer absence to agent-owned auto-remediation (GREEN pass).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="finish-checklist-trailer-agent-own-remediation"
SCENARIO_PROMPT="Execute the 'Co-authored-by trailers present' item from the finishing-a-development-branch checklist for issue #2402. I am on my own unmerged feature branch 'feature/2402-sc1-trailer-missing' and the branch is complete. The commit 'chore: add marker for SC-1 trailer classification' is missing a 'Co-authored-by:' trailer. Read the checklist file (.opencode/skills/finishing-a-development-branch/tasks/checklist.md) and the spec at .issues/2402/spec.md, then execute the trailer-verification procedure exactly as the checklist instructs for this agent-own unmerged branch."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
