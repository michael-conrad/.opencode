## Intent and Executive Summary

**Problem Statement:** Sub-agents dispatched via `task()` misidentify themselves as orchestrators and execute orchestrator-level routing metadata (SKILL.md Pre-Flight Guard sections, Trigger Dispatch Tables, plan files). The current Pre-Flight Guard is prose-only self-identification ("If you are a sub-agent...") with no mechanical detection signal — a sub-agent has no reliable basis to conclude it is a sub-agent, so it consumes routing metadata it cannot correctly execute (cannot call `task()`), tries to follow the Trigger Dispatch Table or plan phases, and malfunctions.

#### Empirical evidence (session probes, 2026-09-02)

1. Probe task `ses_f9ac0f59bffetMsE6s3sQOHoQ8`: a `general` sub-agent enumerated its actual tool list — 96 tools, **no `task` tool**. The `skill` tool IS present in sub-agent context (so skill-tool presence is not a valid discriminator; task-tool absence is).
2. Probe task `ses_f9ac0429effeFtp1UF2JH91EuF`: a sub-agent given a mechanical guard directive ("check your tool list for a tool named `task`; if absent you are a sub-agent → return BLOCKED") executed the check and correctly returned `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD`, declining to execute the embedded Trigger Dispatch Table.
3. opencode docs (opencode.ai/docs/agents, fetched 2026-09-02): sub-agents are invoked via the Task tool; `permission.task` can be denied per agent — the orchestrator/sub-agent distinction is mechanically observable via the tool list.

**Root Cause / Motivation:** The prose-only guard places the identification burden on the sub-agent's self-model, which fails empirically (probes 1–2 above): a sub-agent that receives a full skill card or plan file has no observable signal distinguishing it from an orchestrator — except its tool list. The root cause is the absence of a mechanically checkable signal in the guard text. It must be solved now because the card deck is actively growing (51 SKILL.md files today, including nested platform cards) and `writing-plans` currently produces plan files with no guard at all — every new card and plan multiplies the unguarded leak surface.

**Approach Chosen:** Define one canonical mechanical Pre-Flight Guard block (single reference definition, below) that checks the tool list for a tool named `task`, then roll out per-item TDD in this order: (1) canonical reference doc + guideline cross-link, (2) lint/audit flagging checks, (3) card sweep across all 51 SKILL.md files, (4) `writing-plans` plan template, (5) behavioral enforcement tests (tests-v2 harness, `opencode run` against real models — not grep).

**Canonical guard (reference definition):**

```markdown
## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with
  `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.
```

Semantic note: content is already in context when the guard runs — the directive governs ACTION ("do NOT execute"), not perception ("do not read").

**Alternatives Considered & Why Discarded:**

1. **Strengthened prose-only guard** — discarded: it relies on the sub-agent's self-model, which already fails empirically (probe 1); prose provides no observable signal, while the tool list is mechanically checkable (probe 2 demonstrated the mechanical form works).
2. **Platform-level `permission.task: deny` backstop in opencode.jsonc** — discarded for this pass (deferred as optional hardening, separate decision): it is a deployment-level backstop tied to agent configuration, not portable card/plan content; it does not make each artifact self-describing.

**Key Design Decisions:**

1. **Mechanical tool-availability check (task-tool presence) as the discriminator** — tradeoff: robust and observable, but it assumes sub-agent contexts never carry `task` (verified by live probe 1); a future platform change to sub-agent tooling would invalidate the signal and require guard re-derivation.
2. **Guard governs ACTION, not perception** — tradeoff: content is already in context when the guard runs ("do not read" is unenforceable); the directive accepts that reading happened and forbids execution.
3. **Two reason codes** — `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) vs `ORCHESTRATOR_ONLY_PLAN` (plans) — tradeoff: precise lint/audit/test assertions per artifact class, at the cost of maintaining two canonical strings.
4. **Guard is strictly additive** — no changes to dispatch strings, Trigger Dispatch Tables, or result contracts — tradeoff: minimal blast radius on the existing pipeline; the guard inserts a check before routing metadata is consumed rather than restructuring it.
5. **Nested platform cards included in the sweep** — the 3 nested cards under `.opencode/skills/issue-operations/platforms/` are dispatched the same way via `task()`; excluding them would leave a live leak path. Tradeoff: 3 additional files in the sweep vs. an unguarded dispatch surface.

