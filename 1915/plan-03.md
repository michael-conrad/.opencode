# Phase 3: Restructure `spec-creation/tasks/create.md`

**SCs:** SC-1, SC-4
**Files:** `skills/spec-creation/tasks/create.md`, `skills/spec-creation/SKILL.md`
**Chain dependency:** `phase_2` (same skill, different task file)

## Steps

### Step 3.1: Identify sub-agent dispatch instructions in create.md

Read `skills/spec-creation/tasks/create.md` and identify all instructions that tell a sub-agent to dispatch verification sub-agents.

**Dispatch:** `sub-agent` — reads create.md, produces list of dispatch instructions
**Evidence:** List of line numbers and instruction text

### Step 3.2: Remove verification sub-agent dispatch instructions

For each identified instruction:
1. Remove the `task()` call or "dispatch" language
2. Replace with a reference to the verification result the sub-agent should expect from the orchestrator
3. Preserve all other content

**Dispatch:** `sub-agent` — edits create.md
**Evidence:** Diff of changes

### Step 3.3: Update spec-creation SKILL.md Trigger Dispatch Table

Add orchestrator-level dispatch entries for verification sub-agents that were previously dispatched from within create.md.

**Dispatch:** `sub-agent` — edits SKILL.md
**Evidence:** Updated Trigger Dispatch Table

### Step 3.4: Verify SC-1 and SC-4 compliance

- **SC-1:** `grep` for "dispatch.*sub-agent" or "task()" in create.md — must return no matches
- **SC-4:** File read confirms no sub-agent dispatch instructions remain

**Dispatch:** `sub-agent` — runs verification
**Evidence:** grep output and file read confirmation

## SC-to-Step Traceability

| SC ID | Criterion | Step(s) |
|-------|-----------|---------|
| SC-1 | No task file contains sub-agent dispatch instructions | 3.1, 3.2, 3.4 |
| SC-4 | `spec-creation/tasks/create.md` restructured | 3.1, 3.2, 3.3, 3.4 |

## Safety/Rollback

- **Destructive operations:** None — file edits only
- **Rollback plan:** `git checkout feature/1915-sub-agent-dispatch-architecture -- skills/spec-creation/tasks/create.md skills/spec-creation/SKILL.md`
- **Data loss risk:** None
