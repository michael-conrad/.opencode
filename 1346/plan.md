# Plan: [SPEC] Plan file format — master ToC + per-phase sub-plans with dispatch contracts

**Issue:** #1346
**Authorization scope:** `for_plan` (auto-approved per cascade matrix)

## Phase Dependency Graph

```
Phase 1 (Master ToC) ──────────► Phase 2 (Sub-Plan Format) ──► Phase 4 (pipeline update)
                    │                                          │
                    ├──► Phase 3 (Work State File)              │
                    │                                          │
                    └──────────────────────────────────────────┴──► Phase 5 (writing-plans update)
```

| Phase | Concern | Depends On | Exit Criteria |
|-------|---------|------------|---------------|
| 1 | Master ToC format definition | None | `plan-structure.md` defines `plan.md` routing index with phase table (including Depends On column), exit criteria per phase, ≤50 line limit, and orchestrator-loadable without sub-plan access |
| 2 | Sub-plan file format definition | Phase 1 | `plan-structure.md` defines `plan-phase-N.md` with three-section structure, dispatch contracts, checkbox format, self-contained constraint, `commits: true`, checkpoint tag header, and checkpoint tag creation step |
| 3 | Work state file format definition | Phase 1 | `plan-structure.md` defines `.tmp/work-state-NNN.yaml` with required fields, Z3-verifiable contract fields, and session-resilient disk persistence |
| 4 | implementation-pipeline skill update | Phase 2 | `implementation-pipeline/SKILL.md` dispatch table includes checkpoint-tag-create step; Z3 contract includes valid transitions; no implicit steps remain |
| 5 | writing-plans skill update | Phase 2 | `writing-plans` skill produces master ToC + sub-plans with dispatch contracts and work state file; `plan-structure.md` and `create-and-validate.md` reference new format |

---

## Phase 1 — Master ToC Format

**Concern:** Define the `plan.md` routing index file format.
**Depends on:** None
**Affected files:** `.opencode/skills/writing-plans/tasks/create/plan-structure.md` (format reference)
**Dispatch context:** `{ issue_number: 1346, phase: 1 }`

#### Pre-RED Common

- [ ] 1. `dispatch: verification-enforcement verify { issue_number: 1346, phase: 1 }`
- [ ] 2. `dispatch: issue-review read { issue_number: 1346, phase: 1 }`
- [ ] 3. `dispatch: pre-analysis discover { issue_number: 1346, phase: 1 }`

#### Per-Item RED/GREEN Chains

- [ ] 4. `dispatch: writing-plans update-plan-structure { issue_number: 1346, phase: 1, item: "plan-md-routing-index" }`
- [ ] 5. `check: solve check --state-path .tmp/work-state-1346.yaml --contract-path .opencode/.issues/1346/dependency-contract.yaml --expected-phase 1 --expected-item plan-md-routing-index`
- [ ] 6. `dispatch: writing-plans update-plan-structure { issue_number: 1346, phase: 1, item: "orchestrator-loadable-toc" }`
- [ ] 7. `check: solve check --state-path .tmp/work-state-1346.yaml --contract-path .opencode/.issues/1346/dependency-contract.yaml --expected-phase 1 --expected-item orchestrator-loadable-toc`

#### Post-RED/green

- [ ] 8. `dispatch: completeness-gate check { issue_number: 1346, phase: 1 }`
- [ ] 9. `dispatch: adversarial-audit audit { issue_number: 1346, phase: 1 }`
- [ ] 10. `inline: git tag opencode-config/checkpoint/1346/phase-1-opencode`
- [ ] 11. `inline: git add .opencode/skills/writing-plans/tasks/create/plan-structure.md && git commit -m "Phase 1: Master ToC format"`
- [ ] 12. `dispatch: completion-core report { issue_number: 1346, phase: 1 }`

---

## Phase 2 — Sub-Plan File Format

**Concern:** Define the `plan-phase-N.md` structure with dispatch contracts, commit boundaries, and checkpoint tag creation.
**Depends on:** Phase 1
**Affected files:** `.opencode/skills/writing-plans/tasks/create/plan-structure.md` (sub-plan format section)
**Dispatch context:** `{ issue_number: 1346, phase: 2 }`

