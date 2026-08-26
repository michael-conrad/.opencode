<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->
# [SPEC] Root-repo-only tooling in multi-module checkouts

> **Full spec and artifacts: [`.opencode/.issues/2318/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2318)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2318/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | In a multi-module checkout (git submodules or a toolchain-native multi-module arrangement), the AI agent invents and alters submodules to add dedicated tooling (package.json/build.gradle/Node/gradle/etc.) that immediately conflicts with the root repo's existing toolkit and project-local tools. This produces competing toolchains, wasted work, and build/test breakage. |
| 2 | **Root Cause / Motivation** | The canonical agent rules in `.opencode/AGENTS.md` govern submodule pointer discipline but contain no rule prohibiting the creation or alteration of submodules to add competing toolchains. Without an explicit rule, the agent defaults to inventing submodule-local tooling when a build/test step is needed in a multi-module checkout, producing conflict and rework. The rule must be added now so every repo consuming this config inherits the constraint. |
| 3 | **Approach Chosen** | Author a Tier 2 (process-integrity) rule in the canonical `.opencode/AGENTS.md` `## Boundaries (Critical)` section requiring agents to use ONLY the repo root's build tool or its project-local tools for build/test in a multi-module checkout, and prohibiting submodule toolchain invention/alteration. Enforce as a Tier 2 HALT-by-default with an explicit developer-authorization carve-out for intentional submodule tooling. Cross-reference the rule to `060-tool-usage.md` and `085-project-local-tools.md`. |
| 4 | **Alternatives Considered & Why Discarded** | (a) Add the rule to `060-tool-usage.md` (Tier 1) as a `CRITICAL VIOLATION` — discarded because the spec explicitly classifies this as Tier 2 (process-integrity, developer-authorizable), not Tier 1 safety-critical. (b) Rely on repo-specific toolchains already present — discarded because it cannot generalize across git submodules and toolchain-native multi-module arrangements. (c) Automatic remediation of existing conflicting submodule toolchains — discarded, explicitly out of scope (no auto-remediation). |
| 5 | **Key Design Decisions** | (1) Author the rule in canonical `.opencode/AGENTS.md` so it carries into every consumer repo (decision: canonical placement over repo-local guideline; tradeoff: must remain general and not reference repo-specific build commands). (2) Classify as Tier 2 process-integrity (HALT, no `CRITICAL VIOLATION`, dev-authorizable per critical-rules-018) rather than Tier 1 (tradeoff: default HALT yields to developer authorization — this permits intentional submodule tooling). (3) Cross-reference `060-tool-usage.md` and `085-project-local-tools.md` using the Read-Link pattern; `085` is referenced, not modified (tradeoff: keeps project-local tool definition authoritative). |
| 6 | **User Intent / Original Prompt** | Add a process-integrity rule requiring agents to use only the repo root's build tool or project-local tools for build/test in a multi-module checkout, prohibiting creation/alteration of submodules to add competing toolchains, classified as Tier 2 with a developer-authorization carve-out. |

## 2. Not Included

- **Changes to any specific repo's build configuration or toolchain** — the spec targets the agent-facing rule in `.opencode/AGENTS.md`, not any consumer repo's build files.
- **Hardcoding repo-specific build commands or tool names** — guidance stays framework-agnostic; `gradlew/build.gradle` appears only as an illustrative `e.g.`.
- **Automatic remediation of existing conflicting submodule toolchains** — no migration or cleanup of current conflicts.
- **A Tier 1 safety-critical rule** — this is explicitly Tier 2 (process-integrity, developer-authorizable), not Tier 1.
- **A plugin/session-enforcement.ts code change** — Tier 2 rules are prose-level HALT; no plugin change required.
- **Modification to `085-project-local-tools.md` project-local tool definitions** — that guideline is referenced, not changed.

## 3. Success Criteria

Each success criterion is a single atomic, independently verifiable claim (one concern per SC). The Success Criteria cover two behavioral enforcement-test groups (Phase 3) and the structural/string text attributes authored in Phases 1 and 2.

### Phase 1 / Phase 3 — Rule substance and enforcement (behavioral)

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | In a multi-module checkout, the agent uses ONLY the repo root's build tool for build and test. | behavioral | Behavioral enforcement test via `opencode run` wrapped by `with-test-home` (>=600s bash-tool timeout); behavioral evaluation of the exported `session.yaml` (SQLite event-table export) via clean-room sub-agent inspection per `.opencode/tests-v2/AGENTS.md`, asserting root build-tool selection in recorded agent actions; no structural substitution |
| SC-2 | In a multi-module checkout, the agent uses ONLY the repo root's project-local tools for build and test. | behavioral | Behavioral enforcement test via `opencode run` wrapped by `with-test-home` (>=600s bash-tool timeout); behavioral evaluation of the exported `session.yaml` via clean-room sub-agent inspection per `.opencode/tests-v2/AGENTS.md`, asserting root project-local-tool selection in recorded agent actions; no structural substitution |
| SC-3 | The agent does NOT create or modify a submodule to add a competing toolchain. | behavioral | Behavioral enforcement test via `opencode run` wrapped by `with-test-home` (>=600s bash-tool timeout); behavioral evaluation of the exported `session.yaml` via clean-room sub-agent inspection per `.opencode/tests-v2/AGENTS.md`, asserting absence of submodule toolchain creation/alteration in recorded agent actions; no structural substitution |
| SC-4 | A submodule toolchain invention/alteration results in a HALT by default, framed as Tier 2 with no `CRITICAL VIOLATION` header. | behavioral | Behavioral enforcement test via `opencode run` wrapped by `with-test-home` (>=600s bash-tool timeout); behavioral evaluation of the exported `session.yaml` via clean-room sub-agent inspection per `.opencode/tests-v2/AGENTS.md`, evaluating HALT-without-`CRITICAL VIOLATION` framing from the session record; no structural substitution |
| SC-5 | Explicit developer authorization allows intentional submodule tooling setup. | behavioral | Behavioral enforcement test via `opencode run` wrapped by `with-test-home` (>=600s bash-tool timeout); behavioral evaluation of the exported `session.yaml` via clean-room sub-agent inspection per `.opencode/tests-v2/AGENTS.md`, evaluating that the developer-authorization carve-out path is honored in the session record; no structural substitution |

### Phase 1 — Rule text substance (structural)

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-6 | The guidance applies uniformly to both git submodules and toolchain-native multi-module arrangements. | structural | Structural inspection of the authored text for framework-agnostic coverage of both arrangements |
| SC-7 | The guidance contains no hardcoded repo-specific build commands or tool names. | structural | Structural inspection of the authored text for absence of hardcoded repo-specific command names |
| SC-8 | The rule is authored in the canonical `.opencode/AGENTS.md`. | string | String/file-location verification that the rule exists in `.opencode/AGENTS.md` |

### Phase 2 — Cross-referencing (string)

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-9 | Every cross-reference from the rule to other guidance uses the Read-Link Cross-Reference Rule (`Read [Text](path)`). | string | String/file-location + cross-reference-format verification of `Read [Text](path)` references in the rule |

### Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1 through SC-5: Running the behavioral tests costs minutes of bounded execution time each. Skipping them means a submodule toolchain invention defect ships to every consumer repo and costs exponentially more to fix downstream.
- SC-6 and SC-7: Inspecting the authored text costs a read call. Skipping them means a repo-specific build command leaks in and breaks generality across consumer repos.
- SC-8: Verifying the file location costs one read. Skipping it means the rule is not placed in canonical `.opencode/AGENTS.md` and never reaches consumer repos.
- SC-9: Verifying the cross-reference format costs one read. Skipping it means the rule does not propagate its citations to consumer repos.

## 4. Requirements

- R-1. In a multi-module checkout, the agent SHALL use only the repo root's build tool or the repo root's project-local tools for build and test.
- R-2. The agent SHALL NOT create or modify a submodule to add a competing toolchain.
- R-3. The rule SHALL be classified as Tier 2 (process-integrity), producing a HALT by default on submodule toolchain invention/alteration.
- R-4. The rule SHALL provide an explicit developer-authorization carve-out for intentional submodule tooling setup.
- R-5. The guidance SHALL be framework-agnostic, applying to both git submodules and toolchain-native multi-module arrangements.
- R-6. The guidance SHALL NOT hardcode repo-specific build commands or tool names.
- R-7. The rule SHALL be authored in the canonical `.opencode/AGENTS.md` so it carries into every consumer repo.
- R-8. Any cross-reference from the rule to other guidance SHALL use the Read-Link Cross-Reference Rule pattern (`Read [Text](path)`).

## 5. Phases and Items

Per-SC item enumeration. Each SC maps to exactly one item; each item maps to exactly one SC. Phase numbering is carried through from the analytical artifacts (blast-radius.yaml / concern-map.yaml): Phase 1 = rule substance, Phase 2 = cross-referencing, Phase 3 = behavioral enforcement test.

### Phase 1 — Rule substance (author the Tier 2 root-repo-only tooling rule in `.opencode/AGENTS.md`)

#### Item 1 (SC-1): Root build tool only

- RED: Behavioral enforcement test asserting via `session.yaml` clean-room sub-agent inspection the absence of submodule-local build-tool usage and the presence of exclusive root build-tool selection in recorded agent actions (currently fails — rule absent).
- GREEN: Author the rule in `.opencode/AGENTS.md` requiring root-repo-only build tooling in multi-module checkouts.
- verify: Behavioral test passes via `session.yaml` clean-room sub-agent inspection.
- commit: Rule text in `.opencode/AGENTS.md` + behavioral test scenario.

#### Item 2 (SC-2): Root project-local tools only

- RED: Behavioral enforcement test asserting via `session.yaml` clean-room sub-agent inspection the presence of root project-local-tool selection in recorded agent actions (currently fails — rule absent).
- GREEN: Ensure the rule text covers root project-local tools per `085-project-local-tools.md`.
- verify: Behavioral test passes via `session.yaml` clean-room sub-agent inspection.
- commit: Project-local-tools coverage in rule text + behavioral test scenario.

#### Item 3 (SC-3): No submodule toolchain invention/alteration

- RED: Behavioral enforcement test asserting via `session.yaml` clean-room sub-agent inspection the absence of submodule toolchain creation/alteration in recorded agent actions (currently fails — rule absent).
- GREEN: Author the rule text prohibiting submodule toolchain invention/alteration.
- verify: Behavioral test passes via `session.yaml` clean-room sub-agent inspection.
- commit: Prohibition text + behavioral test scenario.

#### Item 6 (SC-6): Framework-agnostic phrasing

- RED: Structural check asserting the rule covers git submodules AND toolchain-native multi-module arrangements.
- GREEN: Ensure the authored text uses framework-agnostic phrasing covering both arrangements, with only generic `e.g.` illustration.
- verify: Structural inspection of authored text.
- commit: Framework-agnostic phrasing.

#### Item 7 (SC-7): No hardcoded repo-specific commands

- RED: Structural check asserting no hardcoded repo-specific build commands are present.
- GREEN: Keep the rule text free of repo-specific build commands or tool names.
- verify: Structural inspection of authored text.
- commit: Command-free wording.

#### Item 8 (SC-8): Canonical placement

- RED: Structural check asserting the rule is absent from canonical `.opencode/AGENTS.md`.
- GREEN: Place the rule in canonical `.opencode/AGENTS.md`.
- verify: File-location verification that the rule exists in `.opencode/AGENTS.md`.
- commit: Canonical placement.

### Phase 2 — Cross-referencing (Read-Link to 060-tool-usage / 085-project-local-tools)

#### Item 9 (SC-9): Read-Link cross-references

- RED: Structural check asserting the rule's cross-references lack `Read [Text](path)` format.
- GREEN: Add Read-Link cross-references from the rule to `060-tool-usage.md` and `085-project-local-tools.md`.
- verify: Cross-reference-format verification of `Read [Text](path)` pattern.
- commit: Read-Link references.

### Phase 3 — Behavioral enforcement test (agent behavior change)

#### Item 4 (SC-4): Tier 2 HALT classification framing

- RED: Behavioral test asserting HALT-without-`CRITICAL VIOLATION` framing on a violation (currently absent).
- GREEN: Author the rule with Tier 2 HALT framing (no `CRITICAL VIOLATION` header) on submodule toolchain invention/alteration.
- verify: Behavioral test passes on HALT framing via `session.yaml` clean-room sub-agent inspection.
- commit: Tier 2 HALT framing text.

#### Item 5 (SC-5): Developer-authorization carve-out

- RED: Behavioral test asserting the developer-authorization carve-out path is honored (currently absent).
- GREEN: Author the explicit developer-authorization carve-out for intentional submodule tooling setup.
- verify: Behavioral test passes on the carve-out path via `session.yaml` clean-room sub-agent inspection.
- commit: Carve-out text.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/AGENTS.md` | Canonical rules file that carries the new rule into consumer repos | Satisfied (present) |
| `085-project-local-tools.md` | Authoritative definition of allowed root project-local tools; referenced (not modified) | Satisfied (present) |
| `060-tool-usage.md` | Governs tool selection tier hierarchy; provides the existing `--recursive` submodule prohibition analog | Satisfied (present) |
| `000-critical-rules.md` | Defines the Tier 2 process-integrity model (critical-rules-018) that classifies the new rule | Satisfied (present) |
| Behavioral enforcement test (critical-rules-009) | Mandate requiring a behavioral test for any rule that changes agent runtime behavior | Pending (created in Phase 3) |
| Behavioral enforcement test harness (`.opencode/tests-v2`) | Infrastructure presupposed by all five Phase 3 verification methods: `with-test-home`-wrapped `opencode run`, `session.yaml` export as PRIMARY evaluation source, clean-room sub-agent inspection, >=600s bash-tool timeout convention | Satisfied (present) |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1, SC-2 | Phase 3 |
| R-2 | SC-3 | Phase 3 |
| R-3 | SC-4 | Phase 3 |
| R-4 | SC-5 | Phase 3 |
| R-5 | SC-6 | Phase 1 |
| R-6 | SC-7 | Phase 1 |
| R-7 | SC-8 | Phase 1 |
| R-8 | SC-9 | Phase 2 |

Note: R-1 and R-2 govern agent build/test behavior and are verified behaviorally; their enforcement tests live in Phase 3 even though the rule text is authored in Phase 1. R-3 through R-5 similarly verify runtime behavior via the Phase 3 test harness. R-5 through R-8 verify static text properties and are checked in the phase where the text is produced (Phase 1 for the rule body, Phase 2 for cross-references).

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `.opencode/AGENTS.md` | config | `{{project_root}}/.opencode/AGENTS.md` | Read during pre-spec inspection |
| `060-tool-usage.md` | guideline | `.opencode/guidelines/060-tool-usage.md` | Read during pre-spec inspection |
| `085-project-local-tools.md` | guideline | `.opencode/guidelines/085-project-local-tools.md` | Read during pre-spec inspection |
| `000-critical-rules.md` | guideline | `.opencode/guidelines/000-critical-rules.md` | Read during pre-spec inspection |
| critical-rules-009 (enforcement test mandate) | guideline | `000-critical-rules.md` | Read during pre-spec inspection |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1 through SC-5:** Running the behavioral tests costs minutes of bounded execution time. Skipping means a submodule toolchain invention defect ships to every consumer repo and costs exponentially more to fix downstream.
- **SC-6 and SC-7:** Inspecting the authored text costs a read call. Skipping means a hardcoded repo-specific command ships and defeats generality.
- **SC-8:** Verifying the file location costs one read. Skipping means the rule never reaches consumer repos.
- **SC-9:** Verifying the cross-reference format costs one read. Skipping means the rule does not propagate its citations to consumers.

## 11. Edge Cases

### Input boundaries

- **Condition:** A multi-module checkout uses git submodules only.
- **Expected behavior:** Rule applies; agent uses repo root's build tool or root project-local tools.
- **Resolution:** Framework-agnostic phrasing (SC-6) covers git-submodule-only arrangements.

- **Condition:** A multi-module checkout uses toolchain-native multi-module (e.g., a workspace) without git submodules.
- **Expected behavior:** Rule applies identically.
- **Resolution:** Framework-agnostic phrasing covers toolchain-native arrangements.

### State transitions

- **Condition:** Agent needs a build/test step in a multi-module checkout.
- **Expected behavior:** Agent transitions to ROOT_TOOLING (allowed) — uses repo root build tool or root project-local tools.
- **Resolution:** Default path under the rule.

- **Condition:** Agent attempts to invent/alter a submodule toolchain without developer authorization.
- **Expected behavior:** HALT (default), Tier 2 framing.
- **Resolution:** Dev-authorization carve-out is the only transition to SUBMODULE_AUTHORIZED.

### Failure modes

- **Condition:** Rule is too vague to trigger HALT.
- **Expected behavior:** HALT does not fire; the rule fails its enforcement purpose.
- **Resolution:** Concrete Tier 2 gate + explicit carve-out wording (per Impact mitigation).

- **Condition:** Rule over-reaches and blocks intentional submodule tooling.
- **Expected behavior:** Intentional setup is blocked.
- **Resolution:** Explicit developer-authorization carve-out permits it.

- **Condition:** Behavioral test cannot execute.
- **Expected behavior:** SC-1 through SC-5 are FAIL — no structural substitution.
- **Resolution:** Per `critical-rules-060`, report FAIL, remediate, re-verify.

### Concurrency

- **Condition:** Two agents operate in the same multi-module checkout concurrently.
- **Expected behavior:** Both must follow the root-repo-only tooling rule.
- **Resolution:** Rule is agent-facing and applies uniformly to all agents.

### Recovery

- **Condition:** A submodule toolchain was already invented/created.
- **Expected behavior:** Out of scope — no automatic remediation.
- **Resolution:** Documented as out of scope; future builds follow the root-tooling rule.

## 12. Change Control

| Date | Revision | Authorizer | What Changed | Why |
|------|----------|------------|--------------|-----|
| 2026-08-24 | v2 | spec-creation validation | Decomposed four compound SCs into nine atomic SCs; removed `and/or` and `as the sub-agent determines` from SC-4 placement; made SC-4/SC-8 deterministic and consistent with R-7's absolute SHALL; split SC-1 into atomic root-build-tool and project-local-tools SCs; carried the Phase 1/2/3 numbering (behavioral enforcement test as distinct Phase 3) through Success Criteria, Items, and Traceability. | Holistic validation findings: (1) SC-4 determinism/escape-hatch, (2) compound SCs, (3) `or`/`and-or` binary verifiability, (4) phase-numbering inconsistency. Evidence types preserved: SC-1..SC-5 behavioral, SC-6/SC-7 structural, SC-8/SC-9 string. Tier 2 process-integrity classification and framework-agnostic phrasing preserved. |

---
<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
