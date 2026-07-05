# Phase 2 — Reasoning Soundness (A1) + Claim Accuracy (A2)

**Concern:** Add A1 (Reasoning Soundness) and A2 (Claim Accuracy) semantic evaluation dimensions to spec-audit.md.

**Files:**
- `.opencode/skills/adversarial-audit/tasks/spec-audit.md` — add new step after Step 3, before Step 3a; extend Step 2; add SC-REASONING and SC-CLAIM criteria to evaluation table
- `.opencode/tests/behaviors/auditor-reasoning-soundness.sh` — NEW
- `.opencode/tests/behaviors/auditor-claim-accuracy.sh` — NEW

**SCs:** SC-1 (A1: Reasoning Soundness), SC-2 (A2: Claim Accuracy)

**Dependencies:** Phase 1 (Foundation) complete — no work needed.

**Entry conditions:** spec-audit.md exists at `.opencode/skills/adversarial-audit/tasks/spec-audit.md`. Behavioral test directory exists at `.opencode/tests/behaviors/`.

> **Rework admonishment:** Defective deliverables are discarded and reworked from scratch with loss of all prior work. No partial salvage, no patching around failures. If a step produces defective output, the entire phase's output is discarded and the phase is re-executed from the last checkpoint tag.

> **Cost-frame reformation:** Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS. Document size metrics are NOT valid proxies for implementation complexity. Orchestrator context discipline is operational bookkeeping — it describes how context flows through the pipeline, not how much work is being done.

**Exit conditions:** spec-audit.md has A1 step with 3 semantic checks (causal chain, SC traceability, contradiction detection) + A2-extended Step 2 (FABRICATED verdict, negation verification, interface contract verification) + SC-REASONING and SC-CLAIM criteria in evaluation table. Both behavioral tests pass.

---

- [ ] 1. **RED: Write auditor-reasoning-soundness.sh (**sub-agent**).** Create behavioral test that dispatches auditor with spec where Fix Approach doesn't follow from Root Cause (broken causal chain). Test must FAIL because spec-audit.md doesn't have A1 step yet. **→ SC-1**
  - File: `.opencode/tests/behaviors/auditor-reasoning-soundness.sh`
  - Use `with-test-home` wrapper, `assert_semantic` for behavioral evidence
  - Verify test fails (RED) before proceeding

- [ ] 2. **RED: Write auditor-claim-accuracy.sh (**sub-agent**).** Create behavioral test that dispatches auditor with spec containing fabricated numerical claim. Test must FAIL because spec-audit.md Step 2 doesn't have FABRICATED verdict yet. **→ SC-2**
  - File: `.opencode/tests/behaviors/auditor-claim-accuracy.sh`
  - Use `with-test-home` wrapper, `assert_semantic` for behavioral evidence
  - Verify test fails (RED) before proceeding

- [ ] 3. **GREEN: Add A1 step to spec-audit.md (**sub-agent**).** Add new step after Step 3 (Build Evaluation Criteria), before Step 3a (Evaluate Semantic Auditor Criteria). Step includes 3 semantic checks:
  - (1.1) Causal chain validity — M:N mapping between Root Cause and Fix Approach, completeness, sufficiency, causal dependency assumptions
  - (1.2) SC traceability — each SC traces to at least one Root Cause element, each Root Cause tested by at least one SC, achievement assumptions
  - (1.3) Contradiction detection — explicit, implicit, and scope contradictions
  - **→ SC-1**

- [ ] 4. **GREEN: Add SC-REASONING criteria to evaluation table (**sub-agent**).** Add SC-REASONING criteria row to the evaluation table in spec-audit.md Step 3. Include evidence type, description, and expected result. **→ SC-1**

- [ ] 5. **GREEN: Extend spec-audit.md Step 2 with A2 checks (**sub-agent**).** Extend Step 2 (Verify Documentation Sources) with:
  - (a) FABRICATED verdict meta-rule when no source evidence exists for a claim
  - (b) Negation verification via exhaustive search (not assumed from absence)
  - (c) Interface contract verification via `srclight_get_signature`
  - **→ SC-2**

- [ ] 6. **GREEN: Add SC-CLAIM criteria to evaluation table (**sub-agent**).** Add SC-CLAIM criteria row to the evaluation table in spec-audit.md Step 3. Include evidence type, description, and expected result. **→ SC-2**

- [ ] 7. **GREEN doublecheck: Verify A1 step structure (**sub-agent**).** Read spec-audit.md and confirm:
  - A1 step exists after Step 3, before Step 3a
  - All 3 semantic checks present (causal chain, SC traceability, contradiction detection)
  - SC-REASONING criteria in evaluation table
  - **→ SC-1**

- [ ] 8. **GREEN doublecheck: Verify A2 extension (**sub-agent**).** Read spec-audit.md Step 2 and confirm:
  - FABRICATED verdict meta-rule present
  - Negation verification procedure present
  - Interface contract verification via srclight_get_signature present
  - SC-CLAIM criteria in evaluation table
  - **→ SC-2**

- [ ] 9. **Checkpoint commit (**inline**).** Commit all Phase 2 changes:
  ```bash
  git add .opencode/skills/adversarial-audit/tasks/spec-audit.md .opencode/tests/behaviors/auditor-reasoning-soundness.sh .opencode/tests/behaviors/auditor-claim-accuracy.sh
  git commit -m "Phase 2: Add A1 (Reasoning Soundness) + A2 (Claim Accuracy) to spec-audit.md"
  git tag opencode-config/1641/checkpoint/phase-2-.opencode
  ```

- [ ] 10. **Run auditor-reasoning-soundness.sh (**inline**).** Execute behavioral test and confirm PASS. **→ SC-1**

- [ ] 11. **Run auditor-claim-accuracy.sh (**inline**).** Execute behavioral test and confirm PASS. **→ SC-2**

- [ ] 12. **VbC (**clean-room**).** Verify: spec-audit.md has A1 step with 3 semantic checks (causal chain, SC traceability, contradiction detection) + A2-extended Step 2 (FABRICATED verdict, negation verification, interface contract verification) + SC-REASONING and SC-CLAIM criteria in evaluation table. Both behavioral tests pass. **→ SC-1, SC-2**

#### Phase 2 VbC

- [ ] 12. **VbC (**clean-room**).** Verify: spec-audit.md has A1 step with 3 semantic checks (causal chain, SC traceability, contradiction detection) + A2-extended Step 2 (FABRICATED verdict, negation verification, interface contract verification) + SC-REASONING and SC-CLAIM criteria in evaluation table. Both behavioral tests pass. **→ SC-1, SC-2**

**Concern transition:** Leaving A1+A2 (spec-audit.md only) → entering A3+A4 (spec-audit.md + plan-fidelity.md + concern-separation.md). Phase 3 depends on Phase 2's spec-audit.md changes as the foundation for blast radius and research adequacy steps.
