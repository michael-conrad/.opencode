# Plan: Restructure Skill Descriptions for Agent-Intent Dispatch

**Spec:** [#1899](https://github.com/michael-conrad/.opencode/issues/1899)

## Goal

Rewrite all 43 skill descriptions (`skills/*/SKILL.md` + 3 platform sub-skills) from user-utterance-matched `"User phrases:"` to agent-intent dispatch triggers. Update the template, validation rules, Pre-Response Gate, and AGENTS.md to reinforce the new pattern.

## Authorization

- `authorization_scope: for_pr`
- `halt_at: pr_created`
- Auto-approved via cascade (spec approved, scope >= `for_implementation`)

## Architecture

The plan has 4 sequential phases. Each phase updates a distinct concern layer (audit → template → descriptions → gate wording). Phases must execute in order — Phase 2 depends on Phase 1's mapping table, Phase 3 depends on Phase 2's template, Phase 4 is independent but ordered last for coherence.

## Affected Files (Complete Inventory: 45 files)

| File | Phase |
|------|-------|
| All 40 `skills/*/SKILL.md` description fields | 3 |
| 3 `skills/issue-operations/platforms/*/SKILL.md` description fields | 3 |
| `skill-creator/reference/routing-only-template.md` | 2 |
| `skill-creator/tasks/validate.md` REQ-2 | 2 |
| `.opencode/AGENTS.md` §Universal Skill Dispatch Gate | 4 |
| `.opencode/prompts/default.txt` §Pre-Response Gate | 4 |

## Phase Table

| Phase | Name | Steps | Files Changed |
|-------|------|-------|-------------|
| 1 | Audit & Frame | 1.1–1.5 | None (mapping table only) |
| 2 | Template Update | 2.6–2.7 | `routing-only-template.md`, `validate.md` |
| 3 | Per-Skill Description Rewrites | 3.8–3.12 | All 43 SKILL.md files + behavioral tests |
| 4 | Pre-Response Gate Audit | 4.13–4.16 | `AGENTS.md`, `default.txt` |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | No description contains "User phrases:" or "user says" | 3 | 3.8, 3.9, 3.10, 3.11 |
| SC-2 | Every description leads with agent-intent dispatch conditions | 3 | 3.8, 3.9, 3.10 |
| SC-3 | `routing-only-template.md` uses "Triggers when:" not "User phrases:" | 2 | 2.6 |
| SC-4 | `validate.md` REQ-2 accepts description without "User phrases:" | 2 | 2.7 |
| SC-5 | Pre-Response Gate in AGENTS.md says "Evaluate your current context and intent" | 4 | 4.13 |
| SC-6 | Pre-Response Gate in default.txt explicitly mentions agent-intent triggers | 4 | 4.14 |
| SC-7 | All 43 skills have behavioral enforcement tests for internal intent dispatch | 1, 3 | 1.5, 3.11 |

## Safety/Rollback Considerations

| Phase | Destructive Operations | Rollback Plan | Data Loss Risk |
|-------|----------------------|---------------|----------------|
| 1 | None (read-only audit) | No rollback needed | none |
| 2 | File modifications to template + validate.md | `git checkout -- <file>` for each | low (tracked files) |
| 3 | Description rewrites on 43 files | `git checkout -- skills/*/SKILL.md skills/issue-operations/platforms/*/SKILL.md` | medium (bulk change) |
| 4 | File modifications to AGENTS.md + default.txt | `git checkout --` for each | low |

## Implementation-Pipeline Gate Steps (Mandatory — Applied Per Phase After Its Implementation)

Every phase in this plan that produces code/skill changes (Phases 2, 3, 4) MUST route through the implementation-pipeline gate chain after the phase's implementation is complete:

- `verification-before-completion` — verify phase SCs
- `finishing-a-development-branch --task checklist` — branch finishing checks
- `git-workflow --task review-prep` — pre-PR preparation

Per the writing-plans SKILL.md §Mandatory Task Discipline item 5: "All implementation-pipeline steps are mandatory — no exceptions."

## Exit Criteria

- Plan index stored at `.opencode/.issues/1899/plan.md`
- Phase files stored at `.opencode/.issues/1899/plan-01.md` through `plan-04.md`
- All phases listed in phase table above
- Approval cascade applied (auto-approved for `for_pr` scope)

## Self-Review Evidence

- [x] Feature branch `feature/1899-skill-descriptions-agent-intent` exists on `.opencode` submodule
- [x] Spec #1899 read — 4-phase SPEC-FIX confirmed
- [x] Spec has `spec-fix` label, authorization scope `for_pr` provided
- [x] All 40 + 3 platform sub-skills = 43 verified by `ls`
- [x] No analytical artifacts exist — spec is straightforward description rewrites; artifacts not required for plan creation
- [x] Step numbering globally sequential across all phase files
- [x] Phase exit criteria include behavioral test requirements per SC evidence types
