# [SPEC] Fix path confusion: emit project_root from session-init, replace ambiguous relative paths with project-root-anchored resolution

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

**STATUS:** DRAFT
**CREATED:** 2026-07-05
**ISSUE:** https://github.com/michael-conrad/.opencode/issues/1678

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| Problem Statement | Task files use ambiguous relative paths (`./tmp/`, `*/.issues/`) that resolve incorrectly when the agent's CWD is inside a git submodule, causing silent file operation errors |
| Root Cause / Motivation | session-init computes `PROJECT_ROOT` and `is_submodule_context()` internally but never emits them; task files rely on fragile glob patterns and relative paths |
| Approach Chosen | Emit `project_root` and `is_submodule_context` from session-init; add a behavioral rule anchoring all task file paths to project root; replace all `./tmp/` and `*/.issues/` patterns with explicit project-root-anchored paths |
| Alternatives Considered & Why Discarded | (1) Using `git rev-parse --show-toplevel` in every task file — fragile, duplicated logic. (2) env-loader changes — separate pipeline, out of scope. (3) Hardcoding submodule names — breaks when submodule paths change |
| Key Design Decisions | `project_root` is additive only (no existing output changes); `*/.issues/` replaced with explicit path construction from session-init repo entries, not a new variable |

## Objective

Eliminate path confusion when the agent's CWD is inside a git submodule by anchoring all task file paths to the project root, emitted by session-init.

## Problem

Task files in `.opencode/skills/*/tasks/*.md` use ambiguous relative paths:

- `./tmp/{N}/work.md` — resolves against CWD, which may be inside a submodule
- `*/.issues/{N}/plan.md` — glob hack that creates a literal `*` directory with `mkdir`

When the agent's CWD is inside `.opencode/` (the submodule), `./tmp/` resolves to `.opencode/tmp/` instead of the project root `tmp/`. The `*/.issues/` pattern is intended to match any repo's `.issues/` directory but fails for `mkdir` and is fragile for reads.

## Constraints

1. **Never hardcode submodule names.** The `path` field from session-init's `## Repo Information` is the submodule path relative to project root. Resolution pattern: `{project_root}/{path}/.issues/{N}/` where `path` comes from the repo entry.
2. **`project_root` is additive only** — does not change existing session-init output fields.
3. **`*/.issues/` is replaced with explicit path construction** from session-init data, not a new variable.
4. **No env-loader changes** — env-loader is a separate pipeline.

## Scope

### In Scope

1. Emit `project_root` (absolute `git rev-parse --show-toplevel`) from session-init
2. Emit `is_submodule_context` boolean from session-init
3. Add behavioral rule to `000-critical-rules.md`: all paths in task files are relative to project root, not submodule root
4. Update `060-tool-usage.md` to replace workdir-aware composition with project-root resolution rule
5. Replace all `./tmp/` and `*/.issues/` patterns in task files with project-root-anchored paths
6. Fix `mkdir -p */.issues/` bug in `github-mcp/SKILL.md`
7. Behavioral enforcement tests

### Out of Scope

- Changing issue routing logic (which repo an issue belongs to) — remains resolved by session-init's `## Repo Information`
- env-loader changes (separate pipeline)
- Non-task-file documentation references (AGENTS.md etc.)

## Affected Files

| File | Change Type | Anchor |
|------|-------------|--------|
| `.opencode/tools/session-init` | Modify | Emit `project_root` and `is_submodule_context` |
| `.opencode/guidelines/000-critical-rules.md` | Modify | Add project-root path resolution rule |
| `.opencode/guidelines/060-tool-usage.md` | Modify | Replace workdir-aware composition with project-root resolution |
| `.opencode/skills/*/tasks/*.md` | Modify | Replace `./tmp/` and `*/.issues/` patterns |
| `.opencode/skills/issue-operations/platforms/github-mcp/SKILL.md` | Modify | Fix `mkdir -p */.issues/` bug |
| `.opencode/tests/behaviors/` | Create | Behavioral enforcement tests |

## Approach

### Phase 1: session-init emission

Add two new output fields to session-init:

1. `project_root` — absolute path from `git rev-parse --show-toplevel` (already computed internally at line 63)
2. `is_submodule_context` — boolean from `is_submodule_context()` (already exists at line 473-493)

These are additive — no existing output fields change.

### Phase 2: Behavioral rule

Add a new critical rule to `000-critical-rules.md`: all file paths in task files are relative to the project root, not the submodule root. When the agent's CWD is inside a submodule, paths MUST be resolved against `project_root`.

### Phase 3: Guideline update

Replace the "Workdir-Aware Path Composition" section in `060-tool-usage.md` with a "Project-Root Path Resolution" section that references the new session-init fields.

### Phase 4: Task file path replacement

Replace all `./tmp/` and `*/.issues/` patterns in task files with project-root-anchored paths. The `*/.issues/` pattern is replaced with explicit path construction from session-init repo entries.

### Phase 5: Bug fix

