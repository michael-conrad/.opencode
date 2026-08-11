---
plan_schema_version: "1.0"
issue: 2263
title: "Re-scope orchestrator inline-work rule to allocation-by-context-cost model"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 7
---

# Implementation Plan — #2263 — Re-scope orchestrator inline-work rule to allocation-by-context-cost

**Issue:** https://github.com/michael-conrad/.opencode/issues/2263

**Goal:** Replace the self-contradictory "orchestrator NEVER performs inline work" absolute with a coherent allocation-by-context-cost model so the orchestrator has a compliant path on every skill load.

**Architecture:** Re-scope the inline-work rule from role-purity to allocation-by-context-cost (large/disposable → sub-agent; small/necessary → orchestrator). Delete the false "a SKILL.md is not a file" carve-out and replace it with a truthful context-economy justification. Re-express result-contract frugality, the DISPATCH_GATE no-preloaded-context rule, and clean-room sub-agent discipline as consequences of protecting the orchestrator's context resource. Re-justify critical-rules-XXX in 000-critical-rules.md and the 36 skill cards' DISPATCH_GATE Orchestrator Entry Criteria under the same rationale. Preserve the delegation mechanism (task(), skill(), clean-room) and explicitly distinguish cost-blind (verification cost) from context-cost (orchestrator context resource).

**Files:**
- `.opencode/guidelines/020-go-prohibitions.md`
- `.opencode/guidelines/000-critical-rules.md`
- 36 skill cards under `.opencode/skills/` with DISPATCH_GATE sections
- Behavioral enforcement tests under `.opencode/tests-v2/behaviors/` that assert the "never inline" absolute (updated to assert the context-economy model)

---

## Blast Radius

- **020-go-prohibitions.md (Tier 1)** — the "never inline" absolute (re-scope), the false carve-out (delete), §1.1 mechanism re-justification, line 217 cost-blind/context-cost distinction.
- **000-critical-rules.md (Tier 1)** — critical-rules-XXX re-justification; must stay consistent with the re-scoped 020.
- **36 skill cards** — DISPATCH_GATE Orchestrator Entry Criteria re-justification; each card self-contained.
- **Behavioral enforcement tests** — tests asserting the "never inline" absolute must be updated.
- **No ripple:** task cards, delegation mechanism, pipeline behavior, `.opencode/tools/` scripts.

---

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Re-scope 020 inline-work rule | `test-driven-development` | `red`, `green`, `phase-4`, `verify` | `.opencode/guidelines/020-go-prohibitions.md` | SC-1 | — |
| 2 — Delete false carve-out | `test-driven-development` | `red`, `green`, `phase-4`, `verify` | `.opencode/guidelines/020-go-prohibitions.md` | SC-2 | 1 |
| 3 — Re-justify mechanisms (§1.1) | `test-driven-development` | `red`, `green`, `phase-4`, `verify` | `.opencode/guidelines/020-go-prohibitions.md` §1.1 | SC-3 | 1 |
| 4 — Re-justify 000-critical-rules.md | `test-driven-development` | `red`, `green`, `phase-4`, `verify` | `.opencode/guidelines/000-critical-rules.md` | SC-4 | 1, 2, 3 |
| 5 — Re-justify 36 skill cards | `test-driven-development` | `red`, `green`, `phase-4`, `verify` | 36 DISPATCH_GATE skill cards | SC-5 | 4 |
| 6 — Eliminate self-contradiction | `test-driven-development` | `red`, `green`, `phase-4`, `verify` | All affected files | SC-6 | 1, 2, 3, 4, 5 |
| 7 — Preserve delegation / distinguish costs | `verification-before-completion` | `verify` | All affected files (verification only) | SC-7 | 1, 2, 3, 4, 5, 6 |

---

## Phase Details

### Phase 1 — Re-scope 020 inline-work rule

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` / `verification-before-completion` |
| Task | `red` / `green` / `phase-4` / `verify` |
| Target | `.opencode/guidelines/020-go-prohibitions.md` |
| SCs | SC-1 |
| Depends On | — |

**Context:**
```yaml
target_file: .opencode/guidelines/020-go-prohibitions.md
replacement_model: "allocation-by-context-cost: large/disposable -> sub-agent; small/necessary -> orchestrator"
guards:
  - "enforcement of large/disposable inline work preserved"
  - "cost-blind (verification) distinct from context-cost (orchestrator context)"
sc_ids: [SC-1]
```

### Phase 2 — Delete false carve-out

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` / `verification-before-completion` |
| Task | `red` / `green` / `phase-4` / `verify` |
| Target | `.opencode/guidelines/020-go-prohibitions.md` |
| SCs | SC-2 |
| Depends On | 1 |

**Context:**
```yaml
target_file: .opencode/guidelines/020-go-prohibitions.md
false_carve_out: "reading a SKILL.md is NOT 'inline work' or 'reading a file'"
replacement_justification: "skill() auto-loads SKILL.md into orchestrator context; routing metadata is small/necessary and already present; sub-agents cannot load skills"
sc_ids: [SC-2]
```

### Phase 3 — Re-justify mechanisms (§1.1)

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` / `verification-before-completion` |
| Task | `red` / `green` / `phase-4` / `verify` |
| Target | `.opencode/guidelines/020-go-prohibitions.md` §1.1 |
| SCs | SC-3 |
| Depends On | 1 |

**Context:**
```yaml
target_file: .opencode/guidelines/020-go-prohibitions.md
mechanisms_to_re_express:
  - result_contract_frugality
  - dispatch_gate_no_preloaded_context
  - clean_room_sub_agent_discipline
