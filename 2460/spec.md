> **Full spec and artifacts: [`.opencode/.issues/2460/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2460/)** — authoritative spec, `issues-data` branch.
>
> **Remote issue:** https://github.com/michael-conrad/.opencode/issues/2460

# Spec: Rewrite playwright-cli description as agent-intent semantic router

## Intent and Executive Summary

**Problem Statement.** The `playwright-cli` skill description (SKILL.md frontmatter `description` field) uses the deprecated meta-instruction format — `Load via skill() when`, `Also load when`, and `User phrases:` — that [skill-card-description-standards.md](../../reference/skill-card-description-standards.md) prohibits and `validate_skill_cards.py` (REQ-1, SC-LINT-001) flags. Because the description is the sole Level-1 dispatch signal, the defect is behavioral: the description offers user-utterance phrases instead of stating the agent-intent capability class, so browser-appropriate capture intents (JavaScript-rendered pages, bot-blocked sites, login-gated pages) do not activate the skill.

**Root Cause / Motivation.** The description predates the enforced deck standard and was never migrated. The stale open ticket #1520 quotes pre-#1855 text and proposes a no-op, so it cannot fix the defect and is superseded by this spec. This is the scoped first entry of the deck-wide description-compliance wave tracked by umbrella #1384.

**Approach Chosen.** Replace the description with the approved 665-char agent-intent draft stating the escalation capability class (browser-grade rendering vs static HTTP fetching; JS-rendered, bot-blocked, login-gated, interactive verification flows), and extend the Browse-the-web workflow When clause with the same escalation intent family so body-level routing agrees with the description. Verify with a grep-based content test (SC-1..SC-7) and with behavioral probes + clean-room session.yaml evaluations (SC-8..SC-11) scoped to the dispatch decision.

**Alternatives Considered & Why Discarded.**

- **Fix all 50 non-compliant cards in one spec** — discarded: violates the approved scope ruling (developer directive recorded in the brainstorming handoff); deck-wide remediation remains the #1384 umbrella wave.
- **Patch #1520 instead of superseding it** — discarded: #1520 quotes pre-#1855 description text, so implementing its proposal is a no-op against the current defect.
- **Change `validate_skill_cards.py` to also ban `Also load when`** — discarded: validator changes are out of the blast radius per the approved design; SC-1's stricter rule is enforced by the new content test.

**Key Design Decisions.**

- **Description as classifier boundary:** the draft states the escalation capability class rather than trigger phrases — tradeoff: slightly shorter description (665 chars vs the current 739 — a 74-char reduction; pre-change frontmatter measured live: 739 chars with spaces, 644 without) in exchange for intent-based activation on browser-appropriate tasks and no false activation on static fetches (enforced by SC-10/SC-11).
- **When-clause extension without dispatch-contract change:** the Browse-the-web When clause gains escalation-family coverage while the `task()` prompt strings stay byte-identical — tradeoff: body text and description must be kept consistent manually (SC-6 asserts it).
- **Behavioral scope = dispatch decision, not execution:** execution binaries (`playwright-cli`, `npx`) are absent in this environment, so behavioral evidence covers the skill-load event, not end-to-end page capture — tradeoff: weaker end-to-end guarantee now, in exchange for a testable dispatch gate; binary provisioning is a recorded non-goal and future spec.
- **Negative control as a full SC:** no optional SCs — the false-activation boundary is a first-class success criterion (developer ruling).
- **Two-SC pattern for behavioral tests:** artifact generation (probe runs) strictly separated from clean-room evaluation; evaluations read exported session.yaml only — never stdout/stderr prose.

**User Intent / Original Prompt.** Developer directive: rewrite the playwright-cli description as an agent-intent semantic router per the approved brainstorming design (handoff: `.opencode/.issues/2460/artifacts/preliminary/handoff.yaml`), with behavioral verification of the dispatch decision, negative control included as a full SC, and early test-session termination permitted once evidence of correct operation is confirmed in the live session DB (directive dated 2026-09-23).

## Not Included

- **Deck-wide description compliance (other non-compliant cards)** — umbrella #1384 wave; this spec resolves only the playwright-cli entry per the developer scope ruling.
- **Escalation wiring in research/verification/audit/mcp-tool-usage pipelines** — those pipelines referencing the browser tier is a separate integration concern, descoped.
- **Environment provisioning of the playwright-cli binary / node toolchain** — behavioral SCs are scoped to the dispatch decision; binary provisioning is a future spec.
- **#1959 task-card reconciliation with upstream** — adjacent ticket, explicitly not superseded, state unchanged.
- **`validate_skill_cards.py` changes** — the existing validator already prohibits the removed patterns; no validator edit is in the blast radius.
- **Guidelines/reference-document changes** — [skill-card-description-standards.md](../../reference/skill-card-description-standards.md) and [skill-card-schema.md](../../reference/skill-card-schema.md) already codify the target format.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The `playwright-cli` description contains zero prohibited meta-instruction patterns — all 8 SC-LINT-001 patterns plus `Also load when` (stricter than the validator). | string | New content-verification test greps the description frontmatter for each of the 9 patterns and asserts absence. | [skill-card-description-standards.md](../../reference/skill-card-description-standards.md); `validate_skill_cards.py` SC-LINT-001 list (read live) |
| SC-2 | `validate_skill_cards.py` REQ-1/SC-LINT-001 reports a clean verdict for playwright-cli. | string | Validator run against the post-change SKILL.md confirms a clean verdict, recorded by the content test. | `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` (live run) |
| SC-3 | The description states the escalation capability class per the approved draft: browser-grade rendering vs static HTTP fetching; JavaScript-rendered, bot-blocked, login-gated, and interactive verification flows. | string | Content test asserts presence of the capability-class phrases derived from approved draft sentence 2. | Approved draft in handoff.yaml `approved_design.description_draft`; [skill-card-description-standards.md](../../reference/skill-card-description-standards.md) |
| SC-4 | The description length is within the 1–1024 char frontmatter schema limit. | structural | Structural test enforces the length bound from the schema against the post-change description. | [skill-card-schema.md](../../reference/skill-card-schema.md); live frontmatter read |
| SC-5 | `name`, `license`, `compatibility`, `allowed-tools`, `upstream`, `upstream_license` are byte-identical to the pre-change snapshot. | structural | Structural test diffs the 6 frontmatter fields against the pre-change snapshot. | [skill-card-schema.md](../../reference/skill-card-schema.md); live frontmatter read |
| SC-6 | The Browse-the-web workflow When clause covers the escalation intent family (static HTTP fetching returns empty, incomplete, or JavaScript-dependent). | string | Content test asserts escalation-family phrases in the When clause. | Live SKILL.md read (Browse-the-web workflow); approved 189-char extension in handoff.yaml |
| SC-7 | The Browse-the-web workflow dispatch contract strings are unchanged (byte-identical to the pre-change snapshot). | string | Content test asserts byte-equality of the dispatch prompt strings vs the pre-change snapshot. | Live SKILL.md read (Browse-the-web workflow); pre-change snapshot |
| SC-8 | Behavioral positive probe: an agent given a browser-appropriate capture task (JS-rendered/bot-blocked page fetch) dispatches the playwright-cli skill — RED under the old description (no dispatch), GREEN under the new description (dispatch); artifact-only generator per the tests-v2 two-SC pattern. | behavioral | `with-test-home opencode run` probe; session.yaml export; artifact-only generator script in tests-v2/behaviors/. | tests-v2/AGENTS.md harness mandates; behavior_run() pre-flight gate |
| SC-9 | Clean-room evaluation of the SC-8 session.yaml confirms the skill-dispatch event in the event table; early termination is permitted once dispatch evidence is confirmed in the live session DB (developer directive 2026-09-23). | behavioral | Clean-room evaluation sub-agent reads the exported session.yaml event table and returns a verdict. | tests-v2/AGENTS.md §6a two-SC pattern; test-cleanroom-eval-contract precedent |
| SC-10 | Negative control: an agent performing a routine static-fetch task does not dispatch playwright-cli (false-activation boundary); artifact-only generator. | behavioral | `with-test-home opencode run` probe with a no-browser-need prompt; session.yaml export; generator script in tests-v2/behaviors/. | tests-v2/AGENTS.md harness mandates; research-card classifier-boundary principle |
| SC-11 | Clean-room evaluation of the SC-10 session.yaml confirms absence of any playwright-cli dispatch event. | behavioral | Clean-room evaluation sub-agent reads the exported session.yaml event table; absence assertion over the event table. | tests-v2/AGENTS.md §6a two-SC pattern; test-integrity mandate |

## Requirements

- R-1. The `playwright-cli` description SHALL be replaced with the approved agent-intent draft stating the escalation capability class (browser-grade rendering that static HTTP fetching cannot provide: JavaScript-rendered SPAs, bot-blocked sites, login-gated pages, interactive verification flows).
- R-2. The description SHALL contain zero prohibited meta-instruction patterns: the 8 SC-LINT-001 patterns plus `Also load when`.
- R-3. The description SHALL remain within the frontmatter schema limit (1–1024 chars), and all other frontmatter fields SHALL remain byte-identical to the pre-change snapshot.
- R-4. The Browse-the-web workflow When clause SHALL cover the escalation intent family (static HTTP fetching returns empty, incomplete, or JavaScript-dependent), and the workflow dispatch contract strings SHALL remain unchanged.
- R-5. A content-verification test SHALL enforce SC-1..SC-7 statically (grep/schema assertions, no model).
- R-6. A behavioral positive probe SHALL demonstrate that a browser-appropriate capture task dispatches playwright-cli under the new description and does not under the old description (RED before GREEN).
- R-7. A clean-room evaluation SHALL derive the SC-8 verdict from the exported session.yaml event table only, with early termination permitted once dispatch evidence is confirmed in the live session DB.
- R-8. A behavioral negative control SHALL demonstrate that a routine static-fetch task does not dispatch playwright-cli under the new description.
- R-9. A clean-room evaluation SHALL derive the SC-10 verdict from the exported session.yaml event table only, asserting absence of the dispatch event.
- R-10. New test scripts SHALL follow tests-v2 conventions: content tests named per the content-test convention, behavioral generators in tests-v2/behaviors/, no GNU timeout, bash-tool timeout >= 600s, `with-test-home` wrapper, default test model (no substitution), and the ordered commit → push → fresh-fetch → verify cycle before every behavioral run.
- R-11. On new-spec approval, #1520 SHALL be closed as superseded with a cross-link comment, and the playwright-cli entry of umbrella #1384 SHALL be resolved (umbrella stays open); #1959 SHALL remain untouched.

> R-11 is a pipeline-state action (issue-operations at spec approval / PR time), not an implementation item — it has no SC and no TDD item; recorded here for traceability of the supersession decision.

## Items

One item per SC, each with its own RED/GREEN/verify/commit cycle (per-SC decomposition; dependency DAG acyclic: 1→2, 1→3, 1→4, 1→5, 1→8, 2→8, 3→8, 4→8, 5→8, 8→9, 1→10, 2→10, 3→10, 4→10, 5→10, 10→11).

### Item 1 (SC-1): Description with zero prohibited patterns

- RED: pattern-absence grep fails against the current description (3 deprecated patterns present).
- GREEN: apply the approved 665-char draft — zero of the 9 patterns remain.
- verify: run the content test (all 9 patterns asserted absent).
- commit: SKILL.md description + pattern-absence assertions in one slice.

### Item 2 (SC-2): Validator REQ-1/SC-LINT-001 clean

- RED: validator run against the current description flags REQ-1/SC-LINT-001.
- GREEN: validator run against the post-Item-1 description reports a clean verdict.
- verify: validator verdict recorded clean.
- commit: validator-clean assertion wired into the content test.

### Item 3 (SC-3): Escalation capability class stated in description

- RED: capability-class assertion fails against the pre-change description snapshot (escalation class absent).
- GREEN: assertion passes against the post-Item-1 description (phrases derived from approved draft sentence 2).
- verify: run the capability-class assertions.
- commit: assertion addition to the content test.

### Item 4 (SC-4): Description length within schema limit

- RED: length-bound check fails against a deliberately overlong fixture (test validates its own sensitivity).
- GREEN: check passes against the post-change description — within the 1–1024 char schema limit.
- verify: run the length-bound check.
- commit: length-bound test addition.

### Item 5 (SC-5): Frontmatter fields byte-identical to snapshot

- RED: field-diff check fails against a deliberately mutated fixture (test validates its own sensitivity).
- GREEN: check passes against the post-change frontmatter — all 6 fields byte-identical to the pre-change snapshot.
- verify: run the field-diff test.
- commit: field-diff test addition.

### Item 6 (SC-6): Browse-the-web When clause covers escalation intent family

- RED: escalation-family assertion fails against the current When clause (no escalation coverage).
- GREEN: apply the approved 189-char extension — assertion passes.
- verify: run the When-clause assertions.
- commit: SKILL.md When-clause extension + assertions.

### Item 7 (SC-7): Dispatch contract strings unchanged

- RED: byte-equality check fails against a deliberately mutated fixture (altered dispatch string).
- GREEN: dispatch prompt strings byte-identical to the pre-change snapshot.
- verify: run the dispatch-string byte-equality check.
- commit: byte-equality assertion addition.

### Item 8 (SC-8): Behavioral positive probe — dispatch on browser-appropriate task

- RED: probe run under the OLD description (pre-fix effective remote state) shows NO playwright-cli dispatch.
- GREEN: probe run under the NEW description shows the dispatch event; artifact-only generator committed.
- verify: session.yaml export produced per the two-SC pattern.
- commit: generator script in tests-v2/behaviors/.
- Ordering constraint: the RED run requires the pre-fix effective remote state (old description on remote main) — sequencing owned by writing-plans.

### Item 9 (SC-9): Clean-room evaluation of positive-probe session.yaml

- RED: evaluation of the RED-run session.yaml reports dispatch absence.
- GREEN: evaluation of the GREEN-run session.yaml reports dispatch presence in the event table.
- verify: clean-room evaluation verdict recorded; evaluation reads session.yaml only.
- commit: evaluation artifact.

### Item 10 (SC-10): Behavioral negative control — no false activation on static fetch

- RED: boundary demonstrated by a test-sensitivity check (fixture assertion).
- GREEN: probe run under the NEW description with a routine static-fetch prompt shows no playwright-cli dispatch.
- verify: session.yaml export produced.
- commit: generator script in tests-v2/behaviors/.

### Item 11 (SC-11): Clean-room evaluation of negative-control session.yaml

- RED: sensitivity check — evaluation reports presence when a dispatch event is injected into a fixture.
- GREEN: evaluation of the Item-10 session.yaml confirms absence of any dispatch event.
- verify: clean-room evaluation verdict recorded; absence assertion never loosened (test-integrity mandate).
- commit: evaluation artifact.

Non-item pipeline action (not an implementation item): supersede #1520 and resolve the #1384 playwright-cli entry via issue-operations at spec approval / PR time.

## Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| [skill-card-description-standards.md](../../reference/skill-card-description-standards.md) | Codifies the target description format (agent-intent, no meta-instruction patterns) — read before implementation | Satisfied |
| [skill-card-schema.md](../../reference/skill-card-schema.md) | Codifies frontmatter binary constraints (description 1–1024 chars) — read before implementation | Satisfied |
| `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` | Existing validator (REQ-1, SC-LINT-001) used as a verification instrument; no change | Satisfied |
| tests-v2/AGENTS.md | Harness mandates governing the behavioral items (timeout, wrapper, two-SC pattern, ordered cycle) | Satisfied |
| #1520 | Superseded by this spec — close as superseded with cross-link comment on new-spec approval | Pending (pipeline state) |
| #1384 | Umbrella wave — the playwright-cli entry resolves when this spec lands; umbrella stays open | Pending (pipeline state) |
| #1959 | Adjacent reconciliation — explicitly out of scope, not superseded, state unchanged | Not applicable |

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1, SC-2, SC-3, SC-4, SC-5 | phase-1-content |
| R-2 | SC-1, SC-2 | phase-1-content |
| R-3 | SC-4, SC-5 | phase-1-content |
| R-4 | SC-6, SC-7 | phase-1-content |
| R-5 | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7 | phase-1-content |
| R-6 | SC-8 | phase-2-behavioral |
| R-7 | SC-9 | phase-2-behavioral |
| R-8 | SC-10 | phase-2-behavioral |
| R-9 | SC-11 | phase-2-behavioral |
| R-10 | SC-8, SC-9, SC-10, SC-11 | phase-2-behavioral |
| R-11 | (pipeline-state action — no SC) | spec approval / PR time |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| skill-card-description-standards.md | doc | `.opencode/reference/skill-card-description-standards.md` | Read (canonical dispatch-vocabulary table and description rules) |
| skill-card-schema.md | doc | `.opencode/reference/skill-card-schema.md` | Read (description 1–1024 char binary constraint) |
| playwright-cli SKILL.md | code | `.opencode/skills/playwright-cli/SKILL.md` | Live read — deprecated patterns confirmed in description; Browse-the-web When clause confirmed; description length measured (739 chars with spaces, 644 without) |
| validate_skill_cards.py | code | `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` | Live grep — SC-LINT-001 prohibited list and REQ-1 checks confirmed |
| tests-v2/AGENTS.md | doc | `.opencode/tests-v2/AGENTS.md` | Read — harness mandates (§4 ordered cycle, §6a two-SC pattern, §10 lessons, §14 monitoring) |
| Brainstorming handoff | artifact | `.opencode/.issues/2460/artifacts/preliminary/handoff.yaml` | Read — approved design, draft text, developer directives |
| Research cards | artifact | `{project_root}/.issues/research-cards/spec-writing-ai-agents-opencode-skill-architecture.md`, `{project_root}/.issues/research-cards/audit-skill-dimo-role-chain-defects.md`, `{project_root}/.issues/research-cards/imperative-verb-forms-load-directives.md` | Read — semantic-router principle, description-as-sole-dispatch-signal, defect precedent |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Grepping the description for 9 prohibited patterns costs seconds. Skipping costs the defect shipping in the deck's routing surface until the next validator audit — days-to-weeks of missed-activation behavior invisible to every downstream consumer.
- **SC-2:** Running the validator costs seconds. Skipping costs a deck-format regression the pattern grep alone cannot see — the validator enforces REQ-1 checks beyond the 9 grepped patterns, and a flagged card surfaces only at the next deck-wide audit.
- **SC-3:** Asserting capability-class phrases costs one grep. Skipping costs a description that passes format checks but still fails to activate on browser-appropriate intents — the actual behavioral defect survives as a silent missed dispatch.
- **SC-4:** Enforcing the 1–1024 char length bound costs one comparison. Skipping costs an over-limit description rejected at frontmatter parse — discovered only when the skill fails to load.
- **SC-5:** Diffing 6 frontmatter fields against a snapshot costs one scripted comparison. Skipping costs an unnoticed collateral field edit — a broken `allowed-tools` contract or silent field drift discovered only when skill loading or dispatch fails at runtime.
- **SC-6:** Asserting When-clause coverage costs one grep. Skipping costs a body/description routing inconsistency — escalation intents reach a workflow whose When clause no longer matches the description's promise, caught only during a failed dispatch.
- **SC-7:** Asserting dispatch-string byte-equality costs one diff. Skipping costs silent dispatch-contract drift — a downstream caller's `task()` prompt silently diverges from the workflow contract, surfacing as malformed dispatches at runtime.
- **SC-8:** Running the behavioral probe costs minutes of model execution. Skipping costs the death spiral: a description that formats cleanly but never flips the dispatch decision ships unchanged, and the defect surfaces in production as silently missed skill activations worth 1000× the probe cost.
- **SC-9:** Running the clean-room evaluation costs minutes of sub-agent read time. Skipping costs trust in the probe itself — an unevaluated session export proves nothing, and the dispatch claim collapses at review for the same cost re-run later.
- **SC-10:** Running the negative-control probe costs minutes of model execution. Skipping costs undetected false activations — escalation language that hijacks routine static-fetch tasks — a behavioral regression found only after every fetch-heavy workflow degrades.
- **SC-11:** Running the clean-room absence evaluation costs minutes. Skipping costs a loosened or unproven absence claim — the false-activation boundary becomes decoration, and test integrity (no lobotomized assertions) is compromised for the boundary the deck relies on.

## Edge Cases

- **Input boundary — description length:** Condition: the draft drifts beyond the 1024-char schema limit during editing. Expected behavior: the structural test (SC-4) rejects it; the change does not merge. Resolution: trim wording, not constraints.
- **Input boundary — pattern near-miss:** Condition: a partial removal leaves `Also load when` (absent from the SC-LINT-001 validator list, so the validator alone would pass). Expected behavior: the content test (SC-1) checks all 9 patterns and fails. Resolution: the content test is the stricter of the two gates; both must pass (SC-1 pattern-absence, SC-2 validator-clean).
- **State transition — RED/GREEN ordering:** Condition: the behavioral RED run executes against a post-fix ref. Expected behavior: the run is invalid — behavior_run() pre-flight gates fail or the verdict is discarded. Resolution: ordered cycle (commit → push → fresh fetch → verify effective commit in a remote ref) before every run; RED probes a ref still carrying the old description.
- **Failure mode — evaluation contamination:** Condition: the clean-room evaluation sub-agent receives the expected outcome. Expected behavior: the evaluation is discarded and re-dispatched clean-room. Resolution: evaluations read session.yaml only; expected outcomes never enter the evaluation prompt.
- **Failure mode — missing session export:** Condition: the session.yaml export is empty (e.g., run killed by timeout). Expected behavior: export falls back to the stderr `TEST_HOME=<path>` scan; if still absent, the SC is FAIL, not UNVERIFIED. Resolution: post-timeout manual export from the surviving SQLite DB per tests-v2/AGENTS.md §10.5.
- **Failure mode — loosened absence assertion:** Condition: SC-11's absence check is weakened to pass despite a false activation. Expected behavior: test-integrity violation — the change is rejected. Resolution: the sensitivity check (injected dispatch event must be detected) stays in the test; weakening it is a CRITICAL VIOLATION.
- **Concurrency — stale run lock:** Condition: a killed behavioral run leaves the lock file behind. Expected behavior: subsequent runs refuse to start. Resolution: remove the stale lock before re-running (tests-v2/AGENTS.md §10.1); no parallel behavioral runs against the same test home.
- **Recovery — API failure mid-flow:** Condition: the remote spec issue exists but a local write fails. Expected behavior: the pipeline reports the half-bound state rather than reassigning a number. Resolution: re-run binds to the remote-assigned number (2460) — never a local-counter fallback.

## Change Control

| Date | Change | Reason (validation finding) | Authorization |
|------|--------|------------------------------|---------------|
| 2026-09-23 | Corrected the provenance claim in Key Design Decisions: the 665-char draft is 74 chars SHORTER than the current description (pre-change frontmatter measured live: 739 chars with spaces, 644 without), replacing the false "slightly longer (~665 chars vs the old ~590)" claim. | Cluster 1 — check 7-provenance FAIL (claim verifiably contradicted live measurement). | spec-creation validation gate findings (validate aggregate_verdict FAIL), routed via orchestrator revise dispatch |
| 2026-09-23 | Decomposed compound SC-1, SC-3, SC-4 into atomic SCs — SC-1 split into pattern-absence grep (SC-1) + validator-clean run (SC-2); SC-3 split into length-bound check (SC-4) + 6-field byte-identity diff (SC-5); SC-4 split into When-clause coverage (SC-6) + dispatch-string byte-equality (SC-7). Renumbered SCs and Items 1:1 (8 → 11) and updated the item DAG, traceability table, R-5/R-7/R-9 internal SC references, cost frame, edge cases, sc-summary.yaml, and the exec-summary remote body. | Cluster 2 — compound-sc-detection FAIL + decomposition-atomicity FAIL (each bundled two independently verifiable claims joined by "and"). | spec-creation validation gate findings (validate aggregate_verdict FAIL), routed via orchestrator revise dispatch |
