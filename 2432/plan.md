---
plan_schema_version: 1
issue: 2432
title: "local-issues: qualifier enforcement, PROJECT_DIR anchoring, YAML hardening and repair"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 6
dispatch:
  - "phase-1: test-driven-development (red, green, post-regression), verification-before-completion (verify), commit-inline"
  - "phase-2: test-driven-development (red, green, post-regression), verification-before-completion (verify), commit-inline"
  - "phase-3: test-driven-development (red, green, post-regression), verification-before-completion (verify), commit-inline"
  - "phase-4: test-driven-development (red, green, post-regression), verification-before-completion (verify), commit-inline via tool auto-commit"
  - "phase-5: test-driven-development (red, green, post-regression), verification-before-completion (verify), commit-inline; post-implementation: audit, z3-check, finishing-a-development-branch, verification-before-completion, git-workflow-pr, completion-core"
  - "phase-6: test-driven-development (red, green, post-regression), verification-before-completion (verify), commit-inline"
---

# Implementation Plan — local-issues: qualifier enforcement, PROJECT_DIR anchoring, YAML hardening and repair (.opencode#2432)

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.

## Goal / Architecture / Files / Dispatch

- **Issue:** .opencode/.issues/2432/spec.md
- **Goal:** Make `local-issues` resolve repo/issue identity deterministically (qualifier enforcement on all commands, `PROJECT_DIR` anchoring), remediate the worktree bootstrap and counter targeting, harden YAML parsing (warn-and-skip), add `validate-yaml` and `doctor` subcommands, repair the 10 confirmed malformed tracking files, insert the `validate-yaml` gate into the spec-creation and writing-plans task cards, surface the session-resumption mandate at the point of timeout-kill as framework-agnostic behavioral rules — resume when the session store survives, never blind-restart (SC-10), add persistent/shared test-home resumption as an implementation-agnostic capability contract (SC-11), and mandate deliberation review of behavioral test evidence over whatever reasoning/deliberation evidence the session store provides, schema- and provider-agnostic (SC-12) — extended (R-18) so the deliberation/effectiveness review treats excessive run time as a primary defect signal: repeated timeouts, monitor aborts, large single-turn reasoning blocks, or budget exhaustion trigger cause tracing to instructions, task-card/skill-deck wording, prompt construction, fixture state, or harness behavior, with fixes folded in as an SC revision or additional spec, implemented on the stacked feature branch, tested for effectiveness, adjusted, and the pipeline continuing only after the fix is verified effective.
- **Architecture:** Twelve per-SC TDD items in dependency order across six phases. All tool changes live in `.opencode/tools/local-issues` plus a new pytest unit module under `.opencode/tests/`. Repair commits land on issues-data worktree branches via the tool's auto-commit (R-10) — never as parent-repo tracked changes. Phase 6 fixes the timeout-recovery instructions (SC-10), adds the shared-home resumption capability (SC-11), and adds the deliberation-review mandate (SC-12).
- **Files:** `.opencode/tools/local-issues`, new test module under `.opencode/tests/`, task cards under `.opencode/skills/spec-creation/tasks/` and `.opencode/skills/writing-plans/tasks/`, test-driven-development task cards under `.opencode/skills/test-driven-development/tasks/`, behavioral scenario scripts and `.opencode/tests-v2/with-test-home`, live tracking data in `.opencode/.issues/` and `.issues/` (repair only, via tool auto-commit).
- **Dispatch:** Per-task cycle steps dispatch as task cards per the implementation-workflow reference card; commit-inline steps are executed directly by the orchestrator.

## Blast Radius

- `local-issues` CLI surface: breaking change — bare numbers rejected on ALL commands; `create --number` becomes REQUIRED and qualified; auto-number create path removed.
- In-repo consumers: ~36 skill/task files and behavioral fixtures that invoke `local-issues` with bare numbers must be swept in-phase with SC-01 (no compat shims per the no-backward-compat guideline).
- Live tracking data: phase-4 repair touches `.opencode/.issues/` and `.issues/` content via mechanical transforms only; commits confined to issues-data worktree branches.
- Task cards: phase-5 edits spec-creation and writing-plans task cards — behavioral gate re-run required.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|-----------|------------|----------|
| 1 | Qualifier enforcement + PROJECT_DIR anchoring | tool-core identity | SC-01, SC-02 | none | 3-14 | direct (1-2, 13-14) + task-card (3-12) |
| 2 | Bootstrap remediation + counter hygiene + doctor | tool-core infra | SC-03, SC-04, SC-08 | Phase 1 | 15-27 | direct (15-16, 26-27) + task-card (17-25) |
| 3 | YAML warn-and-skip hardening + validate-yaml | parse gate | SC-05, SC-06 | none | 28-37 | direct (28-29, 36-37) + task-card (30-35) |
| 4 | Malformed tracking file repair | repair | SC-07 | Phase 3 | 38-44 | direct (38-39) + task-card (40-43) + auto-commit (44) |
| 5 | Pipeline validate-yaml gate insertion | integration | SC-09 | Phase 3 | 45-58 | direct (45-46) + task-card (47-57) + direct (58) |
| 6 | Session-resumption mandate + shared test home + deliberation review | test-framework | SC-10, SC-11, SC-12 | Phase 3 | 60-78 | direct (60-61, 70-78) + task-card (62-69) |
| — | Post-implementation (after Phase 6) | pipeline gates | all | Phases 1-6 | see Phase 5/6 | mixed |

