# Phase 6 — Integration + Critical Rules Expansion

**Concern:** Add critical-rules-046a through 046h to 000-critical-rules.md, create full-pipeline integration test, and generalize FABRICATED verdict from content-audit.md to spec-audit.md and plan-fidelity.md.

**Files:**
- `.opencode/guidelines/000-critical-rules.md` — add critical-rules-046a through 046h under existing critical-rules-046
- `.opencode/skills/adversarial-audit/tasks/spec-audit.md` — generalize FABRICATED verdict
- `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md` — generalize FABRICATED verdict
- `.opencode/tests/behaviors/full-pipeline-semantic-audit.sh` — NEW

**SCs:** SC-10 (critical-rules-046a through 046h), SC-11 (Full pipeline integration)

**Dependencies:** Phase 5 complete — all 3 task files have A1-A9 steps.

**Entry conditions:** 000-critical-rules.md exists. All 3 task files have Phase 2-5 changes. Phase 5 checkpoint tag exists.

> **Rework admonishment:** Defective deliverables are discarded and reworked from scratch with loss of all prior work. No partial salvage, no patching around failures. If a step produces defective output, the entire phase's output is discarded and the phase is re-executed from the last checkpoint tag.

> **Cost-frame reformation:** Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS. Document size metrics are NOT valid proxies for implementation complexity. Orchestrator context discipline is operational bookkeeping — it describes how context flows through the pipeline, not how much work is being done.

**Exit conditions:** 000-critical-rules.md has critical-rules-046a through 046h. FABRICATED verdict generalized. Full-pipeline integration test passes.

---

- [ ] 54. **RED: Write full-pipeline-semantic-audit.sh (**sub-agent**).** Create integration test that dispatches a complete spec through all 9 audit dimensions and verifies each dimension returns a structured verdict. Test must FAIL because critical rules and FABRICATED generalization don't exist yet. **→ SC-11**
  - File: `.opencode/tests/behaviors/full-pipeline-semantic-audit.sh`
  - Use `with-test-home` wrapper, `assert_semantic` for behavioral evidence
  - Verify test fails (RED) before proceeding

- [ ] 55. **GREEN: Add critical-rules-046a through 046h to 000-critical-rules.md (**sub-agent**).** Add 8 sub-rules under existing critical-rules-046 in the yaml+symbolic rules block:
  - 046a: Reasoning soundness — auditor accepts broken causal chain
  - 046b: Claim accuracy — auditor accepts unverified factual claim
  - 046c: Blast radius — auditor accepts incomplete Files Affected
  - 046d: Research adequacy — auditor accepts asserted claims without tool-call provenance
  - 046e: Gap analysis — auditor accepts spec with untested boundary conditions
  - 046f: Scope integrity — auditor accepts scope creep or symptom-only fix
  - 046g: Concern separation — auditor accepts spec with multiple root causes
  - 046h: Cross-reference — auditor accepts spec with inaccurate references
  - Each rule: tier 2, HALT action, RE-DISPATCH_WITH_SEMANTIC_DEPTH_INSTRUCTION
  - **→ SC-10**

- [ ] 56. **GREEN: Generalize FABRICATED verdict to spec-audit.md (**sub-agent**).** Add FABRICATED as a new verdict option (alongside PASS/FAIL) in spec-audit.md's evaluation framework. Pattern from content-audit.md: when no source evidence exists for a claim, return FABRICATED verdict. **→ SC-2, SC-11**

- [ ] 57. **GREEN: Generalize FABRICATED verdict to plan-fidelity.md (**sub-agent**).** Add FABRICATED as a new verdict option in plan-fidelity.md's evaluation framework. Pattern from content-audit.md: when no source evidence exists for a claim, return FABRICATED verdict. **→ SC-2, SC-11**

- [ ] 58. **GREEN doublecheck: Verify critical-rules-046a through 046h (**sub-agent**).** Read 000-critical-rules.md and grep for critical-rules-046a through 046h. Confirm all 8 sub-rules exist with correct tier, conditions, and actions. **→ SC-10**

- [ ] 59. **GREEN doublecheck: Verify FABRICATED verdict generalization (**sub-agent**).** Read spec-audit.md and plan-fidelity.md and confirm FABRICATED verdict option is present in evaluation framework. **→ SC-11**

- [ ] 60. **Checkpoint commit (**inline**).** Commit all Phase 6 changes:
  ```bash
  git add .opencode/guidelines/000-critical-rules.md .opencode/skills/adversarial-audit/tasks/spec-audit.md .opencode/skills/adversarial-audit/tasks/plan-fidelity.md .opencode/tests/behaviors/full-pipeline-semantic-audit.sh
  git commit -m "Phase 6: Add critical-rules-046a-046h + FABRICATED generalization + integration test"
  git tag opencode-config/1641/checkpoint/phase-6-.opencode
  ```

- [ ] 61. **Run full-pipeline-semantic-audit.sh (**inline**).** Execute integration test and confirm PASS. **→ SC-11**

- [ ] 62. **Run all 9 behavioral tests (**inline**).** Execute all 9 per-dimension behavioral tests and confirm all PASS. **→ SC-1 through SC-9**

- [ ] 63. **VbC (**clean-room**).** Verify: 000-critical-rules.md has critical-rules-046a through 046h. FABRICATED verdict generalized to spec-audit.md and plan-fidelity.md. Full-pipeline integration test passes. All 9 behavioral tests pass. **→ SC-10, SC-11**

- [ ] 64. **Global post-steps (**inline**).** Collect behavioral evidence artifacts from `./tmp/behavioral-evidence-*/` into `./tmp/1641/artifacts/`. Run lint/format checks on all modified files. Run content-verification tests. Generate exec summary.

#### Phase 6 VbC

- [ ] 63. **VbC (**clean-room**).** Verify: 000-critical-rules.md has critical-rules-046a through 046h. FABRICATED verdict generalized to spec-audit.md and plan-fidelity.md. Full-pipeline integration test passes. All 9 behavioral tests pass. **→ SC-10, SC-11**

**Concern transition:** Leaving integration + critical rules → plan complete. All 11 SCs verified. All 10 behavioral tests pass. All 4 task files modified. 000-critical-rules.md expanded.
