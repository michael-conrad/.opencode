# [SPEC-FIX] Implement behavioral test stubs and clean up validate_skill_cards.py comments

> **Part of:** `.opencode#1899` (skill descriptions for agent-intent dispatch)
> **Spec type:** SPEC-FIX
> **Status:** DRAFT

## Problem

The implementation of `.opencode#1899` (skill descriptions for agent-intent dispatch) created 4 behavioral test skeleton files at `.opencode/tests/behaviors/agent-intent-*.sh` that are all TODO stubs — they have no actual test implementation. The spec's SC-7 requires behavioral enforcement tests verifying the agent dispatches skills based on internal intent (not user utterance matching), with `assert_semantic` clean-room evaluation. The stubs were created in Phase 3 but never filled in.

Additionally, `validate_skill_cards.py` lines 165 and 237 contain comments referencing `# User phrases:` — a cosmetic remnant of the old pattern. These are comments only (not validation logic) and have no behavioral impact, but should be cleaned up.

## Solution

### Phase 1: Implement 4 behavioral tests

Implement the 4 TODO stubs at:
- `.opencode/tests/behaviors/agent-intent-audit-dispatch.sh` — agent dispatches audit skill when it detects a need for verification (no user said "audit")
- `.opencode/tests/behaviors/agent-intent-gate-dispatch.sh` — agent dispatches mandatory gate skill (e.g., verification-before-completion) without user saying "verify"
- `.opencode/tests/behaviors/agent-intent-rewrite-description.sh` — agent produces description in canonical agent-intent pattern (no user-phrase list)
- `.opencode/tests/behaviors/agent-intent-template-dispatch.sh` — agent dispatches correct skill based on agent-intent, not user utterance

Each test must:
1. Use `behavior_run` with a real-domain prompt (no interview-style prose-recall prompts)
2. Use `assert_semantic` as the primary assertion (per 080-code-standards.md Rule 5)
3. Use `assert_stderr_pattern_present` as secondary corroboration only
4. Follow the pattern from existing tests like `stacked-pr-organization.sh`

### Phase 2: Clean up validate_skill_cards.py comments

Update lines 165 and 237 in `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` to remove the `# User phrases:` comment references.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | All 4 agent-intent-*.sh tests have real behavioral test implementations (not TODO stubs) | behavioral |
| SC-2 | Each test uses `assert_semantic` as primary assertion for behavioral SCs | string |
| SC-3 | Each test uses a real-domain prompt (not interview-style prose-recall) | structural |
| SC-4 | validate_skill_cards.py lines 165 and 237 no longer reference `User phrases:` | string |
| SC-5 | All 4 tests pass when run via `bash .opencode/tests/with-test-home` wrapper | behavioral |

## Affected Files

| File | Change | Phase |
|------|--------|-------|
| `.opencode/tests/behaviors/agent-intent-audit-dispatch.sh` | Implement behavioral test | 1 |
| `.opencode/tests/behaviors/agent-intent-gate-dispatch.sh` | Implement behavioral test | 1 |
| `.opencode/tests/behaviors/agent-intent-rewrite-description.sh` | Implement behavioral test | 1 |
| `.opencode/tests/behaviors/agent-intent-template-dispatch.sh` | Implement behavioral test | 1 |
| `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` | Remove `# User phrases:` comments | 2 |

## Revision History

| Date | Revision | Author | Description |
|------|----------|--------|-------------|
| 2026-07-13 | 1 | AI | Initial spec-fix creation |
