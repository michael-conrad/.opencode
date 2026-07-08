# Phase 1 — Checklist Files and Dispatcher

**Concern:** Create per-scope checklist files and rewrite gap-fill-cascade.md as routing dispatcher

**Files:**
- `skills/approval-gate/tasks/gap-fill-cascade.md` — rewrite as routing dispatcher
- `skills/approval-gate/tasks/gap-fill-cascade/for-pr.md` — create
- `skills/approval-gate/tasks/gap-fill-cascade/for-implementation.md` — create
- `skills/approval-gate/tasks/gap-fill-cascade/for-plan.md` — create

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5

**Dependencies:** None

**Entry conditions:** Plan approved, feature branch exists

**Exit conditions:** All 4 checklist files exist, dispatcher rewritten, SC-1 through SC-5 verified PASS

---

- [ ] 1. **Coherence gate (**clean-room**).** Dispatch pre-analysis sub-agent to verify spec coherence against codebase. Sub-agent reads spec, reads current `gap-fill-cascade.md`, reads current scope-parsing files, and reports whether the spec's approach is coherent with existing code structure. If BLOCKED: HALT and report. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

- [ ] 2. **RED (**sub-agent**).** Create `gap-fill-cascade/for-pr.md` with 5-item state-verification checklist (spec → plan → approval → implementation → PR). Each item follows verify/create pair format: verify state, if PASS proceed, if FAIL report which action to dispatch next. **→ SC-2, SC-5**

- [ ] 3. **GREEN (**sub-agent**).** Verify `for-pr.md` exists and is non-empty. Verify `grep -c "If PASS:"` returns >= 5. If FAIL: remediate and re-run. **→ SC-2, SC-5**

- [ ] 4. **RED (**sub-agent**).** Create `gap-fill-cascade/for-implementation.md` with 4-item state-verification checklist (spec → plan → approval → implementation). Each item follows verify/create pair format. **→ SC-3, SC-5**

- [ ] 5. **GREEN (**sub-agent**).** Verify `for-implementation.md` exists and is non-empty. Verify `grep -c "If PASS:"` returns >= 4. If FAIL: remediate and re-run. **→ SC-3, SC-5**

- [ ] 6. **RED (**sub-agent**).** Create `gap-fill-cascade/for-plan.md` with 2-item state-verification checklist (spec → plan). Each item follows verify/create pair format. **→ SC-4, SC-5**

- [ ] 7. **GREEN (**sub-agent**).** Verify `for-plan.md` exists and is non-empty. Verify `grep -c "If PASS:"` returns >= 2. If FAIL: remediate and re-run. **→ SC-4, SC-5**

- [ ] 8. **RED (**sub-agent**).** Rewrite `gap-fill-cascade.md` as routing dispatcher. The dispatcher reads `authorization_scope` from context, loads the corresponding per-scope checklist file, walks items sequentially, and reports the first missing state or that all states are verified. Scopes without gap-fill (`for_spec`, `for_analysis`, `for_review_prep`) report all states verified immediately. **→ SC-1**

- [ ] 9. **GREEN (**sub-agent**).** Verify `grep -r "loads.*checklist" skills/approval-gate/tasks/gap-fill-cascade.md` matches. If FAIL: remediate and re-run. **→ SC-1**

- [ ] 10. **VbC (**clean-room**).** Verify all Phase 1 SCs PASS. Run verification commands for SC-1 through SC-5. If any FAIL: remediate and re-run. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

**Concern transition:** Leaving checklist file creation and dispatcher rewrite → entering scope removal and guideline updates. Phase 2 depends on Phase 1's checklist files and dispatcher existing.
