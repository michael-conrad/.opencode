# Implementation Plan — [#1537](https://github.com/michael-conrad/.opencode/issues/1537) — Submodule Pointer Bumps

- **Goal:** Ensure dirty submodule pointers are included in parent repo commits by adding pre-commit pointer checks, updating pre-commit Gate 4 to allow mixed commits, and creating a dedicated sub-agent task.
- **Architecture:** A new `pre-commit-pointer-check` sub-task detects dirty submodule pointers via `git submodule status` and stages them before commit. `implementation.md` calls this check before each commit. `pr-creation.md` verifies pointers are included during squash. Pre-commit Gate 4 is relaxed to allow submodule pointers when non-submodule changes are also staged. `SKILL.md` registers the new task.
- **Files:**
  - `.opencode/skills/git-workflow/tasks/pre-commit-pointer-check.md` (new)
  - `.opencode/skills/git-workflow/tasks/implementation.md` (edit)
  - `.opencode/skills/git-workflow/tasks/pr-creation.md` (edit)
  - `.opencode/hooks/pre-commit` (edit)
  - `.opencode/skills/git-workflow/SKILL.md` (edit)

> **⚠️ COMPLIANCE REQUIREMENT:** All 5 SCs are independent per sc-pipeline-readiness.yaml (PASS). Single phase — no dependency ordering constraints. Each item maps to exactly one file change. Behavioral SCs (SC-3, SC-5) require RED-phase behavioral tests written before GREEN implementation. All implementation-pipeline gate steps are mandatory — no step may be omitted because the plan writer judges it "not needed."

> **⚠️ ONE-STEP-AT-A-TIME PROTOCOL:** Each step below is one atomic action. Do NOT combine steps. After each step, verify the result before proceeding. HALT on failure and remediate.

> **⚠️ STEP STATUS:** All steps start `[ ]`. Mark `[x]` as completed.

## Phase 1 — Pre-Commit Pointer Check & Gate Relaxation

| Phase | Name | Concern | SCs | Dependencies | Steps |
|-------|------|---------|-----|--------------|-------|
| 1 | Pre-commit pointer check & gate relaxation | Ensure dirty submodule pointers are included in parent repo commits | SC-1, SC-2, SC-3, SC-4, SC-5 | None | 1–28 |

### Global Pre-Steps

- [ ] 1. **Coherence gate (**clean-room**).** Verify the plan is coherent with the codebase: confirm `git-workflow/tasks/implementation.md` exists, `git-workflow/tasks/pr-creation.md` exists, `.opencode/hooks/pre-commit` exists, `git-workflow/SKILL.md` exists. Report PASS or BLOCKED. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 2. **Pre-RED baseline (**clean-room**).** Run `bash .opencode/tests/test-enforcement.sh --list` to confirm test infrastructure is operational. Run `bash .opencode/tests/with-test-home opencode-cli run 'ping'` to confirm CLI is operational. Report PASS or BLOCKED. **→ SC-3, SC-5**

### Item 1 — Create pre-commit-pointer-check.md task file (SC-4, string)

- [ ] 3. **GREEN (**sub-agent**).** Create `.opencode/skills/git-workflow/tasks/pre-commit-pointer-check.md` with:
  - Purpose: detect dirty submodule pointers via `git submodule status` (lines starting with `+` or ` `), stage them with `git add <submodule-path>`, verify they appear in `git diff --cached`
  - Procedure: check `git submodule status`, parse for dirty markers, stage dirty pointers, verify staging
  - Verification table with tool calls and expected results
  - Entry/Exit criteria
  - **→ SC-4**
- [ ] 4. **GREEN doublecheck (**inline**).** Verify the file exists at the expected path. Read the file and confirm it contains Purpose, Procedure, and Verification sections. **→ SC-4**
- [ ] 5. **Checkpoint commit (**inline**).** `git add .opencode/skills/git-workflow/tasks/pre-commit-pointer-check.md && git commit -m "WIP: create pre-commit-pointer-check task file"` **→ SC-4**

