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

**Architecture:** Author the rule text in the canonical `.opencode/AGENTS.md` `## Boundaries (Critical)` section (Phase 1), add Read-Link cross-references to `060-tool-usage.md` and `085-project-local-tools.md` (Phase 2), and add behavioral enforcement test scenarios that exercise the rule's root-tooling exclusivity (SC-1, SC-2, SC-3), Tier 2 HALT framing (SC-4), and developer-authorization carve-out (SC-5) (Phase 3). The rule is classified Tier 2 (process-integrity, developer-authorizable) — HALT by default with no `CRITICAL VIOLATION` header, per critical-rules-018. Guidance stays framework-agnostic (git submodules OR toolchain-native multi-module) with no hardcoded repo-specific build commands. SC-1/SC-2/SC-3 rule text and RED behavioral scenarios are authored in Phase 1; their behavioral verification executes in Phase 3 (per spec Section 7 traceability note and concern-map phase_3 scs).

**Files:**
- `.opencode/AGENTS.md` (canonical rules — rule text, cross-references)
- `.opencode/tests-v2/behaviors/` (behavioral enforcement test scenarios: 2318-sc1, 2318-sc2, 2318-sc3, 2318-sc4, 2318-sc5)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Rule substance | `test-driven-development` | `red` | `.opencode/AGENTS.md`; behavioral scenarios `2318-sc1-root-build-tool.sh`, `2318-sc2-root-project-local-tools.sh`, `2318-sc3-submodule-toolchain-prohibition.sh` | SC-1, SC-2, SC-3, SC-6, SC-7, SC-8 | — |
| 2 — Cross-referencing | `test-driven-development` | `red` | `.opencode/AGENTS.md` | SC-9 | 1 |
| 3 — Behavioral enforcement test | `test-driven-development` | `red` | `.opencode/tests-v2/behaviors/2318-sc1-root-build-tool.sh`, `.opencode/tests-v2/behaviors/2318-sc2-root-project-local-tools.sh`, `.opencode/tests-v2/behaviors/2318-sc3-submodule-toolchain-prohibition.sh`, `.opencode/tests-v2/behaviors/2318-sc4-tier2-halt-framing.sh`, `.opencode/tests-v2/behaviors/2318-sc5-dev-authorization-carveout.sh` | SC-1, SC-2, SC-3, SC-4, SC-5 | 1 |

---

## Phase Details

