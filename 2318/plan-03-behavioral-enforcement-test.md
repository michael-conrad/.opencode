# Phase 3 — Behavioral enforcement test

**Concern:** Add behavioral enforcement test scenarios that exercise the Phase 1 rule's Tier 2 HALT framing (SC-4) and developer-authorization carve-out (SC-5), evaluated via `session.yaml` clean-room sub-agent inspection.

**Files:**
- `.opencode/tests-v2/behaviors/2318-sc4-tier2-halt-framing.sh` (new)
- `.opencode/tests-v2/behaviors/2318-sc5-dev-authorization-carveout.sh` (new)

**SCs:** SC-4, SC-5

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: the root-repo-only tooling rule exists in `.opencode/AGENTS.md`
- Phase 1 VbC passed (SC-1, SC-2, SC-3, SC-6, SC-7, SC-8 PASS)

**Exit Conditions:**
- SC-4, SC-5 verified PASS and committed
- Behavioral test scenarios exist exercising the Tier 2 HALT framing and developer-authorization carve-out

---

### Item 4 (SC-4): Tier 2 HALT classification framing

- [ ] 47. **Pre-clean (**inline**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-2318}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-4**
- [ ] 48. **RED (**sub-agent**).** Write a failing behavioral test asserting HALT-without-`CRITICAL VIOLATION` framing on a submodule toolchain invention/alteration violation (the test fails because the rule is absent). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-4**
- [ ] 49. **GREEN (**sub-agent**).** Author the rule with Tier 2 HALT framing (no `CRITICAL VIOLATION` header) on submodule toolchain invention/alteration. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-4**
- [ ] 50. **Post-regression (**sub-agent**).** Run regression test patterns. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-4**
- [ ] 51. **Verify (**clean-room**).** Verify SC-4: the behavioral test passes on HALT framing via `session.yaml` clean-room sub-agent inspection, evaluating HALT-without-`CRITICAL VIOLATION` framing from the session record. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-4**
- [ ] 52. **Commit (**inline**).** Commit the Tier 2 HALT framing text and behavioral test scenario as one atomic slice. `git add .opencode/AGENTS.md .opencode/tests-v2/behaviors/ && git commit -m "<Tier 2 HALT framing + test>"`. **→ SC-4**

### Item 5 (SC-5): Developer-authorization carve-out

- [ ] 53. **Pre-clean (**inline**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-2318}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-5**
- [ ] 54. **RED (**sub-agent**).** Write a failing behavioral test asserting the developer-authorization carve-out path is honored (the test fails because the carve-out is absent). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-5**
- [ ] 55. **GREEN (**sub-agent**).** Author the explicit developer-authorization carve-out for intentional submodule tooling setup. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-5**
- [ ] 56. **Post-regression (**sub-agent**).** Run regression test patterns. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-5**
- [ ] 57. **Verify (**clean-room**).** Verify SC-5: the behavioral test passes on the carve-out path via `session.yaml` clean-room sub-agent inspection, evaluating that the developer-authorization carve-out path is honored in the session record. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-5**
- [ ] 58. **Commit (**inline**).** Commit the carve-out text and behavioral test scenario as one atomic slice. **→ SC-5**

#### Phase 3 VbC

- [ ] 59. **VbC (**clean-room**).** Verify SC-4 and SC-5 verdicts are clean PASS (evidence is `behavioral` via `session.yaml` clean-room inspection; any `DONE_WITH_CONCERNS` is coerced to FAIL per the implementation-workflow coercion rules). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-4, SC-5**

---

### Post-implementation (one-time, after last phase)

- [ ] 60. **Audit (**clean-room**).** Run adversarial audit of the deliverable (DiMo investigator → validator → evaluator → arbiter). Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`, followed by validator, evaluator, arbiter in sequence. **→ audit**
- [ ] 61. **Z3 check (**inline**).** Run Z3 constraint solver verification: `.opencode/tools/solve check --state-path ... --contract-path ...`. Confirm the phase dependency DAG and state transitions are satisfied. **→ z3-check**
- [ ] 62. **Structural checks (**sub-agent**).** Run the finishing checklist (lint, typecheck, etc.). Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`. **→ structural-checks**
- [ ] 63. **Pre-PR gate (**clean-room**).** Read all SC verdicts (SC-1..SC-9); BLOCK if any verdict is FAIL. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ pre-pr-gate**
- [ ] 64. **Regression check (**sub-agent**).** Run final regression check before PR. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ regression-check**
- [ ] 65. **Review prep (**sub-agent**).** Prepare PR review context. Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`. **→ review-prep**
- [ ] 66. **Create PR (**sub-agent**).** Create the pull request (requires `for_pr` scope or explicit instruction). Dispatch `task(..., prompt: "execute create task from git-workflow-pr")`. **→ create-pr**
- [ ] 67. **Completion summary (**clean-room**).** Generate completion executive summary. Dispatch `task(..., prompt: "execute completion task from completion-core")`. **→ exec-summary**

**Concern transition:** All SCs (SC-1..SC-9) implemented and verified. Plan complete — HALT awaiting PR review/merge.
