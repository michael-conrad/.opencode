<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored bug report, filed 2026-10-19 by michael-newsrx
     (michael-conrad/.opencode#2642, labels spec-fix + local-issues). Triaged
     2026-11-04 under the developer dispatch "triage .opencode#2642" and
     converted in place into this governing spec under the work-entry
     conversion (issues card §5, .opencode#2707 mechanics), per the worked
     precedents .opencode#2681 and .opencode#2704. Triage evidence:
     research/triage-2026-11-04.md. Adjacent records: .opencode#2667 (the
     discovery mechanism this spec refines — registered-submodule membership
     was R-1's eligibility rule; the pull-only carve-out it established stays),
     .opencode#2544 (session-init's wiki-origin exclusion), .opencode#2446
     (related pointer — different facet, closed). -->

# [SPEC] local-issues gates child store hosts on issue-host evidence — no child auto-bootstrap, no push to ref-less remotes

## Problem

`tools/local-issues` treats every registered `.gitmodules` child repository as
an issue host and auto-bootstraps an issue store for it. The filing report's
live observation (2026-10-19, `hermes-ingest-pubmed`): the only registered
child there is the GitHub wiki checkout (`git@github.com:NewsRx/hermes-ingest-pubmed.wiki.git`)
— a content repository with no issue role — and the tool created a store in it
anyway. The observed failures, with the code grounds verified 2026-11-04
(triage evidence: `research/triage-2026-11-04.md`):

- **O-1 — discovery has no issue-host evidence requirement.**
  `_discover_all_repos()` returns the tool's project root plus every
  registered initialized submodule; no check asks whether the child actually
  hosts issues.
- **O-2 — the bootstrap sweep provisions stores on every discovered child.**
  `_ensure_all_worktrees()` creates the `.issues/` worktree in each
  non-pull-only discovered repository — in the wiki checkout, a gitignored
  directory the operator never asked for.
- **O-3 — the minted store branch carried wiki trunk content** (`Home.md`, a
  wiki content page, at the branch head). Recorded from the filing session's
  live observation; not re-derived from this workspace's code.
- **O-4 — the bootstrap path pushed the store branch to the child's remote.**
  `_push_orphan_if_needed()` pushes `issues-data -u origin` whenever a remote
  exists (skipping only https-without-credentials). The wiki remote now
  carries a stray `refs/heads/issues-data` (b1f5156) — pollution of a
  special-purpose remote.
- **O-5 — every `init`/`sync` reported permanent conflict noise** while the
  remote ref did not yet exist: `_sync_repo()`'s pull-rebase against a
  ref-less remote fails, and the wiki entry reported
  `status: conflict` / `"fatal: couldn't find remote ref issues-data"` until
  the auto-push landed.
- **O-6 — `doctor` called the phantom store `HEALTHY`.**
  `_doctor_repo_report()` marks `branch_state=HEALTHY` whenever the local
  branch exists; no signal distinguishes a spurious store from a real one.
- **O-7 — the defect is self-healing-defeating.** Removing the local worktree
  does not fix it: the next `init` recreates the store and re-syncs (observed
  live in the filing session; `cmd_init()` runs the bootstrap sweep on every
  invocation).

Root cause covered: discovery's store-host rule keys on submodule
registration alone — `.opencode#2667` R-1 made registered-submodule
membership the eligibility rule without an issue-host evidence gate — and the
bootstrap/sync/push paths propagate whatever discovery hands them, including
minting and pushing a store branch toward a remote that never carried one.

## Scope

The tool's store-host membership and the paths that provision or propagate
child stores, plus the surfaces that describe or observe them:

- `.opencode/tools/local-issues` — discovery (`_discover_all_repos`,
  `_registered_store_host_paths`), the bootstrap sweep (`_ensure_all_worktrees`,
  `_ensure_worktree`, `_create_issues_worktree`, `_push_orphan_if_needed`),
  the sync path (`_sync_repo`, `_push_issues_branch_safe`), the
  `sync-file` path (`_sync_file_in_worktree`, `cmd_sync_file`), the
  mutation auto-push (`_auto_commit`, `_push_issues_changes`), `doctor`
  (`_doctor_repo_report`, `cmd_doctor`), the mutation path's store-host
  resolution and refusal diagnostic, and the explicit opt-in surface.
- `.opencode/tools/session-init` — the child store claims only: the
  Repo Information block's `issues:` field for child entries and the
  Local Issue Folders section's bootstrap hint for children.
- `skills/issues/SKILL.md` — the operating-contract sentence defining which
  repositories hold stores.
- `skills/issues/references/local-issues-cli.md` — the `init` row and the
  store-semantics section.
- `skills/issues/references/sync-mirroring.md` — the store-shape and
  initialization text describing `init`'s repository set.
- `tests/test_local_issues/` and `tests/test_session_init/` — the unit tests
  pinning the child-discovery mechanism carry their expectations onto the
  gated mechanism.

Out of scope:

- **The stray `refs/heads/issues-data` (b1f5156, containing `Home.md`) on
  `NewsRx/hermes-ingest-pubmed.wiki`.** Deletion is maintainer-side:
  remote-branch deletion is a destructive action the agent performs only on
  explicit developer instruction. This spec records the cleanup item; it
  orders no deletion.
- **The workspace root's store behavior.** The root — the repository the
  `.opencode/` deck directory carrying the tool belongs to — remains an
  unconditional store host; its establishment push is preserved and pinned.
- **Pull-only children (`.opencode#2667`).** The classification, the refusal,
  the no-store steady state, and the doctor marker are unchanged.
- **Session-init's wiki-origin exclusion (`.opencode#2544`).** Session-init
  keeps excluding wiki-origin repos from enumeration; this spec changes only
  its store claims for children it does enumerate.
- **Nested submodules at depth two or deeper.** The store scope stays the
  workspace root plus its direct children.
- **Un-pollution logic.** No code path deletes or repairs a polluted child
  remote. The gate prevents new pollution; existing pollution is cleaned by
  the operator (remote-branch deletion maintainer-side, local worktree
  removal operator-side).
- **Deck rule text beyond the three surfaces named above.** No work-card,
  plan-card, or verify-card changes.

## Requirements

- **R-1 — Evidence-gated child store hosts.** The tool SHALL classify a child
  repository (any discovered repository other than the tool's project root)
  as a store host only when the issue store already exists on it: the
  child's origin carries the `issues-data` ref, verified at discovery time,
  or a local `.issues/` store worktree exists in the child. A child with
  neither evidence — including one whose remote ref cannot be verified —
  SHALL NOT be a store host: `init` creates no worktree, no branch, and no
  store artifact in it; `sync` performs no fetch, no rebase, and no push
  against it and reports it as an informational non-host steady state (the
  pull-only entry's shape); a mutation naming it SHALL be refused with a
  diagnostic that names the child's non-host classification and the opt-in
  path. The tool's project root SHALL remain an unconditional store host.
- **R-2 — No child-origin store-branch creation from the passive paths.**
  Before any passive path — the sync path (`_sync_repo`), the `sync-file`
  path (`cmd_sync_file`), the bootstrap sweep, or a mutation command's
  auto-push — operates against a child repository's origin, the tool SHALL
  verify that the origin carries the `issues-data` ref (a live verification
  against a reachable origin). When the origin is reachable and the ref is
  verified absent, the passive path SHALL perform none of its operations
  against that origin — reporting an informational steady state, not a
  failure. When the child's origin cannot be verified — unreachable — a host
  child's sync and mutation paths SHALL keep the existing failure semantics
  (the failure statuses and the non-zero sync exit the `.opencode#2548` C2
  contract pins): a transient outage is never reported as an intentional
  steady state. A non-host child (R-1's classification) is skipped entirely
  on either remote state. The opt-in adoption path (R-3) and the workspace
  root's establishment push are the only origins of a child's remote store
  ref.
- **R-3 — Explicit opt-in provisioning.** The tool SHALL provide an explicit
  opt-in on `init` that provisions a store on one named child: the store
  worktree, the store branch, and the establishment push to that child's
  origin. No other path SHALL provision a child store. The opt-in SHALL
  refuse a pull-only child (the `.opencode#2667` R-3 refusal) and a path
  that is not a registered child of the workspace root, and each refusal
  diagnostic SHALL name its ground — the pull-only classification, or the
  not-a-registered-child ground. The opt-in SHALL leave the named child's
  origin carrying the `issues-data` ref and SHALL exit non-zero when the
  establishment push does not take effect; a re-run of the opt-in on a child
  whose store worktree exists but whose origin ref is absent SHALL perform
  the establishment push — the opt-in completes the establishment and does
  not short-circuit on the worktree's existence.
- **R-4 — `doctor` reflects the gate.** `doctor` SHALL apply the same
  host-evidence rule: a child with neither evidence carries the non-host
  classification in its marker line instead of a branch-state health verdict,
  and no `UNHEALTHY` marker fires for a child whose absent store is
  intentional — the marker pattern `.opencode#2667` R-4 established for
  pull-only repositories.
- **R-5 — Session-init's child store claims agree with the gate.** For a
  child repository that is not a store host under R-1, session-init SHALL
  emit no `issues:` store path in the Repo Information block and no
  `run local-issues init` bootstrap hint in the Local Issue Folders section.
  The root's claims and the pull-only exclusions are unchanged.
- **R-6 — The deck text states the gate.** The `issues` card's
  operating-contract store-host sentence and the two operating references
  (`local-issues-cli.md`, `sync-mirroring.md`) SHALL describe the child
  store-host rule as evidence-gated with the opt-in path named, and SHALL NOT
  describe registered-submodule membership alone as the child eligibility
  rule. The root's unconditional-host description is unchanged.
- **R-7 — Surface bound and suite.** The change SHALL touch only the surfaces
  named in Scope and SHALL add no tool command beyond the opt-in on `init`.
  The deck's unit-test suite SHALL pass after the change, with the tests that
  pin the child-discovery mechanism carrying their expectations onto the
  gated mechanism and keeping the properties they were written for.

## Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|-----------|
| SC-1 | A registered child with no store evidence — reachable pushable origin, no `issues-data` ref, no local `.issues/` — receives no store, and the reports say so: `local-issues init` exits successfully, the child has no `.issues` directory and no `issues-data` branch, the child's origin carries no `issues-data` ref afterward, and the init report carries the child's informational non-host steady-state entry (the pull-only entry's shape — classification, no operation result). | behavioral (runtime effect) | Construct the workspace per the `.opencode#2667` SC-6 fixture family: workspace root whose origin is a reachable local bare repository, the deck's `tools/` at `<workspace>/.opencode/tools/`, and a registered submodule at `sub/deck` whose origin is a reachable bare repository carrying no `issues-data` branch. Run `<workspace>/.opencode/tools/local-issues init`; read its exit status and per-repo report (the entry naming `sub/deck`), then `ls -a sub/deck`, `git -C sub/deck branch`, `git -C sub/deck worktree list`, and `git -C sub/deck ls-remote origin`. |
| SC-2 | A mutation naming a non-host child is refused with a diagnostic naming the child's non-host classification and the opt-in path, and the refusal creates no store artifact in the child. | behavioral (runtime effect) | In the SC-1 workspace (before any adoption), run `create --number 'deck#9999' --title probe` (the child's qualifier) and read the exit status, the diagnostic text (it names the non-host classification and the opt-in path), `ls -a sub/deck`, and `git -C sub/deck branch`. An unknown-repository refusal alone, a diagnostic missing either element, or a refusal that created the store, fails. |
| SC-3 | The passive paths never touch a child's ref-less remote: a child holding a local store worktree whose origin lacks the `issues-data` ref is synced with no fetch, no rebase, and no push — its report entry is an informational steady state (not a failure status), `sync` exits successfully, `sync-file` naming that child's store file likewise performs no push and reports an informational steady state while exiting successfully, a mutation naming that child commits locally and performs no push, and the ref stays absent through all three. | behavioral (runtime effect) | In a workspace as in SC-1, adopt the child, create one record in it (the record's auto-push lands while the ref exists), then delete the remote ref from the child's bare origin (`git -C <bare> branch -D issues-data`). Run `local-issues sync`; run `local-issues sync-file --file 'deck#0001/issue.yaml'` (the child's qualifier); run `local-issues update --number 'deck#0001' --title probe2` (a mutation whose auto-push is gated). Read all three entries and exit statuses, and `git -C sub/deck ls-remote origin` — the ref stays absent and each entry reports no push against the child's remote. |
| SC-4 | The opt-in provisions a store on a named child: `init` with the opt-in naming the registered child leaves the child with an `.issues` worktree, a local `issues-data` branch, and an `issues-data` ref on its origin. | behavioral (runtime effect) | In the SC-1 workspace, run `local-issues init` with the opt-in naming `sub/deck` and read `ls -a sub/deck`, `git -C sub/deck branch`, and `git -C sub/deck ls-remote origin`. |
| SC-5 | A real host child on a fresh clone still bootstraps from its remote: a registered child whose origin carries `issues-data` and which has no local store receives the store worktree from the remote, and `init` exits successfully. | behavioral (runtime effect) | Construct the SC-1 workspace with the child's bare origin carrying an `issues-data` branch (seeded with one issue record); run `local-issues init` and read the exit status, the child's worktree registration, and the seeded record's presence in `sub/deck/.issues/`. |
| SC-6 | `doctor` reports a non-host child with the non-host classification and no `UNHEALTHY` marker. | behavioral (runtime effect) | In the SC-1 workspace, run `local-issues doctor` and read the marker line naming `sub/deck`: it carries the non-host classification and does not carry `UNHEALTHY`. |
| SC-7 | Session-init's child store claims agree with the gate: a non-host child carries no `issues:` store path in the Repo Information block and no bootstrap hint in the Local Issue Folders section; the root's claims are unchanged. | behavioral (runtime effect) | In the SC-1 workspace, run `./.opencode/tools/session-init` and read the Repo Information block entry naming the child and the Local Issue Folders section: no `issues:` line and no `run ./.opencode/tools/local-issues init` hint names the child; the root's `issues: .issues/` line is present. |
| SC-8 | A wiki-origin child — the report's exact repro shape — receives no store: no `.issues` directory, no branch, and no push toward the wiki remote. | behavioral (runtime effect) | Construct the SC-1 workspace with the child's origin URL ending in `.wiki.git` (a local bare repository so the transport is reachable); run `local-issues init` and read the exit status, `ls -a`, the branch list, and `ls-remote origin` for the child. |
| SC-9 | The deck's unit-test suite passes with the gated mechanism, and the tests that pinned child discovery keep the properties they were written for: discovery is CWD-independent; a registered child with host evidence is discovered; the doctor's per-repository attribution covers a child; the pull-only expectations stand; and the gated classification's evidence branches — local-only, remote-only, neither, and unverifiable-remote — carry unit coverage. | behavioral (runtime effect) + structural | Run `uv run --group dev pytest` in the deck and read the summary (no failures). Then read the updated tests: the CWD-independence assertion, the child-discovery assertion (now with host evidence in the fixture), the doctor attribution assertion, the pull-only assertions, and the four evidence-branch coverage tests are each present. |
| SC-10 | The three deck-text surfaces state the gate: the `issues` card's operating-contract store-host sentence, the `local-issues-cli.md` `init` row, and the `sync-mirroring.md` store-shape/initialization text each describe child store-host membership as evidence-gated with the opt-in path named, and none describes registered-submodule membership alone as the child eligibility rule. | structural | Read each surface: the evidence rule and the opt-in are stated for children; the root's unconditional-host statement survives in each; no surface states registration-alone eligibility. |
| SC-11 | The change touches only the surfaces named in Scope and adds no tool command beyond the opt-in on `init`. | structural | The changed-file list against the base tip, plus `local-issues --help` compared with the base revision's command list (the opt-in is a flag on the existing `init` command, not a new command). |
| SC-12 | The opt-in's refusals name their grounds: on a registered child whose origin is an `https` URL resolving to nothing, the opt-in is refused with a diagnostic naming the pull-only classification; on a path that is not a registered child of the workspace root, the opt-in is refused with a diagnostic naming the not-a-registered-child ground; neither refusal creates a store in any target. | behavioral (runtime effect) | In a workspace whose child's origin is an `https` URL resolving to nothing (the `.opencode#2667` SC-1 rewrite — the child is pull-only there regardless of host evidence), run the opt-in naming the child and read the diagnostic: it names the pull-only classification. In the SC-1 workspace, run the opt-in naming a plain directory that is not a registered child (a `scratch/` directory created for the run) and read the diagnostic: it names the not-a-registered-child ground. After both runs, read `ls -a` and the branch lists of both targets: no store artifact exists. |
| SC-13 | The opt-in's establishment failure is visible and completable: on a named child whose origin rejects pushes, the opt-in exits non-zero with a diagnostic naming the failed establishment while the store worktree exists locally; a re-run of the opt-in on that child once its origin accepts pushes performs the establishment push — exits successfully with the origin carrying the `issues-data` ref. | behavioral (runtime effect) | Construct the SC-1 workspace with the child's origin served by the `.opencode#2667` SC-6 SSH-shim family with `git-receive-pack` made to fail (`git-upload-pack` working), so fetch succeeds and push fails. Run the opt-in naming `sub/deck`: read the non-zero exit, the diagnostic (it names the failed establishment), `ls -a sub/deck` (the worktree exists), and `git -C sub/deck ls-remote origin` (the ref is absent). Restore `git-receive-pack` in the shim, re-run the opt-in naming `sub/deck`: read the zero exit, `ls -a sub/deck`, and `git -C sub/deck ls-remote origin` (the ref is present). |
| SC-14 | A child whose origin is unreachable degrades to the informational skip, not a fatal abort: with the child's origin an ssh URL to an unreachable endpoint and no local store, `init` exits successfully, creates no store artifact in the child, and the child's report entry is the informational non-host steady state. | behavioral (runtime effect) | Construct the SC-1 workspace with the child's origin the ssh URL `git@127.0.0.1:<closed-port>/local/deck.git` (a port with nothing listening, so `git ls-remote` fails immediately) and no `issues-data` branch seeded. Run `<workspace>/.opencode/tools/local-issues init`; read its exit status (zero), the per-repo report (the child's entry is the informational steady state), `ls -a sub/deck`, and `git -C sub/deck branch` (no `issues-data` branch). |
| SC-15 | A host child whose origin is unreachable keeps the existing failure semantics: with the child holding a local store worktree and its origin unreachable, `sync` attempts the store operations and exits non-zero with a failure status — the transient outage is not reported as an intentional steady state. | behavioral (runtime effect) | In the SC-1 workspace, adopt the child (its store worktree exists), then make the child's origin unreachable (stop the endpoint serving it, or rewrite the child's origin to a closed port's ssh URL). Run `local-issues sync`: read the non-zero exit and the child's entry — a failure status (`conflict`, `push_failed`, or `timeout`), not a steady-state skip. Restore the origin, re-run `sync`: zero exit, `ok`. |

## Approach

1. **Host classification over enumeration, not discovery exclusion
   (R-1, R-2, R-4).** Discovery keeps enumerating the registered child set —
   `_discover_all_repos()`'s membership is unchanged, because the reporting
   and resolution layers read that set: the init/sync report
   (`_collect_repos()`), `doctor`'s per-repo rows (`cmd_doctor()`), and the
   mutation path's name resolution (`_resolve_worktree_from_path()` and its
   resolver helpers) each need the child present to report or refuse it. The
   host-evidence rule becomes a classification layer over the enumerated
   set: a child is a store host when its origin carries a live-verified
   `issues-data` ref (`git ls-remote` — a stale remote-tracking ref is not
   verification) or a local `.issues/` worktree marker (the tool's own
   `(issues_dir / ".git").is_file()` detection); otherwise it is a non-host.
   The consuming points apply the classification: the bootstrap sweep
   provisions only hosts; the sync path reports a non-host child as the
   informational steady state (the pull-only entry's shape) and gates a host
   child's fetch, rebase, and push on the verified remote ref (R-2);
   `doctor` emits the non-host classification row (R-4); the mutation path
   resolves registered children and refuses non-hosts (R-1). Network absence
   degrades safely — a real host child on a fresh clone simply does not
   bootstrap that session and bootstraps when the remote is reachable again.
2. **Passive-path gates (R-2).** For a child repository, the sync path's
   fetch, rebase, and push, the `sync-file` path's push, and the
   bootstrap-sweep and mutation pushes each verify the origin's
   `issues-data` ref (`git ls-remote`, live) before operating. A reachable
   origin with the ref verified absent yields an informational skip entry —
   no operation runs against that origin. An origin whose ref cannot be
   verified is not a skip: a host child's operations attempt and fail
   through the existing failure statuses and the non-zero sync exit (the
   `.opencode#2548` C2 contract), so a transient outage is never disguised
   as an intentional steady state. The root's establishment push keeps its
   current behavior.
3. **Opt-in (R-3).** `init` gains a per-invocation adoption flag naming one
   registered child. The adoption path is establishment-completing, not a
   bootstrap wrap: it checks the named child's worktree and remote ref
   independently, provisions what is missing (worktree via the existing
   bootstrap, branch via the orphan path, remote ref via the establishment
   push), verifies the push outcome against the live remote ref, and exits
   non-zero when the ref is absent after the attempt — so a failed
   establishment push is visible at adoption time and a re-run completes it.
   The refusal diagnostics for pull-only and unregistered paths follow the
   `_reject_pull_only()` pattern; the mutation path's non-host refusal
   reuses it. The store's existence is the persistent record — the flag is
   the establishment instrument, idempotent over the establishment state.
4. **Doctor (R-4).** `_doctor_repo_report()` gains the non-host
   classification row — `classification=non-host`, no branch-state health
   verdict — beside the existing pull-only row.
5. **Session-init (R-5).** The child store claims consult the same evidence:
   a non-host child emits neither the `issues:` field line nor the bootstrap
   hint. No enumeration change — `.opencode#2544`'s wiki exclusion and the
   pull-only skips stand.
6. **Docs (R-6).** The three deck-text surfaces are reworded to the
   evidence-gated rule with the opt-in named; deck-text edits ride the
   `skill-creator` admission gate at implementation, with this report as the
   observed-failure evidence.
7. **Tests (R-7).** The unit tests' child fixtures gain host evidence or
   assert the gated exclusion; new unit coverage pins the evidence rule's
   branches (local-only, remote-only, neither, unverifiable-remote) and the
   push gates; the construct-workspace behavioral SCs above execute the
   runtime effects.

Discarded alternatives:

- **Transport-based gating** (extending `.opencode#2667`'s origin-scheme rule
  to exclude wiki URLs from local-issues): rejected — transport is not
  issue-host evidence; `.opencode#2667` SC-6 pins pushable ssh children as
  legitimate hosts, and the report's defect is evidence-shape, not transport.
  The wiki child is excluded by the same evidence rule every non-host child
  is (SC-8 pins the repro shape).
- **Strict conjunctive evidence** (remote ref AND local record, the report's
  parenthetical read literally): rejected — it would stop bootstrapping real
  host children on fresh clones, a regression of existing intended behavior
  (session-init's own hint text promises it; the remote-branch-bootstrap
  tests pin it) that the report does not ask for.
- **Un-pollution logic** (the tool deleting stray child-remote refs): rejected
  — remote-branch deletion is destructive and maintainer-side; the tool's
  mandate stops at not creating new pollution.
- **A persistent config file listing host children:** rejected — the store's
  own existence is the persistent state; a one-shot adoption flag establishes
  it without adding a second declaration surface to maintain.

## Impact

- **Consumers:** every workspace whose root registers child repositories —
  the tool's discovery, sync, doctor, and mutation paths; session-init's
  per-session repo table and Local Issue Folders section; the agents reading
  them.
- **Benefit:** content children (wikis, vendored checkouts) no longer receive
  phantom stores; child remotes are never polluted by store-branch pushes
  from the passive paths; the conflict-noise class disappears for non-hosts;
  `doctor` and session-init report store truthfully.
- **Risk — network-down behavior, two cells:** a child whose remote ref is
  temporarily unverifiable and which holds no local worktree does not
  bootstrap that session (deferred, no store minted wrongly); a host child
  holding a local worktree keeps the existing failure semantics — its sync
  fails visibly with a non-zero exit (the `.opencode#2548` C2 contract), a
  transient outage is never disguised as a steady state (SC-15).
- **Risk — transitional polluted state:** a child polluted before this fix
  (remote ref present, or local worktree present) is evidence-classified a
  host until the operator's cleanup removes both artifacts; sync and doctor
  then describe a real store. The cleanup path is recorded in Scope.
- **Risk — adoption misuse:** the opt-in could provision a store on an
  unintended child. Bounded: the flag is explicit and per-invocation, names
  the child, refuses pull-only and unregistered paths, and the provisioned
  store reverses by operator cleanup.
- **Blast radius:** `.opencode/tools/local-issues`,
  `.opencode/tools/session-init`, the three deck-text surfaces, and the two
  unit-test directories. No hook, plugin, or scenario-harness changes.
- **Dependent tests:** the unit suite — notably `test_cwd_independence.py`,
  `test_remote_branch_bootstrap.py`, `test_doctor_branch_health.py`,
  `test_pull_only.py` — carries its expectations onto the gated mechanism
  (SC-9).
- **Recovery:** code, docs, and test changes reverse through branch history.
  A provisioned child store reverses by operator cleanup (worktree removal,
  then maintainer-side remote-branch deletion). Every element reverses.

---

*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
