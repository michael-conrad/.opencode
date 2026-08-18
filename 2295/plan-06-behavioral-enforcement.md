# Phase 6 — Behavioral enforcement

**Concern:** Add a behavioral enforcement test asserting agents do not write test files under `.issues/`, per the canonical artifact-only generator framework.

**Files:**
- `.opencode/tests-v2/behaviors/<scenario>.sh` (new behavioral test)

**SCs:** SC-7

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: `.opencode/.issues/AGENTS.md` declares the content-type boundary
- `.opencode/tests-v2/AGENTS.md` canonical framework available (artifact-only generator paradigm)

**Exit Conditions:**
- A behavioral enforcement test at `.opencode/tests-v2/behaviors/` asserts an agent does NOT write test files under `.issues/`, per the artifact-only generator paradigm

---

## Code Path Coverage

- `.opencode/tests-v2/behaviors/<scenario>.sh` — new behavioral enforcement test (SC-7)

## Cross-Cutting SCs

- **Behavioral absence assertion** (SC-7): the test asserts via stderr that the agent does NOT write a test file under `.issues/`; runs via `with-test-home opencode run` with Bash tool timeout >= 600s.
- **Artifact-only generator** (SC-7): exit 0, no self-evaluation, per the canonical framework in `.opencode/tests-v2/AGENTS.md`.
- **Boundary consistency** (SC-7 → SC-1): SC-7's behavioral test asserts the `.issues/` content-type boundary established by SC-1.

## Interface Boundaries

- **`.opencode/tests-v2/behaviors/<scenario>.sh`** — created; runs in isolation via `with-test-home`, no production state touched.

## State Transitions

- **SC-7:** `no behavioral test for .issues/ write-prohibition` → `behavioral test asserts agent does NOT write test files under .issues/` (trigger: test addition; invariant: canonical artifact-only generator paradigm; re-checkable via `with-test-home opencode run`).

---

**Cost frame:** Running the behavioral enforcement test costs minutes of execution time. Skipping means the aggregate `.issues/` content-type boundary is never verified against real agent behavior, and the misrouting defect ships to production — costing 1000× more to fix than the bounded behavioral test. Correctness is the only success metric — there is no score for tool-call economy.

---

- [ ] 38. **RED (**sub-agent**).** Write the failing behavioral scenario: before the text fixes (or while unguarded) the agent would write a test file under `.issues/`; the scenario currently lacks the `.issues/` write-prohibition assertion. **→ SC-7**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-7, behavioral scenario, no `.issues/`-write assertion
- [ ] 39. **GREEN (**sub-agent**).** Add the behavioral enforcement test at `.opencode/tests-v2/behaviors/<scenario>.sh` asserting an agent does NOT write test files under `.issues/`, per the artifact-only generator paradigm. **→ SC-7**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-7, artifact-only generator, absence-of-`.issues/`-write assertions
- [ ] 40. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the new behavioral test does not regress the enforcement suite. **→ SC-7**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-7, post-GREEN regression
- [ ] 41. **verify (**sub-agent**).** Run the behavioral test via `with-test-home opencode run`; assert stderr shows NO `.issues/` write actions; Bash tool timeout >= 600s. **→ SC-7**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-7, behavioral test PASS, stderr-based absence assertions, 600s timeout
- [ ] 42. **commit-inline (**inline**).** Stage and commit the behavioral enforcement test. **→ SC-7**
  - Command: `git add .opencode/tests-v2/behaviors/<scenario>.sh && git commit -m "<message>"`

#### Phase 6 VbC

- [ ] 43. **VbC (**clean-room**).** Verify SC-7 passes its behavioral check: the enforcement test runs clean and asserts no `.issues/` test-file write. **→ SC-7**

**Concern transition:** Leaving behavioral enforcement → entering post-implementation verification. All phases complete; the post-implementation steps (audit, z3-check, structural-checks, pre-pr-gate, regression-check, review-prep, create-pr, exec-summary) follow.