### Phase 1 — Rule substance

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/AGENTS.md` `## Boundaries (Critical)` section; behavioral scenarios `2318-sc1-root-build-tool.sh`, `2318-sc2-root-project-local-tools.sh`, `2318-sc3-submodule-toolchain-prohibition.sh` |
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
sc1_scenario: ".opencode/tests-v2/behaviors/2318-sc1-root-build-tool.sh (RED: root build-tool selection only)"
sc2_scenario: ".opencode/tests-v2/behaviors/2318-sc2-root-project-local-tools.sh (RED: root project-local-tool selection only)"
sc3_scenario: ".opencode/tests-v2/behaviors/2318-sc3-submodule-toolchain-prohibition.sh (RED: no submodule toolchain creation/alteration)"
```

**Procedure (numbered steps):**
1. **Coherence gate (clean-room).** Verify the plan faithfully derives from the approved spec #2318: every SC-1..SC-9 maps to exactly one plan item, evidence types are preserved (SC-1..SC-5 behavioral, SC-6/SC-7 structural, SC-8/SC-9 string), and the phase DAG (phase 1 → phase 2, phase 1 → phase 3) is acyclic and matches the structure artifact.
2. **Baseline check (clean-room).** Confirm the feature branch is at trunk-tip, submodules are clean, and `.opencode/AGENTS.md` `## Boundaries (Critical)` currently contains no root-repo-only tooling rule and no submodule toolchain prohibition.
3. **Item 1 (SC-1) RED (sub-agent).** Write the failing behavioral scenario `2318-sc1-root-build-tool.sh` asserting via `session.yaml` clean-room sub-agent inspection the absence of submodule-local build-tool usage and the presence of exclusive root build-tool selection (the test fails because the rule is absent). Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
4. **Item 1 (SC-1) GREEN (sub-agent).** Author the rule in `.opencode/AGENTS.md` requiring root-repo-only build tooling in multi-module checkouts. No scope creep. Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
5. **Item 1 (SC-1) verify (clean-room).** Verify SC-1: the behavioral scenario passes via `session.yaml` clean-room sub-agent inspection, asserting root build-tool selection. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
6. **Item 1 (SC-1) commit (inline).** Commit the rule text and `2318-sc1-root-build-tool.sh` together as one atomic slice.
7. **Item 2 (SC-2) RED (sub-agent).** Write the failing behavioral scenario `2318-sc2-root-project-local-tools.sh` asserting via `session.yaml` clean-room sub-agent inspection the presence of root project-local-tool selection. Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
8. **Item 2 (SC-2) GREEN (sub-agent).** Ensure the rule text covers root project-local tools per `085-project-local-tools.md`. Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
9. **Item 2 (SC-2) verify (clean-room).** Verify SC-2: the behavioral scenario passes via `session.yaml` clean-room sub-agent inspection, asserting root project-local-tool selection. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
10. **Item 2 (SC-2) commit (inline).** Commit the project-local-tools coverage and `2318-sc2-root-project-local-tools.sh` as one atomic slice.
11. **Item 3 (SC-3) RED (sub-agent).** Write the failing behavioral scenario `2318-sc3-submodule-toolchain-prohibition.sh` asserting via `session.yaml` clean-room sub-agent inspection the absence of submodule toolchain creation/alteration. Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
12. **Item 3 (SC-3) GREEN (sub-agent).** Author the rule text prohibiting submodule toolchain invention/alteration. Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
13. **Item 3 (SC-3) verify (clean-room).** Verify SC-3: the behavioral scenario passes via `session.yaml` clean-room sub-agent inspection, asserting absence of submodule toolchain creation/alteration. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
14. **Item 3 (SC-3) commit (inline).** Commit the prohibition text and `2318-sc3-submodule-toolchain-prohibition.sh` as one atomic slice.
15. **Item 6 (SC-6) RED (sub-agent).** Write a failing structural check asserting the rule does not yet cover both git submodules AND toolchain-native multi-module arrangements. Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
16. **Item 6 (SC-6) GREEN (sub-agent).** Ensure the authored text uses framework-agnostic phrasing covering both arrangements, with only generic `e.g.` illustration. Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
17. **Item 6 (SC-6) verify (clean-room).** Verify SC-6: structural inspection confirms framework-agnostic coverage of both arrangements. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
18. **Item 6 (SC-6) commit (inline).** Commit the framework-agnostic phrasing as one atomic slice.
19. **Item 7 (SC-7) RED (sub-agent).** Write a failing structural check asserting hardcoded repo-specific build commands are present. Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
20. **Item 7 (SC-7) GREEN (sub-agent).** Keep the rule text free of repo-specific build commands or tool names. Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
21. **Item 7 (SC-7) verify (clean-room).** Verify SC-7: structural inspection confirms absence of hardcoded repo-specific command names. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
22. **Item 7 (SC-7) commit (inline).** Commit the command-free wording as one atomic slice.
23. **Item 8 (SC-8) RED (sub-agent).** Write a failing structural check asserting the rule is absent from canonical `.opencode/AGENTS.md`. Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
24. **Item 8 (SC-8) GREEN (sub-agent).** Place the rule in canonical `.opencode/AGENTS.md`. Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
25. **Item 8 (SC-8) verify (clean-room).** Verify SC-8: file-location verification that the rule exists in `.opencode/AGENTS.md`. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
26. **Item 8 (SC-8) commit (inline).** Commit the canonical placement as one atomic slice.
27. **Phase 1 VbC (clean-room).** Verify all SC-1, SC-2, SC-3, SC-6, SC-7, SC-8 verdicts are clean PASS (SC-1..SC-3 evidence is `behavioral`; SC-6/SC-7 evidence is `structural`; SC-8 evidence is `string`; any `DONE_WITH_CONCERNS` is coerced to FAIL per the implementation-workflow coercion rules). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.

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

**Procedure (numbered steps):**
1. **Item 9 (SC-9) RED (sub-agent).** Write a failing structural check asserting the rule's cross-references lack `Read [Text](path)` format. Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
2. **Item 9 (SC-9) GREEN (sub-agent).** Add Read-Link cross-references from the rule to `060-tool-usage.md` and `085-project-local-tools.md`. Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
3. **Item 9 (SC-9) verify (clean-room).** Verify SC-9: structural inspection confirms every cross-reference from the rule uses the `Read [Text](path)` pattern. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
4. **Item 9 (SC-9) commit (inline).** Commit the Read-Link cross-references as one atomic slice.