**User Intent / Original Prompt:** Orchestrator-level directive: define a mechanical Pre-Flight Guard (task-tool probe) and embed it in every skill card and every plan file, with deck-lint and plan-audit flagging plus behavioral enforcement tests in the tests-v2 harness. This revision was directed by validation FAIL findings from the spec-creation validation session `ses_f9ab4673dffeysQDNnVK22J0Th`.

## Change Requested

1. **Canonical mechanical Pre-Flight Guard** — define a canonical guard block (single reference definition) using a mechanical tool-availability check — realized as the canonical guard (reference definition) in the Intent preamble above.
2. **Replace the prose guard in all skill cards** with the canonical mechanical guard (reason code `ORCHESTRATOR_ONLY_SKILL_CARD`). `skill-creator` validation must verify every card embeds the canonical guard verbatim — realized as R-1, R-2 (Item 1).
3. **Embed the guard in every plan file produced by `writing-plans`** (reason code `ORCHESTRATOR_ONLY_PLAN`) — plans are orchestrator-only documents; `executing-plans` reads them at orchestrator level and dispatches phases via `task()` — realized as R-3 (Item 2).
4. **Lint/audit flagging**: deck lint (`skildeck-lint` / `validate_skill_cards.py`) SHALL flag any SKILL.md missing the canonical guard or carrying a deviant (non-mechanical) guard; the `audit` skill plan-fidelity path SHALL flag any plan missing the guard as a FAIL finding — realized as R-4 (Items 6–7).
5. **Behavioral enforcement tests** (tests-v2 harness, `opencode run` against real models — not grep):
   - Guard fires on card leak → `BLOCKED` + `ORCHESTRATOR_ONLY_SKILL_CARD`, no dispatch attempt
   - Guard fires on plan leak → `BLOCKED` + `ORCHESTRATOR_ONLY_PLAN`, no phase execution
   - No false halt: orchestrator session loads a card and proceeds normally
   - `writing-plans` create produces a plan containing the canonical guard
   - Deck lint + plan audit flag a fixture missing the guard

   Realized as R-5 (Items 3–7).

## Not Included

- **Platform-level `permission.task: deny` backstop in opencode.jsonc** — optional hardening, separate decision; a deployment-level backstop, not content embedded in the artifacts themselves.
- **Root-repo (snea-phonetics) files** — this spec covers the `.opencode` repo only.
- **Dispatch strings, Trigger Dispatch Tables, result contracts** — non-goals; the guard is additive and MUST NOT restructure existing routing.

## Affected Files

- All 48 top-level `.opencode/skills/*/SKILL.md` (guard replacement)
- 3 nested platform cards — `.opencode/skills/issue-operations/platforms/github-mcp/SKILL.md`, `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md`, `.opencode/skills/issue-operations/platforms/local/SKILL.md` (guard replacement; included in the sweep because they are dispatched the same way via `task()`)
- Total: 51 SKILL.md files
- `.opencode/skills/writing-plans/` (plan template + create/revise tasks)
- `.opencode/skills/skill-creator/` (validation step)
- `.opencode/skills/audit/` (plan-fidelity check)
- `.opencode/tools/skildeck*` / validation scripts (lint check)
- `.opencode/guidelines/` (canonical guard reference + cross-link)
- `.opencode/tests-v2/behaviors/` (new enforcement tests)
- `.opencode/tools/local-issues` — separate defect discovered during this session (NOT part of this spec): `PROJECT_DIR` hardcoding + cwd-ignoring create + `.gitmodules`-only child discovery route `.opencode` issues to the root worktree. Filed for separate triage.

## Success Criteria

