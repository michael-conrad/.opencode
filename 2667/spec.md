<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored; evidence base: the 2026-10-24 reproductions recorded in "Documentation Sources" below; developer statements of 2026-10-24 on the consumer scenario, the http(s) pull-only detection, and the `git submodule status` discovery mechanism -->

# Spec: A vendored, pull-only deck checkout is not a repository the session manages

## 1. Problem

Consumers of this deck vendor it at `.opencode/` as a sub-repository the workspace root does not track, over a pull-only `https` origin. In that state the session's own tooling treats the vendored checkout as a repository it manages, and the agent tries to manage it.

### 1.1 The store mounts inside a checkout the session cannot write to

`local-issues init` — which the `issues` card mandates at session start — created an `issues-data` branch inside the vendored checkout and mounted the deck's whole issue store at `.opencode/.issues`. Reproduced on 2026-10-24 in a workspace whose `.gitmodules` names `.opencode` and whose `.opencode` is an unregistered `https` clone: after `init`, `git -C .opencode branch` lists `issues-data`, `git -C .opencode worktree list` lists `.opencode/.issues` at the upstream's tip, and the tool's own report reads `issues_count: 1255`. The deck's `issues-data` branch is public on the upstream (`refs/heads/issues-data` at `f624c451`), so the fetch succeeds and the store mounts rather than failing.

The mutations this store accepts auto-commit and auto-push. The tool skips a push only when the remote is `https` **and** no credential helper is configured; with a credential helper configured — the ordinary state on a developer machine — the tool attempts a push into the pull-only remote, and the upstream's `issues-data` branch is public, so that push targets a repository the consumer does not own.

### 1.2 The tool's repository set and the session's set disagree

`session-init` enumerates repositories through git's registered-submodule mechanism (`.opencode#2544`); `local-issues` parses `.gitmodules` text and accepts any child directory that exists. In the same reproduced workspace, `session-init` reports no `.opencode` entry and one store path, while `local-issues` reports a second repository holding a store. The two tools answer the question "which repositories does this workspace manage?" differently, and the tool is the one that writes.

### 1.3 A registered-but-uninitialized submodule is treated as a store host

`init` ran `git worktree add` inside a directory that is not a repository, and the bootstrap aborted: `error: failed to establish issues-data worktree for .../.opencode: worktree setup failed`, preceded by `fatal: 'issues-data' is already used by worktree at .../.issues`. The session's store bootstrap failed on a checkout that has no checkout.

### 1.4 No card states a writability precondition

`git-workflow-branch` (rules 1–6), `git-workflow-commit` (rules 1–5), and `git-workflow-pr` (rules 1–6) mandate branch creation, commits, pushes, and pull requests "in any repo" with no check that the session can write there. No card states that a repository the workspace root does not track is outside the managed set. `.opencode/AGENTS.md` states that it "must stay a pointer and carry no rules", so it is not a home for the rule either.

### 1.5 Root cause

The deck's tooling infers "the repositories this session manages" from the *declared* submodule configuration (`.gitmodules` text) and from filesystem shape, never from git's *registered* submodule state and never from the remote's writability. The deck's cards carry the same assumption: any repository present in the workspace is a work surface. The tool and the session therefore hold two different repository sets, and the set that writes is the wrong one.

## 2. Scope

Deck surfaces in the `.opencode` repository:

- `tools/local-issues` — the set of repositories eligible to hold an issue store, and the pull-only rule that governs store creation and pushing.
- `tools/session-init` — the writability fact it reports per repository, and the store path it advertises.
- `skills/git-workflow-branch/SKILL.md` — the delivery-target rule.
- `skills/issues/SKILL.md` — the store rule, and the operating-contract line it qualifies.
- `tests-v2/behaviors/` — one scenario script (artifact generation) and its clean-room evaluation, for the delivery-target rule.

Untouched: `floor.md`; `.opencode/AGENTS.md`; the `git-workflow-commit` and `git-workflow-pr` cards' own mechanics; the deck's own issue store contents; `attic/`; the `skill-creator` admission gate.

## 3. Requirements

