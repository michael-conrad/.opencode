> **Full spec and artifacts: `.opencode/.issues/1617/`**

## Exec Summary

During execution of spec #492, four systemic enforcement gaps were discovered in the pipeline infrastructure. These are not #492-specific — they affect every plan execution. Gap 1: contract path mismatch — Z3 check steps reference non-existent YAML files (dead code). Gap 2: step skipping on FAIL without remediation — orchestrator skipped enforcement gates after RED phase. Gap 3: RED phase deliverable defects — echo statements, undefined variables, hardcoded URLs in behavioral test script. Gap 4: sub-agent dispatch without task file discovery directive.

### Cards (dependency order)
1. **Create implementation-pipeline contracts** — 5 YAML files for Z3 check gates
2. **Enforce remediation-first on step failure** — pipeline-level rule, pre-flight contract check
3. **Fix RED phase deliverable defects** — remove echo, derive paths dynamically, content-verification test
4. **Fix canonical dispatch strings** — append discovery directive to all SKILL.md invocation tables

### Key Decisions
- **Self-contained fix spec** — does not depend on #492 (the spec that exposed these gaps)
- **Contract files follow writing-plans schema** — variables + constraints YAML format

### Risk Callouts
- **Dead Z3 check code** — every plan's steps 4, 6, 8, 10, 12 reference non-existent contract files
- **Two test fixture repos available** — `test-submodule-1` and `test-submodule-2` for behavioral tests with real remotes

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/1617/`.
After creation, `local-issues sync 1617` MUST be run and the result committed to create the local `.issues/1617/` entry.
The implementation plan will be created in `.issues/1617/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

---
*Migrated from local tracking. Original local directory: `.opencode/.issues/1617/`*