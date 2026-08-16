#!/bin/bash
# Per-scenario fixture: inject a fixture skill into the test repo's
# .opencode/skills/ that violates each new SC-44/SC-45/SC-46 linter rule.
#
# The violating skill contains:
#   Rule 1 (SC-44 — broken task-card link): a task card's Procedure links to
#     `missing.md` which does not exist. The current linter only checks
#     markdown links in SKILL.md Workflows dispatch lines (R5), NOT links
#     inside task-card bodies, so the broken task-card link is not flagged.
#   Rule 2 (SC-45 — no-YAML-frontmatter-on-task-cards): the `frontmatter.md`
#     task card carries YAML frontmatter (--- delimiters + fields). The
#     current linter has no rule for task-card frontmatter.
#   Rule 3 (SC-46 — dispatch-contract completeness): the SKILL.md Workflows
#     step dispatches `dispatch.md` and (a) supplies the Context param
#     `unconsumed_param` that the task card's Dispatch Contract does NOT
#     accept (over-supplied/unconsumed context param, B1), and (b) its Returns
#     field `finding_summary` does NOT match the task card's Result Contract
#     field `summary` (result-contract field-name mismatch, B2).
#
# NOTE: The workflow step uses the `- [ ] N.` checkbox marker with an
# `Execution mode:` sub-bullet so the existing R2/R4 checks do not fire
# spuriously. The dispatch contract defect (over-supplied param + Returns
# mismatch) is what SC-46 must newly flag.
#
# The fixture script runs with $1 = the attempt workdir (a git repo with a
# .opencode submodule checkout).

set -euo pipefail

setup_2254_sc44_sc45_sc46_fixture() {
    local wd="$1"
    local skills_dir="$wd/.opencode/skills"
    local skill_dir="$skills_dir/skildeck-taskcard-violation"
    mkdir -p "$skill_dir/tasks"

    cat > "$skill_dir/SKILL.md" <<'SKILLEOF'
---
name: skildeck-taskcard-violation
description: "Fixture skill for SC-44/SC-45/SC-46 linter task-card enforcement testing. Not a real skill."
license: MIT
compatibility: opencode
---

# Skill: skildeck-taskcard-violation

## Workflows

### Run a task

- [ ] 1. **dispatch** — Dispatch `task(..., prompt: "Follow the instructions in [skildeck-taskcard-violation/tasks/dispatch.md](.opencode/skills/skildeck-taskcard-violation/tasks/dispatch.md)")`
  - **Execution mode:** inline (this step supplies context)
  - **Context passed:** `{issue_number, project_root, unconsumed_param}`
  - **Returns:** `{status, finding_summary}`
SKILLEOF

    cat > "$skill_dir/tasks/dispatch.md" <<'DISPATCHEOF'
# Task: dispatch

## Dispatch Contract

- [ ] `issue_number` accepted
- [ ] `project_root` accepted

## Result Contract

status, summary
DISPATCHEOF

    cat > "$skill_dir/tasks/broken-link.md" <<'BROKENLINKEOF'
# Task: broken-link

## Procedure

- [ ] 1. Follow the instructions in [skildeck-taskcard-violation/tasks/missing.md](.opencode/skills/skildeck-taskcard-violation/tasks/missing.md).
- [ ] 2. Return the result contract.
BROKENLINKEOF

    cat > "$skill_dir/tasks/frontmatter.md" <<'FRONTMATTEREOF'
---
name: frontmatter
description: "Task card that carries YAML frontmatter (SC-45 violation)."
provenance: AI-generated
---

# Task: frontmatter

## Procedure

- [ ] 1. Return the result contract.
FRONTMATTEREOF

}

setup_2254_sc44_sc45_sc46_fixture "$1"
