#!/bin/bash
# Per-scenario fixture: inject a fixture skill into the test repo's
# .opencode/skills/ that violates each new SC-28 linter format rule.
#
# The violating skill contains:
#   Rule 1 (numbered-checkbox workflow format): Workflows use plain numbered
#     lists (`1.` / `2.`), not `- [ ] N.` markers.
#   Rule 2 (execution-mode sub-bullet): Workflow steps carry only
#     Context/Returns, no `Execution mode:` sub-bullet.
#   Rule 3 (task-card clean-room unit): analyze.md Procedure step 2 calls
#     `task(...)` — an internal sub-agent dispatch inside a task-card
#     Procedure.
#   Rule 4 (dispatch-contract completeness): the workflow Context sub-bullets
#     omit the `project_root` parameter that create.md's Entry Criteria names.
#   Rule 5 (markdown link correctness): the workflow Prompt links to
#     `.opencode/skills/skildeck-violation/tasks/missing.md` which does not
#     exist.
#
# The fixture script runs with $1 = the attempt workdir (a git repo with a
# .opencode submodule checkout).

set -euo pipefail

setup_2254_sc28_fixture() {
    local wd="$1"
    local skills_dir="$wd/.opencode/skills"
    local skill_dir="$skills_dir/skildeck-violation"
    mkdir -p "$skill_dir/tasks"

    cat > "$skill_dir/SKILL.md" <<'SKILLEOF'
---
name: skildeck-violation
description: "Fixture skill for SC-28 linter format-rule enforcement testing. Not a real skill."
license: MIT
compatibility: opencode
---

# Skill: skildeck-violation

## Workflows

### Run a task

1. **analyze** — Dispatch `task(..., prompt: "Follow the instructions in [skildeck-violation/tasks/analyze.md](.opencode/skills/skildeck-violation/tasks/analyze.md)")`
  - **Context passed:** `{issue_number}`
  - **Returns:** `{status, finding_summary}`

2. **create** — Dispatch `task(..., prompt: "Follow the instructions in [skildeck-violation/tasks/create.md](.opencode/skills/skildeck-violation/tasks/create.md)")`
  - **Context passed:** `{issue_number}`
  - **Returns:** `{status, finding_summary}`
SKILLEOF

    cat > "$skill_dir/tasks/analyze.md" <<'ANALYZEEOF'
# Task: analyze

## Entry Criteria

- [ ] `issue_number` received in dispatch context

## Procedure

- [ ] 1. Inspect the codebase.
- [ ] 2. Dispatch `task(..., prompt: "Follow the instructions in [skildeck-violation/tasks/sub.md](.opencode/skills/skildeck-violation/tasks/sub.md)")` to run a sub-analysis.
- [ ] 3. Return the result contract.

## Result Contract

status, finding_summary
ANALYZEEOF

    cat > "$skill_dir/tasks/create.md" <<'CREATEEOF'
# Task: create

## Entry Criteria

- [ ] `issue_number` received in dispatch context
- [ ] `project_root` received in dispatch context
- [ ] `analysis_artifact_path` received in dispatch context

## Procedure

- [ ] 1. Write the spec.
- [ ] 2. Return the result contract.

## Result Contract

status, spec_path, finding_summary
CREATEEOF

}

setup_2254_sc28_fixture "$1"
