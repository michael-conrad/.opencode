# [PLAN] #1302: Three-Part Phase Structure for Plan Writer

**Spec:** https://github.com/michael-conrad/.opencode/issues/1302
**Pipeline-readiness:** PASS (sc-pipeline-readiness.yaml)
**Plan structure decision:** separate

> **Compliance Requirement:** All steps and sub-steps in this plan MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

## Phase 1: Implement Three-Part Phase Structure

### Concern Boundary

- **Entering:** Plan-structure template design — replacing flat step list with three-part phase structure
- **Departing:** Current spec-audit stage (spec approval, pipeline-readiness)
- **Handoff from:** Pipeline-readiness artifact confirming PASS status and SC summary

### Affected Sub-Folders

- `skills/writing-plans/tasks/create/` — plan-structure.md, create-and-validate.md

### SC References

SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8

### Item Decomposition

| Item | Name | Scope | Deliverable |
|------|------|-------|-------------|
| A | plan-structure.md Step 4 three-part template | Replace flat step list with Pre-RED Common, Per-Item RED+green Chains, Post-RED/green sections | Updated Step 4 in plan-structure.md |
| B | Validation rules in plan-structure.md | Add rules: pre-RED once per phase, post-RED once per phase, RED+green sequential, no section mixing, RED/GREEN separate | Updated validation rules in plan-structure.md |
| C | create-and-validate.md 3-part validation | Add 3 validation rules: pre-RED section check, post-RED section check, chain ordering check, RED/GREEN separation | Updated validation rules in create-and-validate.md |
| D | Behavioral test for three-part structure | Test plan generation produces correct three-part structure | Behavioral enforcement test |

### Dependency Ordering

```
A → B → D
A → C → D
```

---

### Pre-RED Common (runs once per phase, before any items)

- [ ] 1. Coherence gate (**clean-room**) — Verify spec/codebase coherence before any implementation begins → SC-1, SC-2, SC-3, SC-8
  - Run `skill({name: "adversarial-audit"})` — load the skill
  - Execute `adversarial-audit --task coherence-extraction` with evidence-type uplift + substrate classification
  - Verify current plan-structure.md Step 4 flat list vs. spec's three-part requirement
  - Return BLOCKED if spec cannot be implemented as specified
- [ ] 2. Pre-RED baseline (**clean-room**) — Establish baseline state before any changes → SC-1, SC-8
  - Read current `plan-structure.md` and `create-and-validate.md` content
  - Run `srclight_codebase_map` to confirm code index is current
  - SC-ID cross-ref traceability: verify all 8 SCs are coverable
  - Document baseline state in `./tmp/1302/artifacts/baseline-state.yaml`

---

### Per-Item RED+green Chains

#### Item A: Update plan-structure.md Step 4 with three-part template

- [ ] 3. RED (**clean-room**) — Write enforcement test that FAILS (three-part structure not yet in plan-structure.md) → SC-1, SC-6, SC-8
  - RED condition: plan-structure.md Step 4 has flat step list — three-part sections (Pre-RED Common, Per-Item RED+green Chains, Post-RED/green) are absent
  - RED and GREEN are separate steps — this step is RED only; GREEN follows at step 6
  - Write behavioral/structure test verifying absence of the three section headers
  - Test must FAIL (RED) — confirms current state has no three-part structure
- [ ] 4. RED doublecheck (**clean-room**) — Verify RED test correctly diagnoses absence → SC-1
- [ ] 5. RED enforcement gate (**inline**) — Confirm RED test fails as expected → SC-1
- [ ] 6. GREEN (**clean-room**) — Update plan-structure.md Step 4 with three-part phase structure → SC-1, SC-6, SC-8
  - Replace flat step list with three sections: Pre-RED Common, Per-Item RED+green Chains, Post-RED/green
  - Pre-RED Common: coherence gate, pre-RED baseline
  - Per-Item RED+green Chains: each item gets RED → doublecheck → enforcement → GREEN → post-GREEN → structural → doublecheck → commit (RED and GREEN are separate steps)
  - Post-RED/green: VbC, resolve-models, auditor 1, auditor 2, cross-validate, regression check, review prep
  - Add single-phase rule: three sections within ONE phase (SC-8)
  - Add RED/GREEN separate-step specification (SC-6)
- [ ] 7. Post-GREEN enforcement (**inline**) — Verify GREEN test passes with new structure → SC-1, SC-6
- [ ] 8. Checkpoint commit (**clean-room**) — `git commit` with checkpoint tag → SC-1
- [ ] 9. Structural checks (**clean-room**) — Ruff/mdformat/pymarkdown verification → SC-1

#### Item B: Add validation rules to plan-structure.md

- [ ] 10. RED (**clean-room**) — Write enforcement test that FAILS (validation rules absent) → SC-2, SC-3, SC-6
  - RED condition: plan-structure.md lacks rules for pre-RED step non-duplication (SC-2), post-RED step non-duplication (SC-3), sequential chain ordering, section boundary enforcement
  - RED and GREEN are separate steps — this step is RED only; GREEN follows at step 13
  - Test must FAIL — confirms rules are missing
