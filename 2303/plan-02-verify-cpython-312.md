# Phase 2 — Verify CPython 3.12

**Concern:** Verify `.opencode/tools/plan` resolves and executes under CPython 3.12 via `uv run --script`, asserting exit code 0 and no pytamer resolution error.

**Files:**
- `.opencode/tools/plan`

**SCs:** SC-2

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: the `requires-python` constraint in `.opencode/tools/plan` is `>=3.12,<3.14`
- Phase 1 VbC passed

**Exit Conditions:**
- Invoking `.opencode/tools/plan` via `uv run --script` under CPython 3.12 completes dependency resolution and execution with exit code 0
- The "No solution found when resolving script dependencies" / `up-tamer` resolution error is absent from output

---

- [ ] 9. **Pre-regression (**sub-agent**).** Run regression test patterns before the RED phase. **→ SC-2**
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/issue-2303/artifacts/pipeline-pre-regression-*`
- [ ] 10. **Pre-regression verify (**sub-agent**).** Verify the pre-regression results. **→ SC-2**
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/issue-2303/artifacts/pipeline-pre-regression-verify-*`
- [ ] 11. **RED (**sub-agent**).** Write a failing enforcement test asserting `.opencode/tools/plan` resolves and executes under CPython 3.12. **→ SC-2**
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`
  - The test invokes `.opencode/tools/plan` via `uv run --script` under CPython 3.12
  - The test asserts exit code 0 and the absence of the "No solution found when resolving script dependencies" / `up-tamer` resolution error in output
  - The test FAILS because the current `~=3.12` constraint permits CPython 3.14 and the resolution error occurs
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/issue-2303/artifacts/pipeline-red-*`
- [ ] 12. **GREEN (**sub-agent**).** Implement the change that makes the RED test pass. **→ SC-2**
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`
  - Confirm the `requires-python` constraint change from Phase 1 is in place
  - No scope creep — only the minimum change needed
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/issue-2303/artifacts/pipeline-green-*`
- [ ] 13. **Post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase. **→ SC-2**
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/issue-2303/artifacts/pipeline-post-regression-*`
- [ ] 14. **Verify (**sub-agent**).** Verify the implementation against the success criterion. **→ SC-2**
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
  - Run `.opencode/tools/plan` via `uv run --script` under CPython 3.12
  - Assert exit code is 0 and the "No solution found when resolving script dependencies" / `up-tamer` resolution error is absent from output
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/issue-2303/artifacts/pipeline-verify-*`
- [ ] 15. **Commit (**inline**).** Stage and commit the test and the change together as one atomic slice.
  - Orchestrator runs `git add <test> && git commit -m "<message>"`
  - No co-author trailer during this implementation commit

#### Phase 2 VbC

- [ ] 16. **VbC (**clean-room**).** Verify `.opencode/tools/plan` resolves and executes under CPython 3.12 with exit code 0 and no pytamer resolution error. **→ SC-2**
  - Dispatch a clean-room sub-agent with routing metadata only
  - Assert exit code 0 and the absence of the resolution error

**Concern transition:** Leaving CPython 3.12 verification → entering post-implementation gates (structural checks, verification, audit, cross-validate, review-prep, PR creation, completion).

---

## Post-Implementation

- [ ] 17. **Audit (**sub-agent**).** Run an adversarial audit of the deliverable. **→ SC-1, SC-2**
  - Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`
  - Follow with validator, evaluator, arbiter in sequence
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/issue-2303/artifacts/pipeline-audit-*`
- [ ] 18. **Z3 check (**inline**).** Run Z3 constraint solver verification. **→ SC-1, SC-2**
  - Orchestrator runs `.opencode/tools/solve check --state-path ... --contract-path ...`
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/issue-2303/artifacts/pipeline-z3-check-*`
- [ ] 19. **Structural checks (**sub-agent**).** Run the finishing checklist (lint, typecheck, etc.). **→ SC-1, SC-2**
  - Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/issue-2303/artifacts/pipeline-structural-checks-*`
- [ ] 20. **Pre-PR gate (**sub-agent**).** Verify all SC verdicts before PR creation. **→ SC-1, SC-2**
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
  - Reads all SC verdicts; BLOCKs if any FAIL
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/issue-2303/artifacts/pipeline-pre-pr-gate-*`
- [ ] 21. **Regression check (**sub-agent**).** Run the final regression check before PR. **→ SC-1, SC-2**
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/issue-2303/artifacts/pipeline-regression-check-*`
- [ ] 22. **Review prep (**sub-agent**).** Prepare PR review context. **→ SC-1, SC-2**
  - Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`
- [ ] 23. **Create PR (**sub-agent**).** Create the pull request. **→ SC-1, SC-2**
  - Dispatch `task(..., prompt: "execute create task from git-workflow-pr")`
- [ ] 24. **Exec summary (**sub-agent**).** Generate the completion executive summary. **→ SC-1, SC-2**
  - Dispatch `task(..., prompt: "execute completion task from completion-core")`
