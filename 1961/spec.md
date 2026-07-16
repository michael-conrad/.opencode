# [SPEC] Rewrite SKILL.md Descriptions to Agent-Intent-Oriented Pattern

**STATUS:** DRAFT
**CREATED:** 2026-07-16

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1961/plan.md` before implementation begins.

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. See `080-code-standards.md` Test Integrity Mandate.

## Problem Statement

All 60 SKILL.md files have `description` frontmatter fields written as if the opencode runtime parses trigger phrases and auto-dispatches skills. In reality, the runtime (`packages/core/src/skill.ts`) only recognizes three frontmatter fields: `name`, `description`, `slash`. The `description` is rendered verbatim into the `<available_skills>` XML block in the system prompt. The LLM reads it and decides whether to call `skill()`. There is zero trigger-phrase matching in the runtime.

Additionally, the "Dispatch when" language in descriptions maps to the wrong action. The description triggers `skill()` (loading routing metadata into orchestrator context), not `task()` (dispatching work to a sub-agent). The orchestrator loads a skill, reads its Trigger Dispatch Table, then dispatches task cards — it never "dispatches" a skill. Descriptions should say "Load via skill() when..." to match the actual two-step protocol.

The current description pattern enforced by `validate_skill_cards.py` is: `"<Noun phrase>. Dispatch when <agent-facing trigger conditions>. Also dispatch when <additional trigger conditions>. <Enforcement statement>. User phrases: <comma-separated list>."`

This is defective because:
1. It is written for a keyword matcher that does not exist
2. It trains the LLM to pattern-match user words instead of reasoning about its own intent
3. The "User phrases:" section is supplementary — the runtime never reads it
4. The LLM needs to self-route based on what it has decided to do, not what the user happened to say
5. "Dispatch when" language maps to the wrong action — the description triggers `skill()` (loading routing metadata), not `task()` (dispatching work to a sub-agent). The description should say "Load via skill() when..." to match the actual protocol.

### Evidence

Verified by reading `session-enforcement.ts` `loadSkillDescriptions()` function:
- `loadSkillDescriptions()` reads `name` and `description` from frontmatter and renders them into the `<available_skills>` XML block
- `extractFrontmatter()` only parses `name`, `description`, `slash` — no other fields are recognized
- The frontmatter validation checks for missing `name` or `description` fields — it does NOT validate description content patterns
- The "Use when" / "Dispatch when" content validation is in `validate_skill_cards.py` `validate_req1()`, not in `session-enforcement.ts`

## Root Cause / Motivation

The "Dispatch when" pattern was introduced as a replacement for the deprecated "Use when" farmage pattern, but it inherited the same fundamental defect: it describes what the agent should do when it dispatches the skill, when the actual action is loading the skill via `skill()`. The runtime renders descriptions verbatim into the `<available_skills>` block — there is no trigger-phrase matching. The LLM reads the description and decides whether to call `skill()`. The description must tell the LLM when to call `skill()`, not when to "dispatch" something.

## Approach Chosen

Rewrite all 60 SKILL.md descriptions from the "Dispatch when" pattern to a "Load via skill() when" pattern. The change is mechanical and content-only — no runtime modifications needed. Update all 5 tooling files (validator, template, reference docs) in coordination. Write behavioral enforcement tests first (Phase 0) to confirm RED state before any changes.

## Alternatives Considered & Why Discarded

| Alternative | Why Discarded |
|-------------|---------------|
| Keep "Dispatch when" and update only the tooling documentation to clarify the semantics | Does not fix the root cause — the LLM reads "dispatch" and maps it to `task()`, not `skill()`. Semantic clarification in docs does not change the description text the LLM reads. |
| Add a new frontmatter field (e.g., `trigger_on`) for the runtime to parse | The runtime only recognizes `name`, `description`, `slash` — adding new fields requires runtime changes, which is out of scope. |
| Rewrite descriptions only, skip tooling updates | Tooling (`validate_skill_cards.py`) enforces "Dispatch when" — descriptions would fail validation. Tooling must be updated in lockstep. |

## Key Design Decisions

| DEC-ID | Decision | Rationale |
|--------|----------|-----------|
| DEC-1 | Use "Load via skill() when" verbatim | Matches the actual API call the LLM makes (`skill({name: "..."})`). Eliminates the "dispatch" → `task()` mapping error. |
| DEC-2 | Accept both old and new patterns during transition | Prevents validation breakage when descriptions are rewritten incrementally. Validator accepts "Dispatch when" OR "Load via skill() when" during Phase 1-2, then requires "Load via skill() when" exclusively after Phase 3. |
| DEC-3 | Behavioral test before any description changes (Phase 0) | Ensures RED state is confirmed before GREEN — prevents false PASS from pre-existing conditions. |

## Scope

**In scope:**
- Rewrite all 60 SKILL.md `description` frontmatter fields to agent-intent-oriented prose using "Load via skill() when" language
- Update `validate_skill_cards.py` to accept "Load via skill() when" pattern (and both old/new during transition)
- Update `session-enforcement.ts` comment in `loadSkillDescriptions()` to reference new pattern
- Update `init_skill.py` template to use new pattern
- Update `routing-only-template.md` to document new pattern
- Update `skill-card-spec.md` to document new pattern
- Write behavioral enforcement tests for the new pattern

**Out of scope:**
- Task card files (299 files) — they use `## Purpose` headings, not YAML frontmatter descriptions
- Guideline files (31 files) — they use `trigger_on` frontmatter, not `description` fields
- Adding new frontmatter fields — the runtime only recognizes `name`, `description`, `slash`
- Changing how the runtime processes descriptions — this is a content-only change

