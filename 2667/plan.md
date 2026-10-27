# Plan: Detect a pull-only registered deck, and handle it with judgment (.opencode#2667)

Derived entirely from `.opencode/.issues/2667/spec.md` (R-1 … R-10, SC-1 … SC-18).
Branch: `feature/2667-pull-only-deck-detection`.
Unit-test baseline: 168 passed (`uv run --group dev pytest`, 2026-10-24).

Languages in scope: Python (`tools/local-issues`, `tools/session-init`,
`tests/test_local_issues/`), markdown card text, one behavioral scenario script
under `tests-v2/behaviors/`.

## Item 1 — Registered-submodule discovery (R-1 → SC-7, SC-8)

- **Deliverable:** In `tools/local-issues`, replace `_discover_all_repos`'s
  `.gitmodules`-text eligibility with git's registered-submodule mechanism:
  root first, then `git submodule status` paths intersected with the paths
  `.gitmodules` names (via `git config -f .gitmodules --get-regexp
  submodule\..*\.path`, mirroring `session-init`'s `_registered_submodule_paths`,
  the mechanism #2544 established). A status line with a leading `-`
  (uninitialized) is excluded and never aborts bootstrap. A `+` line
  (checkout ≠ gitlink) is a store host (SC-7).
- **RED:** `test_cwd_independence` fixtures currently fabricate `.gitmodules`
  text with no gitlink: under the new mechanism the child is not registered, so
  discovery of the child fails. Carry the fixtures onto real registration
  (`git submodule add`) and the assertions onto R-1's mechanism (SC-15) — RED
  against current tool only for the uninitialized-host case; add a new
  assertion that an uninitialized registered submodule yields no store host and
  does not abort.
- **GREEN:** implement the new `_discover_all_repos`; carry
  `test_cwd_independence.py` (root-vs-nested equality, nested-CWD child
  discovery) and `test_doctor_branch_health.py` fixtures to registered
  submodules.
- **Instrument:** `uv run --group dev pytest tests/test_local_issues/`.

## Item 2 — Pull-only detection (R-2 → SC-2, SC-5, SC-6)

- **Deliverable:** `_is_pull_only(repo_path)` helper: effective origin via
  `git remote get-url origin` (rewrites applied); scheme `http://` or
  `https://` ⇒ pull-only; no origin ⇒ not pull-only (no-remote handling
  unchanged); root exempt (never classified on its own scheme).
- **RED:** new unit test: a child over an `https` stored origin is classified
  pull-only; an `ssh`/local-path child is not; the root over `https` is not.
- **GREEN:** add helper; no behavior change yet.
- **Instrument:** unit suite.

## Item 3 — No store, no fetch, no push, no mutation against pull-only (R-3 → SC-1, SC-3)

- **Deliverable:** In `tools/local-issues`: `_ensure_all_worktrees` and
  `_ensure_worktree` skip and never create branch/worktree for a pull-only
  child; `_sync_repo` returns a `pull-only` status entry (no fetch, no rebase,
  no push) instead of running; a shared `_reject_pull_only(repo_name,
  repo_path)` refuses every mutation command (`create`, `update`, `comment`,
  `close`, `delete`, `link`, `renumber`) with an exit-non-zero diagnostic
  naming the repository and its pull-only classification; `sync-file` refuses a
  path resolving into a pull-only repository's store on the same terms (in
  `cmd_sync_file` after `_resolve_worktree_from_path`).
- **RED:** new unit test driving each mutation command + `sync-file` against an
  https-origin child: non-zero exit, diagnostic contains the repo path and the
  pull-only marker, and `git branch` / `git worktree list` show no `issues-data`
  and no `.issues` worktree.
- **GREEN:** implement guards.
- **Instrument:** unit suite; workspace construction mirrors SC-3 (https stored
  origin resolving to an unreachable URL so any attempted fetch fails fast).

## Item 4 — Per-repository report + doctor classification (R-4 → SC-2, SC-18)

- **Deliverable:** `init`/`sync` per-repo entries for a pull-only repository:
  `status`/classification `pull-only`, no operation result fields, tool still
  resolves it by name; `doctor` reports
  `classification=pull-only` and no `branch_state=UNHEALTHY` marker for it
  (absent store is intentional). `doctor` must stay read-only.
- **RED:** assertions added to `test_doctor_branch_health.py` style: doctor
  line for the https child carries the classification and no UNHEALTHY token.
- **GREEN:** implement reporting in `_sync_repo`/`cmd_init`/`cmd_sync` and
  `_doctor_repo_report`.
- **Instrument:** unit suite.

## Item 5 — session-init writability field (R-5 → SC-4, SC-5, SC-6)

- **Deliverable:** `tools/session-init` adds a `writability:` field
  (`pull-only` / `not-pull-only`) per repo entry in `## Repo Information`,
  same detection and root exemption as Item 2, and omits the `issues:` store
  path for a `pull-only` entry (both in the block and in
  `## Local Issue Folders` via `collect_issue_artifact_paths`).
