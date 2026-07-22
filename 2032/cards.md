# Card Catalogue — #2032 Implementation Audit

**Audit date:** 2026-07-22
**Auditor:** OpenCode (ollama-cloud/deepseek-v4-flash)
**Issue:** #2032 — Strip dispatch markers from task cards
**Status:** CLOSED (duplicate of #2020)

---

## Audit Verdicts

| SC | Verdict | Detail |
|----|---------|--------|
| SC-1 | ✅ PASS | No DiMo role descriptions or chain flow in task cards |
| SC-2 | ✅ PASS w/ note | Backtick-quoted references in `plan-fidelity-evaluator.md:112` and `plan-fidelity-investigator.md:100` describe what dispatch indicators look like in plan files — documentation context, not dispatch markers. Spec updated to exempt backtick-quoted references. |
| SC-3 | ✅ PASS | No "Never task()" or "orchestrator dispatches" in task cards |
| SC-4 | ❌ **FAIL — deferred to #2020** | 14 of 31 files lack entry/exit criteria: 12 sub-role files under `closure-verification/`, `coherence-extraction/`, `spec-summary/` + `resolve-models.md` + `behavioral-sc-evaluator.md` (file does not exist). Issue closed as duplicate of #2020 before Phase 2 was completed. |
| SC-5 | ✅ PASS w/ note | Same as SC-2 — backtick-quoted references exempted |
| SC-6 | ✅ PASS | audit SKILL.md TDT documents DiMo chain dispatch |
| SC-7 | ❌ **FAIL — deferred to #2020** | Behavioral test file `.opencode/tests-v2/behaviors/task-card-inline-execution.sh` does not exist. Never created because issue was closed as duplicate before Phase 3. |

---

## Remediation Actions

### Spec update (this session)
- SC-2/SC-5: Exempted backtick-quoted documentation references from the grep pattern. The `plan-fidelity` task cards reference `(**sub-agent**)` and `(**clean-room**)` in backtick-quoted documentation context (describing what dispatch indicators look like in plan files). These are not dispatch markers — they are documentation of the plan format. Spec updated to clarify the exemption.

### Deferred to #2020
- SC-4: 12 sub-role files + `resolve-models.md` need entry/exit criteria. `behavioral-sc-evaluator.md` was deleted in commit `aafeeaa4` and needs recreation if still needed.
- SC-7: Behavioral test for sub-agent inline execution needs creation.

---

## Evidence Artifacts

| Artifact | Path |
|----------|------|
| Audit findings | `.opencode/.issues/2032/cards.md` (this file) |
| Spec | `.opencode/.issues/2032/spec.md` |
| Plan | `.opencode/.issues/2032/plan.md` |
| Phase 1 plan | `.opencode/.issues/2032/plan-01.md` |
| Phase 2 plan | `.opencode/.issues/2032/plan-02.md` |
| Analytical artifacts | `.opencode/.issues/2032/artifacts/` |
| PR #2046 (main fix) | https://github.com/michael-conrad/.opencode/pull/2046 |
| PR #2062 (follow-up) | https://github.com/michael-conrad/.opencode/pull/2062 |
| Commit 4801ba2a (final strip) | `4801ba2a` — strips all remaining dispatch markers from 82 files |
