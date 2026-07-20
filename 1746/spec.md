> **Full spec and artifacts: `.opencode/.issues/364/`**

## Exec Summary

Add a `content-audit` task to the adversarial-audit skill that performs dual cross-family verification of factual claims in generated content, then wire it into verification-enforcement's `verify` task. Auditors receive only `{ document_section, source_data_paths }` — no orchestrator preload.

### Cards (dependency order)
1. **Add `content-audit` task to adversarial-audit SKILL.md** (Trigger Dispatch Table + Invocation section)
2. **Create `content-audit.md` task file** with clean-room protocol, dual auditors, per-claim verdicts
3. **Wire into verification-enforcement `verify` task** — dispatch to adversarial-audit instead of single sub-agent
4. **Create behavioral enforcement test** (`content-audit-fabricated-claim.sh`)

### Key Decisions
- **Clean-room protocol** — auditors receive only `{ document_section, source_data_paths }`. No orchestrator preload. `PRELOADED_CONTEXT_REJECTED` on violation.
- **Dual cross-family auditors** — dispatched via `resolve-models`. Cross-validate for consensus.

### Risk Callouts
- **Auditor independence** — if auditors share context, cross-validation is meaningless
- **Conflicting verdicts** — need consensus mechanism when auditors disagree on claim validity

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/364/`.
After creation, `local-issues sync 364` MUST be run and the result committed to create the local `.issues/364/` entry.
The implementation plan will be created in `.issues/364/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

---
*Migrated from local tracking. Original local directory: `.opencode/.issues/364/`*