Fix `mkdir -p */.issues/<issue_number>/` in `github-mcp/SKILL.md` line 94.

### Phase 6: Behavioral tests

Write behavioral enforcement tests that verify the agent resolves paths against project root when inside a submodule.

## Success Criteria

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

### Core Table

| ID | Criterion | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | session-init emits `project_root` as an absolute path matching `git rev-parse --show-toplevel` | Run `./.opencode/tools/session-init` and grep stdout for `project_root: /` | If missing: add `echo "project_root: $(git rev-parse --show-toplevel)"` to session-init output | Phase 1 | `.opencode/.issues/1678/phase1/` | MUST emit project_root | Phase 1 | pre-commit | standalone | — | null | — | Phase 1 |
| SC-2 | session-init emits `is_submodule_context` as a boolean (`true`/`false`) matching `is_submodule_context()` return value | Run `./.opencode/tools/session-init` and grep stdout for `is_submodule_context: true\|false` | If missing: add `echo "is_submodule_context: $(is_submodule_context && echo true || echo false)"` to session-init output | Phase 1 | `.opencode/.issues/1678/phase1/` | MUST emit is_submodule_context | Phase 1 | pre-commit | standalone | — | null | — | Phase 1 |
| SC-3 | Existing session-init output fields are unchanged (additive-only constraint) | Diff session-init output before and after change — only `project_root` and `is_submodule_context` lines differ | If other fields change: revert and re-implement with additive-only approach | Phase 1 | `.opencode/.issues/1678/phase1/` | MUST NOT change existing fields | Phase 1 | pre-commit | standalone | — | null | — | Phase 1 |
| SC-4 | `000-critical-rules.md` contains a new Tier 2 rule: all task file paths are relative to project root, not submodule root | Grep `000-critical-rules.md` for "project.root" or "project_root" in a rule definition | If missing: add the rule with proper tier, conditions, and actions | Phase 2 | `.opencode/.issues/1678/phase2/` | MUST add project-root path rule | Phase 2 | pre-commit | standalone | — | null | — | Phase 2 |
| SC-5 | `060-tool-usage.md` replaces "Workdir-Aware Path Composition" section with "Project-Root Path Resolution" section referencing session-init fields | Grep `060-tool-usage.md` for "Project-Root Path Resolution" section header | If missing: replace the workdir-aware section with project-root section | Phase 3 | `.opencode/.issues/1678/phase3/` | MUST update path resolution section | Phase 3 | pre-commit | standalone | — | null | — | Phase 3 |
| SC-6 | All `./tmp/` patterns in task files (`.opencode/skills/*/tasks/*.md`) are replaced with project-root-anchored paths | Run `grep -r '\./tmp/' .opencode/skills/*/tasks/*.md` — zero matches | If matches remain: replace each with `{project_root}/tmp/` pattern | Phase 4 | `.opencode/.issues/1678/phase4/` | MUST replace all ./tmp/ patterns | Phase 4 | pre-commit | standalone | — | null | — | Phase 4 |
| SC-7 | All `*/.issues/` patterns in task files (`.opencode/skills/*/tasks/*.md`) are replaced with explicit path construction | Run `grep -r '\*/.issues/' .opencode/skills/*/tasks/*.md` — zero matches | If matches remain: replace each with `{project_root}/{path}/.issues/{N}/` construction | Phase 4 | `.opencode/.issues/1678/phase4/` | MUST replace all */.issues/ patterns | Phase 4 | pre-commit | standalone | — | null | — | Phase 4 |
| SC-8 | `github-mcp/SKILL.md` no longer contains `mkdir -p */.issues/` | Grep `github-mcp/SKILL.md` for `mkdir -p \*/.issues/` — zero matches | If match remains: replace with correct project-root-anchored path | Phase 5 | `.opencode/.issues/1678/phase5/` | MUST fix mkdir bug | Phase 5 | pre-commit | standalone | — | null | — | Phase 5 |
| SC-9 | Behavioral enforcement test exists in `.opencode/tests/behaviors/` that verifies agent resolves paths against project root when inside a submodule | Run `bash .opencode/tests/behaviors/path-resolution.sh` — exits 0 | If test missing or failing: write behavioral test with stderr-based assertions | Phase 6 | `.opencode/.issues/1678/phase6/` | MUST have behavioral test | Phase 6 | pre-commit | standalone | — | null | — | Phase 6 |
| SC-10 | Behavioral enforcement test exists that verifies agent does NOT create literal `*` directories when constructing `.issues/` paths | Run `bash .opencode/tests/behaviors/no-literal-star-dir.sh` — exits 0 | If test missing or failing: write behavioral test with stderr-based assertions | Phase 6 | `.opencode/.issues/1678/phase6/` | MUST have behavioral test | Phase 6 | pre-commit | standalone | — | null | — | Phase 6 |
| SC-11 | Behavioral tests are written BEFORE implementation (RED state confirmed) | Check git log: behavioral test commits predate source change commits | If tests written after: revert and re-implement with RED-first TDD | Phase 6 | `.opencode/.issues/1678/phase6/` | MUST have RED-first tests | Phase 6 | pre-commit | standalone | — | null | — | Phase 6 |

