# Phase 2 — Documentation

**Concern:** Update `.opencode/AGENTS.md` with mandatory test-execution language that documents verifiable test execution (not just command exit codes) as a required pre-condition to any completion claim.

**Files:**
- `.opencode/AGENTS.md`

**SCs:** SC-3

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: verification gate enforces test count and all-passed assertions
- Phase 1 VbC passed

**Exit Conditions:**
- `.opencode/AGENTS.md` contains explicit mandatory test-execution language
- `grep` confirms required language present
- Phase 2 VbC passes

---

**Cost frame:** Updating AGENTS.md costs one documentation edit. Skipping means agents continue treating tests as optional — the gate changes from Phase 1 exist but are undocumented, creating a gap between what agents are told and what the pipeline enforces. Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

---

- [ ] 23. **Pre-regression (**sub-agent**).** Run regression test patterns before RED phase. **→ SC-3**
- [ ] 24. **Pre-regression verify (**sub-agent**).** Verify pre-regression results. **→ SC-3**

- [ ] 25. **RED (**sub-agent**).** Write a failing structural check that confirms no mandatory test-execution language in `.opencode/AGENTS.md`. **→ SC-3**
- [ ] 26. **GREEN (**sub-agent**).** Add explicit mandatory test-execution language to `.opencode/AGENTS.md` in the Build / Lint / Test Commands section, stating that verifiable test execution is required before any completion claim. **→ SC-3**
- [ ] 27. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ SC-3**
- [ ] 28. **Verify (**sub-agent**).** Verify `grep` confirms required language is present. **→ SC-3**
- [ ] 29. **Commit (**inline**).** `git add .opencode/AGENTS.md && git commit -m "AGENTS.md: document mandatory test execution before completion claims"`. **→ SC-3**

#### Phase 2 VbC

- [ ] 30. **VbC (**clean-room**).** Verify SC-3 passes with evidence artifact. **→ SC-3**

**Concern transition:** Leaving documentation update → entering behavioral enforcement test creation. Phase 3 depends on Phase 1's gate changes to produce a BLOCKED result.
