## Summary

`tests-v2/behaviors/issue-ops-core-routing.sh` still targets the retired
`issue-operations-core` skill. Line 7's header comment reads:

> # issue-operations-core sub-skill, not the monolithic issue-operations skill.

The deck rewrite retired `issue-operations-core` to `attic/` (tag `pre-rip`) along
with the monolithic issue-operations skill, `000-critical-rules.md`, and the
dispatch-table architecture. The live deck's `issues` card owns issue routing:
local stores through the `local-issues` tool with qualified `repo#N` names, remote
operations through the authenticated `gh`/`gb` CLIs — "never raw API scripts".

The script references architecture that no longer exists — it cannot execute
meaningfully against the live deck and misleads clean-room agents reading tests
for routing expectations.

Discovered during the `.opencode#1963` triage (verified-resolved closure,
2026-10-17): the grep for live-deck references to the retired skill returned this
script as the sole non-attic hit.

## Root Cause

The script predates the deck rewrite. When `issue-operations-core` was retired to
`attic/`, this test scenario was not migrated or deleted — active drift evidence
from the rewrite's migration sweep.

## Classification

- **Pattern**: stale-reference drift (deck-rewrite migration residue)
- **Substrate**: test scenario referencing a retired artifact as its execution target
- **Risk**: low — the script is inert against the live deck, but it is a false
  signal for test maintenance and clean-room review

## Evidence

- `.opencode/tests-v2/behaviors/issue-ops-core-routing.sh` line 7 references
  `issue-operations-core` as the scenario's routing target.
- Grep across the live deck (excluding `attic/`) for `issue-operations-core` and
  `github_list_issues` returns this script as the only hit.
- No live-deck card, guideline, or tool references the retired skill.

## Resolution

Disposition of the script is a spec-phase decision for this ticket — not pre-judged
at filing:

1. **Delete** the script (its scenario target is gone), checking whether any
   routing-coverage loss results; or
2. **Rewrite** the scenario against the live deck: a "list/read issues" request
   matches the `issues` card description ("reading ... any issue"), and the card
   routes remote operations to `gh`/`gb` — asserting that routing surface instead.

Any `test-enforcement.sh` `FILE_SCENARIO_MAP` bookkeeping tied to the script rides
with the disposition. Renumbering conventions (script numbers matching remote issue
numbers) apply if a new scenario replaces it.

## Requirements

- R-1. No scenario under `tests-v2/` SHALL reference `issue-operations-core` or
  any other `attic/`-retired deck artifact as its execution target.
- R-2. Any routing-coverage loss from deletion SHALL be evaluated at spec time
  (whether the live `issues` card routing has behavioral coverage); the
  disposition documents the decision either way.

## Impact

- **Consumers**: the tests-v2 behavioral suite, `test-enforcement.sh` scenario
  bookkeeping, clean-room agents reading tests as the source of truth for routing
  behavior.
- **Blast radius**: one stale test script; no production surface.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
