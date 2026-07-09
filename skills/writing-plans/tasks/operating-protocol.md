# Writing Plans — 22-Step Pipeline

## Entry Criteria

- Spec is approved (check `approved-for-*` label)
- Authorization scope is `for_plan` or above

## Execution Model

Pipeline steps dispatch to sub-agents via `task()` for independent execution. The orchestrator routes each step to a clean-room sub-agent. Each step is tagged with chain dependency and contract paths.

- [ ] 0. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. A slow correct answer is strictly better than a fast incorrect one. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

### Pipeline Steps

- [ ] 1. Verify spec is approved (check `approved-for-*` label) — read tasks/create.md Step 1 — chain: `none`
- [ ] 2. Research — execute research procedure from tasks/research.md — chain: `step_1`
- [ ] 3. Z3 check — run `solve check` — verify research output contains evidence_artifacts — chain: `step_2`
- [ ] 4. Readiness — execute readiness procedure from tasks/readiness.md — chain: `step_3`
- [ ] 5. Z3 check — run `solve check` — verify readiness output has status PASS — chain: `step_4`
- [ ] 6. Structure — execute structure procedure from tasks/structure.md — chain: `step_5`
- [ ] 7. Z3 check — run `solve check` — verify structure output has phase definitions and dependency contract — chain: `step_6`
- [ ] 8. Solve — execute solve procedure from tasks/solve.md — chain: `step_7`
- [ ] 9. Z3 check — run `solve check` — verify solve output has SAT and SOLVED status — chain: `step_8`
- [ ] 10. Write — execute write procedure from tasks/write.md — chain: `step_9`
- [ ] 11. Clean-room plan generation — execute write procedure with spec body only, no existing plan context — chain: `step_10`
- [ ] 12. Z3 check — run `solve check` — verify clean-room plan output contains clean_room_plan — chain: `step_11`
- [ ] 13. Revisit — execute revisit procedure from tasks/revisit.md — chain: `step_12`
- [ ] 14. Z3 check — run `solve check` — verify revisit output has resolution_status — chain: `step_13`
- [ ] 15. Validate — execute validate procedure from tasks/validate.md — chain: `step_14`
- [ ] 16. Z3 check — run `solve check` — verify validate output has PASS status — chain: `step_15`
- [ ] 17. Audit fidelity — execute audit-fidelity procedure from audit task plan-fidelity — chain: `step_16`
- [ ] 18. Z3 check — run `solve check` — verify audit-fidelity output has PASS — chain: `step_17`
- [ ] 19. Audit concern — execute audit-concern procedure from audit task concern-separation — chain: `step_18`
- [ ] 20. Z3 check — run `solve check` — verify audit-concern output has PASS — chain: `step_19`
- [ ] 21. Completion — execute completion procedure from tasks/completion.md — chain: `step_20`
- [ ] 22. Z3 check — run `solve check` — verify completion output has lifecycle event — chain: `step_21`

### Retroactive Operating Protocol

When the `retroactive` task is dispatched, the pipeline is the same 22-step sequence but with Step 2 (Research) loading the existing spec body as its evidence source rather than performing live-source verification. Steps 3-22 follow the standard pipeline.

## Exit Criteria

- Plan created as a local artifact (index + phase files)
- All Z3 checks pass
- Audit fidelity and concern separation verified
