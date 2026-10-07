# SPEC-FIX: local-issues consolidated defect repair

## Why

`local-issues` carried fourteen open defect reports at research time (2026-10-07). Verification against the current source reduced the live set to ten and surfaced one additional unreported defect. The defects cluster into four root causes plus one contract fiction:

1. **Silent degradation (.opencode#1042).** `_ensure_worktree()` treats failure to establish the `issues-data` worktree as a fallback signal: it warns and returns False, and every caller continues operating in plain-file mode — writing issue records to a directory that is not on the orphan branch, invisible to other checkouts and to the remote mirror. The filed affected-path (a `has_existing` skip in migration) describes superseded code; the live residue is the fail-soft continuation itself, which can also recreate a plain `.issues/` directory through `_next_number()`'s mkdir. Plain-file mode serves no case the orphan branch does not serve better: creating the orphan branch requires only a locally initialized git repository — remote bootstrap is optional and push is skipped without a remote (verified in source and scratch).

2. **Global number namespace (.opencode#2338, .opencode#2394, .opencode#2542, .opencode#2404).** `_check_duplicate_issue()` hard-exits when the target number exists in ANY sibling repo's store, blocking legitimate per-repo numbering and remote-verified mirror registration. Remote trackers number per-repo; the qualified form (`repo#N`) mandated on every command already disambiguates collisions. Separately, `.counter` is advance-only vestigial state — create requires explicit `--number`, so the counter's value is never consulted for numbering — and its untracked drift motivated .opencode#2404. The remote-first reservation mandate makes the remote API the sole number authority wherever a remote exists.

3. **Worktree-lifecycle init (.opencode#2389 + unreported defect).** The temp-worktree init sequence (`worktree add --detach` → `checkout --orphan` → `commit --allow-empty`) has two defects: the failure path leaks a registered temp worktree (.opencode#2389), and — scratch-proven — `checkout --orphan` retains the index, so the "empty" init commit carries the parent repo's entire source tree onto the metadata-only `issues-data` branch, violating the store's content boundary in any fresh no-remote repo (existing stores are clean; created before the current path or bootstrapped from remote). The init path also depends on hook behavior it must not depend on (.opencode#2388 class).

4. **Contract gaps (.opencode#2483, .opencode#2486, .opencode#2466, .opencode#1458).** Scoped `validate-yaml` exits 1 "issue directory not found" for the normal pre-create state, which the analyze-task gate contract treats as `VALIDATE_YAML_FAILED`; the YAML scan covers only the three canonical files, so `artifacts/*.yaml` is never validated and the R-13 backfill gate passes for the wrong reason; `promote` performs no remote mutation and no binding write, and the capability contract that demanded them was attic'd in the .opencode#2490 deck rip — under the remote-first reservation mandate the command's premise (local-first, then promote) is itself a violation, so the command is removed rather than implemented; artifact URLs embed the worktree path (`.issues/N/`) instead of the branch-root path (`N/`).

Five further reports verified already fixed and closed with evidence at filing time: .opencode#1574, .opencode#1576 (argparse rewrite), .opencode#2387 (`_bootstrap_from_remote`), .opencode#2388 (.opencode#2512 hook carve-out; the reported submodule Gate 2 no longer exists), .opencode#2323 (.opencode#2432 warn-and-skip `yaml_load`). Two proposals are rejected as regression: .opencode#1224 and .opencode#1272 — filesystem repo discovery cannot distinguish worktree `.git` files from submodule `.git` files and would reintroduce the .opencode#1296 defect class; the current `.gitmodules`-based discovery already includes the parent repo first.

## What

Repairs are scoped to `.opencode/tools/local-issues`, the create-parser help text, and `.opencode/.issues/AGENTS.md` examples. Deck task-card edits for URL construction ride deck governance separately.

1. **Fail-fatal worktree contract.** `_ensure_worktree()` failure is terminal: exit non-zero with a diagnostic naming the failure and the remediation (the exact `git worktree add` / init command). No caller continues in plain-file mode; no plain `.issues/` directory is created or written on failure. The migration path (`_migrate_existing_issues`, `_restore_migrated_content`) is unchanged.

2. **Per-repo numbering.** `_check_duplicate_issue()` loses the child-repos iteration: uniqueness is enforced within the target repo's own `.issues/{N}` namespace only, with no cross-repo warning. `.counter` and `_next_number()` are removed entirely, including the advance-on-create call and the corrupt-counter hard-fail. `_recent_issue_numbers()` remains the directory-derived hint surface. Create-parser help text and AGENTS.md invocation examples drop counter references.

3. **Plumbing-based init.** `_init_orphan_branch`, `_populate_orphan_branch`, `_commit_orphan_init`, `_remove_temp_worktree`, and the stale-temp-worktree cleanup block are replaced by: empty tree object (`git hash-object -t tree /dev/null`), `git commit-tree` onto it, `git update-ref refs/heads/issues-data` — then the unchanged `_setup_worktree`. No temp worktree exists at any point; no porcelain commit runs, so hook contact is structurally impossible; the branch tree is empty by construction; zero-commit repositories are supported. `cmd_create` calls `_ensure_worktree(repo_path=target)` instead of `_ensure_all_worktrees()`; `cmd_init` keeps all-repo behavior.

4. **Contract alignment.** `_scan_issue_dir_errors` sweeps `**/*.yaml` under the issue directory: every YAML found is parse-validated (`invalid-yaml` on failure); the three canonical filenames retain their schema checks; non-canonical YAML is parse-validated only. Scoped `validate-yaml` on an absent target exits 0 printing a `no-local-records` status line. `promote` is removed (subcommand, parser entry, dispatch, AGENTS.md example). A `url` subcommand emits the platform-correct issue URL derived from the repo's origin remote (SSH→HTTPS), with `--artifacts` emitting the branch-root-relative path (`N/`, never `.issues/N/`).

## Success criteria

**SC-1 — Worktree failure is terminal** (behavioral)
In a scratch repository where issues-data worktree establishment is induced to fail, a mutating command exits non-zero, its stderr names the failure and a remediation command, and no plain `.issues/` directory exists afterward.

**SC-2 — No fail-soft path remains** (structural)
`_ensure_worktree()` contains no path that returns False (or any degraded-mode signal) and allows the caller to continue; failure exits non-zero inside the function.

**SC-3 — Duplicate guard is per-repo** (behavioral)
`create --number R#N` succeeds when `N` exists in a sibling repo's store and `R` has no `N`; it exits non-zero only when `R` itself has `N`. No cross-repo warning is emitted.

**SC-4 — Counter mechanism absent** (structural)
No `.counter` read/write, no `_next_number`, and no counter-reservation reference in the create-parser help text or `.opencode/.issues/AGENTS.md` examples.

**SC-5 — Plumbing init, empty tree** (behavioral)
In a scratch repository with commits, init produces the `issues-data` branch with a zero-file tree; no `.issues-worktree-tmp` path is created at any point; the same sequence succeeds on a zero-commit repository.

**SC-6 — Create scopes worktree-ensure to the target repo** (behavioral)
During a single `create` in repo R, no worktree setup or `issues-data` push attempt occurs for any sibling repo.

**SC-7 — validate-yaml sweeps the issue-dir subtree** (behavioral)
A malformed `artifacts/*.yaml` inside an issue directory is reported `invalid-yaml` with exit 1 by both bare and scoped validate-yaml; the canonical three files retain schema checks; a parse-valid non-canonical YAML produces no error.

**SC-8 — Scoped validate-yaml on remote-only issue** (behavioral)
`validate-yaml --number R#N` where `.issues/{N}/` does not exist locally exits 0 and prints a `no-local-records` status line.

**SC-9 — promote removed** (behavioral)
`local-issues promote ...` exits with an unrecognized-command error; `.opencode/.issues/AGENTS.md` contains no promote reference.

**SC-10 — url subcommand** (behavioral)
`local-issues url R#N` emits the platform-correct issue URL for R's origin remote; `--artifacts` emits a URL whose path is `tree/issues-data/{N}/` (never `.issues/{N}/`).

**SC-11 — Text inventory consistent** (string)
Grep finds no counter-reservation or promote references in the create-parser help text or `.opencode/.issues/AGENTS.md`.

## Out of scope

- Task-card URL-construction edits (deck governance; rides separately per .opencode#1458 SC-3).
- The sibling-peer-repos rearchitecture (.opencode#1120).
- Pre-push hook changes.
- Reconciling remote `issues-data` push rejections accumulated before this fix.

## Filing-time verification evidence

Recorded at filing (2026-10-07), scratch workspaces under /tmp:

- **Plumbing init** (SC-5 design validation): empty-tree branch via `hash-object`/`commit-tree`/`update-ref` + `worktree add` — 0 files in branch tree, 0 entries in worktree, clean status; zero-commit repository also succeeds.
- **.opencode#2388**: temp worktree → `checkout --orphan issues-data` → `commit --allow-empty` PASSES under the current installed hook (the .opencode#2512 carve-out fires; `git branch --show-current` returns `issues-data` in the temp worktree). The trunk-protection gate was incidentally verified blocking a direct trunk commit.
- **.opencode#2387**: real tool run in a scratch checkout — remote `issues-data` present, local branch absent: `init` exits 0, `status: ok`, `pull_result: up_to_date`, worktree contains the remote issue, local branch created from remote. No orphan conflict, no rebase state.
- **.opencode#2323**: real tool run — malformed `issue.yaml` beside a valid one: `list` emits `warn: skipping ... invalid-yaml` to stderr, lists both records (malformed one title-less, status open), exit 0.
- **Live CLI probes**: `create` with unknown flags → argparse error exit 2 (.opencode#1574); `link --help` → full usage (.opencode#1576).
- **Source verification**: duplicate-guard cross-repo iteration (`_check_duplicate_issue`), counter advance-on-create (`cmd_create`), `_ensure_all_worktrees()` in `cmd_create`, `YAML_FILES` scan scope, `cmd_promote` print-only body — all confirmed at current HEAD.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
