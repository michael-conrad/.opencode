# Phase 2 — Documentation work

**Concern:** Document the RAGSync service configuration, per-source layout, usage, offline/cache path, and validation step in the `.opencode` skill/guideline tree.

**Files:**
- `.opencode/` skill/guideline tree (documentation file, new)

**SCs:** SC-6

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: RAGSync registered and configured
- Phase 1 VbC passed (SC-1..SC-5 PASS)

**Exit Conditions:**
- SC-6 verified PASS and committed
- Documentation exists covering service config, per-source layout, usage, offline/cache path, and validation step

---

### Item 6 (SC-6): Document service configuration and usage

- [ ] 34. **Pre-clean (**inline**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-2315}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-6**
- [ ] 35. **RED (**sub-agent**).** Write a failing check asserting the RAGSync documentation file does not yet exist. Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-6**
- [ ] 36. **GREEN (**sub-agent**).** Write documentation in the `.opencode` skill/guideline tree covering service configuration, per-source layout, usage, offline/cache path, and validation step. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-6**
- [ ] 37. **Post-regression (**sub-agent**).** Run regression test patterns. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-6**
- [ ] 38. **Verify (**clean-room**).** Verify SC-6: the documentation file exists and covers service configuration, per-source layout, usage, offline/cache path, and validation step. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-6**
- [ ] 39. **Commit (**inline**).** Commit the documentation change as one atomic slice. `git add .opencode/ && git commit -m "<documentation message>"`. **→ SC-6**

#### Phase 2 VbC

- [ ] 40. **VbC (**clean-room**).** Verify SC-6 verdict is clean PASS. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-6**

---

### Post-implementation (one-time, after last phase)

- [ ] 41. **Audit (**clean-room**).** Run adversarial audit of the deliverable (DiMo investigator → validator → evaluator → arbiter). Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`, followed by validator, evaluator, arbiter in sequence. **→ audit**
- [ ] 42. **Z3 check (**inline**).** Run Z3 constraint solver verification: `.opencode/tools/solve check --state-path ... --contract-path ...`. Confirm the phase dependency DAG and state transitions are satisfied. **→ z3-check**
- [ ] 43. **Structural checks (**sub-agent**).** Run the finishing checklist (lint, typecheck, etc.). Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`. **→ structural-checks**
- [ ] 44. **Pre-PR gate (**clean-room**).** Read all SC verdicts (SC-1..SC-6); BLOCK if any verdict is FAIL. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ pre-pr-gate**
- [ ] 45. **Regression check (**sub-agent**).** Run final regression check before PR. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ regression-check**
- [ ] 46. **Review prep (**sub-agent**).** Prepare PR review context. Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`. **→ review-prep**
- [ ] 47. **Create PR (**sub-agent**).** Create the pull request (requires `for_pr` scope or explicit instruction). Dispatch `task(..., prompt: "execute create task from git-workflow-pr")`. **→ create-pr**
- [ ] 48. **Completion summary (**clean-room**).** Generate completion executive summary. Dispatch `task(..., prompt: "execute completion task from completion-core")`. **→ exec-summary**

**Concern transition:** All SCs (SC-1..SC-6) implemented and verified. Plan complete — HALT awaiting PR review/merge.
