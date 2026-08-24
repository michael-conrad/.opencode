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
| 3 | **Approach Chosen** | Author a Tier 2 (process-integrity) rule in the canonical `.opencode/AGENTS.md` `## Boundaries (Critical)` section requiring agents to use ONLY the root repo's build tool or its project-local tools for build/test in a multi-module checkout, and prohibiting submodule toolchain invention/alteration. Enforce as a Tier 2 HALT-by-default with an explicit developer-authorization carve-out for intentional submodule tooling. Cross-reference the rule to `060-tool-usage.md` and `085-project-local-tools.md`. |
| 4 | **Alternatives Considered & Why Discarded** | (a) Add the rule to `060-tool-usage.md` (Tier 1) as a `CRITICAL VIOLATION` — discarded because the spec explicitly classifies this as Tier 2 (process-integrity, developer-authorizable), not Tier 1 safety-critical. (b) Rely on repo-specific toolchains already present — discarded because it cannot generalize across git submodules and toolchain-native multi-module arrangements. (c) Automatic remediation of existing conflicting submodule toolchains — discarded, explicitly out of scope (no auto-remediation). |
| 5 | **Key Design Decisions** | (1) Author the rule in canonical `.opencode/AGENTS.md` so it carries into every consumer repo (decision: canonical placement over repo-local guideline; tradeoff: must remain general and not reference repo-specific build commands). (2) Classify as Tier 2 process-integrity (HALT, no `CRITICAL VIOLATION`, dev-authorizable per critical-rules-018) rather than Tier 1 (tradeoff: default HALT yields to developer authorization — this permits intentional submodule tooling). (3) Cross-reference `060-tool-usage.md` and `085-project-local-tools.md` using the Read-Link pattern; `085` is referenced, not modified (tradeoff: keeps project-local tool definition authoritative). |
| 6 | **User Intent / Original Prompt** | Add a process-integrity rule requiring agents to use only the root repo's build tool or project-local tools for build/test in a multi-module checkout, prohibiting creation/alteration of submodules to add competing toolchains, classified as Tier 2 with a developer-authorization carve-out. |

## 2. Not Included

- **Changes to any specific repo's build configuration or toolchain** — the spec targets the agent-facing rule in `.opencode/AGENTS.md`, not any consumer repo's build files.
- **Hardcoding repo-specific build commands or tool names** — guidance stays framework-agnostic; `gradlew/build.gradle` appears only as an illustrative `e.g.`.
- **Automatic remediation of existing conflicting submodule toolchains** — no migration or cleanup of current conflicts.
- **A Tier 1 safety-critical rule** — this is explicitly Tier 2 (process-integrity, developer-authorizable), not Tier 1.
- **A plugin/session-enforcement.ts code change** — Tier 2 rules are prose-level HALT; no plugin change required.
- **Modification to `085-project-local-tools.md` project-local tool definitions** — that guideline is referenced, not changed.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | In a multi-module checkout, the agent uses ONLY the root repo's build tool or the root repo's project-local tools for build/test, and does NOT invent or alter submodules to add competing toolchains. | behavioral | Behavioral enforcement test via `opencode run` (with-test-home); assert stderr shows root-tooling selection and no submodule toolchain creation |
| SC-2 | The rule is classified Tier 2 (process-integrity): a submodule toolchain invention/alteration results in a HALT by default, but explicit developer authorization allows intentional submodule tooling setup. | behavioral | Behavioral test asserting HALT-without-`CRITICAL VIOLATION` framing and the developer-authorization carve-out path |
| SC-3 | The guidance is framework-agnostic and general, applying to both git submodules and toolchain-native multi-module arrangements, containing no hardcoded repo-specific build commands. | structural | Structural inspection of the authored text for framework-agnostic phrasing and absence of hardcoded repo-specific command names |
| SC-4 | The rule is authored in the canonical `.opencode/AGENTS.md` (and/or a referenced guideline as the sub-agent determines) so it carries into every consumer repo, using the Read-Link Cross-Reference Rule. | string | String/file-location verification that the rule exists in `.opencode/AGENTS.md` and uses `Read [Text](path)` cross-references |

### Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Running the behavioral test costs minutes of bounded execution time. Skipping it means a submodule toolchain invention defect ships to every consumer repo and costs exponentially more to fix downstream.
- SC-2: Running the behavioral test costs minutes. Skipping it means the HINT/carve-out framing is unverified and the rule mis-fires as a Tier 3 flag or hard block in production.
- SC-3: Inspecting the authored text costs a read call. Skipping it means a repo-specific build command leaks in and breaks generality across consumer repos.
- SC-4: Verifying the file location and cross-reference format costs one read. Skipping it means the rule is not carried into consumer repos and agents never see the constraint.

## 4. Requirements

- R-1. In a multi-module checkout, the agent SHALL use only the root repo's build tool or the root repo's project-local tools for build and test.
- R-2. The agent SHALL NOT create or modify a submodule to add a competing toolchain.
- R-3. The rule SHALL be classified as Tier 2 (process-integrity), producing a HALT by default on submodule toolchain invention/alteration.
- R-4. The rule SHALL provide an explicit developer-authorization carve-out for intentional submodule tooling setup.
- R-5. The guidance SHALL be framework-agnostic, applying to both git submodules and toolchain-native multi-module arrangements.
- R-6. The guidance SHALL NOT hardcode repo-specific build commands or tool names.
- R-7. The rule SHALL be authored in the canonical `.opencode/AGENTS.md` so it carries into every consumer repo.
- R-8. Any cross-reference from the rule to other guidance SHALL use the Read-Link Cross-Reference Rule pattern (`Read [Text](path)`).

