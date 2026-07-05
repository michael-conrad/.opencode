# Task: retroactive

## Purpose

Create a plan for an existing spec that does not yet have one. Uses the same 21-step pipeline as `create` but with the research step loading the existing spec body as its evidence source.

## Operating Protocol — 21-Step Pipeline

Each item is tagged with dispatch scope, chain dependency, and contract paths.

- [ ] 1. (**inline**) Verify spec exists in `.issues/{N}/spec.md` or `{project_root}/{path}/.issues/{N}/spec.md` — chain: `none`
- [ ] 2. (**sub-agent**) Research — Load existing spec body as evidence source — chain: `step_1`
- [ ] 3. (**inline**) Z3 check — `solve check` — verify research output contains evidence_artifacts — chain: `step_2`
- [ ] 4. (**sub-agent**) Readiness — `task(..., prompt: "execute readiness task from writing-plans")` — chain: `step_3`
- [ ] 5. (**inline**) Z3 check — `solve check` — verify readiness output has status PASS — chain: `step_4`
- [ ] 6. (**sub-agent**) Structure — `task(..., prompt: "execute structure task from writing-plans")` — chain: `step_5`
- [ ] 7. (**inline**) Z3 check — `solve check` — verify structure output has phase definitions and dependency contract — chain: `step_6`
- [ ] 8. (**sub-agent**) Solve — `task(..., prompt: "execute solve task from writing-plans")` — chain: `step_7`
- [ ] 9. (**inline**) Z3 check — `solve check` — verify solve output has SAT and SOLVED status — chain: `step_8`
- [ ] 10. (**sub-agent**) Write — `task(..., prompt: "execute write task from writing-plans")` — chain: `step_9`
- [ ] 11. (**inline**) Z3 check — `solve check` — verify write output has plan file path — chain: `step_10`
- [ ] 12. (**sub-agent**) Revisit — `task(..., prompt: "execute revisit task from writing-plans")` — chain: `step_11`
- [ ] 13. (**inline**) Z3 check — `solve check` — verify revisit output has resolution_status — chain: `step_12`
- [ ] 14. (**sub-agent**) Validate — `task(..., prompt: "execute validate task from writing-plans")` — chain: `step_13`
- [ ] 15. (**inline**) Z3 check — `solve check` — verify validate output has PASS status — chain: `step_14`
- [ ] 16. (**sub-agent**) Audit fidelity — `task(..., prompt: "execute audit-fidelity task from writing-plans")` — chain: `step_15`
- [ ] 17. (**inline**) Z3 check — `solve check` — verify audit-fidelity output has PASS — chain: `step_16`
- [ ] 18. (**sub-agent**) Audit concern — `task(..., prompt: "execute audit-concern task from writing-plans")` — chain: `step_17`
- [ ] 19. (**inline**) Z3 check — `solve check` — verify audit-concern output has PASS — chain: `step_18`
- [ ] 20. (**sub-agent**) Completion — `task(..., prompt: "execute completion task from writing-plans")` — chain: `step_19`
- [ ] 21. (**inline**) Z3 check — `solve check` — verify completion output has lifecycle event — chain: `step_20`
