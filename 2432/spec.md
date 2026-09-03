# [SPEC] local-issues: qualifier enforcement, PROJECT_DIR anchoring, YAML hardening and repair

## Intent and Executive Summary

1. **Problem Statement**: `.opencode/tools/local-issues` has inconsistent repo/issue resolution and no malformed-YAML resilience. Identity is CWD-derived while `PROJECT_DIR` is used inconsistently, the `repo#N` qualifier is enforced only on mutation commands, `yaml_load` has zero exception handling across its call sites, and the worktree bootstrap creates unrelated-histories orphan branches. The result: creates misroute to the parent repo, the root counter drifted 50→52, an orphan branch diverged from `origin/issues-data`, and 10 confirmed malformed tracking files crash `search`/`list`/`read`.

2. **Root Cause / Motivation**: `_resolve_repo_name` and `_discover_all_repos` root identity at the current working directory while `PROJECT_DIR` (stable, derived from the tool file location) anchors only some paths — so qualifier and physical location disagree depending on invocation directory. Qualifier enforcement was added only to mutation commands, leaving the read family and the create auto-number path bypassing it. `yaml_load` performs a bare parse with no error handling, so one malformed file takes down whole commands. `_issues_branch_exists` checks only the local `refs/heads`, so a machine with `origin/issues-data` but no local branch gets an unrelated-histories orphan instead of a fetch/track. This MUST be solved now because the defects corrupt live tracking data (counter drift, orphan history) and every pipeline consumer that touches malformed YAML crashes.

3. **Approach Chosen**: Nine per-SC changes land in dependency order as single-concern TDD items: (1) qualifier enforcement on ALL commands, (2) PROJECT_DIR anchoring of identity and discovery, (3) worktree bootstrap fetch/track remediation, (4) counter targeting the qualifier-resolved repo, (5) `yaml_load` warn-and-skip hardening, (6) a new `validate-yaml` subcommand with gate exit codes, (7) mechanical repair of the confirmed malformed files gated by `validate-yaml`, (8) a read-only `doctor` subcommand, and (9) pipeline gate insertion in the spec-creation and writing-plans task cards.

