# Plan: TDD RED/GREEN Sequential Pair Discipline

**Spec:** [#1086](https://github.com/michael-conrad/.opencode/issues/1086)
**Authorization scope:** `for_pr`, **pr_strategy:** `stacked`

## Structure Decision

**Plan structure decision:** separate
**Reason:** Multi-phase spec with distinct concern boundaries (TDD core, spec writer/plan writer, auditors) that are independently implementable.

## Phase 1: Update TDD Skill Core

**Concern boundary** (entering: TDD methodology enforcement core): This phase modifies the TDD skill's own SKILL.md and task files to add RED/GREEN separation prohibition, sequential pair mandate, and the Combined-Phase anti-pattern. Everything in this phase is self-referential — the TDD skill is enforcing its own discipline.

**SC coverage:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-10

**Why this phase first:** The TDD skill is the root of all downstream enforcement. Spec writers and plan writers reference it. Auditors reference it. Changing TDD first means downstream consumers see the new rules when they next load the skill.

### Item 1.1: TDD SKILL.md — RED/GREEN separation prohibition (SC-1)

RED condition: Principle 2 in the Five Core Principles section says "TDD discipline — RED phase tests before GREEN phase implementation" without prohibiting combined phases.
GREEN condition: Principle 2 or a new principle explicitly states "RED and GREEN must be separate phases. They may NEVER be combined into a single phase or step." Uses "NEVER" language. This is a hard gate — no override.

| Gate | Name | Exit Criterion |
|------|------|---------------|
| 1 | sc-coherence-gate | SC-1 requires RED/GREEN separation prohibition in principle 2 or new principle |
| 2 | pre-red-baseline | File read confirms current principle 2 text |
| 3 | red-phase | grep for combined-phase language absent from current SKILL.md |
| 4 | red-doublecheck | Re-run confirms consistent absence |
| 5 | green-phase | `grep "must be separate" .opencode/skills/test-driven-development/SKILL.md` returns match |
| 6 | checkpoint-commit | SKILL.md change committed |
| 7 | structural-checks | `wc -w` of SKILL.md < 4000 |
| 8 | green-doublecheck | Re-run grep confirms match is correct language |
| 9 | green-vbc | SC-1 criterion verified: "NEVER" language present in the Five Core Principles |
| 10 | adversarial-audit | Auditor confirms SC-1 met |
| 11 | cross-validate | Both auditors agree |
| 12 | regression-check | Other SCs (2-11) not affected by this edit |
| 13 | review-prep | PR body covers SC-1 |
| 14 | exec-summary | Phase summary reported |

```
(declare-const I11_p1 Bool) ... (declare-const I11_p14 Bool)
(declare-const D_I11 Bool)
(assert (=> I11_p2 I11_p1)) ... (assert (=> I11_p14 I11_p13))
(assert (=> D_I11 (and I11_p1 ... I11_p14)))
(assert (=> (not (and I11_p1 ... I11_p14)) (not D_I11)))
```

### Item 1.2: TDD SKILL.md — Sequential pair mandate (SC-2)

RED condition: ASCII cycle diagram shows "Next item — back to Phase 0" but no explicit sequential pair mandate text.
GREEN condition: A new subsection or expansion of the ASCII diagram section states: "RED/GREEN pairs execute sequentially. When multiple RED/GREEN pairs exist, each RED must be immediately followed by its GREEN before the next RED begins. The cycle is: item-1-RED → item-1-GREEN → item-2-RED → item-2-GREEN, never RED-ALL → GREEN-ALL."

| Gate | Name | Exit Criterion |
|------|------|---------------|
| 1 | sc-coherence-gate | SC-2 requires sequential pair mandate in SKILL.md |
| 3 | red-phase | grep for "RED/GREEN pairs execute sequentially" absent |
| 5 | green-phase | `grep "execute sequentially" .opencode/skills/test-driven-development/SKILL.md` returns match |
| 9 | green-vbc | Sequential pair mandate text present |
| 10 | adversarial-audit | Auditor confirms SC-2 met |

### Item 1.3: TDD anti-patterns — Combined-Phase anti-pattern (SC-3)

RED condition: Anti-pattern table has 5 rows. No "Combined-Phase" or "Combined RED/GREEN" entry.
GREEN condition: New row in the anti-pattern table: Combined-Phase (RED+GREEN collapsed into one step). Fields: symptom (RED and GREEN happen together), root cause (impatience or false efficiency), alternative (always separate RED then GREEN).

| Gate | Name | Exit Criterion |
|------|------|---------------|
| 1 | sc-coherence-gate | SC-3 requires new anti-pattern row |
| 3 | red-phase | grep for "Combined-Phase" absent |
| 5 | green-phase | `grep "Combined-Phase" .opencode/skills/test-driven-development/tasks/anti-patterns.md` returns match |
| 9 | green-vbc | Row has symptom, root cause, alternative columns filled |

### Item 1.4: TDD patterns — Triangulation mandates sequential pairs (SC-4)

RED condition: Triangulation section shows visual steps but no MANDATORY note about sequential pairs.
GREEN condition: Triangulation section adds: "MANDATORY: Each RED must be immediately followed by its GREEN before the next RED begins."

| Gate | Name | Exit Criterion |
|------|------|---------------|
| 1 | sc-coherence-gate | SC-4 requires sequential mandate in Triangulation |
| 3 | red-phase | grep for "MANDATORY: Each RED" absent |
| 5 | green-phase | `grep "MANDATORY: Each RED" .opencode/skills/test-driven-development/tasks/patterns.md` returns match |

### Item 1.5: TDD patterns — Obvious Implementation sequential mandate (SC-10)

RED condition: Obvious Implementation pattern allows "GREEN only (skip RED)" with no sequential caveat.
GREEN condition: Obvious Implementation section adds note: "Even when skipping RED, GREEN is a separate phase. RED/GREEN may NEVER be combined into a single step. If the implementation is trivially correct, write the GREEN test first (confirm it FAILs due to missing implementation), then implement."

| Gate | Name | Exit Criterion |
|------|------|---------------|
| 1 | sc-coherence-gate | SC-10 requires sequential mandate applies to Obvious Implementation |
| 3 | red-phase | grep for "Even when skipping RED" absent from patterns.md |
| 5 | green-phase | Note about sequential discipline present in Obvious Implementation section |

### Item 1.6: TDD checklist — RED/GREEN separation items (SC-5)

RED condition: RED checklist has no item confirming separation from GREEN. GREEN checklist has no item confirming separation from RED.
GREEN condition: RED checklist adds: "RED is a separate phase — no GREEN work started." GREEN checklist adds: "GREEN is a separate phase — RED was completed and confirmed FAIL before GREEN began."

| Gate | Name | Exit Criterion |
|------|------|---------------|
| 1 | sc-coherence-gate | SC-5 requires checklist items confirming separation |
| 3 | red-phase | Separation items absent from both RED and GREEN checklists |
| 5 | green-phase | Both separation items present in checklist.md |

---

## Phase 2: Update Spec Writer and Plan Writer

**Concern boundary** (entering: downstream consumer enforcement): Phase 1 modified the TDD skill itself. Phase 2 modifies the spec writer and plan writer — the two most common consumers of TDD methodology. They must mandate sequential per-item TDD in the specs and plans they produce.

**SC coverage:** SC-6, SC-7

**Handoff:** Phase 1 delivers updated TDD SKILL.md with the RED/GREEN prohibition and sequential pair mandate. Phase 2 references those new rules when adding mandates to spec-creation and writing-plans.

**Why this phase second:** Spec writers and plan writers produce specs and plans that reference TDD discipline. The TDD core must be updated first so downstream references are consistent.

### Item 2.1: spec-creation write.md — Sequential per-item TDD mandate (SC-6)

RED condition: `spec-creation/tasks/write.md` has no reference to sequential per-item TDD mandate.
GREEN condition: write.md includes a statement that spec's implementation phases MUST enforce sequential RED/GREEN pairing per the TDD skill.

| Gate | Name | Exit Criterion |
|------|------|---------------|
| 1 | sc-coherence-gate | SC-6 requires mandate in write.md |
| 3 | red-phase | grep for "sequential per-item TDD" in write.md absent |
| 5 | green-phase | `grep -c "sequential" .opencode/skills/spec-creation/tasks/write.md` count increased |

### Item 2.2: writing-plans plan-structure.md — RED/GREEN separate phases (SC-7)

RED condition: `writing-plans/tasks/create/plan-structure.md` Step 3.5 does not explicitly require RED/GREEN separation.
GREEN condition: Step 3.5 or a new step explicitly requires that RED and GREEN phases be defined as separate phases in plan structure.

| Gate | Name | Exit Criterion |
|------|------|---------------|
| 1 | sc-coherence-gate | SC-7 requires separation in plan-structure.md |
| 3 | red-phase | Separation requirement absent from Step 3.5 |
| 5 | green-phase | `grep "RED/GREEN" .opencode/skills/writing-plans/tasks/create/plan-structure.md` shows separation requirement |

---

## Phase 3: Update Auditors

**Concern boundary** (entering: verification concern): Phase 1 and 2 modified the producers (TDD skill, spec writer, plan writer). Phase 3 modifies the verifiers — adversarial auditors that check plan fidelity and test quality must verify RED/GREEN separation criteria.

**SC coverage:** SC-8, SC-9

**Handoff:** Phase 2 delivers updated spec-creation and writing-plans with sequential TDD mandates. Phase 3 adds audit criteria that verify those mandates are followed.

**Why this phase third:** Auditors verify what producers create. The producer must be updated first so the auditor has something to verify against.

### Item 3.1: plan-fidelity — PF-6 expanded for RED/GREEN separation (SC-8)

RED condition: PF-6 checks "TDD checkpoints present" without explicitly checking RED/GREEN separation.
GREEN condition: PF-6 criteria expanded: "TDD checkpoints present with RED/GREEN separation — RED and GREEN are separate phases, not combined."

| Gate | Name | Exit Criterion |
|------|------|---------------|
| 1 | sc-coherence-gate | SC-8 requires PF-6 expanded |
| 3 | red-phase | PF-6 does not mention RED/GREEN separation |
| 5 | green-phase | `grep "RED/GREEN" .opencode/skills/adversarial-audit/tasks/plan-fidelity.md` shows expanded PF-6 |

### Item 3.2: test-quality-audit — new TQ-11 for sequential TDD (SC-9)

RED condition: Test quality audit has no criterion for sequential TDD (TQ-11 does not exist).
GREEN condition: New TQ-11 criterion: "Sequential TDD — tests show evidence of RED-before-GREEN ordering (FAIL before PASS) across multiple items."

| Gate | Name | Exit Criterion |
|------|------|---------------|
| 1 | sc-coherence-gate | SC-9 requires new TQ-11 |
| 3 | red-phase | grep for "TQ-11" in test-quality-audit.md absent |
| 5 | green-phase | `grep "TQ-11" .opencode/skills/adversarial-audit/tasks/test-quality-audit.md` returns match |

---

## Cross-Cutting Verification: SC-11 (Single Concern)

SC-11 must be verified at plan level: the spec addresses exactly one concern — TDD RED/GREEN sequential pair discipline. All phases, items, and SCs are about the same concern. No scope creep.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
