> **Full spec and artifacts: `.issues/{N}/`** — this issue is a condensed exec summary; the authoritative spec lives in the local `.issues/{N}/` directory.

## Problem

Two task files in the `writing-plans` skill disagree on how pre-implementation and post-implementation steps are organized in plan documents:

- **`structure.md`** (Exit Criteria, line 17) mandates: "global pre-phase (once), per-file RED/GREEN phases (one chain each), global post-phase (once)" — pre/post are **dedicated `## Phase` sections**.
- **`write.md`** (Three-Tier Plan Structure, lines 88-100) mandates: "Tier 1 (Global): Steps numbered sequentially across the entire plan. Includes global pre-steps and global post-steps" — pre/post are **plan-wide steps without their own phase heading**.

The plan writer must choose between these two contradictory specifications. The choice varies by session, producing inconsistent plan documents. Some plans merge pre-RED common steps into the first real phase; others leave global post-steps as bare sections without a `## Phase` heading.

## Scope

**In scope:**
- Fix `write.md` to match `structure.md`'s three-tier phase model: dedicated pre-phase, per-file phases, dedicated post-phase
- Remove the Tier 1 (Global) concept from `write.md` — pre/post steps get their own `## Phase` headings
- Update the Three-Tier Plan Structure section in `write.md` to reflect the dedicated-phase model
- Update the Required Sections list in `write.md` to include pre-phase and post-phase as phase sections

**Out of scope:**
- Changes to `structure.md` (it already has the correct model)
- Changes to the implementation-pipeline dispatch routing table
- Changes to plan validation rules (they already check for phase structure)

## Approach

Two changes to `write.md`:

1. **Three-Tier Plan Structure (lines 88-100):** Replace the Tier 1 (Global) concept with a dedicated-phase model. Tier 1 becomes "Pre-Phase (global setup)" — a `## Phase 1 — Pre-Phase` section containing coherence gate, pre-red-baseline, and any other pre-implementation steps. Tier 2 becomes per-file RED/GREEN phases. Tier 3 becomes "Post-Phase (global completion)" — a final `## Phase N — Post-Phase` section containing adversarial audit, cross-validate, regression check, review-prep, and exec-summary.

2. **Required Sections (lines 56-84):** Update the section list to include pre-phase and post-phase as named phase sections. The admonishment and one-step-at-a-time protocol remain as plan-wide elements outside the phase sections.

## Affected Files

| File | Change |
|------|--------|
| `.opencode/skills/writing-plans/tasks/write.md` | Three-Tier Plan Structure: replace Tier 1 (Global) with dedicated pre-phase and post-phase sections. Update Required Sections list. |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | `write.md` defers to `structure.md`'s phase model | `structure.md` defines the phase layout; `write.md` renders it. The renderer must match the architect. | MUST | SC-1 |
| DEC-2 | Pre-phase and post-phase get `## Phase` headings | Dedicated sections prevent ambiguity about where pre/post steps belong. A plan reader can immediately identify the setup and teardown phases. | MUST | SC-1 |

## Risk Traceability

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Existing plans reference Tier 1 (Global) structure | Low | Low | Plans are regenerated per spec; no backward compatibility needed | SC-1 |
| RISK-2 | Plan writer ignores new format and produces old-style plans | Medium | Medium | Validation rule in write.md Step 3 checks for pre-phase and post-phase headings | SC-2 |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Phase Binding | Verification Gate | Integration Mode |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|--------------|-----------------|-----------------|
| SC-1 | `write.md` Three-Tier Plan Structure section uses dedicated pre-phase and post-phase headings instead of Tier 1 (Global) steps | `string` | `grep -c 'Pre-Phase\|Post-Phase' .opencode/skills/writing-plans/tasks/write.md` — must show at least 2 matches | If missing, update the Three-Tier Plan Structure section | pre-commit | `.opencode/skills/writing-plans/tasks/write.md` | Phase 1 | pre-commit | atomic |
| SC-2 | Plan validation rule checks for pre-phase and post-phase `## Phase` headings in generated plans | `string` | `grep 'pre-phase\|post-phase\|Pre-Phase\|Post-Phase' .opencode/skills/writing-plans/tasks/write.md` — must appear in validation rules section | If missing, add validation check | pre-commit | `.opencode/skills/writing-plans/tasks/write.md` | Phase 1 | pre-commit | atomic |

## Edge Cases

| Case | Expected Behavior |
|------|------------------|
| Single-phase spec (1 phase) | Pre-phase and post-phase are still present as Phase 1 and Phase 3, with the single implementation phase as Phase 2 |
| Spec with no pre-steps needed | Pre-phase section still exists but contains only the coherence gate and pre-red-baseline (always required) |
| Spec with no post-steps needed | Post-phase section still exists but contains only the mandatory audit and review steps |

## Regression Invariants

1. All existing plan format validation rules remain unchanged
2. The dispatch indicators (`(**sub-agent**)`, `(**clean-room**)`, `(**inline**)`) remain unchanged
3. Global sequential numbering across all phases remains unchanged

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `read .opencode/skills/writing-plans/tasks/structure.md` | Verify three-tier phase model (pre-phase, per-file, post-phase) |
| Direct source search | `read .opencode/skills/writing-plans/tasks/write.md` | Verify Tier 1 (Global) vs dedicated-phase contradiction |
| Direct source search | `read .opencode/skills/implementation-pipeline/SKILL.md` | Verify dispatch routing table for pre/post step labels |

After this spec is approved, invoke `writing-plans` to create `.issues/{N}/plan.md` before implementation begins.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)