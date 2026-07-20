## Problem

42 SKILL.md files in the `.opencode/skills/` directory use inconsistent description formats. Only 6 of 42 follow the farmage YAML description pattern (`"Use when <primary>. Also use when <secondary>. Invoke for: <tasks>. <Enforcement>. Trigger phrases: <phrases>."`). The remaining ~36 skills use ad-hoc prose that produces unreliable skill dispatch — agents cannot reliably match trigger phrases to skills when descriptions lack structured trigger sections.

Additionally:
- 7 skills missing `type` frontmatter field
- 37 missing `provenance` field
- 2 missing `compatibility` field
- 30+ missing Worktree Mode sections
- SC-LINT-004 300-char limit conflicts with farmage 1024-char limit
- Cross-skill conflicts: research↔researcher (identical descriptions), plan↔writing-plans↔plan-creation-pipeline (overlapping triggers), verification↔verification-before-completion↔verification-enforcement (overlapping triggers)
- Invalid types: plan (`domain`→`utility`), solve (`tool`→`utility`), researcher (`problem-solving`→`utility`)

## Scope

**In scope:**
- Apply farmage YAML description pattern to all 42 SKILL.md `description` fields
- Add exclusion clauses (`— distinct from <exclusion>`) for skills that could false-match
- Fix missing frontmatter fields: `type`, `provenance`, `compatibility`
- Add Worktree Mode sections where missing
- Remove or update SC-LINT-004 (300-char limit) to align with farmage 1024-char limit
- Fix invalid type values
- Resolve cross-skill conflicts

**Out of scope:**
- Changes to skill task files, operating procedures, or routing logic
- Changes to guideline files or enforcement rules (except SC-LINT-004)
- Adding or removing skills
- Changes to the skill dispatch engine or agent configuration

## Audit Summary

Full audit performed via `skill-creator validate` task. Key findings:

| Check | Pass | Fail | Total |
|-------|------|------|-------|
| Farmage pattern (all 5 components) | 6 | 36 | 42 |
| REQ-1 (type field) | 35 | 7 | 42 |
| REQ-1 (compatibility) | 40 | 2 | 42 |
| REQ-3 (worktree mode) | 0 | 42 | 42 |
| REQ-4 (provenance) | 5 | 37 | 42 |
| SC-LINT-002 (enforcement keyword) | 39 | 3 | 42 |
| SC-LINT-004 (>300 chars) | 32 | 10 | 42 |

### Cross-Skill Conflicts

1. **research ↔ researcher** — Identical descriptions. `researcher` is used by implementation-pipeline for remediation; `research` is general-purpose. Need differentiation + exclusion clauses.
2. **plan ↔ writing-plans ↔ plan-creation-pipeline** — All trigger on "plan". `plan` = AI planning (unified-planning/PDDL/Z3). `writing-plans` = implementation plans from specs. `plan-creation-pipeline` = 6-step orchestrator. Need narrowed triggers + exclusion clauses.
3. **verification ↔ verification-before-completion ↔ verification-enforcement** — All trigger on "verify". Need exclusion clauses.

### Invalid Types

| Skill | Current | Correct |
|-------|---------|---------|
| plan | `domain` | `utility` |
| solve | `tool` | `utility` |
| researcher | `problem-solving` | `utility` |

## Approach

6 phases in dependency order:

