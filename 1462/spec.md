# [SPEC-FIX] Writing-plans skill: document plan tool applicability domain boundaries

## Problem

The `plan` tool (`opencode/tools/plan`) is a YAML classical planning engine — it operates on action schemas with preconditions and effects, grounded in PDDL. The writing-plans skill produces markdown implementation plans with phases, concerns, SC tables, and checkbox steps. These are **different domains with different representations** — there is no YAML bridge between them.

The `plan` tool was never invoked during the writing-plans pipeline for [SPEC-FIX] #1457, nor would it have produced meaningful output, because:
- The pipeline produces human-readable markdown, not YAML action schemas
- The plan tool's representation (stateful actions with Z3-verified transitions) does not map to the pipeline output (ordered phases with checklists)
- The `skildeck` tool already provides the formal skill-dispatch analysis that a classical planner would provide for this domain

This was documented as **Lesson 8** in the session-2026-06-27 lessons learned — the `plan` tool has a domain mismatch with the writing-plans pipeline and the writing-plans skill gives no guidance on when the tool is applicable.

## Related

- Lesson 8: `opencode/.issues/lessons-learned/session-2026-06-27/README.md`
- #1050 plan tool YAML validation (closed)
- #1141 solve prove crash on dict-format preconditions (closed)
- #1320 writing-plans Z3 contract decomposition (open)

## Proposed Approach

1. **Document the plan tool's domain in writing-plans SKILL.md**: Add a "Related Tools" section after the Trigger Dispatch Table explaining:
   - What the plan tool does: YAML action schema planning with Z3-verified state transitions
   - When it applies: multi-agent workflows, sub-agent routing graphs, tool-dispatch DAGs, formal state validation
   - When it does NOT apply: ordered phase checklists, markdown plan authoring, human-readable spec breakdowns

2. **No code changes to plan tool**: The tool is correct within its domain. The fix is documentation only — preventing future agents from reaching for the wrong tool.

3. **No changes to writing-plans task files**: The pipeline steps that reference `plan plan` for phase solvability validation remain — they fire `solve check` for contract validity, which is what they should do (see sibling spec #1461). The documentation makes clear that this is contract checking, not classical planning.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | writing-plans SKILL.md has a "Related Tools" section | `structural` |
| SC-2 | Section describes plan tool's domain (YAML action schemas, PDDL, Z3 transitions) | `string` |
| SC-3 | Section provides when-to-use / when-not-to-use guidance | `string` |
| SC-4 | Section cross-references skildeck tool as the formal analysis tool for dispatch routing | `string` |
| SC-5 | Section references Lesson 8 from session-2026-06-27 | `string` |

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash-free)