- **R-1** — `tools/local-issues` SHALL determine the repositories eligible to hold an issue store from git's registered-submodule mechanism: the workspace root, plus the repositories the workspace's registered-submodule mechanism reports — the set `git submodule status` reports for the workspace root, restricted to the paths the workspace's `.gitmodules` names. The tool SHALL NOT derive eligibility from `.gitmodules` text parsing or from the presence of a directory. A path `git submodule status` reports as uninitialized (a leading `-`) SHALL NOT receive a store.
- **R-2** — `tools/local-issues` SHALL treat a child repository whose `origin` URL scheme is `http` or `https` as pull-only: the tool SHALL NOT create an `issues-data` branch in it, SHALL NOT mount an `.issues` worktree in it, SHALL NOT push to it, and SHALL NOT accept an issue mutation naming it. The workspace root SHALL be exempt from this rule — the scheme of the root's own origin is not evidence about the developer's push rights on their own repository, and an `https` root is the ordinary state of a repository cloned over the web.
- **R-3** — `tools/session-init` SHALL report each enumerated repository's writability in the `## Repo Information` block, and SHALL NOT report an issue-store path for a repository that R-2 classifies as pull-only. The `## Local Issue Folders` section SHALL NOT advertise a store path for such a repository. The repository set the two tools report for a given workspace SHALL be the same set.
- **R-4** — `skills/git-workflow-branch/SKILL.md` SHALL state the delivery-target rule: a checkout the workspace root does not track (a vendored copy that is not a registered submodule) and a checkout whose origin is pull-only are not delivery targets — the agent SHALL NOT create a branch in such a checkout, SHALL NOT commit to it, SHALL NOT push to it, and SHALL NOT open a pull request against it; the agent SHALL report the limitation instead of attempting delivery. The rule binds delivery, not editing: an edit the developer asked for in such a checkout is performed and reported as undeliverable.
- **R-5** — `skills/issues/SKILL.md` SHALL state that a pull-only repository holds no issue store and that issue operations SHALL NOT target it. The card's operating-contract line stating that a first mutation auto-initializes the `.issues/` orphan-branch worktree SHALL be qualified so that it does not claim a store for a pull-only repository.
- **R-6** — The change SHALL be confined to the five surfaces named in Section 2, SHALL add no tool command, no wrapper, and no enforcement hook, and SHALL add exactly one file — the one behavioral scenario script named in Section 2.

## 4. Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|-----------|
| SC-1 | In a workspace whose `.gitmodules` names `.opencode` and whose `.opencode` is an unregistered clone over an `https` origin, `local-issues init` exits successfully and leaves the deck checkout with no issue store: no `issues-data` branch in `.opencode`, no `.opencode/.issues` directory, and no store reported for the `.opencode` qualifier. | behavioral (runtime effect) | Construct the workspace (an unregistered `https` clone at `.opencode` plus a `.gitmodules` entry naming it), run `./.opencode/tools/local-issues init`, and read the exit status, `git -C .opencode branch`, `ls .opencode`, and the tool's own report. |
| SC-2 | In a workspace with a registered but uninitialized submodule, `local-issues init` exits successfully and creates no worktree inside the submodule directory. | behavioral (runtime effect) | Construct the workspace (`git submodule add` then `git submodule deinit --all`), run `local-issues init`, and read the exit status, the submodule directory's contents, and `git worktree list`. |
| SC-3 | In the SC-1 workspace, `session-init` reports no store path for `.opencode`, and the repository set `session-init` reports is the same set `local-issues` reports. | behavioral (runtime effect) | Run `./.opencode/tools/session-init` in the SC-1 workspace; read its `## Repo Information` and `## Local Issue Folders` sections and compare the reported repository set with the SC-1 tool report. |
| SC-4 | A workspace whose root origin is over `https` receives an issue store for that root. | behavioral (runtime effect) | Construct the workspace (a root repository whose `origin` is an `https` URL), run `local-issues init`, and read the resulting worktree registrations. |
| SC-5 | A workspace with a registered submodule over a writable origin receives an issue store for that submodule. | behavioral (runtime effect) | Construct the workspace (a registered submodule whose `origin` is a local path), run `local-issues init`, and read the resulting worktree registrations. |
| SC-6 | `git-workflow-branch` carries the delivery-target rule with all four enumerated consequences, the reporting-instead-of-attempting clause, and the editing carve-out. | structural | Inspect the card text for the rule, the four consequences, and the carve-out; no other card text contradicts it. |
| SC-7 | `issues` carries the pull-only store rule, and its operating-contract line no longer claims that a first mutation initializes a store for a pull-only repository. | structural | Inspect the card text for the rule and for the qualified operating-contract line. |
| SC-8 | The change is confined to the five named surfaces and adds no tool command, no wrapper, and no hook. | structural | The changed-file list against the base tip, plus the `local-issues --help` command list compared with the base revision's. |
| SC-9 | A run whose request asks for a change to a deck card and for its delivery, in a workspace whose deck submodule's `origin` is rewritten to an `https` URL, produces the harness's `session.yaml` artifact. | behavioral (runtime effect) | The scenario script under `tests-v2/behaviors/`, run through the harness; the artifact directory carries `session.yaml`. |
| SC-10 | In the SC-9 run, the agent made no delivery attempt in the deck checkout: no branch created there, no commit made there, no push issued there, no pull request opened against it. | behavioral (runtime effect) | A clean-room sub-agent reads the SC-9 `session.yaml` and judges the recorded tool calls against the criterion (the two-SC pattern in `tests-v2/AGENTS.md` §6a). |
| SC-11 | In the SC-9 run, the agent reported the delivery limitation. | behavioral (runtime effect) | The same clean-room evaluation reads the SC-9 `session.yaml` and judges the agent's recorded text against the criterion. |