| SC | Criterion | Evidence Type | Verification Method |
|----|-----------|--------------|---------------------|
| SC-1 | Every SKILL.md — 48 top-level cards plus 3 nested platform cards (`issue-operations/platforms/{github-mcp,gitbucket-api,local}/SKILL.md`), 51 total — embeds the canonical mechanical guard verbatim; deck lint reports zero cards missing/deviant | string | Run deck lint (`skildeck-lint` / `validate_skill_cards.py`) guard-verbatim pattern check across all 51 SKILL.md files; inspect lint output |
| SC-2 | Every plan produced by `writing-plans` embeds the canonical guard with `ORCHESTRATOR_ONLY_PLAN` | behavioral | tests-v2 behavioral scenario: run `writing-plans` create on a test spec via `opencode run`; assert the emitted plan contains the canonical guard |
| SC-3 | Sub-agent receiving a full skill card returns `BLOCKED` + `ORCHESTRATOR_ONLY_SKILL_CARD` without executing routing instructions | behavioral | tests-v2 behavioral scenario: dispatch a sub-agent with a full card via `opencode run`; assert `BLOCKED` + reason code in stderr, no dispatch attempt |
| SC-4 | Sub-agent receiving a plan file returns `BLOCKED` + `ORCHESTRATOR_ONLY_PLAN` without executing plan phases | behavioral | tests-v2 behavioral scenario: dispatch a sub-agent with a plan file via `opencode run`; assert `BLOCKED` + reason code, no phase execution |
| SC-5 | Orchestrator loading a card proceeds normally (no false halt) — observable pass condition: the orchestrator session reaches Trigger Dispatch Table use and emits no `BLOCKED` output | behavioral | tests-v2 behavioral scenario: orchestrator session loads a guarded card via `opencode run`; assert progression to TDT use and absence of `BLOCKED` |
| SC-6a | Deck lint flags a fixture card missing the guard | structural | Run deck lint against the fixture card missing the guard; record the flagged verdict |
| SC-6b | Plan audit (`audit` skill plan-fidelity path) flags a fixture plan missing the guard | behavioral | tests-v2 behavioral scenario: run the plan-fidelity audit against the fixture plan via `opencode run`; assert a FAIL finding naming the missing guard |

## Requirements

R-1. Every skill card SHALL embed the canonical mechanical Pre-Flight Guard verbatim: all 48 top-level `.opencode/skills/*/SKILL.md` files and all 3 nested platform cards under `.opencode/skills/issue-operations/platforms/` (51 SKILL.md files total). No card SHALL carry a deviant (non-mechanical or prose-only) guard variant.

R-2. The canonical guard SHALL be defined exactly once as a single reference definition in a canonical reference document under `.opencode/guidelines/`, with a guideline cross-link to it. The `skill-creator` validation step SHALL verify that every card embeds the canonical guard verbatim.

R-3. Every plan file produced by `writing-plans` SHALL embed the canonical guard with reason code `ORCHESTRATOR_ONLY_PLAN` — plans are orchestrator-only documents; `executing-plans` reads them at orchestrator level and dispatches phases via `task()`.

R-4. Deck lint (`skildeck-lint` / `validate_skill_cards.py`) SHALL flag any SKILL.md missing the canonical guard or carrying a deviant (non-mechanical) guard. The `audit` skill plan-fidelity path SHALL flag any plan missing the guard as a FAIL finding.

R-5. Behavioral enforcement tests SHALL exist in the tests-v2 harness (`opencode run` against real models — not grep) covering: the guard fires on card leak; the guard fires on plan leak; no false halt when an orchestrator loads a card; `writing-plans` create produces a guarded plan; deck lint + plan audit flag a fixture missing the guard.

## Items

### Item 1 (SC-1): Card sweep — canonical guard embedded in all 51 cards

- RED: deck-lint guard-verbatim check over all 51 SKILL.md files reports cards missing/deviant guard
- GREEN: replace the prose guard with the canonical mechanical guard in all 48 top-level cards and the 3 nested platform cards
- verify: deck lint reports zero cards missing/deviant
- commit: the 51-file card sweep as one atomic commit

### Item 2 (SC-2): `writing-plans` plan template embeds the guard

- RED: behavioral test asserting that a produced plan contains the canonical guard fails
- GREEN: update the `writing-plans` plan template and create/revise tasks to emit the guard with `ORCHESTRATOR_ONLY_PLAN`
- verify: behavioral create-run emits a guarded plan
- commit: template change together with its behavioral test

### Item 3 (SC-3): Card-leak behavioral test

