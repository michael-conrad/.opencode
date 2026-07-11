# Phase 3: Writing-Plans Pre-Flight Gates (Create + Update)

**SCs:** SC-10, SC-11, SC-12, SC-15, SC-16
**Dependencies:** Phase 1 (cross-reference file exists)

## Steps

1. Read `.opencode/skills/writing-plans/tasks/create.md` — insert Step 0 pre-flight gate:
   - Dispatch clean-room sub-agent with spec body
   - Sub-agent evaluates same 11 spec dimensions
   - If any FAIL → hard-fail immediately, escalate to user with details of which dimension(s) failed and resolution guidance
   - Add sync header comment

2. Read `.opencode/skills/writing-plans/tasks/update.md` — insert Step 0 pre-flight gate:
   - Same pattern: clean-room sub-agent, 11 spec dimensions, hard-fail + escalation
   - Add sync header comment

3. Verify both pre-flight gates use sub-agent dispatch pattern (not inline evaluation)

## Verification

- SC-10: `grep` for holistic evaluation step in writing-plans create task, positioned before any plan creation steps
- SC-11: `behavioral` — `opencode-cli run` with ambiguous spec → plan writer hard-fails with escalation message
- SC-12: `grep` for sub-agent dispatch pattern in writing-plans pre-flight step
- SC-15: `grep` for holistic evaluation step in writing-plans update task, positioned before any revision steps
- SC-16: `behavioral` — `opencode-cli run` with ambiguous revised spec → revision hard-fails with escalation
