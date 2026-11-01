<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, filed remotely 2026-10-22 as .opencode#2654;
     local record recreated from the remote body on 2026-11-01 (mirror-repair,
     issues-card §7 — no local issues-data mirror existed for this record). -->

# root-build-framework prohibition missing from floor and build cards — agent ran an out-of-repo Gradle distribution during Butter triage (deck regression)

## Problem

During Butter production `issuedates`-endpoint triage (2026-10-22, session start 15:51 EDT), the operating agent violated the root-build-framework discipline. Concretely:

- The documented local-farm workflow `./gradlew build :farmRun -xtest` failed on trunk under the Gradle 9.7.0 wrapper (PR #233 rollout): gretty 5.0.2's `farmRun` resolves cross-project configurations (`:MainSite:runtimeClasspath`, `:ButterAdmin:compileClasspath`) from a task action, which Gradle 9 refuses: `Resolution of the configuration ... was attempted without an exclusive lock. This is unsafe and not allowed.` The failure is reproducible with both the chained and split invocations; rollout ownership lives in NewSRX-Tech-LLC/Butter#233 (open, dual-version compatibility spec).
- To obtain a local farm for latency decomposition, the agent downloaded an out-of-repo Gradle 8.14.3 distribution to `/tmp/opencode/` and invoked `gradle build :farmRun -xtest` through it — bypassing the parent repo's `./gradlew` build framework.

The developer ruled this a **serious violation and a deck regression**. The instrument failed anyway (`BUILD FAILED in 1s`), was abandoned on instruction, and was cleaned up (processes killed, distribution removed; the repo worktree was never modified).

## Root cause in the deck

The prohibition is nowhere written:

- `floor.md` `Environment` states per-root build/test commands arrive as session-init data, but does not forbid running build tooling outside the root repo's framework, and does not state what to do when the sanctioned workflow fails.
- `work`, `implement`, and `gradle` cards route how to build but never assert framework exclusivity.
- The sanctioned vendored-tooling precedent (`.tools/z3` for formal tooling, `.tools/node` for `playwright-cli`, per project runbooks) covers analysis/browser/CLI tools — an agent can misread it as licensing vendored *build* tooling too.

The verified-failure protocol ("report evidence and HALT in a cannot-continue state; no workarounds") exists for tests in AGENTS-level guidance but does not name toolchain substitution as a prohibited workaround class.

**Currency re-check on triage (2026-11-01):** the live deck still carries no framework-exclusivity rule. Nearest coverage, none of it on point:

- `.opencode/skills/implement/references/implementation-workflow.md` §Submodule execution boundary: build/test run through the parent repo's own build framework — but only against running *a submodule's* tooling directly (the #2318/#2313 boundary); it does not prohibit substituting a foreign toolchain for the parent framework when the parent framework itself fails.
- `.opencode/skills/gradle/SKILL.md` R-bullets: "Invoke builds through the wrapper (`./gradlew`) when the repository ships one" — a routing preference, no prohibition, no failure path.
- `release-promoter` operating protocol: parent framework governs, never substitute a submodule's tooling — release-gate scoped (clean-room checkout), not the general work cycle.

Closed neighbor filings — related, not overlapping: #2318 (root-repo-only tooling in multi-module checkouts, closed), #2557 (build/run verification practice + language/build-framework skill-card family, closed), #2416 (release gate must run actual tests, closed). No open issue on this topic (remote search, 2026-11-01): #2654 is the only one.

## Scope (deck fix)

Add an explicit, absolute root-build-framework-only rule to the deck and wire the verified-failure path to it. Deck edits go through deck governance (skill-creator admission gate).

## Requirements

- R-1: floor.md SHALL carry an irreducible rule: build and test MUST run only through the root repo's own build framework (its `./gradlew` wrapper for Gradle repos; the repo's documented wrapper/framework generally). No alternative distributions, sibling wrappers, or ad-hoc binary invocations of build tooling, for any reason, including making a broken task work.
- R-2: The `gradle` and `implement` cards SHALL restate the prohibition in their build-execution sections.
- R-3: A verified failure OF the sanctioned build workflow (e.g., `farmRun` under the Gradle 9.7.0 wrapper) SHALL be handled only by report-with-evidence-and-halt or routing to the owning ticket — here Butter#233 — never by invoking a different build toolchain.

## Impact

All agents, all repos, every work cycle. An out-of-framework build silently defeats wrapper pinning (Butter#233's design treats the wrapper as the single version-specific artifact), can produce divergent plugin behavior (this incident: gretty farm tasks behave differently across Gradle versions), and undermines baseline integrity guarantees. Blast radius is correctness of all future agent work, not this one repo.

## Evidence trail (from the session)

- Root-framework failure (the trigger): `./gradlew build :farmRun -xtest` and the chained `build :farmRun` both fail with the exclusive-lock error quoted above (Gradle 9.7.0, gretty 5.0.2, `org.gradle.parallel=true`).
- Violating instrument: `curl -fSL -o gradle-8.14.3-bin.zip https://services.gradle.org/distributions/gradle-8.14.3-bin.zip` unpacked to `/tmp/opencode/gradle-8.14.3`, then `/tmp/opencode/gradle-8.14.3/bin/gradle build :farmRun -xtest` → `BUILD FAILED in 1s`.
- Remediation on instruction: `gradle-8.14.3` processes killed; distribution and log files deleted from `/tmp/opencode`; repo tree verified untouched; all subsequent builds return to `./gradlew` only.