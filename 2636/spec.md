## Summary

Four tier-2 behavioral scenario scripts under `.opencode/tests-v2/behaviors/`
still assert routing to the retired `issue-operations` skill family:

- `issue-ops-core-routing.sh` — routes issue CRUD to `issue-operations-core`
- `issue-ops-comments-routing.sh` — routes comment operations to `issue-operations-comments`
- `issue-ops-sub-issues-routing.sh` — routes sub-issue operations to `issue-operations-sub-issues`
- `issue-ops-sync-routing.sh` — routes sync operations to `issue-operations-sync`

The deck rewrite retired the whole `issue-operations` family to `attic/`
(tag `pre-rip`) along with the monolithic `issue-operations` skill,
`000-critical-rules.md`, and the dispatch-table architecture. The live deck's
`issues` card owns issue routing: local stores through the `local-issues` tool
with qualified `repo#N` names, remote operations through the authenticated
`gh`/`gb` CLIs — "authenticated tools, never raw API scripts."

The harness spec carries the same residue: `tests-v2/AGENTS.md` §Scope Anchor's
R-6 routing directive instructs agents to "route via issue-operations" — a
retired card — for deck defects discovered under a mis-scoped mandate.

Scenarios whose execution targets no longer exist cannot run meaningfully and
mislead clean-room agents reading tests as the source of truth for routing
behavior; a live routing directive naming a dead card misdirects the same
readers. Disposition (decided): delete all four scripts and repair the R-6
directive to name the live routing owner. A replacement live-routing scenario
is out of scope — see Coverage evaluation and Out of scope.

Discovered during the `.opencode#1963` triage (verified-resolved closure,
2026-10-17), which surfaced `issue-ops-core-routing.sh`; the verification sweep
for this spec surfaced the three sibling scripts and the R-6 directive as the
same migration residue.

## Root Cause

The four scripts predate the deck rewrite. When the `issue-operations` family
was retired to `attic/`, its routing scenario family and the harness spec's
routing directive were not migrated or deleted — active drift evidence from
the rewrite's migration sweep.

## Classification

- **Pattern**: stale-reference drift (deck-rewrite migration residue)
- **Substrate**: tier-2 scenario scripts referencing retired artifacts as
  execution targets; a live routing directive in the harness spec naming a
  retired card
- **Risk**: low — the scripts are inert generators against the live deck, but
  they are false signals for test maintenance and clean-room review; the R-6
  directive is a live instruction pointing at a dead card

## Evidence

All facts verified against the live tree, 2026-10-17:

- The four scripts exist under `tests-v2/behaviors/`; each header SC routes its
  operation class to a retired `issue-operations*` sub-skill ("CRUD operations
  ... MUST route to issue-operations-core sub-skill", "Comment operations ...
  MUST route to issue-operations-comments sub-skill", "Sub-issue operations
  ... MUST route to issue-operations-sub-issues sub-skill", "Sync operations
  ... MUST route to issue-operations-sync sub-skill"). All four are
  artifact-only generators (`SCENARIO_TIER="2"`) that do not evaluate model
  output.
- `grep -rln "issue-operations" .opencode/tests-v2/behaviors/` (recursive,
  fixtures included) returns exactly those four scripts — no other test asset
  under `behaviors/` references the family.
- Tree-wide sweep for the family (excluding `attic/`, the `.issues/` store, and
  `.git/` internals): the four scripts, `tests-v2/AGENTS.md` line 15 (R-6
  directive), `README.md` line 96 (skill-index row), and
  `tests-v2/test-enforcement.sh` line 141 (one `FILE_SCENARIO_MAP` entry).
  CHANGELOG mentions are historical record, not live references.
- `tests-v2/test-enforcement.sh` contains no reference to any of the four
  scenario names — no `FILE_SCENARIO_MAP` or registry bookkeeping is tied to
  any of them; deleting them strands nothing.
- Tree-wide sweep for the four scenario names (same exclusions): the scripts
  themselves only — no runner, manifest, or document references any of them.
- `test-isolation.sh` SC-8/SC-9 enumerate `behaviors/*.sh` dynamically —
  deletion requires no list maintenance.
- The live `issues` card routes local stores via `local-issues` (qualified
  `repo#N`) and remote operations via `gh`/`gb` — "authenticated tools, never
  raw API scripts."
- Adjacent live coverage: `needs-approval-local-verification.sh` and
  `needs-approval-remote-verification.sh` probe issue creation end-to-end
  (local store; GitBucket remote with `gb` CLI label verification);
  `2547-sc1-gb-cli-reload-on-class-change.sh` asserts gb-cli card compliance.
  No scenario asserts the routing decision for issue operations against the
  live surface.

## Disposition

Decided:

1. **Delete** the four scenario scripts. A test whose execution target is
   retired cannot catch a live defect — the §6b ceremony-test retirement
   policy's survival condition ("a test survives only if a real defect would
   escape without it") fails trivially for each. No rewrite survives either:
   the scripts' subject matter (sub-skill routing under the retired
   dispatch-table architecture) no longer exists to route to.
