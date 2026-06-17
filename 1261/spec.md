# Spec: Spec writer must embed compliance requirement notice in all generated specs

STATUS: 1.1
CREATED: 2026-06-17

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

**Problem Statement:** The spec-creation `write.md` task already has the compliance requirement blockquote in its procedure steps (Step 1 and Step 2), but the generated spec body does not include it. Future specs created by the spec writer will lack the compliance requirement notice unless the writer is updated to embed it.

**Root Cause / Motivation:** The `write.md` task file references the compliance requirement blockquote in its procedure text but does not include it in the spec body template that gets generated. The blockquote exists as instructions to the agent writing the spec, not as content in the spec itself.

**Approach Chosen:** Add the compliance requirement blockquote to the spec body template at two positions: at the top (after STATUS/CREATED header) and before the success criteria table.

**Alternatives Considered & Why Discarded:** Adding it only at the top — the write.md procedure already specifies two positions (Step 1: "at the top" and Step 2: "before the success criteria table"). Both positions are required.

**Key Design Decisions:**
- Two positions match the existing write.md procedure language
- Existing specs are grandfathered — only newly generated specs are affected

---

## Phase 1: Template Update (Gated)

### Steps
1. ☐ Add compliance requirement blockquote to spec body template at top position (after STATUS/CREATED header)
2. ☐ Add compliance requirement blockquote to spec body template at bottom position (before success criteria table)

### Content

**File:** `.opencode/skills/spec-creation/tasks/write.md`

**Changes:**
1. In the spec body template section (where the generated spec content is assembled), add the compliance requirement blockquote immediately after the STATUS/CREATED header
2. Add the same blockquote immediately before the success criteria table

The blockquote text:
```
> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.
```

### Success Criteria

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Compliance requirement blockquote appears at top of generated spec body (after STATUS/CREATED header) | `string` | `grep -c "Compliance Requirement" .opencode/skills/spec-creation/tasks/write.md` → must output at least 2 |
| SC-2 | Compliance requirement blockquote appears before success criteria table in generated spec body | `string` | `grep -c "Compliance Requirement" .opencode/skills/spec-creation/tasks/write.md` → must output at least 2 |
| SC-3 | Existing specs are not modified by this change | `structural` | `git diff --name-only` → only `write.md` changed |

### Edge Cases

| Case | Behavior |
|------|----------|
| Spec has no success criteria table | Blockquote still appears at top position; bottom position omitted |
| Spec is minimal (no STATUS/CREATED header) | Blockquote appears at the very top of the spec body |

### Regression Invariants

- [ ] Existing spec generation behavior is unchanged
- [ ] The write.md procedure steps are not modified — only the spec body template

### Non-Goals

- Updating existing specs to include the compliance notice — out of scope
- Changing the compliance requirement text itself — out of scope

---

**Documentation Sources:**
| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `read .opencode/skills/spec-creation/tasks/write.md` | Verify current spec body template and compliance requirement references |
| Direct source search | `grep "Compliance Requirement" .opencode/skills/spec-creation/tasks/write.md` | Confirm blockquote exists in procedure but not in generated template |

🤖 OpenCode (ollama-cloud/deepseek-v4-pro) created