rationale: "direct consequences of protecting the orchestrator's context resource; substance unchanged"
sc_ids: [SC-3]
```

### Phase 4 — Re-justify 000-critical-rules.md

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` / `verification-before-completion` |
| Task | `red` / `green` / `phase-4` / `verify` |
| Target | `.opencode/guidelines/000-critical-rules.md` |
| SCs | SC-4 |
| Depends On | 1, 2, 3 |

**Context:**
```yaml
target_file: .opencode/guidelines/000-critical-rules.md
rule_to_rejustify: "critical-rules-XXX Dispatching SKILL.md to sub-agents - category error"
preserved: "category-error prohibition"
removed: "any false 'not a file' claim"
sc_ids: [SC-4]
```

### Phase 5 — Re-justify 36 skill cards

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` / `verification-before-completion` |
| Task | `red` / `green` / `phase-4` / `verify` |
| Target | 36 DISPATCH_GATE skill cards |
| SCs | SC-5 |
| Depends On | 4 |

**Context:**
```yaml
target_cards: "36 skill cards with DISPATCH_GATE sections (see code-path-inventory)"
section: "DISPATCH_GATE Orchestrator Entry Criteria"
rationale: "context-economy: reading TDT + Invocation in orchestrator context is small/necessary; sub-agents cannot load skills"
preserved: "no-preloaded-context substance"
sc_ids: [SC-5]
```

### Phase 6 — Eliminate self-contradiction

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` / `verification-before-completion` |
| Task | `red` / `green` / `phase-4` / `verify` |
| Target | All affected files |
| SCs | SC-6 |
| Depends On | 1, 2, 3, 4, 5 |

**Context:**
```yaml
scope: "all affected files (020, 000, 36 skill cards, behavioral enforcement tests)"
scenario: "skill load + dispatch without contradiction"
test_command: "bash .opencode/tests-v2/with-test-home opencode run '<message>'"
evidence_type: behavioral
sc_ids: [SC-6]
```

### Phase 7 — Preserve delegation / distinguish costs

| Field | Value |
|-------|-------|
| Skill | `verification-before-completion` |
| Task | `verify` |
| Target | All affected files (verification only) |
| SCs | SC-7 |
| Depends On | 1, 2, 3, 4, 5, 6 |

**Context:**
```yaml
scope: "all affected files"
verification_only: true
guards:
  - "delegation mechanism (task(), skill(), clean-room) unchanged"
  - "cost-blind vs context-cost distinction explicit"
sc_ids: [SC-7]
```

---

## Global Pre-Implementation Steps

These steps run once before any phase. Global sequential numbering across all phase files starts at step 3 in Phase 1.

- [ ] 1. **Coherence gate (**inline**).** Verify the spec SCs are internally coherent and no superseding/overlapping spec exists (authority-source protocol — check open specs #1406, #1204, #1010). **→ global pre-gate**
- [ ] 2. **Baseline check (**inline**).** Verify the affected files exist and the current "never inline" absolute and carve-out are present as described in the spec. **→ global pre-gate**

---

## Global Post-Implementation Steps

These steps run once after the last phase.

- [ ] 39. **Audit (**sub-agent**).** Execute verification-audit DiMo investigator from `audit`, followed by validator, evaluator, arbiter in sequence. **→ post-gate**
- [ ] 40. **Z3 check (**inline**).** Run `.opencode/tools/solve check` against the state and contract paths. **→ post-gate**
- [ ] 41. **Structural checks (**sub-agent**).** Execute checklist task from `finishing-a-development-branch`. **→ post-gate**
- [ ] 42. **Pre-PR gate (**sub-agent**).** Execute verify task from `verification-before-completion`; BLOCK if any SC verdict FAILs. **→ post-gate**
- [ ] 43. **Regression check (**sub-agent**).** Execute phase-4 task from `test-driven-development` for final regression. **→ post-gate**
- [ ] 44. **Review prep (**sub-agent**).** Execute review-prep from `git-workflow-pr`. **→ post-gate**
- [ ] 45. **Create PR (**sub-agent**).** Execute create task from `git-workflow-pr`. **→ post-gate**
- [ ] 46. **Executive summary (**sub-agent**).** Execute completion task from `completion-core`. **→ post-gate**

---

## Exit Criteria

- [ ] C1. `.opencode/guidelines/020-go-prohibitions.md` contains the allocation-by-context-cost model, no "NEVER performs inline work" absolute remains (SC-1).
- [ ] C2. The false carve-out is deleted from `020-go-prohibitions.md`, replaced with a truthful context-economy justification (SC-2).
- [ ] C3. Result-contract frugality, DISPATCH_GATE no-preloaded-context, and clean-room sub-agent discipline are re-expressed under context-economy in `020-go-prohibitions.md` §1.1 with substance unchanged (SC-3).
- [ ] C4. `000-critical-rules.md` critical-rules-XXX is re-justified under context-economy, category-error prohibition preserved, no false "not a file" claim remains (SC-4).
- [ ] C5. All 36 DISPATCH_GATE skill cards re-justify Orchestrator Entry Criteria under context-economy with no-preloaded-context substance unchanged (SC-5).
- [ ] C6. The self-contradiction is eliminated — a skill-load scenario runs without the orchestrator reconciling contradictory signals (SC-6, behavioral).
- [ ] C7. The delegation mechanism is unchanged and cost-blind is explicitly distinguished from context-cost (SC-7).

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-10T20:40:13-0400 | `plan_created` | Plan file `.opencode/.issues/2263/plan.md`, 7 phases |
