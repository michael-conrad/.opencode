# Phase 3 — Blast Radius (A3) + Research Adequacy (A4)

**Concern:** Add A3 (Blast Radius) and A4 (Research Adequacy) semantic evaluation dimensions to spec-audit.md, plan-fidelity.md, and concern-separation.md.

**Files:**
- `.opencode/skills/adversarial-audit/tasks/spec-audit.md` — add blast radius step + research adequacy step
- `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md` — add blast radius step
- `.opencode/skills/adversarial-audit/tasks/concern-separation.md` — extend CS-6 with srclight_get_dependents procedure
- `.opencode/tests/behaviors/auditor-blast-radius.sh` — NEW
- `.opencode/tests/behaviors/auditor-research-adequacy.sh` — NEW

**SCs:** SC-3 (A3: Blast Radius), SC-4 (A4: Research Adequacy)

**Dependencies:** Phase 2 complete — spec-audit.md has A1 step and A2-extended Step 2.

> **Rework admonishment:** Defective deliverables are discarded and reworked from scratch with loss of all prior work. No partial salvage, no patching around failures. If a step produces defective output, the entire phase's output is discarded and the phase is re-executed from the last checkpoint tag.

> **Cost-frame reformation:** Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS. Document size metrics are NOT valid proxies for implementation complexity. Orchestrator context discipline is operational bookkeeping — it describes how context flows through the pipeline, not how much work is being done.

**Entry conditions:** spec-audit.md, plan-fidelity.md, concern-separation.md exist. Phase 2 checkpoint tag exists.

**Exit conditions:** All 3 task files updated with A3/A4 steps. Both behavioral tests pass.

---

- [ ] 13. **RED: Write auditor-blast-radius.sh (**sub-agent**).** Create behavioral test that dispatches auditor with spec claiming "all files" but listing incomplete set. Test must FAIL because blast radius step doesn't exist yet. **→ SC-3**
  - File: `.opencode/tests/behaviors/auditor-blast-radius.sh`
  - Use `with-test-home` wrapper, `assert_semantic` for behavioral evidence
  - Verify test fails (RED) before proceeding

- [ ] 14. **RED: Write auditor-research-adequacy.sh (**sub-agent**).** Create behavioral test that dispatches auditor with spec where Root Cause has no tool-call provenance. Test must FAIL because research adequacy step doesn't exist yet. **→ SC-4**
  - File: `.opencode/tests/behaviors/auditor-research-adequacy.sh`
  - Use `with-test-home` wrapper, `assert_semantic` for behavioral evidence
  - Verify test fails (RED) before proceeding

- [ ] 15. **GREEN: Add blast radius step to spec-audit.md (**sub-agent**).** Add new step after the A1 step (added in Phase 2) with:
  - Impact completeness — all affected files/components traced via `srclight_get_dependents`
  - Non-code impact — guideline/skill cross-references, behavioral test implications
  - **→ SC-3**

- [ ] 16. **GREEN: Add research adequacy step to spec-audit.md (**sub-agent**).** Add new step after blast radius step with:
  - Evidence provenance — tool-call artifacts for key findings
  - Investigation breadth — alternatives ruled out
  - Edge case discovery — boundary exploration
  - Recency check — commit history reviewed
  - **→ SC-4**

- [ ] 17. **GREEN: Add blast radius step to plan-fidelity.md (**sub-agent**).** Add new step to plan-fidelity.md with:
  - Plan scope verification against spec scope
  - Impact completeness via srclight_get_dependents
  - **→ SC-3**

- [ ] 18. **GREEN: Extend concern-separation.md CS-6 with srclight_get_dependents (**sub-agent**).** Extend CS-6 (Blast radius bounded) evaluation procedure to include `srclight_get_dependents` tool call for verifying phase blast radius claims. **→ SC-3**

- [ ] 19. **GREEN doublecheck: Verify A3/A4 steps in spec-audit.md (**sub-agent**).** Read spec-audit.md and confirm:
  - Blast radius step present with impact completeness and non-code impact checks
  - Research adequacy step present with evidence provenance, investigation breadth, edge case discovery, recency checks
  - **→ SC-3, SC-4**

- [ ] 20. **GREEN doublecheck: Verify A3 step in plan-fidelity.md (**sub-agent**).** Read plan-fidelity.md and confirm blast radius step present with plan scope verification and srclight_get_dependents. **→ SC-3**

- [ ] 21. **GREEN doublecheck: Verify CS-6 extension (**sub-agent**).** Read concern-separation.md and confirm CS-6 procedure includes srclight_get_dependents. **→ SC-3**

- [ ] 22. **Checkpoint commit (**inline**).** Commit all Phase 3 changes:
  ```bash
  git add .opencode/skills/adversarial-audit/tasks/spec-audit.md .opencode/skills/adversarial-audit/tasks/plan-fidelity.md .opencode/skills/adversarial-audit/tasks/concern-separation.md .opencode/tests/behaviors/auditor-blast-radius.sh .opencode/tests/behaviors/auditor-research-adequacy.sh
  git commit -m "Phase 3: Add A3 (Blast Radius) + A4 (Research Adequacy)"
  git tag opencode-config/1641/checkpoint/phase-3-.opencode
  ```

- [ ] 23. **Run behavioral tests (**inline**).** Execute both behavioral tests and confirm PASS. **→ SC-3, SC-4**

- [ ] 24. **VbC (**clean-room**).** Verify: spec-audit.md has blast radius + research adequacy steps. plan-fidelity.md has blast radius step. concern-separation.md CS-6 extended with srclight_get_dependents. Both behavioral tests pass. **→ SC-3, SC-4**

#### Phase 3 VbC

- [ ] 24. **VbC (**clean-room**).** Verify: spec-audit.md has blast radius + research adequacy steps. plan-fidelity.md has blast radius step. concern-separation.md CS-6 extended with srclight_get_dependents. Both behavioral tests pass. **→ SC-3, SC-4**

**Concern transition:** Leaving A3+A4 (blast radius + research) → entering A5+A6+A7 (scope triad: gap analysis, scope creep, scope narrowness). Phase 4 depends on Phase 3's blast radius infrastructure for scope boundary verification.
