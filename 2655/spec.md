<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored; issue .opencode#2655 filed 2026-10-22 (remote body the
     authoritative record — the filer's local mirror artifacts were not durable in
     that environment); developer directive 2026-11-01: "triage .opencode#2655 and
     upgrade to a full spec". Local record recreated 2026-11-01 per the issues
     card's mirror-repair (§7); triage re-verified every claim against
     .opencode/tools/local-issues at c5c46686f (.opencode checkout, 2026-11-01). -->

# [SPEC] local-issues sync-file resolves every issues worktree — submodule paths, repo#N qualification, accurate mismatch reporting

## Problem

`local-issues sync-file` cannot sync any submodule repo's issue store.
`_resolve_worktree_from_path()` (`.opencode/tools/local-issues`; verified in the
current checkout 2026-11-01 at `c5c46686f`, lines 2172–2198) recognizes exactly
two cwd-pinned path shapes — `<workspace>/.opencode/.issues/…` and
`<workspace>/.issues/…` — and returns `None` for everything else, so any other
invocation exits with:

```
Error: file path '<path>' does not match any known issues worktree (.issues/ or .opencode/.issues/)
```

The tool in that workspace ships as the deck's `.opencode` submodule into every
mounting workspace, so every workspace holding submodule issue stores (~40 per
the filer's session-init inventory — ButterApi, ButterShared, SHARED-*,
xBaseJ, …) loses the single-file commit-and-push path. Only the umbrella `sync`
(commit + pull + push for all stores) still works, which is coarser than
intended and slower. Operators following the `repo#N` convention used by every
other `local-issues` command (`create`, `read`, `update`, `comment` all take
`repo#NNNN`) reasonably expect it here; the tool rejects it with a misleading
error that names only the two hardcoded prefixes.

Triaged 2026-11-01 against the current checkout — every claim verified:

1. **Two hardcoded shapes only.** `_resolve_worktree_from_path()` tries
   `<cwd>/.opencode/.issues` and `<cwd>/.issues` prefixes and `return None`
   otherwise. There is no enumeration of the repos the tool itself already
   knows (`_collect_repos()` / `_discover_all_repos()`).
2. **No `repo#N` form.** `_add_sync_file_parser()` (lines 2451–2457) parses
   `--file` as a plain path; `_parse_qualified` / `_require_qualified` /
   `_resolve_repo_path` — the qualifier machinery other commands use — are
   unreachable from `cmd_sync_file` (call-site survey: every use is a
   `--number` command). The flag help "Path to the file to sync" describes none
   of the conventions.
3. **Misleading error.** The mismatch message (lines 2281–2285) names only the
   two hardcoded prefixes — which is also all it will ever name after R-2/R-1
   land unless the message is made to enumerate the real grammar.
4. **Live failure re-demonstrated** (2026-11-01, this workspace): all three
   invocation forms `ButterApi/.issues/21/spec.md`, `ButterApi#21`,
   `ButterApi#21/spec.md` exit 1 with the same two-prefix error. (No resolving
   invocation was run against real stores — resolution failure exits before any
   git operation; and even a no-op re-sync would create an `--allow-empty`
   commit, so none was attempted.)
5. **Reuse basis exists.** `_parse_qualified()` (line 1321), `_resolve_repo_path()`
   (line 1343), `_discover_all_repos()` (line 411), `_collect_repos()`
   (line 948), `_reject_pull_only()` (line 462), and `_sync_file_in_worktree()`
   (line 2201) all exist and are store-agnostic; the resolver change has a
   natural single-file basis.

## Root causes

- **RC-1** — the resolver hardcodes one environment's layout (one workspace's
  two store locations) instead of resolving against the tool's own repo
  enumeration; submodule stores are invisible to it.
- **RC-2** — `sync-file` lacks the qualified-name convention every other
  number-taking command uses; `--file` is treated as a bare path.
- **RC-3** — user-facing text (the mismatch stderr and the `--file` help)
  neither matches nor states the resolver's actual grammar.

## Scope

`.opencode/tools/local-issues` — resolution, error, and help surfaces:

