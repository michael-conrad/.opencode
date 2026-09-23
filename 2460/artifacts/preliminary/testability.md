# Preliminary Testability Assessment — playwright-cli description fix

> Renumbered 2026-09-23 after validate-round-1 compound-SC decomposition (8 SCs → 11 SCs); mirrors the spec's authoritative SC table.

## SC evidence-type mapping

| SC | Evidence Type | Instrument | Feasibility |
|----|---------------|------------|-------------|
| SC-1 (zero prohibited patterns — 9 patterns incl. `Also load when`) | string | grep on frontmatter | Deterministic — draft text verified clean |
| SC-2 (validator REQ-1/SC-LINT-001 clean) | string | `validate_skill_cards.py` run | Deterministic |
| SC-3 (escalation capability class present) | string | grep on frontmatter | Deterministic |
| SC-4 (description within 1–1024 char limit) | structural | schema-bound check; RED uses overlong fixture | Deterministic |
| SC-5 (6 frontmatter fields byte-identical to snapshot) | structural | field diff vs pre-change snapshot; RED uses mutated fixture | Deterministic |
| SC-6 (When clause covers escalation family) | string | grep on SKILL.md line 55 region | Deterministic |
| SC-7 (dispatch contract strings unchanged) | string | byte-equality check vs snapshot; RED uses altered fixture | Deterministic |
| SC-8 (agent dispatches playwright-cli for browser-appropriate task) | behavioral | artifact-only generator → session.yaml | Feasible — RED runs against current remote state; GREEN requires commit+push cycle |
| SC-9 (clean-room evaluation confirms dispatch event) | behavioral | clean-room sub-agent reads SC-8 session.yaml | Feasible — skill-load events recorded in SQLite event table; early termination per developer directive (2026-09-23) once dispatch evidence confirmed in live session DB |
| SC-10 (negative control artifact generation) | behavioral | artifact-only generator, routine static-fetch prompt | Feasible |
| SC-11 (clean-room evaluation: no playwright dispatch in negative control) | behavioral | clean-room sub-agent reads SC-10 session.yaml | Feasible — absence assertion over event table |

## Harness requirements per tests-v2/AGENTS.md

- Bash tool timeout ≥600s for all behavioral runs; no GNU `timeout` in scripts
- Default model (`DEFAULT_TEST_MODEL` in `default-model.sh`) — no model substitution
- Ordered precondition cycle before every behavioral run: commit → push → fresh fetch → verify effective commit contained in remote ref → run
- Two-SC pattern (§6a): artifact generation (SC-8, SC-10) strictly separated from clean-room evaluation (SC-9, SC-11); evaluation reads session.yaml, never stdout/stderr
- §14 semantic monitoring with recorded poll log; early-termination directive applies to GREEN/negative runs once the judged evidence is confirmed

## RED phase precondition

Behavioral RED must observe the agent NOT dispatching playwright-cli under the OLD description. Satisfied by running against current remote main (old description is the effective remote state) before the fix branch lands. Content-verification RED runs against the working tree before the description edit.

## Known testability limitation (recorded as spec non-goal)

Execution binaries (`playwright-cli`, `npx`) absent in this environment — behavioral evidence covers the dispatch decision (skill-load event), not end-to-end page capture. Environment provisioning is a future spec.