### Evidence Type Classification

| SC | Affects Runtime Behavior? | Evidence Type | Rationale |
|----|-------------------------|---------------|-----------|
| SC-1 | NO | `string` | session-init output is static text; verified by grep |
| SC-2 | NO | `string` | session-init output is static text; verified by grep |
| SC-3 | NO | `string` | Diff comparison; verified by git diff |
| SC-4 | NO | `string` | Rule text presence; verified by grep |
| SC-5 | NO | `string` | Section header presence; verified by grep |
| SC-6 | NO | `string` | Pattern absence; verified by grep |
| SC-7 | NO | `string` | Pattern absence; verified by grep |
| SC-8 | NO | `string` | Pattern absence; verified by grep |
| SC-9 | YES | `behavioral` | Agent path resolution is runtime behavior; verified by opencode-cli run |
| SC-10 | YES | `behavioral` | Agent directory creation is runtime behavior; verified by opencode-cli run |
| SC-11 | NO | `string` | Git log check; verified by git log |

## Risk and Edge Cases

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | session-init output change breaks downstream consumers that parse specific line positions | Low | High | Additive-only constraint (SC-3); new fields appended at end | SC-3 |
| RISK-2 | Path replacement misses some task files | Medium | Medium | Exhaustive grep sweep with zero-match verification (SC-6, SC-7) | SC-6, SC-7 |
| RISK-3 | Behavioral test flakes due to model variability | Medium | Medium | Use stderr-based assertions (not prose-recall); add timeout configuration | SC-9, SC-10 |
| RISK-4 | `is_submodule_context` detection is incorrect for edge-case submodule layouts | Low | Medium | Verify against `git rev-parse --show-toplevel` comparison | SC-2 |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | `project_root` emitted as absolute path from `git rev-parse --show-toplevel` | Already computed internally; no new computation needed | MUST | SC-1 |
| DEC-2 | `is_submodule_context` emitted as boolean from existing function | Already exists; no new detection logic needed | MUST | SC-2 |
| DEC-3 | Additive-only — new fields appended, existing fields unchanged | Prevents breaking downstream consumers | MUST | SC-3 |
| DEC-4 | `*/.issues/` replaced with explicit path construction, not a new variable | Keeps session-init output minimal; consumers already have repo path data | MUST | SC-7 |
| DEC-5 | Behavioral tests use stderr-based assertions, not prose-recall prompts | Stderr shows actual agent actions (tool dispatches, file reads) | MUST | SC-9, SC-10 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Decomposition Classification

| Classification | Number of Phases | Sub-Issue Requirements | PR Strategy |
| -------------- | ---------------- | ---------------------- | ----------- |
| multi-phase | 6 | One sub-issue per phase | stacked PRs per phase |

## Cross-Cutting SCs

SC-3 (additive-only constraint) — verified once in Phase 1, applies to all subsequent phases.

## Non-Goals

- **env-loader changes** — env-loader is a separate pipeline with its own naming convention (UPPER_CASE); session-init changes do not cascade to env-loader
- **Issue routing logic** — which repo an issue belongs to remains resolved by session-init's `## Repo Information` section
- **Non-task-file documentation** — AGENTS.md, README.md, and other non-task-file references are out of scope

## Regression Invariants

1. Existing session-init output fields MUST remain unchanged (SC-3)
2. All existing issue routing behavior MUST remain unchanged
3. All existing git workflow behavior MUST remain unchanged

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `session-init` line 63 (`PROJECT_ROOT` computation) | Verify project_root already computed internally |
| Direct source search | `session-init` lines 473-493 (`is_submodule_context()`) | Verify submodule detection already exists |
| Direct source search | `grep -r '\./tmp/' .opencode/skills/*/tasks/*.md` | Count ./tmp/ occurrences (100+) |
| Direct source search | `grep -r '\*/.issues/' .opencode/skills/*/tasks/*.md` | Count */.issues/ occurrences (42) |
| Direct source search | `grep -r '\./tmp/' .opencode/guidelines/*.md` | Count ./tmp/ in guidelines (47) |
| Direct source search | `github-mcp/SKILL.md` line 94 | Verify `mkdir -p */.issues/` bug |

## AI Agent Instructions

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1678/plan.md` before implementation begins.

Before any implementation, write behavioral enforcement tests in `.opencode/tests/behaviors/` that verify the new rules; confirm RED state (test fails before change). If the tests are missing from the working tree when implementation begins, they must be re-created before any source changes.

Behavioral tests MUST use stderr-based assertion helpers (`assert_stderr_pattern_present`/`assert_stderr_pattern_absent_all_models`) to verify agent actions (skill dispatches, file reads, tool invocations). Prose-recall prompts are NOT accepted as valid behavioral tests.

Co-authored with AI: OpenCode (deepseek-v4-flash)
