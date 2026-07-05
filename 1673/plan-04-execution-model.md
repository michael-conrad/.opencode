# Phase 4 — writing-plans Execution Model Contradiction

**Concern:** writing-plans SKILL.md repeatedly states "no task() calls within the pipeline" (5 occurrences across 4 sections), but `create.md` dispatches sub-agents for 11 of 22 steps. The SKILL.md must be updated to match the actual sub-agent dispatch implementation.

**Files:**
- `.opencode/skills/writing-plans/SKILL.md` — Mandatory Task Discipline, Persona, Invocation, Sub-Agent Routing, Operating Protocol

**SCs:** SC-15, SC-16, SC-17

**Dependencies:** None

**Entry conditions:** Feature branch exists

**Exit conditions:** All "no task() calls" language removed, Mandatory Task Discipline states sub-agent dispatch, behavioral test passes

---

### Global Pre-Steps

- [ ] 38. **Coherence gate (**clean-room**).** `skill({name: "pre-analysis"})` → `task(..., prompt: "execute pre-analysis task from pre-analysis")` for writing-plans SKILL.md. Verify current "no task()" language locations and create.md dispatch pattern before making changes.

- [ ] 39. **Pre-red-baseline (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute verify task from verification-before-completion")` for SC-15, SC-16, SC-17. Confirm current state fails.

### Phase 4 Steps

- [ ] 40. **RED (**sub-agent**).** `skill({name: "test-driven-development"})` → `task(..., prompt: "execute red task from test-driven-development")` for SC-17. Write behavioral test: `opencode-cli run` with plan creation prompt → stderr shows task() calls for pipeline steps. Confirm FAIL.

- [ ] 41. **GREEN (**sub-agent**).** `skill({name: "test-driven-development"})` → `task(..., prompt: "execute green task from test-driven-development")` for SC-15, SC-16. Edit `.opencode/skills/writing-plans/SKILL.md`:

    - Mandatory Task Discipline (line 12): change "All pipeline steps execute at orchestrator level — no `task()` calls within the pipeline" to "All pipeline steps dispatch sub-agents via `task()` for execution."
    - Mandatory Task Discipline (line 22): same change.
    - Persona section (line 45-47): change from "orchestrator reads each step procedure and executes it directly" to "orchestrator dispatches sub-agents for each pipeline step."
    - Invocation section (line 69-71): remove "No `task()` calls are used within the pipeline" language.
    - Sub-Agent Routing section (line 118-120): remove "The pipeline uses no `task()` calls" language. Update to document the sub-agent dispatch pattern.

- [ ] 42. **GREEN doublecheck (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute verify task from verification-before-completion")` for SC-15, SC-16. Verify: `grep -c "no task()" .opencode/skills/writing-plans/SKILL.md` == 0, and `grep -q "sub-agent" .opencode/skills/writing-plans/SKILL.md` → exit 0.

- [ ] 43. **Checkpoint commit (**inline**).** `skill({name: "git-workflow"})` → `task(..., prompt: "execute commit task from git-workflow")` with message: `Phase 4: resolve writing-plans execution model contradiction — remove "no task()" language, adopt sub-agent dispatch model`.

### Global Post-Steps

- [ ] 44. **Behavioral test (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute verify task from verification-before-completion")` for SC-17. Run behavioral test: `opencode-cli run` with plan creation prompt → stderr shows task() calls. Confirm PASS.

- [ ] 45. **Regression check (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute verify task from verification-before-completion")` for existing writing-plans functionality. Run existing enforcement tests to confirm no regressions.

#### Phase 4 VbC

- [ ] 46. **VbC (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute completion task from verification-before-completion")` for SC-15, SC-16, SC-17. Verify all three SCs pass.

**Concern transition:** Leaving writing-plans execution model → entering missing pipeline steps. Phase 5 depends on Phase 2 (same file — spec-creation SKILL.md).