- [ ] 11. RED doublecheck (**clean-room**) — Verify RED test correctly diagnoses absence → SC-2, SC-3
- [ ] 12. RED enforcement gate (**inline**) — Confirm RED test fails → SC-2, SC-3
- [ ] 13. GREEN (**clean-room**) — Add validation rules to plan-structure.md → SC-2, SC-3, SC-6
  - Pre-RED steps appear exactly once per phase
  - Post-RED/green steps appear exactly once per phase
  - RED+green chains are sequential (item N+1 starts after item N's commit)
  - No pre-RED or post-RED steps appear inside item chains
  - RED and GREEN are separate steps within each chain
- [ ] 14. Post-GREEN enforcement (**inline**) — Verify GREEN test passes → SC-2, SC-3
- [ ] 15. Checkpoint commit (**clean-room**) — `git commit` with checkpoint tag → SC-2, SC-3
- [ ] 16. Structural checks (**clean-room**) — Ruff/mdformat/pymarkdown verification → SC-2, SC-3

#### Item C: Update create-and-validate.md validation rules

- [ ] 17. RED (**clean-room**) — Write enforcement test that FAILS (3-part validation rules absent) → SC-4, SC-7
  - RED condition: create-and-validate.md lacks the 3 validation rules for three-part structure (SC-4, SC-7)
  - RED and GREEN are separate steps — this step is RED only; GREEN follows at step 20
  - Test must FAIL — confirms rules are missing
- [ ] 18. RED doublecheck (**clean-room**) — Verify RED test correctly diagnoses absence → SC-4, SC-7
- [ ] 19. RED enforcement gate (**inline**) — Confirm RED test fails → SC-4, SC-7
- [ ] 20. GREEN (**clean-room**) — Add validation rules to create-and-validate.md → SC-4, SC-7
  - Every phase has exactly one Pre-RED Common section
  - Every phase has exactly one Post-RED/green section
  - RED+green chains are between Pre-RED and Post-RED sections
  - Pre-RED steps are not duplicated across items
  - Post-RED steps are not duplicated across items
  - RED and GREEN steps are separate (not combined) within each chain
- [ ] 21. Post-GREEN enforcement (**inline**) — Verify GREEN test passes → SC-4, SC-7
- [ ] 22. Checkpoint commit (**clean-room**) — `git commit` with checkpoint tag → SC-4, SC-7
- [ ] 23. Structural checks (**clean-room**) — Ruff/mdformat/pymarkdown verification → SC-4, SC-7

#### Item D: Behavioral test for three-part structure (SC-5)

- [ ] 24. RED (**clean-room**) — Write behavioral enforcement test that FAILS (three-part structure not yet verifiable in generated plans) → SC-5
  - RED condition: No test exists that verifies a generated plan has correct three-part structure
  - RED and GREEN are separate steps — this step is RED only; GREEN follows at step 27
  - Behavioral test sends a prompt and verifies the agent's response produces correct plan structure
  - Test must FAIL (RED)
- [ ] 25. RED doublecheck (**clean-room**) — Verify RED test correctly diagnoses absence → SC-5
- [ ] 26. RED enforcement gate (**inline**) — Confirm RED test fails → SC-5
- [ ] 27. GREEN (**clean-room**) — Implement behavioral test that verifies three-part structure → SC-5
  - Generate a test plan using the updated plan writer
  - Verify pre-RED steps appear once per phase
  - Verify post-RED steps appear once per phase
  - Verify RED+green chains are between Pre-RED and Post-RED sections
  - Verify RED and GREEN are separate steps within each chain
- [ ] 28. Post-GREEN enforcement (**inline**) — Verify GREEN test passes → SC-5
- [ ] 29. Checkpoint commit (**clean-room**) — `git commit` with checkpoint tag → SC-5
- [ ] 30. Structural checks (**clean-room**) — Ruff/mdformat/pymarkdown verification → SC-5

---

### Post-RED/green (runs once per phase, after all items)

- [ ] 31. VbC — Verification before completion (**clean-room**) — Execute verification against all 8 SCs → SC-1 through SC-8
  - Execute `verification-before-completion --task verify`
  - Verify all 8 SCs against implementation evidence
  - SC-5 requires behavioral evidence: generated plan produces correct three-part structure
- [ ] 32. Resolve models (**inline**) — Select cross-family auditors for adversarial audit → SC-1 through SC-8
  - Run `.opencode/tools/resolve-models`
- [ ] 33. Auditor 1 — spec-audit/plan-fidelity (**clean-room**) — Dispatch first auditor → SC-1 through SC-8
  - Audit the updated plan-structure.md and create-and-validate.md
  - If non-clean-pass: remediate root cause, restart from resolve-models
- [ ] 34. Auditor 2 — spec-audit/plan-fidelity (**clean-room**) — Dispatch second auditor → SC-1 through SC-8
  - Same audit task with second (different-family) model
  - If non-clean-pass: remediate, restart from resolve-models
- [ ] 35. Cross-validate (**clean-room**) — Compare both auditor verdicts, produce consensus → SC-1 through SC-8
- [ ] 36. Regression check (**clean-room**) — Run full test suite, confirm no regressions → SC-1 through SC-8
- [ ] 37. Review prep (**clean-room**) — Prepare PR with compare URL, summary, SC coverage → SC-1 through SC-8
  - PR targets `dev`, single commit, stacked strategy
  - Compare URL: `https://github.com/michael-conrad/.opencode/compare/dev...<branch>`
- [ ] 38. Exec summary (**clean-room**) — Report completion status with SC coverage table → SC-1 through SC-8

> **Compliance Requirement:** All steps and sub-steps in this plan MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.
