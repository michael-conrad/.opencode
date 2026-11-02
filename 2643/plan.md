# Plan — .opencode#2643 (remediate-legacy command for legacy-format residue)

Source spec: `.opencode/.issues/2643/spec.md` (R-1..R-6, SC-1..SC-5).
Scope: one change surface — `.opencode/tools/local-issues`. No deck content.

## Design grounding (from source read, 2026-11-02)

- The warning gate `main()` (~2665) calls `_check_legacy_formats(Path(ISSUES_DIR))`
  for every command except `doctor`/`validate-yaml`; predicates: `open/` or
  `closed/` dir present, or any dir matching `^\d+-.+` (~2634–2646). `_legacy/`
  parses to no number and is unflagged.
- Mutation commands follow: `_require_qualified` → `_resolve_and_validate_repo`
  → `_reject_pull_only` → mutate → `_auto_commit(msg, repo_path)`.
  Worktree establishment goes through `_ensure_worktree(repo_path=...)`
  (fail-fatal, `_fail_worktree` exits 1; no plain-file fallback, ~893–930).
- `_parse_number(entry)` splits on the first `-` and ints the head (~1690) —
  legacy `{N}-slug` twins parse to N.
- `_auto_commit` stages (`_stage_issues_changes`), commits, pushes; silently
  skips when no changes (~1168).

## Item 1 (R-1, R-2, R-3, R-4) — `remediate-legacy` command core

- **Deliverable:** (a) refactor `_check_legacy_formats`'s residue detection
  into `_legacy_residue_items(issues_dir) -> list[Path]` returning the residue
  entries (dirs named `open`, `closed`, or matching `^\d+-.+`); the warning
  gate calls it (predicates single-sourced — the command cannot disagree with
  the warning); (b) new `cmd_remediate_legacy`: resolve the repo that owns the
  CWD-relative `.issues/` (the current repo per `_resolve_repo_name()`), run
  `_ensure_worktree(repo_path=...)` and `_reject_pull_only` (standing mutation
  contract, fail-fatal per SC-5), then for each residue item decide routing:
  **remove** when removability verifies — no content beyond YAML metadata
  (no non-YAML files such as spec.md; `issue.yaml` body empty; `comments.yaml`
  has no non-empty comment bodies; `links.yaml` empty) AND no
  `github_url`/`github_issue` field set — else **preserve-by-move** the whole
  directory intact to `.issues/_legacy/` (create on demand; name collisions
  resolved by suffixing). After item routing, remove `open/`/`closed/` when
  empty (and `{N}-slug` dirs that were removed); report per-item actions as
  YAML; `_auto_commit("auto: remediate legacy-format residue", repo_path)`.
  Register the subparser and `command_map` entry.
- **RED:** `.opencode/tools/local-issues remediate-legacy` exits 2
  (invalid choice) against a fixture store.
- **GREEN:** the command + shared predicate refactor above.
- **Instrument:** SC-1 fixture run (mixed outcomes in one invocation: removals,
  intact `3/` collision twin, remote-referencing item intact at `_legacy/`
  byte-identical, `issues-data` log records the commit, post-run `read`
  invocation silent) and SC-2 fixture run (content-bearing records intact at
  `_legacy/`, nothing deleted, post-run silence).

## Item 2 (R-5) — `--dry-run`

- **Deliverable:** `remediate-legacy --dry-run`: run the same routing decision
  per residue item, print the report (remove / preserve-by-move with the
  reason), mutate nothing — no path change, no `_auto_commit` call.
- **RED:** `--dry-run` flag unrecognized (argparse exit 2).
- **GREEN:** the flag + no-mutation branch.
- **Instrument:** SC-3 fixture run (itemized report, before/after store-tree
  manifest identical, `issues-data` log shows no new commit). Dry-run on a
  residue-free store reports nothing to do and mutates nothing (spec Approach
  edge).

## Item 3 (R-6) — warning text names the affordance

- **Deliverable:** `_check_legacy_formats`'s warning text's directive sentence
  replaced: the warning names `local-issues remediate-legacy` as the
  remediation path (firing predicates untouched; R-3 preserved).
- **RED:** warning text currently directs "AI agent must inspect and remediate
  manually" — grep confirms no `remediate-legacy` mention.
- **GREEN:** the new directive sentence.
- **Instrument:** SC-4 source inspection: firing predicates unchanged
  (single-sourced via `_legacy_residue_items`), warning names the command, no
  suppression state introduced anywhere in the diff.

## Ordering

Item 1 → Item 2 → Item 3 (Item 2 reuses Item 1's routing decision; Item 3
edits the warning Item 1 already re-plumbed). SC-5's fail-fatal behavior rides
Item 1's `_ensure_worktree`/`_reject_pull_only` reuse — no separate item;
verified with the others.

## Test placement

SC instrument scripts are throwaway fixture runs (bash + the tool against
temp fixture stores), recorded in the session evidence — not committed test
files. Revision note (recorded at implementation, 2026-11-02): the tool does
have a pytest suite (`.opencode/tests/test_local_issues/`); the SC
instruments stay fixture runs per the spec's instruments, and the suite runs
as the smoke/regression tier for the change.

## Validation

Plan validation standards self-pass, then fresh-context dispatch before
implement. Post-implement: SC-1..SC-5 instrument runs with captured output;
fresh-context verify against the spec; PR per `git-workflow-pr`.
