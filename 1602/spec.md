# [SPEC] Apply farmage YAML description pattern to all skill cards

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| **Problem Statement** | 42 SKILL.md files in `.opencode/skills/` use inconsistent description formats. Only 6 of 42 follow the farmage YAML description pattern. The remaining ~36 use ad-hoc prose causing unreliable skill dispatch. |
| **Root Cause / Motivation** | The farmage pattern was introduced after most skills were created. No migration was performed. Additionally: 37 missing `provenance`, 7 missing `type`, 2 missing `compatibility`, 30+ missing Worktree Mode sections, SC-LINT-004 300-char limit conflicts with farmage 1024-char limit, cross-skill conflicts (research↔researcher, plan↔writing-plans↔plan-creation-pipeline, verification↔verification-before-completion↔verification-enforcement), invalid types (plan:domain, solve:tool, researcher:problem-solving). |
| **Approach Chosen** | 7-phase sequential pipeline: behavioral tests RED → frontmatter fixes → farmage expansion + exclusion clauses → platform sub-skills → Worktree Mode → SC-LINT-004 → cross-skill conflicts. |
| **Alternatives Considered & Why Discarded** | Single-phase bulk edit (too risky, no verification gates). Per-file manual editing (too slow, inconsistent). |
| **Key Design Decisions** | Farmage pattern in YAML frontmatter `description` field. Exclusion clauses document when NOT to dispatch. SC-LINT-004 limit raised to 1024-char. |

## Objective

Standardize all 42 SKILL.md files to use the farmage YAML description pattern, fix frontmatter gaps, add Worktree Mode sections, resolve SC-LINT-004 conflicts, and fix cross-skill conflicts.

## Problem

42 SKILL.md files in `.opencode/skills/` use inconsistent description formats. Only 6 of 42 follow the farmage pattern. The remaining ~36 use ad-hoc prose causing unreliable skill dispatch. Additionally: 37 missing `provenance`, 7 missing `type`, 2 missing `compatibility`, 30+ missing Worktree Mode sections, SC-LINT-004 300-char limit conflicts with farmage 1024-char limit, cross-skill conflicts (research↔researcher, plan↔writing-plans↔plan-creation-pipeline, verification↔verification-before-completion↔verification-enforcement), invalid types (plan:domain, solve:tool, researcher:problem-solving).

## Scope

### In Scope

- All 42 SKILL.md files (39 main skills + 3 platform sub-skills)
- Frontmatter fixes (provenance, type, compatibility)
- Farmage description expansion (YAML description pattern)
- Exclusion clauses in all skill cards
- Worktree Mode sections where applicable
- SC-LINT-004 guideline limit resolution (300-char → 1024-char)
- Cross-skill conflict resolution (3 conflict groups)
- Invalid type correction (plan, solve, researcher)

### Out of Scope

- Task files (`.opencode/skills/*/tasks/*.md`)
- Guidelines (except SC-LINT-004)
- Dispatch engine
- Non-SKILL.md files
- Non-.opencode submodule files

## Affected Files

| File | Phase | Change |
|------|-------|--------|
| `.opencode/skills/*/SKILL.md` (39 files) | 1, 2, 4 | Frontmatter, farmage, Worktree Mode |
| `.opencode/skills/issue-operations/platforms/*/SKILL.md` (3 files) | 3 | Farmage descriptions |
| `.opencode/guidelines/` (SC-LINT-004) | 5 | Limit value change |
| `.opencode/skills/{research,researcher,plan,writing-plans,plan-creation-pipeline,verification,verification-before-completion,verification-enforcement}/SKILL.md` (8 files) | 6 | Cross-skill conflict resolution |

## Phases

| Phase | Tier | Target | SCs |
|-------|------|--------|-----|
| Phase 0 — Behavioral tests RED | 1 (pre) | Write failing behavioral tests before any changes | SC-9 |
| Phase 1 — Frontmatter fixes | 2 (per-file) | All 42 SKILL.md files | SC-3, SC-6 |
| Phase 2 — Farmage expansion + exclusion clauses | 2 (per-file) | All 42 SKILL.md files | SC-1, SC-8 |
| Phase 3 — Platform sub-skills | 2 (per-file) | 3 platform sub-skill files | SC-7 |
| Phase 4 — Worktree Mode sections | 2 (per-file) | 30+ SKILL.md files | SC-4 |
| Phase 5 — SC-LINT-004 resolution | 2 (per-file) | 1 guideline file | SC-2 |
| Phase 6 — Cross-skill conflicts | 2 (per-file) | 8 SKILL.md files in 3 groups | SC-5 |
| Phase 7 — Global Post-Phase | 3 (post) | Adversarial audit, cross-validate, regression | All |

## Approach

### Phase 0 — Behavioral Tests RED

Write behavioral enforcement tests in `.opencode/tests/behaviors/` that verify the new rules. Confirm RED state (test fails before change). Tests MUST use stderr-based assertion helpers (`assert_stderr_pattern_present`/`assert_stderr_pattern_absent_all_models`) with real-domain prompts — NOT prose-recall prompts.

### Phase 1 — Frontmatter Fixes

For all 42 SKILL.md files, add missing frontmatter fields:
- `provenance: AI-generated` (37 files missing)
- `type: skill` (7 files missing)
- `compatibility: opencode-cli` (2 files missing)
- Correct invalid types: `plan:domain` → `plan:skill`, `solve:tool` → `solve:skill`, `researcher:problem-solving` → `researcher:skill`

### Phase 2 — Farmage Expansion + Exclusion Clauses