## New Description Pattern

The description MUST lead with agent-intent language: what the skill does and when the agent should call `skill()` to load it. User trigger phrases follow as supplementary information appended after the agent-facing content.

### Pattern Specification

```
<Agent-intent statement>. Load via skill() when <agent-decision conditions>. <Enforcement statement>. User phrases: <comma-separated list>.
```

### Components

| Component | Purpose | Required? |
|-----------|---------|-----------|
| Agent-intent statement | What the skill does — the agent's role when it loads this skill (1 sentence) | Yes |
| Load conditions | When the agent should call `skill()` to load this skill's routing metadata (1-2 sentences) | Yes |
| Enforcement statement | Mandatory/REQUIRED language about the skill's discipline | Yes |
| User phrases | Comma-separated list of natural language phrases a user might say | Yes |

### Before/After Example

**BEFORE (current pattern):**
> "Use when creating a branch, committing, pushing, or creating a PR. Also use when handling rebase/merge conflicts (invoke conflict-resolution), checking PR state and cleanup, or running provenance tracking. Invoke for: branch creation, commit, push, PR creation, rebase, merge, conflict resolution dispatch, PR state verification, cleanup, provenance tracking, submodule sync. Branch-and-PR discipline is REQUIRED — always follow the workflow. Trigger phrases: create branch, commit, push, create PR, rebase, merge, check pr, check prs, check merged prs, pr merged, provenance, sync submodules, release PR."

**AFTER (new pattern):**
> "Branch, commit, push, and PR lifecycle management. Load via skill() when the agent needs to create a feature branch, commit changes, push to remote, create a pull request, handle rebase or merge operations, verify PR state, clean up merged branches, sync submodules, or track provenance. Also load when a PR has been merged and cleanup is needed. Branch-and-PR discipline is REQUIRED — always follow the workflow. User phrases: create branch, commit, push, create PR, rebase, merge, check pr, check prs, check merged prs, pr merged, provenance, sync submodules, release PR."

### Key Differences

| Aspect | Old Pattern | New Pattern |
|--------|-------------|-------------|
| Opening | "Use when" (user-facing) | Agent-intent statement (agent-facing) |
| Structure | "Use when... Also use when... Invoke for:... Trigger phrases:" | "Statement. Load via skill() when... Enforcement. User phrases:" |
| Trigger phrases | "Trigger phrases:" prefix | "User phrases:" prefix |
| Task list | "Invoke for:" (redundant with load conditions) | Integrated into load conditions |
| Action verb | "Dispatch when" (maps to `task()`) | "Load via skill() when" (maps to `skill()`) |
| Mental model | "Did the user say one of these magic words?" | "Should I call skill() to load this skill's routing metadata?" |

### Constraints