## Exit Criteria

- C1: All twelve SCs verified PASS with behavioral evidence artifacts under `tmp/2432/`.
- C2: Phase 1 items committed in DAG order; Phase 2 depends on Phase 1 commits; Phases 4 and 5 depend on Phase 3; Phase 6 items committed after their RED evidence.
- C3: Phase-4 repair commits exist only on issues-data worktree branches (parent repo untouched).
- C4: Post-implementation gates (audit, z3-check, structural-checks, pre-pr-gate, regression-check) all clean before review-prep.
- C5: Single stacked feature branch with one commit per issue; PR created via git-workflow-pr.

## Pre-Implementation Steps

- [ ] 1. Coherence gate — verify plan fidelity to spec
  - Confirm every SC-01..SC-09 maps to exactly one item in exactly one phase per the structure artifact; confirm the phase DAG is acyclic (phase-1 → phase-2; phase-3 → phase-4; phase-3 → phase-5).
  - Confirm the verification ledger exists at `.opencode/.issues/2432/artifacts/plan-input-verification.md` and record the gate outcome.
  - (**direct**)
- [ ] 2. Baseline check — verify clean starting state
  - Run `git status --porcelain` in `.opencode` and the parent repo; both must be clean.
  - Run `./.opencode/tools/local-issues read .opencode#2432` and confirm the spec is readable; run the existing test suite baseline `uv run pytest .opencode/tests/` and record pass/fail counts.
  - Create the feature branch per git-workflow pre-work (requires `for_implementation`+ scope — `approved-for-pr` label satisfies this).
  - (**direct**)
- [ ] 3. Pre-regression — run regression test patterns before RED phase
  - (**task-card** — dispatch `test-driven-development` phase-0 task: `task(..., prompt: "execute phase-0 task from test-driven-development")`)
- [ ] 4. Pre-regression verify — verify pre-regression results
  - (**task-card** — dispatch `verification-before-completion` verify task: `task(..., prompt: "execute verify task from verification-before-completion")`)

## Phase 1 — Qualifier enforcement + PROJECT_DIR anchoring

- **Concern:** tool-core identity layer of `local-issues`.
- **Files:** `.opencode/tools/local-issues` (qualifier-resolution and identity/discovery layers), new pytest module under `.opencode/tests/`, in-repo consumer sweep targets (skill/task files invoking bare numbers).
- **SCs:** SC-01, SC-02.
- **Dependencies:** none (first phase).
- **Entry:** pre-implementation steps 1-4 complete; baseline tests recorded.
- **Exit:** SC-01 and SC-02 verified PASS; two commits landed on the feature branch.

### Code Path Coverage

- Qualifier-resolution layer: argument parsing and `repo#N` resolution on every subcommand, including the read family (`read`, `read-comments`, `read-labels`, `read-sub-issues`) and `create`.
- Identity/discovery layer: `_resolve_repo_name` (CWD-derived today) and `_discover_all_repos` (must root at `PROJECT_DIR`, `.gitmodules`-only children).

### Cross-Cutting SCs

- None — both items are confined to the identity/discovery concern.

### Interface Boundaries

- CLI surface is BREAKING: bare numbers exit non-zero with a stderr qualifier listing; `create --number` REQUIRED and qualified; auto-number path removed (R-1, R-2, R-14; no shims).

### State Transitions

- None — read/resolve-only concern; no persisted state changes in this phase.

### Step-by-step

- [ ] 5. RED for item 1 (SC-01) — qualifier enforcement on all commands
  - Write a unit test invoking the read family and `create` with a bare number; assert non-zero exit plus a stderr qualifier listing. The test FAILS because bare numbers are currently accepted.
  - (**task-card** — `task(..., prompt: "execute red task from test-driven-development")`)
- [ ] 6. GREEN for item 1 (SC-01)
  - Make read-family commands and `create` resolve only from an explicit `repo#N` qualifier; bare numbers exit non-zero with the qualifier listing; mutation-command enforcement untouched. Sweep in-repo consumers to the qualified form (no shims).
  - (**task-card** — `task(..., prompt: "execute green task from test-driven-development")`)
- [ ] 7. Post-regression for item 1 (SC-01)
  - (**task-card** — `task(..., prompt: "execute phase-4 task from test-driven-development")`)
- [ ] 8. Verify item 1 (SC-01)
  - (**task-card** — `task(..., prompt: "execute verify task from verification-before-completion")`)
- [ ] 9. Commit item 1 (SC-01) — qualifier-resolution layer changes + tests, single commit
  - (**direct** — orchestrator runs `git add <files> && git commit -m "<message>"` directly; no sub-agent dispatch)
- [ ] 10. RED for item 2 (SC-02) — PROJECT_DIR anchoring of identity + discovery
  - Write a unit test resolving the same qualifier from two CWDs (project root vs nested subdirectory) asserting identical identity/discovery results. FAILS while identity is CWD-derived.
  - (**task-card** — `task(..., prompt: "execute red task from test-driven-development")`)
- [ ] 11. GREEN for item 2 (SC-02)
  - `_resolve_repo_name` returns the anchored project name; `_discover_all_repos` roots at `PROJECT_DIR` with `.gitmodules`-only child discovery preserved.
  - (**task-card** — `task(..., prompt: "execute green task from test-driven-development")`)
- [ ] 12. Post-regression for item 2 (SC-02)
  - (**task-card** — `task(..., prompt: "execute phase-4 task from test-driven-development")`)
