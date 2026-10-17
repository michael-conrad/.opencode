# Cross-Reference Behavioral Enforcement Tests — #1926

## Problem

The deck's cross-reference convention is the canonical form `Read [Text](path)`
(normatively defined in the `skill-creator` card; used by `implement`,
`programming-principles`, `behavioral-testing`, and others). The form is a load
directive: the referenced content is NOT pre-loaded, and following the link
means calling `read` on the linked path. No verification exists that the agent
actually does so. Structural tooling (`reference-integrity`) only proves links
resolve to real sections — it cannot prove runtime link-following. The failure
mode (#1923's diagnosis) is that the agent treats the link as a decorative
citation, acts on the summary text alone, and never loads the referenced rule.

## Fix

Behavioral enforcement evidence, split across the harness's two evidence modes:

- **Harness run (`opencode run` through tests-v2, tier-2):** produces the raw
  behavioral artifact. A scenario script runs a real model session in the
  isolated test home, where a fixture skill file contains a `Read [Topic](path)`
  link to content that is not pre-loaded, and the scenario prompt poses a task
  whose correct answer requires the linked content.
- **Clean-room sub-agent (tier-1 dispatch, no model run):** produces the
  verdict. A separate evaluator dispatch reads the run's `session.yaml` and
  judges whether the linked content entered the agent's context via a `read`
  call on the linked path.

Scenario authoring follows the `behavioral-testing` card: copy `template.sh`,
`SCENARIO_TIER=tier-2`, the script is an artifact-only generator (runs
`behavior_run`, exits 0, never evaluates output), evaluation uses the
clean-room evaluator per the card's behavioral-evaluation reference, and any
prompt content referencing this issue is seeded via `fixtures/issues/1926/`.
The RED/GREEN state is fixture-controlled (see SC-3) — the tests ship
independently and block nothing.

Model-sensitivity is part of the evidence contract: the verdict is
model-conditional on the harness's single `DEFAULT_TEST_MODEL`. A FAIL indicts
the deck-and-model pair on that model, not the deck alone; model-shopping to
turn a FAIL into a PASS is prohibited (R-20).

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | A tier-2 harness scenario produces a session in which the run agent encounters a `Read [Text](path)` link in a skill file whose target is not pre-loaded, while the prompt requires the linked content to complete the task | `behavioral` | Run `bash .opencode/tests-v2/behaviors/<scenario>.sh` from the project root; artifact set (`session.yaml`, stdout/stderr logs) exists under `./tmp/behavioral-evidence-<scenario>-<phase>-<model>/` |
| SC-2 | In that session, the linked content enters the agent's context via a `read` tool call on the linked path — not via pre-loading, not via a different path, not guessed | `behavioral` | Clean-room sub-agent dispatch (separate from the run) reads only the artifact directory and the SC criterion, reads `session.yaml` as the primary source, returns PASS iff the `read` call on the linked path preceded any use of the linked content |
| SC-3 | The evidence is RED when the link is absent or its target file absent, GREEN when both are present | `behavioral` | Two harness runs from the same scenario: fixture variant with the link/target removed evaluates FAIL; fixture variant with link/target present evaluates PASS. Each run paired with its own clean-room evaluation dispatch |
| SC-4 | The run agent's context contains no pre-loaded copy of the linked content at session start | `behavioral` | The SC-2 clean-room evaluator additionally verifies in `session.yaml` that the linked content's distinctive text appears in context only after the first `read` call on the linked path |

## Affected Files

- `.opencode/tests-v2/behaviors/<scenario>.sh` — new scenario script (artifact-only generator, tier-2)
- `.opencode/tests-v2/behaviors/fixtures/` — fixture skill file carrying the `Read [Text](path)` link, its linked target file, and any issue-referenced prompt content under `fixtures/issues/1926/`

## Interdependency Ordering

- **BLOCKED BY**: Nothing (ships independently; RED state is fixture-controlled)
- **BLOCKS**: Nothing
- **INDEPENDENT OF**: #1923 (band-aid), #1924 (citation rewrites — its plan predates the deck restructuring and targets files that no longer exist), #1925 (linting)

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
