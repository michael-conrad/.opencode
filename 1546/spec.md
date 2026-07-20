## Intent

Add the 10 missing trigger-to-task routing entries to `writing-plans/SKILL.md` so every pipeline step has a discoverable dispatch path.

## Problem

The Trigger Dispatch Table in `SKILL.md` only contains 3 entries (`create`, `retroactive`, `completion`). The remaining 10 sub-agent tasks (research, readiness, structure, solve, write, revisit, validate, audit-fidelity, audit-concern) have NO routing mechanism. They exist as files under `tasks/` but cannot be invoked from the skill's trigger system — making them unreachable by design.

**Affected file:** `.opencode/skills/writing-plans/SKILL.md` §Trigger Dispatch Table (lines 24-31)

**Missing entries:** research, readiness, structure, solve, write, revisit, validate, audit-fidelity, audit-concern, completion

## Fix Approach

Add `sub-agent` task rows to the Trigger Dispatch Table:

| User says / Context | Task | Dispatch |
|---------------------|------|----------|
| "research" / "evidence" / "verify claims" | `research` | `sub-agent` |
| "readiness" / "pipeline ready check" | `readiness` | `sub-agent` |
| "structure" / "phase structure" / "combined or separate" | `structure` | `sub-agent` |
| "solve" / "dependency check" / "Z3 verify" | `solve` | `sub-agent` |
| "write plan" / "generate plan" | `write` | `sub-agent` |
| "revisit" / "resolve concerns" | `revisit` | `sub-agent` |
| "validate" / "check plan" | `validate` | `sub-agent` |
| "audit fidelity" / "fidelity check" | `audit-fidelity` | `sub-agent (auditor)` |
| "audit concern" / "concern separation" | `audit-concern` | `sub-agent (auditor)` |

Also add a Dispatch table in SKILL.md (matching other skills like `issue-operations`) for programmatic invocation:

| Task | Call via task() |
|------|-----------------|
| `research` | `task(..., prompt: "execute research task from writing-plans")` |
| ...etc... |

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Trigger Dispatch Table has entries for all 10 sub-agent tasks | `string` |
| SC-2 | Dispatch table (programmatic invocation) matches issue-operations pattern with canonical strings | `string` |
| SC-3 | Each entry includes dispatch scope (`sub-agent` or `auditor`) in the Dispatch column | `string` |

## Dependencies

- None — this is a self-contained routing fix
- Must be applied before Spec #2 (pipeline restructure) can take effect, since routing must exist first