- MUST fit within the existing `description` frontmatter field (no new fields)
- MUST NOT exceed 1024 characters (existing `validate_skill_cards.py` SC-LINT-004 limit)
- MUST include mandatory keyword (MUST/REQUIRED/always/not optional/mandatory) per SC-LINT-002
- MUST NOT contain narrative-only sentences per SC-LINT-003
- MUST NOT contain angle brackets per REQ-1
- Exclusion clauses (`— distinct from <exclusion>`) retained for skills that could false-match

## Affected Files

### SKILL.md Files (60 files)

All files in `.opencode/skills/*/SKILL.md` and `.opencode/skills/*/platforms/*/SKILL.md`.

### Validation and Tooling Files

| File | Change Required |
|------|----------------|
| `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` | Update `validate_req1()` to accept "Load via skill() when" pattern alongside "Dispatch when" during transition, then require "Load via skill() when" exclusively |
| `.opencode/plugins/session-enforcement.ts` | Update `loadSkillDescriptions()` comment to reference new pattern |
| `.opencode/skills/skill-creator/scripts/init_skill.py` | Update template to use new pattern |
| `.opencode/skills/skill-creator/reference/routing-only-template.md` | Update description format documentation |
| `.opencode/skills/skill-creator/reference/skill-card-spec.md` | Update description format documentation |

### Behavioral Enforcement Tests

New test file: `.opencode/tests-v2/behaviors/skill-description-pattern.sh`

This file MUST be created as a prerequisite before any description rewrites begin (Phase 0). It verifies the agent dispatches skills correctly with the new descriptions.

## Implementation Approach

The rewrite is a content-only change to the `description` frontmatter field in 60 SKILL.md files. No runtime code changes are needed — the runtime already renders descriptions verbatim. The validation scripts must be updated to accept the new pattern.

The rewrite follows a mechanical transformation:
1. Remove "Use when" / "Also use when" / "Invoke for:" prefixes
2. Restructure into agent-intent statement + load conditions + enforcement + user phrases
3. Change "Trigger phrases:" to "User phrases:"
4. Change "Dispatch when" to "Load via skill() when" — the description triggers `skill()`, not `task()`
5. Preserve enforcement statements and exclusion clauses

### Phase 0: Prerequisites
- [ ] 1. Create behavioral enforcement test file at `.opencode/tests-v2/behaviors/skill-description-pattern.sh` — `sub-agent`
- [ ] 2. Confirm RED state: run test, verify it fails before any description changes — `sub-agent`

### Phase 1: Tooling Updates
- [ ] 1. Update `validate_skill_cards.py` to accept "Load via skill() when" pattern (accept both old and new during transition) — `sub-agent`
- [ ] 2. Update `session-enforcement.ts` comment in `loadSkillDescriptions()` — `sub-agent`
- [ ] 3. Update `init_skill.py` template — `sub-agent`
- [ ] 4. Update `routing-only-template.md` documentation — `sub-agent`
- [ ] 5. Update `skill-card-spec.md` documentation — `sub-agent`

### Phase 2: Description Rewrites
- [ ] 1. Rewrite all 60 SKILL.md descriptions to new pattern — `sub-agent`
- [ ] 2. Run validation after each batch to catch errors early — `sub-agent`

### Phase 3: Verification
- [ ] 1. Run `validate_skill_cards.py` on all 60 files — must exit 0 — `sub-agent`
- [ ] 2. Run behavioral enforcement test — must PASS (GREEN state) — `sub-agent`
- [ ] 3. Run `with-test-home opencode run "list skills"` — verify no frontmatter warnings — `sub-agent`

## SC Enforcement Gate

All 13 SCs must achieve 100% clean PASS. If any SC fails, the implementation is rejected and must be reworked from scratch. No SC may be waived, deferred, or skipped. This gate is enforced at Phase 3 verification.

## Dependencies

- No external dependencies
- No runtime changes required
- Validation script changes must be coordinated with description rewrites to avoid false validation failures
- Behavioral test file must be created before any description changes (Phase 0)

