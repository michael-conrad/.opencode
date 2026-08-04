---
remote_issue: 2243
remote_url: "https://github.com/michael-conrad/.opencode/issues/2243"
last_sync: 2026-08-04T17:39:28Z
source: github
---

## Problem Statement

Python projects have no standardized dependency injection approach. Developers use manual parameter-passing — `config` and `secrets` objects threaded through call chains via Click context (`ctx.obj['config']`, `ctx.obj['secrets']`). As codebases grow, this leads to tightly coupled code, difficult testing, and inconsistent patterns across projects. Without a mandated DI framework, each project reinvents its own wiring approach.

## Success Criteria

| ID | Description | Evidence Type | Documentation Sources | Cost Frame |
|----|-------------|---------------|----------------------|------------|
| SC-1 | A "Dependency Injection" section SHALL be added to `.opencode/guidelines/080-code-standards.md` covering: what DI is, why it is required, the mandated library (`dependency-injector`), usage patterns, and the carveout for `.opencode/` infrastructure tools | behavioral | `.opencode/guidelines/080-code-standards.md` | Every project that reinvents its own wiring instead of using a standard DI framework produces code that is harder to test, harder to refactor, and harder for new engineers to understand. The cost of standardizing now is one section in a guidelines file. The cost of not standardizing is cumulative coupling across every Python project that adopts these standards. |
| SC-2 | `.opencode/guidelines/INDEX.md` SHALL be updated to include DI-related trigger patterns (`dependency injection`, `di`, `inject`, `container`) in the `080-code-standards.md` row | structural | `.opencode/guidelines/INDEX.md` | An INDEX.md that does not route agents to the DI section when they encounter DI-related patterns means the section might as well not exist. The trigger patterns are the delivery mechanism — without them, the mandate is invisible to the agents that need to follow it. |
| SC-3 | The carveout for `.opencode/` infrastructure tools SHALL be documented within the DI section (contained within SC-1) | structural | `.opencode/guidelines/080-code-standards.md` | A mandate without carveouts is a mandate that gets ignored when it does not fit. Explicitly exempting small self-contained scripts prevents the DI requirement from becoming a nuisance that erodes compliance for the cases where it actually matters. |

## Approach

1. Add a new "Dependency Injection" section to `.opencode/guidelines/080-code-standards.md` after the "Libraries & Packages" section, before "Print Statements & Output"
2. Update the `080-code-standards.md` row in `.opencode/guidelines/INDEX.md` to add DI-related trigger patterns

### Library Choice: dependency-injector

| Metric | dependency-injector | injector |
|--------|-------------------|----------|
| GitHub stars | ~4,900 | ~1,500 |
| PyPI monthly downloads | ~7.7M | ~3.8M |
| PyPI total downloads | 131.7M | 110.0M |
| Latest release | 4.49.1 (Aug 2026) | 0.24.0 (Jan 2026) |
| Async support | Yes | No |
| Config injection | YAML, INI, JSON, env vars, Pydantic | None |
| Cython acceleration | Yes | No |
| Provider override | `.override()` on-the-fly | Module replacement |

`dependency-injector` wins across all dimensions: more features, Cython acceleration, active development, and a growing adoption gap (2x monthly downloads gap vs 1.2x total, indicating accelerating divergence). It is the "Spring of Python DI."

### Carveout

The following paths are explicitly exempt from the DI mandate:
- `.opencode/tools/` — standalone PEP 723 inline-script executables
- `.opencode/scripts/` — standalone Python and bash scripts
- `.opencode/skills/*/scripts/` — skill-specific scripts

These are small self-contained scripts where DI adds no value and would increase complexity.

## Affected Files

| File | Action | Repo |
|------|--------|------|
| `.opencode/guidelines/080-code-standards.md` | Modify — add DI section | michael-conrad/.opencode |
| `.opencode/guidelines/INDEX.md` | Modify — add trigger patterns | michael-conrad/.opencode |

## Phases

| Phase | Scope | Repo | Depends On |
|-------|-------|------|------------|
| 1 | Guideline updates (080-code-standards.md, INDEX.md) | michael-conrad/.opencode | None |

## Blast Radius

MINIMAL — documentation-only change affecting 2 files in a single repo. No code changes, no interface changes, no state transitions. All changes are additive (new section, new row) with zero modification to existing content.

## Cross-Cutting Concerns

- **Submodule workflow:** Affected files live in the `.opencode/` submodule — requires a PR to `michael-conrad/.opencode`
- **AI agent behavior:** New guideline section will affect how AI agents write Python code — a behavioral enforcement test SHALL be included
- **Documentation consistency:** New section MUST follow existing formatting, tone, and structure of `080-code-standards.md`

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-04 | Removed SC-3 (optional `ButterWordCounts/AGENTS.md` DI mention) and its dependent Phase 2; renumbered SC-4 → SC-3; removed all Butter/NewSRX references; made Problem Statement repo-agnostic | SC-3 referenced the non-existent `NewSRX-Tech-LLC/Butter` repo (`ButterWordCounts/AGENTS.md`), making it structurally unimplementable | Issue revision (spec-creation revise) |
