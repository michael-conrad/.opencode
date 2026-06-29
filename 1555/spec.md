# [SPEC-FIX] Remove 'auditor unavailable' dual-auditor bypass escape hatch in adversarial-audit

**Issue:** https://github.com/michael-conrad/.opencode/issues/1555

## Executive Summary

Remove the "Auditor unavailable → Use fallback chain per multimodal-dispatch" escape hatch from spec-audit and verification-audit tasks. Strengthen resolve-models to return BLOCKED if < 2 auditors found. Add auditor count check before dispatch.

## Problem

The fallback chain allows the agent to bypass the dual-auditor requirement by claiming an auditor is "unavailable." This violates `adversarial-audit-009` (Tier 2) which requires dual cross-family auditor consensus at pipeline gates.

## Fix (3 changes)

1. Remove "Use fallback chain per multimodal-dispatch" from `spec-audit.md:328` and `verification-audit.md:222`. Replace with: "Auditor unavailable → HALT. Report BLOCKED with AUDITOR_UNAVAILABLE. Do NOT proceed with single-auditor or fallback."

2. `resolve-models` script: if it cannot find 2 auditors from different families, return `status: BLOCKED, reason: RESOLVE_MODELS_INSUFFICIENT` instead of a partial result.

3. Consuming tasks (spec-audit, verification-audit): add explicit check before dispatch — if `len(auditors) < 2`, HALT with `AUDITOR_COUNT_INSUFFICIENT` before even attempting dispatch.

## Files Affected

- `adversarial-audit/tasks/spec-audit.md` line 328
- `adversarial-audit/tasks/verification-audit.md` line 222
- `.opencode/tools/resolve-models`
- `adversarial-audit/tasks/spec-audit.md` — add auditor count check
- `adversarial-audit/tasks/verification-audit.md` — add auditor count check

## Behavioral Test

Simulate auditor unavailability scenario. Assert agent HALTs with BLOCKED, does not proceed with single-auditor or fallback chain.

## Dependencies

None.
