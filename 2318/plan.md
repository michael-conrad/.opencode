---
plan_schema_version: "1.0"
issue: 2318
title: "Root-repo-only tooling in multi-module checkouts"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
---

# Implementation Plan — #2318 — Root-repo-only tooling in multi-module checkouts

Issue: https://github.com/michael-conrad/.opencode/issues/2318

**Goal:** Author a Tier 2 (process-integrity) rule in the canonical `.opencode/AGENTS.md` requiring agents to use ONLY the repo root's build tool or its project-local tools for build/test in a multi-module checkout, prohibiting submodule toolchain invention/alteration, with a developer-authorization carve-out, and enforce it with behavioral tests.

**Architecture:** Author the rule text in the canonical `.opencode/AGENTS.md` `## Boundaries (Critical)` section (Phase 1), add Read-Link cross-references to `060-tool-usage.md` and `085-project-local-tools.md` (Phase 2), and add behavioral enforcement test scenarios that exercise the rule's Tier 2 HALT framing and developer-authorization carve-out (Phase 3). The rule is classified Tier 2 (process-integrity, developer-authorizable) — HALT by default with no `CRITICAL VIOLATION` header, per critical-rules-018. Guidance stays framework-agnostic (git submodules OR toolchain-native multi-module) with no hardcoded repo-specific build commands.

**Files:**
- `.opencode/AGENTS.md` (canonical rules — rule text, cross-references)
- `.opencode/tests-v2/behaviors/` (behavioral enforcement test scenarios)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Rule substance | `test-driven-development` | `red` | `.opencode/AGENTS.md`, behavioral test scenarios | SC-1, SC-2, SC-3, SC-6, SC-7, SC-8 | — |
| 2 — Cross-referencing | `test-driven-development` | `red` | `.opencode/AGENTS.md` | SC-9 | 1 |
| 3 — Behavioral enforcement test | `test-driven-development` | `red` | `.opencode/tests-v2/behaviors/2318-sc4-tier2-halt-framing.sh`, `.opencode/tests-v2/behaviors/2318-sc5-dev-authorization-carveout.sh` | SC-4, SC-5 | 1 |

---

## Phase Details

### Phase 1 — Rule substance

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/AGENTS.md` `## Boundaries (Critical)` section, behavioral test scenarios |
| SCs | SC-1, SC-2, SC-3, SC-6, SC-7, SC-8 |
| Depends On | — |

**Context:**
```yaml
rule_location: ".opencode/AGENTS.md ## Boundaries (Critical)"
rule_classification: Tier 2 process-integrity (HALT, no CRITICAL VIOLATION header, dev-authorizable)
root_tooling_requirement: "use ONLY the repo root's build tool or the repo root's project-local tools for build/test in a multi-module checkout"
submodule_prohibition: "do NOT create or modify a submodule to add a competing toolchain"
framework_agnostic: true
hardcoded_commands: none
behavioral_test_harness: ".opencode/tests-v2/behaviors/ (with-test-home-wrapped opencode run, session.yaml clean-room inspection, >=600s bash-tool timeout)"
```

### Phase 2 — Cross-referencing

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/AGENTS.md` rule cross-references |
| SCs | SC-9 |
| Depends On | 1 |

**Context:**
```yaml
cross_reference_targets:
  - ".opencode/guidelines/060-tool-usage.md"
  - ".opencode/guidelines/085-project-local-tools.md"
cross_reference_format: "Read [Text](path) per the Read-Link Cross-Reference Rule"
```

### Phase 3 — Behavioral enforcement test

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/2318-sc4-tier2-halt-framing.sh`, `.opencode/tests-v2/behaviors/2318-sc5-dev-authorization-carveout.sh` |
| SCs | SC-4, SC-5 |
| Depends On | 1 |

**Context:**
```yaml
behavioral_test_harness: ".opencode/tests-v2/behaviors/ (with-test-home-wrapped opencode run, session.yaml clean-room sub-agent inspection, >=600s bash-tool timeout)"
sc4_scenario: "submodule toolchain invention/alteration results in HALT by default, framed as Tier 2 with no CRITICAL VIOLATION header"
sc5_scenario: "explicit developer authorization allows intentional submodule tooling setup"
```

---

## Exit Criteria

- [ ] C1. SC-1 PASS: In a multi-module checkout, the agent uses ONLY the repo root's build tool for build and test (behavioral).
- [ ] C2. SC-2 PASS: In a multi-module checkout, the agent uses ONLY the repo root's project-local tools for build and test (behavioral).
- [ ] C3. SC-3 PASS: The agent does NOT create or modify a submodule to add a competing toolchain (behavioral).
- [ ] C4. SC-4 PASS: A submodule toolchain invention/alteration results in a HALT by default, framed as Tier 2 with no `CRITICAL VIOLATION` header (behavioral).
- [ ] C5. SC-5 PASS: Explicit developer authorization allows intentional submodule tooling setup (behavioral).
- [ ] C6. SC-6 PASS: The guidance applies uniformly to both git submodules and toolchain-native multi-module arrangements (structural).
- [ ] C7. SC-7 PASS: The guidance contains no hardcoded repo-specific build commands or tool names (structural).
- [ ] C8. SC-8 PASS: The rule is authored in the canonical `.opencode/AGENTS.md` (string).
- [ ] C9. SC-9 PASS: Every cross-reference from the rule to other guidance uses the Read-Link Cross-Reference Rule (`Read [Text](path)`) (string).

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-26T18:06:12Z | `plan_created` | Plan file `.opencode/.issues/2318/plan.md` verified, phase count = 3 |
