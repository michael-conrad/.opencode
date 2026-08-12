#!/bin/bash
# Behavioral test: 2272-sc1-audit-status-reconciliation
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1 (#2272): When an implementation audit completes with a PASS verdict, the
# agent checks the ticket's current status and updates it to reflect the
# verified-complete state (e.g. applies a review/PR-ready label or transitions
# status) if an update is warranted. Evidence type: behavioral.
#
# RED phase: the audit skill workflow (SKILL.md + verification-audit task cards)
# has NO status-check-and-update step after a PASS verdict. The agent runs the
# verification-audit ARBITER role on fixture issue #2272 (status: open, label:
# approved-for-implementation). All upstream artifacts (evidence.yaml,
# reasoning.yaml, verdict.yaml with all_criteria_pass: true) are pre-provisioned,
# so the arbiter computes an overall PASS verdict. The agent then reports the
# verdict in chat WITHOUT checking the ticket's current status or updating it.
# A clean-room sub-agent evaluating session.yaml observes no status-read /
# status-update tool calls after the PASS verdict — the behavioral criterion is
# NOT yet met.
#
# GREEN phase: after the audit skill workflow gains the status-check-and-update
# step, the agent reads the ticket's current status (issue read / issue.yaml)
# and updates it (review/PR-ready label or status transition) after the PASS
# verdict.
#
# Scope note: the full audit DiMo 4-role chain (investigator -> validator ->
# evaluator -> arbiter) exceeds practical model-run timeouts (observed: 900s
# bash-tool timeout after the chain reached the validator dispatch). Following
# the 2283-sc3 scope-note pattern, the test scopes to the ARBITER role — the
# decision point where the PASS verdict is produced and where the
# status-check-and-update step is required to fire. The upstream artifacts are
# pre-provisioned by the per-scenario fixture.
#
# The prompt is a real-domain task (run the verification-audit arbiter role on
# a fixture implementation and report the verdict), NOT a prose-recall
# interview. The prompt routes the agent to the arbiter task card procedure
# (.opencode/skills/audit/tasks/verification-audit-arbiter.md) rather than
# self-enumerating the procedure — the agent must read the task card to discover
# the full Step 8 Ticket Status Reconciliation sequence. See
# .opencode/tests-v2/AGENTS.md §11 Prompt Construction Mandate.
# The session.yaml (SQLite DB export) is the PRIMARY evidence source — a
# clean-room sub-agent evaluates whether the agent checked the ticket status
# and updated it after the PASS verdict.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2272-sc1-audit-status-reconciliation"
SCENARIO_PROMPT="Run the verification-audit ARBITER role for issue #2272. Follow the arbiter task procedure in .opencode/skills/audit/tasks/verification-audit-arbiter.md. The spec is at .issues/2272/spec.md. The upstream audit artifacts are pre-collected: evidence.yaml, reasoning.yaml, and verdict.yaml (all criteria PASS) are at tmp/2272/artifacts/verification-audit/. Read the upstream artifacts, compute the aggregate judgment, and report the final audit verdict and next step."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
