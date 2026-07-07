# Phase 1 — Eliminate Cross-Model Infrastructure

**Concern:** Delete 4 auditor cards, resolve-models tool, qualified-auditor-pool.sh, and INSUFFICIENT_FAMILIES references from remaining code.

**Files:**
- `.opencode/agents/auditor-deepseek-flash.md` — Delete
- `.opencode/agents/auditor-gemma4.md` — Delete
- `.opencode/agents/auditor-mistral-large.md` — Delete
- `.opencode/agents/auditor-qwen3.5.md` — Delete
- `.opencode/tools/resolve-models` — Delete
- `.opencode/tests/qualification/qualified-auditor-pool.sh` — Delete
- `.opencode/skills/adversarial-audit/tasks/cross-validate.md` — Modify (remove INSUFFICIENT_FAMILIES references)

**SCs:** SC-1, SC-2, SC-3, SC-12

**Dependencies:** None

**Entry conditions:** Plan approved, feature branch exists

**Exit conditions:** All 6 files deleted, INSUFFICIENT_FAMILIES references removed from cross-validate.md

---

- [ ] 1. **Coherence gate (**clean-room**).** Dispatch `adversarial-audit --task coherence-extraction` to verify the spec's evidence types are correctly classified and substrate classification is applied. **→ SC-1, SC-2, SC-3, SC-12**

- [ ] 2. **Z3 check (**inline**).** Run `solve check --state-path .opencode/.issues/1672/solve-state.yaml --contract-path .opencode/skills/writing-plans/contracts/create-output-template.yaml` to verify coherence gate output conforms to contract.

- [ ] 3. **Pre-RED baseline (**clean-room**).** Dispatch `implementation-pipeline --task pre-red-baseline` to capture current state of all files to be deleted/modified. **→ SC-1, SC-2, SC-3, SC-12**

- [ ] 4. **Z3 check (**inline**).** Run `solve check` against pre-red-baseline output contract.

- [ ] 5. **RED: Write structural deletion test (**sub-agent**).** Dispatch `test-driven-development --task red` to write a test script that verifies:
  - `ls .opencode/agents/auditor-*.md` returns no results (SC-1)
  - `ls .opencode/tools/resolve-models` returns "not found" (SC-2)
  - `ls .opencode/tests/qualification/qualified-auditor-pool.sh` returns "not found" (SC-3)
  - `grep -rn "INSUFFICIENT_FAMILIES" .opencode/` returns no matches (SC-12)
  The test MUST fail at this point because the files still exist. **→ SC-1, SC-2, SC-3, SC-12**

- [ ] 6. **Z3 check RED (**inline**).** Run `solve check` against red-phase output contract.

- [ ] 7. **RED doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm the RED test correctly detects the existing files. **→ SC-1, SC-2, SC-3, SC-12**

- [ ] 8. **Z3 check RED doublecheck (**inline**).** Run `solve check` against red-doublecheck output contract.

- [ ] 9. **Post-RED enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement` to verify no source code was modified during RED phase. **→ SC-1, SC-2, SC-3, SC-12**

- [ ] 10. **Z3 check post-RED (**inline**).** Run `solve check` against post-red-enforcement output contract.

- [ ] 11. **GREEN: Delete 4 auditor card files (**sub-agent**).** Dispatch `test-driven-development --task green` to delete:
  - `.opencode/agents/auditor-deepseek-flash.md`
  - `.opencode/agents/auditor-gemma4.md`
  - `.opencode/agents/auditor-mistral-large.md`
  - `.opencode/agents/auditor-qwen3.5.md`
  Use `git rm` for each file. **→ SC-1**

- [ ] 12. **Z3 check GREEN (**inline**).** Run `solve check` against green-phase output contract.

- [ ] 13. **Post-GREEN enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement` to verify only test files were modified. **→ SC-1, SC-2, SC-3, SC-12**

- [ ] 14. **Z3 check post-GREEN (**inline**).** Run `solve check` against post-green-enforcement output contract.

- [ ] 15. **GREEN: Delete resolve-models tool (**sub-agent**).** Dispatch `test-driven-development --task green` to delete `.opencode/tools/resolve-models` via `git rm`. **→ SC-2**

- [ ] 16. **GREEN: Delete qualified-auditor-pool.sh (**sub-agent**).** Dispatch `test-driven-development --task green` to delete `.opencode/tests/qualification/qualified-auditor-pool.sh` via `git rm`. **→ SC-3**

- [ ] 17. **GREEN: Remove INSUFFICIENT_FAMILIES references (**sub-agent**).** Dispatch `test-driven-development --task green` to edit `.opencode/skills/adversarial-audit/tasks/cross-validate.md`:
  - Remove the `INSUFFICIENT_FAMILIES` error return at line 157
  - Remove the `REPORT_INSUFFICIENT_FAMILIES` action at line 470
  - Replace with appropriate DiMo-aligned error handling (single-model-family is no longer an error) **→ SC-12**

- [ ] 18. **Checkpoint commit (**inline**).** Run `git add -A && git commit -m "Phase 1: Eliminate cross-model infrastructure"`. Create checkpoint tag: `opencode-config/checkpoint/1672/phase-1-opencode`. **→ SC-1, SC-2, SC-3, SC-12**

- [ ] 19. **Structural checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist` to run lint/typecheck/format. **→ SC-1, SC-2, SC-3, SC-12**

- [ ] 20. **GREEN doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm:
  - All 4 auditor card files are deleted (SC-1)
  - `resolve-models` is deleted (SC-2)
  - `qualified-auditor-pool.sh` is deleted (SC-3)
  - No `INSUFFICIENT_FAMILIES` references remain (SC-12) **→ SC-1, SC-2, SC-3, SC-12**

#### Phase 1 VbC

- [ ] 20a. **VbC (**clean-room**).** Verify all 4 SCs pass: SC-1 (no auditor cards), SC-2 (no resolve-models), SC-3 (no qualified-auditor-pool.sh), SC-12 (no INSUFFICIENT_FAMILIES). **→ SC-1, SC-2, SC-3, SC-12**

**Concern transition:** Leaving deletion of cross-model infrastructure → entering creation of DiMo role card. Phase 2 depends on Phase 1's clean state (old files removed, no INSUFFICIENT_FAMILIES references).
