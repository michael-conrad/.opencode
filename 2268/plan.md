---
plan_schema_version: "1.0"
issue: 2268
title: "Add vision-agent and visual-design-agent sub-agent cards to .opencode/agents"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 4
dispatch:
  - phase: 1
    skill: test-driven-development
    task: red
  - phase: 2
    skill: test-driven-development
    task: red
  - phase: 3
    skill: test-driven-development
    task: red
  - phase: 4
    skill: test-driven-development
    task: red
---

# Implementation Plan — #2268 — Add vision-agent and visual-design-agent Sub-Agent Cards

**Issue:** [.opencode #2268](https://github.com/michael-conrad/.opencode/issues/2268)

**Goal:** Add two new sub-agent cards, `vision-agent` and `visual-design-agent`, to `.opencode/agents/` so they are available globally across all repos using this setup, targeting the `ollama-cloud/qwen3.5:397b-cloud` model.

**Architecture:** Four phases, one per success criterion. Phase 1 creates `.opencode/agents/vision-agent.md` with the exact frontmatter and body from the spec (SC-1). Phase 2 creates `.opencode/agents/visual-design-agent.md` with the exact frontmatter and body from the spec (SC-2). Phases 3 and 4 are validation phases: Phase 3 verifies both files are valid opencode sub-agent cards (frontmatter fields, `mode: subagent`, provider-prefixed model ID) (SC-3); Phase 4 verifies the agent names are exactly `vision-agent` and `visual-design-agent` with no suffix (SC-4). Phases 1 and 2 are independent. Phases 3 and 4 depend on both creation phases. This is a purely additive change — two new files, no modifications, no deletions, no changes outside `.opencode/agents/`. Evidence types are string (SC-1, SC-2, SC-4) and structural (SC-3); no behavioral tests are required because there is no runtime behavior change.

**Files:**
- `.opencode/agents/vision-agent.md` (new)
- `.opencode/agents/visual-design-agent.md` (new)
- `.opencode/tests-v2/test-2268-sc1-vision-agent-card.sh` (new, content-verification)
- `.opencode/tests-v2/test-2268-sc2-visual-design-agent-card.sh` (new, content-verification)
- `.opencode/tests-v2/test-2268-sc3-valid-sub-agent-cards.sh` (new, content-verification)
- `.opencode/tests-v2/test-2268-sc4-agent-names.sh` (new, content-verification)

**Dispatch:** `test-driven-development` (red/green), `verification-before-completion` (verify), per the implementation-workflow reference card.

---

## Blast Radius

- **New files:** `.opencode/agents/vision-agent.md`, `.opencode/agents/visual-design-agent.md`
- **Existing directory:** `.opencode/agents/` — unchanged; contains pre-existing `steps-value-analysis.md` which is a documentation file, not an agent card, and must not be renamed or modified
- **Outside `.opencode/agents/`:** no changes to skills, guidelines, configs, or tests
- **Regression invariants:** `steps-value-analysis.md` must remain unchanged; no other `.opencode/` content may be modified

---

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Create vision-agent card | `test-driven-development` | `red` | `.opencode/agents/vision-agent.md` | SC-1 | — |
| 2 — Create visual-design-agent card | `test-driven-development` | `red` | `.opencode/agents/visual-design-agent.md` | SC-2 | — |
| 3 — Validate both cards | `test-driven-development` | `red` | `.opencode/agents/` (both new files) | SC-3 | 1, 2 |
| 4 — Verify agent names | `test-driven-development` | `red` | `.opencode/agents/` (both new files) | SC-4 | 1, 2 |

---

## Phase Details

### Phase 1 — Create vision-agent card

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/agents/vision-agent.md` |
| SCs | SC-1 |
| Depends On | — |

**Context:**
- target_file: `.opencode/agents/vision-agent.md`
- source: spec #2268, "File 1" code block — exact frontmatter (description, mode: subagent, model: ollama-cloud/qwen3.5:397b-cloud, temperature: 0.3, top_p: 0.8, top_k: 20, options, permission edit/bash/webfetch deny) and exact body
- evidence_type: string (file content comparison against the spec block)
- verification_test: `.opencode/tests-v2/test-2268-sc1-vision-agent-card.sh`
- sc_ids: [SC-1]

**Cost frame:** Verifying the card file matches the spec block exactly costs one content comparison. Skipping means a card with wrong frontmatter or body ships and fails the sub-agent discovery load at first use.

### Phase 2 — Create visual-design-agent card

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/agents/visual-design-agent.md` |
| SCs | SC-2 |
| Depends On | — |

**Context:**
- target_file: `.opencode/agents/visual-design-agent.md`
- source: spec #2268, "File 2" code block — exact frontmatter (description, mode: subagent, model: ollama-cloud/qwen3.5:397b-cloud, temperature: 0.8, top_p: 1.0, top_k: 40, options, permission edit allow / bash allowlist) and exact body
- evidence_type: string (file content comparison against the spec block)
- verification_test: `.opencode/tests-v2/test-2268-sc2-visual-design-agent-card.sh`
- sc_ids: [SC-2]

**Cost frame:** Verifying the card file matches the spec block exactly costs one content comparison. Skipping means a card with a wrong permission model or body ships and breaks generation behavior at first use.

### Phase 3 — Validate both cards

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/agents/` (both new files) |
| SCs | SC-3 |
| Depends On | 1, 2 |

**Context:**
- validation_targets: `.opencode/agents/vision-agent.md`, `.opencode/agents/visual-design-agent.md`
- assertions: both files parse as valid opencode sub-agent cards; `mode: subagent` present in both; model IDs provider-prefixed (`ollama-cloud/qwen3.5:397b-cloud`)
- evidence_type: structural (frontmatter parse)
- verification_test: `.opencode/tests-v2/test-2268-sc3-valid-sub-agent-cards.sh`
- sc_ids: [SC-3]

**Cost frame:** Parsing both frontmatter blocks costs two reads. Skipping means a structurally invalid card (wrong mode or unprefixed model) is discovered only when a consumer tries to load the sub-agent and it silently falls back to the wrong model.

### Phase 4 — Verify agent names

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/agents/` (both new files) |
| SCs | SC-4 |
| Depends On | 1, 2 |

**Context:**
- validation_targets: filenames exactly `vision-agent.md` and `visual-design-agent.md` in `.opencode/agents/`
- assertions: no suffix appended to either filename; pre-existing `steps-value-analysis.md` untouched and not an agent card
- evidence_type: string (filename check)
- verification_test: `.opencode/tests-v2/test-2268-sc4-agent-names.sh`
- sc_ids: [SC-4]

**Cost frame:** Listing the directory and comparing filenames costs one `ls`. Skipping means a suffixed filename ships, the agent is never discovered by its canonical name, and downstream routing references break.

---

## Exit Criteria

- [ ] C1. `.opencode/agents/vision-agent.md` exists with the exact frontmatter and body from the spec (SC-1)
- [ ] C2. `.opencode/agents/visual-design-agent.md` exists with the exact frontmatter and body from the spec (SC-2)
- [ ] C3. Both files are valid opencode sub-agent cards — correct frontmatter fields, `mode: subagent`, provider-prefixed model ID `ollama-cloud/qwen3.5:397b-cloud` (SC-3)
- [ ] C4. The agent names are exactly `vision-agent` and `visual-design-agent` — no suffix (SC-4)
- [ ] C5. Pre-existing `.opencode/agents/steps-value-analysis.md` is unchanged (regression invariant)
- [ ] C6. All four content-verification tests pass (SC-1 string, SC-2 string, SC-3 structural, SC-4 string)