## 5. Items

Per-SC item enumeration. Each SC maps to exactly one item; each item maps to exactly one SC.

### Item 1 (SC-1): Root-repo-only tooling rule substance

- RED: Behavioral enforcement test asserting stderr does NOT show submodule toolchain invention/alteration and DOES show root tooling selection (currently absent).
- GREEN: Author the rule in `.opencode/AGENTS.md` requiring root-repo-only build/test tooling in multi-module checkouts.
- verify: Behavioral test passes (assert_stderr_pattern_present/absent).
- commit: Rule text in `.opencode/AGENTS.md` + behavioral test scenario.

### Item 2 (SC-2): Tier 2 HALT classification and developer-authorization carve-out

- RED: Behavioral test asserting HALT-without-`CRITICAL VIOLATION` framing on a violation and the dev-authorization carve-out path.
- GREEN: Author the rule with Tier 2 HALT framing (no `CRITICAL VIOLATION` header) and explicit developer-authorization carve-out for intentional submodule tooling.
- verify: Behavioral test passes on HALT framing + carve-out.
- commit: Tier 2 framing + carve-out text.

### Item 3 (SC-3): Framework-agnostic phrasing

- RED: Structural check asserting no hardcoded repo-specific build commands.
- GREEN: Ensure the authored text uses framework-agnostic phrasing (git submodules AND toolchain-native multi-module), with only generic `e.g.` illustration.
- verify: Structural inspection of authored text.
- commit: Framework-agnostic phrasing.

### Item 4 (SC-4): Canonical placement and Read-Link cross-references

- RED: Structural check asserting the rule is absent from canonical `.opencode/AGENTS.md` and/or lacks Read-Link format.
- GREEN: Place the rule in canonical `.opencode/AGENTS.md` and add Read-Link cross-references to `060-tool-usage.md` / `085-project-local-tools.md`.
- verify: File-location + cross-reference-format check.
- commit: Canonical placement + Read-link references.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/AGENTS.md` | Canonical rules file that carries the new rule into consumer repos | Satisfied (present) |
| `085-project-local-tools.md` | Authoritative definition of allowed root project-local tools; referenced (not modified) | Satisfied (present) |
| `060-tool-usage.md` | Governs tool selection tier hierarchy; provides the existing `--recursive` submodule prohibition analog | Satisfied (present) |
| `000-critical-rules.md` | Defines the Tier 2 process-integrity model (critical-rules-018) that classifies the new rule | Satisfied (present) |
| Behavioral enforcement test (critical-rules-009) | Mandate requiring a behavioral test for any rule that changes agent runtime behavior | Pending (created in Phase 3) |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-1 | Phase 1 |
| R-3 | SC-2 | Phase 1 |
| R-4 | SC-2 | Phase 1 |
| R-5 | SC-3 | Phase 2 |
| R-6 | SC-3 | Phase 2 |
| R-7 | SC-4 | Phase 2 |
| R-8 | SC-4 | Phase 2 |

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

- **SC-1:** Running the behavioral test costs minutes of bounded execution time. Skipping means a submodule toolchain invention defect ships to every consumer repo and costs exponentially more to fix downstream.
- **SC-2:** Running the behavioral test costs minutes. Skipping means the Tier 2 HINT framing is unverified and the carve-out mis-fires in production.
- **SC-3:** Inspecting the authored text costs one read call. Skipping means a hardcoded repo-specific command ships and defeats generality.
- **SC-4:** Verifying file location and cross-reference format costs one read. Skipping means the rule never reaches consumer repos.

## 11. Edge Cases

### Input boundaries

- **Condition:** A multi-module checkout uses git submodules only.
- **Expected behavior:** Rule applies; agent uses root repo's build tool or root project-local tools.
- **Resolution:** Framework-agnostic phrasing (SC-3) covers git-submodule-only arrangements.

- **Condition:** A multi-module checkout uses toolchain-native multi-module (e.g., a workspace) without git submodules.
- **Expected behavior:** Rule applies identically.
- **Resolution:** Framework-agnostic phrasing covers toolchain-native arrangements.

### State transitions

- **Condition:** Agent needs a build/test step in a multi-module checkout.
- **Expected behavior:** Agent transitions to ROOT_TOOLING (allowed) — uses root repo build tool or root project-local tools.
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
- **Expected behavior:** SC-1/SC-2 are FAIL — no structural substitution.
- **Resolution:** Per `critical-rules-060`, report FAIL, remediate, re-verify.

### Concurrency

- **Condition:** Two agents operate in the same multi-module checkout concurrently.
- **Expected behavior:** Both must follow the root-repo-only tooling rule.
- **Resolution:** Rule is agent-facing and applies uniformly to all agents.

### Recovery

- **Condition:** A submodule toolchain was already invented/created.
- **Expected behavior:** Out of scope — no automatic remediation.
- **Resolution:** Documented as out of scope; future builds follow the root-tooling rule.

---
<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