### Phase 3 — Behavioral enforcement test

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/2318-sc1-root-build-tool.sh`, `.opencode/tests-v2/behaviors/2318-sc2-root-project-local-tools.sh`, `.opencode/tests-v2/behaviors/2318-sc3-submodule-toolchain-prohibition.sh`, `.opencode/tests-v2/behaviors/2318-sc4-tier2-halt-framing.sh`, `.opencode/tests-v2/behaviors/2318-sc5-dev-authorization-carveout.sh` |
| SCs | SC-1, SC-2, SC-3, SC-4, SC-5 |
| Depends On | 1 |

**Context:**
```yaml
behavioral_test_harness: ".opencode/tests-v2/behaviors/ (with-test-home-wrapped opencode run, session.yaml clean-room sub-agent inspection, >=600s bash-tool timeout)"
sc1_scenario: ".opencode/tests-v2/behaviors/2318-sc1-root-build-tool.sh — behavioral verification of root build-tool selection only (authored Phase 1, verified here)"
sc2_scenario: ".opencode/tests-v2/behaviors/2318-sc2-root-project-local-tools.sh — behavioral verification of root project-local-tool selection only (authored Phase 1, verified here)"
sc3_scenario: ".opencode/tests-v2/behaviors/2318-sc3-submodule-toolchain-prohibition.sh — behavioral verification of no submodule toolchain creation/alteration (authored Phase 1, verified here)"
sc4_scenario: "submodule toolchain invention/alteration results in HALT by default, framed as Tier 2 with no CRITICAL VIOLATION header"
sc5_scenario: "explicit developer authorization allows intentional submodule tooling setup"
```

**Procedure (numbered steps):**
1. **Item 4 (SC-4) RED (sub-agent).** Write the failing behavioral scenario `2318-sc4-tier2-halt-framing.sh` asserting HALT-without-`CRITICAL VIOLATION` framing on a submodule toolchain invention/alteration violation (the test fails because the rule is absent). Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
2. **Item 4 (SC-4) GREEN (sub-agent).** Author the rule with Tier 2 HALT framing (no `CRITICAL VIOLATION` header) on submodule toolchain invention/alteration. Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
3. **Item 4 (SC-4) verify (clean-room).** Verify SC-4: the behavioral scenario passes on HALT framing via `session.yaml` clean-room sub-agent inspection, evaluating HALT-without-`CRITICAL VIOLATION` framing from the session record. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
4. **Item 4 (SC-4) commit (inline).** Commit the Tier 2 HALT framing text and `2318-sc4-tier2-halt-framing.sh` as one atomic slice.
5. **Item 5 (SC-5) RED (sub-agent).** Write the failing behavioral scenario `2318-sc5-dev-authorization-carveout.sh` asserting the developer-authorization carve-out path is honored (the test fails because the carve-out is absent). Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
6. **Item 5 (SC-5) GREEN (sub-agent).** Author the explicit developer-authorization carve-out for intentional submodule tooling setup. Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
7. **Item 5 (SC-5) verify (clean-room).** Verify SC-5: the behavioral scenario passes on the carve-out path via `session.yaml` clean-room sub-agent inspection, evaluating that the developer-authorization carve-out path is honored in the session record. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
8. **Item 5 (SC-5) commit (inline).** Commit the carve-out text and `2318-sc5-dev-authorization-carveout.sh` as one atomic slice.
9. **SC-1 behavioral verification (clean-room).** Execute the Phase 1-authored scenario `2318-sc1-root-build-tool.sh` via `session.yaml` clean-room sub-agent inspection, confirming exclusive root build-tool selection in recorded agent actions. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
10. **SC-2 behavioral verification (clean-room).** Execute the Phase 1-authored scenario `2318-sc2-root-project-local-tools.sh` via `session.yaml` clean-room sub-agent inspection, confirming root project-local-tool selection in recorded agent actions. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
11. **SC-3 behavioral verification (clean-room).** Execute the Phase 1-authored scenario `2318-sc3-submodule-toolchain-prohibition.sh` via `session.yaml` clean-room sub-agent inspection, confirming absence of submodule toolchain creation/alteration in recorded agent actions. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
12. **Phase 3 VbC (clean-room).** Verify SC-1, SC-2, SC-3, SC-4, SC-5 verdicts are clean PASS (evidence is `behavioral` via `session.yaml` clean-room inspection; any `DONE_WITH_CONCERNS` is coerced to FAIL per the implementation-workflow coercion rules). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
13. **Post-implementation audit (clean-room).** Run adversarial audit of the deliverable (DiMo investigator → validator → evaluator → arbiter). Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read audit/tasks/verification-audit-investigator.md first")`, followed by validator, evaluator, arbiter in sequence.
14. **Z3 check (inline).** Run Z3 constraint solver verification: `.opencode/tools/solve check --state-path ... --contract-path ...`. Confirm the phase dependency DAG and state transitions are satisfied.
15. **Structural checks (sub-agent).** Run the finishing checklist (lint, typecheck, etc.). Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`.
16. **Pre-PR gate (clean-room).** Read all SC verdicts (SC-1..SC-9); BLOCK if any verdict is FAIL. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
17. **Regression check (sub-agent).** Run final regression check before PR. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
18. **Review prep (sub-agent).** Prepare PR review context. Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read git-workflow-pr/tasks/review-prep.md first")`.
19. **Create PR (sub-agent).** Create the pull request (requires `for_pr` scope or explicit instruction). Dispatch `task(..., prompt: "execute create task from git-workflow-pr")`.
20. **Completion summary (clean-room).** Generate completion executive summary. Dispatch `task(..., prompt: "execute completion task from completion-core")`.

