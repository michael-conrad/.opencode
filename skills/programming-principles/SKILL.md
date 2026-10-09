---
name: programming-principles
description: "Load when designing or writing code — before creating a module, service, or abstraction; choosing between alternative approaches; deciding whether to reuse, extend, or replace existing code; or when reviewing code — and whenever industry-standard engineering expectations come into question: versioning discipline, compatibility and deprecation, how code is structured and evolved. Owns the working design principles, the cross-language dependency-injection mandate, and general programming practices; language-specific conventions belong to the language cards."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; widened to the general engineering space, .opencode#2557 -->

# programming-principles

Load this card before creating a module, service, or abstraction; when choosing
between alternative approaches; when deciding whether to reuse, extend, or
replace existing code; and when reviewing code.

## Working design principles

1. **Minimal change.** Solve the stated problem; no unrelated refactoring, no
   speculative generality. Targeted improvements only where they serve the
   current goal.
2. **Follow the codebase.** Existing patterns, naming, and structure win over
   personal preference; a consistent codebase outperforms a clever one.
3. **Composition over cleverness.** Small focused units with clear contracts;
   prefer the straightforward version until measurement says otherwise.
4. **Delete dead code.** Unused code is liability; removal is part of the
   change that orphans it.
5. **Tradeoffs are explicit.** When principles conflict (DRY vs clarity,
   abstraction vs directness), state the conflict and choose with a reason —
   silently optimizing for one is how architecture drifts.
6. **Design before code** when the change shapes interfaces or module
   boundaries; the design is stated briefly, then built.

## Dependency injection — mandatory read

**Read [the dependency-injection mandate and tier table](references/dependency-injection.md)
before writing or unit-testing service-style code in any language.** The
enforceable rule is "use a DI approach," not "use framework X": approach problem
solving and unit tests from the point of view of having an available DI approach
of some worth, and use it rather than hand-rolled manual wiring where such an
approach exists. The detail card carries the cross-language recommended-packages
tier table and selection guidance — including cardless languages, which it
covers because the mandate rides this card, not a language card.

## Industry-standard expectations

Two expectations are visible at this level; the depth is one hop away:

- **Versioning discipline** — released artifacts carry version numbers that
  mean something (semver discipline: breaking changes bump the major, features
  the minor, fixes the patch); version operations belong to `version-manager`
  and release-notes artifacts to `changelog-generator` — this card owns the
  expectation, not the operations.
- **Compatibility and deprecation** — internal refactors take clean breaks;
  public APIs with external consumers take deprecation cycles per standard
  practice.

Read [industry-standard practices](references/practices.md) when versioning,
compatibility, deprecation, or industry-standard practice questions arise in
design or review.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
