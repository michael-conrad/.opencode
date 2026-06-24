# Task: retroactive

## Purpose

Create a plan for an existing spec that does not yet have one. Uses the same 21-step pipeline as `create` but with the research step loading the existing spec body as its evidence source.

## Operating Protocol — 21-Step Pipeline

Each item is tagged with dispatch scope, chain dependency, and contract paths.

- [ ] 1. [inline] Verify spec exists in `.issues/{N}/spec.md` — chain: `none`
- [ ] 2. [sub-task: research] Load existing spec body as evidence source — chain: `step_1`
- [ ] 3. [z3-check] `solve check` — verify research output contains evidence_artifacts — chain: `step_2`
- [ ] 4. [sub-task: readiness] `task(..., prompt: "execute readiness task from writing-plans")` — input: `contracts/readiness-input-template.yaml`, output: `contracts/readiness-output-template.yaml`, template: `contracts/readiness-input-template.yaml`, chain: `step_3`
- [ ] 5. [z3-check] `solve check` — verify readiness output has status PASS — chain: `step_4`
- [ ] 6. [sub-task: structure] `task(..., prompt: "execute structure task from writing-plans")` — input: `contracts/structure-input-template.yaml`, output: `contracts/structure-output-template.yaml`, template: `contracts/structure-input-template.yaml`, chain: `step_5`
- [ ] 7. [z3-check] `solve check` — verify structure output has phase definitions and dependency contract — chain: `step_6`
- [ ] 8. [sub-task: solve] `task(..., prompt: "execute solve task from writing-plans")` — input: `contracts/solve-input-template.yaml`, output: `contracts/solve-output-template.yaml`, template: `contracts/solve-input-template.yaml`, chain: `step_7`
- [ ] 9. [z3-check] `solve check` — verify solve output has SAT and SOLVED status — chain: `step_8`
- [ ] 10. [sub-task: write] `task(..., prompt: "execute write task from writing-plans")` — input: `contracts/write-input-template.yaml`, output: `contracts/write-output-template.yaml`, template: `contracts/write-input-template.yaml`, chain: `step_9`
- [ ] 11. [z3-check] `solve check` — verify write output has plan file path — chain: `step_10`
- [ ] 12. [sub-task: revisit] `task(..., prompt: "execute revisit task from writing-plans")` — input: `contracts/revisit-input-template.yaml`, output: `contracts/revisit-output-template.yaml`, template: `contracts/revisit-input-template.yaml`, chain: `step_11`
- [ ] 13. [z3-check] `solve check` — verify revisit output has resolution_status — chain: `step_12`
- [ ] 14. [sub-task: validate] `task(..., prompt: "execute validate task from writing-plans")` — input: `contracts/validate-input-template.yaml`, output: `contracts/validate-output-template.yaml`, template: `contracts/validate-input-template.yaml`, chain: `step_13`
- [ ] 15. [z3-check] `solve check` — verify validate output has PASS status — chain: `step_14`
- [ ] 16. [sub-task: audit-fidelity] `task(..., prompt: "execute audit-fidelity task from writing-plans")` — input: `contracts/audit-fidelity-input-template.yaml`, output: `contracts/audit-fidelity-output-template.yaml`, template: `contracts/audit-fidelity-input-template.yaml`, chain: `step_15`
- [ ] 17. [z3-check] `solve check` — verify audit-fidelity output has PASS — chain: `step_16`
- [ ] 18. [sub-task: audit-concern] `task(..., prompt: "execute audit-concern task from writing-plans")` — input: `contracts/audit-concern-input-template.yaml`, output: `contracts/audit-concern-output-template.yaml`, template: `contracts/audit-concern-input-template.yaml`, chain: `step_17`
- [ ] 19. [z3-check] `solve check` — verify audit-concern output has PASS — chain: `step_18`
- [ ] 20. [sub-task: completion] `task(..., prompt: "execute completion task from writing-plans")` — input: `contracts/completion-input-template.yaml`, output: `contracts/completion-output-template.yaml`, template: `contracts/completion-input-template.yaml`, chain: `step_19`
- [ ] 21. [z3-check] `solve check` — verify completion output has lifecycle event — chain: `step_20`
