> **Full spec and artifacts: `.opencode/.issues/1010/`**

## Exec Summary

The orchestrator agent reads task `.md` files and inlines procedural steps instead of dispatching blind to sub-agents via `task()`. This produces poisoned work that must be discarded. Root cause is a compound defect: 45k words pre-loaded at session start, prose format activates "read, interpret, decide" instead of "discharge obligation," no behavioral test catches inline dispatch, and skill() call does not flush cached task file knowledge. Z3 formally proved the dependency chain.

### Cards (dependency order)
1. **Phase 1a: Fix pre-read cascade (#1003)** — trim guidelines, instruction sandwich, word count target
2. **Phase 1b: skill() cache flush** — opencode CLI requirement (Z3 counterexample proved)
3. **Phase 2: Checklist format conversion (#958, #863, #909)** — 38 skills batch migration

### Key Decisions
- **Z3-proved dependency ordering** — strict prerequisite chain, each phase requires all prior
- **Hybrid checklist pattern** — SKILL.md skeleton + self-generated tmp/ decomposition in sub-agents

### Risk Callouts
- **skill() cache flush requires opencode CLI change** — upstream dependency on anomalyco/opencode
- **Behavioral tests required** — cannot validate without real agent execution

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/1010/`.
After creation, `local-issues sync 1010` MUST be run and the result committed to create the local `.issues/1010/` entry.
The implementation plan will be created in `.issues/1010/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

---
*Migrated from local tracking. Original local directory: `.opencode/.issues/1010/`*