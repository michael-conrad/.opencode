## Implementation Plan — [#1793](https://github.com/michael-conrad/.opencode/issues/1793) — Three-tier finding classification migration

> **Full spec and artifacts: [`.opencode/.issues/1793/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1793)** — this issue is a condensed exec summary; the authoritative plan lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1793/` — implementation plan, phase files, spec, pipeline readiness

**Goal:** Redesign or remove the three-tier finding classification model (`auto-fix`/`conditional`/`flag-for-review`) from `adversarial-verification.md`, migrate all ~45+ task files to the new binary model, update stale guideline reference, and add behavioral tests.

**Dependency:** #1792 must be completed first (surgical removal of `flag-for-review` from audit tasks)

### Phase Table

| Phase | Name | SCs | Dependencies | Steps |
|-------|------|-----|--------------|-------|
| 1 | adversarial-verification.md redesign | SC-1 | #1792 | 1-4 |
| 2 | Task file migration (~45+ files) | SC-2, SC-3 | Phase 1 | 5-9 |
| 3 | Behavioral tests + guidelines update | SC-4, SC-5 | Phase 2 | 10-16 |

### Exit Criteria

- C1: `adversarial-verification.md` three-tier model redesigned — no tier implies "defects are acceptable"
- C2: All ~45+ task files migrated to binary classification
- C3: `guidelines/000-critical-rules.md:422` updated
- C4: Behavioral test verifies audit sub-agent produces only binary PASS/FAIL (no `flag-for-review`)
- C5: Behavioral test verifies VbC sub-agent produces only binary PASS/FAIL (no `conditional`)

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)