- **RED:** structural/behavioral assert in a sandbox: run session-init, grep
  for `writability: pull-only` and the suppressed store path.
- **GREEN:** implement.
- **Instrument:** run the tool in the Item-3 sandbox; or unit assertion if a
  driver test exists — session-init has no dedicated unit-test directory, so
  the check runs the tool directly in the sandbox.

## Item 6 — Runtime workspace verifications, spec Section 4 constructions (SC-1, SC-5, SC-6, SC-7, SC-8)

- **Deliverable:** A run-each-construction pass executing the spec's named
  runtime instruments in `/tmp/opencode` sandboxes against the changed tools:
  - **SC-1:** registered submodule at `.opencode`, its origin rewritten to an
    `https` URL that resolves to nothing, root `origin` a reachable local bare
    repo; run `init` — exit 0, no `issues-data` branch, no `.issues` worktree
    in the submodule.
  - **SC-5:** root whose effective origin is an http URL served by a local git
    HTTP endpoint backed by a bare repo with an `issues-data` branch and
    `http.receivepack` enabled; run `init` — exit 0, worktree registered, and
    `session-init` reports `writability: not-pull-only` plus the store path for
    the root.
  - **SC-6:** workspace root (local bare origin) plus registered submodule
    `sub/deck` whose effective origin is `git@127.0.0.1:local/deck.git`,
    satisfied by a `GIT_SSH_COMMAND` shim executing `upload-pack`/`receive-pack`
    against a local bare repo carrying `issues-data`; `init` succeeds, the
    store is created, `writability: not-pull-only` + store path reported.
  - **SC-7:** the SC-6 workspace without init, submodule checked out moved off
    the recorded gitlink (`+` form confirmed); `init` gives it a store.
  - **SC-8:** registered submodule `git submodule deinit --all` (empty
    checkout); `init` exits 0 and creates no worktree inside the submodule
    directory.
- **RED:** each construction run against the pre-Item-3 tool fails its
  assertion (the store mounts in the pull-only submodule for SC-1; SC-8 aborts
  the bootstrap).
- **GREEN:** verified after Items 1–4 land; SC-1/SC-8 additionally gate the
  final state.
- **Instrument:** the executable constructions above — exit statuses,
  `git -C ... branch`, `git worktree list`, `ls -a`, and the
  `session-init` output read per criterion. These are transient checks, not
  committed test files (the spec does not require committed runtime tests; the
  harness scenario Item 8 carries the behavioral surface).

## Item 7 — Card texts (R-6, R-7, R-8, R-9 → SC-9, SC-10, SC-11, SC-12)

- **Deliverable:** `skills/git-workflow-branch/SKILL.md`: pull-only delivery
  clause (names the registered-submodule whose origin is pull-only state;
  forbids attempting the push that cannot succeed; leaves delivery choice to
  agent judgment — a repository the agent can push to, or reporting to the
  developer; no forbidding of delivering from a pushable repository) + scope
  rules 2/3 to registered submodules with the no-pointer statement for
  non-tracked checkouts. `skills/issues/SKILL.md`: pull-only store rule
  (no store, no local-store operations, platform-CLI against its own tracker) +
  qualified operating-contract line. `references/local-issues-cli.md` `init`
  row and `references/sync-mirroring.md` `init` bullet (and its `.gitmodules`
  sentence at line 12): registered-submodule vocabulary + pull-only carve-out.
- **RED:** n/a (structural) — text does not exist; inspection after edit.
- **GREEN:** edit the four files.
- **Instrument:** SC-9..SC-12 inspection lists.

## Item 8 — Unit-test suite green (R-10, SC-14, SC-15) + SC-13

- **Instrument:** full `uv run --group dev pytest` — zero failures; the four
  named test functions retained with their properties (SC-15 assertions).
  SC-13: `git diff --name-only` against base tip shows exactly the seven
  surfaces + the one added file; `local-issues --help` command list unchanged.

## Item 9 — Behavioral scenario SC-16/SC-17

- **Deliverable:** one scenario script under `tests-v2/behaviors/`
  (`SCENARIO_TIER="2"` — Docker tier, whose env-level URL rewrite makes the
  deck submodule's effective origin `https`), asking the agent for a change to
  the deck and its delivery; run through the harness producing `session.yaml`;
  clean-room evaluation sub-agent judges SC-17 from the recording.
- **Instrument:** harness run per the two-SC pattern in `tests-v2/AGENTS.md` §6a.

## Dependency order

1 → 2 → 3 → 4 → 5 (all tool-side, each builds on verified prior state) → 6
(runtime workspace verifications, against items 1–4) → 7 (card texts) → 8 → 9.
Item 9 runs strictly after Item 7: its SC-17 judgment evaluates the agent
against the delivery clause Item 7 introduces into `git-workflow-branch`, so
the card text must exist before the recorded run. Items 7 and 8 execute on the
same branch with no cross-dependency except sequencing above.