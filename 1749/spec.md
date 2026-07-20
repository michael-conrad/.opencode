> **Full spec and artifacts: `.opencode/.issues/854/`**

## Exec Summary

Implement 8 issues across 6 layers in 5 sequential phases. Each phase produces a self-contained PR that depends structurally on the previous phase. The plan defines phase boundaries, sub-issue linkage, SC pass-through, and handoff contracts between spec-upstream and plan-downstream artifacts. Layers span Reference Cards (#848, #853), Policy (#849), Enforcement Style + Structure (#850, #1060), Artifact Infrastructure (#1061), Boundary Gates (#1062), and Pipeline + Plan Enforcement (#1063, #1064).

### Cards (dependency order)
1. **Phase 1 Foundation: Reference cards (#848, #853) + co-application policy (#849) — 57 SCs**
2. **Phase 2 Structure: Spec-creation write.md expansion (#1060) — 12 SCs**
3. **Phase 3 Artifacts: SC coverage YAML, solve contracts, lifecycle manifest (#1061) — 10 SCs**

### Key Decisions
- **5 sequential phases with strict dependency ordering** — Phase N+1 requires Phase N merged
- **Sub-issue linkage per phase** — each phase has its own PR branch and sub-issues

### Risk Callouts
- **Phase sequencing strictly enforced** — no Phase N+1 before Phase N merge
- **57 SCs in Phase 1** — coordination complexity across 3 sub-issues

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/854/`.
After creation, `local-issues sync 854` MUST be run and the result committed to create the local `.issues/854/` entry.
The implementation plan will be created in `.issues/854/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

---
*Migrated from local tracking. Original local directory: `.opencode/.issues/854/`*