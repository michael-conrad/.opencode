# Plan: Restructure SKILL.md Files to Routing-Only Format with DISPATCH_GATE

## Goal

Restructure all 39 SKILL.md files to routing-only format with DISPATCH_GATE, migrate procedure content to `tasks/*.md`, add validation, behavioral tests, and pre-commit gate.

## Architecture

8 phases executed sequentially. Each phase produces a self-contained deliverable that the next phase depends on. Phase 1 is DONE (routing-only template exists). All phases share one feature branch with one commit per phase (stacked PR strategy).

## Files Affected

- All 39 `skills/*/SKILL.md` files — remove procedure text, add DISPATCH_GATE
- `skills/*/tasks/*.md` — receive migrated procedure content
- `skills/skill-creator/reference/routing-only-template.md` — add DISPATCH_GATE
- `skills/skill-creator/reference/skill-card-spec.md` — document DISPATCH_GATE
- `skills/skill-creator/scripts/validate_skill_cards.py` — add REQ-6 check
- `.opencode/hooks/pre-commit` — add structural gate
- `.opencode/tests/behaviors/` — new behavioral test files
- `.opencode/guidelines/080-code-standards.md` — update if needed
- `skills/skill-creator/SKILL.md` — update validation rules

## Phase Table

| Phase | Title | Sub-Issue | Concern | Dependency |
|-------|-------|-----------|---------|------------|
| 1 | Routing-only template defined | N/A (DONE) | Template | None |
| 2 | Add DISPATCH_GATE to routing-only template | #1784-sub-2 | Template | Phase 1 |
| 3 | Audit all 39 SKILL.md files for procedure content | #1784-sub-3 | Audit | Phase 2 |
| 4 | Migrate procedure content to tasks/*.md | #1784-sub-4 | Migration | Phase 3 |
| 5 | Add DISPATCH_GATE to defective cards | #1784-sub-5 | DISPATCH_GATE | Phase 4 |
| 6 | Update validation script | #1784-sub-6 | Validation | Phase 5 |
| 7 | Behavioral enforcement tests | #1784-sub-7 | Testing | Phase 6 |
| 8 | Pre-commit structural gate | #1784-sub-8 | Gate | Phase 7 |
| 9 | Update guidelines | #1784-sub-9 | Docs | Phase 8 |

## Exit Criteria

All 15 SCs from the spec pass:

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-ROUTING-1 | After `skill("approval-gate")`, orchestrator has no procedure text | `behavioral` |
| SC-ROUTING-2 | After `skill("approval-gate")`, orchestrator has dispatch table + canonical strings | `behavioral` |
| SC-ROUTING-3 | Orchestrator dispatches sub-agents (not inline work) when processing approved spec | `behavioral` |
| SC-ROUTING-4 | All 39 SKILL.md files pass routing-only audit (no procedure text in body) | `structural` |
| SC-ROUTING-5 | Pre-commit hook detects prohibited procedure patterns in SKILL.md files | `behavioral` |
| SC-ROUTING-6 | Pre-commit hook does NOT block commits that only modify tasks/*.md files | `behavioral` |
| SC-ROUTING-7 | All task files that received migrated content have proper entry/exit criteria and step definitions | `semantic` |
| SC-DG-1 | `audit/SKILL.md` has complete DISPATCH_GATE with all 7 subsections | `string` |
| SC-DG-2 | `playwright-cli/SKILL.md` has complete DISPATCH_GATE; only DISPATCH_GATE section modified | `string` |
| SC-DG-3 | `solve/SKILL.md` gains missing subsections; existing content preserved | `string` |
| SC-DG-4 | `routing-only-template.md` has DISPATCH_GATE section with all 7 subsections | `string` |
| SC-DG-5 | `skill-card-spec.md` documents DISPATCH_GATE structure requirements | `string` |
| SC-DG-6 | `validate_skill_cards.py` REQ check catches missing DISPATCH_GATE subsections | `behavioral` |
| SC-DG-7 | Existing 33 working cards not broken by validation change | `behavioral` |

## Self-Review Evidence

- Spec #1784 is approved with `approved-for-pr` label
- Authorization scope: `for_pr` — plan auto-approved per approval cascade
- Feature branch `feature/1784-routing-dispatch-gate` exists
- 8 sub-issues created (one per remaining phase)
- All implementation-pipeline steps enumerated in phase files
- Phase dependency chain is linear (no parallel concerns)
- Stacked PR strategy: one branch, 8 commits, one PR targeting `dev`

## Implementation Pipeline Gate References

Each phase file includes the following mandatory pipeline gates:
- Pre-work (git-workflow) — branch creation, submodule tagging
- Implementation-pipeline dispatch — RED/GREEN sub-agents
- Verification-before-completion — SC verification per phase
- Finishing-a-development-branch — checklist
- Review-prep — compare URL, PR body
- Cleanup — post-merge branch deletion, issue closure

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
