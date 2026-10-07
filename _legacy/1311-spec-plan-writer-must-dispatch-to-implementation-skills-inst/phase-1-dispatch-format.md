# Phase 1: Dispatch Format Change

**Parent:** #1311
**Order:** 1 of 4
**Concern:** Skill task file format updates — updating the plan output format template and validation rules in `plan-structure.md` and `create-and-validate.md` to require skill-dispatch markers.
**Files:** `.opencode/skills/writing-plans/tasks/create/plan-structure.md`, `.opencode/skills/writing-plans/tasks/create/create-and-validate.md`, `.opencode/skills/writing-plans/tasks/create.md`
**SCs covered:** SC-1, SC-2, SC-3

## TDD Items

- TDD-1: Update `plan-structure.md` Step 5 output format to require skill-dispatch markers (SC-1, SC-12)
- TDD-2: Update `create-and-validate.md` format template to require skill-dispatch format (SC-1, SC-11)
- TDD-3: Update `create-and-validate.md` Step 10 validation to reject bare `(**clean-room**)` without skill name (SC-3)
- TDD-4: Update `create-and-validate.md` Step 10 validation to verify skill names exist in skill deck (SC-3)
- TDD-5: Update `create.md` operating protocol Step 7 to reference skill-dispatch format (SC-1)

## Exit Criteria

- All 5 TDD items complete with RED→GREEN cycle
- Post-RED/green gates: completeness-gate, adversarial-audit, completion-core
- Phase-complete event written to lifecycle manifest

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
