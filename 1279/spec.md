> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

**Problem Statement:** When agents modify skill cards (SKILL.md) or task cards (task `.md` files), there is no standardized taxonomy for classifying the type of change being made, causing inconsistent spec writing, no remediation reference, no audit classification, no impact analysis, and no workflow validation mandate.

**Key Design Decisions:**
- Taxonomy is a reference document, not enforcement gates (except workflow validation)
- All 10 types share the same field structure for consistency
- Workflow validation is mandatory for ALL types regardless of blast radius

## Fix Approach

### Phase 2: Add cross-references

Add a cross-reference from `spec-creation/SKILL.md` and `writing-plans/SKILL.md` to the taxonomy document in their Cross-References sections.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Phase Binding |
|----|-----------|---------------|---------------------|---------------|
| SC-7 | spec-creation/SKILL.md Cross-References references the taxonomy document | `string` | `grep -q "skill-card-change-types" .opencode/skills/spec-creation/SKILL.md` | Phase 2 |
| SC-8 | writing-plans/SKILL.md Cross-References references the taxonomy document | `string` | `grep -q "skill-card-change-types" .opencode/skills/writing-plans/SKILL.md` | Phase 2 |

## Phase-Scoped Compliance

Implementation is complete for a given phase ONLY when ALL SCs bound to that phase pass verification. Phase-scoped evaluation means auditors verify only the SCs whose Phase Binding matches the current pipeline phase.

---

🤖 OpenCode (deepseek-v4-flash)
