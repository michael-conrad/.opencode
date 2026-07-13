# Phase 1: Restructure `writing-plans/tasks/create.md`

**SCs:** SC-1, SC-2
**Files:** `skills/writing-plans/tasks/create.md`, `skills/writing-plans/SKILL.md`
**Chain dependency:** `none` (first phase)

## Steps

### Step 1.1: Identify sub-agent dispatch instructions in create.md

Read `skills/writing-plans/tasks/create.md` and identify all instructions that tell a sub-agent to dispatch another sub-agent via `task()`. These include:
- Step 0: "dispatch a clean-room sub-agent to evaluate the spec" — this is a sub-agent dispatch instruction
- Any other `task()` or "dispatch" instructions in the file

**Dispatch:** `sub-agent` — reads create.md, produces list of dispatch instructions to remove
**Evidence:** List of line numbers and instruction text

### Step 1.2: Remove sub-agent dispatch instructions from create.md

For each identified instruction:
1. Remove the `task()` call or "dispatch" language
2. Replace with a reference to the artifact or result the sub-agent should expect to receive from the orchestrator
3. Preserve all other content (purpose, template sections, guidance, escape hatch prohibition)

**Dispatch:** `sub-agent` — edits create.md
**Evidence:** Diff of changes

### Step 1.3: Update writing-plans SKILL.md Trigger Dispatch Table

Add orchestrator-level dispatch entries for the sub-steps that were previously dispatched by sub-agents. The Trigger Dispatch Table must now include entries for:
- Holistic spec evaluation (previously Step 0 sub-agent dispatch)
- Any other sub-steps that were moved

**Dispatch:** `sub-agent` — edits SKILL.md
**Evidence:** Updated Trigger Dispatch Table

### Step 1.4: Verify SC-1 and SC-2 compliance

- **SC-1:** `grep` for "dispatch.*sub-agent" or "task()" in create.md — must return no matches
- **SC-2:** File read confirms no sub-agent dispatch instructions remain

**Dispatch:** `sub-agent` — runs verification
**Evidence:** grep output and file read confirmation

## SC-to-Step Traceability

| SC ID | Criterion | Step(s) |
|-------|-----------|---------|
| SC-1 | No task file contains sub-agent dispatch instructions | 1.1, 1.2, 1.4 |
| SC-2 | `writing-plans/tasks/create.md` restructured | 1.1, 1.2, 1.3, 1.4 |

## Safety/Rollback

- **Destructive operations:** None — file edits only
- **Rollback plan:** `git checkout feature/1915-sub-agent-dispatch-architecture -- skills/writing-plans/tasks/create.md skills/writing-plans/SKILL.md`
- **Data loss risk:** None
