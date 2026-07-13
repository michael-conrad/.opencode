# Phase 4: Restructure `verification-before-completion/tasks/behavioral-test-evaluation.md`

**SCs:** SC-1, SC-5
**Files:** `skills/verification-before-completion/tasks/behavioral-test-evaluation.md`, `skills/verification-before-completion/SKILL.md`
**Chain dependency:** `phase_3` (independent skill)

## Steps

### Step 4.1: Identify sub-agent dispatch instructions in behavioral-test-evaluation.md

Read `skills/verification-before-completion/tasks/behavioral-test-evaluation.md` and identify all instructions that tell a sub-agent to dispatch per-SC sub-agents.

**Dispatch:** `sub-agent` — reads behavioral-test-evaluation.md, produces list of dispatch instructions
**Evidence:** List of line numbers and instruction text

### Step 4.2: Remove per-SC sub-agent dispatch instructions

For each identified instruction:
1. Remove the `task()` call or "dispatch" language
2. Replace with a reference to the per-SC evaluation result the sub-agent should expect from the orchestrator
3. Preserve all other content

**Dispatch:** `sub-agent` — edits behavioral-test-evaluation.md
**Evidence:** Diff of changes

### Step 4.3: Update verification-before-completion SKILL.md Trigger Dispatch Table

Add orchestrator-level dispatch entries for per-SC sub-agents that were previously dispatched from within behavioral-test-evaluation.md.

**Dispatch:** `sub-agent` — edits SKILL.md
**Evidence:** Updated Trigger Dispatch Table

### Step 4.4: Verify SC-1 and SC-5 compliance

- **SC-1:** `grep` for "dispatch.*sub-agent" or "task()" in behavioral-test-evaluation.md — must return no matches
- **SC-5:** File read confirms no sub-agent dispatch instructions remain

**Dispatch:** `sub-agent` — runs verification
**Evidence:** grep output and file read confirmation

## SC-to-Step Traceability

| SC ID | Criterion | Step(s) |
|-------|-----------|---------|
| SC-1 | No task file contains sub-agent dispatch instructions | 4.1, 4.2, 4.4 |
| SC-5 | `behavioral-test-evaluation.md` restructured | 4.1, 4.2, 4.3, 4.4 |

## Safety/Rollback

- **Destructive operations:** None — file edits only
- **Rollback plan:** `git checkout feature/1915-sub-agent-dispatch-architecture -- skills/verification-before-completion/tasks/behavioral-test-evaluation.md skills/verification-before-completion/SKILL.md`
- **Data loss risk:** None
