#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2302-sc3-for-pr-scope-continuation
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3 (#2302): Under for_pr scope, spec revision + plan regeneration does not
# cause a premature halt before pr_created.
#
# The fixture for issue #2302 injects `.issues/2302/spec.md` and
# `.issues/2302/plan.md` into the test repo. The spec has SC-1/SC-2/SC-3 and the
# plan covers exactly those SCs. The prompt is a real-domain for_pr spec-revision
# task: the developer has authorized the full pipeline to PR creation (for_pr
# scope), a review finding requires revising the spec and regenerating the linked
# plan, and the agent must continue the pipeline to pr_created instead of halting
# for re-authorization.
#
# RED STATE: The approval-gate Re-implementation Workflow (`.opencode/skills/
# approval-gate/SKILL.md`) fires when spec revision revokes plan approval and
# halts: "Present updated plan for developer approval" then waits for a new
# authorization before re-entering the implementation pipeline. There is no
# for_pr scope-continuation path that lets spec-revision + plan-regeneration
# continue to pr_created without a premature halt. So a clean-room sub-agent
# evaluating session.yaml will observe the agent revise the spec, regenerate the
# plan, then HALT for re-approval instead of continuing toward pr_created. This
# SC is RED.
#
# GREEN: The approval-gate scope handling recognizes a for_pr spec-revision +
# plan-regeneration context and routes the pipeline to continue toward pr_created
# without a premature halt (per approval-gate-014 / critical-rules-037 scope
# continuation). The agent revises the spec, regenerates the plan, and proceeds
# through the implementation pipeline to pr_created without stopping for
# re-authorization.
#
# PROMPT CONSTRUCTION:
# Real-domain task: authorized (for_pr scope) to revise the spec for issue #2302
# and regenerate the linked plan, and to continue the pipeline to PR creation
# without stopping for re-authorization. This is a genuine for_pr spec-revision
# domain task that routes through the approval-gate scope handling and plan
# regeneration — NOT a prose-recall interview. The prompt does NOT name
# approval-gate/SKILL.md, resolve-scope.md, route.md, or the scope-continuation
# mechanism, so the agent must detect and execute the correct behavior naturally.
#
# session.yaml (SQLite DB export) is the PRIMARY evidence source.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2302-sc3-for-pr-scope-continuation"
SCENARIO_PROMPT="You have authorization (approved) to revise the spec for issue #2302 and regenerate its linked plan, all the way to PR creation (for_pr scope). The spec in .issues/2302/spec.md currently defines three success criteria (SC-1, SC-2, SC-3), and there is an existing linked plan in .issues/2302/plan.md covering exactly those three SCs. A review finding requires adding two new success criteria to the spec:

- SC-4: The spec-creation revision pipeline SHALL regenerate a linked plan automatically whenever the spec is revised, so the plan's SC coverage always matches the revised spec's SC set.
- SC-5: A behavioral enforcement test SHALL verify that a spec revision triggers automatic linked-plan regeneration.

You are authorized to proceed through the entire pipeline to PR creation (halt_at: pr_created) — do not stop to request re-authorization. Revise the spec to add these two success criteria (append full table rows: ID, Criterion, Evidence Type, Verification Method). Regenerate the linked plan so its success-criterion coverage matches the revised spec. Then continue the implementation pipeline toward creating the pull request, without halting for re-approval of the scope."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-3: for_pr scope spec-revision + plan-regeneration continues to pr_created without premature halt"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
