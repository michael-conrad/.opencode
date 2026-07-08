# Phase 2 — Scope Removal and Guideline Updates

**Concern:** Remove for_pr_only/for_review_only, remove gap-fill column, add YAML-only rule, remove pr_strategy

**Files:**
- `skills/approval-gate/enforcement/scope-parsing.md`
- `skills/approval-gate/enforcement/auto-dispatch-table.md`
- `skills/approval-gate/SKILL.md`
- `skills/approval-gate/tasks/verify-authorization.md`
- `skills/approval-gate/tasks/verify-authorization/gap-fill-cascade.md`
- `skills/approval-gate/tasks/verify-authorization/auto-dispatch.md`
- `guidelines/010-approval-gate.md`
- `guidelines/020-go-prohibitions.md`
- `guidelines/000-critical-rules.md`
- `guidelines/020-go-prohibitions.md`
- `guidelines/080-code-standards.md`
- ~71 skill task files with authorization_scope template blocks

**SCs:** SC-6, SC-7, SC-10, SC-11

**Dependencies:** Phase 1

**Entry conditions:** Phase 1 complete and verified PASS

**Exit conditions:** All for_pr_only/for_review_only references removed, gap-fill column removed, YAML-only rule added, pr_strategy removed from template blocks, SC-6/SC-7/SC-10/SC-11 verified PASS

---

- [ ] 11. **RED (**sub-agent**).** Remove `for_pr_only` and `for_review_only` from `skills/approval-gate/enforcement/scope-parsing.md`. Remove their entries from the scope table and parsing table. **→ SC-6**

- [ ] 12. **RED (**sub-agent**).** Remove `for_pr_only` and `for_review_only` from `skills/approval-gate/enforcement/auto-dispatch-table.md`. Remove their dispatch entries. **→ SC-6**

- [ ] 13. **RED (**sub-agent**).** Remove `for_pr_only` and `for_review_only` from `skills/approval-gate/SKILL.md` authorization_scope enum. **→ SC-6**

- [ ] 14. **RED (**sub-agent**).** Remove `for_pr_only` and `for_review_only` from `skills/approval-gate/tasks/verify-authorization.md` and `skills/approval-gate/tasks/verify-authorization/auto-dispatch.md`. **→ SC-6**

- [ ] 15. **RED (**sub-agent**).** Remove `for_pr_only` and `for_review_only` from `skills/approval-gate/tasks/verify-authorization/gap-fill-cascade.md`. Remove their halt_at mappings and gap-fill entries. **→ SC-6**

- [ ] 16. **RED (**sub-agent**).** Remove `for_pr_only` and `for_review_only` from `guidelines/010-approval-gate.md`, `guidelines/000-critical-rules.md`, and `guidelines/020-go-prohibitions.md`. Remove gap-fill column from the scope table in `010-approval-gate.md`. **→ SC-6, SC-7**

- [ ] 17. **GREEN (**sub-agent**).** Verify `grep -r "for_pr_only\|for_review_only" skills/approval-gate/ guidelines/` returns no matches. If FAIL: remediate and re-run. **→ SC-6**

- [ ] 18. **RED (**sub-agent**).** Add YAML-only rule section to `guidelines/080-code-standards.md`. Section mandates YAML for all LLM-to-LLM data transfers, with JSON prohibited. Exceptions: external API calls, configuration files requiring JSON, data interchange with non-LLM systems. **→ SC-11**

- [ ] 19. **GREEN (**sub-agent**).** Verify `grep "YAML.*LLM\|LLM.*YAML" guidelines/080-code-standards.md` matches. If FAIL: remediate and re-run. **→ SC-11**

- [ ] 20. **RED (**sub-agent**).** Remove `pr_strategy` from all `authorization_scope` template blocks across skill task files (~71 files). Use grep to enumerate all files with `pr_strategy` in template blocks, then remove from each. **→ SC-10**

- [ ] 21. **GREEN (**sub-agent**).** Verify `grep -r "pr_strategy" skills/` returns no matches (except in scope-parsing.md where it is derived). If FAIL: remediate and re-run. **→ SC-10**

- [ ] 22. **VbC (**clean-room**).** Verify all Phase 2 SCs PASS. Run verification commands for SC-6, SC-7, SC-10, SC-11. If any FAIL: remediate and re-run. **→ SC-6, SC-7, SC-10, SC-11**

**Concern transition:** Leaving scope removal and guideline updates → entering behavioral tests. Phase 3 depends on Phase 2's code changes being in place.
