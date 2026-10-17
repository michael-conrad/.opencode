---
number: 1255
title: "[SPEC] Deviation-triggered worktree map in session-init"
state: OPEN
---

## Problem

The agent cannot see, from the session-start injection, which git worktrees
exist in the workspace or what branch each is on. The only worktree facts
session-init emits today are the `Worktree:` context line (when session-init
itself runs inside a linked worktree) and the `## Local Issue Folders` paths
for `.issues/` stores. Branch assignments, non-issue-store worktrees, and
stale (prunable) worktree registrations are invisible until the agent runs
git itself — and raw `git worktree list` output is misleading here: inside a
submodule, the main-worktree row is the module gitdir (`.git/modules/...`),
not a real worktree path (Git Display Quirks, `.opencode/.issues/AGENTS.md`).

Separately, the workspace contains `.git`-bearing paths of several kinds with
different operational semantics, and nothing in the injected surface
distinguishes them. The developer directive of 2026-10-16 states the
requirement: non-submodule git sub-repos must not be treated the same as
standard git submodules for agent operational purposes — the needs are
different, and the agent sometimes gets confused about this.

## Root Causes

- **RC1 — worktree facts absent from the injected surface.** `session-init`
  (`.opencode/tools/session-init`) emits no branch, existence, or staleness
  data for linked worktrees beyond the `.issues/` store paths. The agent
  must run git commands itself to learn what worktrees exist and what
  branches they hold, and a raw `git worktree list` reproduces the
  module-gitdir quirk rather than resolving it.
