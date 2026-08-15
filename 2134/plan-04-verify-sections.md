# Phase 4 — Verify All Sections Present and Semantic Preservation

**Concern:** Run a verification-only integration gate over all 10 SCs against the rewritten guideline, then run the post-implementation pipeline (audit, Z3 check, structural checks, pre-PR gate, regression check, review-prep, PR creation, completion).

**Files:**
- `.opencode/guidelines/117-session-trigger-behavior.md` (rewritten, verified)

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10

**Dependencies:** Phase 1, Phase 2, Phase 3

**Entry Conditions:**
- Phase 1 complete and VbC passed (SC-1, SC-2, SC-10)
- Phase 2 complete and VbC passed (SC-3, SC-4, SC-5, SC-9)
- Phase 3 complete and VbC passed (SC-6, SC-7, SC-8)
- The rewritten guideline file is in its final state

**Exit Conditions:**
- All 10 SCs pass the integration gate; a single FAIL blocks the plan (SC Enforcement Gate)
- Post-implementation pipeline (audit, Z3, structural checks, pre-PR gate, regression) passes
- PR created and completion executive summary generated

---

## Integration Gate — All SCs

- [ ] 46. **String checks (**clean-room**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Re-run all string grep checks against the rewritten guideline: `Self-Simulation` (SC-1), `No-Echo` (SC-3), `pair_mode_resume` and `nested_opencode_fatal` (SC-4), `Suppression Rule` (SC-5). **→ SC-1, SC-3, SC-4, SC-5**
- [ ] 47. **Semantic checklists (**clean-room**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Re-run all semantic verification checklists via clean-room sub-agents: V-SC-2 (7 checks), V-SC-6 (4 checks), V-SC-7 (3 checks), V-SC-8 (1 check), V-SC-9 (4 checks), V-SC-10 (4 checks). All must PASS. **→ SC-2, SC-6, SC-7, SC-8, SC-9, SC-10**

## Post-Implementation Steps

- [ ] 48. **Audit (**clean-room**).** Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`, followed by validator, evaluator, arbiter in sequence. Adversarial audit of the rewritten guideline against the spec. **→ SC-1..SC-10**
- [ ] 49. **Z3 check (**inline**).** Run `.opencode/tools/solve check --state-path .opencode/.issues/2134/artifacts/state-analysis.yaml --contract-path .opencode/.issues/2134/artifacts/interface-compatibility.yaml` directly — no sub-agent dispatch. Verify the phase DAG and dependency contract remain satisfiable. **→ SC-1..SC-10**
- [ ] 50. **Structural checks (**sub-agent**).** Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`. Run the finishing checklist (markdown lint, format check) on the rewritten guideline. **→ SC-1..SC-10**
- [ ] 51. **Pre-PR gate (**clean-room**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Read all SC verdicts; BLOCK if any SC is FAIL. All SCs must be clean PASS before PR creation. **→ SC-1..SC-10**
- [ ] 52. **Regression check (**sub-agent**).** Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run the final regression check before PR. **→ SC-1..SC-10**
- [ ] 53. **Review-prep (**sub-agent**).** Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`. Prepare PR review context. **→ SC-1..SC-10**
- [ ] 54. **Create PR (**sub-agent**).** Dispatch `task(..., prompt: "execute create task from git-workflow-pr")`. Create the pull request. **→ SC-1..SC-10**
- [ ] 55. **Exec summary (**sub-agent**).** Dispatch `task(..., prompt: "execute completion task from completion-core")`. Generate the completion executive summary. **→ SC-1..SC-10**

#### Phase 4 VbC

- [ ] 56. **VbC (**clean-room**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Verify all 10 SCs pass the integration gate and the post-implementation pipeline completed without FAIL. **→ SC-1..SC-10**

**Cost frame:** Cost is measured in defect-discovery-latency, not tool calls. Skipping the integration gate means a FAIL in any SC ships to the guideline and causes false-positive or false-negative enforcement at runtime. Skipping the audit, Z3 check, structural checks, or pre-PR gate means a defect is not caught until after PR merge — the most expensive discovery point.

**Concern transition:** This is the final phase. After Phase 4 VbC passes, the plan is complete and the PR is created.