#### Pre-RED Common

- [ ] 13. `dispatch: verification-enforcement verify { issue_number: 1346, phase: 2 }`
- [ ] 14. `dispatch: issue-review read { issue_number: 1346, phase: 2 }`
- [ ] 15. `dispatch: pre-analysis discover { issue_number: 1346, phase: 2 }`

#### Per-Item RED/GREEN Chains

- [ ] 16. `dispatch: writing-plans update-plan-structure { issue_number: 1346, phase: 2, item: "sub-plan-format" }`
- [ ] 17. `check: solve check --state-path .tmp/work-state-1346.yaml --contract-path .opencode/.issues/1346/dependency-contract.yaml --expected-phase 2 --expected-item sub-plan-format`

#### Post-RED/green

- [ ] 18. `dispatch: completeness-gate check { issue_number: 1346, phase: 2 }`
- [ ] 19. `dispatch: adversarial-audit audit { issue_number: 1346, phase: 2 }`
- [ ] 20. `inline: git tag opencode-config/checkpoint/1346/phase-2-opencode`
- [ ] 21. `inline: git add .opencode/skills/writing-plans/tasks/create/plan-structure.md && git commit -m "Phase 2: Sub-plan file format"`
- [ ] 22. `dispatch: completion-core report { issue_number: 1346, phase: 2 }`

---

## Phase 3 — Work State File

**Concern:** Define the `.tmp/work-state-NNN.yaml` format with Z3-verifiable contracts.
**Depends on:** Phase 1
**Affected files:** `.opencode/skills/writing-plans/tasks/create/plan-structure.md` (work state section)
**Dispatch context:** `{ issue_number: 1346, phase: 3 }`

#### Pre-RED Common

- [ ] 23. `dispatch: verification-enforcement verify { issue_number: 1346, phase: 3 }`
- [ ] 24. `dispatch: issue-review read { issue_number: 1346, phase: 3 }`
- [ ] 25. `dispatch: pre-analysis discover { issue_number: 1346, phase: 3 }`

#### Per-Item RED/GREEN Chains

- [ ] 26. `dispatch: writing-plans update-plan-structure { issue_number: 1346, phase: 3, item: "work-state-format" }`
- [ ] 27. `check: solve check --state-path .tmp/work-state-1346.yaml --contract-path .opencode/.issues/1346/dependency-contract.yaml --expected-phase 3 --expected-item work-state-format`

#### Post-RED/green

- [ ] 28. `dispatch: completeness-gate check { issue_number: 1346, phase: 3 }`
- [ ] 29. `dispatch: adversarial-audit audit { issue_number: 1346, phase: 3 }`
- [ ] 30. `inline: git tag opencode-config/checkpoint/1346/phase-3-opencode`
- [ ] 31. `inline: git add .opencode/skills/writing-plans/tasks/create/plan-structure.md && git commit -m "Phase 3: Work state file format"`
- [ ] 32. `dispatch: completion-core report { issue_number: 1346, phase: 3 }`

---

## Phase 4 — implementation-pipeline Skill Update

**Concern:** Audit and update the implementation-pipeline dispatch routing table to include all mandatory steps as explicit entries.
**Depends on:** Phase 2
**Affected files:** `.opencode/skills/implementation-pipeline/SKILL.md` (dispatch routing table), `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md` (inline bash procedures)
**Dispatch context:** `{ issue_number: 1346, phase: 4 }`

#### Pre-RED Common

- [ ] 33. `dispatch: verification-enforcement verify { issue_number: 1346, phase: 4 }`
- [ ] 34. `dispatch: issue-review read { issue_number: 1346, phase: 4 }`
- [ ] 35. `dispatch: pre-analysis discover { issue_number: 1346, phase: 4 }`

#### Per-Item RED/GREEN Chains