### Item 2 — Update implementation.md with pre-commit-pointer-check step (SC-1, string)

- [ ] 6. **GREEN (**sub-agent**).** Edit `.opencode/skills/git-workflow/tasks/implementation.md`: insert a step in the "Making Implementation Commits" procedure, before `git add`, that runs pre-commit-pointer-check to detect and stage dirty submodule pointers. Reference the new sub-task file. **→ SC-1**
- [ ] 7. **GREEN doublecheck (**inline**).** Read `implementation.md` and confirm the pre-commit-pointer-check step appears before the `git add` instruction. **→ SC-1**
- [ ] 8. **Checkpoint commit (**inline**).** `git add .opencode/skills/git-workflow/tasks/implementation.md && git commit -m "WIP: add pre-commit-pointer-check step to implementation.md"` **→ SC-1**

### Item 3 — Update pr-creation.md with submodule pointer verification step (SC-2, string)

- [ ] 9. **GREEN (**sub-agent**).** Edit `.opencode/skills/git-workflow/tasks/pr-creation.md`: insert a step in the squash-push procedure that verifies dirty submodule pointers are included in staged changes before squash. Reference the pre-commit-pointer-check task. **→ SC-2**
- [ ] 10. **GREEN doublecheck (**inline**).** Read `pr-creation.md` and confirm the submodule pointer verification step appears in the squash-push section. **→ SC-2**
- [ ] 11. **Checkpoint commit (**inline**).** `git add .opencode/skills/git-workflow/tasks/pr-creation.md && git commit -m "WIP: add submodule pointer verification to pr-creation.md"` **→ SC-2**

### Item 4 — Update pre-commit Gate 4 to allow mixed commits (SC-3, behavioral)

- [ ] 12. **RED (**sub-agent**).** Write behavioral test at `.opencode/tests/behaviors/gate4-mixed-commits.sh` that:
  - Sets up a test repo with a `.gitmodules` entry and a mock submodule path
  - Stages a non-submodule file AND a submodule pointer change together
  - Runs the pre-commit hook
  - Asserts the hook PASSES (exit 0) when both submodule pointer and non-submodule changes are staged
  - Run the test and confirm it FAILS (RED) **→ SC-3**
- [ ] 13. **GREEN (**sub-agent**).** Edit `.opencode/hooks/pre-commit` Gate 4: change the `ALL_SUBMODULE_POINTERS=1` check so that if any staged file is NOT a submodule pointer, set `ALL_SUBMODULE_POINTERS=0` (allowing the commit). The gate only blocks when ALL staged files are submodule pointers. **→ SC-3**
- [ ] 14. **GREEN doublecheck (**inline**).** Read the modified Gate 4 logic and confirm the condition correctly allows mixed commits. **→ SC-3**
- [ ] 15. **Re-run behavioral test (**inline**).** Run `bash .opencode/tests/behaviors/gate4-mixed-commits.sh` and confirm it PASSES (GREEN). **→ SC-3**
- [ ] 16. **Checkpoint commit (**inline**).** `git add .opencode/hooks/pre-commit .opencode/tests/behaviors/gate4-mixed-commits.sh && git commit -m "WIP: relax Gate 4 to allow mixed submodule+non-submodule commits"` **→ SC-3**

### Item 5 — Update SKILL.md to register new task + behavioral test (SC-5, behavioral)

- [ ] 17. **RED (**sub-agent**).** Write behavioral test at `.opencode/tests/behaviors/submodule-pointer-inclusion.sh` that:
  - Sends a real-domain prompt via `opencode-cli run` simulating a commit with dirty submodule pointers
  - Asserts the agent includes dirty submodule pointers in the commit without using `--no-verify`
  - Run the test and confirm it FAILS (RED) **→ SC-5**
