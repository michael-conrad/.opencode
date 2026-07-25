---
issue: .opencode#2142
title: "[SPEC] Fix: Skill card descriptions reference abstract tool names instead of project-local paths"
status: draft
approved: 2026-07-25
created: 2026-07-25
license: MIT
provenance: AI-generated
phase: 1
phase_name: Skill Description Fix
authors:
  - OpenCode (deepseek-v4-flash)
---

> **Full spec and artifacts: [`.opencode/.issues/2142/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2142)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2142/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

Four skill cards reference their tool dependencies by abstract domain concept names in the YAML `description` field instead of by project-local path. When the agent evaluates the description at Level 1 (the `<available_skills>` list), the abstract name primes training-data lookups (e.g., `which z3`) instead of consulting the `## Agent Tools` section from session-init.

This was discovered during plan creation for `.opencode#2141` when the orchestrator ran `which z3` instead of using `.opencode/tools/solve` — a tool that was listed in the `## Agent Tools` section of session-init. The root cause was the `solve` skill's description saying "Z3 constraint solver" which primed a system-binary lookup.

## Affected Skills

| Skill | Description says | Primes agent to look for |
|-------|----------------|------------------------|
| `solve` | "Z3 constraint solver" | `which z3` (system binary) |
| `plan` | "Formal AI planning...PDDL conversion" | `which unified-planning` or `pip list` |
| `plan-creation-pipeline` | "Z3-verified state transitions" | `which z3` (system binary) |
| `issue-operations-core` | "routes to...GitBucket API" | `which gitbucket-api` (doesn't exist) |

## Approach

Update the `description` field in each affected SKILL.md to lead with the project-local tool path (`.opencode/tools/<tool>`) before the domain concept. This ensures the agent's first exposure to the skill tells it where the tool lives, preventing training-data fallback.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `solve/SKILL.md` description starts with `.opencode/tools/solve` | `string` | grep on description field |
| SC-2 | `plan/SKILL.md` description starts with `.opencode/tools/plan` | `string` | grep on description field |
| SC-3 | `plan-creation-pipeline/SKILL.md` description references `.opencode/tools/solve` instead of bare "Z3" | `string` | grep on description field |
| SC-4 | `issue-operations-core/SKILL.md` description references `.opencode/tools/gitbucket-api` instead of bare "GitBucket API" | `string` | grep on description field |
| SC-5 | All other skill descriptions remain unchanged | `structural` | diff shows only 4 files modified |
| SC-6 | Behavioral test verifies agent does NOT run `which`/`command -v` for `.opencode/tools/` tools | `behavioral` | `opencode run` with stderr assertions |

## Requirements

| ID | Requirement | SC | Item |
|----|-------------|----|------|
| REQ-1 | Update `solve/SKILL.md` description to lead with `.opencode/tools/solve` | SC-1 | 1 |
| REQ-2 | Update `plan/SKILL.md` description to lead with `.opencode/tools/plan` | SC-2 | 1 |
| REQ-3 | Update `plan-creation-pipeline/SKILL.md` description to reference `.opencode/tools/solve` | SC-3 | 1 |
| REQ-4 | Update `issue-operations-core/SKILL.md` description to reference `.opencode/tools/gitbucket-api` | SC-4 | 1 |
| REQ-5 | Verify no other skill descriptions changed | SC-5 | 2 |
| REQ-6 | Write behavioral enforcement test for tool-lookup pattern | SC-6 | 3 |

## Edge Cases

1. **Description length limit:** The description field is a Level 1 classifier with ~100 token budget. Adding `.opencode/tools/solve` prefix must not push the description over the effective limit. Verify each updated description stays within reasonable length.
2. **Existing consumers:** Skills that reference `solve` or `plan` by name in their own descriptions (e.g., `writing-plans`, `implementation-pipeline`) are NOT affected — they reference the skill name, not the tool path. No changes needed to consumer skills.
3. **`plan-creation-pipeline` references Z3 in body too:** The SKILL.md body (not just description) mentions "Z3-verified state transitions" in the description field. The body text is a separate concern — this spec only targets the YAML `description` field.

## Implementation Items

1. Update 4 SKILL.md description fields
2. Verify no other descriptions changed (diff check)
3. Write behavioral enforcement test

## Pipeline Gates

| Gate | Phase | Check |
|------|-------|-------|
| Pre-work | Before any edit | Branch creation, submodule sync |
| RED | Item 3 | Behavioral test fails before changes |
| GREEN | Item 1 | All 4 descriptions updated |
| Verify | Item 2 | Diff shows exactly 4 files changed |
| Commit | After verify | All changes + test committed together |
| PR | After commit | PR created against main |

