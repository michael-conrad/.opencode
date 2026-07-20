## Problem

The `spec-creation` skill produces specs that are then audited by `spec-audit`. Issue #1850 adds an 11-dimension holistic semantic gate to spec-audit that runs before narrow criteria. But the spec-creation skill has no corresponding producer-side discipline — it doesn't know about the 11 dimensions and doesn't self-check its output before finalizing.

A spec that fails the holistic gate is a spec-producer defect. The producer should catch these defects before the auditor does. Currently, the spec-creation skill:

- Has no root cause analysis section requirement (feeds Correctness, Traceability)
- Has no "Alternatives Considered & Why Discarded" requirement in the preamble (feeds Implementability)
- Has no safety considerations section for destructive changes (feeds Safety)
- Has no evidence/provenance requirement for factual claims (feeds Provenance)
- Has no SC-to-root-cause traceability table requirement (feeds Traceability)
- Has no feasibility assessment requirement — doesn't verify referenced files/functions exist (feeds Feasibility)
- Has no pre-completion holistic self-check (all 11 dimensions)
- Has no guidance prohibiting escape hatch language
- Has no guidance requiring live-source verification before claims enter the spec body
- Has no guidance requiring preamble-body alignment (Correctness)

**Root cause:** The spec-creation skill was designed before the holistic gate existed. It produces structurally complete specs but doesn't ensure they're semantically sound.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | spec-creation SKILL.md description updated to include holistic self-check trigger phrases ("holistic check", "self-check", "pre-completion check") | `string` | grep for trigger phrases in spec-creation SKILL.md YAML header |
| SC-2 | spec-creation Trigger Dispatch Table updated with holistic self-check task entry | `string` | grep for holistic self-check entry in spec-creation SKILL.md dispatch table |
| SC-3 | spec-creation create task includes root cause analysis section in spec template | `string` | grep for root cause analysis in spec-creation create task file |
| SC-4 | spec-creation create task includes "Alternatives Considered & Why Discarded" in preamble template | `string` | grep for "Alternatives Considered" in spec-creation create task file |
| SC-5 | spec-creation create task includes safety considerations section for destructive changes | `string` | grep for safety considerations in spec-creation create task file |
| SC-6 | spec-creation create task requires evidence/provenance for every factual claim (no assertion without tool-call artifact) | `string` | grep for provenance/evidence requirement in spec-creation create task file |
| SC-7 | spec-creation create task includes SC-to-root-cause traceability table in spec template | `string` | grep for traceability table in spec-creation create task file |
| SC-8 | spec-creation create task includes feasibility assessment requirement (verify referenced files/functions/libraries exist) | `string` | grep for feasibility assessment in spec-creation create task file |
| SC-9 | spec-creation completion task includes pre-completion holistic self-check (run 11 dimensions before finalizing) | `string` | grep for holistic self-check in spec-creation completion task file |
| SC-10 | spec-creation guidance prohibits escape hatch language in spec body | `string` | grep for escape hatch prohibition in spec-creation task files |
| SC-11 | spec-creation guidance requires live-source verification before any factual claim enters the spec body | `string` | grep for live-source verification requirement in spec-creation task files |
| SC-12 | spec-creation guidance requires preamble-body alignment (preamble's problem statement must match body's SCs) | `string` | grep for preamble-body alignment in spec-creation task files |
| SC-13 | Behavioral test: spec-creation produces a spec that passes all 11 holistic dimensions | `behavioral` | `opencode-cli run` with spec creation request → produced spec passes holistic gate |
| SC-14 | Behavioral test: spec-creation refuses to finalize a spec that would fail the holistic gate | `behavioral` | `opencode-cli run` with spec creation request for ambiguous spec → spec-creation halts with holistic gate failure |
| SC-15 | spec-creation create task and completion task have sync header comments referencing `.opencode/reference/holistic-dimensions.yaml` | `string` | grep for "Dimensions synced from .opencode/reference/holistic-dimensions.yaml" in both files |

## Recommended Approach

### Template additions to spec-creation create task

Add the following sections to the spec template:

1. **Root Cause Analysis** — Required section between Problem and Success Criteria. Documents the root cause, not just symptoms. Feeds Correctness and Traceability dimensions.

2. **Alternatives Considered & Why Discarded** — Required field in the preamble. Each alternative must have a discard rationale. Feeds Implementability dimension.

3. **Safety Considerations** — Required section when the spec involves destructive operations, data mutations, or security-sensitive changes. Documents rollback plans and safeguards. Feeds Safety dimension.