## Risk and Edge Cases

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| LLM routing regression | Low | High | Behavioral tests verify agent still dispatches correctly with new descriptions |
| Validation breakage during transition | High | Medium | Update validator to accept both old and new patterns; run validation after each batch |
| Description length exceeds 1024 chars | Low | Low | SC-LINT-004 catches this; descriptions must be trimmed to comply |
| Missing enforcement keyword | Low | Low | SC-LINT-002 catches this; ensure each description has MUST/REQUIRED |
| Tooling update missed | Medium | Medium | All 5 tooling files explicitly listed in affected files; verify each after Phase 1 |
| Behavioral test timeout | Low | Medium | Increase BEHAVIOR_TIMEOUT; verify model availability before test run |
| Partial rewrite state recovery | Medium | Low | Git checkpoint before each batch; `git checkout .` reverts uncommitted changes |
| Validator regression from pattern change | Medium | Medium | Run full validation suite after validator update before any description rewrites |

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [#601](https://github.com/michael-conrad/.opencode/issues/601) | RELATED | Original bug that motivated frontmatter validation |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `session-enforcement.ts` `loadSkillDescriptions()` function | Verify runtime only recognizes name/description/slash; frontmatter validation checks for missing fields, not description content |
| Direct source search | `validate_skill_cards.py` `validate_req1()` | Verify current validation rules enforce "Dispatch when" pattern |
| Direct source search | `init_skill.py` template | Verify current template uses "Dispatch when" pattern |
| Direct source search | `routing-only-template.md` | Verify current template documentation uses "Dispatch when" |
| Direct source search | `skill-card-spec.md` | Verify reference docs use "Dispatch when" |
| Direct source search | `glob` on all 60 SKILL.md files | Verify count is 60 |
| Commit history review | `git log --oneline` on `.opencode/skills/` | Verify no recent changes to description patterns that would conflict with this rewrite |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Phase |
|----|-----------|---------------|---------------------|-------------|-------|
| SC-1 | All 60 SKILL.md descriptions use the new agent-intent pattern | `string` | `grep -L 'User phrases:' .opencode/skills/*/SKILL.md` returns empty. DDL cost: string evidence catches grep-detectable defects at CI gate — a missed file is a grep-detectable omission, not a runtime behavior change, so string evidence is sufficient. A string FAIL means a file was missed; remediation cost is bounded (re-run grep, fix one file). No death spiral risk because the defect is text-pattern, not runtime behavior | Rewrite any file still using old pattern | Phase 2 |
| SC-2 | No SKILL.md description starts with "Use when" | `string` | `grep -r 'description: "Use when' .opencode/skills/*/SKILL.md` returns empty. DDL cost: string evidence catches grep-detectable defects at CI gate — a remaining "Use when" is a text-pattern defect, not a runtime behavior change. A string FAIL means a file was missed; remediation cost is bounded. No death spiral risk because the defect is text-pattern, not runtime behavior | Rewrite any file still using old pattern | Phase 2 |
| SC-3 | All descriptions include "User phrases:" suffix | `string` | `grep -L 'User phrases:' .opencode/skills/*/SKILL.md` returns empty. DDL cost: string evidence catches grep-detectable defects at CI gate — a missing suffix is a text-pattern omission, not a runtime behavior change. A string FAIL means a file was missed; remediation cost is bounded. No death spiral risk because the defect is text-pattern, not runtime behavior | Add missing User phrases section | Phase 2 |
| SC-4 | `validate_skill_cards.py` passes on all 60 files with new pattern | `behavioral` | `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py` exits 0. DDL cost: behavioral evidence catches runtime defects at pre-commit gate — a validator that rejects the new pattern is a runtime behavior change (the validator's acceptance logic is code, not text). A behavioral FAIL means the validator's code rejects valid input; a string PASS would miss this runtime regression, producing a death spiral where the validator silently blocks all future skill creation | Fix validation failures | Phase 1 |
| SC-5 | `session-enforcement.ts` accepts new description pattern — stderr must not contain `Warning:` or `error parsing frontmatter` from session-enforcement.ts | `behavioral` | `with-test-home opencode run "list skills"` produces no stderr lines matching `Warning:|error parsing frontmatter` from session-enforcement.ts. DDL cost: behavioral evidence catches runtime defects at pre-commit gate — plugin loading is runtime behavior. A behavioral FAIL means the plugin rejects the new pattern; a string PASS would miss this runtime regression, producing a death spiral where the plugin silently fails to load all skill descriptions | Fix session-enforcement.ts validation | Phase 1 |
| SC-6 | `init_skill.py` template uses new description pattern | `string` | `grep 'Load via skill()' .opencode/skills/skill-creator/scripts/init_skill.py` matches. DDL cost: string evidence catches grep-detectable defects at CI gate — a template string is static text, not runtime behavior. A string FAIL means the template still uses the old pattern; remediation cost is bounded. No death spiral risk because the defect is text-pattern, not runtime behavior | Update template | Phase 1 |
| SC-7 | `routing-only-template.md` documents new description pattern | `string` | `grep 'Load via skill()' .opencode/skills/skill-creator/reference/routing-only-template.md` matches. DDL cost: string evidence catches grep-detectable defects at CI gate — documentation text is static content, not runtime behavior. A string FAIL means the docs still reference the old pattern; remediation cost is bounded. No death spiral risk because the defect is text-pattern, not runtime behavior | Update template docs | Phase 1 |
| SC-8 | `skill-card-spec.md` documents new description pattern | `string` | `grep 'Load via skill()' .opencode/skills/skill-creator/reference/skill-card-spec.md` matches. DDL cost: string evidence catches grep-detectable defects at CI gate — documentation text is static content, not runtime behavior. A string FAIL means the docs still reference the old pattern; remediation cost is bounded. No death spiral risk because the defect is text-pattern, not runtime behavior | Update reference docs | Phase 1 |
| SC-9 | Behavioral enforcement test verifies agent calls `skill()` for matching task descriptions and does NOT call `skill()` for non-matching task descriptions | `behavioral` | `bash .opencode/tests-v2/behaviors/skill-description-pattern.sh` exits 0 — the test must assert that the agent calls `skill()` for a matching task description and does NOT call `skill()` for a non-matching task description. DDL cost: behavioral evidence catches runtime defects at pre-commit gate — agent routing decisions are runtime behavior. A behavioral FAIL means the agent misroutes based on new descriptions; a string PASS would miss this runtime regression, producing a death spiral where the agent silently ignores the new descriptions and routes incorrectly | Fix test or descriptions | Phase 0 |
| SC-10 | No description exceeds 1024 characters | `string` | `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py` SC-LINT-004 passes. DDL cost: string evidence catches grep-detectable defects at CI gate — description length is a static property, not runtime behavior. A string FAIL means a description exceeds the limit; remediation cost is bounded. No death spiral risk because the defect is text-pattern, not runtime behavior | Trim description to comply | Phase 2 |
| SC-11 | All descriptions include mandatory keyword (MUST/REQUIRED/always/not optional/mandatory) | `string` | `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py` SC-LINT-002 passes. DDL cost: string evidence catches grep-detectable defects at CI gate — keyword presence is a static text property, not runtime behavior. A string FAIL means a description lacks enforcement language; remediation cost is bounded. No death spiral risk because the defect is text-pattern, not runtime behavior | Add enforcement keyword | Phase 2 |
| SC-12 | All 13 SC evidence types in the spec match the declared evidence types in the SC table (verified by grep on evidence_type column) | `string` | `grep -c 'evidence_type' .opencode/.issues/1961/spec.md` matches expected count; audit confirms no evidence type was downgraded from its declared type. DDL cost: string evidence catches grep-detectable defects at CI gate — evidence type declarations are static text, not runtime behavior. A string FAIL means an evidence type was changed; remediation cost is bounded. No death spiral risk because the defect is text-pattern, not runtime behavior | Restore original evidence type and implement | Phase 3 |
| SC-13 | Before any implementation, write behavioral enforcement tests in `.opencode/tests-v2/behaviors/` that verify the new description pattern; confirm RED state (test fails before any description changes, passes after) | `behavioral` | `bash .opencode/tests-v2/behaviors/skill-description-pattern.sh` exits non-zero before implementation (RED), exits 0 after implementation (GREEN). DDL cost: behavioral evidence catches runtime defects at pre-commit gate — the RED→GREEN cycle verifies the test actually catches the absence of the new pattern (RED) and passes when it exists (GREEN). A behavioral FAIL at either stage means the test is defective; a string PASS would miss this runtime regression, producing a death spiral where the test silently passes without actually verifying agent behavior | Write missing tests | Phase 0 |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
