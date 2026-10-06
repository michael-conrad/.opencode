# Behavioral-Testing Card: Local GitBucket Capability Missing — Spec

## Problem Statement

The behavioral-testing skill card (`.opencode/skills/behavioral-testing/SKILL.md`) is the
dispatch surface for behavioral verification. It routes agents to `tests-v2/AGENTS.md`
("read first, every time") but carries no mention of the harness's self-contained
GitBucket container capability for remote-API behavioral tests — documented in
`tests-v2/AGENTS.md` §12 ("Self-Contained GitBucket Container for Remote API Tests") and
implemented by `__ensure_gitbucket()` in `behaviors/helpers.sh` (JDK provisioning, cached
GitBucket JAR, auto-assigned port, token generation; `GB_TOKEN` / `GB_HOST` /
`GITBUCKET_PORT` environment).

An agent loading the card has no signal that remote-API behavioral SCs can run against a
locally provisioned GitBucket — affecting scenario design (mock vs provision) and
capability discoverability at the card's dispatch surface.

Developer direction 2026-10-06: check whether this information is missing from the card;
if yes, address with a new spec. Inspection confirmed it is missing (zero GitBucket
mentions in the card; 25 in the harness docs).

## Scope

### In Scope

- Add the self-contained-GitBucket capability to the behavioral-testing card's dispatch
  surface — card description (routing match surface) and/or card rules — in the card's
  established lean style, referencing `tests-v2/AGENTS.md` §12 as the detail source
  (progressive disclosure: card carries the capability signal; docs carry the mechanics).
- Deck-governance admission via the skill-creator gate for the card edit.

### Out of Scope

- Any change to the harness itself (`tests-v2/` scripts, helpers, or docs — the docs
  already carry the capability).
- Changes to any other card.

## Success Criteria

- [ ] **SC-1 (structural):** The behavioral-testing card's description and/or rules
  reference the self-contained GitBucket container for remote-API tests (tests-v2 §12)
  such that an agent loading the card learns the capability exists and where its
  mechanics live. Verification: inspection of the card against §12 content.
- [ ] **SC-2 (structural):** The card edit is admitted through the skill-creator
  governance gate and introduces no reference breakage. Verification: governance record
  + reference-integrity check.

## References

- `tests-v2/AGENTS.md` §12 — Self-Contained GitBucket Container for Remote API Tests
- `.opencode/tests-v2/behaviors/helpers.sh` — `__ensure_gitbucket()`
- Related: `.opencode/.issues/169/` — wiki-operations card set; its SC-4 behavioral run
  is a consumer of this capability

---

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
