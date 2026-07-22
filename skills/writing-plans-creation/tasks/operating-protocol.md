# Writing Plans — 22-Step Pipeline

## Entry Criteria

- Approved spec exists with `[SPEC]` prefix
- Spec issue body contains success criteria table with evidence types
- Analytical artifacts generated (blast radius, concern map, code path inventory, cross-cutting matrix, interface compatibility, state analysis, testability assessment)

## Procedure

1. **Load spec** — Read the approved spec issue body, extract success criteria, evidence types, and constraints
2. **Load analytical artifacts** — Read all 7 analytical artifacts from `{N}/artifacts/`
3. **Define phase structure** — Decompose work into phases based on concern boundaries, each phase addressing one concern
4. **Define TDD items** — For each phase, define RED/GREEN items corresponding to code paths and testability requirements
5. **Run Z3 solve** — Validate phase ordering and dependency DAG via `./.opencode/tools/solve`
6. **Write plan index** — Create `{N}/plan.md` with phase table, goal, architecture, admonishments, exit criteria
7. **Write phase files** — Create `{N}/plan-{NN}-{slug}.md` per phase with metadata, steps, dispatch indicators
8. **Validate plan** — Run all validation checks (placeholders, completeness, dispatch markers, structural compliance)
9. **Sync cross-reference** — Update spec issue body with plan reference URL
10. **Apply approval cascade** — Apply approval labels per authorization scope
11. **Run holistic self-check** — Evaluate plan against all 11 dimensions
12. **Report** — Generate executive summary in chat with plan URL
13. **Hand off** — Route to next pipeline stage (audit or implementation)

### Retroactive Protocol

When creating a plan retroactively for an existing spec that was implemented without a plan:

1. Read the existing spec and codebase state
2. Reconstruct phase structure from implemented changes
3. Document what was implemented, not what should be implemented
4. Mark as retroactive in the plan metadata
5. Do NOT create sub-issues or approval markers for retroactive plans

## Exit Criteria

- Plan index exists at `{N}/plan.md` with complete phase table
- Phase files exist at `{N}/plan-{NN}-{slug}.md` for each phase
- All 22 pipeline steps completed or verified as already done
- Plan validated against all checks
- Holistic self-check passed (all 11 dimensions)
- Approval cascade applied per authorization scope
- Executive summary posted to chat with plan URL

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "..." |
| artifact_path | ".../artifacts/operating-protocol.yaml" |
| blocker_reason | "..." |
