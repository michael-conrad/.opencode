---
title: Remove dead BEHAVIOR_TIMEOUT variable from helpers.sh error messages
status: draft
created: 2026-07-15
license: MIT
provenance: AI-generated
issue: 1954
authors:
  - OpenCode (deepseek-v4-pro)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-15

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

`BEHAVIOR_TIMEOUT` is referenced on lines 341, 347, and 348 of `.opencode/tests-v2/behaviors/helpers.sh` but is never defined, never assigned, and never passed to `opencode run`. It exists only in error messages — it doesn't control any timeout. The bash tool has its own `timeout` parameter. `opencode run` has its own internal timeout. This variable controls nothing and only surfaces as a crash when `set -u` hits it during error reporting.

The crash at line 341 (`BEHAVIOR_TIMEOUT: unbound variable`) obscures the real error (empty model output) and prevents proper diagnosis.

## Root Cause Analysis

The variable `BEHAVIOR_TIMEOUT` was likely intended as a configurable timeout for behavioral test execution but was never wired into the actual `opencode run` invocation. The references in error messages are vestigial — they report a value that was never set, producing an unbound variable crash under `set -u` that masks the actual diagnostic information (model name, word count).

## Objectives

- Remove dead `BEHAVIOR_TIMEOUT` references from `helpers.sh` error messages
- Preserve useful diagnostic information (model name, word count) in error messages
- Ensure no other files in `.opencode/tests-v2/` reference the dead variable

## Goals

- `BEHAVIOR_TIMEOUT` is no longer referenced anywhere in `.opencode/tests-v2/`
- Error messages still report model name and word count for diagnosis
- No behavioral change to test execution — only error message cleanup

## Non-Goals

- **Adding a real timeout mechanism** — Out of scope. The bash tool and `opencode run` already have their own timeout mechanisms.
- **Changing test execution behavior** — This is a dead-code removal only.

## Constraints and Scope

- Only `.opencode/tests-v2/behaviors/helpers.sh` is modified
- Only error message strings are changed — no logic changes
- No new variables or timeout mechanisms are introduced

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|-------------------|
| Define and wire `BEHAVIOR_TIMEOUT` into `opencode run` | Adds complexity for a feature already handled by the bash tool's `timeout` parameter and `opencode run`'s internal timeout. Dead code removal is simpler and sufficient. |
| Replace with a hardcoded timeout value in the message | Misleading — the message would report a timeout value that doesn't control anything. |

## Safety Considerations

- No destructive operations — only string changes in error messages
- No data mutations or security-sensitive changes
- Rollback: revert the commit

## Affected Files

| File | Lines | Change |
|------|-------|--------|
| `.opencode/tests-v2/behaviors/helpers.sh` | 341, 347, 348 | Remove `BEHAVIOR_TIMEOUT` references from error messages |

## Fix

Remove the three references to `BEHAVIOR_TIMEOUT` from the error messages on lines 341, 347, and 348 of `helpers.sh`. The messages MUST still report the model name and word count for diagnosis.

Line 341: Change from `echo "  BEHAVIOR_TIMEOUT=$BEHAVIOR_TIMEOUT, BEHAVIOR_MODEL=$model"` to `echo "  BEHAVIOR_MODEL=$model"`.

Line 347: Change from referencing `BEHAVIOR_TIMEOUT` in the advisory message to a message that does not reference the dead variable.

Line 348: Change from `echo "  BEHAVIOR_TIMEOUT=$BEHAVIOR_TIMEOUT, BEHAVIOR_MODEL=$model"` to `echo "  BEHAVIOR_MODEL=$model"`.

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. See `080-code-standards.md` Test Integrity Mandate.

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| None | — | No known dependencies |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `BEHAVIOR_TIMEOUT` is no longer referenced anywhere in `helpers.sh` | `string` | `grep -c "BEHAVIOR_TIMEOUT" .opencode/tests-v2/behaviors/helpers.sh` returns 0 |
| SC-2 | Error messages on lines 341 and 348 still report useful diagnostic info (model name, word count) without the dead variable | `string` | `grep "BEHAVIOR_MODEL" .opencode/tests-v2/behaviors/helpers.sh` returns matches; `grep "BEHAVIOR_TIMEOUT" .opencode/tests-v2/behaviors/helpers.sh` returns 0 |
| SC-3 | No other files in `.opencode/tests-v2/` reference `BEHAVIOR_TIMEOUT` | `string` | `grep -r "BEHAVIOR_TIMEOUT" .opencode/tests-v2/` returns 0 matches |
| SC-4 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation | `behavioral` | Audit confirms all SCs are implemented at declared evidence types |

## SC-to-Root-Cause Traceability

| SC | Root Cause Element |
|----|--------------------|
| SC-1 | Vestigial variable reference in error message |
| SC-2 | Diagnostic information must survive cleanup |
| SC-3 | Dead variable may exist in other files |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep -r "BEHAVIOR_TIMEOUT" .opencode/tests-v2/` | Confirm all references to dead variable |
| Direct source read | `read .opencode/tests-v2/behaviors/helpers.sh` lines 335-355 | Verify exact line content and context |

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1954/plan.md` before implementation begins.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

🤖 Co-authored with AI: OpenCode (deepseek-v4-pro)
