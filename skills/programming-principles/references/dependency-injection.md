<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: restored from .opencode#2249 (generic DI mandate + recommended-packages tier table) through the #2557 currency pass; .opencode#2557 -->

# Dependency-injection mandate and tier table

## The mandate

Approach problem solving and unit tests from the point of view of having an
available DI approach of some worth, and use it rather than hand-rolled manual
wiring where such an approach exists. The enforceable rule is
**"use a DI approach," not "use framework X."**

What DI is: the pattern of supplying a component's dependencies from outside
(via a container or explicit wiring) rather than having the component construct
them itself. Why it is required: components that construct their own
dependencies are tightly coupled, hard to test in isolation, and resist change.
DI keeps services easy to test (swap real collaborators for fakes), refactor,
and reason about.

## Recommended packages — three advisory tiers

The table below is advisory guidance, not an enforcement pin. Tier placement
reflects ecosystem idiom, not a mandate to adopt the framework. Use a DI
approach where one is idiomatic; where the table marks a tier "guidance-only,"
hand-rolled wiring or a framework-free approach is acceptable. Currency-verified
against live sources 2026-10-07 (record: the #2557 currency-pass artifact).

| Tier | Languages / Frameworks |
|---|---|
| Clear standard | Python (`dependency-injector`; framework-native `Depends` for web-framework-internal wiring), C#/.NET (built-in `Microsoft.Extensions.DependencyInjection`), Java (Spring / Guice / Dagger 2), Angular (built-in DI framework; Vue/Svelte: provide-inject / context pattern) |
| Contested | Kotlin (Koin/Hilt), Scala (MacWire/Guice/ZIO ZLayer), Dart/Flutter (get_it/provider/Riverpod), TypeScript (tsyringe/InversifyJS) |
| Guidance-only | Go, Rust, C++, Swift, Ruby, React (Context/hooks), Web Components |

## Selection guidance

- Framework choice is driven by **code analysis and spec requirements**, never a
  fixed pin. Read the code's structure and the requirements' testability and
  wiring needs, then select from the tier the language sits in.
- **Combinations are allowed** where the table documents two or more idiomatic
  options for the same language (e.g. TypeScript's tsyringe and InversifyJS are
  both idiomatic; pick per the code's needs and state the choice).
- For guidance-only languages, manual constructor wiring is idiomatic — the
  mandate is satisfied by wiring dependencies from outside (constructor
  injection) rather than components constructing their own collaborators.
- Prefer the container-first pattern where a container is idiomatic: define the
  wiring graph once in the container and let the container resolve dependencies
  for all consumers; services declare their dependencies in their constructor.

## Exclusions and carveouts

- **HTML/CSS exclusion:** markup and styling are not programming languages, and
  DI guidance does not apply. Do not attempt a DI approach on HTML/CSS.
- **Infrastructure-tooling carveout:** the DI mandate applies to
  application/service code only. Agent-deck infrastructure tooling (the deck's
  own scripts, tools, and skill-local scripts) is exempt — it may use simple,
  direct wiring appropriate to its scope.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
