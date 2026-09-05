# Post-Implementation (Global Steps)

These steps run once after phase 5 completes. They are plan-level gates, not phase items — no new SC coverage is introduced here; they verify and deliver what phases 1–5 built.

- [ ] 36. **Audit (**task-card**).** Adversarial audit of the deliverable.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-audit-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by validator, evaluator, arbiter in sequence.

- [ ] 37. **Z3 check (**direct**).** Run Z3 constraint solver verification.
  - Orchestrator runs `.opencode/tools/solve check --state-path ... --contract-path ...` directly — no sub-agent dispatch. The contract is `.opencode/.issues/2430/dependency-contract.yaml`; the state reflects phase completion booleans after phase 5.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-z3-check-*` before dispatch.

- [ ] 38. **Structural checks (**task-card**).** Run the finishing checklist (lint, typecheck, etc.).
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-structural-checks-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute checklist task from finishing-a-development-branch")`.

- [ ] 39. **Pre-PR gate (**task-card**).** Verify all SC verdicts before PR creation — BLOCKs if any FAIL.
  - Reads all SC verdicts: SC-1, SC-2, SC-3, SC-4, SC-5, SC-6a, SC-6b. Any non-clean pass (DONE_WITH_CONCERNS) is coerced to FAIL. EVIDENCE_TYPE_MISMATCH is a hard FAIL.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-pre-pr-gate-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`.

- [ ] 40. **Regression check (**task-card**).** Final regression check before PR.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-regression-check-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`.

- [ ] 41. **Review-prep (**task-card**).** Prepare PR review context.
  - Dispatch: `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`.

- [ ] 42. **Create PR (**task-card**).** Create the pull request.
  - Stacked strategy — one branch, one commit per issue (squash at PR time), targeting the trunk.
  - Dispatch: `task(..., prompt: "execute create task from git-workflow-pr")`.
  - Halt after PR creation — human-only merge; do not merge.

- [ ] 43. **Completion summary (**task-card**).** Generate the completion executive summary.
  - Dispatch: `task(..., prompt: "execute completion task from completion-core")`.
  - Report once after all steps complete; halt at scope boundary (`for_pr` ⇒ halt at pr_created).