#!/bin/bash
# Behavioral test: 1674-skillmd-dispatch-table
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: Orchestrator dispatches pipeline steps from SKILL.md Trigger Dispatch Table
# using canonical dispatch strings, NOT by reading task files inline.
#
# PROMPT RATIONALE
# ================
# The orchestrator receives a real-domain task: execute the implementation pipeline
# for an approved spec. The prompt tests whether the orchestrator dispatches each
# step using the canonical dispatch strings from the SKILL.md dispatch table,
# rather than reading task files inline or writing custom prompts.
#
# BEHAVIORAL EVIDENCE (stderr)
# ============================
# Stderr shows task() dispatches with canonical dispatch strings matching the
# SKILL.md Trigger Dispatch Table entries. No inline file reads of task files
# by the orchestrator. Each step is dispatched via task() with the correct
# skill/task name from the dispatch table.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1674-skillmd-dispatch-table"
read -r -d '' SCENARIO_PROMPT <<'PROMPT_EOF' || true
You are an orchestrator agent. You have loaded the "implementation-pipeline" skill and read its Trigger Dispatch Table.

The dispatch table shows these entries (among others):

| User says / Context | Task | Dispatch | Canonical Dispatch String |
|---------------------|------|----------|--------------------------|
| "execute plan" / "implement spec" | sc-coherence-gate | sub-task | "execute sc-coherence-gate from implementation-pipeline. Read `implementation-pipeline/tasks/sc-coherence-gate.md` first" |
| "sc-coherence-gate" / "coherence gate" | sc-coherence-gate | sub-task | "execute sc-coherence-gate from implementation-pipeline. Read `implementation-pipeline/tasks/sc-coherence-gate.md` first" |
| "pre-red-baseline" / "baseline check" | pre-red-baseline | sub-task | "execute pre-red-baseline from implementation-pipeline. Read `implementation-pipeline/tasks/pre-red-baseline.md` first" |
| "red-phase" / "write failing test" | red-phase | sub-task | "execute red-phase from implementation-pipeline. Read `implementation-pipeline/tasks/red-phase.md` first" |
| "green-phase" / "implement" | green-phase | sub-task | "execute green-phase from implementation-pipeline. Read `implementation-pipeline/tasks/green-phase.md` first" |
| "post-green-enforcement" / "GREEN gate" | post-green-enforcement | sub-task | "execute post-green-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-green-enforcement.md` first" |
| "structural-checks" / "lint/typecheck" | structural-checks | sub-task | "execute structural-checks from implementation-pipeline. Read `implementation-pipeline/tasks/structural-checks.md` first" |
| "green-vbc" / "verification before completion" | green-vbc | sub-task | "execute green-vbc from implementation-pipeline. Read `implementation-pipeline/tasks/green-vbc.md` first" |
| "audit" / "audit step" | audit | orchestrator | orchestrator multi-dispatch: resolve-models -> auditor-1 -> auditor-2 -> cross-validate |
| "review-prep" / "prepare review" | review-prep | sub-task | "execute review-prep from implementation-pipeline. Read `implementation-pipeline/tasks/review-prep.md` first" |
| "exec-summary" / "completion" | exec-summary | sub-task | "execute exec-summary from implementation-pipeline. Read `implementation-pipeline/tasks/exec-summary.md` first" |

Now the developer says "approved #1674 to PR" and the plan has been approved.

Your task: execute the implementation pipeline for issue #1674. Start with the first step in the Trigger Dispatch Table, then proceed through the pipeline steps. For each sub-task step, use the exact canonical dispatch string from the dispatch table.

Do NOT read any task files inline. Do NOT write custom prompts. Use the exact canonical dispatch strings from the table.
PROMPT_EOF

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
