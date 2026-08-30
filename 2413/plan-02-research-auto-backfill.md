# Phase 2 — Research.md step 9 adaptation — auto-backfill dependency_contract

**Concern:** Eliminate the hard block in `research.md` step 9 by auto-backfilling `dependency_contract` from existing artifact keys when the section is missing.

**Files:**
- `.opencode/skills/writing-plans/tasks/research.md`

**SCs:** SC-3

**Dependencies:** None (independent of Phase 1)

**Entry Conditions:**
- Spec #2413 is approved
- Feature branch exists
- `research.md` is readable and step 9 logic is understood

**Exit Conditions:**
- `research.md` step 9 detects a missing `dependency_contract` section in `interface-compatibility.yaml`
- When missing, step 9 auto-backfills `dependency_contract` from the existing `interfaces`/`removed_interfaces`/`breaking_changes` keys
- The auto-backfill produces a valid `dependency-contract.yaml` that the `solve`/`plan` tools can consume
- Plan creation proceeds without `DEPENDENCY_CONTRACT_NOT_FOUND`

---

- [ ] 8. **Pre-regression (**sub-agent**).** Run regression test patterns to establish baseline. **→ SC-3**
- [ ] 9. **RED (**sub-agent**).** Write a behavioral enforcement test that feeds an `interface-compatibility.yaml` missing `dependency_contract` into the research pipeline and asserts it auto-backfills (not hard-blocks). The test calls `opencode run` with a research prompt and inspects stderr for backfill activity. **→ SC-3**
- [ ] 10. **GREEN (**sub-agent**).** Modify `research.md` step 9 to detect missing `dependency_contract` section and auto-backfill from `interfaces`/`removed_interfaces`/`breaking_changes` keys. Ensure the output `dependency-contract.yaml` structure matches what `solve`/`plan` tools expect. **→ SC-3**
- [ ] 11. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ SC-3**
- [ ] 12. **Verify (**clean-room**).** Run verification-before-completion: confirm auto-backfill works on a test artifact without `dependency_contract`, produces correct `dependency-contract.yaml`, and does not block. **→ SC-3**
- [ ] 13. **Commit (**inline**).** `git add .opencode/skills/writing-plans/tasks/research.md && git commit -m "phase 2: auto-backfill dependency_contract in research.md step 9 (#2413 SC-3)"`

#### Phase 2 VbC

- [ ] 14. **VbC (**clean-room**).** Verify Phase 2 deliverable meets all exit conditions. **→ SC-3**

**Concern transition:** Leaving research.md consumer adaptation → entering schema agreement verification. Phase 2 is structurally independent of Phase 1.
