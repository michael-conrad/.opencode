# Phase 5 — Behavioral Tests

**Concern:** Write behavioral enforcement tests for SC-13 (DiMo role chain dispatch) and SC-14 (single-model-family resilience).

**Files:**
- `.opencode/tests/behaviors/dimo-role-chain-dispatch.sh` — Create (SC-13)
- `.opencode/tests/behaviors/single-model-family-resilience.sh` — Create (SC-14)

**SCs:** SC-13, SC-14

**Dependencies:** Phase 1, 2, 3, 4 complete (all infrastructure changes in place)

**Entry conditions:** SKILL.md updated with DiMo architecture, no old infrastructure remains

**Exit conditions:** 2 behavioral test scripts exist, both pass with clean-room evaluation

---

- [ ] 75. **Coherence gate (**clean-room**).** Dispatch `adversarial-audit --task coherence-extraction` to verify SC-13 and SC-14 evidence types (behavioral) are correctly classified with automatic uplift. **→ SC-13, SC-14**

- [ ] 76. **Z3 check (**inline**).** Run `solve check` against coherence gate output contract.

- [ ] 77. **Pre-RED baseline (**clean-room**).** Dispatch `implementation-pipeline --task pre-red-baseline` to confirm no behavioral tests for SC-13/SC-14 exist yet. **→ SC-13, SC-14**

- [ ] 78. **Z3 check (**inline**).** Run `solve check` against pre-red-baseline output contract.

- [ ] 79. **RED: Write behavioral test for SC-13 (**sub-agent**).** Dispatch `test-driven-development --task red` to create `.opencode/tests/behaviors/dimo-role-chain-dispatch.sh`:
  - Send an audit prompt via `opencode-cli run` (using `with-test-home` wrapper)
  - Assert stderr shows role-differentiated dispatch (Knowledge Supporter, Path Provider, Evaluator, Judger roles)
  - Assert stderr does NOT show `resolve-models` dispatch
  - Use `assert_stderr_pattern_present` and `assert_stderr_pattern_absent` helpers
  - The test MUST fail at this point because the DiMo dispatch logic isn't implemented yet **→ SC-13**

- [ ] 80. **Z3 check RED (**inline**).** Run `solve check` against red-phase output contract.

- [ ] 81. **RED doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm the RED test correctly fails. **→ SC-13**

- [ ] 82. **Z3 check RED doublecheck (**inline**).** Run `solve check` against red-doublecheck output contract.

- [ ] 83. **Post-RED enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-13, SC-14**

- [ ] 84. **Z3 check post-RED (**inline**).** Run `solve check` against post-red-enforcement output contract.

- [ ] 85. **GREEN: Implement DiMo dispatch logic (**sub-agent**).** Dispatch `test-driven-development --task green` to ensure the DiMo role chain dispatch is fully implemented in SKILL.md and task files. This step is a verification pass — the implementation was done in Phases 2-4. If the RED test still fails after Phases 2-4, remediate the dispatch logic. **→ SC-13**

- [ ] 86. **RED: Write behavioral test for SC-14 (**sub-agent**).** Dispatch `test-driven-development --task red` to create `.opencode/tests/behaviors/single-model-family-resilience.sh`:
  - Set up an environment with only 1 model family available
  - Send an audit prompt via `opencode-cli run` (using `with-test-home` wrapper)
  - Assert the audit completes without `INSUFFICIENT_FAMILIES` error
  - Assert stderr shows DiMo role dispatch (not cross-model dispatch)
  - The test MUST fail at this point **→ SC-14**

- [ ] 87. **Z3 check RED (**inline**).** Run `solve check` against red-phase output contract.

- [ ] 88. **RED doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm the RED test correctly fails. **→ SC-14**

- [ ] 89. **Z3 check RED doublecheck (**inline**).** Run `solve check` against red-doublecheck output contract.

- [ ] 90. **Post-RED enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-13, SC-14**

- [ ] 91. **Z3 check post-RED (**inline**).** Run `solve check` against post-red-enforcement output contract.

- [ ] 92. **GREEN: Verify single-model-family resilience (**sub-agent**).** Dispatch `test-driven-development --task green` to verify the implementation handles single-model-family environments. This is a verification pass — the architecture change (removing resolve-models dependency) was done in Phases 1-4. If the RED test still fails, remediate. **→ SC-14**

- [ ] 93. **Z3 check GREEN (**inline**).** Run `solve check` against green-phase output contract.

- [ ] 94. **Post-GREEN enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-13, SC-14**

- [ ] 95. **Z3 check post-GREEN (**inline**).** Run `solve check` against post-green-enforcement output contract.

- [ ] 96. **Checkpoint commit (**inline**).** Run `git add -A && git commit -m "Phase 5: Add behavioral tests for SC-13 and SC-14"`. Create checkpoint tag: `opencode-config/checkpoint/1672/phase-5-opencode`. **→ SC-13, SC-14**

- [ ] 97. **Structural checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-13, SC-14**

- [ ] 98. **GREEN doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm both behavioral tests pass with clean-room semantic evaluation. **→ SC-13, SC-14**

- [ ] 99. **VbC (**clean-room**).** Verify SC-13 and SC-14: run both behavioral tests, collect evidence artifacts, dispatch clean-room evaluation. **→ SC-13, SC-14**

#### Phase 5 VbC

- [ ] 99a. **VbC (**clean-room**).** Verify SC-13 (DiMo role chain dispatch) and SC-14 (single-model-family resilience) both pass with behavioral evidence. **→ SC-13, SC-14**

**Concern transition:** Leaving behavioral tests → entering global post-phase (adversarial audit, cross-validate, regression check, review-prep, exec-summary). All 5 phases complete.
