## Summary

Four routing scenarios under `tests-v2/behaviors/` still target skills the
deck rewrite retired to `attic/` (tag `pre-rip`) — the `issue-operations`
sub-skill family (`issue-operations-core`, `-comments`, `-sub-issues`,
`-sync`). Each script's SC header asserts routing to a named sub-skill
"not the monolithic issue-operations skill" — a distinction that no longer
exists: the live deck's `issues` card owns the entire issue surface,
routing local stores through the `local-issues` tool with qualified
`repo#N` names and remote operations through the authenticated `gh`/`gb`
CLIs. One harness-doc routing directive names the retired mechanism too:
`tests-v2/AGENTS.md`'s R-6 line ("route via issue-operations").

The scripts cannot execute meaningfully against the live deck and mislead
clean-room agents reading tests for routing expectations.

Discovered during the `.opencode#1963` triage (verified-resolved closure,
2026-10-17): a live-deck grep for the retired family returned the routing
scenario family and the R-6 directive line.

## Root Cause

The deck rewrite retired the `issue-operations` skill family to `attic/`
but did not migrate or delete its routing-scenario family or the R-6
routing directive — active drift evidence from the rewrite's migration.

## Classification

- **Pattern**: stale-reference drift (deck-rewrite migration residue) — a
  reference family, not a single file
- **Substrate**: test scenarios and a harness-doc directive referencing
  retired artifacts as execution targets / routing mechanisms
- **Risk**: low — the scripts are inert against the live deck, but they
  are false signals for test maintenance and clean-room review

## Evidence

All facts verified against the working tree, 2026-10-17:

- SC headers naming retired sub-skills, each at lines 6–7 of its script:
  - `issue-ops-core-routing.sh` → `issue-operations-core`
  - `issue-ops-comments-routing.sh` → `issue-operations-comments`
  - `issue-ops-sub-issues-routing.sh` → `issue-operations-sub-issues`
  - `issue-ops-sync-routing.sh` → `issue-operations-sync`
- `tests-v2/AGENTS.md` line 15 (R-6 routing directive) names
  `issue-operations` as the defect-routing mechanism.
- All four sub-skills and the monolithic `issue-operations` skill are
  present under `attic/skills/`; no live card, guideline, or tool
  references them.
- `test-enforcement.sh` carries no `FILE_SCENARIO_MAP` entry for any of
  the four scripts — no bookkeeping rides with their deletion.
- The live `issues` card's description covers all four retired surfaces:
  "creating, reading, updating, commenting on, linking, or closing any
  issue".
- Existing behavioral coverage of issue operations under the live deck
  (incidental, directive prompts): `2561-sc1`, `2561-sc2`, `2547-sc1`,
  `2550-sc4`–`2550-sc7`, `2516-terminal-approval-stage-zero`,
  `2518-verify-bar-invariance`, `record-authorization-workflow`,
  `record-authorization-worktree-commit`,
  `record-authorization-issue-yaml-label`.
- What the family uniquely covers beyond those: undirected prompts — no
  "per your rules" phrasing — probing description-driven routing, i.e.
  whether the card description alone catches a natural issue request.

## Resolution

Consolidate the family to one survivor:

1. **Delete** `issue-ops-comments-routing.sh`,
   `issue-ops-sub-issues-routing.sh`, `issue-ops-sync-routing.sh`. Their
   surfaces collapse into the single live `issues` card and are exercised
   by the listed pipeline scenarios; dedicated probes for the retired
   sub-skill split would test the retired architecture's shape — ceremony
   under the tests-v2 §6b policy.
2. **Rewrite** `issue-ops-core-routing.sh` in place as the family's sole
   survivor:
   - Keep `SCENARIO_PROMPT` verbatim — the undirected create-issue
     request is natural-behavior compliant (§11) and "creating" matches
     the live card description.
   - Rewrite the SC header: an undirected issue-creation request routes
     to the live `issues` card, and issue operations use the sanctioned
     tooling — `local-issues` with qualified `repo#N` names for local
     stores, `gh`/`gb` CLIs for remote operations — never raw API
     scripts.
   - Rename the script free of retired-name residue (the "core" in
     `issue-ops-core-routing` names the retired sub-skill).
   - Evaluation stays with the two-SC pattern (§6a): artifact generation,
     then a clean-room sub-agent reading `session.yaml` for the card load
     and tool routing.
3. **Fix** the `tests-v2/AGENTS.md` R-6 routing directive: "route via
   issue-operations" → "route via the `issues` card".

## Scope boundary

- `tests-v2/behaviors/fixtures/` issue copies are frozen historical
  records — the specs as filed, not execution targets. R-1 does not
  reach them.
- Other residue instances of the same drift class are excluded — e.g.
  the pre-rewrite skill tables in `README.md`, `test-enforcement.sh`'s
  `FILE_SCENARIO_MAP` keys referencing retired guideline/skill paths
  (all dead; each needs a live-equivalent disposition of its own), and
  fixture setup scripts referencing retired skill paths. Each is
  separate work, not silently absorbed here.
- The `vector_db/` retrieval index is a derived artifact, not authored
  deck prose — out of scope.

## Requirements

- R-1. No file under `tests-v2/behaviors/` and no routing directive in
  `tests-v2/AGENTS.md` SHALL reference the retired `issue-operations`
  family — `issue-operations`, `issue-operations-core`,
  `issue-operations-comments`, `issue-operations-sub-issues`,
  `issue-operations-sync` — by name. Instrument: grep of
  `tests-v2/behaviors/*.sh` and `tests-v2/AGENTS.md` for
  `issue-operations` (substring covers all variants); zero hits.
- R-2. The three scripts named in Resolution §1 SHALL be absent from
  `tests-v2/behaviors/`. Instrument: file-absence check.
- R-3. The surviving scenario SHALL carry no retired-name residue in its
  file name, SHALL keep `SCENARIO_PROMPT` verbatim, and SHALL state in
  its SC header the live routing surface — `issues` card load on an
  undirected issue request; sanctioned tooling (`local-issues` with
  qualified names, `gh`/`gb` CLIs); never raw API scripts — with its
  clean-room evaluation pairing per §6a. Instrument: header and content
  inspection against this clause.

## Impact

- **Consumers**: the tests-v2 behavioral suite, clean-room agents reading
  tests as the source of truth for routing behavior.
- **Blast radius**: four scripts and one doc line; no production surface.
  All deletions are git-tracked and recoverable. The survivor's
  `SCENARIO_PROMPT` is unchanged — no other scenario is touched.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
