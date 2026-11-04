<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: bug report filed 2026-11-04 (remote GitHub); converted in place
     into this governing spec on 2026-11-04 under triage dispatch "triage
     .opencode#2642" (work-entry conversion, .opencode#2707). Triage evidence:
     code-level verification of .opencode/tools/local-issues —
     _registered_store_host_paths (submodule intersection, no issue-host
     evidence check), _discover_all_repos (bootstrap of every initialized
     registered child), _push_issues_branch_safe (unconditional push to any
     remote once a local worktree exists). Related: .opencode#2446 (different
     facets of the same repo-discovery surface; the child-repo
     auto-bootstrap + phantom store + remote-pollution finding is not covered
     there). -->

# [SPEC] local-issues: require issue-host evidence before child-repo store bootstrap; never auto-push store branch to ref-less remotes

## Problem

`local-issues` treats every initialized registered submodule of the
workspace root as an issue host. `_registered_store_host_paths` intersects
`.gitmodules`-declared paths with `git submodule status` and `_discover_all_repos`
bootstraps a store for every resulting child — with no check that the child
actually hosts issues. In `hermes-ingest-pubmed` the only registered child is a
GitHub wiki checkout (`git@github.com:NewsRx/hermes-ingest-pubmed.wiki.git`), a
content repo with no issue role. Observed failure chain:

1. `init`/`sync` created `wiki/.issues/` inside the wiki checkout.
2. The store branch's head ended up containing wiki trunk content (`Home.md`),
   not issue data.
3. `_push_issues_branch_safe` pushed the branch to the wiki remote —
   `git -C wiki ls-remote origin` showed `refs/heads/issues-data` (b1f5156),
   polluting a special-purpose remote with a junk branch.
4. Until the auto-push landed, every `init`/`sync` reported the wiki entry as
   `status: conflict / pull_result: "fatal: couldn't find remote ref
   issues-data"` — permanent failure noise.
5. After the push, the phantom store reported `status: ok / issues_count: 0`
   and `doctor` called it `HEALTHY` — no signal the store is spurious.
6. Removing the worktree locally (`git -C wiki worktree remove --force
   .issues`) does not fix it — the next `init` recreates the store and re-syncs.

Every store-holding workspace whose `.gitmodules` lists a non-issue child repo
hits this: phantom stores, junk branches on third-party/special-purpose
remotes, and standing sync-failure noise that can mask real divergences
(the `_exit_on_sync_failures` gate trips on the phantom's conflict).

## Scope

`/.opencode/tools/local-issues` (single-file Python tool) — repo discovery
(`_registered_store_host_paths`, `_discover_all_repos`, `_ensure_all_worktrees`)
and the sync/push path (`_sync_repo`, `_push_issues_branch_safe`).

## Requirements

- **R-1.** `_discover_all_repos` SHALL treat a registered initialized child as
  a store host only when issue-host evidence exists: (a) the child's remote
  carries a `refs/heads/issues-data` ref, or (b) the child holds a local
  `.issues/` record, or (c) the child is an explicit opt-in (an explicit
  configuration the tool already reads or a documented opt-in mechanism this
  change adds). A child with no such evidence is never bootstrapped: no
  `.issues/` worktree creation, no store branch, no init/sync entry that
  fails.
- **R-2.** `_push_issues_branch_safe` SHALL NOT push a store branch to a
  remote that has no `refs/heads/issues-data` ref. Push is gated on
  remote-ref existence (`git ls-remote origin refs/heads/issues-data`
  non-empty); a store whose local branch exists but whose remote ref does not
  is reported as an informational entry, not a push and not a failure.
- **R-3.** `init`/`sync` entries for a child excluded under R-1 SHALL report
  as an informational state (not in the failure set that trips
  `_exit_on_sync_failures`) and SHALL NOT abort or fail the run.
- **R-4.** The workspace root's own store bootstrap is unaffected: the root
  remains a store host unconditionally, and children that do carry
  issue-host evidence bootstrap exactly as today.

## Approach

1. Extend child eligibility in `_registered_store_host_paths` /
   `_discover_all_repos` with the R-1 evidence check (remote-ref probe
   plus local-record check plus explicit opt-in), applied before any
   `_ensure_all_worktrees` bootstrap.
2. Gate `_push_issues_branch_safe` on the remote-ref existence probe (R-2),
   returning an informational entry shape for ref-less remotes.
3. Ensure the informational entries stay outside
   `SYNC_FAILURE_STATUSES` (R-3).
4. Behavioral verification runs against a scratch workspace whose registered
   child is a non-issue-host repo (mirroring the report's wiki-child shape).

## Success criteria

- **SC-1 (behavioral).** In a workspace whose only registered child is a
  non-issue-host repo, running `local-issues init` creates no `wiki/.issues/`
  worktree, no store branch, and no push toward the child remote.
  *Instrument:* behavioral test run against a scratch workspace (provisioned
  per the behavioral-testing card's harness); assert the child directory
  contains no `.issues/` and the child remote's `ls-remote` shows no
  `issues-data` ref after `init` and after `sync`.
- **SC-2 (behavioral).** A child that does carry issue-host evidence (remote
  `issues-data` ref present, or explicit opt-in) bootstraps and syncs
  normally.
  *Instrument:* same harness; positive-case workspace; `init` reports the
  child `status: ok` and the store branch exists locally.
- **SC-3 (structural).** `_push_issues_branch_safe` performs no push when the
  remote lacks a `refs/heads/issues-data` ref.
  *Instrument:* unit test invoking `_sync_repo` against a local bare remote
  without the ref; assert no push occurred (ref still absent) and the entry
  status is informational.
- **SC-4 (structural).** A child excluded under R-1 produces an entry whose
  status is not in `SYNC_FAILURE_STATUSES`; `init`/`sync` exit zero.
  *Instrument:* unit test asserting the exclusion entry's classification and
  the process exit code.

## Out of scope

- Deletion of the stray `refs/heads/issues-data` (b1f5156) on
  `NewsRx/hermes-ingest-pubmed.wiki` — maintainer-side action on a
  third-party remote; noted for the developer, not performed by this change.
- Repo-discovery facets owned by `.opencode#2446`.

## Impact

Consumers: every session that runs `init`/`sync` in a store-holding workspace
with non-issue children (the session-start sequence). Risk: low — the change
narrows bootstrap and push eligibility; the root store and evidence-backed
child stores are unaffected (R-4). Blast radius: `.opencode/tools/local-issues`
only.

---

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2642/
>
> AI-facing artifacts pointer: `.opencode/.issues/2642/`
