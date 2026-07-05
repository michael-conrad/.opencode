# Implementation Plan — [#1537](https://github.com/michael-conrad/.opencode/issues/1537) — Include Dirty Submodule Pointers in Parent Repo Commits

- **Goal:** Ensure dirty submodule pointers are included in parent repo commits by adding pre-commit pointer checks, updating Gate 4 to allow mixed commits, and creating a dedicated sub-agent task.
- **Architecture:** A new `pre-commit-pointer-check` sub-task detects dirty submodule pointers via `git submodule status` and stages them before commit. `implementation.md` calls this check before each commit. `pr-creation.md` verifies pointers are included during squash. Pre-commit Gate 4 is relaxed to allow submodule pointers when non-submodule changes are also staged. `SKILL.md` registers the new task.
- **Files:**
  - `.opencode/skills/git-workflow/tasks/pre-commit-pointer-check.md` (new)
  - `.opencode/skills/git-workflow/tasks/implementation.md` (edit)
  - `.opencode/skills/git-workflow/tasks/pr-creation.md` (edit)
  - `.opencode/hooks/pre-commit` (edit)
  - `.opencode/skills/git-workflow/SKILL.md` (edit)

> **⚠️ COMPLIANCE REQUIREMENT:** All 5 SCs are independent per sc-pipeline-readiness.yaml (PASS). Single phase — no dependency ordering constraints. Each item maps to exactly one file change. Behavioral SCs (SC-3, SC-5) require RED-phase behavioral tests written before GREEN implementation.
> **⚠️ ONE-STEP-AT-A-TIME PROTOCOL:** Each step below is one atomic action. Do NOT combine steps. After each step, verify the result before proceeding. HALT on failure and remediate.
> **⚠️ STEP STATUS:** All steps start `[ ]`. Mark `[x]` as completed.

## Phase 1 — Pre-Commit Pointer Check & Gate Relaxation

| Phase | Name | Concern | SCs | Dependencies | Steps |
|-------|------|---------|-----|--------------|-------|
| 1 | Pre-commit pointer check & gate relaxation | Ensure dirty submodule pointers are included in parent repo commits | SC-1, SC-2, SC-3, SC-4, SC-5 | None | 1–5 |

### Item 1 — Create pre-commit-pointer-check.md task file (SC-4, string)

- [ ] 1. **Create `.opencode/skills/git-workflow/tasks/pre-commit-pointer-check.md` with purpose, procedure, and verification table (**clean-room**).** The task file defines: (a) detect dirty submodule pointers via `git submodule status` (lines starting with `+` or ` `), (b) stage them with `git add <submodule-path>`, (c) verify they appear in `git diff --cached`. Include a verification table with tool calls and expected results. **→ SC-4**

### Item 2 — Update implementation.md with pre-commit-pointer-check step (SC-1, string)

- [ ] 2. **Add a pre-commit-pointer-check step to `implementation.md`'s "Making Implementation Commits" procedure, before `git add` (**inline**).** Insert a step: "Run pre-commit-pointer-check: detect and stage dirty submodule pointers." Reference the new sub-task file. **→ SC-1**

### Item 3 — Update pr-creation.md with submodule pointer verification step (SC-2, string)

- [ ] 3. **Add a submodule pointer verification step to `pr-creation.md`'s squash-push procedure (**inline**).** Insert a step in the squash-push sub-task: "Verify dirty submodule pointers are included in the staged changes before squash." Reference the pre-commit-pointer-check task. **→ SC-2**

### Item 4 — Update pre-commit Gate 4 to allow mixed commits (SC-3, behavioral)

- [ ] 4. **Modify pre-commit Gate 4 logic to PASS when submodule pointers AND non-submodule changes are staged together (**inline**).** Change the `ALL_SUBMODULE_POINTERS=1` check: if any staged file is NOT a submodule pointer, set `ALL_SUBMODULE_POINTERS=0` (allowing the commit). The gate only blocks when ALL staged files are submodule pointers. **→ SC-3**

### Item 5 — Update SKILL.md to register new task + behavioral test (SC-5, behavioral)

- [ ] 5. **Add `pre-commit-pointer-check` to SKILL.md's task list, trigger dispatch table, and Invocation section (**inline**).** Insert the new task name in the `## Tasks` list, add a dispatch row for `"pre-commit-pointer-check"` / `"check submodule pointers"` in the Trigger Dispatch Table, and add the corresponding `task()` invocation line. **→ SC-5**

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