2. **Repair** the R-6 routing directive in `tests-v2/AGENTS.md` to name the
   live routing owner — the `issues` card — instead of the retired skill.
3. **No replacement routing scenario in this ticket** — see Coverage
   evaluation.

## Coverage evaluation

Deleting the four scripts removes the suite's only scenario-level assertions
of issue-operations routing. The record:

- **What remains**: issue-creation behavior is probed end-to-end by
  `needs-approval-local-verification.sh` (local store) and
  `needs-approval-remote-verification.sh` (GitBucket remote); gb-cli card
  compliance by `2547-sc1-gb-cli-reload-on-class-change.sh`.
- **The gap**: no scenario asserts the routing decision for issue operations
  (CRUD, comments, sub-issues, sync) against the live surface — `issues` card
  → `local-issues` / `gh` / `gb`.
- **Decision**: no replacement in this ticket. A replacement is new behavioral
  coverage — tier-2 harness work under `tests-v2/AGENTS.md` §3 with its own
  §6b admission-gate justification (the defect it must catch: issue operations
  routed off the live surface) — categorically different work from this
  dead-test cleanup. The gap is recorded here; pursuing it is a separate
  ticket.

## Requirements

- R-1. The four scenario scripts named in the Summary SHALL be deleted from
  `tests-v2/behaviors/`.
- R-2. No file under `tests-v2/behaviors/` SHALL reference the retired
  `issue-operations` skill family (`issue-operations`, `issue-operations-core`,
  `issue-operations-comments`, `issue-operations-sub-issues`,
  `issue-operations-sync`).
- R-3. The R-6 routing directive in `tests-v2/AGENTS.md` SHALL name the live
  routing owner (the `issues` card) instead of the retired `issue-operations`
  skill, and the edited file SHALL pass the reference-integrity check (§6c).

The class-level intent behind R-2 — no scenario targets any `attic/`-retired
artifact as its execution target — is the governing principle; R-2's
mechanical instrument covers the `issue-operations` family because it is the
only retired-name set with no live-deck name collision (see Success criteria).

## Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | The four scripts named in the Summary are absent from `tests-v2/behaviors/`. | structural | File-existence check on the four paths — all absent. |
| SC-2 | No file under `tests-v2/behaviors/` references `issue-operations`, `issue-operations-core`, `issue-operations-comments`, `issue-operations-sub-issues`, or `issue-operations-sync`. | structural | `grep -rn "issue-operations" .opencode/tests-v2/behaviors/` — zero hits. |
| SC-3 | The R-6 routing directive in `tests-v2/AGENTS.md` does not reference `issue-operations` and names the `issues` card as the routing owner. | structural | `grep -n "issue-operations" .opencode/tests-v2/AGENTS.md` — zero hits; the R-6 paragraph names the `issues` card. `./.opencode/tools/reference-integrity .opencode/tests-v2/AGENTS.md` — exit 0. |

All three criteria are structural (repository-content invariants). No
behavioral criterion applies: the change deletes dead scenario artifacts and
repairs one prose directive; nothing new executes.

Name-discrimination note: mechanical name-grepping cannot distinguish retired
card copies from live cards that share names (`gh-cli`, `gb-cli`,
`git-workflow-*` exist in both `attic/skills/` and live `skills/` as rewritten
cards). The `issue-operations` family is the unambiguous retired-name set, so
SC-2's instrument is fully capable for the criterion it states; the broader
class invariant is judged by review, not by this grep.

## Impact

- **Consumers**: the tests-v2 behavioral suite; `test-isolation.sh` structural
  scans (dynamically enumerated — no bookkeeping updates); clean-room agents
  reading `tests-v2/` as routing truth.
- **Blast radius**: four script deletions and one paragraph edit in
  `tests-v2/AGENTS.md`; no production surface.
- **Risk**: low.

## Out of scope

1. `tests-v2/test-enforcement.sh` registry drift — 13 of its 14
   `FILE_SCENARIO_MAP` path keys reference retired deck files (the surviving
   key, `plugins/session-enforcement.ts`, is live), and the v1-era `SCENARIOS`
   tags name retired skills (`brainstorming`, `issue-review`, `git-workflow`),
   leaving `--changed` filtering largely inert. Its disposition requires its
   own investigation of what the v1 prompt-registry becomes post-rewrite;
   follow-up ticket.
2. `README.md` skill-index staleness (line 96 names retired skills alongside
   live ones) — a repo-README refresh is its own item.
3. A replacement live-routing behavioral scenario for issue operations — if
   the coverage gap recorded under Coverage evaluation justifies one, it is a
   separate ticket under the §6b admission gate.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
