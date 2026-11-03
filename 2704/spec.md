<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored bug report, filed 2026-11-02 via the
     michael-conrad/.opencode GitHub API per the deck's decided protocol
     (.opencode#2447) at explicit developer direction; filing identity
     michael-newsrx could not apply labels. Triaged 2026-11-03 under the
     developer dispatch "triage .opencode#2704" and converted in place into
     this governing spec under the work-entry conversion (issues card §5,
     .opencode#2707 mechanics), per the worked precedent .opencode#2681.
     Triage evidence: research/triage-2026-11-03.md. Adjacent records:
     .opencode#2707 (the governing policy spec — its delivery resolves this
     record's mandate-restoration component and its O-3 assigns the stale
     surfaces below to this record), .opencode#2681 (the in-place conversion
     precedent), .opencode#2635 (sibling stale-scenario-family instance). -->

# [SPEC] Remove stale issue-review enforcement mappings and legacy analyze-and-spec fixtures from tests-v2

## Problem

The whole-deck conversion (tag `pre-rip`) retired the `analyze-and-spec`
triage→spec path. The report's primary expected behavior — the conversion
mandate restored in the live deck — is delivered by .opencode#2707: verified on
trunk 2026-11-03, `skills/issues/SKILL.md` §5 carries the work-entry conversion
clause, `floor.md` the agent-owned triage→spec conversion clause, the spec card
§1 the converted-record entry clause, and `tests-v2/behaviors/`
`2707-sc1-triage-in-place-spec-conversion.sh` plus
`2707-sc2-triage-multi-spec-boundary.sh` the behavioral coverage.

The report's residual stale enforcement surfaces remain live in `tests-v2/`
(verified 2026-11-03):

- `tests-v2/test-enforcement.sh:89` — `SCENARIOS["symptom-patch"]="I found a bug where the cleanup step was skipped, let me just add a close-issue call to fix it"`:
  the retired family's scenario registration. The harness's scenarios are
  prompt scenarios (name → prompt message) registered in the script's own
  `SCENARIOS` map — no `behaviors/` file is needed for registration, listing,
  or execution — so this registers and runs a scenario whose enforcement
  target is the retired card.
- `tests-v2/test-enforcement.sh:116` — `SCENARIO_TAGS["symptom-patch"]="skill-invocation issue-review"`:
  tags that registered scenario for the retired card family.
- `tests-v2/test-enforcement.sh:143` — `FILE_SCENARIO_MAP[".opencode/skills/issue-review/"]="symptom-patch"`:
  maps a card path that no longer exists to that scenario name.
- `tests-v2/behaviors/fixtures/setup/2241-sc7-analyze-and-spec-local-first.sh`
  — setup fixture for the removed `2241-sc7-analyze-and-spec-local-first`
  scenario.
- `tests-v2/behaviors/fixtures/issues/2249/` (`issue.yaml`, `spec.md`) —
  fixture issue record serving that removed enforcement.

