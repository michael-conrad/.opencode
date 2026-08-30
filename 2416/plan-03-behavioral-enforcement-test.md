# Phase 3 — Behavioral enforcement test

**Concern:** Write a behavioral enforcement test that verifies an agent attempting to bypass the test-execution gate produces a BLOCKED verification result.

**Files:**
- `.opencode/tests-v2/behaviors/2416-bypass-gate.sh` (new)

**SCs:** SC-4

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: verification gate enforces test count and all-passed assertions
- Phase 1 VbC passed

**Exit Conditions:**
- New behavioral test scenario exists at `.opencode/tests-v2/behaviors/2416-bypass-gate.sh`
- `opencode run` with the new scenario produces BLOCKED result
- Phase 3 VbC passes

---

**Cost frame:** Writing the behavioral test costs one scenario + assertion file. Skipping means there is no enforcement mechanism to prevent regression — future changes to the verification gate could silently remove the test evidence assertion without detection. Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

---

- [ ] 31. **Pre-regression (**sub-agent**).** Run regression test patterns before RED phase. **→ SC-4**
- [ ] 32. **Pre-regression verify (**sub-agent**).** Verify pre-regression results. **→ SC-4**

- [ ] 33. **RED (**sub-agent**).** Confirm no behavioral test exists for the bypass scenario — structural check via `ls` or `glob`. **→ SC-4**
- [ ] 34. **GREEN (**sub-agent**).** Write behavioral test file at `.opencode/tests-v2/behaviors/2416-bypass-gate.sh` that dispatches a bypass scenario (agent claims completion without running tests) and asserts the gate produces BLOCKED. Source `helpers.sh` for assertion helpers. **→ SC-4**
- [ ] 35. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ SC-4**
- [ ] 36. **Verify (**sub-agent**).** Run `opencode run` with the new scenario to verify it produces a BLOCKED result. **→ SC-4**
- [ ] 37. **Commit (**inline**).** `git add .opencode/tests-v2/behaviors/2416-bypass-gate.sh && git commit -m "behaviors: add bypass-gate enforcement test for SC-4"`. **→ SC-4**

#### Phase 3 VbC

- [ ] 38. **VbC (**clean-room**).** Verify SC-4 passes with behavioral evidence artifact. **→ SC-4**

### Post-implementation (once per plan)

- [ ] 39. **Audit (**sub-agent**).** Run adversarial audit of the deliverable. Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`. **→ SC-1a, SC-1b, SC-2, SC-3, SC-4**
- [ ] 40. **Structural checks (**sub-agent**).** Run finishing checklist (lint, typecheck, etc.). Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`. **→ SC-1a, SC-1b, SC-2, SC-3, SC-4**
- [ ] 41. **Pre-PR gate (**sub-agent**).** Verify all SC verdicts before PR creation. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-1a, SC-1b, SC-2, SC-3, SC-4**
- [ ] 42. **Regression check (**sub-agent**).** Final regression check before PR. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-1a, SC-1b, SC-2, SC-3, SC-4**
- [ ] 43. **Review prep (**sub-agent**).** Prepare PR review context. Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`. **→ SC-1a, SC-1b, SC-2, SC-3, SC-4**
- [ ] 44. **Create PR (**sub-agent**).** Create the pull request. Dispatch `task(..., prompt: "execute create task from git-workflow-pr")`. **→ SC-1a, SC-1b, SC-2, SC-3, SC-4**
- [ ] 45. **Executive summary (**sub-agent**).** Generate completion executive summary. Dispatch `task(..., prompt: "execute completion task from completion-core")`. **→ SC-1a, SC-1b, SC-2, SC-3, SC-4**
