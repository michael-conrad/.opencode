> SPDX-FileCopyrightText: 2026 Michael Conrad
> SPDX-License-Identifier: MIT
> Provenance: AI-authored plan from the governing spec (spec.md, this store), .opencode#2642

# Plan — child store hosts gated on issue-host evidence

Spec: `.opencode/.issues/2642/spec.md` (mirrored to michael-conrad/.opencode#2642) — SC-1..SC-15.
Branch: `feature/2642-child-store-host-evidence-gate` (base dd38f7c5b).

## Shared mechanism (all items)

**Evidence ground** — three small added functions in `tools/local-issues`:

- `_remote_has_issues_ref(repo_path) -> bool | None` — live verification:
  `git ls-remote --heads origin issues-data` run in, not against a
  stale-tracking ref. Non-zero exit → `None` (unreachable origin); clean
  exit with output → `True`; clean exit, empty output → `False`
  (verified absent). Run from inside the child (`git -C <child>`), never
  from the workspace root — the push-relevant remote is the child's own.
  Never called for the workspace root (the root is an unconditional host).
- `_local_store_evidence(repo_path) -> bool` — the tool's own worktree
  detection: `(repo_path / ".issues" / ".git").is_file()` (matches
  `_worktree_active`), plus a local `issues-data` branch
  (`_issues_branch_exists`) — coverage for adoption states where the
  worktree checkout is absent but the local branch exists.
- `_is_store_host(repo_path) -> bool` — classification layer over the
  enumerated set (per spec Approach 1, `_discover_all_repos()` is
  unchanged): root → `True` unconditionally; child → local evidence, else
  remote-ref evidence; `False` (non-host) otherwise, including
  unverifiable-remote with no local evidence (SC-14). Pull-only children
  keep their existing refusal semantics — `_is_pull_only` still fires
  first at every gate site; the non-host layer adds nothing on top of it.

**Shape note:** every informational entry the spec calls "the pull-only
entry's shape" carries `status` naming the steady state plus a
`classification` field — `status: non-host` / `classification: non-host`
for a bare non-host child (SC-1/SC-6/SC-14), `status: remote-ref-absent`
/ `classification: host-pending` for a child with local store evidence but
a verified-absent origin ref (SC-3). Neither status is added to
`SYNC_FAILURE_STATUSES`.

## Item 1 — Host classification stops the bootstrap sweep (SC-1 + SC-8 + SC-14)

- **Deliverable:** `_ensure_all_worktrees()` consults `_is_store_host`
  next to `_is_pull_only`; a non-host child receives no `_ensure_worktree`
  call. A host child with only remote evidence bootstraps (SC-5).
- **RED:** on a registered ssh child with no store evidence and a
  reachable stateless origin, `init` mints `.issues/`, `issues-data`, and
  pushes the ref to the child's origin. Fixture: the `#2667` SC-6 pattern
  (`test_pull_only.py` `_register_child`) with an ssh origin
  (`git@127.0.0.1:<closed-port>/...` for the SC-14 shape; local bare
  origin for the SC-1 shape).
- **GREEN:** the classification consult above.
- **Instrument:** run the tool's `init`; read exit 0, the per-repo report
  (the child's `non-host` entry), `ls -a child/.issues`,
  `git -C child branch`, `git -C child ls-remote origin`, and the root's
  origin ref after `init` (the root's establishment still fires).

## Item 2 — Mutation and sync-file refusals name the non-host ground (SC-2 + SC-12)

- **Deliverable:** a `_reject_non_store_host(name, path)` in the
  `_reject_pull_only` pattern, called in all mutation commands
  (`create`, `update`, `comment`, `close`, `delete`, `link`, `renumber`)
  and `sync-file` after repo resolution, before any store write. The
  diagnostic names the child's non-host classification and the opt-in
  path (`init --adopt <name>`). Resolution by name keeps working for
  non-host children (the refusal, not a not-found, carries the naming).
- **Ordering:** existing `_reject_pull_only` first (a pull-only child is
  refused with the pull-only ground even though it also lacks evidence);
  non-host refusal second.
- **RED:** create/update/comment/close/delete/link/renumber/sync-file
  naming a non-host child proceeds into the bootstrap path and mints a
  store.
- **GREEN:** the refusal gate.
- **Instrument:** each command's exit status, diagnostic text (both
  elements), and the child's unchanged state; SC-12's two refusal shapes
  (pull-only child via the https-origin workspace, not-a-registered-child
  via a plain directory in the SC-1 workspace).

## Item 3 — Passive-path gates on the child's verified remote ref (SC-3 + SC-15)

- **Deliverable:** before each passive path operates against a *child*
  origin, `_remote_has_issues_ref` decides: reachable + `True` → proceed;
  reachable + `False` → none of that path's remote operations run
  (informational entry); `None` (unreachable) → keep the existing failure
  semantics for a host (attempt and fail through the existing statuses +
  sync exit 1); a non-host is already excluded by Item 1 / Item 2.
  Gate sites, each skipping only its own remote writes:
  `_sync_repo` (skip fetch, rebase, push — entry `remote-ref-absent`);
  `_sync_file_in_worktree` (no push; local commit still allowed; status
  `ok`); `_push_issues_branch`/`_push_issues_changes` inside
  `_auto_commit` (mutation commits locally, pushes nothing);
  `_create_issues_worktree`'s `_push_orphan_if_needed` call (bootstrap of
  a child host does not push the freshly minted branch to a ref-less
  origin; the root's path stays unconditional).
- **Push helper:** the three push functions gain the gate inline (root
  exempt); no new command.
- **RED:** a child with a local store whose origin's ref is deleted:
  `sync` fetches against a ref-less remote and reports `conflict` per
  O-5; `sync-file` and `update` push and re-create the ref.
- **GREEN:** the gates above.
- **Instrument:** SC-3's sequence (adopt → record → delete remote ref →
  `sync`, `sync-file --file …`, `update --title probe2` — read the three
  entry statuses, exits, and `ls-remote origin`) and SC-15's restore
  cycle (unreachable origin → failure status + exit 1 → restore → `ok`).

## Item 4 — Opt-in provisioning on `init` (R-3; SC-4 + SC-12 + SC-13)

- **Deliverable:** `init --adopt <name>` — no new subcommand (the
  `--help`-comparison instrument holds). The flag names exactly one
  registered child (registered per
  `_registered_store_host_paths`/`git submodule status`). Behavior
  (establishment-completing, spec Approach 3): resolve the named child;
  refuse pull-only (the existing ground); refuse
  not-a-registered-child (ground named); then provision what is missing
  independently — worktree via `_ensure_worktree`, establishment push via
  the gate-exempt push path, then re-verify the origin ref via
  `git ls-remote`; a re-run on a child whose worktree exists but whose
  origin ref is absent performs the push (no short-circuit on the
  worktree's existence); exit non-zero with a diagnostic naming the
  failed establishment when the ref is absent after the attempt.
- **RED:** the flag does not exist today.
- **Instrument:** SC-4's read (worktree, branch, ref present after
  `--adopt`), the two refusal diagnostics on the SC-12 workspaces, and
  SC-13's fail-then-complete cycle through the #2667 SSH-shim family
  (`git-upload-pack` working, `git-receive-pack` failing, then restored).

## Item 5 — `doctor` reports the non-host classification (SC-6)

- **Deliverable:** `_doctor_repo_report`: a host-evidence check before
  the branch-state verdict; a non-host child reports
  `classification=non-host branch_state=absent-by-design worktree=absent`
  beside the existing pull-only row; a host child with local store keeps
  today's row. Root unchanged.
- **RED:** `doctor` on the no-evidence fixture prints `UNHEALTHY` — the
  O-6 false alarm.
- **GREEN:** the classification row.
- **Instrument:** the doctor marker line for the child + absence of
  `UNHEALTHY`; the root's row unchanged.

## Item 6 — Session-init's child store claims consult the same evidence (R-5; SC-7)

- **Deliverable:** `session-init`: a child entry gains host evidence the
  same way — the local `<path>/.issues/.git` worktree marker or a live
  `git -C <child> ls-remote --heads origin issues-data` check. No
  evidence → no `issues:` line and no bootstrap hint for that child (in
  both `collect_issue_artifact_paths` and the Repo Information
  `issues:`-field emission); the entry itself stays (owner/repo/platform
  unchanged). Pull-only skip and root line unchanged.
- **Shared helper:** session-init is a separate script with no import of
  the tool; it gains its own copy of the two checks, consistent with how
  `_is_pull_only_repo` is already duplicated (`#2667 R-5` precedent) —
  both docstrings name their twin to prevent silent drift.
- **RED:** session-init on the SC-1 workspace prints
  `issues: .opencode/.issues/` for the non-host child today.
- **GREEN:** the evidence consult above.
- **Instrument:** the SC-1 workspace run (child emits no `issues:` line
  and no bootstrap hint; root carries `issues: .issues/`), and the
  seeded-evidence variant (child whose origin carries the ref → line
  present).

## Item 7 — Unit coverage onto the gated mechanism (R-7; SC-9)

- **Deliverable:** tests in `tests/test_local_issues/` and
  `tests/test_session_init/`:
  - Carried annotations: `test_remote_branch_bootstrap.py` (the host
    child's remote bootstrap is the seeded-evidence path — fixtures gain
    host evidence where the mechanism now needs it),
    `test_cwd_independence.py` (discovery CWD independence keeps its
    property; fixtures gain evidence or assert the gated exclusion),
    `test_doctor_branch_health.py` (per-repository attribution keeps the
    property; the non-host child no longer carries UNHEALTHY),
    `test_pull_only.py` (the negative-control child has no store evidence
    either — its classification moves onto the non-host row with the
    classification-not-connectivity scope intact).
  - New: `test_child_store_host_gate.py` — the four evidence-branch cases
    (local-only, remote-only, neither, unverifiable-remote), the opt-in
    happy path + two refusals + the fail-complete cycle, the SC-3
    passive-path/no-push sequence, and the SC-8 wiki-origin child (a bare
    origin carrying wiki-like content: content repo shape, no store
    evidence).
- **Instrument:** `uv run --group dev pytest` (no failures) + reading the
  updated/new tests for each property's presence and the four
  evidence-branch coverage tests.

## Item 8 — Deck text states the gate (R-6; SC-10)

- **Deliverable:** three surfaces reworded to evidence-gated + opt-in
  named; none states registration-alone eligibility; each keeps the
  root's unconditional-host statement:
  - `skills/issues/SKILL.md` — the operating-contract store-host
    sentence.
  - `skills/issues/references/local-issues-cli.md` — the `init` row.
  - `skills/issues/references/sync-mirroring.md` — the store-shape and
    initialization text.
- Edits ride the `skill-creator` admission gate: the triage evidence
  (`research/triage-2026-11-04.md`) is the observed-failure evidence.
- **Instrument:** read each surface for the four SC-10 elements (the
  evidence rule, the opt-in, the root statement, absence of
  registration-alone eligibility).

## Item 9 — Whole-scope composition (SC-11)

- **Deliverable:** the changed-file list equals the Scope surfaces
  (`tools/local-issues`, `tools/session-init`, `tests/test_local_issues/`,
  `tests/test_session_init/`, the three deck-text files); no new tool
  command beyond the opt-in flag on `init`.
- **Instrument:** `git diff --name-only <base>` vs Scope;
  `local-issues --help` and the command map compared against
  `git show <base>:tools/local-issues`.

## Dependency order

1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9. Items 2/3/4 depend on Item 1's
classification; Item 7 depends on 1–6; Items 8 and 9 read the composed
state.

## Suite

`uv run --group dev pytest` in the deck, green, before any PR-readiness
claim.