4. **Evidence/Provenance** — Every factual claim in the spec body must be backed by a tool-call artifact (srclight, grep, read, webfetch). Claims without evidence are flagged before finalization. Feeds Provenance dimension.

5. **SC-to-Root-Cause Traceability Table** — Maps each SC to the root cause element it tests. Feeds Traceability dimension.

6. **Feasibility Assessment** — Before including a file/function/library reference in the spec, verify it exists. References to non-existent artifacts are flagged before finalization. Feeds Feasibility dimension.

### Process addition: pre-completion holistic self-check

Add to the `completion` task:

**Step: Holistic Self-Check**

Before finalizing the spec, dispatch a clean-room sub-agent to evaluate the spec against the 11 dimensions defined in `.opencode/reference/holistic-dimensions.yaml`. If any dimension FAILs, refuse to finalize — return the spec to the create task for revision with the failed dimensions listed.

### Guidance additions

Add to the spec-creation task files:

- **Escape hatch prohibition:** The spec body must not contain language that lets the agent short-circuit requirements. Prohibited patterns: "use best judgment", "if time permits", "simplify if needed", "TBD", "TODO", "left to implementor", "implementor's choice", "optionally", "preferably", "ideally", "should" (as weasel word), "as appropriate", "as needed" (without criteria).

- **Live-source verification:** Before any factual claim enters the spec body, verify it against a live source (srclight, grep, read, webfetch). No claim from memory or training data.

- **Preamble-body alignment:** The preamble's problem statement must match the body's SCs. If the preamble says "fix X" but the SCs test Y, the spec is incorrect.

### Trigger text updates

Add to the SKILL.md YAML header description:

```
Also use when running holistic self-checks on specs before completion, or verifying spec quality against the 11-dimension holistic gate. Invoke for: holistic check, self-check, pre-completion check, spec quality verification.
```

Add to the Trigger Dispatch Table:

| "holistic check" / "self-check" / "pre-completion check" | `holistic-self-check` | `sub-task` | {spec_context} |

### Cross-reference sync

The 11 dimensions are defined in `.opencode/reference/holistic-dimensions.yaml` (#1850). The spec-creation create and completion tasks reference this file via sync header comments:

```markdown
<!-- Dimensions synced from .opencode/reference/holistic-dimensions.yaml -->
<!-- Sync locations: see cross-reference table in that file -->
```

The cross-reference file tracks both spec-creation locations in its `producer_self_checks` section.

## Files Affected

| File | Change |
|------|--------|
| `.opencode/skills/spec-creation/SKILL.md` | Update description with holistic check trigger phrases; add holistic-self-check to dispatch table and invocation table |
| `.opencode/skills/spec-creation/tasks/create.md` | Add root cause analysis, alternatives considered, safety considerations, evidence/provenance, traceability table, feasibility assessment to spec template; add sync header comment |
| `.opencode/skills/spec-creation/tasks/completion.md` | Add pre-completion holistic self-check step (11 dimensions); add sync header comment |
| `.opencode/skills/spec-creation/tasks/holistic-self-check.md` | NEW — clean-room sub-agent evaluates spec against 11 dimensions from cross-reference file |
| `.opencode/tests/behaviors/spec-creation-holistic-gate.sh` | NEW — behavioral test for SC-13, SC-14 |

## Constraints

- The holistic self-check must be a clean-room sub-agent dispatch, not inline evaluation
- The self-check must use the same 11 dimensions defined in `.opencode/reference/holistic-dimensions.yaml` (#1850)
- The self-check must not modify the spec — only return PASS/FAIL with failed dimensions
- Existing spec-creation pipeline (brainstorming → spec-creation → audit) must not be disrupted
- The self-check is a pre-completion gate, not a replacement for the spec-audit
- Sync header comments must be present in create.md and completion.md

## Dependencies

- **#1850** — Defines the 11-dimension holistic gate and the central cross-reference file `.opencode/reference/holistic-dimensions.yaml`. This spec references that file for its template and self-check dimensions. Must be implemented after or concurrently with #1850.
- **#1666** — The spec that triggered the holistic gate work. Canonical example of what the Implementability dimension catches.

## Changelog

- v1 — Initial spec
- v2 — Added cross-reference sync: create and completion tasks reference `.opencode/reference/holistic-dimensions.yaml` via sync header comments. Added SC-15. Updated Dependencies to reference #1850's cross-reference file.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)