- `_resolve_worktree_from_path()` — resolution generalized (RC-1, RC-2).
- `cmd_sync_file()` — error message (RC-3).
- `_add_sync_file_parser()` — `--file` help text (RC-3).
- A shared grammar statement (constant or single construction) reused by both
  the error message and the help text, so the two cannot drift.
- A test fixture (constructed at implementation) exercising the new resolution
  in a throwaway workspace — the fixture is a test artifact only, never store
  content.

Out of scope:

- Umbrella `sync` behavior — unchanged.
- Store bootstrap from `sync-file` — a repo whose store is not established
  reports the existing `no_worktree` status; `sync-file` never bootstraps one.
- Any remote issues-system call from the tool (local-store boundary, #2382).
- Deck skill-reference edits (`.opencode/skills/**`) — deck-governance surface;
  the CLI reference delegates flag-level truth to `--help`, which this change
  makes accurate (see Impact).
- Commit/push machinery (`_sync_file_in_worktree`) — unchanged; resolution
  feeds it, it does not change under this spec.

## Requirements

- **R-1 — qualified forms.** `sync-file` SHALL accept the qualified
  `repo-folder#NNNN` form (consistent with the tool's other commands — the
  same qualifier vocabulary: current repo first, then registered store hosts),
  in two shapes: `<repo>#<N>` syncs all files under the issue's folder `{N}/`
  in that repo's store; `<repo>#<N>/<relpath>` syncs exactly the single file
  `{N}/<relpath>`. When the argument matches the qualified grammar, it is
  parsed as a qualified reference and resolved via
  `_resolve_repo_path()`-equivalent lookup; an unknown qualifier produces the
  tool's standard repo-not-found error with the available-qualifier list
  (exit non-zero) — the same behavior the other commands' qualifier
  resolution produces.
- **R-2 — enumerated path resolution.** `sync-file` SHALL additionally resolve
  any repo's issues worktree from a repo-root-relative path prefix
  (`<submodule>/.issues/…`), not just the two hardcoded shapes. The resolver's
  candidates SHALL be the repos the tool itself already enumerates (current
  repo first, then registered store hosts via `_discover_all_repos()` — the
  #2667 store-host mechanism), first match wins; no cwd-pinned hardcoded
  prefix branch remains. A path under a non-enumerated directory (neither the
  workspace root nor a registered store host) is not a store: the resolver
  rejects it per R-3.
- **R-3 — accurate mismatch reporting.** The mismatch error message SHALL
  enumerate the form classes the resolver actually accepts — qualified
  issue-folder form, qualified issue-file form, and repo-root-relative
  issues-worktree paths — and the `--file` help text SHALL state the same
  accepted forms, both derived from the one shared grammar statement.

## Success criteria

- **SC-1 (behavioral) (→ R-1, RC-2).** `sync-file --file ButterApi#21` syncs
  all files under issue folder `21/` in the ButterApi store: YAML reports
  `status: ok` with a `commit_sha`, and the commit covers the folder's files.
  *Instrument:* fixture-workspace CLI run (script copy at
  `<fixture>/.opencode/tools/local-issues` so PROJECT_DIR discovery binds;
  parent repo with `.issues/` `issues-data` worktree; registered submodules
  `ButterApi` and `.opencode` each holding an `issues-data` worktree and an
  issue folder; each fixture repository wired a reachable local bare origin
  before `init` — the tool's bootstrap contract is fatal on an unreachable
  origin, so an originless fixture cannot establish stores; fixtures
  bootstrapped with the tool's own `init`, which pushes to the local bare
  origins); assert the YAML output and the commit contents inside the fixture
  only.
- **SC-2 (behavioral) (→ R-1, RC-2).** `sync-file --file ButterApi#21/spec.md`
  syncs exactly that file: YAML `status: ok`, `file: 21/spec.md`.
  *Instrument:* same fixture run; assert YAML.
- **SC-3 (behavioral) (→ R-1).** A qualified argument with an unknown
  qualifier (`NoSuchRepo#21`) exits non-zero with the standard repo-not-found
  diagnostic and the available-qualifier list — the other commands' qualifier
  behavior.
  *Instrument:* fixture run; assert stderr content and exit code.
- **SC-4 (behavioral) (→ R-1, out-of-scope "no bootstrap").** A qualified
  argument naming a real registered repo whose store is not established
  reports `status: no_worktree` — the existing machinery — and does not create
  a store.
  *Instrument:* fixture run against a registered repo whose `.issues` worktree
  was removed; assert YAML status and the repo directory's absence of a
  `.issues` worktree afterward.
- **SC-5 (behavioral) (→ R-1/R-2 consistency, pull-only preservation).** The
  pull-only refusal (`_reject_pull_only`) still fires after resolution on the
  new forms: a qualified or path argument resolving to an http(s)-origin
  repo exits non-zero with the refusal diagnostic naming the repository.
  *Instrument:* fixture variant with that submodule's origin set to an https
  URL (no credential helper); assert refusal stderr and exit code before any
  store mutation.
- **SC-6 (behavioral) (→ R-2, RC-1).** `sync-file --file
  ButterApi/.issues/21/spec.md` resolves the registered submodule store and
  syncs that file: YAML `status: ok`, `file: 21/spec.md` under the
  ButterApi store.
  *Instrument:* fixture run; assert YAML.
- **SC-7 (behavioral) (→ R-2 regression preservation).** The two established
  shapes still resolve and sync unchanged: `--file .issues/<file>` to the root
  store and `--file .opencode/.issues/<file>` to the `.opencode` store (in a
  fixture where `.opencode` is a registered submodule, matching the deck's
  environment contract).
  *Instrument:* fixture runs of both forms; assert YAML for each.
- **SC-8 (behavioral) (→ R-2 negative bound).** A path under a directory that
  is neither the workspace root nor a registered store host (e.g.
  `RandomDir/.issues/21/spec.md`, RandomDir unregistered) exits 1 with the
  R-3 mismatch error — enumeration is the resolution basis; arbitrary sibling
  directories are not sync targets.
  *Instrument:* fixture run with such a directory present; assert stderr and
  exit code, and that no commit happens in any real store.
- **SC-9 (structural) (→ R-3, RC-3).** The mismatch stderr for an
  unresolvable path enumerates all three accepted form classes (qualified
  issue-folder form, qualified issue-file form, repo-root-relative
  issues-worktree path), no longer only the two hardcoded prefixes.
  *Instrument:* run `sync-file --file <unresolvable-path>` in the fixture;
  assert each form class appears in stderr.
- **SC-10 (structural) (→ R-3, RC-3).** `sync-file --help` help text for
  `--file` states the accepted forms.
  *Instrument:* run `sync-file --help`; assert the form classes appear in the
  help output.
- **SC-11 (structural) (→ R-2, RC-1).** `_resolve_worktree_from_path()` builds
  its candidates from the tool's repo enumeration (current repo first, then
  `_discover_all_repos()` store hosts) and contains no cwd-pinned hardcoded
  prefix branch; `cmd_sync_file` routes every form through the existing
  `_reject_pull_only` call.
  *Instrument:* read-back of the function and call site at the merged
  commit — assert enumeration-derived candidates, absence of the two
  legacy relative-prefix literals as matching branches, and the guard
  preceding every mutation.

## Traceability

| Source | Covered by |
|---|---|
| R-1 (qualified forms) | SC-1, SC-2, SC-3, SC-4, SC-5 |
| R-2 (enumerated path resolution) | SC-5, SC-6, SC-7, SC-8, SC-11 |
| R-3 (accurate mismatch + help) | SC-8 (negative bound exercises it), SC-9, SC-10 |
| RC-1 (hardcoded layout) | SC-6, SC-7, SC-11 |
| RC-2 (missing qualified form) | SC-1, SC-2, SC-3 |
| RC-3 (text mismatch) | SC-9, SC-10 |

Every criterion traces to the issue's stated requirements (R-1–R-3, filed
2026-10-22) or the verified failure evidence above; every root cause is
covered by at least one criterion; no orphan criteria.

