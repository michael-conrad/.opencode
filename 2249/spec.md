> **Full spec and artifacts: [`.opencode/.issues/2249/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2249)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2249/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# SPEC — Generalize the dependency-injection mandate to a generic multi-language DI approach

## 1. Intent and Executive Summary

### Problem Statement

`.opencode/guidelines/080-code-standards.md` currently mandates a single Python-specific dependency-injection library (`dependency-injector`) via #2243. But agents write code and unit tests in many languages — C#/.NET, Java, Kotlin, Scala, Dart/Flutter, TypeScript, Go, Rust, C++, Swift, Ruby, and web frameworks. Without a generic mandate, agents writing in a non-Python language either hand-roll manual wiring (threading `config`/`secrets` objects through call chains) or pick a framework arbitrarily. The result is the same coupling, untestable code, and reinvention that #2243 addressed for Python — repeated in every other language with no consistent standard.

### Root Cause / Motivation

The #2243 mandate is scoped to Python and pins a specific library (`dependency-injector`). It does not generalize. There is no rule telling an agent writing a C# service or a TypeScript app to use *a* DI approach. The gap is a missing generic principle: approach problem solving and unit tests from the point of view of having an available DI approach of some worth, and use it rather than hand-rolling manual wiring. The enforceable rule is "use a DI approach," not "use framework X." Without this, every language reinvents its own wiring and each project produces tightly coupled, hard-to-test code.

### Approach Chosen

Add a single generic "Dependency Injection (generic mandate)" section to `080-code-standards.md` after the "Libraries & Packages" section, containing: (1) a generic principle statement, (2) a curated per-language framework table in three advisory tiers (Clear standard / Contested / Non-idiomatic and guidance-only), (3) selection guidance driven by code analysis and spec requirements rather than a fixed pin, with combinations allowed when the framework table documents two or more idiomatic DI options for the same language, and (4) an explicit HTML/CSS exclusion (markup and styling are not programming languages). Update the `080-code-standards.md` row in `INDEX.md` to add DI-related trigger patterns. Add a behavioral enforcement test (Two-SC pattern) verifying agents apply the DI mandate across languages. This is a superset of #2243's Python mandate, not a replacement — Python remains in the "Clear standard" tier with `dependency-injector`. Sequenced after #2243 merges to avoid contradiction.

### Alternatives Considered & Why Discarded

**Rely on the existing #2243 Python-only mandate.** Discarded: it covers only Python. Agents writing in other languages receive no guidance and default to hand-rolled wiring or arbitrary framework choice, reproducing the coupling #2243 was designed to eliminate.

**Pin a single universal DI framework across all languages.** Discarded: no single framework is idiomatic or even viable across the language spectrum. A fixed universal pin would be non-idiomatic in most languages (e.g., Go and Rust have no dominant container), producing worse code than hand-rolled wiring. The curated table is explicitly advisory and tiered precisely because the right answer is language- and ecosystem-dependent.

**Mandate "no manual wiring ever."** Discarded: for small, self-contained, or non-idiomatic languages (Go, Rust, C++, Swift, Ruby, web components), hand-rolled wiring or framework-free approaches are sometimes the correct engineering choice. The mandate targets using a DI approach *where one exists*; the non-idiomatic tier is explicitly guidance-only, not an enforcement pin.

### Key Design Decisions

- **The enforceable rule is "use a DI approach," not "use framework X."** Agents must approach problem solving and unit tests from the point of view of having an available DI approach of some worth, and prefer it over manual wiring where such an approach exists. This is the generic principle, and it is a superset that contains #2243's Python mandate.
- **The curated framework table is explicitly advisory and tiered.** Three tiers — Clear standard, Contested, Non-idiomatic and guidance-only — give agents per-language guidance without imposing a fixed pin. Selection is driven by code analysis and spec requirements.
- **Python remains in the "Clear standard" tier with `dependency-injector`.** Consistent with #2243; the generic mandate does not replace or contradict the Python-specific mandate.
- **HTML/CSS are explicitly excluded.** Markup and styling are not programming languages, so DI guidance does not apply.
- **Behavioral enforcement uses the Two-SC pattern** (artifact generation + clean-room `session.yaml` evaluation), because this is an agent-behavior rule and string/grep evidence would be EVIDENCE_TYPE_MISMATCH. Per critical-rules-BEH-EV, the guideline change affects runtime behavior (how agents write code and unit tests across languages), so SCs MUST declare behavioral evidence type.

### User Intent / Original Prompt

Spec-creation create step for a follow-up spec to `#2243` (Python dependency-injector mandate) in the `.opencode` repo that generalizes the DI mandate to cover other languages in a generic fashion. Confirmed design from brainstorming: generic principle + curated framework table (three advisory tiers) + selection guidance + HTML/CSS exclusion. Single-task spec, sequenced after #2243 merges, superset of #2243.

## 2. Not Included

- **Replacing or removing the #2243 Python-specific `dependency-injector` mandate.** The generic mandate is a superset, not a replacement. Python remains in the "Clear standard" tier.
- **Pinning a single universal DI framework across all languages.** Explicitly discarded; the curated table is advisory and tiered.
- **Mandating "no manual wiring ever."** The mandate targets using a DI approach where one exists; non-idiomatic languages are guidance-only.
- **Modifying `.opencode/tools/`, `.opencode/scripts/`, or skill task files.** No runtime tooling change.
- **Changing any existing section of `080-code-standards.md`.** All changes are additive (new section, new trigger patterns). Existing anchors and cross-references are preserved.
- **Altering #2243's carveout for `.opencode/` infrastructure tools.** Unchanged; preserved by #2243.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | A generic "Dependency Injection (generic mandate)" section SHALL be added to `.opencode/guidelines/080-code-standards.md` stating the generic principle: approach problem solving and unit tests from the point of view of having an available DI approach of some worth, and use it rather than hand-rolling manual wiring where such an approach exists. The enforceable rule SHALL be "use a DI approach," not "use framework X." | behavioral | Run the SC-1 behavior scenario via `bash .opencode/tests-v2/with-test-home opencode run`; clean-room sub-agent reads `session.yaml` and verifies the agent applied the generic DI principle (chose a DI approach) for a solution where a DI approach exists. |
| SC-2 | The generic section SHALL include a curated per-language framework table that is explicitly advisory and organized into three tiers: (1) Clear standard — Python (`dependency-injector`), C#/.NET (built-in `Microsoft.Extensions.DependencyInjection`), Java (Spring; Dagger for GWT-style), Angular/Vue/Svelte (built-in); (2) Contested — Kotlin (Koin/Hilt), Scala (MacWire/Guice/ZIO), Dart/Flutter (get_it/provider/Riverpod), TypeScript (tsyringe/InversifyJS); (3) Non-idiomatic and guidance-only — Go, Rust, C++, Swift, Ruby, React (Context/hooks), Web Components. | behavioral | Run the SC-2 behavior scenario via `with-test-home`; clean-room sub-agent reads `session.yaml` and verifies the agent applied the tiered guidance appropriately for a given language. |
| SC-3 | The generic section SHALL include selection guidance stating that framework choice is driven by code analysis and spec requirements, not a fixed pin, and that combinations of DI approaches are allowed when the framework table documents two or more idiomatic DI options for the same language. | behavioral | Run the SC-3 behavior scenario via `with-test-home`; clean-room sub-agent reads `session.yaml` and verifies the agent selected a DI approach based on code/spec context rather than a fixed pin. |
| SC-4 | The generic section SHALL explicitly exclude HTML/CSS, stating that markup and styling are not programming languages and DI guidance does not apply. | behavioral | Run the SC-4 behavior scenario via `with-test-home`; clean-room sub-agent reads `session.yaml` and verifies the agent did NOT attempt a DI approach on markup/styling. |
| SC-5 | `.opencode/guidelines/INDEX.md` SHALL be updated to include DI-related trigger patterns (`dependency injection`, `di`, `inject`, `container`) in the `080-code-standards.md` row. | structural | `grep` `INDEX.md` for the DI trigger patterns in the `080-code-standards.md` row returns a match. |
| SC-6 | A behavioral enforcement test SHALL be added under `.opencode/tests-v2/behaviors/` that dispatches a real-domain prompt via `opencode run` requiring the agent to design a solution/unit test where a DI approach exists, producing `session.yaml` artifacts. | behavioral | Run the SC-6 scenario via `with-test-home`; confirm a `session.yaml` artifact is produced recording agent tool calls and decisions. |
| SC-7 | A clean-room sub-agent SHALL evaluate the `session.yaml` artifact and confirm the agent applied the DI mandate (selected a DI approach rather than hand-rolling manual wiring), covering at least one "Clear standard" language and one "Contested"/"Non-idiomatic" language, and confirming the HTML/CSS exclusion. | behavioral | Clean-room sub-agent reads `session.yaml` (from SC-6) and verifies DI-mandate compliance per the test design notes. |

## 4. Requirements

- R-1. `.opencode/guidelines/080-code-standards.md` SHALL include a generic "Dependency Injection (generic mandate)" section stating the generic principle: approach problem solving and unit tests from the point of view of having an available DI approach of some worth, and use it rather than hand-rolling manual wiring where such an approach exists. The enforceable rule SHALL be "use a DI approach," not "use framework X."
- R-2. The generic section SHALL include a curated per-language framework table, explicitly advisory, with three tiers: Clear standard (Python `dependency-injector`, C#/.NET built-in M.E.DI, Java Spring / Dagger for GWT-style, Angular/Vue/Svelte built-in), Contested (Kotlin Koin/Hilt, Scala MacWire/Guice/ZIO, Dart/Flutter get_it/provider/Riverpod, TypeScript tsyringe/InversifyJS), and Non-idiomatic and guidance-only (Go, Rust, C++, Swift, Ruby, React Context/hooks, Web Components).
- R-3. The generic section SHALL include selection guidance: framework choice is driven by code analysis and spec requirements, not a fixed pin; combinations of DI approaches SHALL be allowed when the framework table documents two or more idiomatic DI options for the same language.
- R-4. The generic section SHALL explicitly exclude HTML/CSS, stating that markup and styling are not programming languages and DI guidance does not apply.
- R-5. `.opencode/guidelines/INDEX.md` SHALL include DI-related trigger patterns (`dependency injection`, `di`, `inject`, `container`) in the `080-code-standards.md` row, preserving existing trigger patterns.
- R-6. A behavioral enforcement test SHALL be added under `.opencode/tests-v2/behaviors/` using the Two-SC pattern (SC-6 artifact generation + SC-7 clean-room `session.yaml` evaluation) per §6a of `tests-v2/AGENTS.md`.
- R-7. The behavioral test prompts SHALL be real-domain (natural behavior), not prose-recall, per §11 Prompt Construction Mandate.
- R-8. The generic mandate SHALL be a superset of (not a contradiction of) the #2243 Python-specific `dependency-injector` mandate; Python SHALL remain in the "Clear standard" tier with `dependency-injector`.
- R-9. The generic section SHALL follow the existing formatting, tone, and structure of `080-code-standards.md` (numbered lists start at 1, stable anchors, Mandatory Triple Co-Application, no hardcoded identity values).
- R-10. The generic section SHALL be sequenced after #2243 merges to avoid contradiction with the Python-specific mandate.

## 5. Items

### Item 1 (SC-1): Add the generic DI principle to `080-code-standards.md`

- RED: Run the SC-1 behavior scenario before the rule is documented; clean-room `session.yaml` shows the agent hand-rolling manual wiring (defect present).
- GREEN: Add the generic DI principle section between "Libraries & Packages" and "Print Statements & Output"; the SC-1 scenario then shows the agent selecting a DI approach where one exists.
- verify: Two-SC pattern — SC-1a generates `session.yaml`; SC-1b clean-room sub-agent verifies the agent applied the generic DI principle.
- commit: Commit the guideline section (foundational — SC-2/SC-3/SC-4 depend on it).

### Item 2 (SC-2): Add the curated framework table

- RED: Run the SC-2 behavior scenario before the table exists; clean-room `session.yaml` shows no tiered per-language guidance applied.
- GREEN: Add the curated three-tier framework table; the SC-2 scenario then shows tiered guidance applied for the given language.
- verify: Two-SC pattern — SC-2a generates `session.yaml`; SC-2b clean-room sub-agent verifies tiered guidance application.
- commit: Commit the table.

### Item 3 (SC-3): Add selection guidance

- RED: Run the SC-3 behavior scenario before the selection guidance exists; clean-room `session.yaml` shows arbitrary/fixed-pin framework choice.
- GREEN: Add the selection guidance; the SC-3 scenario then shows framework choice driven by code/spec context.
- verify: Two-SC pattern — SC-3a generates `session.yaml`; SC-3b clean-room sub-agent verifies context-driven selection.
- commit: Commit the guidance.

### Item 4 (SC-4): Add the HTML/CSS exclusion

- RED: Run the SC-4 behavior scenario before the exclusion exists; clean-room `session.yaml` shows the agent attempting DI on markup/styling.
- GREEN: Add the explicit HTML/CSS exclusion; the SC-4 scenario then shows no DI attempt on markup/styling.
- verify: Two-SC pattern — SC-4a generates `session.yaml`; SC-4b clean-room sub-agent verifies the exclusion.
- commit: Commit the exclusion.

### Item 5 (SC-5): Update `INDEX.md` trigger patterns

- RED: `grep` `INDEX.md` for the DI trigger patterns in the `080-code-standards.md` row returns 0 matches.
- GREEN: Add `dependency injection`, `di`, `inject`, `container` to the `080-code-standards.md` row.
- verify: `grep` `INDEX.md` for the DI trigger patterns returns a match; existing trigger patterns preserved.
- commit: Commit the `INDEX.md` row update.

### Item 6 (SC-6): Behavioral test — artifact generation

- RED: Run the SC-6 scenario before the rule is documented; clean-room `session.yaml` shows the agent hand-rolling manual wiring.
- GREEN: After the rule is documented, the SC-6 scenario runs via `with-test-home` and produces a `session.yaml` artifact.
- verify: SC-6a generates `session.yaml` via `opencode run`; artifact exists and records tool calls and decisions.
- commit: Commit the rule + test together.

### Item 7 (SC-7): Clean-room evaluation of `session.yaml`

- RED: Run the SC-7 scenario before the rule is documented; clean-room evaluation shows no DI-mandate compliance.
- GREEN: After the rule is documented, a clean-room sub-agent reads `session.yaml` and verifies DI-mandate compliance across at least one "Clear standard" and one "Contested"/"Non-idiomatic" language, plus the HTML/CSS exclusion.
- verify: Clean-room sub-agent produces a PASS verdict on `session.yaml` (from SC-6) confirming DI-mandate compliance.
- commit: Commit the rule + test together.

## 6. Dependencies

- **Reference:** `#2243` — Python dependency-injector mandate. **Relationship:** The parent spec this follow-up generalizes. Python's `dependency-injector` pin remains in the "Clear standard" tier. **Status:** Open (`approved-for-pr`); this spec is sequenced after it merges.
- **Reference:** `.opencode/guidelines/080-code-standards.md` — §Enforcement Test Mandate, §critical-rules-BEH-EV, §Evidence Type Taxonomy. **Relationship:** Mandates behavioral evidence for runtime-behavioral changes and a behavioral enforcement test. **Status:** Satisfied.
- **Reference:** `tests-v2/AGENTS.md` §6a, §11. **Relationship:** Defines the Two-SC pattern (artifact generation + clean-room `session.yaml` evaluation) and the §11 Prompt Construction Mandate (real-domain prompts, not prose-recall). **Status:** Satisfied.
- **Reference:** `skills/test-driven-development/SKILL.md` Test Integrity Mandate. **Relationship:** Behavioral tests MUST NOT be lobotomized; real-domain prompts required. **Status:** Satisfied.
- **Reference:** `critical-rules-BEH-EV`, `020-go-prohibitions.md` cost-blind verification. **Relationship:** Behavioral SCs require behavioral evidence; structural/string evidence for a runtime-behavioral change is EVIDENCE_TYPE_MISMATCH. **Status:** Satisfied.

## 7. Traceability

| Requirement | SC(s) | Item(s) |
|-------------|-------|---------|
| R-1 | SC-1 | Item 1 |
| R-2 | SC-2 | Item 2 |
| R-3 | SC-3 | Item 3 |
| R-4 | SC-4 | Item 4 |
| R-5 | SC-5 | Item 5 |
| R-6, R-7 | SC-6, SC-7 | Items 6, 7 |
| R-8, R-9 | SC-1..SC-5 | Items 1..5 |
| R-10 | SC-1..SC-4 | Items 1..4 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| 080-code-standards.md | doc | `.opencode/guidelines/080-code-standards.md` (§Libraries & Packages, §Enforcement Test Mandate, §critical-rules-BEH-EV) | live read during analysis; confirm insertion point and existing format conventions |
| INDEX.md | doc | `.opencode/guidelines/INDEX.md` (row for 080-code-standards.md, line 22) | live read during analysis; confirm existing trigger patterns to preserve |
| #2243 remote spec | issue | `.opencode/.issues/2243/remote.md` | live read; confirm Python `dependency-injector` mandate and carveout to preserve |
| tests-v2/AGENTS.md | doc | `tests-v2/AGENTS.md` (§6a Two-SC pattern, §11 Prompt Construction) | live read during analysis; confirm behavioral test framework contract |
| framework ecosystem references | web | per-language DI framework documentation (Spring, M.E.DI, Koin, MacWire, get_it, tsyringe, etc.) | verification of framework names and idiomatic status during analysis |
| Java — Spring / Dagger | web | Spring: https://github.com/spring-projects/spring-framework (60,165 stars); Dagger: https://github.com/google/dagger (17,705 stars) | live web fetch via GitHub API during analysis; adoption metrics + source URLs captured in `tmp/di-framework-research-20260805.md` |
| Kotlin — Koin / Hilt | web | Koin: https://github.com/InsertKoinIO/koin (10,009 stars); Hilt: https://github.com/google/dagger (part of google/dagger monorepo) | live web fetch via GitHub API; adoption metrics + source URLs captured in `tmp/di-framework-research-20260805.md` |
| Scala — MacWire / Guice / ZIO | web | MacWire: https://github.com/softwaremill/macwire (1,314 stars); Guice: https://github.com/google/guice (12,730 stars); ZIO: https://github.com/zio/zio (4,402 stars) | live web fetch via GitHub API; adoption metrics + source URLs captured in `tmp/di-framework-research-20260805.md` |
| Dart/Flutter — get_it / provider / Riverpod | web | get_it: https://pub.dev/packages/get_it (1,829,183 dl/30d); provider: https://pub.dev/packages/provider (1,072,817 dl/30d); Riverpod: https://pub.dev/packages/flutter_riverpod (2,656,054 dl/30d) | live web fetch via pub.dev package registry API; adoption metrics + source URLs captured in `tmp/di-framework-research-20260805.md` |
| TypeScript — tsyringe / InversifyJS | web | tsyringe: https://www.npmjs.com/package/tsyringe (10,236,744 weekly dl); InversifyJS: https://www.npmjs.com/package/inversify (2,666,499 weekly dl) | live web fetch via npm registry API; adoption metrics + source URLs captured in `tmp/di-framework-research-20260805.md` |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Running the behavioral test costs minutes of execution time and produces behavioral evidence that the agent uses a DI approach where one exists. Skipping means agents hand-roll manual wiring in non-Python languages, reproducing the coupling #2243 eliminated in Python — a behavioral-defect death spiral across every language.
- **SC-2:** Running the tiered-table behavioral test costs minutes and produces evidence the agent applies per-language tiered guidance. Skipping means agents pick frameworks arbitrarily or apply a single framework non-idiomatically, producing worse code than hand-rolled wiring.
- **SC-3:** Running the selection-guidance behavioral test costs minutes and produces evidence of context-driven framework choice. Skipping means agents pin a fixed framework regardless of code/spec reality, breaking the "use a DI approach" principle.
- **SC-4:** Running the HTML/CSS-exclusion behavioral test costs minutes and produces evidence the agent does not apply DI to markup/styling. Skipping means agents waste effort attempting DI on non-programming artifacts.
- **SC-5:** Verifying the `INDEX.md` trigger patterns costs one grep. Skipping means the DI section is invisible to agents that encounter DI-related patterns, so the mandate might as well not exist.
- **SC-6:** Running the artifact-generation behavioral test costs minutes and produces a `session.yaml` artifact. Skipping means there is no behavioral evidence to evaluate against, forcing string/grep substitution that is EVIDENCE_TYPE_MISMATCH.
- **SC-7:** Clean-room evaluation of `session.yaml` costs minutes and produces a PASS/FAIL verdict on DI-mandate compliance. Skipping means the behavioral test passes without verification — a false PASS masking the defect.

## 11. Edge Cases

- **Condition:** An agent writes code in a language with no clear DI standard (e.g., Go, Rust). **Expected behavior:** The agent applies the tiered guidance — the non-idiomatic tier is guidance-only, not an enforcement pin. **Resolution:** SC-2/R-2 keep the non-idiomatic tier advisory; the mandate targets using a DI approach where one exists, not forcing a framework where none is idiomatic.
- **Condition:** An agent encounters markup/styling (HTML/CSS). **Expected behavior:** The agent does NOT attempt a DI approach. **Resolution:** SC-4/R-4 explicitly exclude HTML/CSS as non-programming languages.
- **Condition:** The generic mandate contradicts the #2243 Python-specific mandate. **Expected behavior:** The generic mandate is a superset; Python remains pinned to `dependency-injector`. **Resolution:** R-8 requires consistency; the generic principle "use a DI approach" contains the Python-specific "use `dependency-injector`."
- **Condition:** An agent works on a small self-contained script (e.g., `.opencode/tools/`). **Expected behavior:** The #2243 carveout applies. **Resolution:** The carveout is preserved unchanged by this spec (Not Included).
- **Condition:** The framework table documents two or more idiomatic DI options for the same language (contested tier). **Expected behavior:** The agent chooses based on code analysis and spec requirements, and may combine approaches when the framework table documents two or more idiomatic DI options for that language. **Resolution:** SC-3/R-3 permit context-driven selection and combinations under the countable two-or-more threshold.
- **Condition:** A behavioral test times out (bash-tool default 120s). **Expected behavior:** The agent follows §10.2/§10.5 remediation. **Resolution:** Behavioral SCs use the documented remediation path; tests require >= 600s timeout per `tests-v2/AGENTS.md`.

## 12. Change Control

| Date | Changed | Why | Authorized By |
|------|---------|-----|---------------|
| 2026-08-05 | Initial spec created from analysis at `tmp/2249/artifacts/` and handoff at `tmp/2243-followup/artifacts/preliminary/handoff.yaml` (create step) | Spec-creation pipeline: assemble the generic multi-language DI mandate spec from the requirements/decomposition/artifacts | Spec-creation create task |
| 2026-08-05 | SC-3 determinism fix: replaced hedging phrase "combinations of DI approaches are allowed when warranted" with a concrete thresholded condition "combinations of DI approaches are allowed when code analysis or spec requirements identify multiple viable approaches for the same language". Propagated the same fix to the Approach Chosen summary, R-3, and the §11 contested-tier edge case. Design intent preserved: framework choice remains driven by code analysis and spec requirements, not a fixed pin; combinations allowed when justified. | Validate step determinism check: SC-3 criterion contained the hedged pattern "when warranted" with no concrete threshold, which is a FAIL per the determinism check (any SC with ≥1 prohibited pattern is FAIL) | Spec-creation revise task |
| 2026-08-05 | SC-3 determinism fix (round 2): replaced soft term "multiple viable approaches" (no countable definition) with the countable condition "two or more idiomatic DI options documented in the framework table for the same language". Propagated the sharpened threshold to the Approach Chosen summary, R-3, and the §11 contested-tier edge case. Design intent preserved: framework choice remains driven by code analysis and spec requirements, not a fixed pin; combinations allowed under the two-or-more threshold. | DiMo spec audit Finding 1 (SC-3 determinism, SC-9/SC-DET FAIL): the criterion's soft term "multiple viable approaches" had no concrete countable definition, so two clean-room auditors could reach different verdicts | Spec-audit DiMo chain remediation |
| 2026-08-05 | SC-RESEARCH provenance fix: added per-framework source URLs and live-verification evidence (GitHub API / pub.dev / npm registry metrics + official docs URLs) to the §8 Documentation Sources table for the five framework-tier claims (Spring/Dagger, Koin/Hilt, MacWire/Guice/ZIO, get_it/provider/Riverpod, tsyringe/InversifyJS). | DiMo spec audit Finding 2 (research_adequacy.evidence_provenance FAIL): five framework-tier claims lacked live tool-call provenance in Documentation Sources | Spec-audit DiMo chain remediation |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash:0731)
