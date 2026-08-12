#!/bin/bash
# Behavioral test: 2272-sc2-git-workflow-pr-status-reconciliation
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2 (#2272): When an implementation-for-PR workflow completes, the agent
# checks the ticket's current status and updates it to reflect the PR-created
# state if an update is warranted. Evidence type: behavioral.
#
# RED phase: the git-workflow-pr skill workflows (SKILL.md + completion task
# card) have NO status-check-and-update step on completion. The agent runs the
# git-workflow-pr COMPLETION workflow on fixture issue #2272 (status: open,
# label: approved-for-implementation). The implementation is complete and the
# feature branch is pre-pushed by the per-scenario fixture, so the completion
# workflow reports the completion summary. The agent then reports completion
# WITHOUT checking the ticket's current status or updating it to the
# PR-created state. A clean-room sub-agent evaluating session.yaml observes no
# status-read / status-update tool calls during the completion workflow — the
# behavioral criterion is NOT yet met.
#
# GREEN phase: after the git-workflow-pr skill workflows gain the
# status-check-and-update step, the agent reads the ticket's current status
# (issue read / issue.yaml) and updates it (PR-created/for_pr label or status
# transition) when the completion workflow finishes.
#
# Scope note: the full implementation-for-PR pipeline (squash, rebase, push,
# PR creation via API) exceeds practical model-run timeouts. Following the
# 2283-sc3 scope-note pattern, the test scopes to the COMPLETION workflow —
# the idempotent completion subtask that runs at the end of the PR workflow
# and where the status-check-and-update step is required to fire. The feature
# branch is pre-pushed by the per-scenario fixture.
#
# The prompt is a real-domain task (run the git-workflow-pr completion
# workflow on a fixture implementation and report the completion summary),
# NOT a prose-recall interview. The prompt routes the agent to the completion
# task card procedure (.opencode/skills/git-workflow-pr/tasks/completion.md)
# rather than self-enumerating the procedure — the agent must read the task
# card to discover the full status reconciliation sequence. See
# .opencode/tests-v2/AGENTS.md §11 Prompt Construction Mandate.
# The prompt instructs the agent to EXECUTE the task-card steps inline (not
# dispatch them): a "dispatch a sub-agent" phrasing routes the agent through
# the git-workflow-pr SKILL.md workflow pattern, and the dispatched sub-agent
# burns the model-run window failing to use task() (observed in the initial
# 900s-timeout run, exported session.yaml: the @general subagent never
# reached the completion procedure). Inline execution mirrors the working
# 2272-sc1 arbiter prompt pattern, where the agent reads the task card and
# executes Steps 0-9 itself, firing Step 8 Ticket Status Reconciliation.
# The session.yaml (SQLite DB export) is the PRIMARY evidence source — a
# clean-room sub-agent evaluates whether the agent checked the ticket status
# and updated it during the completion workflow.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2272-sc2-git-workflow-pr-status-reconciliation"
SCENARIO_PROMPT="Run the git-workflow-pr COMPLETION workflow for issue #2272. Follow the completion task procedure in .opencode/skills/git-workflow-pr/tasks/completion.md. The implementation is complete and the feature branch is pushed. Execute the completion steps from the task card in order and report the completion summary."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