- [ ] 18. **GREEN (**sub-agent**).** Edit `.opencode/skills/git-workflow/SKILL.md`: add `pre-commit-pointer-check` to the `## Tasks` list, add a dispatch row for `"pre-commit-pointer-check"` / `"check submodule pointers"` in the Trigger Dispatch Table, and add the corresponding `task()` invocation line in the Invocation section. **→ SC-5**
- [ ] 19. **GREEN doublecheck (**inline**).** Read `SKILL.md` and confirm the new task appears in all three locations (Tasks list, Trigger Dispatch Table, Invocation section). **→ SC-5**
- [ ] 20. **Re-run behavioral test (**inline**).** Run `bash .opencode/tests/behaviors/submodule-pointer-inclusion.sh` and confirm it PASSES (GREEN). **→ SC-5**
- [ ] 21. **Checkpoint commit (**inline**).** `git add .opencode/skills/git-workflow/SKILL.md .opencode/tests/behaviors/submodule-pointer-inclusion.sh && git commit -m "WIP: register pre-commit-pointer-check task in SKILL.md"` **→ SC-5**

### Global Post-Steps

- [ ] 22. **Collect behavioral evidence (**clean-room**).** Collect evidence artifacts from `./tmp/behavioral-evidence-*/` into `./tmp/1537/artifacts/`. Verify all behavioral SCs (SC-3, SC-5) have evidence artifacts. **→ SC-3, SC-5**
- [ ] 23. **Adversarial audit (**sub-agent**).** Dispatch `adversarial-audit --task spec-audit` with the spec issue number 1537 and the plan file path. Collect verdict. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 24. **Cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate` with the spec issue number 1537 and the plan file path. Collect consensus verdict. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 25. **Regression check (**clean-room**).** Run `bash .opencode/tests/test-enforcement.sh --changed` to verify no existing tests regressed. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 26. **Review-prep (**sub-agent**).** Dispatch `git-workflow --task review-prep` to prepare the branch for PR. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 27. **Executive summary (**inline**).** Report completion: all 5 SCs implemented, behavioral tests passing, plan file at `.opencode/.issues/1537/plan.md`. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

#### Phase 1 VbC

- [ ] 28. **VbC (**clean-room**).** Verify all exit criteria C1–C7 are met. Confirm `pre-commit-pointer-check.md` exists, `implementation.md` has the pointer check step, `pr-creation.md` has the verification step, Gate 4 allows mixed commits (behavioral test PASS), `SKILL.md` registers the new task, and both behavioral tests pass. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

> **⚠️ COMPLIANCE REQUIREMENT:** SC-3 and SC-5 are behavioral. Each requires a RED-phase behavioral test (written before GREEN) that sends a real-domain prompt via `opencode-cli run` and asserts the agent's stderr output. The behavioral test files go in `.opencode/tests/behaviors/`. See `080-code-standards.md` §Behavioral RED/GREEN as Primary Enforcement Gate.

> **⚠️ SELF-REMEDIATION PROTOCOL:** If any step fails (hook rejection, lint error, behavioral test FAIL), diagnose root cause, fix, re-verify. Do NOT proceed past a failed step. Double-failure on behavioral test: escalate with both failure artifacts.

## Exit Criteria

- [ ] C1: `pre-commit-pointer-check.md` exists with purpose, procedure, and verification table
- [ ] C2: `implementation.md` has a pre-commit-pointer-check step before `git add`
- [ ] C3: `pr-creation.md` has a submodule pointer verification step in squash-push
- [ ] C4: Pre-commit Gate 4 allows submodule pointers when non-submodule changes are also staged (verified by behavioral test)
- [ ] C5: `SKILL.md` lists `pre-commit-pointer-check` in tasks, dispatch table, and invocation section
- [ ] C6: Behavioral test for SC-3 passes (Gate 4 allows mixed commits)
- [ ] C7: Behavioral test for SC-5 passes (agent includes dirty submodule pointers without `--no-verify`)
