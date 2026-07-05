# Phase 5 — Separation of Concerns (A8) + Cross-Reference Completeness (A9)

**Concern:** Add A8 (Separation of Concerns) and A9 (Cross-Reference Completeness) semantic evaluation dimensions to concern-separation.md, spec-audit.md, and plan-fidelity.md.

**Files:**
- `.opencode/skills/adversarial-audit/tasks/concern-separation.md` — extend with SC orthogonality + cross-concern overlap detection
- `.opencode/skills/adversarial-audit/tasks/spec-audit.md` — add cross-reference step
- `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md` — add cross-reference step
- `.opencode/tests/behaviors/auditor-concern-orthogonality.sh` — NEW
- `.opencode/tests/behaviors/auditor-cross-reference-integrity.sh` — NEW

**SCs:** SC-8 (A8: Separation of Concerns), SC-9 (A9: Cross-Reference Completeness)

**Dependencies:** Phase 4 complete — all 3 task files have A5/A6/A7 steps.

> **Rework admonishment:** Defective deliverables are discarded and reworked from scratch with loss of all prior work. No partial salvage, no patching around failures. If a step produces defective output, the entire phase's output is discarded and the phase is re-executed from the last checkpoint tag.

> **Cost-frame reformation:** Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS. Document size metrics are NOT valid proxies for implementation complexity. Orchestrator context discipline is operational bookkeeping — it describes how context flows through the pipeline, not how much work is being done.

**Entry conditions:** spec-audit.md, plan-fidelity.md, concern-separation.md exist with Phase 4 changes. Phase 4 checkpoint tag exists.

**Exit conditions:** All 3 task files updated with A8/A9 steps. Both behavioral tests pass.

---

- [ ] 43. **RED: Write auditor-concern-orthogonality.sh (**sub-agent**).** Create behavioral test that dispatches auditor with spec containing two distinct root causes. Test must FAIL because concern-separation.md doesn't have SC orthogonality check yet. **→ SC-8**
  - File: `.opencode/tests/behaviors/auditor-concern-orthogonality.sh`
  - Use `with-test-home` wrapper, `assert_semantic` for behavioral evidence
  - Verify test fails (RED) before proceeding

- [ ] 44. **RED: Write auditor-cross-reference-integrity.sh (**sub-agent**).** Create behavioral test that dispatches auditor with spec citing external doc that doesn't support the claim. Test must FAIL because cross-reference step doesn't exist yet. **→ SC-9**
  - File: `.opencode/tests/behaviors/auditor-cross-reference-integrity.sh`
  - Use `with-test-home` wrapper, `assert_semantic` for behavioral evidence
  - Verify test fails (RED) before proceeding

- [ ] 45. **GREEN: Extend concern-separation.md with SC orthogonality (**sub-agent**).** Add new step after Step 6 (Verify Boundary Claims) with:
  - SC orthogonality — independent verification that each SC tests exactly one concern
  - Cross-concern overlap detection — shared symbols between phases via srclight_search_symbols
  - **→ SC-8**

- [ ] 46. **GREEN: Add cross-reference step to spec-audit.md (**sub-agent**).** Add new step after scope narrowness step with:
  - Completeness of citation — all relevant context cited
  - Reference sufficiency — cited sources support claims
  - **→ SC-9**

- [ ] 47. **GREEN: Add cross-reference step to plan-fidelity.md (**sub-agent**).** Add new step after scope narrowness step with:
  - Plan reference integrity
  - Citation completeness verification
  - **→ SC-9**

- [ ] 48. **GREEN doublecheck: Verify A8 extension in concern-separation.md (**sub-agent**).** Read concern-separation.md and confirm SC orthogonality and cross-concern overlap detection steps present. **→ SC-8**

- [ ] 49. **GREEN doublecheck: Verify A9 steps (**sub-agent**).** Read spec-audit.md and plan-fidelity.md and confirm cross-reference steps present with citation completeness and reference sufficiency checks. **→ SC-9**

- [ ] 50. **Checkpoint commit (**inline**).** Commit all Phase 5 changes:
  ```bash
  git add .opencode/skills/adversarial-audit/tasks/concern-separation.md .opencode/skills/adversarial-audit/tasks/spec-audit.md .opencode/skills/adversarial-audit/tasks/plan-fidelity.md .opencode/tests/behaviors/auditor-concern-orthogonality.sh .opencode/tests/behaviors/auditor-cross-reference-integrity.sh
  git commit -m "Phase 5: Add A8 (Separation of Concerns) + A9 (Cross-Reference Completeness)"
  git tag opencode-config/1641/checkpoint/phase-5-.opencode
  ```

- [ ] 51. **Run auditor-concern-orthogonality.sh (**inline**).** Execute behavioral test and confirm PASS. **→ SC-8**

- [ ] 52. **Run auditor-cross-reference-integrity.sh (**inline**).** Execute behavioral test and confirm PASS. **→ SC-9**

- [ ] 53. **VbC (**clean-room**).** Verify: concern-separation.md has SC orthogonality + cross-concern overlap detection. spec-audit.md and plan-fidelity.md have cross-reference steps. Both behavioral tests pass. **→ SC-8, SC-9**

#### Phase 5 VbC

- [ ] 53. **VbC (**clean-room**).** Verify: concern-separation.md has SC orthogonality + cross-concern overlap detection. spec-audit.md and plan-fidelity.md have cross-reference steps. Both behavioral tests pass. **→ SC-8, SC-9**

**Concern transition:** Leaving A8+A9 (concerns + references) → entering Phase 6 (integration + critical rules expansion). Phase 6 depends on Phase 5's completed task file changes for the full-pipeline integration test.
