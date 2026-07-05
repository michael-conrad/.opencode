> **Full spec and plan artifacts:** https://github.com/michael-conrad/.opencode/tree/issues-data/1673/

## Problem

The spec-creation and writing-plans skills have structural defects that prevent them from being invoked correctly. Two failure modes: (1) dispatch bypass — phrases like "create a spec" don't trigger the skill, agent inlines the work; (2) remote body format — full spec content dumped into issue body instead of condensed exec summary.

## Scope

- Trigger phrase expansion (article variants) for both skill cards
- Dispatch table fixes for spec-creation SKILL.md
- write.md structural renumbering (content templates → sub-bullets, 7r ordering, duplicate labels)
- writing-plans execution model contradiction (SKILL.md says "no task()" but create.md dispatches sub-agents)
- Missing pipeline steps (adversarial-audit dispatch, orphan task files)
- Behavioral enforcement tests

## Approach

Five phases: (1) trigger phrase expansion, (2) dispatch table fixes, (3) write.md renumbering, (4) writing-plans execution model fix, (5) missing pipeline steps. Phases 1-2 independent; 3-5 depend on 2.

## Impact

- 16 success criteria across 5 phases
- Behavioral tests for trigger dispatch and sub-agent dispatch model
- Coordinate with #1407 (routing-only SKILL.md) and #1208 (dispatch table overhaul)
- No impact on existing specs/plans
