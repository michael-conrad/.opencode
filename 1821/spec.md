> **Full spec and artifacts: [`.opencode/.issues/1792/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1792)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1792/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Plan Summary

**Spec:** #1792 — [SPEC-FIX] Audit tasks produce PASS+hedging verdicts

**Goal:** Add self-consistency gates to 10 audit task files, remove non-binary classifications from 6 files, remove severity-based exceptions from 2 files, and add behavioral enforcement tests.

**Architecture:** Three concern groups: (A) self-consistency gate addition, (B) non-binary classification removal, (C) severity exception removal. Behavioral tests verify SC-6 and SC-7.

**Phase count:** 1 (single phase — Audit Task Hardening)

**Step count:** 29 (including RED/GREEN, verification, audit, regression, review-prep)

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps |
|-------|------|---------|-----|-------------|-------|
| 1 | Audit Task Hardening | Add self-consistency gates, remove non-binary classifications, remove severity exceptions, add behavioral tests | SC-1 through SC-17 | None | 1–29 |

## Affected Files

- `.opencode/skills/audit/tasks/spec-audit.md` — self-consistency gate + Bidirectional Findings fix + WARNING→ERROR
- `.opencode/skills/audit/tasks/verification-audit.md` — self-consistency gate + flag-for-review removal
- `.opencode/skills/audit/tasks/concern-separation.md` — self-consistency gate + flag-for-review removal
- `.opencode/skills/audit/tasks/plan-fidelity.md` — self-consistency gate + flag-for-review removal
- `.opencode/skills/audit/tasks/closure-verification.md` — self-consistency gate
- `.opencode/skills/audit/tasks/content-audit.md` — self-consistency gate
- `.opencode/skills/audit/tasks/guideline-audit.md` — self-consistency gate
- `.opencode/skills/audit/tasks/coherence-maintenance.md` — self-consistency gate
- `.opencode/skills/audit/tasks/drift-detection.md` — self-consistency gate
- `.opencode/skills/audit/tasks/resolve-models.md` — self-consistency gate
- `.opencode/skills/audit/tasks/test-quality-audit.md` — remove FAIL (inconclusive)
- `.opencode/skills/audit/tasks/spec-summary.md` — remove cosmetic severity
- `.opencode/skills/audit/tasks/cross-validate.md` — remove severity-based exception
- `.opencode/tests/behaviors/` — behavioral tests for SC-6, SC-7

## Exit Criteria

- All 17 SCs verified PASS
- Behavioral tests for SC-6 and SC-7 pass
- All 13 audit task files modified correctly
- No regressions in existing audit behavioral tests
- All changes committed to feature branch

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)