- [ ] 13. Verify item 2 (SC-02)
  - (**task-card** — `task(..., prompt: "execute verify task from verification-before-completion")`)
- [ ] 14. Commit item 2 (SC-02) — identity/discovery layer changes + tests, single commit (depends on item 1's commit)
  - (**direct** — orchestrator runs `git add <files> && git commit -m "<message>"` directly; no sub-agent dispatch)

### Phase Completion Block

- Verify SC-01 and SC-02 verdicts are PASS with behavioral evidence before advancing to Phase 2.
- Daisy-chain check: item 1's commit precedes item 2's RED.

**Cost frame:** Running the qualifier and multi-CWD unit tests costs minutes of execution time — defects surface at the earliest gate and fixes cost the same bounded delay. Skipping costs weeks of silent misrouted operations — every bare-number consumer fans out to the wrong repo, compounding into counter drift and wrong-repo writes discovered only during data forensics. Correctness is the only metric.

## Phase 2 — Bootstrap remediation + counter hygiene + doctor

- **Concern:** tool-core infrastructure layer of `local-issues`.
- **Files:** `.opencode/tools/local-issues` (worktree bootstrap layer, create path, subcommand registration), pytest module under `.opencode/tests/`.
- **SCs:** SC-03, SC-04, SC-08.
- **Dependencies:** Phase 1 (items 3, 4, 8 depend on qualifier resolution + anchoring).
- **Entry:** Phase 1 committed; SC-01/SC-02 verified.
- **Exit:** SC-03, SC-04, SC-08 verified PASS; three commits landed.

### Code Path Coverage

- Worktree bootstrap layer: `_issues_branch_exists` (local-refs-only today) and the orphan-branch creation path.
- Create path: counter write targeting (`_next_number` reservation flow retained; counter file format unchanged).
- Subcommand registration: new read-only `doctor` subcommand.

### Cross-Cutting SCs

- R-5 spans SC-04 and SC-05: the counter keeps fail-fast (missing creates at 1; corrupt exits FATAL) — warn-and-skip never applies to control state. Asserted in Phase 2 item 4 and re-asserted in Phase 3 item 5.

### Interface Boundaries

- `doctor` output is machine-greppable per-repo health markers (R-12); doctor never mutates state (R-11).
- Counter format preserved; only write targeting changes (R-7).

### State Transitions

- Bootstrap: no-local-branch + remote-present state → fetch + track (new); neither-exists → orphan (unchanged).
- Counter: missing → created at 1; corrupt → FATAL exit (both unchanged in behavior, retargeted in path).

### Step-by-step

- [ ] 15. RED for item 3 (SC-03) — worktree bootstrap remote-tracking remediation
  - Write a unit test with a repo holding `origin/issues-data` but no local branch; assert no orphan created and a remote-tracked branch checked out. FAILS while bootstrap checks only local refs.
  - (**task-card** — `task(..., prompt: "execute red task from test-driven-development")`)
- [ ] 16. GREEN for item 3 (SC-03)
  - Bootstrap checks the remote ref, fetches and tracks when present, falls back to the orphan path only when no remote branch exists; fetch failure warns and falls back.
  - (**task-card** — `task(..., prompt: "execute green task from test-driven-development")`)
- [ ] 17. Post-regression for item 3 (SC-03)
  - (**task-card** — `task(..., prompt: "execute phase-4 task from test-driven-development")`)
- [ ] 18. Verify item 3 (SC-03)
  - (**task-card** — `task(..., prompt: "execute verify task from verification-before-completion")`)
- [ ] 19. Commit item 3 (SC-03) — worktree bootstrap layer changes + tests, single commit
  - (**direct** — orchestrator runs `git add <files> && git commit -m "<message>"` directly; no sub-agent dispatch)
- [ ] 20. RED for item 4 (SC-04) — counter hygiene
  - Write a unit test creating with the `.opencode` qualifier; assert the `.opencode` counter incremented and the root counter byte-identical. FAILS while create always targets the root counter.
  - (**task-card** — `task(..., prompt: "execute red task from test-driven-development")`)
- [ ] 21. GREEN for item 4 (SC-04)
  - Create resolves the counter path from the qualifier-resolved repo; missing counter creates at 1; corrupt counter stays FATAL.
  - (**task-card** — `task(..., prompt: "execute green task from test-driven-development")`)
- [ ] 22. Post-regression for item 4 (SC-04)
  - (**task-card** — `task(..., prompt: "execute phase-4 task from test-driven-development")`)
- [ ] 23. Verify item 4 (SC-04)
  - (**task-card** — `task(..., prompt: "execute verify task from verification-before-completion")`)
- [ ] 24. Commit item 4 (SC-04) — create-path changes + tests, single commit
  - (**direct** — orchestrator runs `git add <files> && git commit -m "<message>"` directly; no sub-agent dispatch)
- [ ] 25. RED + GREEN + verify for item 8 (SC-08) — doctor subcommand
  - RED: unit test with a fixture missing a local branch reports an unhealthy branch marker — FAILS while the subcommand does not exist. (`task(..., prompt: "execute red task from test-driven-development")`)
  - GREEN: subcommand emits per-repo health markers (branch state, merge-base delta vs `origin/issues-data`, counter state, worktree presence) for the root and all discovered repos, read-only; read-only invariant asserted via repo-state hash comparison before/after. (`task(..., prompt: "execute green task from test-driven-development")`)
  - Verify: `task(..., prompt: "execute verify task from verification-before-completion")`
  - (**task-card** — three dispatches, one per cycle step, in sequence)
- [ ] 26. Post-regression for item 8 (SC-08)
  - (**task-card** — `task(..., prompt: "execute phase-4 task from test-driven-development")`)
- [ ] 27. Commit item 8 (SC-08) — new subcommand + registration + tests, single commit
  - (**direct** — orchestrator runs `git add <files> && git commit -m "<message>"` directly; no sub-agent dispatch)

### Phase Completion Block

- Verify SC-03, SC-04, SC-08 verdicts are PASS with behavioral evidence before advancing.
- Daisy-chain check: each item's commit precedes the next item's RED.

**Cost frame:** Running the bootstrap fixture and counter-targeting tests costs minutes. Skipping costs the unrelated-histories orphan class — a diverged issues-data branch requiring manual history surgery — and silent cross-repo counter corruption surfacing as duplicate or skipped issue numbers discovered late. Correctness is the only metric.

## Phase 3 — YAML warn-and-skip hardening + validate-yaml

- **Concern:** parse gate layer of `local-issues`.
- **Files:** `.opencode/tools/local-issues` (parse layer, subcommand registration), pytest module under `.opencode/tests/`.
- **SCs:** SC-05, SC-06.
- **Dependencies:** none (parallel-safe with Phases 1-2; must complete before Phases 4-5).
- **Entry:** baseline tests recorded.
- **Exit:** SC-05 and SC-06 verified PASS; two commits landed; exit-code contract (0 clean / 1 malformed) fixed and stable.

### Code Path Coverage

- Parse layer: `yaml_load` (bare parse today, zero exception handling at all call sites) and the shared error-class taxonomy.
- Subcommand registration: new `validate-yaml` subcommand reusing the SC-05 error classification.

### Cross-Cutting SCs

- R-5 boundary: the counter is control state and keeps fail-fast; warn-and-skip applies only to content tracking files (data class boundary asserted in item 5).
- R-12: `validate-yaml` output is machine-greppable (`<path>: <error-class>` lines).

### Interface Boundaries

- `validate-yaml` exit-code contract fixed BEFORE its consumers (Phase 4 repair, Phase 5 pipeline gate): exit 0 clean, exit 1 malformed found, never mutates files (R-8).

### State Transitions

- Parse: malformed content file → stderr warning (path + error class) + skip/empty result; iteration paths skip malformed records and complete; valid files in the same tree still parsed.

### Step-by-step

- [ ] 28. RED for item 5 (SC-05) — YAML parse hardening (warn-and-skip)
  - Write a unit test running list/search/read over a fixture with malformed YAML (one malformed file per error class plus valid files); assert exception-free completion with stderr warnings. FAILS while `yaml_load` raises.
  - (**task-card** — `task(..., prompt: "execute red task from test-driven-development")`)
- [ ] 29. GREEN for item 5 (SC-05)
  - `yaml_load` catches parse errors, warns to stderr with file path and error class, returns skip/empty results; iteration paths skip malformed records; counter fail-fast untouched.
  - (**task-card** — `task(..., prompt: "execute green task from test-driven-development")`)
- [ ] 30. Post-regression for item 5 (SC-05)
  - (**task-card** — `task(..., prompt: "execute phase-4 task from test-driven-development")`)
- [ ] 31. Verify item 5 (SC-05)
  - (**task-card** — `task(..., prompt: "execute verify task from verification-before-completion")`)
- [ ] 32. Commit item 5 (SC-05) — parse-layer changes + tests, single commit
  - (**direct** — orchestrator runs `git add <files> && git commit -m "<message>"` directly; no sub-agent dispatch)
- [ ] 33. RED for item 6 (SC-06) — validate-yaml subcommand
  - Write a unit test on a fixture tree with known-bad files asserting exit 1 plus `<path>: <class>` report lines. FAILS while the subcommand does not exist.
  - (**task-card** — `task(..., prompt: "execute red task from test-driven-development")`)
- [ ] 34. GREEN for item 6 (SC-06)
  - Subcommand walks issue directories, reuses the SC-05 error classification, prints the report, and applies the exit-code gate (0 clean / 1 malformed); never mutates files.
  - (**task-card** — `task(..., prompt: "execute green task from test-driven-development")`)
- [ ] 35. Post-regression for item 6 (SC-06)
  - (**task-card** — `task(..., prompt: "execute phase-4 task from test-driven-development")`)
- [ ] 36. Verify item 6 (SC-06)
  - (**task-card** — `task(..., prompt: "execute verify task from verification-before-completion")`)
- [ ] 37. Commit item 6 (SC-06) — new subcommand + registration + tests, single commit
  - (**direct** — orchestrator runs `git add <files> && git commit -m "<message>"` directly; no sub-agent dispatch)

### Phase Completion Block

- Verify SC-05 and SC-06 verdicts are PASS with behavioral evidence before advancing to Phases 4 and 5.
- Confirm the exit-code contract is recorded and stable for downstream consumers.

**Cost frame:** Running the malformed-YAML fixture and gate tests costs minutes. Skipping costs a tool-wide outage on every command touching one bad file, and leaves the repair pass and pipeline gate without a verification contract — both consumers then verify nothing while malformed data flows into plans and specs undetected. Correctness is the only metric.

## Phase 4 — Malformed tracking file repair

- **Concern:** repair of the 10 confirmed malformed tracking files, gated by `validate-yaml`.
- **Files:** live tracking data in `.opencode/.issues/{1204,1205,1235,1296,1305,2013,2177}/issue.yaml`, `.opencode/.issues/{1296,2013}/comments.yaml`, `.issues/162/comments.yaml`; flag report artifact.
- **SCs:** SC-07.
- **Dependencies:** Phase 3 (item 7 is gated by `validate-yaml`, item 6).
- **Entry:** Phase 3 committed; `validate-yaml` exit-code contract stable.
- **Exit:** SC-07 verified PASS; post-repair `validate-yaml` exits 0 for core files; flag report lists semantic cases; before/after evidence retained; repairs committed only on issues-data worktree branches.

### Code Path Coverage

- Repair transforms: legacy GitHub-export mapping, markdown-comment mapping, ANSI-escape cleanup, truncation repair — mechanical only (R-9).

### Cross-Cutting SCs

- R-10: repair commits land on the issues-data worktree branches via the tool's auto-commit; repairs never appear as parent-repo tracked changes.

### Interface Boundaries

- `validate-yaml` is the gate: pre-repair run reports the 10 files; post-repair run exits 0 for core files.

### State Transitions

- Content files: malformed → parsed-clean (mechanical transform) or left malformed + flagged (semantic/unrecoverable cases — flag, don't guess).

### Step-by-step

- [ ] 38. RED for item 7 (SC-07) — pre-repair gate evidence
  - Run `validate-yaml` over the live repos; record the pre-repair report listing the 10 confirmed malformed files as RED evidence.
  - (**task-card** — `task(..., prompt: "execute red task from test-driven-development")`)
- [ ] 39. GREEN for item 7 (SC-07) — mechanical transforms + flag report
  - Apply mechanical transforms to the confirmed files (legacy GitHub-export mapping, markdown-comment mapping, ANSI-escape cleanup, truncation repair); list semantic cases in a flag report and leave them as-is; retain before/after evidence.
  - (**task-card** — `task(..., prompt: "execute green task from test-driven-development")`)
- [ ] 40. Post-regression for item 7 (SC-07)
  - (**task-card** — `task(..., prompt: "execute phase-4 task from test-driven-development")`)
- [ ] 41. Verify item 7 (SC-07) — post-repair gate
  - Post-repair `validate-yaml` exits 0 for core files; flag report asserted to list semantic cases without rewriting them.
  - (**task-card** — `task(..., prompt: "execute verify task from verification-before-completion")`)
- [ ] 42. Retain before/after evidence
  - Store pre/post `validate-yaml` reports and the flag report under `tmp/2432/` as behavioral evidence artifacts.
  - (**direct**)
- [ ] 43. Confirm parent repo clean
  - `git status --porcelain` in the parent repo must show no repair-related tracked changes.
  - (**direct**)
- [ ] 44. Commit item 7 (SC-07) — data repair on issues-data worktree branches only
  - Commits land via the tool's auto-commit on the issues-data worktree branches (R-10); the orchestrator does NOT create a parent-repo commit for repair data.
  - (**direct** — tool-driven auto-commit; no sub-agent dispatch)

### Phase Completion Block

- Verify SC-07 verdict is PASS with before/after behavioral evidence.
- Confirm repairs exist only on issues-data worktree branches.

**Cost frame:** Running the before/after validate-yaml integration gate costs minutes. Skipping costs unrepaired malformed files feeding every read/list/search path indefinitely, plus the risk of unreviewed semantic rewrites — which is why semantic cases are flagged, not guessed. Correctness is the only metric.

## Phase 5 — Pipeline validate-yaml gate insertion

- **Concern:** integration of the `validate-yaml` gate into the spec-creation and writing-plans task cards.
- **Files:** `.opencode/skills/spec-creation/tasks/` (analyze, create) and `.opencode/skills/writing-plans/tasks/` task cards; behavioral test scenario under `.opencode/tests-v2/`.
- **SCs:** SC-09.
- **Dependencies:** Phase 3 (the gate references the `validate-yaml` subcommand, item 6).
- **Entry:** Phase 3 committed; `validate-yaml` available.
- **Exit:** SC-09 verified PASS via behavioral harness; task-card edits structurally confirmed; commit landed.

### Code Path Coverage

- Task-card edit path: append the `validate-yaml` invocation after artifact generation with a BLOCKED result contract on exit 1 (R-13).

### Cross-Cutting SCs

- None — single-item integration phase.

### Interface Boundaries

- BLOCKED result contract on gate exit 1; behavioral verification per the behavioral-variant discipline (stderr-pattern assertions, commit+push before the behavioral run).

### State Transitions

- Task cards: no gate → gate invocation after artifact generation; gate exit 1 → BLOCKED result contract.

### Step-by-step

- [ ] 45. Commit+push precondition for the behavioral run
  - Ensure any prior-phase commits are pushed and the effective commit is contained in a remote ref (fresh `git fetch` verification) — behavioral runs MUST NOT execute on unpushed state.
  - (**direct**)
- [ ] 46. RED for item 9 (SC-09) — behavioral, with-test-home harness
  - Run an artifact-generation scenario through the isolated harness (`bash .opencode/tests-v2/with-test-home opencode run '<message>'`); assert the gate is absent (agent does not invoke `validate-yaml`). FAILS before the change.
  - (**task-card** — `task(..., prompt: "execute red task from test-driven-development")`)
- [ ] 47. GREEN for item 9 (SC-09) — task-card edits
  - spec-creation (analyze, create) and writing-plans task cards append the `validate-yaml` invocation with a BLOCKED result contract on exit 1.
  - (**task-card** — `task(..., prompt: "execute green task from test-driven-development")`)
- [ ] 48. Commit + push the task-card change before the behavioral re-run
  - (**direct** — orchestrator runs `git add <files> && git commit -m "<message>"` then pushes; fresh `git fetch` verifies containment in a remote ref)
- [ ] 49. Behavioral re-run for item 9 (SC-09)
  - (**task-card** — `task(..., prompt: "execute phase-4 task from test-driven-development")`)
- [ ] 50. Verify item 9 (SC-09) — behavioral re-run + structural check
  - Behavioral test re-run asserts gate invocation; structural check confirms task-card edits.
  - (**task-card** — `task(..., prompt: "execute verify task from verification-before-completion")`)
- [ ] 51. Commit item 9 (SC-09) — task-card changes + behavioral test, single commit
  - (**direct** — orchestrator runs `git add <files> && git commit -m "<message>"` directly; no sub-agent dispatch)

**Cost frame:** Running the behavioral gate test costs minutes of model execution time. Skipping costs the death spiral — a skipped pipeline gate lets malformed artifacts flow into plans and specs, where the defect surfaces downstream at 100×–1000× the cost of the behavioral test that would have caught it. Correctness is the only metric.

## Phase 6 — Session-resumption mandate + shared test home

- **Concern:** test-framework defect fix — surface the resumption mandate at the point of timeout-kill as framework-agnostic behavioral rules (SC-10), make cross-invocation resumption possible via an implementation-agnostic capability contract (SC-11), and mandate deliberation review of behavioral test evidence over whatever reasoning/deliberation evidence the session store provides (SC-12). Evidence: 14 isolated-harness runs aborted over ~7h during SC-09 behavioral testing; two bash-tool-timeout kills were recoverable via §10.7 resumption (documented PRIMARY path; full re-run prohibited per line 677) but the agent never applied it.
- **Files:** test-driven-development task cards under `.opencode/skills/test-driven-development/tasks/` (red, green, post-regression), behavioral scenario scripts under `.opencode/tests-v2/behaviors/`, `.opencode/tests-v2/with-test-home`, `.opencode/tests-v2/AGENTS.md` (§10.7/§14 cross-reference updates), `.opencode/tools/session-to-timeline` (deliberation-evidence source for SC-12).
- **SCs:** SC-10, SC-11, SC-12.
- **Dependencies:** Phase 3 (harness availability); SC-11 builds on SC-10's instruction surfacing for end-to-end usefulness; SC-12 builds on Items 10-11 for session-evidence availability.
- **Entry:** Phase 3 committed; isolated harness operational.
- **Exit:** SC-10, SC-11, and SC-12 verified PASS via behavioral harness; timeout-recovery scenario asserts resumption dispatch; resume-after-timeout scenario asserts prior session-state reachability; deliberation-review scenario asserts deliberation-evidence inspection; commits landed.

### Code Path Coverage

- Task-card edit path: RED/GREEN/post-regression cards gain the resumption directive at the timeout-recovery decision point, expressed as framework-agnostic behavioral rules (R-15) — resume when the session store survives, never blind-restart; no hardcoded flags or paths.
- Harness provisioning path: the harness gains a resumption capability satisfying the contract — a test home that survives across invocations and exposes prior session state to the harness (R-16). Implementation-agnostic: any mechanism (stable home path per scenario, explicit resume option, or equivalent) qualifies; no language, storage engine, or CLI surface is mandated.
- Evidence-review path: review instructions gain the deliberation-review directive — inspect whatever reasoning/deliberation evidence the session store provides (reasoning events/thinking traces in session evidence, via `session-to-timeline` where applicable) for excessive deliberation, false starts, off-track reasoning, and prompt/fixture-induced derailment (R-17); schema- and provider-agnostic. The instructions additionally gain the excessive-run-time defect-signal rule (R-18): when a behavioral run takes excessively long (repeated timeouts, monitor aborts, large single-turn reasoning blocks, budget exhaustion), the reviewer traces the cause to instructions, task-card/skill-deck wording, prompt construction, fixture state, or harness behavior; identified fixes are folded in as an SC revision or an additional spec, implemented on the stacked feature branch, tested for effectiveness, adjusted, and the pipeline continues only after the fix is verified effective.

### Cross-Cutting SCs

- R-15 spans SC-10's task-card and scenario-script edits: blind restart after an interrupt is marked PROHIBITED, mirroring tests-v2 AGENTS.md line 677.
- R-16: fresh-invocation behavior (new test home per invocation) is unchanged when resumption is not requested.

### Interface Boundaries

- Resumption requires a prior invocation's session state; missing-session resumption fails fast with a clear error naming the missing session/test home. Corrupted/unreadable session store on resume reports FATAL naming the store path (control-state fail-fast, R-5 analog).

### State Transitions

- Timeout kill → surviving session store → the harness's resumption capability resumes prior session state (new path); without resumption requests, per-invocation provisioning unchanged.

### Step-by-step

- [ ] 60. Commit+push precondition for the behavioral runs
  - Ensure prior-phase commits are pushed and the effective commit is contained in a remote ref (fresh `git fetch` verification).
  - (**direct**)
- [ ] 61. RED for item 10 (SC-10) — behavioral, with-test-home harness
  - Run a timeout-kill recovery scenario through the isolated harness; assert the resumption instruction is absent (executing agent does not dispatch session resumption after a timeout kill — full re-run attempted instead). FAILS before the change.
  - (**task-card** — `task(..., prompt: "execute red task from test-driven-development")`)
- [ ] 62. GREEN for item 10 (SC-10) — task-card / scenario-script edits
  - test-driven-development RED/GREEN/post-regression task cards (and/or behavioral scenario scripts) add the resumption directive at the timeout-recovery decision point, expressed as framework-agnostic behavioral rules: resume the surviving session whenever the session store survives — never a blind restart; blind restart after an interrupt marked PROHIBITED. No specific flags or paths hardcoded; the rule references whatever resumption mechanism the harness provides.
  - (**task-card** — `task(..., prompt: "execute green task from test-driven-development")`)
- [ ] 63. Commit + push the SC-10 change before the behavioral re-run
  - (**direct** — orchestrator runs `git add <files> && git commit -m "<message>"` then pushes; fresh `git fetch` verifies containment in a remote ref)
- [ ] 64. Behavioral re-run + verify for item 10 (SC-10)
  - Re-run the timeout-recovery scenario asserting resumption dispatch; structural check confirms task-card/scenario-script edits carry the resumption rule.
  - (**task-card** — `task(..., prompt: "execute phase-4 task from test-driven-development")` then `task(..., prompt: "execute verify task from verification-before-completion")`)
- [ ] 65. Commit item 10 (SC-10) — task-card/scenario-script changes + behavioral test, single commit
  - (**direct** — orchestrator runs `git add <files> && git commit -m "<message>"` directly; no sub-agent dispatch)
- [ ] 66. RED for item 11 (SC-11) — behavioral, with-test-home harness
  - Interrupt a run by timeout then resume via the harness's resumption capability; assert the resumed run cannot reach the prior invocation's session state (a new test home is provisioned). FAILS while test homes are per-invocation (§14).
  - (**task-card** — `task(..., prompt: "execute red task from test-driven-development")`)
- [ ] 67. GREEN for item 11 (SC-11) — harness provisioning changes
  - The harness gains a resumption capability satisfying the capability contract: a test home that survives across invocations and exposes prior session state, so the resumed invocation targets the prior invocation's session state; harness integration updated so resumption picks up where the agent left off per §10.7 line 623; AGENTS.md §10.7/§14 cross-references updated. Implementation-agnostic — any mechanism meeting the capability contract qualifies; no language, storage engine, or CLI surface is mandated.
  - (**task-card** — `task(..., prompt: "execute green task from test-driven-development")`)
- [ ] 68. Commit + push the SC-11 change before the behavioral re-run
  - (**direct** — orchestrator runs `git add <files> && git commit -m "<message>"` then pushes; fresh `git fetch` verifies containment in a remote ref)
- [ ] 69. Behavioral re-run for item 11 (SC-11) — resume-after-timeout scenario
  - Assert the resumed run reuses the prior invocation's test home / session state rather than provisioning a fresh one; prior session state asserted reachable post-resume; fresh-invocation behavior unchanged when resumption is not requested.
  - (**task-card** — `task(..., prompt: "execute phase-4 task from test-driven-development")`)
- [ ] 70. Verify item 11 (SC-11)
  - (**task-card** — `task(..., prompt: "execute verify task from verification-before-completion")`)
- [ ] 71. Commit item 11 (SC-11) — `with-test-home` changes + harness docs + behavioral test, single commit
  - (**direct** — orchestrator runs `git add <files> && git commit -m "<message>"` directly; no sub-agent dispatch)
- [ ] 72. RED for item 12 (SC-12) — deliberation-review mandate, behavioral, with-test-home harness
  - Run an evidence-review scenario through the isolated harness; assert the deliberation review is absent (the reviewing agent inspects tool-call output only and does not inspect the run agent's deliberation evidence) and no excessive-run-time cause tracing occurs (long run time accepted without tracing to instructions/task-card wording/prompt construction/fixture state/harness behavior). FAILS before the change.
  - (**task-card** — `task(..., prompt: "execute red task from test-driven-development")`)
- [ ] 73. GREEN for item 12 (SC-12) — review-instruction edits
  - Evidence-review instructions (test-driven-development post-regression/verify task cards and/or behavioral scenario scripts) add the deliberation-review directive: inspect whatever reasoning/deliberation evidence the session store provides — reasoning events/thinking traces in the session evidence, defined generically, schema- and provider-agnostic — for excessive deliberation (reasoning budget burned on loops/surveys before productive tool calls), false starts (abandoned investigation paths), off-track reasoning, and prompt/fixture-induced derailment; findings recorded and routed to test-scenario and prompt adjustments. The instructions additionally add the excessive-run-time defect-signal rule (R-18): when a behavioral run takes excessively long (repeated timeouts, monitor aborts, large single-turn reasoning blocks, budget exhaustion), the reviewer traces the cause to instructions, task-card/skill-deck wording, prompt construction, fixture state, or harness behavior; identified fixes are folded in as an SC revision or an additional spec, implemented on the stacked feature branch, tested for effectiveness, adjusted, and the pipeline continues only after the fix is verified effective.
  - (**task-card** — `task(..., prompt: "execute green task from test-driven-development")`)
- [ ] 74. Commit + push the SC-12 change before the behavioral re-run
  - (**direct** — orchestrator runs `git add <files> && git commit -m "<message>"` then pushes; fresh `git fetch` verifies containment in a remote ref)
- [ ] 75. Behavioral re-run for item 12 (SC-12) — deliberation-review scenario
  - Assert the review output names the inspected deliberation-evidence source and reports identified test-effectiveness findings; absent deliberation evidence is recorded as such (never fabricated). An excessive-run-time signal scenario asserts cause tracing to the identified defect classes and fix-folding (SC revision or additional spec + stacked-branch implementation).
  - (**task-card** — `task(..., prompt: "execute phase-4 task from test-driven-development")`)
- [ ] 76. Verify item 12 (SC-12)
  - Behavioral re-run asserts deliberation-evidence inspection and excessive-run-time cause tracing with fix-folding; structural check confirms the review instructions reference both the deliberation-review mandate and the excessive-run-time defect-signal rule.
  - (**task-card** — `task(..., prompt: "execute verify task from verification-before-completion")`)
- [ ] 77. Commit item 12 (SC-12) — review-instruction changes + behavioral test, single commit
  - (**direct** — orchestrator runs `git add <files> && git commit -m "<message>"` directly; no sub-agent dispatch)
- [ ] 78. (reserved — end of Phase 6 step range; SC-12 complete)

### Phase Completion Block

- Verify SC-10, SC-11, and SC-12 verdicts are PASS with behavioral evidence.
- Daisy-chain check: SC-10's commit precedes SC-11's RED; SC-11's commit precedes SC-12's RED.

### Post-Implementation Steps (end of plan)

> These gates run after Phase 6 (all twelve SCs verified). Post-implementation step numbers (52-59) were assigned when the plan had five phases; they are unchanged and remain the final sequence.

- [ ] 52. Audit — adversarial audit of the deliverable
  - (**task-card** — `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by validator, evaluator, arbiter in sequence)
- [ ] 53. Z3 check — run constraint solver verification
  - (**direct** — orchestrator runs `.opencode/tools/solve check --state-path ... --contract-path ...` directly; no sub-agent dispatch)
- [ ] 54. Structural checks — finishing checklist
  - (**task-card** — `task(..., prompt: "execute checklist task from finishing-a-development-branch")`)
- [ ] 55. Pre-PR gate — verify all SC verdicts before PR creation
  - (**task-card** — `task(..., prompt: "execute verify task from verification-before-completion")` — reads all SC verdicts, BLOCKs if any FAIL)
- [ ] 56. Regression check — final regression before PR
  - (**task-card** — `task(..., prompt: "execute phase-4 task from test-driven-development")`)
- [ ] 57. Review prep — prepare PR review context
  - (**task-card** — `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`)
- [ ] 58. Create PR — stacked PR targeting the trunk
  - (**task-card** — `task(..., prompt: "execute create task from git-workflow-pr")`)
- [ ] 59. Executive summary — completion report
  - (**task-card** — `task(..., prompt: "execute completion task from completion-core")`)

### Phase Completion Block

- Verify SC-09 and SC-10/SC-11 verdicts are PASS with behavioral evidence; all post-implementation gates clean before PR creation.

---

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)

## lifecycle_events

- timestamp: 2026-09-15T14:11:01Z
  event: plan_created
  plan_file: .opencode/.issues/2432/plan.md
  phase_count: 5
- timestamp: 2026-09-15T23:30:00Z
  event: plan_revised
  plan_file: .opencode/.issues/2432/plan.md
  phase_count: 6
  reason: "Developer directive during for_pr execution — SC-09 behavioral testing exposed timeout-recovery defect; added SC-10/SC-11 (Phase 6: session-resumption mandate + shared test home)"
- timestamp: 2026-09-15T23:55:00Z
  event: plan_revised
  plan_file: .opencode/.issues/2432/plan.md
  phase_count: 6
  reason: "Developer directive — second addition to the SC-10/SC-11 revision; added SC-12 (deliberation-review mandate, R-17, Phase 6 steps 72-77): behavioral test evidence review MUST inspect the run agent's reasoning traces for test-effectiveness findings"
- timestamp: 2026-09-16T00:00:00Z
  event: plan_revised
  plan_file: .opencode/.issues/2432/plan.md
  phase_count: 6
  reason: "Developer directive — third addition: constrained SC-10/SC-11/SC-12 (R-15/R-16/R-17, verification methods, Phase 6 steps 61-77) to be holistic and implementation-agnostic — framework-agnostic resumption rules (SC-10), capability-contract test-home survival (SC-11), schema/provider-agnostic deliberation review (SC-12); no criterion weakened; SC-01..SC-09 unchanged"
- timestamp: 2026-09-16T03:00:00Z
  event: plan_revised
  plan_file: .opencode/.issues/2432/plan.md
  phase_count: 6
  reason: "Developer directive (2026-09-16) — extended the SC-12 deliberation-review mandate (R-17) with R-18: the deliberation/effectiveness review MUST treat excessive run time as a primary defect signal (repeated timeouts, monitor aborts, large single-turn reasoning blocks, budget exhaustion) and trace the cause to instructions, task-card/skill-deck wording, prompt construction, fixture state, or harness behavior; fixes folded in as SC revision or additional spec, implemented on the stacked feature branch, tested for effectiveness, adjusted before the pipeline continues. Updated Goal, Phase 6 concern/code-path wording, and Item 12 steps 72-76; SC-01..SC-12 preserved"
