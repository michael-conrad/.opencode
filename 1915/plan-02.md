# Phase 2: Restructure `spec-creation/tasks/analytical-artifacts.md`

**SCs:** SC-1, SC-3
**Files:** `skills/spec-creation/tasks/analytical-artifacts.md`, `skills/spec-creation/SKILL.md`
**Chain dependency:** `phase_1` (same pattern, independent skill)

## Steps

### Step 2.1: Identify sub-agent dispatch instructions in analytical-artifacts.md

Read `skills/spec-creation/tasks/analytical-artifacts.md` and identify all instructions that tell a sub-agent to dispatch another sub-agent. The file currently has 7 sub-steps, each marked as `(**sub-agent**)` — these are the dispatch instructions to remove.

**Dispatch:** `sub-agent` — reads analytical-artifacts.md, produces list of dispatch instructions
**Evidence:** List of line numbers and instruction text

### Step 2.2: Remove sub-agent dispatch instructions from analytical-artifacts.md

For each identified instruction:
1. Remove the `(**sub-agent**)` marker and "dispatch" language
2. Replace with a reference to the artifact the sub-agent should expect to receive from the orchestrator
3. Preserve all artifact schemas, evidence type declarations, and generation logic

**Dispatch:** `sub-agent` — edits analytical-artifacts.md
**Evidence:** Diff of changes

### Step 2.3: Update spec-creation SKILL.md Trigger Dispatch Table

Add orchestrator-level dispatch entries for all 7 artifact sub-agents (blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, testability-assessment).

**Dispatch:** `sub-agent` — edits SKILL.md
**Evidence:** Updated Trigger Dispatch Table

### Step 2.4: Verify SC-1 and SC-3 compliance

- **SC-1:** `grep` for "dispatch.*sub-agent" or "task()" in analytical-artifacts.md — must return no matches
- **SC-3:** File read confirms no sub-agent dispatch instructions remain

**Dispatch:** `sub-agent` — runs verification
**Evidence:** grep output and file read confirmation

## SC-to-Step Traceability

| SC ID | Criterion | Step(s) |
|-------|-----------|---------|
| SC-1 | No task file contains sub-agent dispatch instructions | 2.1, 2.2, 2.4 |
| SC-3 | `analytical-artifacts.md` restructured | 2.1, 2.2, 2.3, 2.4 |

## Safety/Rollback

- **Destructive operations:** None — file edits only
- **Rollback plan:** `git checkout feature/1915-sub-agent-dispatch-architecture -- skills/spec-creation/tasks/analytical-artifacts.md skills/spec-creation/SKILL.md`
- **Data loss risk:** None
