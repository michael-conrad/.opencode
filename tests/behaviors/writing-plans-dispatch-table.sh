#!/bin/bash
# Behavioral test: writing-plans-dispatch-table
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: create.md has dispatch table template section with 6 columns
#   (Gate/Dispatch Type/Blind?/Sub-Agent Type/Receives Context/SCs) and 7 rules
# SC-2: create.md has orchestrator execution protocol section with all 10 rules
# SC-3: plan-structure.md has dispatch table as primary phase section template
#   before concern boundaries/files/SCs
# SC-4: create-and-validate.md Step 9 has dispatch table validation subsection
#   with 8 rules (inline=CHECKPOINT-COMMIT only, standard gate set check against
#   implementation-pipeline/SKILL.md §Dispatch Routing Table)
# SC-5: create-and-validate.md no longer generates implementation-checklist.md
# SC-6: create-and-validate.md has plan-reference sync step after Step 13
#   referencing github_issue_write
#
# RED phases: Phase 1 (no dispatch table/protocol in create.md),
#   Phase 2 (prose-driven Step 4 in plan-structure.md),
#   Phase 3 (no dispatch table validation in Step 9, no plan-ref sync step)
#
# GREEN phases: All 3 phases implemented, all 6 SCs satisfied.
#
# Authority: #1191 Phases 1-3 (SC-1 through SC-6)
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="writing-plans-dispatch-table"
SCENARIO_PROMPT="Read the files .opencode/skills/writing-plans/tasks/create.md, .opencode/skills/writing-plans/tasks/create/plan-structure.md, and .opencode/skills/writing-plans/tasks/create/create-and-validate.md. Analyze the phase structure and validation content across all three files. Report what structures you find. Specifically:

1. In create.md: Does the section contain a dispatch table template with at least 6 columns (Gate, Dispatch Type, Blind?, Sub-Agent Type, Receives Context, SCs)?
2. In create.md: Does the section contain an orchestrator execution protocol with numbered rules?
3. In plan-structure.md Step 4: Does the Plan Phase Structure section contain a dispatch table as the primary section template, appearing before concern boundaries, file references, and SC references?
4. In create-and-validate.md Step 9 (Validate Plan): Does the section contain a dispatch table validation subsection with specific validation rules (e.g., inline=CHECKPOINT-COMMIT only, standard gate set check against implementation-pipeline/SKILL.md)?
5. In create-and-validate.md: Does the file contain any reference to 'implementation-checklist' or 'checklist.md' generation?
6. In create-and-validate.md: After Step 13 (Plan Approval), is there a plan-reference sync step that references github_issue_write?
7. Describe the current content of Step 9 in create-and-validate.md in detail."

# RED phase: BEHAVIOR_PHASE=RED will be set when running for RED
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0