# Implementation Plan — [#492](https://github.com/michael-conrad/opencode-config/tree/issues-data/492) — Stale-branch detection before PR creation

**Goal:** Add automated staleness-check + auto-rebase to the pre-PR gate so feature branches are always rebased onto `origin/$DEFAULT_BRANCH` before push and PR creation.

**Architecture:** Single-phase implementation. A staleness-check step is added to `review-prep` (or `pr-creation/squash-push`) that runs `git rev-list --count --left-right` before any push. On `behind > 0`, the agent auto-rebases onto `origin/$DEFAULT_BRANCH`. On Tier 3 conflict, the agent halts and escalates. A behavioral enforcement test verifies the agent's stale-branch handling.

**Files:**
- `.opencode/skills/git-workflow/tasks/review-prep/` — add staleness-check + auto-rebase step before push
- `.opencode/tests/behaviors/stale-branch-auto-rebase.sh` — new behavioral enforcement test

> **Compliance requirement:** This plan MUST be followed step by step. Every numbered step is mandatory. No step may be skipped, reordered, or combined. The orchestrator dispatches each step to a clean-room sub-agent via `task()` — no inline execution except where explicitly marked `(**inline**)`. Each step produces exactly one artifact. If a step's verification fails, the orchestrator MUST roll back to the last checkpoint tag and re-dispatch. This is a NON-WAIVABLE hard gate.

> **One-step-at-a-time protocol:** The orchestrator dispatches exactly one step at a time. After each step completes, the orchestrator reads the result contract, logs it to the work state file, and proceeds to the next step. The orchestrator NEVER dispatches multiple steps in parallel. The orchestrator NEVER reads task file content — it receives result contracts only.

> **Step Status instruction:** After each step completes, the orchestrator MUST update the step's checkbox status in this plan file: `- [x] N.` for completed steps, `- [-] N.` for skipped/blocked steps. The orchestrator reads the plan file before each dispatch to determine the current step.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps |
|-------|------|---------|-----|--------------|-------|
| 1 | Stale-branch detection and auto-rebase | Add staleness-check + auto-rebase to pre-PR gate, add behavioral enforcement test | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7 | None | 1–22 |

---

## Phase 1 — Stale-branch detection and auto-rebase

**Concern:** Add a staleness-check + auto-rebase step to the pre-PR gate (`review-prep` or `pr-creation/squash-push`) and a behavioral enforcement test that verifies the agent's stale-branch handling.

**Files:**
- `.opencode/skills/git-workflow/tasks/review-prep/` — add staleness-check step
- `.opencode/tests/behaviors/stale-branch-auto-rebase.sh` — new behavioral test

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7

**Dependencies:** None

**Entry conditions:** Plan approved, feature branch created, on `$DEFAULT_BRANCH` base.

**Exit conditions:** All 7 SCs verified PASS, behavioral test passes, review-prep complete.

### Global Pre-Steps

- [ ] 1. **SC-coherence gate (**clean-room**).** Dispatch `audit --task coherence-extraction` to verify SC evidence types match the change's substrate classification. The staleness-check step in review-prep is a string/structural change (SC-1); the auto-rebase behavior is runtime-behavioral (SC-2 through SC-7). Evidence-type uplift must be applied if the substrate classification differs from the declared type. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7**

- [ ] 2. **Pre-RED baseline (**clean-room**).** Dispatch `implementation-pipeline --task pre-red-baseline` to verify doc-source currency and SC-ID cross-reference traceability. Confirm the spec's file references (`review-prep/`, `pr-creation/squash-push.md`) exist and the SC IDs are consistent. **→ SC-1, SC-7**

### Item 1: Behavioral enforcement test (RED)

- [ ] 3. **RED phase (**sub-agent**).** Dispatch `test-driven-development --task red` to write the behavioral enforcement test at `.opencode/tests/behaviors/stale-branch-auto-rebase.sh`. The test MUST:
  - Set up a test repo with a feature branch behind `origin/$DEFAULT_BRANCH`
  - Send a prompt that triggers `git-workflow --task review-prep`
  - Assert via `assert_semantic` that the agent detects staleness and auto-rebases
  - Assert via `assert_semantic` that on clean (behind == 0) the agent proceeds normally
  - Assert via `assert_semantic` that on Tier 3 conflict the agent halts and escalates
  - The test MUST FAIL at this point because the task file has no staleness check yet
  - **→ SC-2, SC-3, SC-4, SC-5, SC-7**

