# Plan: Audit and remediate "Cards" → "Scope of Work" rename blast radius

**Issue:** #1905
**Spec path:** `.opencode/.issues/1905/spec.md`
**Scope:** `.opencode/` submodule — skills task files, guidelines, behavioral tests, enforcement tests
**Authorization scope:** `for_pr`
**Halt at:** `pr_created`
**Plan type:** Multi-phase (3 phases — audit, remediate, validate)

## Goal

Audit the full blast radius of 8 format-alignment changes from #1902 across all `.opencode/*/tasks/*.md`, `guidelines/*.md`, `tests/behaviors/*.sh`, and `tests/*.sh`. Classify every match as DIRECT/PATTERN-MATCH/DOMAIN-DIFFERENT/GENERIC-PROSE. Remediate DIRECT and PATTERN-MATCH matches. Validate format consistency and test suite pass.

## Architecture

```
Phase 1 (Audit)     → Phase 2 (Remediate)   → Phase 3 (Validate)
  grep × 8 changes     apply DIRECT updates     cross-skill validation
  classify matches     apply PATTERN-MATCH      test suite pass
  produce audit log    leave DOMAIN-DIFFERENT   format consistency check
```

## Files Affected (Search Scope)

| Directory | File Types | Risk |
|-----------|------------|------|
| `.opencode/skills/*/tasks/*.md` | Task files | HIGH — cross-references to Step 7, Cards heading, section ordering |
| `.opencode/guidelines/*.md` | Guidelines | MEDIUM — spec template references |
| `.opencode/skills/*/SKILL.md` | Skill cards | MEDIUM — description patterns referencing format |
| `.opencode/tests/behaviors/*.sh` | Behavioral tests | HIGH — assertions on old format strings |
| `.opencode/tests/*.sh` | Enforcement tests | MEDIUM — grep patterns on spec format |

## Phase Table

| Phase | Title | Steps | Concern |
|-------|-------|-------|---------|
| 1 | Audit — Full blast radius scan | 1–5 | Discover all matches across 8 changes × all files |
| 2 | Remediate — Apply updates | 6–9 | Update DIRECT and PATTERN-MATCH matches |
| 3 | Validate — Consistency & test suite | 10–12 | Cross-skill validation, format check, test run |

## Success Criteria Mapping

| SC ID | Criterion | Plan Steps |
|-------|-----------|------------|
| SC-1 | All `.opencode/skills/*/tasks/*.md` audited — DIRECT matches updated | 1, 2, 6, 7 |
| SC-2 | All `.opencode/guidelines/*.md` audited — no stale format references | 1, 3, 6, 7 |
| SC-3 | All test files audited — no assertions on old format | 1, 4, 6, 7 |
| SC-4 | Cross-references to old Step 7 numbering eliminated | 2, 7 |
| SC-5 | AI Agent Instructions enforcement is gate-level, not inline | 5, 7 |
| SC-6 | Format consistency validated — `validate_skill_cards.py` passes, test suite green | 10, 11, 12 |

## Exit Criteria

- [ ] All 8 changes × all files audited — audit log produced at `1905/audit-log.md`
- [ ] All DIRECT and PATTERN-MATCH matches remediated
- [ ] Domain-different and generic-prose matches documented as verified-unaffected
- [ ] Format consistency validation passes
- [ ] Behavioral enforcement test suite green
- [ ] `validate_skill_cards.py` passes
