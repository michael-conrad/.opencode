---
type: PLAN
status: DRAFT
version: 1.0
created: 2026-07-08
parent_spec: 1785
labels: [PLAN, audit, pipeline, touchpoint, behavioral-test]
---

# Implementation Plan — [#1785](https://github.com/michael-conrad/.opencode/issues/1785) — Audit invocation verification

## Goal

Create 16 behavioral test scripts verifying correct audit dispatch at all 7 pipeline touchpoints, plus 5 structural file updates (rename `adversarial-audit` → `audit`, update `audit/SKILL.md` §Blind Dispatch).

## Phase Structure

| Phase | Name | SCs | Steps | Deliverables |
|-------|------|-----|-------|-------------|
| 1 | Core audit dispatch | SC-1 through SC-6 | 5–16 | 6 test scripts (unified invocation, cleanroom, consensus PASS/FAIL/DISAGREE, multi-type) |
| 2 | Pipeline touchpoints | SC-7 through SC-13 | 17–31 | 7 test scripts (spec-creation, writing-plans, issue-operations, implementation-pipeline, verification-before-completion, pr-creation-workflow, git-workflow) |
| 3 | Cross-validate behavior | SC-14, SC-15 | 32–36 | 2 test scripts (evidence type gate, frugal contract) |
| 4 | Bidirectional finding | SC-16 | 37–39 | 1 test script (plan-spec mismatch → revision options) |
| 5 | Structural changes | SC-17, SC-18 | 40–49 | Blind Dispatch update + 5 file renames (`adversarial-audit` → `audit`) |
| 6 | Auto-invocation | SC-19 | 50–52 | 1 test script (audit fires without explicit request) |

## Plan Files

- `.opencode/.issues/1785/plan.md` — Index file with Goal, Architecture, Phase table, Exit criteria
- `.opencode/.issues/1785/plan-01.md` — Phase 1: Core audit dispatch
- `.opencode/.issues/1785/plan-02.md` — Phase 2: Pipeline touchpoints
- `.opencode/.issues/1785/plan-03.md` — Phase 3: Cross-validate behavior
- `.opencode/.issues/1785/plan-04.md` — Phase 4: Bidirectional finding
- `.opencode/.issues/1785/plan-05.md` — Phase 5: Structural changes
- `.opencode/.issues/1785/plan-06.md` — Phase 6: Auto-invocation

## Exit Criteria

- C1. All 16 behavioral test scripts exist at `.opencode/tests/behaviors/NEW-sc*-audit-*.sh`
- C2. Each test script is an artifact-only generator (exit 0 unconditionally, uses `behavior_run`)
- C3. Each test script has `# SC-N:` comment annotations for its SCs
- C4. `audit/SKILL.md` §Blind Dispatch documents `audit_phase` as optional field
- C5. No stale `adversarial-audit` references remain in tracked files
- C6. All 6 pipeline touchpoint tests pass via `--tag audit-touchpoint`
- C7. All 16 tests pass individually
- C8. Verification-before-completion confirms all 19 SCs
- C9. Finishing checklist passes
- C10. Review-prep completed with compare URL
- C11. PR created targeting `dev` branch

🤖 OpenCode (deepseek-v4-flash)
