---
name: java
description: "Load when writing, modifying, reviewing, or testing code in Java. Owns the language's conventions and its dependency-injection practice — which frameworks are idiomatic and how components are wired; the cross-language DI mandate lives in `programming-principles`. Building and packaging the project belong to `gradle`."
license: MIT
provenance: AI-authored, .opencode#2557
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2557; DI practice currency-verified 2026-10-07 -->

# java

This card owns Java language work: the language's conventions and its
dependency-injection practice. Building and packaging the project — fat jars,
service registrations — belong to `gradle`.

## Dependency injection — Java practice

The cross-language mandate ("use a DI approach," never hand-rolled manual
wiring where an idiomatic approach exists) and the tier table live in the
shared card under `programming-principles`; this card carries the Java wiring
practice, which presupposes the mandate.

Java's clear-standard set (currency-verified 2026-10-07): **Spring, Guice,
Dagger 2**.

- **Spring** — the dominant ecosystem standard: component scanning with
  stereotype annotations (`@Service`, `@Component`, `@Repository`),
  constructor injection (`@Autowired` on constructors, or plain single
  constructor where the framework infers it), Java config (`@Configuration` +
  `@Bean`) for third-party wiring. Prefer constructor injection throughout —
  dependencies explicit, immutable, and test-friendly.
- **Dagger 2** — compile-time DI: `@Component`/`@Module`/`@Provides`, graph
  validated at compile time, no runtime reflection; the standard on Android
  (via Hilt). Choose it when build-time verification and zero-reflection
  startup matter.
- **Guice** — runtime DI with a module DSL (`AbstractModule`, `bind()`),
  lighter than Spring when only wiring is needed.
- **GWT note:** GWT's historical DI story (Gin) is deprecated; it is a legacy
  footnote, not a live recommendation.
- Combination is acceptable where the code calls for it — but one wiring style
  per component graph; mixing containers in one graph is a defect, not a
  feature.

## Conventions

- Constructor injection over field injection — dependencies visible in the
  type signature, required at construction, mockable in tests.
- Interfaces at wiring boundaries where substitution or proxying is real;
  otherwise concrete types — no speculative interfaces.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
