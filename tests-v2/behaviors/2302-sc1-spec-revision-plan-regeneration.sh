#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2302-sc1-spec-revision-plan-regeneration
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1 (#2302): When a spec is revised, the linked plan (if one exists) is
# regenerated to match the revised spec's SC set.
#
# The fixture for issue #2302 injects `.issues/2302/spec.md` and
# `.issues/2302/plan.md` into the test repo. The spec has SC-1/SC-2/SC-3 and the
# plan covers exactly those SCs. The prompt is a real-domain spec-revision task
# that adds new success criteria to the spec and requires the linked plan to be
# regenerated so its SC coverage matches the revised SC set.
#
# RED STATE: `spec-creation/tasks/revise.md` (Step 3-7) revises the spec body,
# updates change control, regenerates the remote exec-summary body, writes the
# local spec, and deletes stale analytical artifacts — but it does NOT dispatch
# writing-plans/revise.md (or otherwise regenerate) the linked plan. So a
# clean-room sub-agent evaluating session.yaml will observe the agent revise the
# spec but NOT regenerate the linked plan's SC coverage. This SC is RED.
#
# GREEN: spec-creation revise detects the existing linked plan and regenerates it
# against the revised spec's SC set (via writing-plans revise) before any
# downstream gate. The agent dispatches writing-plans after the spec revision, and
# the plan's SC set is updated to match the revised spec.
#
# PROMPT CONSTRUCTION:
# Real-domain task: revise the spec for issue #2302 to add new success criteria
# and regenerate the linked plan so its SC coverage matches. This is a genuine
# spec-revision domain task that routes through the spec-creation revise pipeline
# and requires plan regeneration — NOT a prose-recall interview. The prompt does
# NOT name spec-creation/tasks/revise.md, writing-plans/tasks/revise.md, or the
# plan-regeneration linkage, so the agent must detect and execute the correct
# behavior naturally.
#
# session.yaml (SQLite DB export) is the PRIMARY evidence source.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2302-sc1-spec-revision-plan-regeneration"
SCENARIO_PROMPT="You have authorization (approved) to revise the spec for issue #2302. The spec in .issues/2302/spec.md currently defines three success criteria (SC-1, SC-2, SC-3), and there is an existing linked plan in .issues/2302/plan.md covering exactly those three SCs. A review finding requires adding two new success criteria to the spec:

- SC-4: The spec-creation revision pipeline SHALL regenerate a linked plan automatically whenever the spec is revised, so the plan's SC coverage always matches the revised spec's SC set.
- SC-5: A behavioral enforcement test SHALL verify that a spec revision triggers automatic linked-plan regeneration.

Revise the spec to add these two success criteria (append them to the existing Success Criteria section with full table rows: ID, Criterion, Evidence Type, Verification Method). Then update the linked plan so its success-criterion coverage matches the revised spec — do not leave the plan stale. Follow your spec-revision workflow to make the plan's SC coverage current with the revised spec."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-1: revising a spec regenerates the linked plan to match the revised SC set"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
