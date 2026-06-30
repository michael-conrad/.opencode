# [SPEC] Apply farmage YAML description pattern to all skill cards

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| **Problem Statement** | 42 SKILL.md files in `.opencode/skills/` use inconsistent description formats. Only 6 of 42 follow the farmage YAML description pattern. The remaining ~36 use ad-hoc prose causing unreliable skill dispatch. Additionally, `researcher` is a duplicate of `research` and should be merged. |
| **Root Cause / Motivation** | The farmage pattern was introduced after most skills were created. No migration was performed. Additionally: 40 missing `provenance`, 4 missing `type` + 2 invalid types, 2 missing `compatibility`, 30+ missing Worktree Mode sections, SC-LINT-004 300-char limit conflicts with farmage 1024-char limit, cross-skill conflicts (research↔researcher, plan↔writing-plans↔plan-creation-pipeline, verification↔verification-before-completion↔verification-enforcement), invalid types (plan:domain, solve:tool), researcher duplicates research. |
| **Approach Chosen** | 7-phase sequential pipeline: behavioral tests RED → frontmatter fixes → farmage description expansion → platform sub-skills → Worktree Mode → SC-LINT-004 → cross-skill conflicts + exclusion clauses. |
| **Alternatives Considered & Why Discarded** | Single-phase bulk edit (too risky, no verification gates). Per-file manual editing (too slow, inconsistent). |
| **Key Design Decisions** | Farmage pattern in YAML frontmatter `description` field. Exclusion clauses document when NOT to dispatch. SC-LINT-004 limit raised to 1024-char. |

## Objective

Standardize all 41 SKILL.md files (researcher deleted, merged into research) to use the farmage YAML description pattern, fix frontmatter gaps, add Worktree Mode sections, resolve SC-LINT-004 conflicts, and fix cross-skill conflicts.

## Problem

42 SKILL.md files in `.opencode/skills/` use inconsistent description formats. Only 6 of 42 follow the farmage pattern. The remaining ~36 use ad-hoc prose causing unreliable skill dispatch. Additionally: 40 missing `provenance`, 4 missing `type` + 2 invalid types, 2 missing `compatibility`, 30+ missing Worktree Mode sections, SC-LINT-004 300-char limit conflicts with farmage 1024-char limit, cross-skill conflicts (research↔researcher, plan↔writing-plans↔plan-creation-pipeline, verification↔verification-before-completion↔verification-enforcement), invalid types (plan:domain, solve:tool), researcher duplicates research.

## Scope

### In Scope

- All 41 SKILL.md files (38 main skills + 3 platform sub-skills) — researcher is removed, not updated
- Frontmatter fixes (provenance, type, compatibility)
- Farmage description expansion (YAML description pattern)
- Exclusion clauses in all skill cards
- Worktree Mode sections where applicable
- SC-LINT-004 guideline limit resolution (300-char → 1024-char)
- Cross-skill conflict resolution (3 conflict groups)
- Invalid type correction (plan, solve)
- Remove `researcher` skill (merge into `research`)

### Out of Scope

- Task files (`.opencode/skills/*/tasks/*.md`) — except researcher task files which are deleted as part of the merge
- Guidelines (except SC-LINT-004)
- Dispatch engine
- Non-SKILL.md files
- Non-.opencode submodule files

## Affected Files

| File | Phase | Change |
|------|-------|--------|
| `.opencode/skills/*/SKILL.md` (38 files, excluding researcher) | 1, 2, 4 | Frontmatter, farmage, Worktree Mode |
| `.opencode/skills/issue-operations/platforms/*/SKILL.md` (3 files) | 3 | Farmage descriptions |
| `.opencode/guidelines/` (SC-LINT-004) | 5 | Limit value change |
| `.opencode/skills/researcher/SKILL.md` | 6 | Remove file (merge into research) |
| `.opencode/skills/research/SKILL.md` | 6 | Update description to absorb researcher's purpose |
| `.opencode/skills/{plan,writing-plans,plan-creation-pipeline}/SKILL.md` (3 files) | 6 | Add exclusion clauses |
| `.opencode/skills/{verification,verification-before-completion,verification-enforcement}/SKILL.md` (3 files) | 6 | Add exclusion clauses |

## Phases

