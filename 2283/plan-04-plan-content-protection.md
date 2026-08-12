# Phase 4 — Plan-Content Protection

**Concern:** Stop plan phase prose from being posted to public issue bodies; plan files live only in the local `.issues/{N}/` spec folder (SC-5).

**Files:**
- `.opencode/skills/issue-operations-sub-issues/tasks/link-sub-issue.md`

**SCs:** SC-5

**Dependencies:** Phase 3

**Entry Conditions:**
- Phase 3 complete: `create-pr.md` does not sweep plan-phase sub-issues into PR-merge autoclose
- Phase 3 VbC passed
- `link-sub-issue.md` (lines 83, 90, 94) still composes plan phase prose into sub-issue bodies

**Exit Conditions:**
- `link-sub-issue.md` sub-issue bodies are metadata-only — no plan phase prose (Field/Value tables, Context YAML blocks, Procedure steps)
- SC-5 string verification passes
- issue-operations-sub-issues API capability unchanged (out of scope)

---

- [ ] 28. **RED (**sub-agent**).** Dispatch `task(..., prompt: "execute red task from test-driven-development")` to write a failing content-verification assertion: `grep` `link-sub-issue.md` for plan phase prose body composition markers (`Parent Plan`, `Field | Value`) returns a match (plan content is still posted). Confirm the assertion fails. **→ SC-5**
- [ ] 29. **GREEN (**sub-agent**).** Dispatch `task(..., prompt: "execute green task from test-driven-development")` to stop composing plan phase prose into sub-issue bodies in `link-sub-issue.md` (lines 83, 90, 94); sub-issue body content becomes metadata-only (title, phase reference) — plan files live only in the local `.issues/{N}/` spec folder. **→ SC-5**
- [ ] 30. **GREEN doublecheck (**clean-room**).** Verify `link-sub-issue.md` no longer composes plan phase prose (Field/Value tables, Context YAML blocks, Procedure steps) into sub-issue bodies and that body composition is metadata-only. **→ SC-5**
- [ ] 31. **Post-regression (**sub-agent**).** Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")` to run regression test patterns after the GREEN phase. **→ SC-5**
- [ ] 32. **Verify (**sub-agent**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` to verify the implementation against SC-5 (grep public issue bodies for plan phase markers such as `Parent Plan`, `Field | Value` → absent). **→ SC-5**
- [ ] 33. **Checkpoint commit (**inline**).** Stage `link-sub-issue.md` and commit the change as one atomic slice. (No co-author trailer — added at squash time.) **→ SC-5**

#### Phase 4 VbC

- [ ] 34. **VbC (**clean-room**).** Verify SC-5 is satisfied: `link-sub-issue.md` does not post plan phase prose to public issue bodies. **→ SC-5**

**Concern transition:** Leaving plan-content protection → entering post-implementation steps.

---

## Post-Implementation Steps

These steps run once after the last phase completes.

- [ ] 35. **Audit (**sub-agent**).** Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`, followed by validator, evaluator, arbiter in sequence. **→ all SCs**
- [ ] 36. **Z3 check (**inline**).** Run `.opencode/tools/solve check --state-path ... --contract-path ...` to re-confirm the phase ordering (1 → 2 → 3 → 4) is satisfiable. **→ all SCs**
- [ ] 37. **Structural checks (**sub-agent**).** Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")` to run the finishing checklist (lint, typecheck, format). **→ all SCs**
- [ ] 38. **Pre-PR gate (**sub-agent**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` — reads all SC verdicts, BLOCKs if any FAIL or DONE_WITH_CONCERNS (coerced to FAIL). **→ all SCs**
- [ ] 39. **Regression check (**sub-agent**).** Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")` for the final regression check before PR. **→ all SCs**
- [ ] 40. **Review-prep (**sub-agent**).** Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")` to prepare PR review context. **→ all SCs**
- [ ] 41. **Create PR (**sub-agent**).** Dispatch `task(..., prompt: "execute create task from git-workflow-pr")` to create the pull request. **→ all SCs**
- [ ] 42. **Exec summary (**sub-agent**).** Dispatch `task(..., prompt: "execute completion task from completion-core")` to generate the completion executive summary. **→ all SCs**