## Approach

1. **Qualified attempt first.** In `_resolve_worktree_from_path()`, attempt a
   qualified-form parse derived from `_parse_qualified`'s grammar, extended
   with an optional `/<relpath>` tail (`^(.+?)#(\d+)(?:/(.+))?$`). On match:
   resolve the repo via `_resolve_repo_path()`; rel path is `N` (folder) or
   `N/<relpath>` (file). Unknown repo → the standard repo-not-found error with
   the available-qualifier list (the `_resolve_and_validate_repo` behavior),
   exit non-zero. Qualified grammar match takes precedence over path
   resolution — the same precedence the other commands exercise by requiring
   qualified numbers.
2. **Enumerated path resolution second.** Non-qualform arguments resolve
   against candidates = current repo first, then `_discover_all_repos()`
   children (the ordering `_collect_repos()` uses): for each candidate, try
   `resolved_path.relative_to(candidate/.issues)`; first match wins. This
   subsumes both legacy shapes as instances of the general rule (root's
   `.issues/`, `.opencode`'s `.issues/` when registered) and adds every other
   registered store host. The alternative — globbing the filesystem for any
   `*/.issues` directory — is rejected: it makes unregistered sibling
   directories sync targets (R-2's negative bound, SC-8) and abandons the
   tool's #2667 store-host mechanism, under which a registered repo list is
   already the enumeration basis for `init`/`sync`/qualifier resolution.
3. **Single-sourced grammar text.** One shared statement of the accepted form
   classes (constant or single construction in the module) feeds both the
   mismatch error message and the `--file` help string; the message names the
   three accepted classes, not the two legacy prefixes.
4. **Machinery untouched.** `_sync_file_in_worktree()` receives
   `(repo_path, rel_path, message)` exactly as before — a folder form passes
   `N` (git-add of the folder) and a file form `N/<relpath>`;
   `_reject_pull_only(repo_name, repo_path)` stays called after resolution in
   `cmd_sync_file`, so every form inherits the refusal.
5. **Fixture verification.** All behavioral SCs run in a throwaway fixture
   workspace built per SC-1's instrument (constructed at implementation):
   each fixture repository is wired a reachable local bare origin — the
   tool's bootstrap contract (#2548 C4) exits fatally when `issues-data`
   existence cannot be verified against `origin`, so originless fixtures
   cannot establish stores; the tool's own `init` then bootstraps every
   fixture store and pushes to the local bare origins. Assertions read
   `status`/`commit_sha`/`file` from the tool's YAML output. No real store is
   touched.

## Impact

- **Consumers:** every workspace mounting the deck's `.opencode` submodule
  with submodule issue stores (~40 per the filer's session-init inventory);
  operators gain the exact `repo#N` convention the tool teaches everywhere
  else, and the single-file sync path is restored at submodule stores without
  the umbrella `sync`'s commit-all-pull-all-push-all round trip.
- **Risk:** low — resolution and user-facing text only; store-data semantics,
  commit/push machinery, and the local-store/remote boundary are untouched.
  Write-surface additions are bounded by the resolver's enumeration (R-2's
  negative bound, SC-8) and by the preserved pull-only refusal (SC-5).
- **Blast radius:** one file, `.opencode/tools/local-issues` (resolver,
  `cmd_sync_file` error, sync-file parser help, shared grammar text), plus a
  fixture test artifact at implementation. Documentation surfaces: the tool's
  `--help` (in scope, SC-10); the deck's CLI-reference command table row for
  sync-file reads "Commit + push one file …" — its flag-level truth is
  delegated to `--help` by that same reference, so no deck edit is required
  for correctness here; the row remains true of the path form. Any future
  deck-row rewording goes through deck governance on its own ticket.
- **Recovery:** single-file revert on the `.opencode` repo restores prior
  behavior; the change introduces no store migration, no data rewrite, and no
  branch/tag effect.

## Edge cases

- Unknown qualifier in a qualified argument → repo-not-found error + qualifier
  list (SC-3), consistent with the other commands.
- Known qualifier, store not established → `no_worktree`; no bootstrap
  (SC-4).
- Pull-only repo on any form → refusal before mutation (SC-5).
- Unregistered sibling directory carrying an `.issues/` tree → rejected
  (SC-8); the store-host mechanism (#2667) is the only sync-target basis.
- Qualified folder form where folder `{N}/` does not exist → the existing
  `add_failed` status machinery reports the git pathspec error — unchanged
  behavior, now reachable through the new form.
- `--message` applies to every resolved form unchanged.
- Empty `--file` argument resolves nowhere (cwd matches no enumeration)
  → mismatch error.