| Phase | Tier | Target | SCs |
|-------|------|--------|-----|
| Phase 0 — Behavioral tests RED | 1 (pre) | Write failing behavioral tests before any changes | SC-9 |
| Phase 1 — Frontmatter fixes | 2 (per-file) | All 41 SKILL.md files (researcher excluded — will be deleted) | SC-3, SC-6 |
| Phase 2 — Farmage description expansion | 2 (per-file) | All 41 SKILL.md files (researcher excluded) | SC-1 |
| Phase 3 — Platform sub-skills (merged into Phase 2) | — | Removed — platform sub-skills are already covered by Phase 2's "all 41 files" scope | SC-7 |
| Phase 4 — Worktree Mode sections | 2 (per-file) | 30+ SKILL.md files | SC-4 |
| Phase 5 — SC-LINT-004 resolution | 2 (per-file) | 1 guideline file | SC-2 |
| Phase 6 — Cross-skill conflicts + exclusion clauses | 2 (per-file) | Merge researcher→research, add exclusion clauses to 6 remaining files | SC-5, SC-8 |
| Phase 7 — Global Post-Phase | 3 (post) | Adversarial audit, cross-validate, regression | All |

## Approach

### Phase 0 — Behavioral Tests RED

Write behavioral enforcement tests in `.opencode/tests/behaviors/` that verify the new rules. Confirm RED state (test fails before change). Tests MUST use stderr-based assertion helpers (`assert_stderr_pattern_present`/`assert_stderr_pattern_absent_all_models`) with real-domain prompts — NOT prose-recall prompts.

### Phase 1 — Frontmatter Fixes

For all 41 SKILL.md files (researcher excluded — will be deleted), add missing frontmatter fields:
- `provenance: AI-generated` (40 files missing)
- `type: discipline-enforcing` (4 files missing; plan and solve get `type: utility` as they wrap external tools)
- `compatibility: opencode` (2 files missing)
- Correct invalid types: `plan:domain` → `plan:utility`, `solve:tool` → `solve:utility`

### Phase 2 — Farmage Description Expansion

Replace ad-hoc description prose with farmage YAML description pattern in all 41 SKILL.md files (researcher excluded — will be deleted in Phase 6). Each description MUST:
- Be in the YAML frontmatter `description` field
- Use structured prose (not ad-hoc sentences)
- Stay within the SC-LINT-004 1024-char limit (after Phase 5)

Exclusion clauses (`— distinct from <exclusion>`) are NOT added in this phase. They are added in Phase 6 alongside cross-skill conflict resolution, where the specific exclusion language is determined per conflict group.

### Phase 3 — Platform Sub-Skills (merged into Phase 2)

Platform sub-skills are already covered by Phase 2's scope ("all 41 SKILL.md files"). No separate phase needed. SC-7 is verified as part of Phase 2's VbC.

### Phase 4 — Worktree Mode Sections

Add Worktree Mode sections to SKILL.md files that reference git operations or branch management. Only add to skills where Worktree Mode is applicable.

### Phase 5 — SC-LINT-004 Resolution

Raise the SC-LINT-004 300-char limit to 1024-char in the guideline file. Only the limit value changes — not the rule semantics.

### Phase 6 — Cross-Skill Conflicts

Resolve dispatch ambiguity between 3 conflict groups:

1. **research ↔ researcher**: Merge `researcher` into `research`. These are functionally identical skills with identical descriptions. `researcher` adds "used by implementation-pipeline for remediation" but that's a usage note, not a distinct skill. Delete `researcher/SKILL.md` and its task files. Update `research/SKILL.md` description to note it is the skill dispatched by `implementation-pipeline` for remediation-scope investigation.

2. **plan ↔ writing-plans ↔ plan-creation-pipeline**: Add exclusion clauses to each:
   - `plan`: `— distinct from writing-plans (implementation plans from specs) and plan-creation-pipeline (6-step orchestrator)`
   - `writing-plans`: `— distinct from plan (AI planning with PDDL/Z3) and plan-creation-pipeline (task()-dispatch pipeline)`
   - `plan-creation-pipeline`: `— distinct from plan (formal AI planning) and writing-plans (orchestrator-level plan creation)`