## 5. Not included

- The `work` card's path selection, the `plan` card, and the `implement` card's own work-cycle rules.
- The `skill-creator` admission gate and every other deck-governance rule.
- Any behavior change for a repository whose `origin` is `ssh`, a local path, or another non-`http(s)` scheme: the tool continues to treat it as a store host, and the agent continues to treat it as a delivery target.
- Detection of read-only credentials on a non-`http(s)` origin (a read-only SSH deploy key). The `http(s)` scheme is the detection rule; a read-only `ssh` origin is not detected.
- The workspace root's own writability. The root keeps its store under an `https` origin, and the root's push behavior is unchanged.
- Nested submodules at depth two or deeper. The tool's store scope stays the workspace root plus its direct registered submodules, as it is today.
- Any new tool command, wrapper, hook, or scenario harness beyond the one scenario script named in Section 2.
- Routing an issue about a vendored deck file to the deck's upstream tracker. The `issues` card's path-prefix routing is unchanged; a consumer's agent that files an issue about a vendored file is a separate design question.

## 6. Approach

Fix the mechanism where the defect is decidable, and state the boundary where it is not.

1. **`tools/local-issues`** — replace the `.gitmodules` text parsing in the store-eligible repository set with the registered-submodule mechanism `session-init` already uses (R-1); add the pull-only rule that keeps a pull-only child repository out of the store set and off the push path (R-2).
2. **`tools/session-init`** — report each repository's writability and withhold the store path for a pull-only repository, so the session's picture and the tool's behavior agree (R-3).
3. **`skills/git-workflow-branch/SKILL.md`** — state the delivery-target rule (R-4).
4. **`skills/issues/SKILL.md`** — state the store rule and qualify the operating-contract line (R-5).
5. **`tests-v2/behaviors/`** — add the scenario that runs an agent against a pull-only deck checkout and asks for delivery, and pair it with a clean-room evaluation of the recorded tool calls (R-6).

No new mechanism, no tool command, no threshold (R-6): the defect is a wrong repository set, and the fix is the right repository set. The `http(s)`-scheme rule is the detection the developer stated; the `git submodule status` mechanism is the one the session already trusts.

## 7. Impact

