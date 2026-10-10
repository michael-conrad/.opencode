# [SPEC-FIX] Forbid workflow-step skipping in the implement card

## Problem

AI agents implementing plans will, when faced with multiple procedural steps —
baseline runs, RED-phase assertions, post-regression suite re-runs, verification
dispatches — rationalize that a step is "redundant" or "unnecessary" and skip,
compress, reorder, or defer it silently. The downstream defect surfaces only at
review or after merge, when the skipped step's protection is missing and the
rework cost is maximal.

The revised deck already covers two adjacent failure paths:

- `implement` rule 8 (SC fidelity) forbids weakening, skipping, deferring, or
  reinterpreting a **criterion** to make it passable — it governs what must be
  satisfied, not how the work proceeds.
- `verify` forbids proceeding past an unremediated FAIL — it governs review,
  after the work.

The uncovered residue is **workflow-step-level skipping**: nothing in the
implementation-level cards names the workflow's own procedural steps as
non-compressible, and nothing addresses the specific rationalization (a step
appearing redundant or unnecessary) that precedes the skip.

## Analysis: why the card, not the artifact body

The original fix proposed a fixed compliance statement stamped at top and
bottom of every generated spec and plan body. Against the revised deck that
mechanism fails on four grounds:

1. **Timing.** `implement` loads before work starts and before every
   mid-cycle change — exactly when the skip-temptation arises. Artifact
   boilerplate is out of sight at execution time unless the agent re-reads the
   spec, which is itself the failure case.
2. **Deck law.** The `spec` card's normative body footer allowlist permits only
   spec content plus the byline footer and bans process indicators of any kind;
   a mandated compliance statement at the bottom of every spec body would
   violate it by construction.
3. **Predicate class.** Step-skipping is intent-decidable: judgment decides
   when a step is being skipped. The floor assigns intent-decidable rules to
   judgment, never mechanical enforcement — so the original spec's mechanical
   behavioral tests (grep-generated artifacts, count occurrences) enforced an
   intent-level rule mechanically, a category mismatch.
4. **Cost model.** One rule in one card, loaded at the point of need, versus
   boilerplate duplicated into every artifact forever, plus an exact-wording
   lock that makes future wording maintenance brittle.

The failure mode lives at execution, so the rule has one home — `implement`.
Scattering the admonishment across `plan`/`work`/`verify` would re-import the
boilerplate pattern one level up.

## Proposed Fix

Append one new numbered rule to `.opencode/skills/implement/SKILL.md` (as
rule 10, after the existing rules 1–9, which remain unchanged and unrenumbered)
with content that:

- names the failure mode: a workflow step that appears redundant or
  unnecessary is not grounds to skip, compress, reorder, or defer it;
- covers the full workflow: the pre-implementation checklist, the RED/GREEN
  chain, and the post-implementation steps, including steps defined in the
  implementation-workflow reference;
- routes steps that genuinely cannot complete to the escalation path (stop the
  cycle, report the state) — silent omission is never the alternative;
- states the cost rationale: the cost of an extra step is negligible against
  the cost of a skipped one.

Recommended wording (the admission gate reviews final wording; the SCs key to
the content elements above, not to a character-for-character match):

> **Workflow fidelity.** Every step of the pre-implementation checklist, the
> RED/GREEN chain, and the post-implementation gates — including steps defined
> in the implementation-workflow reference — runs in order. A step that appears
> redundant or unnecessary is not grounds to skip, compress, reorder, or defer
> it; the cost of an extra step is negligible against the cost of a skipped
> one. A step that cannot complete stops the cycle per the reference's
> escalation rule — never silently omitted.

## Scope

**In scope:**

- Appending one rule to `.opencode/skills/implement/SKILL.md`

**Out of scope:**

- Compliance statements in generated spec/plan bodies (retired mechanism)
- Changes to the `spec`/`plan` cards or their artifact conventions
- Changes to the implementation-workflow reference (its escalation line
  already exists and the new rule references it)
- The same rule in any other card
- Mechanical or behavioral enforcement tests
- Retroactive edits to existing artifacts
- Renumbering or rewording of existing `implement` rules

**Constraint:** the target file is a governed deck skill card — the routing
index dispatches skill-file edits through the `skill-creator` admission gate.

## Affected Files

| File | Change |
|------|--------|
| `.opencode/skills/implement/SKILL.md` | Append rule 10 (workflow fidelity); rules 1–9 unchanged |

## Success Criteria

Evidence classification: the change is file text in a skill card; its runtime
effect (agents not skipping steps) is intent-decidable and not mechanically
testable, so all criteria are structural with fact-decidable instruments.

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `implement/SKILL.md` contains a rule stating that a workflow step appearing redundant or unnecessary is not grounds to skip, compress, reorder, or defer it | `string` | Read the card; the new rule names the rationalization ("redundant"/"unnecessary") and forbids all four actions (skip, compress, reorder, defer) |
| SC-2 | The new rule covers the full workflow — pre-implementation checklist, RED/GREEN chain, post-implementation steps — and includes steps defined in the implementation-workflow reference | `string` | The rule text names all three phases and references the implementation-workflow reference |
| SC-3 | The new rule routes steps that cannot complete to the escalation path rather than silent omission | `string` | The rule text names the escalation path (stop the cycle / report) as the alternative to skipping |
| SC-4 | The change is append-only: rules 1–9 of `implement/SKILL.md` are unchanged in numbering and content | `string` | Diff of the change shows exactly one appended numbered rule; no existing line modified or removed |

## Risk and Edge Cases

| RISK-ID | Risk | Likelihood | Impact | Mitigation | Verifying SC |
|---------|------|------------|--------|------------|--------------|
| RISK-1 | Rule reads as generic motivational boilerplate rather than naming the observed failure | Medium | Medium — dilutes the deck's lean style without changing behavior | The rule names the specific rationalization (redundant/unnecessary) and ties skipping to the escalation path; the admission gate reviews the final wording | SC-1, SC-3 |
| RISK-2 | Rule overlaps or conflicts with rule 8 (SC fidelity) | Low | Low — reader confusion about which governs what | Distinct objects: rule 8 governs criteria (what to satisfy); the new rule governs procedure (how the work proceeds) | SC-1 |
| RISK-3 | Rule creates a deadlock when a step genuinely cannot complete | Low | High — agent loops on an impossible step | SC-3 requires the escalation tie-in: a blocked step stops the cycle and reports | SC-3 |

## Documentation Sources

| Source | Purpose |
|--------|---------|
| `.opencode/skills/implement/SKILL.md` | Confirmed rule 8 covers criterion-level skipping only; no rule governs workflow-step skipping |
| `.opencode/skills/implement/references/implementation-workflow.md` | Confirmed the escalation line covers "cannot complete honestly", not skip-by-rationalization; confirmed the three workflow phases the rule must name |
| `.opencode/skills/verify/SKILL.md` | Confirmed review-level consequence (FAIL-halt) already exists; no card duplication needed |
| `.opencode/skills/spec/SKILL.md`, `.opencode/skills/plan/SKILL.md` | Confirmed the footer allowlist bans process indicators from artifact bodies; confirmed plan derivation needs no admonishment |

---

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