| Phase | Description | Dependencies |
|-------|-------------|-------------|
| Phase 0 | Behavioral enforcement tests in RED state | None |
| Phase 1 | Frontmatter field fixes (type, provenance, compatibility) + invalid type corrections | Phase 0 |
| Phase 2 | Farmage description expansion for ~32 skills + exclusion clauses | Phase 1 |
| Phase 3 | Platform sub-skill farmage + enforcement keywords | Phase 2 |
| Phase 4 | Worktree Mode sections | Phase 3 |
| Phase 5 | SC-LINT-004 resolution | Phase 4 |
| Phase 6 | Cross-skill conflict resolution | Phase 5 |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|-------------------|
| SC-1 | All 42 SKILL.md `description` fields follow farmage pattern | behavioral | `opencode-cli run "list skills"` → verify stderr shows all 5 farmage components per skill |
| SC-2 | SC-LINT-004 300-char limit removed or updated to 1024 | behavioral | `grep -r "SC-LINT-004" .opencode/guidelines/` → verify no 300-char limit or updated to 1024 |
| SC-3 | All 42 SKILL.md files have `type`, `provenance`, `compatibility` frontmatter | structural | `for f in $(find .opencode/skills -name SKILL.md); do head -20 "$f" | grep -q "^type:" || echo "MISSING type: $f"; done` |
| SC-4 | Worktree Mode sections added to all 42 SKILL.md files | structural | `grep -rl "Worktree Mode" .opencode/skills/*/SKILL.md | wc -l` → verify count >= 39 |
| SC-5 | Cross-skill conflicts resolved | semantic | Sub-agent reads conflicting skill descriptions and judges distinct non-overlapping trigger phrases |
| SC-6 | Invalid type values corrected | structural | `grep "^type:" .opencode/skills/{plan,solve,researcher}/SKILL.md` → verify `utility` |
| SC-7 | Platform sub-skills have full farmage + enforcement keywords | behavioral | `opencode-cli run "show platform skills"` → verify farmage pattern for all 3 |
| SC-8 | Exclusion clauses on all false-matchable skills | semantic | Sub-agent reads all 42 descriptions, judges which need `— distinct from` clauses |
| SC-9 | Behavioral enforcement tests exist in RED state before changes | behavioral | `bash .opencode/tests/behaviors/farmage-pattern.sh` → FAILS (RED) before, PASSES (GREEN) after |

## Constraints

| Constraint | Value |
|------------|-------|
| Description length | Farmage pattern: 1024-char limit (not 300-char SC-LINT-004) |
| File scope | SKILL.md files only — no task files, guidelines, or enforcement rules |
| Phase ordering | Must follow dependency order: frontmatter → farmage → platform → worktree → SC-LINT → cross-skill |
| TDD discipline | Each phase requires RED behavioral test before GREEN implementation |
| Evidence type | Behavioral for dispatch-affecting changes; structural for frontmatter; semantic for conflict resolution |

## Decision Ledger

| DEC-ID | Decision | Rationale |
|--------|----------|-----------|
| DEC-1 | Farmage pattern includes all 5 components | Ensures complete structured descriptions for reliable skill dispatch |
| DEC-2 | SC-LINT-004 300-char limit removed in favor of farmage 1024-char limit | 300-char limit conflicts with farmage pattern |
| DEC-3 | Frontmatter fields populated with correct values per skill-card-change-types.md | Missing fields cause agent config loading failures |
| DEC-4 | Worktree Mode sections follow standard template from existing skills | Consistency across all skills |
| DEC-5 | Cross-skill conflicts resolved by exclusion clauses + distinct trigger sets | Prevents ambiguous dispatch routing |
| DEC-6 | Behavioral tests written in RED state before any changes | Per 091-incremental-build.md TDD discipline |

## Risk Traceability

| RISK-ID | Risk | Likelihood | Impact | Mitigation | Verifying SC |
|---------|------|------------|--------|------------|--------------|
| RISK-1 | Cross-skill conflict resolution changes dispatch behavior | Medium | High | Behavioral tests before and after each change | SC-5 |
| RISK-2 | SC-LINT-004 removal affects other linting | Low | Medium | Verify SC-LINT-004 is only used for 300-char limit | SC-2 |
| RISK-3 | 42-file scope causes merge conflicts | Medium | Medium | Phase ordering with stacked PR strategy | SC-9 |
| RISK-4 | Farmage pattern applied inconsistently | Low | High | Automated verification script per SC-1 | SC-1 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | MUST | Update assertions to match revised SCs |
| SC-LINT-004 change | SHOULD | Review for continued validity |

## Decomposition Classification

| Classification | Value |
|----------------|-------|
| Type | multi-phase |
| Phase count | 6 (Phase 0-6) |
| Sub-issue requirement | One sub-issue per phase |
| PR strategy | stacked |

## Non-Goals

- Task file changes — No modifications to `.md` task files within skills
- Guideline changes — No modifications to `.opencode/guidelines/` files (except SC-LINT-004)
- Skill addition/removal — No new skills created or existing skills deleted
- Dispatch engine changes — No changes to agent configuration or skill loading logic

## Regression Invariants

1. All existing skill dispatch behavior MUST continue to work for skills that already have farmage pattern
2. All existing frontmatter fields MUST be preserved (only missing fields added)
3. No SKILL.md file MAY be deleted or renamed
4. All existing task files and operating procedures MUST remain unchanged

---

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/{N}/plan.md` before implementation begins.

🤖 OpenCode (deepseek-v4-flash) created