- [ ] 4. **Z3 check — RED (**clean-room**).** Dispatch `solve check` against the RED-phase output contract (`contracts/red-phase-output-template.yaml`). Verify the test code satisfies the output contract. **→ SC-7**

- [ ] 5. **RED doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to verify RED-side SC evidence. Confirm the behavioral test exists, is executable, and FAILS as expected. **→ SC-7**

- [ ] 6. **Z3 check — RED doublecheck (**clean-room**).** Dispatch `solve check` against the RED-doublecheck output contract (`contracts/red-doublecheck-output-template.yaml`). **→ SC-7**

- [ ] 7. **Post-RED enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-red-enforcement`. Run `git diff --name-only -- src/ | wc -l` — verify zero source files were modified during RED phase (only test files). **→ SC-7**

- [ ] 8. **Z3 check — post-RED (**clean-room**).** Dispatch `solve check` against the post-RED-enforcement output contract (`contracts/post-red-enforcement-output-template.yaml`). **→ SC-7**

### Item 2: Task file modification (GREEN)

- [ ] 9. **GREEN phase (**sub-agent**).** Dispatch `test-driven-development --task green` to add the staleness-check + auto-rebase step to `.opencode/skills/git-workflow/tasks/review-prep/` (or `pr-creation/squash-push.md`). The step MUST:
  - Run `git rev-list --count --left-right feature-branch...origin/$DEFAULT_BRANCH` before push
  - If `behind > 0`: auto-rebase onto `origin/$DEFAULT_BRANCH` via `git rebase origin/$DEFAULT_BRANCH`
  - If rebase succeeds (clean): proceed to push and PR creation
  - If rebase conflict: classify per `conflict-resolution` skill's three-tier system
    - Tier 1-2: auto-resolve, proceed
    - Tier 3: HALT and escalate to developer with conflict details
  - If `behind == 0`: proceed normally to push and PR creation
  - **→ SC-1, SC-2, SC-3, SC-4, SC-5**

- [ ] 10. **Z3 check — GREEN (**clean-room**).** Dispatch `solve check` against the GREEN-phase output contract (`contracts/green-phase-output-template.yaml`). **→ SC-1**

- [ ] 11. **Post-GREEN enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-green-enforcement`. Run `git diff --name-only -- test/ | wc -l` — verify zero test files were modified during GREEN phase (only source/task files). **→ SC-1**

- [ ] 12. **Z3 check — post-GREEN (**clean-room**).** Dispatch `solve check` against the post-GREEN-enforcement output contract (`contracts/post-green-enforcement-output-template.yaml`). **→ SC-1**

### Checkpoint

