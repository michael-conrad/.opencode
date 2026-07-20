> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **Full spec and artifacts: [`.issues/1447/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1447)**

## Problem

`writing-plans/tasks/structure.md` Exit Criteria (line 17) mandates "global pre-phase (once), per-file RED/GREEN phases (one chain each), global post-phase (once)" — pre/post are dedicated `## Phase` sections with their own headings. But `writing-plans/tasks/write.md` Three-Tier Plan Structure (lines 88-100) mandates "Tier 1 (Global): Steps numbered sequentially across the entire plan. Includes global pre-steps and global post-steps" — pre/post are plan-wide steps without their own phase heading. The plan writer must choose between contradictory specs, producing inconsistent plans.

## Scope

**In scope:**
- Update `writing-plans/tasks/write.md` Three-Tier Plan Structure section to use dedicated pre-phase and post-phase `## Phase` headings instead of Tier 1 (Global) flat steps
- Update `writing-plans/tasks/write.md` Required Sections list to reflect the new pre-phase/post-phase structure
- Update `writing-plans/tasks/write.md` Three-Tier Plan Structure table to replace Tier 1 with dedicated phase entries

**Out of scope:**
- Changes to `writing-plans/tasks/structure.md` — it is the authoritative model
- Changes to `implementation-pipeline` skill
- Changes to plan validation rules
- Changes to any other skill or guideline

## Approach

Replace the Tier 1 (Global) concept in `write.md` with dedicated `## Phase — Pre-RED Common` and `## Phase — Post-RED/green` phase headings, matching `structure.md`'s three-tier organization. The pre-phase contains coherence gate and pre-red-baseline steps. The post-phase contains evidence collection, adversarial audit, cross-validate, regression check, review-prep, and exec-summary steps. Both are proper `## Phase` sections with metadata, not flat plan-wide steps.

## Affected Files

| File | Change |
|------|--------|
| `.opencode/skills/writing-plans/tasks/write.md` | Three-Tier Plan Structure section: replace Tier 1 with dedicated pre/post phase headings |
| `.opencode/skills/writing-plans/tasks/write.md` | Required Sections list: add pre-phase and post-phase entries |
| `.opencode/skills/writing-plans/tasks/write.md` | Three-Tier Plan Structure table: replace Tier 1 row with pre-phase and post-phase rows |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `write.md` Three-Tier Plan Structure section no longer references "Tier 1 (Global)" as flat plan-wide steps | `string` | `grep` for "Tier 1" in `write.md` — MUST NOT appear in the Three-Tier Plan Structure section |
| SC-2 | `write.md` Three-Tier Plan Structure section has dedicated `## Phase — Pre-RED Common` and `## Phase — Post-RED/green` headings | `string` | `grep` for "Phase — Pre-RED Common" and "Phase — Post-RED/green" in `write.md` — both MUST be present |
| SC-3 | `write.md` Required Sections list includes pre-phase and post-phase entries in the correct order | `string` | Read Required Sections list — pre-phase and post-phase MUST appear in order |
| SC-4 | `write.md` Three-Tier Plan Structure table replaces Tier 1 row with pre-phase and post-phase rows | `string` | Read Three-Tier Plan Structure table — MUST have rows for pre-phase and post-phase, NOT Tier 1 |
| SC-5 | Pre-phase in `write.md` includes coherence gate and pre-red-baseline steps | `string` | `grep` for "coherence gate" and "pre-red-baseline" under the pre-phase section — both MUST be present |
| SC-6 | Post-phase in `write.md` includes evidence collection, adversarial audit, cross-validate, regression check, review-prep, and exec-summary steps | `string` | `grep` for each of the six step names under the post-phase section — all MUST be present |
| SC-7 | Global sequential numbering rule (Required Sections item 9) is preserved — steps numbered across all phases including pre and post | `string` | Read Required Sections item 9 — MUST still mandate global sequential numbering |
| SC-8 | No structural changes to `structure.md` | `structural` | `git diff` on `structure.md` — MUST show no changes |
| SC-9 | Behavioral enforcement test exists in `.opencode/tests/behaviors/` that verifies the plan writer uses dedicated pre/post phase headings | `behavioral` | `opencode-cli run` with prompt to write a plan — stderr MUST show `## Phase — Pre-RED Common` and `## Phase — Post-RED/green` in the written plan |

## Edge Cases

- **Existing plans:** Plans already written with the Tier 1 (Global) structure are not invalidated — they were written under the old spec. Only new plans must use the new structure.
- **Single-phase plans:** A single-phase plan still gets a pre-phase and post-phase. The pre-phase runs once before the single implementation phase; the post-phase runs once after.

## Key Decisions

| DEC-ID | Decision | Rationale | Requirement Key |
|--------|----------|-----------|-----------------|
| DEC-1 | Defer to `structure.md` as authoritative | `structure.md` is the phase structure definition task; `write.md` is the plan writing task. The structure definition should drive the writing format, not the other way around. | MUST |
| DEC-2 | Pre/post are dedicated `## Phase` sections, not flat steps | Dedicated phase sections carry metadata (Concern, Files, SCs, Dependencies, Entry/Exit) that flat steps cannot express. This matches `structure.md`'s model. | MUST |

## Risk Callouts

| RISK-ID | Risk | Likelihood | Impact | Mitigation | Verifying SC |
|---------|------|------------|--------|------------|--------------|
| RISK-1 | Plan writer ignores new structure and uses old Tier 1 pattern | Medium | High — inconsistent plans | Behavioral enforcement test (SC-9) catches non-compliance | SC-9 |
| RISK-2 | Global sequential numbering breaks with new phase structure | Low | Medium — steps restart per phase | Required Sections item 9 explicitly preserves global numbering (SC-7) | SC-7 |

## AI Agent Instructions

This issue is an executive summary for human stakeholders. The authoritative spec and plan artifacts are at `.issues/1447/`. After creation, `local-issues sync 1447` MUST be run and the result committed to create the local `.issues/1447/` entry. The implementation plan will be created in `.issues/1447/plan.md` after approval. AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

🤖 OpenCode (deepseek-v4-flash) created