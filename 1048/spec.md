# [SPEC] Revise spec-creation, writing-plans, and adversarial-audit workflows with lessons from #46

## Problem

The [viewport-editor#46](https://github.com/michael-conrad/viewport-editor/issues/46) spec/plan revision cycle revealed systematic gaps in how specs and plans are created, structured, and audited. The `spec-creation`, `writing-plans`, and `adversarial-audit` skills produce artifacts that exhibit:

- Tracking language in forward-looking specs ("implemented", "confirmed", "pending")
- Prescriptive code content in plans (line numbers, exact import strings, assertion code)
- Cross-referenced requirements that agents ignore (pipeline gates stated once, not per-unit)
- Z3 models that don't enforce pipeline completion
- Contract preconditions that block valid state transitions

These patterns produced a multi-hour revision cycle for a single issue. Without systematic correction, every future issue will repeat the same rework.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `spec-creation` outputs specs with no status/tracking language | behavioral |
| SC-2 | `writing-plans` outputs RED/GREEN conditions without line numbers or exact code | behavioral |
| SC-3 | Plans embed pipeline gate tables per-unit, not as a single cross-reference | behavioral |
| SC-4 | `spec-creation` and `writing-plans` produce artifacts from a forward-looking "must be true" stance only | behavioral |
| SC-5 | `adversarial-audit` detects tracking language, prescriptive code, missing pipeline gates, and missing per-unit gate tables | behavioral |
| SC-6 | `spec-creation` generates spec folder URLs for the remote issue body blockquote | behavioral |
| SC-7 | `writing-plans` generates Z3 contracts with pipeline gates (not just domain variables) and no preconditions | behavioral |
| SC-8 | `adversarial-audit` contract-audit step rejects Z3 models missing pipeline gates or containing preconditions | behavioral |
| SC-9 | `spec-creation` and `writing-plans` use sub-folder references for artifacts, never hardcoded file lists | string |
| SC-10 | `writing-plans` and `spec-creation` never use bare `#N` — all issue refs use descriptive Markdown links with full URLs | string |

## Cross-References

| Type | Reference | Direction |
|------|-----------|-----------|
| lessons learned | `.opencode/.issues/1048/spec-artifacts/lessons-learned.md` | Full distillation of #46 revision cycle |
| source issue | [viewport-editor#46](https://github.com/michael-conrad/viewport-editor/issues/46) | fastmcp switch — exposed all seven defect categories |

## Update Record

| Date | Change |
|------|--------|
| 2026-06-06 | Initial spec created from #46 post-mortem |