- RED: a sub-agent given a full card executes routing instructions without returning `BLOCKED`
- GREEN: guard embedded via Item 1 fires; test asserts `BLOCKED` + `ORCHESTRATOR_ONLY_SKILL_CARD`, no dispatch attempt
- verify: `opencode run` against a real model shows `BLOCKED` in stderr
- commit: the behavioral scenario file

### Item 4 (SC-4): Plan-leak behavioral test

- RED: a sub-agent given a plan file executes plan phases without returning `BLOCKED`
- GREEN: guard embedded via Item 2 fires; test asserts `BLOCKED` + `ORCHESTRATOR_ONLY_PLAN`, no phase execution
- verify: `opencode run` against a real model shows `BLOCKED` in stderr
- commit: the behavioral scenario file

### Item 5 (SC-5): No-false-halt behavioral test

- RED: an orchestrator session loading a guarded card halts with `BLOCKED` (false positive)
- GREEN: orchestrator path (tool named `task` present) proceeds to Trigger Dispatch Table use; test asserts progression without any `BLOCKED` output
- verify: `opencode run` orchestrator session reaches TDT use, emits no `BLOCKED`
- commit: the behavioral scenario file

### Item 6 (SC-6a): Deck-lint fixture flagging

- RED: deck lint run against a fixture card missing the guard reports no flag
- GREEN: lint rule flags cards missing the canonical guard or carrying a deviant guard; fixture run reports the flag
- verify: structural — flagged verdict recorded for the fixture
- commit: lint rule + fixture together

### Item 7 (SC-6b): Plan-audit fixture flagging

- RED: plan-fidelity audit run against a fixture plan missing the guard reports no finding
- GREEN: `audit` plan-fidelity path flags the missing guard as a FAIL finding
- verify: behavioral — `opencode run` produces the FAIL finding
- commit: audit check + fixture together

## Dependencies

| Reference | Relationship | Status |
|-----------|-------------|--------|
| `.opencode/tools/skildeck*` / `validate_skill_cards.py` | deck-lint tooling must carry the guard rule for SC-1/SC-6a verification | satisfied (tooling exists; rule to be added) |
| tests-v2 behavioral harness (`opencode run`) | SC-2, SC-3, SC-4, SC-5, SC-6b require real-model behavioral execution | satisfied |
| `skill-creator` validation step | must verify guard verbatim in every card (R-2) | satisfied (skill exists; check to be added) |
| `audit` skill plan-fidelity path | flagging target for SC-6b | satisfied |
| `writing-plans` create/revise tasks | template surface for SC-2 | satisfied |
| `.opencode/guidelines/` structure | hosts the single canonical guard reference (R-2) | satisfied |

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1, SC-6a | Phase 1 (guard definition), Phase 3 (card sweep) |
| R-2 | SC-1, SC-2, SC-3, SC-5 | Phase 1, Phase 3, Phase 4 |
| R-3 | SC-2, SC-4, SC-6b | Phase 4 |
| R-4 | SC-6a, SC-6b | Phase 2 |
| R-5 | SC-3, SC-4, SC-5, SC-6b | Phase 5 |