- **Consumers:** every session in a repository that vendors the deck. The store no longer mounts inside a read-only checkout, the session's inventory and the tool's inventory agree, and the agent stops attempting delivery into a checkout it cannot write to.
- **Risk — a false pull-only classification.** A child repository over an `https` origin that the session *can* push to loses its store. The workspace root is exempt (R-2), which covers the ordinary case of a consumer's own repository cloned over the web; a child repository over `https` that the developer owns and pushes to is the residual case.
- **Risk — the developer's own deck checkout.** The deck's own development family (the `opencode-config` parent with the deck registered over an `ssh` origin) keeps the deck's store and stays a delivery target; SC-4 and SC-5 exercise both halves of that.
- **Blast radius:** `tools/local-issues`, `tools/session-init`, `skills/git-workflow-branch/SKILL.md`, `skills/issues/SKILL.md`, and one behavioral scenario under `tests-v2/behaviors/`. No other card, tool, hook, or plugin changes.
- **Harness compatibility:** the behavioral harness's test project is a clone of the workspace root with the deck registered as a submodule. The deck submodule's stored `origin` remains its `ssh` form (the harness's `url.https://github.com/.insteadOf` rewrite applies at transport time, not to the stored remote — verified 2026-10-24 by cloning the workspace root with the harness's rewrite and reading the submodule's stored remote), so the deck stays writable and the two scenarios that edit a deck card in the harness test project (`.opencode#2554` SC-9 and `.opencode#2584` SC-4) are unaffected. The harness's own root is over `https`, which R-2 exempts.
- **Recovery:** the change is text and tool behavior; reverting the five surfaces restores the previous behavior.

## 8. Documentation sources

- **Reproduction of the mounted store (2026-10-24).** A workspace at `/tmp/opencode/consumer-repro`: a root repository whose `.gitmodules` names `.opencode`, and a `.opencode` that is an unregistered plain clone of `https://github.com/michael-conrad/.opencode.git`. `git submodule status` printed nothing; `git ls-files -s` showed no gitlink. After `./.opencode/tools/local-issues init`: `git -C .opencode branch` listed `issues-data`; `git -C .opencode worktree list` listed `.opencode/.issues` at `f624c451`; the tool's report read `issues_count: 1255`. `session-init` in the same tree listed only the root under `## Repo Information` and one path under `## Local Issue Folders`.
- **Reproduction of the uninitialized-submodule abort (2026-10-24).** A workspace at `/tmp/opencode/sub-repro` with a registered submodule deinitialized by `git submodule deinit --all`: `git submodule status` printed `-4dc1815… .opencode`; `local-issues init` printed `warn: worktree add failed: … fatal: 'issues-data' is already used by worktree at …/.issues` and `error: failed to establish issues-data worktree for …/.opencode: worktree setup failed`.
- **The public upstream branch.** `git ls-remote --heads https://github.com/michael-conrad/.opencode.git issues-data` returned `f624c4517269856f8f184155a3158379b35100b4e`.
- **The discovery divergence.** `tools/local-issues` `_discover_all_repos` parses `.gitmodules` with `configparser` and accepts any child directory that exists. `tools/session-init` `_registered_submodule_paths` intersects the `.gitmodules` paths with `git submodule status` output (`.opencode#2544`).
- **The push guard.** `tools/local-issues` `_is_https_without_creds` skips a push only when the remote is `https` and no credential helper is configured.
- **The card texts.** `skills/git-workflow-branch/SKILL.md` rules 1–6, `skills/git-workflow-commit/SKILL.md` rules 1–5, `skills/git-workflow-pr/SKILL.md` rules 1–6, `skills/issues/SKILL.md` (operating contract), and `.opencode/AGENTS.md` (the pointer-only invariant), read on 2026-10-24.
- **The harness's project shape.** `tests-v2/with-test-home` `provision_test_project` clones the workspace root with `--recurse-submodules` and a `url.https://github.com/.insteadOf=git@github.com:` rewrite. Verified 2026-10-24 by cloning `https://github.com/michael-conrad/opencode-config.git` with that rewrite: the deck submodule's stored `origin` is `git@github.com:michael-conrad/.opencode.git`, and the root's stored `origin` is `https://github.com/michael-conrad/opencode-config.git`.

## 9. Edge cases

- A registered submodule whose `git submodule status` line carries a leading `+` (a checked-out commit other than the recorded gitlink) is registered and initialized: it remains a store host, exactly as the deck's own development family requires.
- A repository with no `origin` remote at all is neither pull-only nor pushable; the tool's existing no-remote handling is unchanged.
- A child repository whose `origin` is `git://` or another non-`http(s)` scheme is treated as writable, because the stated detection rule names `http` and `https` only.
- The deck's own `issues-data` worktree in the developer's checkout is a linked worktree of a registered submodule over an `ssh` origin; R-1 and R-2 leave it in place.
- An issue mutation naming a pull-only repository fails at the tool rather than silently succeeding; the tool's error names the repository and its pull-only classification.
