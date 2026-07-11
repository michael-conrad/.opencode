# Plan: Rewrite SKILL.md descriptions from user-trigger-phrase-oriented to agent-intent-oriented

**Issue:** .opencode#1855
**Status:** DRAFT
**Created:** 2026-07-11

## Goal

Rewrite all 43 SKILL.md `description` frontmatter fields from the old user-trigger-phrase-oriented pattern (`"Use when... Invoke for:... Trigger phrases:..."`) to the new agent-intent-oriented pattern (`"<Noun phrase>. Dispatch when... Also dispatch when... User phrases:..."`). Update the skill-creator validation scripts, reference docs, and init script to define and enforce the new pattern. Add behavioral enforcement tests.

## Architecture

The change is a mechanical text transformation across 47 files (43 SKILL.md + 2 scripts + 2 reference docs) plus 5 new behavioral test files. No runtime changes — the opencode runtime (`packages/core/src/skill.ts`) reads the `description` field as an opaque string and is unaffected by format changes.

### Key Design Decisions

- **DEC-1**: The `description` field is the only mechanism available — no new frontmatter fields
- **DEC-2**: User phrases are retained as supplementary info under `"User phrases:"` label
- **DEC-3**: The skill-creator validation script must enforce the new pattern (reject old, accept new)
- **DEC-4**: Behavioral enforcement tests required because this changes agent dispatch behavior

## Affected Files

### Phase 1 — Pattern Definition (4 files)
| File | Change |
|------|--------|
| `.opencode/skills/skill-creator/reference/routing-only-template.md` | Update description template and farmage pattern docs |
| `.opencode/skills/skill-creator/reference/skill-card-spec.md` | Add note referencing new pattern |
| `.opencode/skills/skill-creator/scripts/init_skill.py` | Update SKILL_TEMPLATE description placeholder |
| `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` | Reverse description validation rules |

### Phase 2 — Description Rewrites (43 files)
All 43 SKILL.md files listed in blast-radius.yaml. Each file's `description` field in YAML frontmatter is rewritten.

### Phase 3 — Behavioral Tests (5 new files + 1 updated)
| File | Change |
|------|--------|
| `.opencode/tests/behaviors/1855-sc2-validator-rejects-old-pattern.sh` | New |
| `.opencode/tests/behaviors/1855-sc3-validator-accepts-new-pattern.sh` | New |
| `.opencode/tests/behaviors/1855-sc7-git-workflow-intent-dispatch.sh` | New |
| `.opencode/tests/behaviors/1855-sc8-spec-creation-intent-dispatch.sh` | New |
| `.opencode/tests/behaviors/1855-sc9-verification-before-completion-intent-dispatch.sh` | New |
| `.opencode/tests/content-verification/d1-description-format.sh` | Update assertion |

## Phase Table

| Phase | ID | Description | Files | Dependencies |
|-------|----|-------------|-------|--------------|
| 1 | pattern-definition | Define canonical pattern, update reference docs, init script, validator | 4 | None |
| 2 | description-rewrites | Rewrite all 43 SKILL.md descriptions | 43 | Phase 1 (validator must exist first) |
| 3 | behavioral-tests | Write 5 behavioral tests, update 1 content-verification test | 6 | Phase 1 (validator tests), Phase 2 (intent-dispatch tests need GREEN) |

## Exit Criteria

| ID | Criterion | Evidence Type | Phase |
|----|-----------|---------------|-------|
| SC-1 | New description pattern defined and documented in reference docs | `string` | 1 |
| SC-2 | validate_skill_cards.py rejects descriptions starting with "Use when" | `behavioral` | 1 |
| SC-3 | validate_skill_cards.py accepts descriptions matching new pattern | `behavioral` | 1 |
| SC-4 | init_skill.py generates descriptions using new pattern | `string` | 1 |
| SC-5 | All 43 SKILL.md descriptions follow new pattern | `string` | 2 |
| SC-6 | All 43 SKILL.md descriptions contain "User phrases:" | `string` | 2 |
| SC-7 | Agent dispatches git-workflow on intent to create PR | `behavioral` | 3 |
| SC-8 | Agent dispatches spec-creation on intent to write spec | `behavioral` | 3 |
| SC-9 | Agent dispatches verification-before-completion on intent to verify | `behavioral` | 3 |
| SC-10 | validate_skill_cards.py passes on all 43 rewritten files | `behavioral` | 2 |
| SC-11 | All rewritten descriptions ≤ 1024 characters | `structural` | 2 |
| SC-12 | No existing behavioral tests break | `behavioral` | 3 |

## Admonishments

- **Scope isolation**: Phase 1 touches only skill-creator tools and reference docs. Phase 2 touches only the `description` field in YAML frontmatter of SKILL.md files — no other frontmatter fields, no body content. Phase 3 touches only test files.
- **No runtime changes**: The opencode runtime reads `description` as an opaque string. Format change is transparent.
- **User phrase preservation**: All existing trigger phrases are preserved under the `"User phrases:"` label — zero content loss.
- **Enforcement statement preservation**: All enforcement statements (e.g., "Spec creation is REQUIRED before implementation.") are preserved as-is.
- **Exclusion clause preservation**: All `"— distinct from"` clauses are preserved as-is.
- **1024-character limit**: Each rewritten description must be verified against the 1024-character opencode limit.
- **Behavioral TDD**: Intent-dispatch behavioral tests (SC-7, SC-8, SC-9) follow RED/GREEN pattern — write in RED phase before Phase 2, verify GREEN after Phase 2.

## Self-Review Evidence

- All 7 analytical artifacts read and validated: blast-radius.yaml, concern-map.yaml, code-path-inventory.yaml, cross-cutting-matrix.yaml, interface-compatibility.yaml, state-analysis.yaml, testability-assessment.yaml
- Spec body read and confirmed: 3 phases, 12 success criteria, 4 key design decisions
- Codebase files inspected: validate_skill_cards.py (lines 97-195), init_skill.py (line 29), routing-only-template.md (lines 18-27), skill-card-spec.md, d1-description-format.sh
- Label confirmed: `approved-for-plan`
- Z3 checks: All pipeline Z3 checks will be executed during plan execution