- [ ] 13. **Checkpoint tag create (**clean-room**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Create a git tag per `000-critical-rules.md` §Checkpoint Rollback Exception format: `<parent>/checkpoint/492/phase-1-<submodule>`. **→ All SCs**

- [ ] 14. **Checkpoint commit (**inline**).** Dispatch `git-workflow --task commit-prep`. Commit all changes with message: `feat: add stale-branch detection + auto-rebase to review-prep (#492)`. Include `Co-authored with AI: OpenCode (deepseek-v4-flash)`. **→ All SCs**

### Verification

- [ ] 15. **Structural checks (**clean-room**).** Dispatch `finishing-a-development-branch --task checklist`. Run lint (`uvx ruff check`), type check (`uvx pyright`), format check (`uvx ruff format --check`), and markdown lint (`uvx pymarkdownlnt scan`). Fix any issues. **→ SC-1**

- [ ] 16. **GREEN doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` for semantic-intent verification. Confirm the task file change correctly implements all spec requirements: staleness detection, auto-rebase, conflict classification, clean-path handling. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

- [ ] 17. **GREEN VbC (**clean-room**).** Dispatch `verification-before-completion --task completion`. Produce VbC completion artifact with evidence for all 7 SCs:
  - SC-1: Behavioral test `assert_semantic` evidence that agent runs staleness check before push
  - SC-2: Behavioral test `assert_semantic` evidence for auto-rebase on staleness
  - SC-3: Behavioral test `assert_semantic` evidence for proceed after rebase
  - SC-4: Behavioral test `assert_semantic` evidence for HALT on Tier 3 conflict
  - SC-5: Behavioral test `assert_semantic` evidence for clean-path proceed
  - SC-7: Behavioral test file existence + PASS result
  - **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7**

### Audit

- [ ] 18. **Adversarial audit (**sub-agent**).** Orchestrator multi-dispatch:
  1. Run `.opencode/tools/resolve-models` to select cross-family auditors
  2. Dispatch `audit --task verification-audit` with `auditor_1` — audit the task file change and behavioral test against spec SCs
  3. On non-clean-pass: remediate and restart auditor_1
  4. Dispatch same audit task with `auditor_2`
  5. On non-clean-pass: remediate and restart auditor_2
  6. Collect dual-auditor YAML verdicts
  - **→ All SCs**

- [ ] 19. **Cross-validate (**clean-room**).** Dispatch `audit --task cross-validate` with `auditor_artifact_paths` from step 18. Produce cross-validate findings YAML. Resolve any auditor disagreements. **→ All SCs**

### Post-Audit

- [ ] 20. **Regression check (**clean-room**).** Dispatch `test-driven-development --task patterns` (regression). Run the full behavioral test suite via `bash .opencode/tests/test-enforcement.sh --changed` to verify no existing tests are broken. **→ SC-7**

- [ ] 21. **Review-prep (**clean-room**).** Dispatch `git-workflow --task review-prep`. Run the full pre-PR checklist including the newly added staleness-check step. Verify the branch is not behind `origin/$DEFAULT_BRANCH`. **→ SC-1, SC-5**

- [ ] 22. **Exec summary (**inline**).** Dispatch `completion-core --task completion`. Append lifecycle event to issue body. Produce chat executive summary with plan file path, SC status table, and byline. **→ All SCs**

#### Phase 1 VbC

- [ ] 23. **VbC (**clean-room**).** Verify all 7 SCs have PASS evidence:
  - SC-1: `grep` confirms staleness-check step in review-prep task file
  - SC-2: Behavioral test PASS confirms auto-rebase on staleness
  - SC-3: Behavioral test PASS confirms proceed after rebase
  - SC-4: Behavioral test PASS confirms HALT on Tier 3 conflict
  - SC-5: Behavioral test PASS confirms clean-path proceed
  - SC-6: Behavioral test file exists at `tests/behaviors/492-stale-branch-auto-rebase.sh` (string evidence)
  - SC-7: Behavioral test passes with all assertions passing (behavioral evidence)
  - **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7**

> **Compliance requirement:** This plan MUST be followed step by step. Every numbered step is mandatory. No step may be skipped, reordered, or combined. The orchestrator dispatches each step to a clean-room sub-agent via `task()` — no inline execution except where explicitly marked `(**inline**)`. Each step produces exactly one artifact. If a step's verification fails, the orchestrator MUST roll back to the last checkpoint tag and re-dispatch. This is a NON-WAIVABLE hard gate.

> **Self-remediation protocol:** If any step fails verification, the orchestrator MUST NOT halt immediately. It MUST: (1) diagnose the root cause, (2) remediate the defect, (3) re-verify, and (4) proceed on PASS. Only on double-failure (remediation also fails) does the orchestrator HALT with escalation. This applies to ALL steps — RED, GREEN, Z3 checks, doublechecks, enforcement gates, audits, and cross-validate.

## Exit Criteria

- [ ] C1. Staleness-check step exists in `review-prep` (or `pr-creation/squash-push`) before push — verified by `grep` (SC-1)
- [ ] C2. Behavioral test verifies agent auto-rebases on staleness — verified by `assert_semantic` PASS (SC-2)
- [ ] C3. Behavioral test verifies agent proceeds after successful rebase — verified by `assert_semantic` PASS (SC-3)
- [ ] C4. Behavioral test verifies agent halts on Tier 3 conflict — verified by `assert_semantic` PASS (SC-4)
- [ ] C5. Behavioral test verifies agent proceeds on clean branch — verified by `assert_semantic` PASS (SC-5)
- [ ] C6. Behavioral enforcement test file exists — verified by file existence (SC-6)
- [ ] C7. Behavioral enforcement test passes — verified by test execution (SC-7)
- [ ] C8. All 22 pipeline gates completed with PASS status
- [ ] C9. Dual-auditor consensus achieved with no unresolved disagreements
- [ ] C10. Regression suite passes with no regressions
- [ ] C11. Review-prep completes successfully
- [ ] C12. All 7 SCs (SC-1 through SC-7) verified with 100% clean PASS — no SC skipped, deferred, weakened, or blocked
