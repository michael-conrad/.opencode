<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->
---
trigger_on: python standards, typing, dependency injection, di, inject, container, pathlib, f-strings, print statements, pipeline rerun
tier: 2
load_when: sub-agent
---

# Python Standards

> Demoted from [080-code-standards.md](080-code-standards.md) — reach this content through the one-line pointer retained in the 080 core.

## Typing

- Explicit type hints (Pydantic/Dataclasses) project-wide. Avoid `Any`; use concrete types wherever possible. This is the project standard — type hints make code self-documenting and catch errors at definition time.
  `Any` is acceptable only when imposed by third-party signatures.
- Use Python 3.12+ built-in types (`list[str]`, `dict[str, Any]`), not `typing.List`/`Dict`.
- **Strict Enum Mapping**: DB-stored enums use plain string values (`NEW_DISCOVERY = "new_discovery"`).
  Emojis/presentation strings handled as properties or mapping functions, never stored in DB.
- **Pipeline Rerun Constraint**: Changes to data processing pipelines that affect extracted metadata require a full
  pipeline rerun — performed by the user, not the agent. A change **affects extracted metadata** if it alters the
  values, presence, or format of any field written to the database or output files. Agent MUST NOT write DB
  remediation, backfill, or migration code to compensate for pipeline changes; the pipeline rerun handles data
  consistency. Flag the rerun requirement to the user after making such changes. Redundant "safety-net" updates
  in downstream processing steps prohibited.

## Design Principles

The project-specific code structure rules below are governed from the Tier-1 core: Read [080-code-standards.md](080-code-standards.md) §Design Principles (non-monolithic decomposition, single-function methods, no monoliths, no magic strings, no re-exports, top-level documentation, docstring determinism, labels over index numbers, derivation provenance) and the `programming-principles` skill for the universal design principles.

## Modern Python

- **Pathlib**: `pathlib.Path` exclusively for file/dir ops. No `os.path.join`, `os.mkdir`, string concatenation. Use `/`
  operator.
- **f-strings**: For all string interpolation. No `.format()` or `%` unless required by external libs.
- **Metadata Integrity**: Use `shutil.copy2` (not `shutil.copy`). Never discard metadata unless explicitly instructed.

## Libraries & Packages

- Use domain-appropriate libraries for specialized tasks — no regex for NLP. NLP tasks include tokenization, stemming,
  lemmatization, part-of-speech tagging, named entity recognition, and sentence segmentation. Simple pattern matching
  or fixed-format extraction does not qualify and may use regex. For tasks requiring complex pattern logic beyond
  simple fixed-format extraction, prefer FSM or LALR-type grammars (e.g., `lark`, `pyparsing`) over regex — regex is
  brittle on live data.
- All DB/system ops use existing project libraries. Direct data file manipulation prohibited unless instructed.
- Use project-provided abstractions for all data file paths — never hardcode or assume data file locations.

## Dependency Injection

- **What DI is**: Dependency Injection (DI) is the pattern of supplying a component's dependencies from outside (via a container or explicit wiring) rather than having the component construct them itself. A service receives its collaborators as constructor or setter inputs instead of instantiating them internally.
- **Why it is required**: DI decouples a class from its dependencies, making it easy to test (swap real collaborators for fakes), refactor, and reason about. Components that construct their own dependencies are tightly coupled, hard to test in isolation, and resist change. DI is required so services remain easy to test and refactor.
- **Mandated library**: Use `dependency-injector` for all dependency wiring. Do not hand-roll DI containers, use ad-hoc module-level singletons, or wire dependencies through arbitrary parameter passing. Structure wiring through an `Injector`/`Container` from `dependency-injector`, with providers declared for each dependency.
- **Usage patterns**: Declare a container class that registers each dependency as a provider (e.g., `ConfigProvider`, `SecretsProvider`) and wires them into the service and its callers. Services declare their dependencies in their constructor; the container supplies them at composition time. Follow the container-first pattern — define the wiring graph once in the container and let the container resolve dependencies for all consumers.
- **Carveout for `.opencode/` infrastructure tools**: The DI mandate applies to application/service code only. It does NOT apply to infrastructure tooling under `.opencode/`. Scripts and tools in `.opencode/tools/`, `.opencode/scripts/`, and `.opencode/skills/*/scripts/` are exempt — they may use simple, direct wiring appropriate to their scope.

## Dependency Injection (generic mandate)

- **The enforceable rule is "use a DI approach," not "use framework X."** Agents MUST approach problem solving and unit tests from the point of view of having an available DI approach of some worth, and use it rather than hand-rolling manual wiring where such an approach exists. This generic principle applies across all programming languages and is a superset of the Python-specific `dependency-injector` mandate above — Python remains in the "Clear standard" tier with `dependency-injector`.
- **Curated per-language framework table (explicitly advisory):** The table below is advisory guidance, not an enforcement pin. Tier placement reflects ecosystem idiom, not a mandate to adopt the framework. Use a DI approach where one is idiomatic; where the table marks a tier "guidance-only", hand-rolled wiring or a framework-free approach is acceptable.

| Tier | Languages / Frameworks |
| -- | -- |
| Clear standard | Python (`dependency-injector`), C#/.NET (built-in `Microsoft.Extensions.DependencyInjection`), Java (Spring; Dagger for GWT-style), Angular/Vue/Svelte (built-in) |
| Contested | Kotlin (Koin/Hilt), Scala (MacWire/Guice/ZIO), Dart/Flutter (get_it/provider/Riverpod), TypeScript (tsyringe/InversifyJS) |
| Non-idiomatic and guidance-only | Go, Rust, C++, Swift, Ruby, React (Context/hooks), Web Components |

- **Selection guidance:** Framework choice is driven by code analysis and spec requirements, not a fixed pin. Combinations of DI approaches are allowed when the framework table documents two or more idiomatic DI options for the same language.
- **HTML/CSS exclusion:** Markup and styling are not programming languages, and DI guidance does not apply. Do not attempt a DI approach on HTML/CSS.

## Print Statements & Output

- **NO narration/signal prints**: Never add print statements that narrate code changes, signal feature updates, or announce implementation details. Print statements are for data output and user-facing information only.
- **NO pedantic notes in code**: Lines like `print("Note: X now uses Y")` or `print("Feature Z implemented")` are prohibited. Code should speak for itself through documentation and version control.
- **Valid print uses**: Progress bars, data summaries, error messages, user-facing status, diagnostic output during development/testing.
- **Invalid print uses**: Announcing "implementation complete", narrating changes, signaling "now using X", helpful hints, tutorial-style output, any form of self-documentation via print.
- **Examples of prohibited prints**:
  - `print("Note: Visualizations now use dark mode")`
  - `print("Feature X enabled")`
  - `print("Using new algorithm for Y")`
  - `print("Implementation complete - phase 1")`
- **If context is needed**: Add a docstring, code comment, or update documentation — never a print statement.

## Linting & Static Analysis

The lint-tool selection and advisory/read-only mandate for Python files is governed from the Tier-1 core: Read [080-code-standards.md](080-code-standards.md) §Linting & Static Analysis and §Tool Selection by File Type.

## Attribution Note

Attribution, provenance headers, byline preservation, cross-reference standards, numbering, and the YAML standard remain governed by the Tier-1 core: Read [080-code-standards.md](080-code-standards.md).

*Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)*
