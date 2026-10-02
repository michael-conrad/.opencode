# Phase 3 — Advisory Text Rewrite

**Concern:** Rewrite the pre-commit-pointer-check advisory text so it stops referencing the removed hook gate and SKIP hatch and instead references the PR-time freshness gates.

**Files:**
- `.opencode/skills/git-workflow-branch/tasks/pre-commit-pointer-check.md`

**SCs:** SC-5, SC-6

**Dependencies:** Phase 1 (SC-1 → SC-5)

**Entry Conditions:**
- Phase 1 complete: Gate 2 removed from the hook (SC-1 PASS)
- Phase 1 VbC passed

**Exit Conditions:**
- Advisory file contains zero stale-pointer-gate / SKIP-hatch wordings
- Advisory file references the PR-time freshness gates (enforcement-gate Steps 0/0.5/0.75) and the referenced target sections exist

**Code Path Coverage:** Path 1 (commit-time — advisory describes the post-removal hook contract); agent-facing text surface only.

**Cross-Cutting SCs:** agent-facing text (advisory must not instruct agents to interact with a gate that no longer exists).

**Interface Boundaries:** advisory text is agent-facing prose only — no contract fields, no code changes.

**State Transitions:** advisory guidance — before: agents directed toward the removed gate and hatch; after: agents directed toward the PR-time freshness authority (Steps 0/0.5/0.75).

**Cost frame:** Verifying the advisory grep costs seconds — a wrong advisory is caught before any agent follows it. Skipping costs hours-to-days of agents acting on an advisory that instructs interacting with a gate that no longer exists.

---

- [ ] 26. **RED (**task-card**).** Grep `pre-commit-pointer-check.md` for stale-pointer-gate / SKIP-hatch wording patterns — matches exist (RED for the clean-advisory state). **→ SC-5**
- [ ] 27. **GREEN (**task-card**).** Remove the stale-pointer-gate / SKIP-hatch wording from the advisory text. Re-run the grep: zero matches. **→ SC-5**
- [ ] 28. **Verify (**task-card**).** Verify SC-5: grep of the advisory file returns zero stale-pointer/hatch matches. **→ SC-5**
- [ ] 29. **COMMIT (**direct**).** `git add` the advisory edit; commit (message: strip stale-pointer gate and SKIP hatch wording from pointer-check advisory). **→ SC-5**
- [ ] 30. **RED (**task-card**).** Grep the advisory file for the PR-time gate references (enforcement-gate Steps 0/0.5/0.75) — no matches exist (RED for the referenced state). **→ SC-6**
- [ ] 31. **GREEN (**task-card**).** Rewrite the advisory text to reference the PR-time freshness gates (enforcement-gate Steps 0/0.5/0.75) using inline `Read [Text](path)` form pointing at the live target file. **→ SC-6**
- [ ] 32. **Verify (**task-card**).** Verify SC-6: grep finds the PR-time gate references, and the referenced target sections exist in `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md`. **→ SC-6**
- [ ] 33. **COMMIT (**direct**).** `git add` the advisory edit; commit (message: point pointer-check advisory at PR-time freshness gates). **→ SC-6**
- [ ] 34. **VbC (**task-card**).** Verify SC-5 and SC-6 verdicts are PASS with string evidence artifacts on disk (both grep outputs). **→ SC-5, SC-6**

#### Phase 3 Completion Block

- [ ] SC-5 verdict recorded with string evidence (zero-match grep output)
- [ ] SC-6 verdict recorded with string evidence (reference grep output + target-section existence check)

**Concern transition:** Leaving advisory text → entering the reference-integrity check build. Phase 4 depends on Phase 2's ordering (test retirement before tool build keeps the runner index clean) but not on Phase 3's outputs.
