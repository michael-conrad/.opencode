# Phase 4 — Scope Triad: Gap Analysis (A5) + Scope Creep (A6) + Scope Narrowness (A7)

**Concern:** Add A5 (Gap Analysis), A6 (Scope Creep), and A7 (Scope Narrowness) semantic evaluation dimensions to spec-audit.md, plan-fidelity.md, and concern-separation.md.

**Files:**
- `.opencode/skills/adversarial-audit/tasks/spec-audit.md` — add gap analysis, scope creep, scope narrowness steps
- `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md` — add gap analysis, scope creep, scope narrowness steps
- `.opencode/skills/adversarial-audit/tasks/concern-separation.md` — add scope creep step
- `.opencode/tests/behaviors/auditor-gap-analysis.sh` — NEW
- `.opencode/tests/behaviors/auditor-scope-creep.sh` — NEW
- `.opencode/tests/behaviors/auditor-scope-narrowness.sh` — NEW

**SCs:** SC-5 (A5: Gap Analysis), SC-6 (A6: Scope Creep), SC-7 (A7: Scope Narrowness)

**Dependencies:** Phase 3 complete — all 3 task files have A3/A4 steps.

> **Rework admonishment:** Defective deliverables are discarded and reworked from scratch with loss of all prior work. No partial salvage, no patching around failures. If a step produces defective output, the entire phase's output is discarded and the phase is re-executed from the last checkpoint tag.

> **Cost-frame reformation:** Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS. Document size metrics are NOT valid proxies for implementation complexity. Orchestrator context discipline is operational bookkeeping — it describes how context flows through the pipeline, not how much work is being done.

**Entry conditions:** spec-audit.md, plan-fidelity.md, concern-separation.md exist with Phase 3 changes. Phase 3 checkpoint tag exists.

**Exit conditions:** All 3 task files updated with A5/A6/A7 steps. All 3 behavioral tests pass.

---

- [ ] 25. **RED: Write auditor-gap-analysis.sh (**sub-agent**).** Create behavioral test that dispatches auditor with spec that appears complete but has 2 untested boundary conditions. Test must FAIL because gap analysis step doesn't exist yet. **→ SC-5**
  - File: `.opencode/tests/behaviors/auditor-gap-analysis.sh`
  - Use `with-test-home` wrapper, `assert_semantic` for behavioral evidence
  - Verify test fails (RED) before proceeding

- [ ] 26. **RED: Write auditor-scope-creep.sh (**sub-agent**).** Create behavioral test that dispatches auditor with spec where Fix Approach has element with no Root Cause traceability. Test must FAIL because scope creep step doesn't exist yet. **→ SC-6**
  - File: `.opencode/tests/behaviors/auditor-scope-creep.sh`
  - Use `with-test-home` wrapper, `assert_semantic` for behavioral evidence
  - Verify test fails (RED) before proceeding

- [ ] 27. **RED: Write auditor-scope-narrowness.sh (**sub-agent**).** Create behavioral test that dispatches auditor with spec that fixes symptom rather than root cause. Test must FAIL because scope narrowness step doesn't exist yet. **→ SC-7**
  - File: `.opencode/tests/behaviors/auditor-scope-narrowness.sh`
  - Use `with-test-home` wrapper, `assert_semantic` for behavioral evidence
  - Verify test fails (RED) before proceeding

- [ ] 28. **GREEN: Add gap analysis step to spec-audit.md (**sub-agent**).** Add new step after research adequacy step with:
  - Missing coverage — untested boundary conditions
  - Implicit conditions — preconditions not stated
  - **→ SC-5**

- [ ] 29. **GREEN: Add scope creep step to spec-audit.md (**sub-agent**).** Add new step after gap analysis step with:
  - Traceability enforcement — every Fix element traces to Root Cause
  - Proportionality — fix scope vs blast radius aligned
  - **→ SC-6**

- [ ] 30. **GREEN: Add scope narrowness step to spec-audit.md (**sub-agent**).** Add new step after scope creep step with:
  - Root cause depth — 5-Whys test
  - Systemic implication — problem exists elsewhere?
  - Minimum viable scope — not over-scoped
  - **→ SC-7**

- [ ] 31. **GREEN: Add gap analysis step to plan-fidelity.md (**sub-agent**).** Add new step with:
  - Plan completeness against spec
  - Missing coverage detection
  - **→ SC-5**

- [ ] 32. **GREEN: Add scope creep step to plan-fidelity.md (**sub-agent**).** Add new step with:
  - Plan scope boundary verification
  - Fix element traceability to Root Cause
  - **→ SC-6**

- [ ] 33. **GREEN: Add scope narrowness step to plan-fidelity.md (**sub-agent**).** Add new step with:
  - Plan root cause depth
  - Symptom vs root cause detection
  - **→ SC-7**

- [ ] 34. **GREEN: Add scope creep step to concern-separation.md (**sub-agent**).** Add new step with:
  - Cross-concern scope detection
  - Phase boundary verification
  - **→ SC-6**

- [ ] 35. **GREEN doublecheck: Verify A5/A6/A7 steps in spec-audit.md (**sub-agent**).** Read spec-audit.md and confirm gap analysis, scope creep, and scope narrowness steps present with all required checks. **→ SC-5, SC-6, SC-7**

- [ ] 36. **GREEN doublecheck: Verify A5/A6/A7 steps in plan-fidelity.md (**sub-agent**).** Read plan-fidelity.md and confirm gap analysis, scope creep, and scope narrowness steps present. **→ SC-5, SC-6, SC-7**

- [ ] 37. **GREEN doublecheck: Verify A6 step in concern-separation.md (**sub-agent**).** Read concern-separation.md and confirm scope creep step present with cross-concern scope detection. **→ SC-6**

- [ ] 38. **Checkpoint commit (**inline**).** Commit all Phase 4 changes:
  ```bash
  git add .opencode/skills/adversarial-audit/tasks/spec-audit.md .opencode/skills/adversarial-audit/tasks/plan-fidelity.md .opencode/skills/adversarial-audit/tasks/concern-separation.md .opencode/tests/behaviors/auditor-gap-analysis.sh .opencode/tests/behaviors/auditor-scope-creep.sh .opencode/tests/behaviors/auditor-scope-narrowness.sh
  git commit -m "Phase 4: Add A5 (Gap Analysis) + A6 (Scope Creep) + A7 (Scope Narrowness)"
  git tag opencode-config/1641/checkpoint/phase-4-.opencode
  ```

- [ ] 39. **Run auditor-gap-analysis.sh (**inline**).** Execute behavioral test and confirm PASS. **→ SC-5**

- [ ] 40. **Run auditor-scope-creep.sh (**inline**).** Execute behavioral test and confirm PASS. **→ SC-6**

- [ ] 41. **Run auditor-scope-narrowness.sh (**inline**).** Execute behavioral test and confirm PASS. **→ SC-7**

- [ ] 42. **VbC (**clean-room**).** Verify: all 3 task files have A5/A6/A7 steps. All 3 behavioral tests pass. **→ SC-5, SC-6, SC-7**

#### Phase 4 VbC

- [ ] 42. **VbC (**clean-room**).** Verify: all 3 task files have A5/A6/A7 steps. All 3 behavioral tests pass. **→ SC-5, SC-6, SC-7**

**Concern transition:** Leaving scope triad (gap analysis, scope creep, scope narrowness) → entering A8+A9 (separation of concerns + cross-reference completeness). Phase 5 depends on Phase 4's scope infrastructure for concern orthogonality and cross-reference verification.