- [ ] 36. `dispatch: implementation-pipeline update-dispatch-table { issue_number: 1346, phase: 4, item: "checkpoint-tag-in-dispatch-table" }`
- [ ] 37. `check: solve check --state-path .tmp/work-state-1346.yaml --contract-path .opencode/.issues/1346/dependency-contract.yaml --expected-phase 4 --expected-item checkpoint-tag-in-dispatch-table`
- [ ] 38. `dispatch: implementation-pipeline update-z3-contract { issue_number: 1346, phase: 4, item: "z3-state-machine-transitions" }`
- [ ] 39. `check: solve check --state-path .tmp/work-state-1346.yaml --contract-path .opencode/.issues/1346/dependency-contract.yaml --expected-phase 4 --expected-item z3-state-machine-transitions`
- [ ] 40. `dispatch: implementation-pipeline audit-implicit-steps { issue_number: 1346, phase: 4, item: "implicit-steps-audit" }`
- [ ] 41. `check: solve check --state-path .tmp/work-state-1346.yaml --contract-path .opencode/.issues/1346/dependency-contract.yaml --expected-phase 4 --expected-item implicit-steps-audit`

#### Post-RED/green

- [ ] 42. `dispatch: completeness-gate check { issue_number: 1346, phase: 4 }`
- [ ] 43. `dispatch: adversarial-audit audit { issue_number: 1346, phase: 4 }`
- [ ] 44. `inline: git tag opencode-config/checkpoint/1346/phase-4-opencode`
- [ ] 45. `inline: git add .opencode/skills/implementation-pipeline/SKILL.md .opencode/skills/implementation-pipeline/tasks/pipeline-executor.md && git commit -m "Phase 4: implementation-pipeline skill update"`
- [ ] 46. `dispatch: completion-core report { issue_number: 1346, phase: 4 }`

---

## Phase 5 — writing-plans Skill Changes

**Concern:** Update the writing-plans skill to produce the new multi-file format (master ToC + sub-plans) instead of the single-file format.
**Depends on:** Phase 2
**Affected files:** `.opencode/skills/writing-plans/SKILL.md`, `.opencode/skills/writing-plans/tasks/create.md`, `.opencode/skills/writing-plans/tasks/create/plan-structure.md`, `.opencode/skills/writing-plans/tasks/create/create-and-validate.md`
**Dispatch context:** `{ issue_number: 1346, phase: 5 }`

#### Pre-RED Common

- [ ] 47. `dispatch: verification-enforcement verify { issue_number: 1346, phase: 5 }`
- [ ] 48. `dispatch: issue-review read { issue_number: 1346, phase: 5 }`
- [ ] 49. `dispatch: pre-analysis discover { issue_number: 1346, phase: 5 }`

#### Per-Item RED/GREEN Chains

- [ ] 50. `dispatch: writing-plans update-skill-md { issue_number: 1346, phase: 5, item: "plan-model" }`
- [ ] 51. `check: solve check --state-path .tmp/work-state-1346.yaml --contract-path .opencode/.issues/1346/dependency-contract.yaml --expected-phase 5 --expected-item plan-model`
- [ ] 52. `dispatch: writing-plans update-create-and-validate { issue_number: 1346, phase: 5, item: "multi-file-output" }`
- [ ] 53. `check: solve check --state-path .tmp/work-state-1346.yaml --contract-path .opencode/.issues/1346/dependency-contract.yaml --expected-phase 5 --expected-item multi-file-output`

#### Post-RED/green

- [ ] 54. `dispatch: completeness-gate check { issue_number: 1346, phase: 5 }`
- [ ] 55. `dispatch: adversarial-audit audit { issue_number: 1346, phase: 5 }`
- [ ] 56. `inline: git tag opencode-config/checkpoint/1346/phase-5-opencode`
- [ ] 57. `inline: git add .opencode/skills/writing-plans/SKILL.md .opencode/skills/writing-plans/tasks/create.md .opencode/skills/writing-plans/tasks/create/plan-structure.md .opencode/skills/writing-plans/tasks/create/create-and-validate.md && git commit -m "Phase 5: writing-plans skill changes"`
- [ ] 58. `dispatch: completion-core report { issue_number: 1346, phase: 5 }`