- **RC2 — sub-repo classes are indistinguishable in the injected surface.**
  Registered submodules, parent-repo linked worktrees (`.issues/` stores,
  feature worktrees), and embedded foreign repos all appear as
  `.git`-bearing directories. `## Repo Information` correctly lists only
  registered submodules (#2544 strict discovery), but no surface states or
  operationalizes the distinction for everything that is *not* a submodule,
  so agents conflate the classes.

## Design Decision — Sub-Repo Classification

Developer directive, 2026-10-16: non-submodule git sub-repos are not treated
the same as standard git submodules for agent operational purposes. Three
classes, three different operational profiles:

| Class | Example | Routing target | Pointer discipline | `git submodule` ops |
|---|---|---|---|---|
| Registered submodule | `.opencode` | yes — own owner/repo in `## Repo Information` | yes — pointer updates ride with parent commits | apply |
| Parent repo's linked worktree | `.issues/`, `.worktrees/main/` | no | n/a — same repository | never apply |
| Embedded non-submodule repo | unrelated clone under a gitignored path | no — never enumerated (#2544) | n/a — parent does not track it | never apply |

Operational consequences that follow from the classes:

- A branch checked out in one linked worktree cannot be checked out in
  another worktree of the same repository (git enforces this).
- Parent-repo git operations crossing `.issues/` paths corrupt branches;
  store operations go through `local-issues` or `git -C .issues/`.
- Linked worktrees are removed with `git worktree remove`/`prune`, never by
  deleting their directories as if they were plain content.
- Only registered submodules participate in `git submodule status/update`
  and in pointer-drift handling (`+` marker).

**Normative home of the rule:** the classification rule itself is deck card
content, not injected output. It lands in `git-workflow-branch` (which
already carries submodule sync discipline and the branch-exclusivity `+`
marker) via the skill-creator governance flow, with `issues` citing it —
not restating it. This spec's implementation scope is the session-init
surface only; the session-init surface contributes facts and never
misrepresents a worktree as a repo (SC-6, SC-8, SC-9).

## Approach

Session-init stays a facts-only carrier and gains a **deviation-triggered
worktree map**: in the standard workspace shape it injects nothing new, and
when the topology deviates from standard it injects one compact, accurate
map. Signal equals anomaly — the map appearing *is* the information that
topology is non-standard.

Facts that are constant in the standard shape (`.issues` store paths,
`issues-data` branch) are already injected by `## Local Issue Folders` and
documented in the `issues` card; restating them every session buys nothing.

## Worktree Map — Emission and Shape

**Enumerated repos:** the project root plus each checked-out registered
submodule, exactly the discovery set of `collect_repo_info()` (#2544:
registered-submodule mechanism, transitively; wiki-origin repos excluded;
uninitialized submodules produce no entry).

**Standard worktree set** for an enumerated repo R: R's main worktree plus
its `.issues` store worktree (`<R>/.issues`). Nothing else.

**Deviation triggers** — the map is emitted when any of these holds for any
enumerated repo:

- **T1** — a linked worktree outside the standard set exists (e.g. a
  feature worktree under `.worktrees/`).
- **T2** — git reports `prunable` for any linked worktree.
- **T3** — any linked worktree is in detached-HEAD state.
- **T4** — an `.issues` store worktree is on a branch other than
  `issues-data`.

**Shape** — emitted immediately after `## Local Issue Folders`:

```
## Worktree Map

<owner>/<repo>:
  <relpath> [<branch>] [current] [prunable]

submodule <relpath>:
  <relpath> [<branch>] [current] [prunable]
```

- One group per enumerated repo, in `## Repo Information` order; rows are
  the repo's linked worktrees excluding its main worktree, one row each.
- `<relpath>` is project_root-relative (`.issues`, `.worktrees/main`,
  `.opencode/.issues`); single-quoted when it contains whitespace.
- `<branch>` is the checked-out branch without `refs/heads/`; a detached
  worktree renders `[detached]` with no SHA.
- Flags in fixed order: `current` (the row whose resolved toplevel equals
  session-init's running toplevel), then `prunable`.
- **The map is complete when emitted** — every linked worktree of every
  enumerated repo appears, including standard `.issues` rows. A partial map
  would be misread as "no other worktrees exist".
- Every module-gitdir row is resolved to its real worktree toplevel before
  display; no `.git/modules/` path ever appears in the map.
- The standalone `Worktree:` line and all existing sections are unchanged.

## Success Criteria

| ID | Criterion | Class | Verification Instrument |
|----|-----------|-------|------------------------|
| SC-1 | With only the standard worktree set present, session-init emits no `## Worktree Map` section | behavioral | Run session-init in a scratch fixture workspace with standard topology; assert the `## Worktree Map` marker does not occur in the output |
| SC-2 | The pre-existing emission surface is preserved in every run: `## Hook Inventory`, `## Local Issue Folders`, `## Repo Information`, and `## Agent Tools` appear in their current relative order (with `## CLI Auth Status` preceding them when installed), and the `Worktree:` context line appears when session-init runs inside a linked worktree | behavioral | Run session-init twice in a scratch fixture workspace (once from the main worktree, once from inside a fixture linked worktree); assert ordered presence of the markers and conditional presence of the `Worktree:` line |
| SC-3 | With a linked worktree outside the standard set present, session-init emits `## Worktree Map` containing that worktree's project-relative path and its actual checked-out branch | behavioral | In a scratch fixture workspace: create a linked worktree on a new branch; run session-init; assert the map contains the worktree's relative path and that the displayed branch equals `git -C <worktree> rev-parse --abbrev-ref HEAD`; remove the worktree, prune, delete the branch, and verify cleanup |
| SC-4 | With a linked worktree whose directory has been removed, the map marks that row `prunable` | behavioral | In a scratch fixture workspace: create a linked worktree, delete its directory, run session-init, assert the row carries `prunable`; then `git worktree prune` and verify the registration is gone |
| SC-5 | When session-init runs from inside a linked worktree that is itself outside the standard set, that worktree's map row carries `current` | behavioral | In a scratch fixture workspace: create a non-standard linked worktree (its existence is trigger T1), run session-init with cwd set to that worktree, and assert its row carries `current` |
| SC-6 | Every line of the emitted map conforms to the specified grammar: group headers (`<owner>/<repo>:` or `submodule <relpath>:`) or rows (`<relpath> [<branch>\|detached] [current] [prunable]`) — no other line shape, no SHA, no absolute path, no prose | structural | Parse the emitted map section line-by-line against the grammar; assert zero non-conforming lines |
| SC-7 | When the map is emitted it is complete: each enumerated repo's group lists all of that repo's linked worktrees, including submodule `.issues` store rows | behavioral | In a scratch fixture workspace with a submodule carrying an `.issues` store plus a parent deviation trigger: run session-init; assert the submodule group contains the store row with `[issues-data]` |
| SC-8 | No `.git/modules/` path appears anywhere in the emitted map; submodule rows resolve to real worktree paths | structural | Run session-init with a map-triggering fixture; assert the substring `.git/modules` does not occur in the map section |
| SC-9 | An embedded non-submodule repo under a gitignored path neither triggers the map nor appears in it or in `## Repo Information` | behavioral | In a scratch fixture workspace with standard topology plus an embedded repo (`git init` under an ignored path): run session-init; assert no `## Worktree Map` and no group or entry naming the embedded path |

SC traceability: SC-3, SC-4, SC-7 answer RC1 (existence, branch accuracy,
staleness, submodule coverage — the original issue's stated need: which
worktrees exist, what branches they are on, whether any are prunable);
SC-6, SC-8, SC-9 answer RC2 and the 2026-10-16 directive (no
misrepresentation of worktree or foreign-repo class in the injected
surface); SC-1 carries the approved deviation-triggered design (no
constant-fact restatement in the standard shape); SC-2 preserves unchanged
behavior the change puts at risk; SC-5 carries the approved design
direction (deviation-triggered map with `current`/`prunable` flags,
2026-10-16).

## Edge Cases

- Worktree path containing whitespace → single-quoted `<relpath>`; grammar
  (SC-6) treats the quoted form as conforming.
- `git worktree list --porcelain` on a platform whose git lacks the
  `prunable` field → T2 never fires and no row is ever labeled `prunable`;
  the map still fires on T1/T3/T4. No mislabel is possible.
- Uninitialized submodule → no checkout, no group, no rows.
- Detached HEAD renders `[detached]`; the agent obtains the SHA on demand.
- Session-init run from inside an `.issues` store in standard shape → the
  `Worktree:` context line fires as today; the map stays absent unless a
  deviation trigger holds.

## Affected Files

- `.opencode/tools/session-init` — deviation detection, worktree
  enumeration with toplevel resolution, map emission.
- The tool's existing unit tests (added by #2088) — dependents of
  session-init behavior; they must be extended for the map and kept green.

## Out of Scope

- Changes to `session-enforcement.ts`: `buildPreImplementationGate()` was
  removed on 2026-06-23 (`02d19d17`) and the plugin was stripped to minimal
  on 2026-07-16 (`84c01a8b`); post-rip the deck has no pre-implementation
  gate. No second injection surface exists to update.
- Deck card edits (the classification rule in `git-workflow-branch`, the
  `issues` citation) — they go through the skill-creator governance flow as
  their own artifact, consuming the design decision recorded here.
- Embedded-repo discovery or enumeration — #2544 strict discovery stands;
  the map adds worktree facts without making worktrees routing targets.
- Automated pruning or remediation — the map is report-only.
- Format changes to `## Repo Information`, `## Local Issue Folders`, or the
  `Worktree:` line.

## Alternatives Considered

- **Always-on compact section** — rejected: in the standard shape it would
  restate constant facts (`issues-data` stores) in every session, including
  sub-agents; deviation-triggered emission keeps signal equal to anomaly at
  near-zero steady-state cost.
- **Raw `git worktree list --porcelain` passthrough** — rejected: it
  reproduces the module-gitdir rows the Git Display Quirks section warns
  about (verified live: `git -C .opencode worktree list` lists
  `.git/modules/.opencode` as a worktree), injects SHA noise, and invites
  exactly the class confusion the 2026-10-16 directive prohibits.
- **Rule prose inside the map** — rejected: the deck's doctrine is rules in
  cards loaded on demand; the injected surface carries facts. The taxonomy
  lands in `git-workflow-branch` via governance.
- **Enumerating embedded repos as map groups** — rejected: it would
  reintroduce filesystem-shape discovery that #2544 deliberately replaced
  with the registered-submodule mechanism, and would present foreign repos
  as operational peers.

## Risks

- **`prunable` availability** — verified present in git 2.43.0 porcelain
  output (probe: stale registration yields
  `prunable gitdir file points to non-existent location`); older git
  degrades per the edge case, never mislabels.
- **Cost** — one `git worktree list --porcelain` per enumerated repo plus
  one toplevel resolution per emitted row; bounded by the registered
  submodule count and emitted only on deviation.
- **Fixture hygiene** — SC-3/SC-4 instruments create and destroy real
  worktrees; each instrument's cleanup steps (remove, prune, branch
  delete, verify) are part of the check, and all instruments run in
  scratch fixture workspaces rather than the live checkout. The probe
  pattern was verified live this session (worktree add → verify →
  directory removal → `prunable` observed → prune → branch delete →
  zero residual registrations).

## Interplay with .opencode#2102

#2102 (open) proposes moving session-init output from stdout to
`{project_root}/tmp/session-context.yaml` (its SC-7). This spec's map
design is mechanism-independent; if #2102 lands first, this spec's
behavioral instruments grep the temp file instead of stdout. No criterion
here depends on stdout specifically.

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored 2026-06-16; AI-revised 2026-10-16 — deck-currency pass (post-rip floor/skills), #2544 conformance, developer directive 2026-10-16 -->

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