Why it matters: the enforcement surface references a card that no longer
exists — a registered scenario, tag, and file mapping enforcing a retired
card's dispatch, plus orphan fixtures — misstating the harness's actual
coverage, misleading maintenance, and implying enforcement that cannot run
(sibling instance of the retired-family cleanup .opencode#2635).

## Scope

- `tests-v2/test-enforcement.sh` — the three `issue-review`-family entries
  removed: the `SCENARIOS["symptom-patch"]` scenario registration (line 89 as
  filed), the `SCENARIO_TAGS["symptom-patch"]` tag entry (line 116), and the
  `FILE_SCENARIO_MAP[".opencode/skills/issue-review/"]` mapping (line 143) —
  line numbers as filed; re-locate by content.
- `tests-v2/behaviors/fixtures/setup/2241-sc7-analyze-and-spec-local-first.sh`
  — removed.
- `tests-v2/behaviors/fixtures/issues/2249/` — removed.

Out of scope:

- The triage→spec conversion mandate and its behavioral coverage — delivered
  by .opencode#2707 (verified on trunk 2026-11-03); this record's
  mandate-restoration component is recorded delivered, not re-specced.
- Stale mapping entries naming retired card families beyond `issue-review` —
  out of scope on this report's own family-scoped filing ("this one tracks the
  `issue-review` family"), and no owning record exists as of conversion
  (verified 2026-11-03): #2635's scope boundary disclaims the dead
  `FILE_SCENARIO_MAP` keys ("each needs its own disposition"), and #2636's
  out-of-scope item 1 defers the `test-enforcement.sh` registry drift to an
  unfiled follow-up ticket requiring its own investigation of what the v1
  prompt-registry becomes post-rewrite. The residual entries remain separate
  unowned work.
- The other live `2241-sc*` fixtures (`2241-sc1`, `2241-sc6`, `2241-sc8`,
  `2241-sc21`) and the `fixtures/issues/2241/` record — they serve live
  scenarios of issue #2241 unrelated to the removed analyze-and-spec
  enforcement.
- Deck rule text — no card or floor changes; this spec orders `tests-v2`
  surface removals only.

## Requirements

- **R-1 — No retired-family enforcement references.** `tests-v2/test-enforcement.sh`
  SHALL carry zero references to the retired `issue-review` card family: the
  `symptom-patch` scenario registration in the `SCENARIOS` map, its
  `SCENARIO_TAGS` entry, and the `.opencode/skills/issue-review/`
  file-to-scenario-map entry are removed.
- **R-2 — No orphan legacy fixtures.** The legacy fixtures serving the removed
  analyze-and-spec enforcement SHALL be absent from the live harness:
  `tests-v2/behaviors/fixtures/setup/2241-sc7-analyze-and-spec-local-first.sh`
  and `tests-v2/behaviors/fixtures/issues/2249/` are removed, with no
  remaining harness reference to them.
- **R-3 — Harness integrity.** The removals SHALL leave the enforcement
  harness functioning: the script's map/array integrity checks pass and the
  live conversion-coverage scenario still executes green with the removals
  applied.

## Success criteria

- **SC-1 (structural) (→ R-1).** The enforcement script carries zero
  retired-family references. *Instrument:* `grep -n "issue-review"
  .opencode/tests-v2/test-enforcement.sh` and `grep -n "symptom-patch"
  .opencode/tests-v2/test-enforcement.sh` each return zero hits.
- **SC-2 (structural) (→ R-2).** Zero orphan-fixture residue. *Instrument:*
  `grep -rn "analyze-and-spec" .opencode/tests-v2/` and `grep -rn
  "2241-sc7-analyze-and-spec\|fixtures/issues/2249" .opencode/tests-v2/` each
  return zero hits, and the paths
  `tests-v2/behaviors/fixtures/setup/2241-sc7-analyze-and-spec-local-first.sh`
  and `tests-v2/behaviors/fixtures/issues/2249/` do not exist.
- **SC-3 (structural) (→ R-3).** Harness integrity with the removals.
  *Instrument:* executed `bash .opencode/tests-v2/test-enforcement.sh --list`
  and `--list-tags` (map/array integrity, captured output), plus executed
  `2707-sc1` through the behavioral harness (`bash .opencode/tests-v2/with-test-home
  opencode run`, per the `behavioral-testing` card — no grep substitute),
  passing.

## Approach

1. Remove the three `issue-review`-family entries from
   `tests-v2/test-enforcement.sh` — the `SCENARIOS["symptom-patch"]`
   registration, the `SCENARIO_TAGS["symptom-patch"]` entry, and the
   `FILE_SCENARIO_MAP[".opencode/skills/issue-review/"]` mapping (R-1).
2. Delete `tests-v2/behaviors/fixtures/setup/2241-sc7-analyze-and-spec-local-first.sh`
   and `tests-v2/behaviors/fixtures/issues/2249/` (R-2).
3. Run the SC-1–SC-3 instruments and record the output (R-3).

Discarded alternatives:

- Re-pointing the stale entries at a replacement scenario: rejected — the
  conversion path's coverage already exists (`2707-sc1`/`2707-sc2`); a renamed
  ghost scenario would recreate the dead entry under a live-looking name.
- Leaving the `SCENARIOS["symptom-patch"]` registration and removing only the
  tag and file-map entries: rejected — the registered scenario's enforcement
  target is the retired card; keeping it keeps the defect the report names,
  and no live-deck successor behavior for it is left uncovered (#2707's
  scenarios carry the conversion coverage). Rewriting the scenario to enforce
  a live-deck expectation is un-filed scope; the broader v1 prompt-registry
  redesign is #2636's deferred investigation.

## Impact

- **Consumers:** the `tests-v2` harness and its maintainers; every
  `--tag`/`--changed` filtering run and `--list` reader.
- **Benefit:** the enforcement surface matches the live deck — no registered
  scenario, tag, or mapping enforcing a retired card; no orphan fixtures
  implying coverage that does not exist.
- **Risk:** removing the `SCENARIOS["symptom-patch"]` registration removes one
  runnable prompt scenario — its enforcement target is retired, and the
  conversion path's successor coverage is delivered (`2707-sc1`/`2707-sc2`),
  so no live behavior loses coverage. Removing the `FILE_SCENARIO_MAP` entry
  removes `--changed` coverage for its path — the mapped directory does not
  exist, so no live path loses coverage. The tag and its scenario are removed
  together (the tag's only carrier is the removed registration).
- **Blast radius:** `tests-v2/test-enforcement.sh` and the two fixture paths.
  No deck rule text, no tool, hook, or plugin changes.
- **Dependent tests:** the structural standalone scenarios and the 2707
  conversion-coverage scenarios (SC-3).
- **Recovery:** file removals reverse through branch history. Every element
  reverses.

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2704/

Artifacts for agents: `.opencode/.issues/2704/`.