3. **verification ↔ verification-before-completion ↔ verification-enforcement**: Add exclusion clauses to each:
   - `verification`: `— distinct from verification-before-completion (completion gate) and verification-enforcement (content generation)`
   - `verification-before-completion`: `— distinct from verification (general claim verification) and verification-enforcement (content generation)`
   - `verification-enforcement`: `— distinct from verification (general claim verification) and verification-before-completion (completion gate)`

Each skill MUST have a unique dispatch trigger scope.

### Phase 7 — Global Post-Phase

Adversarial audit, cross-validate, regression testing, review prep.

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Farmage pattern in YAML frontmatter `description` field | Standardized format for all skill cards | MUST | SC-1 |
| DEC-2 | Exclusion clauses in all skill cards | Prevents false-positive dispatch matches | MUST | SC-8 |
| DEC-3 | SC-LINT-004 limit raised to 1024-char | Accommodates farmage pattern description length | MUST | SC-2 |
| DEC-4 | Sequential phase ordering | Dependency chain: tests → frontmatter → farmage → sub-skills → Worktree → lint → conflicts | MUST | All |
| DEC-5 | Behavioral tests RED before any changes | TDD discipline per 091-incremental-build.md | MUST | SC-9 |
| DEC-6 | researcher merged into research | Identical descriptions and purpose; researcher is a usage variant, not a distinct skill | MUST | SC-5 |
| DEC-7 | Invalid types: plan→utility, solve→utility | These skills wrap external tools (unified-planning, Z3) — `utility` is the correct type per the taxonomy | MUST | SC-6 |
| DEC-8 | Frontmatter compatibility value: `opencode` (not `opencode-cli`) | Existing skills use `opencode`; consistency required | MUST | SC-3 |

## Risk Traceability

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | YAML frontmatter corruption during bulk edits | Medium | High | Validate YAML after each edit | SC-1 |
| RISK-2 | Farmage description exceeds 300-char before Phase 5 | High | High | Phase 5 must complete before or alongside Phase 2 | SC-2 |
| RISK-3 | Cross-skill resolution creates new conflicts | Low | Medium | Adversarial audit in post-phase | SC-5 |
| RISK-4 | Behavioral tests not truly RED | Low | High | Verify test failure before changes | SC-9 |
| RISK-5 | Worktree Mode added to wrong skills | Medium | Low | Only add where applicable | SC-4 |
| RISK-6 | SC-LINT-004 change modifies other parts | Low | Medium | Targeted edit with diff review | SC-2 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Decomposition Classification

| Classification | Value |
| -------------- | ----- |
| Type | multi-phase |
| Phase count | 7 (plus 1 post-phase) |
| Sub-issue requirements | One sub-issue per phase |
| PR strategy | stacked |

## Regression Invariants

1. Existing skill dispatch behavior MUST NOT change
2. All existing frontmatter fields MUST be preserved
3. YAML frontmatter MUST remain valid after all edits
4. SC-LINT-004 rule semantics MUST NOT change — only the limit value

## Cross-Cutting SCs