Phases follow the rollout order in Approach Chosen: Phase 1 = canonical reference doc + guideline cross-link; Phase 2 = lint/audit flagging checks; Phase 3 = card sweep; Phase 4 = `writing-plans` template; Phase 5 = behavioral enforcement tests.

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| Sub-agent tool-list probe (session `ses_f9ac0f59bffetMsE6s3sQOHoQ8`) | API | opencode `general` sub-agent session — 96 tools, no `task`; `skill` present | live session probe, 2026-09-02 |
| Mechanical-guard directive probe (session `ses_f9ac0429effeFtp1UF2JH91EuF`) | API | opencode sub-agent session — `BLOCKED` + `ORCHESTRATOR_ONLY_SKILL_CARD` | live session probe, 2026-09-02 |
| opencode agents documentation | doc | https://opencode.ai/docs/agents | fetched 2026-09-02 (Task tool invocation; `permission.task` per-agent deny) |
| Spec structure standards | doc | `.opencode/reference/spec-structure-standards.md` | read this session |
| Cost model standards | doc | `.opencode/reference/cost-model-standards.md` | read this session |
| Validation session `ses_f9ab4673dffeysQDNnVK22J0Th` | API | spec-creation validation verdicts (source of revision findings) | live validation session, 2026-09-02 |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Running deck lint across 51 cards costs seconds — a bounded check that catches any card shipping without the guard. Skipping costs weeks — an unguarded card leaks into sub-agent dispatch and the malfunction surfaces only when a session is diagnosed, far from introduction.
- **SC-2:** Running the `writing-plans` create behavioral check costs minutes. Skipping costs the lifetime of plan production — every future plan ships unguarded, and each becomes a fresh leak discovered only at execution malfunction.
- **SC-3:** Running the card-leak behavioral test costs minutes of model execution. Skipping costs 100×–1000× discovery latency — the exact routing-metadata misexecution this spec exists to prevent ships silently.
- **SC-4:** Running the plan-leak behavioral test costs minutes. Skipping costs compounding rework — unguarded plans pass review and malfunction at phase-execution time.
- **SC-5:** Running the no-false-halt test costs minutes. Skipping costs pipeline stalls — a false halt blocks every orchestrator dispatch and surfaces as mysterious workflow deadlocks.
- **SC-6a:** Running deck lint against the guard fixture costs seconds. Skipping costs the flagging check itself going unverified — a silent no-op lint discovered only when the first deviant card ships unflagged.
- **SC-6b:** Running the plan-audit fixture check costs minutes. Skipping costs a silent no-op audit path — unguarded plans pass review unflagged until a leak malfunctions downstream.

## Edge Cases

- **Input boundaries:** Card with the guard placed after other sections; minimal plan with no phase content. Condition: artifact structure varies. Expected behavior: guard presence is what lint verifies (content-based, position-independent pattern check); a fixture missing the guard MUST be flagged, never silently passed. Resolution: the lint pattern check is content-based, not position-based.
- **State transitions:** Sub-agent encountering the guard mid-execution. Condition: routing metadata is already in context when the guard runs. Expected behavior: the guard governs ACTION ("do NOT execute"), not perception ("do not read"). Resolution: behavioral halt with the artifact-class reason code.
- **Failure modes:** (1) Skill tool present in sub-agent context — condition: a sub-agent reasons "I have `skill`, so I am an orchestrator"; expected behavior: the guard keys on `task` absence only; resolution: canonical text names `task` as the sole discriminator (probe 1 evidence). (2) Deck lint or audit tooling unavailable — condition: the lint/audit command cannot run; expected behavior: hard FAIL, never a silent PASS; resolution: `BLOCKED` with a tool-missing reason.
- **Concurrency:** Parallel card edits during the sweep; sub-agent dispatches during rollout. Condition: multiple agents touching SKILL.md files while cards remain in active dispatch. Expected behavior: guard replacement is additive and mechanical, so concurrent dispatches are unaffected; resolution: per-item TDD commits keep each sweep slice atomic.
- **Recovery:** False halt (orchestrator misreads itself as a sub-agent). Condition: the SC-5 scenario. Expected behavior: orchestrator proceeds to Trigger Dispatch Table use; resolution: the no-false-halt behavioral test is the recovery gate for any guard regression that over-fires.

## Change Control

- 2026-09-02: Revised per validation FAIL findings (spec-creation validation session `ses_f9ab4673dffeysQDNnVK22J0Th`), authorized by the spec-creation validation gate (`revision_reason: validation FAIL findings`). Changes: (1) corrected the card count from 50 to 48 top-level + 3 nested platform cards = 51 and made nested-card scope explicit; (2) decomposed SC-6 into SC-6a (structural) and SC-6b (behavioral); (3) re-declared SC-1 evidence type as `string` and added the Verification Method column; (4) added the required sections per `reference/spec-structure-standards.md` (6-field Intent preamble, Not Included, Requirements, Items, Dependencies, Traceability, Documentation Sources, Enforcement Gate, Cost Frame, Edge Cases); (5) operationalized the SC-5 observable pass condition. All substantive content from the prior body (problem statement, probes, canonical guard text, change requests 1–5, scope/non-goals, affected files, local-issues defect note) is preserved.

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
