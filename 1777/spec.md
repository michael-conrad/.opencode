> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

The `spec-creation` and `writing-plans` skills produce specs and plans that are consumed by AI agents during implementation. Currently, the Persona sections describe the role (Spec Architect, Plan Author) but do not include an explicit admonishment that micro-management of implementing sub-agents is forbidden.

The existing DISPATCH_GATE sections in both skills already have Sub-Agent Entry Criteria that reject preloaded context (`PRELOADED_CONTEXT_REJECTED`). However, the Persona sections — which define the *mindset* of the spec/plan writer — lack a corresponding admonishment. This means the spec/plan writer may produce artifacts that over-prescribe implementation details (exact file paths, line numbers, step sequences, expected outcomes) rather than specifying WHAT and WHY.

Sub-agents are intelligent agents, not dumb terminals. They read specs and use skills autonomously. Specs and plans must describe requirements and intent — not prescribe implementation mechanics.

## Scope

**In scope:**
- Add micro-management prohibition admonishment to `spec-creation/SKILL.md` Persona section
- Add micro-management prohibition admonishment to `writing-plans/SKILL.md` Persona section

**Out of scope:**
- Changes to DISPATCH_GATE sections (already correct)
- Changes to task files (write.md, create.md)
- Changes to any other skill

## Fix Approach

Add the following admonishment to the Persona section of both `spec-creation/SKILL.md` and `writing-plans/SKILL.md`:

> **Micro-management prohibition:** The sub-agents that implement this spec/plan are intelligent agents, not dumb terminals. They read specs and use skills autonomously. Do not prescribe exact file paths, line numbers, step sequences, or expected outcomes. Specify WHAT and WHY — not HOW. The implementing agent discovers scope independently and produces its own result contract.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `spec-creation/SKILL.md` Persona section contains the micro-management prohibition admonishment | `string` | `grep -q "Micro-management prohibition" .opencode/skills/spec-creation/SKILL.md` |
| SC-2 | `writing-plans/SKILL.md` Persona section contains the micro-management prohibition admonishment | `string` | `grep -q "Micro-management prohibition" .opencode/skills/writing-plans/SKILL.md` |
| SC-3 | Admonishment text in both files matches the approved wording exactly | `string` | `grep -c "intelligent agents, not dumb terminals"` matches in both files |
| SC-4 | Behavioral test exists verifying that spec-creation agent includes the admonishment in generated specs | `behavioral` | `opencode-cli run` with spec-creation prompt, verify stderr contains the admonishment dispatch |

## Edge Cases

- **Existing specs/plans are not affected** — this change only affects newly generated specs and plans
- **The admonishment is additive** — it does not replace or modify existing Persona content

After this spec is approved, invoke `writing-plans` to create `.issues/{N}/plan.md` before implementation begins.

---

**Implemented in `feature/1777-micro-management-admonishment` branch.**
- SC-1 ✅: `spec-creation/SKILL.md` line 45 contains the admonishment blockquote
- SC-2 ✅: `writing-plans/SKILL.md` line 57 contains the admonishment blockquote
- SC-3 ✅: Both files have exact match for "intelligent agents, not dumb terminals"
- SC-4 ✅: Behavioral test script at `tests/behaviors/1777-sc4-micro-management-admonishment.sh`

🤖 Co-authored with AI: OpenCode (ollama/ornith:35b-256k)