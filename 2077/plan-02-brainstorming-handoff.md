# Phase 2 — Update brainstorming handoff

**Concern:** Brainstorming handoff — completion task returns result contract signaling "handoff to spec-creation"

**Files:**
- `.opencode/skills/brainstorming/tasks/completion.md`

**SCs:** SC-12

**Dependencies:** Phase 1 (new spec-creation skill exists)

**Entry conditions:** Phase 1 complete, new SKILL.md and task files exist

**Exit conditions:** brainstorming completion task returns handoff signal to spec-creation

## Code Path Coverage

- brainstorming/tasks/completion.md — result contract section

## Cross-Cutting SCs

- None

## Interface Boundaries

- completion.md result contract must include a field that signals "handoff to spec-creation"
- The orchestrator reads this field and calls `skill({name: "spec-creation"})`

## State Transitions

- Brainstorming complete → handoff signal present → orchestrator dispatches spec-creation

## Step-by-step

- [ ] 6. **Update brainstorming completion.md (**sub-agent**).** Edit `.opencode/skills/brainstorming/tasks/completion.md` to add a handoff signal in the result contract that tells the orchestrator to call `skill({name: "spec-creation"})` and dispatch the analyze task. The handoff signal MUST be a field in the result contract (e.g., `next_skill: spec-creation` or equivalent). **→ SC-12**

#### Phase 2 VbC

- [ ] 6a. **VbC (**clean-room**).** Verify: grep brainstorming/tasks/completion.md for "spec-creation" — non-empty match. **→ SC-12**

**Concern transition:** Leaving brainstorming handoff → entering cleanup old sub-skills. Phase 3 depends on Phase 1 and Phase 2 being complete.
