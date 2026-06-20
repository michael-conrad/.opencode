# Plan: Behavioral Test Harness Fix — Unified Entry Point, Correct Nesting, Per-Test Hooks

**Parent spec:** [`.opencode#1307`](https://github.com/michael-conrad/.opencode/issues/1307)
**Status:** PLANNED
**Scope:** Single concern — behavioral test harness architecture refactoring. All three phases in one plan per unified pipeline path rule.

**Authorization cascade:** Approved by michael-conrad for `.opencode#1307` (spec → plan). Plan faithfully reflects the spec. Auto-approved via cascading approval-gate-001a-cascade. Implementation authorization NOT granted — next step: `approved-for-implementation`.

## Dependency Order

**Phase 1 → Phase 2 → Phase 3.** Each phase's items must complete before advancing to the next. Phase 3 (documentation) is the final gate — changes are not released until all docs are consistent.

---

## Phase 1: Core Architecture — test project nesting and single-entry enforcement

Items P1-1 through P1-4 implement structural changes. Items run TDD cycle per item (RED → GREEN → REFACTOR → COMMIT). Each item is one actionable step (2-5 min execution time).

### P1-1: Modify `behavior_run` to create test project inside test home

**Dependency:** None in this plan. Independent first step in core architecture.
**Why first:** Nesting change is the highest-risk structural change — all other items depend on it being stable.

**Implementation tasks (execute as a single work unit per item):**
1. Read `with-test-home` to understand current setup logic (`--setup` mode and test home creation)
2. Read `helpers.sh` to understand how `behavior_run` currently invokes the setup
3. Modify `with-test-home --setup` to set `TEST_PROJECT_DIR=$TEST_HOME/test-project/` (new variable exported alongside `TEST_HOME`)
4. In `helpers.sh` / `behavior_run`, after `--setup` confirms success, create `$TEST_PROJECT_DIR/` with `.opencode/` subdirectory skeleton
5. Add `__setup_test_project()` function in `with-test-home`:
   - Creates `test-project/.opencode/` as cloned submodule (same mechanism as current project clone)
   - Seeds local `.issues/` if needed
   - Sets `$TEST_PROJECT_DIR` for downstream use
6. Verify test home directory now contains `test-project/` with `.opencode/` inside, not sibling at `tmp/behavior-isolated-*`

**Verification:** P1-1 behavioral test: run a minimal scenario script; confirm `$TEST_HOME/test-project/.opencode/` exists and is a valid git repo pointing to the `.opencode` submodule. Structural check: `ls $TEST_HOME/test-project/.opencode/` shows module contents.

### P1-2: Update `with-test-home` to validate CWD has `.opencode/`

**Dependency:** P1-1 (nesting must exist before enforcement can be added)
**Why second:** Enforcement depends on nesting being operational first.

**Implementation tasks:**
1. Modify the command execution path in `with-test-home` (the `--keep` / default case):
   - Before executing `<command>`, check that `$(pwd)/.opencode/` exists as a directory
   - If absent, print usage error to stderr and `exit 2` with a clear message: "Error: CWD does not contain .opencode/. Must be run from a test project directory."
2. Add check in `do_run()` (or equivalent command path) before any `eval "$@"` call

**Verification:** P1-2 behavioral test: run `with-test-home echo hello` from `/tmp` — confirm it exits with error code 2 and prints the clear error message. Structural: verify exit code via `assert_exit_code 2`.

### P1-3: Update artifact paths to resolve relative to test project

**Dependency:** P1-1 (nesting must exist before artifact path adjustments)
**Why parallel with P1-4:** No dependency on enforcement; independent artifact-path adjustment.

**Implementation tasks:**
1. Identify all references to `tmp/behavior-isolated-*` or hardcoded temp paths in `helpers.sh` and `with-test-home` that need to resolve relative to `$TEST_PROJECT_DIR/tmp/` instead
2. Update behavior_run / helpers to set `BEHAVIOR_WORKDIR=$TEST_PROJECT_DIR` (the working directory for the model) and ensure all artifact writes go to `$BEHAVIOR_WORKDIR/tmp/behavioral-evidence-*`
3. If existing tests write evidence to sibling dirs, update those references

**Verification:** P1-3 structural check: grep all test scripts referencing `behavior-isolated` or relative temp paths to confirm migration is complete. No behavioral test needed — this is path-resolution, not behavior-change.

### P1-4: Verify all existing tests still work with new nesting structure

**Dependency:** P1-1, P1-2, P1-3 (all core changes must be stable before regression verification)
**Why last in Phase 1:** Regression check validates the entire core architecture change as a unit. Runs `./opencode/tests/test-enforcement.sh --changed` against the `.opencode` submodule.

**Implementation tasks:**
1. Check out dev tip of `.opencode` submodule for comparison (note: cannot directly modify submodules from inside the worktree — handle via git-workflow skill or direct submodule checkout)
2. Copy `.opencode` contents into `$TEST_HOME/test-project/.opencode/` after setup
3. Run a representative subset of all 34 behavioral test scripts (~10 across different scenarios) to validate nesting works end-to-end: `bash <test-path>` for each in the isolated environment
4. Verify artifact manifests (file existence, paths match expected `$TEST_HOME/test-project/tmp/`)

**Verification:** P1-4 structural + behavioral: run all existing test scripts; compare output artifacts against baseline. SC-7 in spec: "All 330 existing tests produce identical artifacts." Structural evidence: diff `ls -R` of old vs new artifact structure after running same tests. Behavioral: re-run full enforcement suite and confirm PASS on all scenarios.

---

## Phase 2: Hooks and Enforcement — per-test setup, submodule control, linting

Items P2-1 through P2-4 build hooks and enforcement layers on top of the nesting foundation from Phase 1.

### P2-1: Add `BEHAVIOR_SETUP_SCRIPT` support to `behavior_run`

**Dependency:** P1-1 (nesting must exist before setup scripts have a target working directory)
**Why first in Phase 2:** Hooks are the most feature-complex addition in this phase — start with hook mechanics.

**Implementation tasks:**
1. In `behavior_run` / helpers.sh, add environment variable check for `BEHAVIOR_SETUP_SCRIPT`:
   - If set: resolve to absolute path and source it (after `.opencode/ clone + config)
   - Pass `$TEST_PROJECT_DIR` as `$WORKDIR` env var to the sourced script
   - If file does not exist, print error to stderr and `exit 2`
   - Sourcing uses `source "$BEHAVIOR_SETUP_SCRIPT"` (NOT `eval`, for proper context sharing)
2. Add fallback: if `BEHAVIOR_SETUP_SCRIPT` is NOT set (env var), check for `fixtures/${SCENARIO_NAME}.setup.sh` relative to test scenario directory — if it exists, source as fallback
3. Document in both `helpers.sh` docstring and `with-test-home` docstring

**Verification:** P2-1 behavioral test: create a temporary setup script that writes `$TEST_PROJECT_DIR/tmp/hook-marker.txt`; run behavior_run with `BEHAVIOR_SETUP_SCRIPT` set; verify file exists after execution (assert_required_pattern_present or structural check).

### P2-2: Add `BEHAVIOR_SUBMODULE_BRANCH` and `BEHAVIOR_SUBMODULE_COMMIT` support

**Dependency:** P1-1 (nesting must exist before submodule checkout is meaningful)
**Why parallel with P2-3:** Independent of hook mechanic — pure configuration support.

**Implementation tasks:**
1. After `.opencode/` clone in setup, check `BEHAVIOR_SUBMODULE_BRANCH` env var:
   - If set and non-empty: `git -C $TEST_HOME/test-project/.opencode checkout "$BEHAVIOR_SUBMODULE_BRANCH"`
   - If branch doesn't exist on remote, print error and `exit 2`
2. Check `BEHAVIOR_SUBMODULE_COMMIT` env var (overrides branch if both set):
   - If set and non-empty: `git -C $TEST_HOME/test-project/.opencode checkout "$BEHAVIOR_SUBMODULE_COMMIT"`
3. Add check to skip submodule checkout if neither variable is set (use HEAD — default behavior)

**Verification:** P2-2 behavioral test: run with `BEHAVIOR_SUBMODULE_BRANCH=dev` and verify `git branch --show-current` in `.opencode/` shows `dev`. Structural: assert required pattern "dev" appears in branch output.

### P2-3: Add lint to `test-enforcement.sh` for raw `with-test-home opencode-cli run`

**Dependency:** Independent — no code changes needed, just adding a grep pattern.
**Why parallel:** Pure content check; can be done anytime but logically before docs are updated (so enforcement rules get documented).

**Implementation tasks:**
1. In `test-enforcement.sh`, add a new lint function or phase:
   - Grep all `.sh` files in `tests/behaviors/` for pattern `\bwith-test-home\b.*\bopencode-cli run\b` (i.e., direct invocation of both tools on the same line)
   - If found, flag as FAIL with message: "Direct 'with-test-home opencode-cli run' detected — must use behavior_run instead"
2. Include this lint in the existing enforcement test pipeline (should run before individual scenario tests)

**Verification:** P2-3 content-verification structural check: grep for the lint function exists in `test-enforcement.sh` referencing `tests/behaviors/*.sh`. Confirm it would match raw invocations by testing the regex against a sample file. SC-5: "test-enforcement.sh flags raw with-test-home opencode-cli run" — string evidence sufficient since this checks a static lint rule, not behavioral agent action.

### P2-4: Update `template.sh` with DO NOT warning block

**Dependency:** Independent
**Why parallel:** Documentation-only update to the template file.

**Implementation tasks:**
1. Modify `.opencode/tests/behaviors/template.sh`:
   - Add a prominent WARNING block at the top (after shebang, before imports):
     ```
     # WARNING: DO NOT call with-test-home directly.
     # WARNING: DO NOT call opencode-cli run directly.
     # WARNING: Always use behavior_run as your test entry point.
     ```
   - Add comment referencing `AGENTS.md` for architecture details

**Verification:** P2-4 content-verification string check: grep `template.sh` for the warning text. SC-6: "template.sh contains DO NOT call warning" — string evidence sufficient.

---

## Phase 3: Documentation — unified docs across all layers

Items P3-1 through P3-3 ensure all documentation layers are consistent with the new architecture. Documentation is released last — changes are not usable until docs accurately reflect implementation.

### P3-1: Update `.opencode/tests/AGENTS.md` — spec paradigm and architecture

**Dependency:** P2-4 (docs can only be meaningful after all features exist)
**Why first in Phase 3:** Core architecture docs must be authoritative reference.

**Implementation tasks:**
1. Rewrite the "Spec Paradigm" section of `tests/AGENTS.md`:
   - Single-entry-point rule: "All behavioral tests MUST use behavior_run"
   - Test project inside test home (new directory layout diagram)
   - Per-test setup hooks mechanism (`BEHAVIOR_SETUP_SCRIPT` env var, fixture-based fallback)
2. Update the "Infrastructure Details" section:
   - `with-test-home` is internal component, not for direct test use
   - Directory structure: show `tmp/test-home-*/test-project/.opencode/` diagram
   - Submodule branch/commit control variables table
3. Add example scenario using per-test hooks (one concrete example)

**Verification:** P3-1 content-verification + semantic check: sub-agent reads AGENTS.md, confirms architecture description matches current codebase (nesting, hooks, submodule vars). String evidence sufficient for structural parts; semantic for architectural accuracy alignment.

### P3-2: Update `helpers.sh` function-level docs — behavior_run as sole entry point

**Dependency:** None in this phase — independent documentation update.
**Why parallel with P3-3:** Both are code-level doc updates that happen together.

**Implementation tasks:**
1. Add/update `behavior_run()` docstring in helpers.sh:
   - Comprehensive usage section showing all env vars (`BEHAVIOR_SETUP_SCRIPT`, `BEHAVIOR_SUBMODULE_BRANCH`, `BEHAVIOR_SUBMODULE_COMMIT`)
   - Directory layout description
   - Setup hook resolution order (env var → fixture fallback)
2. Add `with-test-home` function-level docstring clarifying internal use only
3. Update any existing parameter documentation

**Verification:** P3-2 content-verification: grep helpers.sh for `BEHAVIOR_SETUP_SCRIPT`, `BEHAVIOR_SUBMODULE_BRANCH` in docstrings. Semantic check: confirm docstring accuracy by comparing to actual code behavior.

### P3-3: Verify all docs are consistent across layers (AGENTS.md → template.sh → helpers.sh → with-test-home)

**Dependency:** None — final gate validation step.
**Why last in Phase 3:** Cross-reference consistency check. Must come after all individual doc updates are done.

**Implementation tasks:**
1. Systematic cross-check of architecture description across 4 document sources:
   - `.opencode/tests/AGENTS.md` (authoritative spec)
   - `with-test-home` (internal docs, function-level)
   - `helpers.sh` function docstrings
   - `template.sh` warning block
   - All descriptions must use the same directory structure diagram, variable names, and hook resolution order
2. Check for any documentation drift — sections that reference old behavior-isolated sibling directories, or missing references to new features (NESTED paths, hooks, submodule vars)

**Verification:** P3-3 content-verification semantic cross-check sub-agent: scan all 4 sources for consistency of terminology (variable names, directory structure), identify any inconsistencies. Return PASS only if all descriptions match exactly. SC: consistency across documentation layers — semantic evidence sufficient since this is about textual alignment, not runtime behavior.

---

## Plan Fidelity to Spec Mapping

| Spec Phase | Plan Phases / Items |
|------------|-------------------|
| Spec Phase 1 (Core architecture) | P1-1, P1-2, P1-3, P1-4 |
| Spec Phase 2 (Hooks and enforcement) | P2-1, P2-2, P2-3, P2-4 |
| Spec Phase 3 (Documentation) | P3-1, P3-2, P3-3 |

### Success Criteria Mapping

| Spec SC | Plan Coverage | Evidence Type |
|---------|--------------|---------------|
| SC-1: behavior_run creates test project inside test home | P1-1 + behavioral test | Behavioral |
| SC-2: Calling with-test-home opencode-cli run from non-.opencode FAILS | P1-2 + behavioral test | Behavioral |
| SC-3: behavior_run sources per-test setup script when BEHAVIOR_SETUP_SCRIPT is set | P2-1 + behavioral test | Behavioral |
| SC-4: behavior_run checks out specified submodule branch | P2-2 + behavioral test | Behavioral |
| SC-5: test-enforcement.sh flags raw with-test-home opencode-cli run | P2-3 + content verification | Structural |
| SC-6: template.sh contains DO NOT call warning | P2-4 + content verification | Structural |
| SC-7: All 330 existing tests produce identical artifacts | P1-4 full regression suite | Behavioral |

## Co-Authored Attribution

🤖 Co-authored with AI: qwen3.6:35b-256k

