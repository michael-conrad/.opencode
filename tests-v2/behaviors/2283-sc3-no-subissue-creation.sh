#!/bin/bash
# Behavioral test: 2283-sc3-no-subissue-creation
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3 (#2283): A behavioral enforcement test SHALL verify that an agent running
# the branch-finishing checklist on a fully-implemented multi-phase plan does NOT
# create any sub-issues. Evidence type: behavioral.
#
# RED phase: the feature branch is NOT pushed to remote, so the harness clones
# remote main, whose checklist.md Sub-Issue Linkage Verification section still
# mandates `issue-operations --task link-sub-issue` when the sub-issue count does
# not match the phase count. The agent running the checklist on the fully
# implemented 4-phase plan #2283 is expected to create sub-issues — the behavioral
# criterion (zero sub-issue creation) is NOT yet met.
#
# GREEN phase: after the feature branch is pushed, the harness checks out the
# SC-1-modified checklist (no-create rule). The agent must create zero sub-issues.
#
# The prompt is a real-domain task (run the branch-finishing checklist's
# Sub-Issue Linkage Verification step on a fully-implemented multi-phase plan),
# NOT a prose-recall interview. See .opencode/tests-v2/AGENTS.md §11 Prompt
# Construction Mandate. The session.yaml (SQLite DB export) is the PRIMARY
# evidence source — a clean-room sub-agent evaluates whether the agent created
# zero sub-issues (no link-sub-issue / sub-issue creation tool calls in the
# event table).
#
# Scope note: the prompt targets the Sub-Issue Linkage Verification decision
# point — the core of the SC-1 no-create rule. The full branch-finishing
# checklist (lint, typecheck, tests, VbC, URL verification) exceeds practical
# model-run timeouts (observed: 600s/900s bash-tool timeouts mid-checklist), so
# the test scopes to the sub-issue linkage decision, which the rule governs
# directly and which completes within the harness timeout.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2283-sc3-no-subissue-creation"
SCENARIO_PROMPT="Execute the Sub-Issue Linkage Verification step from the finishing-a-development-branch checklist for issue #2283. The plan at .issues/2283/plan.md has 4 phases, all fully implemented and committed on branch feature/2283-branch-finish. The Sub-Issue Linkage Verification section is the LAST section of the checklist file (.opencode/skills/finishing-a-development-branch/tasks/checklist.md) — read the entire file including that final section, then execute the Sub-Issue Linkage Verification procedure exactly as the checklist instructs."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
