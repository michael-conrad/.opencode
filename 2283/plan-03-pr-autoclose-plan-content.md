# Phase 3 — PR Autoclose + Plan-Content Protection

**Concern:** Fix `create-pr.md` so plan-phase sub-issues are not auto-closed on PR merge, and stop plan phase prose from being posted to public issue bodies (SC-4, SC-5).

**Files:**
- `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md`
- `.opencode/skills/issue-operations-sub-issues/tasks/link-sub-issue.md`

**SCs:** SC-4, SC-5

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: behavioral test proves zero sub-issue creation at finishing time
- Phase 2 VbC passed
- `create-pr.md` lines 123-124 still sweep sub-issues into `autoclose_issues`
- `link-sub-issue.md` (lines 83, 90, 94) still composes plan phase prose into sub-issue bodies

**Exit Conditions:**
- `create-pr.md` autoclose preserves parent issue autoclose and excludes plan-phase sub-issues
- `link-sub-issue.md` sub-issue bodies are metadata-only — no plan phase prose (Field/Value tables, Context YAML blocks, Procedure steps)
- SC-4 and SC-5 string verifications pass
- issue-operations-sub-issues API capability and multi-task authorization cascade model unchanged (out of scope)

---

- [ ] 21. **RED (**sub-agent**).** Dispatch `task(..., prompt: "execute red task from test-driven-development")` to write a failing content-verification assertion: `grep` `create-pr.md` for the `autoclose_issues` sub-issue collection (lines 123-124) returns a match (the sweep is still present). Confirm the assertion fails. **→ SC-4**
- [ ] 22. **GREEN (**sub-agent**).** Dispatch `task(..., prompt: "execute green task from test-driven-development")` to remove or gate the sub-issue collection in `autoclose_issues` in `create-pr.md` so plan-phase sub-issues are never auto-closed on PR merge; preserve the parent issue autoclose. **→ SC-4**
- [ ] 23. **GREEN doublecheck (**clean-room**).** Verify `create-pr.md` no longer sweeps plan-phase sub-issues into autoclose and that parent autoclose is preserved. **→ SC-4**
- [ ] 24. **Post-regression (**sub-agent**).** Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")` to run regression test patterns after the GREEN phase. **→ SC-4**
- [ ] 25. **Verify (**sub-agent**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` to verify the implementation against SC-4 (grep `create-pr.md` for `autoclose_issues` → sub-issue collection removed or gated). **→ SC-4**
- [ ] 26. **Checkpoint commit (**inline**).** Stage `create-pr.md` and commit the change as one atomic slice. (No co-author trailer — added at squash time.) **→ SC-4**

---

- [ ] 27. **RED (**sub-agent**).** Dispatch `task(..., prompt: "execute red task from test-driven-development")` to write a failing content-verification assertion: `grep` `link-sub-issue.md` for plan phase prose body composition markers (`Parent Plan`, `Field | Value`) returns a match (plan content is still posted). Confirm the assertion fails. **→ SC-5**
- [ ] 28. **GREEN (**sub-agent**).** Dispatch `task(..., prompt: "execute green task from test-driven-development")` to stop composing plan phase prose into sub-issue bodies in `link-sub-issue.md` (lines 83, 90, 94); sub-issue body content becomes metadata-only (title, phase reference) — plan files live only in the local `.issues/{N}/` spec folder. **→ SC-5**
- [ ] 29. **GREEN doublecheck (**clean-room**).** Verify `link-sub-issue.md` no longer composes plan phase prose (Field/Value tables, Context YAML blocks, Procedure steps) into sub-issue bodies and that body composition is metadata-only. **→ SC-5**
- [ ] 30. **Post-regression (**sub-agent**).** Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")` to run regression test patterns after the GREEN phase. **→ SC-5**
- [ ] 31. **Verify (**sub-agent**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` to verify the implementation against SC-5 (grep public issue bodies for plan phase markers such as `Parent Plan`, `Field | Value` → absent). **→ SC-5**
- [ ] 32. **Checkpoint commit (**inline**).** Stage `link-sub-issue.md` and commit the change as one atomic slice. (No co-author trailer — added at squash time.) **→ SC-5**

#### Phase 3 VbC

- [ ] 33. **VbC (**clean-room**).** Verify SC-4 and SC-5 are satisfied: `create-pr.md` does not sweep plan-phase sub-issues into PR-merge autoclose (parent preserved) and `link-sub-issue.md` does not post plan phase prose to public issue bodies. **→ SC-4, SC-5**

**Concern transition:** Leaving PR autoclose + plan-content protection → entering post-implementation steps.

---

## Post-Implementation Steps

These steps run once after the last phase completes.

- [ ] 34. **Audit (**sub-agent**).** Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`, followed by validator, evaluator, arbiter in sequence. **→ all SCs**
- [ ] 35. **Z3 check (**inline**).** Run `.opencode/tools/solve check --state-path ... --contract-path ...` to re-confirm the phase ordering (1 → 2 → 3) is satisfiable. **→ all SCs**
- [ ] 36. **Structural checks (**sub-agent**).** Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")` to run the finishing checklist (lint, typecheck, format). **→ all SCs**
- [ ] 37. **Pre-PR gate (**sub-agent**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` — reads all SC verdicts, BLOCKs if any FAIL or DONE_WITH_CONCERNS (coerced to FAIL). **→ all SCs**
- [ ] 38. **Regression check (**sub-agent**).** Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")` for the final regression check before PR. **→ all SCs**
- [ ] 39. **Review-prep (**sub-agent**).** Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")` to prepare PR review context. **→ all SCs**
- [ ] 40. **Create PR (**sub-agent**).** Dispatch `task(..., prompt: "execute create task from git-workflow-pr")` to create the pull request. **→ all SCs**
- [ ] 41. **Exec summary (**sub-agent**).** Dispatch `task(..., prompt: "execute completion task from completion-core")` to generate the completion executive summary. **→ all SCs**
