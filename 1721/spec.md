## Phase 3 of #1672 — Refactor 15 Task Files

**Depends on:** Phase 1, Phase 2
**SCs:** SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11

### Steps
For each of the 15 task files in `.opencode/skills/adversarial-audit/tasks/`:
1. Remove `audit_phase` from dispatch contracts (reduce to 2 fields: `spec_local_dir`, `artifact_evidence_dir`)
2. Embed DiMo role persona in each task file (no conditionals on `audit_phase`)
3. Add pre-clean step (step 0) to each task checklist — removes only this task's artifact files
4. Specify artifact read/write paths per role: `evidence.yaml`, `reasoning.yaml`, `verdict.yaml`, `judgment.yaml`
5. Specify downstream role read chain: each role reads upstream artifacts
6. Integrate cross-validate as Judger role in each task's checklist
7. Convert dispatch model to sequential role chain per checklist
8. Update remediation sections to specify restart from pre-clean step (step 0)

### Verification
- SC-5: No `audit_phase` references in dispatch contracts
- SC-6: Zero `if audit_phase` or equivalent conditional branches
- SC-7: Artifact paths follow `./tmp/{issue-N}/artifacts/{task-name}/` with role-named files
- SC-8: Downstream role read chain specified
- SC-9: Pre-clean step present, scoped to task directory
- SC-10: Sequential role chain pattern present
- SC-11: Remediation section specifies restart from step 0

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)