SC-1 — Verified once in Phase 2, applies to all subsequent phases. SC-3 — Verified once in Phase 1, applies to all subsequent phases. SC-8 — Verified once in Phase 6, applies to all subsequent phases.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|--------------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | All 41 SKILL.md files (researcher excluded) use farmage YAML description pattern in frontmatter `description` field | `behavioral` | `opencode-cli run "list skills"` → verify stderr shows all 5 farmage components (Use when, Also use when, Invoke for, enforcement, Trigger phrases) per skill | Re-apply farmage pattern to files that don't match | Phase 2 | `.opencode/skills/*/SKILL.md` | Farmage YAML description pattern | Phase 2 | pre-commit | sequential | farmage | Phase 2 | `.opencode/tests/behaviors/farmage-pattern.sh` | Phase 2 |
| SC-2 | SC-LINT-004 300-char limit raised to 1024-char | `string` | `grep -n 'len(desc) > 1024' .opencode/skills/skill-creator/scripts/validate_skill_cards.py` — verify limit value | Revert and re-apply targeted edit | Phase 5 | `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` | SC-LINT-004 limit raised | Phase 5 | pre-commit | sequential | lint | Phase 5 | N/A | Phase 5 |
| SC-3 | All 41 SKILL.md files (researcher excluded) have complete frontmatter (provenance, type, compatibility) | `string` | `grep -c '^provenance:' .opencode/skills/*/SKILL.md` — verify count equals 42 | Add missing fields to files that lack them | Phase 1 | `.opencode/skills/*/SKILL.md` | Complete frontmatter | Phase 1 | pre-commit | sequential | frontmatter | Phase 1 | N/A | Phase 1 |
| SC-4 | All applicable SKILL.md files have Worktree Mode sections | `string` | `grep -c 'Worktree Mode' .opencode/skills/*/SKILL.md` — verify count matches applicable skills | Add Worktree Mode section to files that lack it | Phase 4 | `.opencode/skills/*/SKILL.md` | Worktree Mode sections | Phase 4 | pre-commit | sequential | worktree | Phase 4 | N/A | Phase 4 |
| SC-5 | Cross-skill conflicts resolved — each skill has unique dispatch trigger scope; researcher merged into research | `behavioral` | Behavioral test: dispatch each skill with ambiguous prompt, verify correct skill fires | Revisit conflict resolution for affected group | Phase 6 | `.opencode/skills/{research,plan,writing-plans,plan-creation-pipeline,verification,verification-before-completion,verification-enforcement}/SKILL.md` | Cross-skill conflicts resolved | Phase 6 | post-implementation | sequential | conflicts | Phase 6 | `.opencode/tests/behaviors/cross-skill-conflicts.sh` | Phase 6 |
| SC-6 | Invalid types corrected (plan:domain→utility, solve:tool→utility) | `string` | `grep 'type: domain\|type: tool' .opencode/skills/*/SKILL.md` — verify zero matches | Correct remaining invalid types | Phase 1 | `.opencode/skills/{plan,solve}/SKILL.md` | Invalid types corrected | Phase 1 | pre-commit | sequential | frontmatter | Phase 1 | N/A | Phase 1 |
| SC-7 | Platform sub-skills have farmage descriptions | `behavioral` | `opencode-cli run "show platform skills"` → verify stderr shows all 5 farmage components per platform sub-skill | Apply farmage pattern to missing sub-skills | Phase 3 | `.opencode/skills/issue-operations/platforms/*/SKILL.md` | Platform sub-skill farmage | Phase 3 | pre-commit | sequential | farmage | Phase 3 | `.opencode/tests/behaviors/farmage-pattern.sh` | Phase 3 |
| SC-8 | Exclusion clauses present on all skills that could false-match with other skills | `semantic` | Sub-agent reads all 41 descriptions and judges which skills need `— distinct from` clauses; verify those clauses are present | Add exclusion clause to files that lack it | Phase 6 | `.opencode/skills/*/SKILL.md` | Exclusion clauses present | Phase 6 | pre-commit | sequential | conflicts | Phase 6 | `.opencode/tests/behaviors/exclusion-clauses.sh` | Phase 6 |
| SC-9 | Behavioral tests in RED state before implementation | `behavioral` | Run behavioral tests before any changes — verify FAIL | Re-create behavioral tests that pass when they should fail | Phase 0 | `.opencode/tests/behaviors/` | Behavioral tests RED | Phase 0 | pre-commit | sequential | tests | Phase 0 | `.opencode/tests/behaviors/farmage-pattern.sh` | Phase 0 |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

After this spec is approved, invoke `writing-plans` to create `.issues/1602/plan.md` before implementation begins.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `ls .opencode/skills/*/SKILL.md` | Count SKILL.md files (42 total) |
| Direct source search | `ls .opencode/skills/issue-operations/platforms/*/SKILL.md` | Count platform sub-skill files (3 total) |
| Local docs | `skill-creator/SKILL.md` | Farmage pattern reference |
| MCP search | `srclight_search_symbols` | Verify file paths and structure |

## Edge Cases

1. **New skills added during implementation**: If new SKILL.md files are added between spec creation and implementation, they MUST also be updated to follow the farmage pattern.
2. **SC-LINT-004 already modified**: If SC-LINT-004 has been modified before Phase 5, verify the current limit value before changing.
3. **Cross-skill resolution creates new conflicts**: Adversarial audit in Phase 7 MUST verify no new conflicts introduced.

## Dependencies

- `skill-creator` skill for farmage pattern reference
- SC-LINT-004 guideline file for limit resolution
- `.opencode/tests/behaviors/` directory for behavioral test files

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
