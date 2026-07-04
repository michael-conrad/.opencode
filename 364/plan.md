# Plan: Add adversarial content-audit task (#364)

## Goal

Add a `content-audit` task to the adversarial-audit skill that performs dual cross-family verification of factual claims in generated content, then wire it into verification-enforcement's `verify` task.

## Architecture

- **adversarial-audit** gains a new `content-audit` task (parallel to existing `verification-audit`, `spec-audit`, etc.)
- **verification-enforcement** `verify` task dispatches to `content-audit` instead of single sub-agents
- Clean-room protocol: dual cross-family auditors, no orchestrator preload, `PRELOADED_CONTEXT_REJECTED` on violation

## Files

| File | Action |
|------|--------|
| `.opencode/skills/adversarial-audit/SKILL.md` | Add `content-audit` to Trigger Dispatch Table and Invocation section |
| `.opencode/skills/adversarial-audit/tasks/content-audit.md` | Create new task file |
| `.opencode/skills/verification-enforcement/tasks/verify.md` | Update to dispatch adversarial-audit instead of single sub-agent |
| `.opencode/tests/behaviors/content-audit-fabricated-claim.sh` | Create behavioral enforcement test |

## Phase Table

| Phase | Concern | Files | Steps |
|-------|---------|-------|-------|
| 1 | Add content-audit task to adversarial-audit | SKILL.md, content-audit.md | 1-4 |
| 2 | Wire into verification-enforcement verify task | verify.md | 5 |
| 3 | Behavioral enforcement test | content-audit-fabricated-claim.sh | 6 |

## Exit Criteria

- adversarial-audit SKILL.md has `content-audit` in dispatch table
- `content-audit.md` task file exists with clean-room protocol, dual auditors, per-claim verdicts
- `verify.md` dispatches to `adversarial-audit --task content-audit`
- Behavioral test exists and passes

## Admonishments

- **Clean-room protocol**: Auditors receive only `{ document_section, source_data_paths }`. No orchestrator preload. `PRELOADED_CONTEXT_REJECTED` on violation.
- **No GitHub routing fields**: Content audit verifies against local source data, not GitHub issues.
- **Dual cross-family auditors**: Dispatched via `resolve-models`. Cross-validate for consensus.
