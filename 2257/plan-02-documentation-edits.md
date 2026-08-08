# Phase 2 — Documentation Edits

**Concern:** Propagate the verified issue-level vs repo-level label-ops truth to the four skill-card files.

**Files:**
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/label-operations.md`
- `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md`
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/issue-operations.md`
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/mcp-operations.md`

**SCs:** SC-5, SC-6, SC-7

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: empirical probes run, issue-level vs repo-level capability split verified (SC-4)
- Phase 1 VbC passed
- The verified truth (WORKING/BROKEN classification) is available from Phase 1 evidence

**Exit Conditions:**
- `label-operations.md` reflects the verified workflow (add/replace/remove/remove-all + repo-level section)
- `SKILL.md` capability manifest "Post-creation labels" row and label rows corrected to verified workflow
- `issue-operations.md` and `mcp-operations.md` label claims match the verified workflow
- No false BROKEN/WORKING claims remain

**Cost frame (dark-prose-007):** Verification cost is measured in defect-discovery-latency (DDL). SC-5/6/7 are string grep checks (~1s each) at pre-commit gate catching stale label claims. Low risk, but a stale claim in any of the four cards re-introduces the documentation contradiction this spec resolves.

---

### Item SC-5 — Correct `label-operations.md`

- [ ] 24. **RED (**sub-agent**).** Write a failing grep assertion checking `label-operations.md` for the corrected operation status matching the Phase 1 verified truth (add/replace/remove/remove-all + repo-level section). **→ SC-5**
- [ ] 25. **GREEN (**sub-agent**).** Update `label-operations.md` to the verified workflow, removing false BROKEN claims if issue-level works and adding the repo-level section. **→ SC-5**
- [ ] 26. **Post-regression (**sub-agent**).** Dispatch `execute phase-4 task from test-driven-development` to run regression patterns after GREEN. **→ SC-5**
- [ ] 27. **Verify (**sub-agent**).** Dispatch `execute verify task from verification-before-completion` confirming the grep matches verified truth in `label-operations.md`. **→ SC-5**
- [ ] 28. **Commit (**inline**).** Stage `label-operations.md`; commit test + change together.

### Item SC-6 — Correct `SKILL.md` capability manifest

- [ ] 29. **RED (**sub-agent**).** Write a failing grep assertion checking the `SKILL.md` capability manifest "Post-creation labels" row (and any label-related rows) for the verified workflow status. **→ SC-6**
- [ ] 30. **GREEN (**sub-agent**).** Update the capability manifest row(s) in `gitbucket-api/SKILL.md` to the verified workflow. **→ SC-6**
- [ ] 31. **Post-regression (**sub-agent**).** Dispatch `execute phase-4 task from test-driven-development` to run regression patterns after GREEN. **→ SC-6**
- [ ] 32. **Verify (**sub-agent**).** Dispatch `execute verify task from verification-before-completion` confirming the capability manifest row matches verified truth. **→ SC-6**
- [ ] 33. **Commit (**inline**).** Stage `SKILL.md`; commit test + change together.

### Item SC-7 — Correct downstream `issue-operations.md` and `mcp-operations.md`

- [ ] 34. **RED (**sub-agent**).** Write failing grep assertions checking `issue-operations.md` and `mcp-operations.md` for corrected label guidance matching the verified workflow. **→ SC-7**
- [ ] 35. **GREEN (**sub-agent**).** Update the downstream label claims in both files (removing the "Labels Can ONLY Be Set During Creation" / delete-and-recreate workaround claims if contradicted by verified truth). **→ SC-7**
- [ ] 36. **Post-regression (**sub-agent**).** Dispatch `execute phase-4 task from test-driven-development` to run regression patterns after GREEN. **→ SC-7**
- [ ] 37. **Verify (**sub-agent**).** Dispatch `execute verify task from verification-before-completion` confirming both downstream files match verified truth. **→ SC-7**
- [ ] 38. **Commit (**inline**).** Stage `issue-operations.md` and `mcp-operations.md`; commit test + change together.

#### Phase 2 VbC

- [ ] 39. **VbC (**clean-room**).** Verify SC-5..SC-7 pass (string grep evidence matching verified truth), all four skill-card files corrected, no false claims remain. **→ SC-5, SC-6, SC-7**

**Concern transition:** Leaving documentation edits → entering post-implementation global checks (structural, Z3, pre-PR gate, regression, audit, review-prep, PR creation, exec summary per the plan index).
