# Phase 4 — Reference-Integrity Enforcement Check Build

**Concern:** Implement the standing reference-integrity enforcement check BEFORE the reference repairs, so the repairs in Phase 5 are validated by the new tool (spec DAG: SC-12 → SC-8/SC-9/SC-10).

**Files:**
- `.opencode/tools/` (new reference-integrity check script)
- `.opencode/tests-v2/AGENTS.md` (enforcement-workflow note wiring)
- `.opencode/tests-v2/` (new behavioral test for the broken probe)

**SCs:** SC-12

**Dependencies:** Phase 2 (ordering only — test retirement before tool build keeps the runner index clean; no code dependency)

**Entry Conditions:**
- Phases 1-3 complete with VbC passed
- Runner index clean after Phase 2

**Exit Conditions:**
- The check exists in `.opencode/tools/` and validates that agent-facing Read-links resolve to sections contained in their target files
- Run against a deliberately introduced broken Read-link, the check fails with the file path and the missing-section name
- The check is wired into the enforcement-workflow note (`.opencode/tests-v2/AGENTS.md`)

**Code Path Coverage:** New internal tool path (additive only — no existing code path modified).

**Cross-Cutting SCs:** test integrity (new behavioral assertions for the check); behavioral evidence duty (SC-12 is behavioral — exit code and report lines are the evidence).

**Interface Boundaries:** New interface: reference-integrity enforcement check — internal tool in `.opencode/tools/`, additive only, internal to agent enforcement. No existing interfaces changed.

**State Transitions:** enforcement state — before: no standing guard, canon moves can silently strand references; after: a deliberate broken link produces a failing exit code with file path + missing-section name; a well-formed repo state passes.

**Cost frame:** Building and running the integrity check costs minutes of execution time — the recurrence guard is in place the same change. Skipping costs the entire defect class recurring: the next canon move silently strands its dependents again, and the dead-link backlog regrows at 1000× the check's cost.

---

- [ ] 35. **RED (**task-card**).** Run the (not-yet-existing) check against a deliberately introduced broken Read-link — a link pointing at a section absent from its target file. No check exists, so the failure is not reported (RED). **→ SC-12**
- [ ] 36. **GREEN (**task-card**).** Implement the reference-integrity enforcement check in `.opencode/tools/` — it validates that agent-facing Read-links resolve to sections contained in their target files and fails closed on malformed input (empty file, no headings → report broken, never pass vacuously). Wire it into the enforcement-workflow note in `.opencode/tests-v2/AGENTS.md`. Re-run against the deliberate broken probe: the check must fail, reporting the file path and the missing-section name. **→ SC-12**
- [ ] 37. **Verify (**task-card**).** Verify SC-12: run the check against the deliberate broken probe; inspect the exit code (non-zero) and report lines (file path + missing-section name present). Evidence type is behavioral. **→ SC-12**
- [ ] 38. **COMMIT (**direct**).** `git add` the new tool, its behavioral test, and the AGENTS.md wiring; commit (message: add reference-integrity enforcement check). **→ SC-12**
- [ ] 39. **VbC (**task-card**).** Verify SC-12 verdict is PASS with behavioral evidence artifacts on disk (probe run output with non-zero exit + report lines). **→ SC-12**

#### Phase 4 Completion Block

- [ ] SC-12 verdict recorded with behavioral evidence (broken-probe exit code + report lines)
- [ ] Enforcement-workflow note wired; tool exists at `.opencode/tools/`

**Concern transition:** Leaving tool build → entering reference repair. Phase 5 depends on Phase 4's SC-12 — every repair is validated by the new check.
