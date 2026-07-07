# Phase 2 — Create DiMo Role-Differentiated Auditor Card

**Concern:** Create single `auditor-role.md` at `.opencode/agents/` defining all 4 DiMo roles (Generator, Evaluator, Knowledge Supporter, Path Provider), both interaction protocols (Divergent mode, Logical mode), and the Judger role for cross-validate integration.

**Files:**
- `.opencode/agents/auditor-role.md` — Create

**SCs:** SC-4

**Dependencies:** Phase 1 complete (old auditor cards deleted)

**Entry conditions:** Phase 1 verified complete, no old auditor cards remain

**Exit conditions:** `auditor-role.md` exists with all 4 DiMo roles, 2 protocols, and Judger role

---

- [ ] 21. **Coherence gate (**clean-room**).** Dispatch `adversarial-audit --task coherence-extraction` to verify the spec's evidence type for SC-4 (structural) is correctly classified. **→ SC-4**

- [ ] 22. **Z3 check (**inline**).** Run `solve check` against coherence gate output contract.

- [ ] 23. **Pre-RED baseline (**clean-room**).** Dispatch `implementation-pipeline --task pre-red-baseline` to confirm `.opencode/agents/auditor-role.md` does not exist yet. **→ SC-4**

- [ ] 24. **Z3 check (**inline**).** Run `solve check` against pre-red-baseline output contract.

- [ ] 25. **RED: Write structural existence test (**sub-agent**).** Dispatch `test-driven-development --task red` to write a test that verifies `ls .opencode/agents/auditor-role.md` returns the file. The test MUST fail at this point because the file doesn't exist yet. **→ SC-4**

- [ ] 26. **Z3 check RED (**inline**).** Run `solve check` against red-phase output contract.

- [ ] 27. **RED doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm the RED test correctly detects the missing file. **→ SC-4**

- [ ] 28. **Z3 check RED doublecheck (**inline**).** Run `solve check` against red-doublecheck output contract.

- [ ] 29. **Post-RED enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-4**

- [ ] 30. **Z3 check post-RED (**inline**).** Run `solve check` against post-red-enforcement output contract.

- [ ] 31. **GREEN: Create auditor-role.md (**sub-agent**).** Dispatch `test-driven-development --task green` to create `.opencode/agents/auditor-role.md` with:
  - All 4 DiMo roles: Generator, Evaluator, Knowledge Supporter, Path Provider — each with persona, function, and interaction protocol
  - Divergent mode protocol: parallel proposals → synthesis → discussion
  - Logical mode protocol: Evaluate → Refine → Judge loop
  - Judger role: holistic assessment, reads all upstream artifacts, produces judgment.yaml
  - Clean-room isolation requirements per LLMs-as-Judges survey bias analysis
  - Artifact path conventions: `evidence.yaml`, `reasoning.yaml`, `verdict.yaml`, `judgment.yaml` **→ SC-4**

- [ ] 32. **Z3 check GREEN (**inline**).** Run `solve check` against green-phase output contract.

- [ ] 33. **Post-GREEN enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-4**

- [ ] 34. **Z3 check post-GREEN (**inline**).** Run `solve check` against post-green-enforcement output contract.

- [ ] 35. **Checkpoint commit (**inline**).** Run `git add -A && git commit -m "Phase 2: Create DiMo role-differentiated auditor card"`. Create checkpoint tag: `opencode-config/checkpoint/1672/phase-2-opencode`. **→ SC-4**

- [ ] 36. **Structural checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-4**

- [ ] 37. **GREEN doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm `auditor-role.md` exists and contains all required role definitions. **→ SC-4**

- [ ] 38. **VbC (**clean-room**).** Verify SC-4: `auditor-role.md` exists at `.opencode/agents/` with all 4 DiMo roles, 2 protocols, and Judger role. **→ SC-4**

**Concern transition:** Leaving creation of DiMo role card → entering refactoring of 15 task files. Phase 3 depends on Phase 2's auditor-role.md (task files will reference the role card).