Replace ad-hoc description prose with farmage YAML description pattern in all 42 SKILL.md files. Each description MUST:
- Be in the YAML frontmatter `description` field
- Use structured prose (not ad-hoc sentences)
- Include an exclusion clause documenting when NOT to dispatch
- Stay within the SC-LINT-004 1024-char limit (after Phase 5)

### Phase 3 — Platform Sub-Skills

Apply farmage descriptions to 3 platform sub-skill files:
- `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md`
- `.opencode/skills/issue-operations/platforms/github-mcp/SKILL.md`
- `.opencode/skills/issue-operations/platforms/local/SKILL.md`

### Phase 4 — Worktree Mode Sections

Add Worktree Mode sections to SKILL.md files that reference git operations or branch management. Only add to skills where Worktree Mode is applicable.

### Phase 5 — SC-LINT-004 Resolution

Raise the SC-LINT-004 300-char limit to 1024-char in the guideline file. Only the limit value changes — not the rule semantics.

### Phase 6 — Cross-Skill Conflicts

Resolve dispatch ambiguity between 3 conflict groups:
1. **research ↔ researcher**: Clarify dispatch boundaries between these two skills
2. **plan ↔ writing-plans ↔ plan-creation-pipeline**: Define when each of the three planning skills dispatches
3. **verification ↔ verification-before-completion ↔ verification-enforcement**: Define when each of the three verification skills dispatches

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

SC-1, SC-3, SC-8 — Verified once in Phase 2, applies to all subsequent phases.

## Success Criteria

| ID | Criterion | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | All 42 SKILL.md files use farmage YAML description pattern in frontmatter `description` field | `grep -c 'description:' .opencode/skills/*/SKILL.md .opencode/skills/issue-operations/platforms/*/SKILL.md` — verify count equals 42 | Re-apply farmage pattern to files that don't match | Phase 2 | `.opencode/skills/*/SKILL.md` | Farmage YAML description pattern | Phase 2 | pre-commit | sequential | farmage | Phase 2 | N/A | Phase 2 |
| SC-2 | SC-LINT-004 300-char limit raised to 1024-char | `grep 'max_length: 1024' .opencode/guidelines/` — verify limit value | Revert and re-apply targeted edit | Phase 5 | `.opencode/guidelines/` | SC-LINT-004 limit raised | Phase 5 | pre-commit | sequential | lint | Phase 5 | N/A | Phase 5 |
| SC-3 | All 42 SKILL.md files have complete frontmatter (provenance, type, compatibility) | `grep -l 'provenance:' .opencode/skills/*/SKILL.md | wc -l` — verify count equals 42 | Add missing fields to files that lack them | Phase 1 | `.opencode/skills/*/SKILL.md` | Complete frontmatter | Phase 1 | pre-commit | sequential | frontmatter | Phase 1 | N/A | Phase 1 |
| SC-4 | All applicable SKILL.md files have Worktree Mode sections | `grep -c 'Worktree Mode' .opencode/skills/*/SKILL.md` — verify count matches applicable skills | Add Worktree Mode section to files that lack it | Phase 4 | `.opencode/skills/*/SKILL.md` | Worktree Mode sections | Phase 4 | pre-commit | sequential | worktree | Phase 4 | N/A | Phase 4 |
| SC-5 | Cross-skill conflicts resolved — each skill has unique dispatch trigger scope | Behavioral test: dispatch each skill with ambiguous prompt, verify correct skill fires | Revisit conflict resolution for affected group | Phase 6 | `.opencode/skills/{research,researcher,plan,writing-plans,plan-creation-pipeline,verification,verification-before-completion,verification-enforcement}/SKILL.md` | Cross-skill conflicts resolved | Phase 6 | post-implementation | sequential | conflicts | Phase 6 | `.opencode/tests/behaviors/cross-skill-conflicts.sh` | Phase 6 |
| SC-6 | Invalid types corrected (plan:domain→skill, solve:tool→skill, researcher:problem-solving→skill) | `grep 'type: domain\|type: tool\|type: problem-solving' .opencode/skills/*/SKILL.md` — verify zero matches | Correct remaining invalid types | Phase 1 | `.opencode/skills/{plan,solve,researcher}/SKILL.md` | Invalid types corrected | Phase 1 | pre-commit | sequential | frontmatter | Phase 1 | N/A | Phase 1 |
| SC-7 | Platform sub-skills have farmage descriptions | `grep 'description:' .opencode/skills/issue-operations/platforms/*/SKILL.md` — verify 3 files have farmage pattern | Apply farmage pattern to missing sub-skills | Phase 3 | `.opencode/skills/issue-operations/platforms/*/SKILL.md` | Platform sub-skill farmage | Phase 3 | pre-commit | sequential | farmage | Phase 3 | N/A | Phase 3 |
| SC-8 | Exclusion clauses present in all skill cards | `grep -c 'exclusion\|not dispatch\|do not use' .opencode/skills/*/SKILL.md` — verify count equals 42 | Add exclusion clause to files that lack it | Phase 2 | `.opencode/skills/*/SKILL.md` | Exclusion clauses present | Phase 2 | pre-commit | sequential | farmage | Phase 2 | N/A | Phase 2 |
| SC-9 | Behavioral tests in RED state before implementation | Run behavioral tests before any changes — verify FAIL | Re-create behavioral tests that pass when they should fail | Phase 0 | `.opencode/tests/behaviors/` | Behavioral tests RED | Phase 0 | pre-commit | sequential | tests | Phase 0 | `.opencode/tests/behaviors/farmage-pattern.sh` | Phase 0 |

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
