# Phase 4: Plan-Fidelity + Implementation-Pipeline Pre-Flight Gates

**SCs:** SC-13, SC-14, SC-17, SC-18
**Dependencies:** Phase 1 (cross-reference file exists)

## Steps

1. Read `.opencode/skills/audit/tasks/plan-fidelity.md` — insert Step 0 pre-flight gate:
   - Dispatch clean-room sub-agent with **plan** body (not spec)
   - Sub-agent evaluates 11 plan dimensions (adapted for plans)
   - If any FAIL → hard-fail immediately, escalate to user with details of which dimension(s) failed and resolution guidance
   - Add sync header comment

2. Read `.opencode/skills/implementation-pipeline/tasks/pre-flight.md` (or equivalent entry task) — insert Step 0 pre-flight gate:
   - Dispatch clean-room sub-agent with **plan** body (not spec)
   - Sub-agent evaluates 11 plan dimensions
   - If any FAIL → hard-fail immediately, escalate to user with details
   - Add sync header comment

3. Verify both pre-flight gates evaluate the plan artifact, not the spec

## Verification

- SC-13: `grep` for holistic evaluation step in plan-fidelity.md evaluating the plan, positioned before any audit steps
- SC-14: `behavioral` — `opencode-cli run` with broken plan → plan-fidelity hard-fails with escalation
- SC-17: `grep` for holistic evaluation step in implementation-pipeline task, positioned before any implementation steps
- SC-18: `behavioral` — `opencode-cli run` with broken plan → implementation hard-fails with escalation