---

## Exit Criteria

Each criterion below is verified against the SC-to-phase mapping: SC-1, SC-2, SC-3, SC-6, SC-7, SC-8 are authored in **Phase 1**; SC-9 is implemented in **Phase 2**; the behavioral verification of SC-1, SC-2, SC-3, SC-4, SC-5 executes in **Phase 3**.

- [ ] **C1 (Phase 3) — SC-1 PASS:** In a multi-module checkout, the agent uses ONLY the repo root's build tool for build and test (behavioral; verified via `2318-sc1-root-build-tool.sh`).
- [ ] **C2 (Phase 3) — SC-2 PASS:** In a multi-module checkout, the agent uses ONLY the repo root's project-local tools for build and test (behavioral; verified via `2318-sc2-root-project-local-tools.sh`).
- [ ] **C3 (Phase 3) — SC-3 PASS:** The agent does NOT create or modify a submodule to add a competing toolchain (behavioral; verified via `2318-sc3-submodule-toolchain-prohibition.sh`).
- [ ] **C4 (Phase 3) — SC-4 PASS:** A submodule toolchain invention/alteration results in a HALT by default, framed as Tier 2 with no `CRITICAL VIOLATION` header (behavioral; verified via `2318-sc4-tier2-halt-framing.sh`).
- [ ] **C5 (Phase 3) — SC-5 PASS:** Explicit developer authorization allows intentional submodule tooling setup (behavioral; verified via `2318-sc5-dev-authorization-carveout.sh`).
- [ ] **C6 (Phase 1) — SC-6 PASS:** The guidance applies uniformly to both git submodules and toolchain-native multi-module arrangements (structural).
- [ ] **C7 (Phase 1) — SC-7 PASS:** The guidance contains no hardcoded repo-specific build commands or tool names (structural).
- [ ] **C8 (Phase 1) — SC-8 PASS:** The rule is authored in the canonical `.opencode/AGENTS.md` (string).
- [ ] **C9 (Phase 2) — SC-9 PASS:** Every cross-reference from the rule to other guidance uses the Read-Link Cross-Reference Rule (`Read [Text](path)`) (string).

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-26T18:06:12Z | `plan_created` | Plan file `.opencode/.issues/2318/plan.md` verified, phase count = 3 |
| 2026-08-26T18:20:00Z | `plan_revised` | Applied writing-plans validate findings: added per-phase numbered Procedure steps, added SC-to-phase mapping to Exit Criteria, enumerated SC-1/SC-2/SC-3 behavioral scenarios in Phase 1 and Phase 3 targets, aligned Phase 3 SCs to concern-map [SC-1..SC-5], updated dependency-contract Phase 3 SCs/files |
| 2026-08-26T18:27:13Z | `plan_created` | Plan file `.opencode/.issues/2318/plan.md` verified, phase count = 3 |
