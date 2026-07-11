# Implementation Plan — [#1883](https://github.com/michael-conrad/.opencode/issues/1883) — Resolve Conflicting Skill Description Format Mandates (Unified Agent-Intent)

**Goal:** Adopt Agent-Intent as the single canonical format for skill card `description` fields, deprecate Farmage Pattern, update validation to accept only Agent-Intent format, and update the canonical template.

**Architecture:** Three files in `.opencode/skills/skill-creator/` are modified: `tasks/validate.md` (REQ-2 rewrite), `scripts/validate_skill_cards.py` (validation logic), `reference/routing-only-template.md` (template example). No changes to any of the 37 existing skill SKILL.md files.

**Files:**
- `.opencode/skills/skill-creator/tasks/validate.md`
- `.opencode/skills/skill-creator/scripts/validate_skill_cards.py`
- `.opencode/skills/skill-creator/reference/routing-only-template.md`

**Dispatch:** `skill-creator` skill — tasks `validate.md` update, `validate_skill_cards.py` update, `routing-only-template.md` update.

**Blast Radius:** Limited to `skill-creator` skill directory. No changes to individual skill SKILL.md files. No changes to skill dispatch behavior. The blast radius is contained within the skill-creator tooling.

**Concern Map Reference:**
- Concern 1: Validation specification (validate.md REQ-2) — Phase 1
- Concern 2: Validation script logic (validate_skill_cards.py) — Phase 2
- Concern 3: Canonical template (routing-only-template.md) — Phase 3

> **⚠️ COMPLIANCE REQUIREMENT:** This plan MUST be followed step-by-step. Every step is mandatory. No step may be skipped, combined, reordered, or optimized out. Each step produces a specific deliverable that feeds the next step. The agent MUST NOT deviate from this plan. If a step cannot be completed, the agent MUST halt and report the blocker — not skip the step and continue.

> **⚠️ ONE-STEP-AT-A-TIME PROTOCOL:** Execute exactly one step at a time. After each step, verify the output before proceeding to the next. Do NOT batch steps. Do NOT parallelize. Each step's output is the next step's input.

> **⚠️ STEP STATUS:** After each step, mark it as `[x]` (completed), `[ ]` (not started), or `[!]` (blocked). If blocked, report the blocker and halt.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range | Dispatch |
|-------|------|---------|-----|-------------|------------|----------|
| 1 | Update validate.md REQ-2 | Validation specification | SC-1 | None | 1.1–1.4 | `skill-creator` |
| 2 | Update validate_skill_cards.py | Validation script logic | SC-2, SC-3, SC-4 | Phase 1 | 2.1–2.5 | `skill-creator` |
| 3 | Update routing-only-template.md | Canonical template | SC-5 | Phase 2 | 3.1–3.3 | `skill-creator` |

> **⚠️ COMPLIANCE REQUIREMENT:** This plan MUST be followed step-by-step. Every step is mandatory. No step may be skipped, combined, reordered, or optimized out. Each step produces a specific deliverable that feeds the next step. The agent MUST NOT deviate from this plan. If a step cannot be completed, the agent MUST halt and report the blocker — not skip the step and continue.

> **⚠️ SELF-REMEDIATION PROTOCOL:** If a step fails, the agent MUST attempt remediation before halting. Diagnose the root cause, fix it, and re-verify. Only halt after remediation has been attempted and failed. Do NOT halt at the first sign of difficulty.

## Exit Criteria

- [ ] C1: `validate.md` REQ-2 updated to specify Agent-Intent as canonical format
- [ ] C2: `validate_skill_cards.py` REJECTS Farmage format and `User phrases:`/`Trigger phrases:` elements
- [ ] C3: All 37 existing skills pass validation in their current Agent-Intent format
- [ ] C4: New skills created via `skill-creator --task init` use Agent-Intent format
- [ ] C5: `routing-only-template.md` updated to show Agent-Intent as canonical