4. **Alternatives Considered & Why Discarded**:
   - **`owner/repo#NNN` qualifier format** — discarded by settled developer decision (supersedes #2319); `repo#N` is sufficient for this two-repo workspace and avoids owner-name coupling.
   - **Filesystem-glob child discovery (nested `.git` detection)** — discarded by settled decision; `.gitmodules`-only discovery anchored at `PROJECT_DIR` supersedes #1224, and non-submodule children are out of scope.
   - **Backward-compat shims for bare numbers** — discarded per the no-backward-compat guideline; all in-repo consumers are updated in-phase instead of shimmed.
   - **Reconstruction of semantically broken historical artifacts** — discarded per the data-integrity mandate (flag, don't guess); only mechanical transforms with verifiable before/after state are permitted.

5. **Key Design Decisions**:
   - **`create --number` becomes REQUIRED and qualified**; the auto-number path is removed. Tradeoff: callers must reserve a number via the counter before create, in exchange for deterministic qualifier-to-path routing.
   - **Counter reservation flow retained**: `_next_number` is kept for number reservation rather than retired. Tradeoff: one extra call for callers, but the reservation flow stays testable in isolation.
   - **Warn-and-skip boundary drawn at data class**: YAML content files are records (warn-and-skip); the counter is control state and keeps its existing fail-fast FATAL behavior. Tradeoff: two error policies, but each matches the blast radius of its data class.
   - **`validate-yaml` exit-code contract fixed before consumers**: exit 0 clean / exit 1 malformed found, machine-greppable output. Tradeoff: the contract must be stable before repair (SC-07) and the pipeline gate (SC-09) consume it, but both consumers then share one verification gate.
   - **Doctor is read-only**: residual defects (root counter drift value, divergent worktrees) are reported, never mutated. Tradeoff: drift values persist until a human repairs them, but diagnostics can never corrupt state.

6. **User Intent / Original Prompt**: Union of the chat brainstorm (2026-09-03 session: qualifier enforcement, anchoring, YAML hardening, validate-yaml, repair, pipeline gate) and the developer bug report GitHub #2432 (misrouting, bootstrap, counter hygiene, doctor), with settled decisions: `repo#N` qualifier required everywhere; `.gitmodules`-only discovery anchored at `PROJECT_DIR`; supersedes #2319 and #1224; #2093 closed as already satisfied.

## Not Included

- **`owner/repo#NNN` qualifier migration** — settled decision retains the `repo#N` format; owner-prefixed forms add no routing value here.
- **Filesystem-glob child discovery** — settled decision supersedes #1224; only `.gitmodules`-declared repos are discoverable qualifiers.
- **Reconstruction of semantically broken historical artifacts** — data-integrity constraint: semantic breakage is flagged in a report, never guessed at or rewritten.
- **Root counter value repair (50→52 drift)** — the doctor subcommand reports counter state; repairing the stored drift value is out of scope.
- **Counter format changes** — the counter file format is preserved; only write targeting changes.
- **Push/promote/renumber/sync behavioral changes beyond anchoring inheritance** — these commands change only via inherited identity anchoring; no new behavior is specified.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-01 | ALL local-issues commands reject bare issue numbers: the read family (`read`, `read-comments`, `read-labels`, `read-sub-issues`) and `create` invoked without an explicit `repo#N` qualifier exit non-zero with a stderr qualifier listing; a qualified `repo#N` resolves to exactly one repo. | behavioral | Unit tests: argparse-fixture invocations of the read-family and create commands; bare number asserts non-zero exit plus qualifier listing on stderr; qualified number asserts single-repo resolution; mutation commands assert unchanged enforcement. | `local-issues` source (qualifier-resolution layer); interface-compatibility artifact |
| SC-02 | Repo identity and discovery are anchored to `PROJECT_DIR`: `_resolve_repo_name` and `_discover_all_repos` produce identical results when invoked from any directory within the project, and each qualifier maps to exactly one `.issues/` folder. | behavioral | Unit tests: resolution run from two different CWDs (project root, nested subdirectory) over a fixture repo with `.gitmodules`; results asserted identical. | `local-issues` source (identity/discovery layer); `.gitmodules` |
| SC-03 | Worktree bootstrap fetches and tracks `origin/issues-data` when the remote branch exists but no local branch exists; the orphan-branch path fires only when neither local nor remote branch exists. | behavioral | Unit tests: temp git fixture with a bare origin holding `issues-data` and a clone without the local branch — bootstrap asserts remote-tracked branch, no orphan, merge-base equality; second fixture without remote asserts the orphan path still fires. | `local-issues` source (worktree bootstrap layer); issues-data branch on `origin` |
| SC-04 | Counter writes target the qualifier-resolved repo's `.issues/.counter`: create with the `.opencode` qualifier increments the `.opencode` counter and leaves the root counter byte-identical. | behavioral | Unit tests: two-repo fixture; create with `.opencode` qualifier asserts the `.opencode` counter incremented and root counter byte-identical; corrupt-counter fixture asserts fail-fast exit preserved. | `local-issues` source (create path); state-analysis artifact |
| SC-05 | `yaml_load` warn-and-skip: malformed YAML in any content tracking file produces a stderr warning (file path plus error class) and a skip/empty result; `search`/`list`/`read` complete without exception, and valid files in the same tree are still parsed. | behavioral | Unit tests: fixture tree containing one malformed file per error class plus valid files; list/search/read asserted exception-free with stderr warnings; valid-file parse asserted. | `local-issues` source (parse layer); testability artifact |
| SC-06 | The `validate-yaml` subcommand scans issue directories and prints `<path>: <error-class>` per malformed file; exit code 0 when all files parse, exit code 1 when at least one malformed file is found. | behavioral | Unit tests: fixture tree with known-bad and known-good files asserts exit 1 plus file/class report lines; clean fixture asserts exit 0. | `local-issues` source (subcommand registration); interface-compatibility artifact |
| SC-07 | The 10 confirmed malformed tracking files parse cleanly after repair; ANSI-escape and truncation artifact classes are repaired; unrecoverable or semantically broken cases are listed in a flag report and left as-is. | behavioral | Integration via the validate-yaml gate over the live repos: pre-repair run reports the 10 files; post-repair run exits 0 for core files; flag report asserted to list semantic cases without rewriting them; before/after evidence retained. | `.opencode/.issues/` and `.issues/` worktree content; state-analysis artifact (repair mappings) |
| SC-08 | The `doctor` subcommand emits per-repo health markers (issues-data branch state, merge-base delta vs `origin/issues-data`, counter state, worktree presence) without mutating any repository state. | behavioral | Unit tests: fixture states (healthy repo, missing local branch with remote present, corrupt counter) assert marker output; read-only invariant asserted via repo-state hash comparison before/after the run. | `local-issues` source (subcommand registration); research card on worktree/submodule distinction |
| SC-09 | The spec-creation (analyze, create) and writing-plans task cards invoke `validate-yaml` after artifact generation and return a BLOCKED result contract when it exits 1. | behavioral | Behavioral test via the isolated harness: artifact-generation scenario asserted to invoke the gate after the change (and absent before); stderr-pattern assertions per the behavioral-variant discipline. | spec-creation and writing-plans task cards; enforcement-test framework docs |

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Requirements

R-1. The tool SHALL reject bare issue numbers on every command: each invocation SHALL use the `repo#N` qualifier form.
R-2. The qualifier SHALL resolve to exactly one `.issues/` folder consistently, regardless of the invocation directory.
R-3. Repo discovery SHALL parse `.gitmodules` only, anchored at `PROJECT_DIR`; non-`.gitmodules` children SHALL NOT be discoverable as qualifiers.
R-4. `yaml_load` SHALL warn-and-skip on malformed content YAML (stderr warning with file path and error class) instead of raising to callers.
R-5. A corrupt or missing counter file SHALL keep the existing fail-fast behavior: missing counter creates at 1; corrupt counter exits FATAL. Warn-and-skip SHALL NOT apply to the counter.
R-6. The worktree bootstrap SHALL fetch and track `origin/issues-data` when the remote branch exists without a local branch, and SHALL create an orphan branch only when neither exists.
R-7. Counter writes SHALL target the qualifier-resolved repo's `.issues/.counter`; a create against one repo SHALL NOT increment another repo's counter.
R-8. The `validate-yaml` subcommand SHALL report each malformed file as `<path>: <error-class>` on stdout, SHALL exit 0 on a clean tree, and SHALL exit 1 when malformed files are found; it SHALL NOT mutate any file.
R-9. The repair pass SHALL apply only mechanical transforms to the confirmed malformed files, SHALL preserve or restore semantic meaning, and SHALL flag unrecoverable or semantically ambiguous files in a report without rewriting them.
R-10. Repair commits SHALL land on the issues-data worktree branches via the tool's auto-commit; repairs SHALL NOT appear as parent-repo tracked changes.
R-11. The `doctor` subcommand SHALL emit per-repo health markers for issues-data branch state, merge-base delta vs `origin/issues-data`, counter state, and worktree presence, and SHALL NOT mutate repository state.
R-12. The `doctor` and `validate-yaml` outputs SHALL be machine-greppable (stable per-file and per-repo markers) so gates and repair verification can consume them.
R-13. The spec-creation and writing-plans task cards SHALL invoke `validate-yaml` after artifact generation and SHALL return a BLOCKED result contract when it exits 1.
R-14. Existing qualifier enforcement on mutation commands (`update`, `comment`, `close`, `delete`, `link`, `renumber`, `promote`) SHALL be preserved without regression.

## Items

### Item 1 (SC-01): Qualifier enforcement on all commands

- RED: Unit test invoking the read family and create with a bare number asserts non-zero exit plus a stderr qualifier listing (change does not exist yet, so bare numbers are currently accepted).
- GREEN: Read-family commands and create resolve only from an explicit `repo#N` qualifier; bare numbers exit non-zero with the qualifier listing; mutation enforcement untouched.
- verify: Unit suite green; mutation-command regression tests pass unchanged.
- commit: Qualifier-resolution layer changes + tests, single commit.

### Item 2 (SC-02): PROJECT_DIR anchoring of identity and discovery

- RED: Unit test resolving the same qualifier from two CWDs (project root vs nested subdirectory) asserts identical identity/discovery results — fails while identity is CWD-derived.
- GREEN: `_resolve_repo_name` returns the anchored project name; `_discover_all_repos` roots at `PROJECT_DIR` with `.gitmodules`-only child discovery preserved.
- verify: Unit suite green; multi-CWD invariant test passes.
- commit: Identity/discovery layer changes + tests, single commit (depends on Item 1).

### Item 3 (SC-03): Worktree bootstrap remote-tracking remediation

- RED: Unit test with a repo holding `origin/issues-data` but no local branch asserts no orphan created and a remote-tracked branch checked out — fails while bootstrap checks only local refs.
- GREEN: Bootstrap checks the remote ref, fetches and tracks when present, and falls back to the orphan path only when no remote branch exists; fetch failure warns and falls back.
- verify: Unit suite green on both fixture states (remote present / remote absent).
- commit: Worktree bootstrap layer changes + tests, single commit (depends on Item 2).

### Item 4 (SC-04): Counter hygiene — resolved-repo counter targeting

- RED: Unit test creating with the `.opencode` qualifier asserts the `.opencode` counter incremented and root counter byte-identical — fails while create always targets the root counter.
- GREEN: Create resolves the counter path from the qualifier-resolved repo; missing counter creates at 1; corrupt counter stays FATAL.
- verify: Unit suite green; cross-repo non-interference asserted.
- commit: Create-path changes + tests, single commit (depends on Items 1 and 2).

### Item 5 (SC-05): YAML parse hardening (warn-and-skip)

- RED: Unit test running list/search/read over a fixture with malformed YAML asserts exception-free completion with a stderr warning — fails while `yaml_load` raises.
- GREEN: `yaml_load` catches parse errors, warns to stderr with file path and error class, returns skip/empty results; iteration paths skip malformed records; counter fail-fast untouched.
- verify: Unit suite green; valid files in the same tree still parsed.
- commit: Parse-layer changes + tests, single commit.

### Item 6 (SC-06): validate-yaml subcommand

- RED: Unit test on a fixture tree with known-bad files asserts exit 1 plus `<path>: <class>` report lines — fails while the subcommand does not exist.
- GREEN: Subcommand walks issue directories, reuses the SC-05 error classification, prints the report, and applies the exit-code gate.
- verify: Unit suite green; clean fixture exits 0.
- commit: New subcommand + registration + tests, single commit (depends on Item 5).

### Item 7 (SC-07): Malformed tracking file repair

- RED: `validate-yaml` run over the live repos reports the 10 confirmed malformed files (pre-repair state).
- GREEN: Mechanical transforms applied to the confirmed files (legacy GitHub-export mapping, markdown-comment mapping, ANSI-escape cleanup, truncation repair); semantic cases flagged in a report and left as-is; repairs committed via tool auto-commit on the issues-data branches.
- verify: Post-repair `validate-yaml` exits 0 for core files; flag report lists semantic cases; before/after evidence retained.
- commit: Data repair on issues-data worktree branches only (depends on Item 6).

### Item 8 (SC-08): doctor subcommand

- RED: Unit test with a fixture missing a local branch reports an unhealthy branch marker — fails while the subcommand does not exist.
- GREEN: Subcommand emits per-repo health markers (branch state, merge-base delta, counter state, worktree presence) for the root and all discovered repos, read-only.
- verify: Unit suite green; read-only invariant (state hash unchanged) asserted.
- commit: New subcommand + registration + tests, single commit (depends on Items 2 and 3).

### Item 9 (SC-09): Pipeline validate-yaml gate insertion

- RED: Behavioral test running an artifact-generation scenario through the isolated harness asserts the gate is absent (agent does not invoke validate-yaml).
- GREEN: spec-creation (analyze, create) and writing-plans task cards append the validate-yaml invocation with a BLOCKED result contract on exit 1.
- verify: Behavioral test re-run asserts gate invocation; structural check confirms task-card edits.
- commit: Task-card changes + behavioral test, single commit (depends on Item 6).

## Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| #2319 (qualifier format) | Superseded by this spec's settled `repo#N` decision | Superseded |
| #1224 (filesystem-glob discovery) | Superseded by the settled `.gitmodules`-only decision | Superseded |
| #2093 (child discovery) | Closed — already satisfied by current `.gitmodules` parsing | Closed |
| GitHub #2432 (bug report) | Source problem statement; this spec subsumes it | In scope |
| `local-issues` tool | All SC-01..SC-08 changes modify this tool | Present |
| pytest unit scaffolding (`.opencode/tests/`) | New test module required for SC-01..SC-06, SC-08 | To create |
| Behavioral enforcement harness (tests-v2) | SC-09 verification runs through it | Present |
| issues-data branches on both repos | SC-07 repair commits land there via tool auto-commit | Present |

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-01 | tool-core |
| R-2 | SC-02 | tool-core |
| R-3 | SC-02 | tool-core |
| R-4 | SC-05 | tool-core |
| R-5 | SC-04, SC-05 | tool-core |
| R-6 | SC-03 | tool-core |
| R-7 | SC-04 | tool-core |
| R-8 | SC-06 | repair |
| R-9 | SC-07 | repair |
| R-10 | SC-07 | repair |
| R-11 | SC-08 | tool-core |
| R-12 | SC-06, SC-08 | repair, tool-core |
| R-13 | SC-09 | integration |
| R-14 | SC-01 | tool-core |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `local-issues` tool source | code | `.opencode/tools/local-issues` | Read + line-verified during analyze pass (2026-09-03) |
| `.gitmodules` | config | `.gitmodules` | Read during pre-spec inspection |
| Malformed tracking files (10) | data | `.opencode/.issues/{1204,1205,1235,1296,1305,2013,2177}/issue.yaml`, `.opencode/.issues/{1296,2013}/comments.yaml`, `.issues/162/comments.yaml` | Live `yaml.safe_load` parse test — all 10 confirmed malformed |
| Research card: discover-repos/worktree-filter | research | `.opencode/.issues/research-cards/local-issues-discover-repos-worktree-filter.md` | Read; confidence 0.95; staleness note incorporated |
| Bug report #2432 | issue | https://github.com/michael-conrad/.opencode/issues/2432 | Read via GitHub API (2026-09-03) |
| Testability/decomposition artifacts | analysis | `.opencode/.issues/2432/artifacts/` | Produced by the analyze pass this session |

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-01:** Running the bare-number rejection unit tests costs minutes of execution time — the defect surfaces at the earliest gate and the fix costs the same bounded delay. Skipping costs weeks of silent misrouted operations — every consumer that passes a bare number fans out to the wrong repo, and the misroute compounds into counter drift and wrong-repo writes discovered only during data forensics.
- **SC-02:** Running the multi-CWD identity invariant tests costs minutes. Skipping costs the full misrouting class in production — qualifier and physical location disagree depending on invocation directory, and each occurrence costs a diagnosis session to untangle.
- **SC-03:** Running the bootstrap fixture tests costs minutes. Skipping costs the unrelated-histories orphan class — a diverged issues-data branch that requires manual history surgery to reconcile, at 100× the gate cost.
- **SC-04:** Running the counter-targeting tests costs minutes. Skipping costs silent cross-repo counter corruption — every misrouted create drifts a counter that downstream number reservations then trust, surfacing as duplicate or skipped issue numbers discovered late.
- **SC-05:** Running the malformed-YAML fixture tests costs minutes. Skipping costs a crash on every command that touches one malformed file — the crash blocks list/search/read over the entire tree, converting a single bad file into a tool-wide outage.
- **SC-06:** Running the validate-yaml gate tests costs minutes. Skipping costs the repair pass (SC-07) and pipeline gate (SC-09) their verification contract — both consumers then verify nothing, and malformed data flows into plans and specs undetected.
- **SC-07:** Running the before/after validate-yaml integration gate costs minutes. Skipping costs unrepaired malformed files feeding every read/list/search path indefinitely, plus the risk of unreviewed semantic rewrites — which is why semantic cases are flagged, not guessed.
- **SC-08:** Running the doctor marker tests costs minutes. Skipping costs the residual-defect visibility layer — counter drift and divergent worktrees stay invisible until they cause an operational failure.
- **SC-09:** Running the behavioral gate test costs minutes of model execution time. Skipping costs the death spiral — a skipped pipeline gate lets malformed artifacts flow into plans and specs, where the defect surfaces downstream at 100×–1000× the cost of the behavioral test that would have caught it.

## Edge Cases

| Condition | Expected behavior | Resolution |
|-----------|-------------------|------------|
| Bare number passed to any command | Non-zero exit with stderr qualifier listing available repos | Rejected at the qualifier-resolution layer; no partial execution |
| Qualifier for a repo absent from `.gitmodules` | Rejected with qualifier listing | Discovery layer defines the valid qualifier set |
| Invocation from a nested subdirectory | Identity and discovery identical to project-root invocation | PROJECT_DIR anchoring invariant (SC-02) |
| `origin/issues-data` exists, local branch missing | Fetch + local tracking branch; no orphan | Bootstrap remediation (SC-03) |
| Neither local nor remote issues-data exists | Orphan branch created (existing behavior preserved) | Orphan path retained for first-run bootstrap |
| Fetch failure during bootstrap | Warning + fallback to the existing path | Warn-and-fallback; never a crash |
| Missing counter file | Created at 1 (existing behavior) | Counter initialization preserved |
| Corrupt counter file | FATAL exit (existing fail-fast preserved) | Counter is control state, not content (R-5) |
| Malformed YAML in a content file | Stderr warning with path + error class; record skipped; command completes | Warn-and-skip (SC-05); classify per shared error taxonomy |
| Valid and malformed files in the same tree | Valid files parsed; malformed files skipped with warnings | Per-record skip in iteration paths |
| Unreadable file during validate-yaml scan | Reported as an error class on stdout; scan continues | Reported, never crashed |
| Unrecoverable or semantically ambiguous file in repair | Listed in flag report; left malformed | Flag, don't guess (R-9); no semantic invention |
| Repair commit mechanics | Commits land on issues-data worktree branches via tool auto-commit | Parent repo untouched (R-10) |
| Concurrent counter access | Single-process CLI assumption; no multi-process lock specified | Out of scope — tool has no cross-process locking today; unchanged |

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
