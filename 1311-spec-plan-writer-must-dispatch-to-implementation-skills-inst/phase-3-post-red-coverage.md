# Phase 3: Post-RED/green Pipeline Gate Coverage

**Parent:** #1311
**Order:** 3 of 4
**Concern:** Skill task file format updates — adding adversarial-audit, completeness-gate, and completion-core steps to post-RED sections in `plan-structure.md` and `create-and-validate.md`.
**Files:** `.opencode/skills/writing-plans/tasks/create/plan-structure.md`, `.opencode/skills/writing-plans/tasks/create/create-and-validate.md`
**SCs covered:** SC-7, SC-8, SC-9

## TDD Items

- TDD-1: Add adversarial-audit step to post-RED sections in `plan-structure.md` (SC-7)
- TDD-2: Add completeness-gate bridge step to post-RED sections in `plan-structure.md` (SC-8)
- TDD-3: Add completion-core step to post-RED sections in `plan-structure.md` (SC-9)
- TDD-4: Update `create-and-validate.md` Step 10 validation to require post-RED pipeline gates (SC-7, SC-8, SC-9)

## Exit Criteria

- All 4 TDD items complete with RED→GREEN cycle
- Post-RED/green gates: completeness-gate, adversarial-audit, completion-core
- Phase-complete event written to lifecycle manifest

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
