# Phase 2 — research.md dependency-contract generation

**Concern:** Replace the BLOCK-if-missing for `dependency-contract.yaml` in `research.md` with generation from `interface-compatibility.yaml` `dependency_contract` section.

**Files:**
- `.opencode/skills/writing-plans/tasks/research.md`

**SCs:** SC-2

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: `analyze.md` uses `issue.yaml` labels for approval check
- Phase 1 VbC passed

**Exit Conditions:**
- `research.md` Step 9 generates `dependency-contract.yaml` from `interface-compatibility.yaml` `dependency_contract` section instead of BLOCKing if missing
- Z3 steps 10-12 consume the generated `dependency-contract.yaml`
- `opencode run` with plan-creation prompt produces no `DEPENDENCY_CONTRACT_NOT_FOUND` BLOCK

---

- [ ] 7. **RED (**sub-agent**).** Write a failing enforcement test that asserts `research.md` generates `dependency-contract.yaml` from `interface-compatibility.yaml` `dependency_contract` section instead of BLOCKing. **→ SC-2**
- [ ] 8. **GREEN (**sub-agent**).** Modify `research.md` Step 9: replace `"If missing: return BLOCKED with DEPENDENCY_CONTRACT_NOT_FOUND"` with generation logic that reads `interface-compatibility.yaml` `dependency_contract` section and writes `dependency-contract.yaml`. **→ SC-2**
- [ ] 9. **GREEN doublecheck (**clean-room**).** Verify the generated `dependency-contract.yaml` is consumed in Z3 steps 10-12. **→ SC-2**
- [ ] 10. **Checkpoint commit (**inline**).** Commit research.md dependency-contract generation.

#### Phase 2 VbC

- [ ] 11. **VbC (**clean-room**).** Verify SC-2: grep for `interface-compatibility.yaml` and `dependency_contract` in `research.md` returns matches; no `DEPENDENCY_CONTRACT_NOT_FOUND` pattern remains. **→ SC-2**

**Concern transition:** Leaving research.md dependency-contract generation → entering cross-skill audit. Phase 3 depends on the pattern established by both Phase 1 and Phase 2 fixes.
