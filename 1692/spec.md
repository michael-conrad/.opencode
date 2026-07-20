## Phase 2: Dispatch Table Fixes

**Parent:** #1673

Expand Tasks table, fix Invocation section, expand Trigger Dispatch Table in spec-creation SKILL.md.

**SCs:** SC-5, SC-6, SC-7

**Files:**
- `.opencode/skills/spec-creation/SKILL.md` — Tasks table, Invocation section, Trigger Dispatch Table

**Changes:**
- Expand Tasks table to list all 8 task files on disk
- Update Invocation: change canonical dispatch to `task(..., prompt: "execute write task from spec-creation")`
- Expand Trigger Dispatch Table to include all 7 sub-tasks: `requirements`, `decompose`, `traceability`, `pipeline-readiness-gate`, `risk`, `write`, `completion`

**Dependencies:** None (independent)