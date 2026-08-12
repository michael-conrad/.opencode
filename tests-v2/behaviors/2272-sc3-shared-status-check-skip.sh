#!/bin/bash
# Behavioral test: 2272-sc3-shared-status-check-skip
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3 (#2272): The agent performs a status check (reads current ticket status)
# before reporting completion of an implementation audit or implementation-for-PR,
# and only skips the update when the status is already correct. Evidence type:
# behavioral.
#
# This scenario exercises the SKIP-WHEN-ALREADY-CORRECT branch of the shared
# status-check discipline in the implementation-audit (verification-audit
# ARBITER) workflow. The fixture puts ticket #2272 in the already-correct
# verified-complete state (labels include approved-for-review). The agent runs
# the verification-audit ARBITER role on the fixture issue. All upstream
# artifacts (evidence.yaml, reasoning.yaml, verdict.yaml with
# all_criteria_pass: true) are pre-provisioned, so the arbiter computes an
# overall PASS verdict.
#
# RED phase: the audit arbiter task card carries the status-check-and-update
# step, but the agent does NOT consistently read the ticket's current status
# before reporting the PASS verdict when the ticket is already correct, and does
# not explicitly skip the update. A clean-room sub-agent evaluating session.yaml
# observes whether the agent read the ticket status (local-issues read) and
# skipped the update (no local-issues update call) when the status was already
# correct — the behavioral criterion.
#
# GREEN phase: after the shared status-check discipline is strengthened and
# documented in the audit skill, the agent reads the ticket's current status
# before reporting the PASS verdict and skips the update when the status is
# already correct (no redundant re-application of the review/PR-ready label).
#
# Scope note: mirroring the 2272-sc1 scope-note pattern, the test scopes to the
# ARBITER role — the decision point where the PASS verdict is produced and where
# the status-check-and-update step is required to fire. The upstream artifacts
# are pre-provisioned by the per-scenario fixture, and the ticket is pre-set to
# the already-correct state.
#
# The prompt is a real-domain task (run the verification-audit arbiter role on
# a fixture implementation and report the verdict), NOT a prose-recall
# interview. The prompt routes the agent to the arbiter task card procedure
# (.opencode/skills/audit/tasks/verification-audit-arbiter.md) rather than
# self-enumerating the procedure — the agent must read the task card to
# discover the full Step 8 Ticket Status Reconciliation sequence. See
# .opencode/tests-v2/AGENTS.md §11 Prompt Construction Mandate.
# The session.yaml (SQLite DB export) is the PRIMARY evidence source — a
# clean-room sub-agent evaluates whether the agent checked the ticket status
# before reporting the PASS verdict and skipped the update when already correct.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2272-sc3-shared-status-check-skip"
SCENARIO_PROMPT="Run the verification-audit ARBITER role for issue #2272. Follow the arbiter task procedure in .opencode/skills/audit/tasks/verification-audit-arbiter.md. The spec is at .issues/2272/spec.md. The upstream audit artifacts are pre-collected: evidence.yaml, reasoning.yaml, and verdict.yaml (all criteria PASS) are at tmp/2272/artifacts/verification-audit/. Read the upstream artifacts, compute the aggregate judgment, and report the final audit verdict and next step."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
