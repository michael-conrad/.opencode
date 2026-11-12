<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored bug report, filed 2026-11-12 on the remote
     tracker; triaged 2026-11-12 under the developer dispatch "triage
     .opencode#2736" and converted in place into this governing spec under
     the work-entry conversion (issues card §5, .opencode#2707 mechanics).
     Developer ruling recorded in the report: only a real failure — an
     actual build or test failure, or equivalent verified failure — should
     block a release; manifest absence is not a real failure. Triage
     evidence: claims verified against the live card text
     (skills/release-promoter/references/operating-protocol.md steps 7.4,
     8, 10; skills/release-promoter/SKILL.md step 0) and the
     pointer-only `.opencode/AGENTS.md` constraint, this date. -->

# [SPEC] release-promoter: resolve canonical build/test commands from sanctioned documented sources — manifest absence is not a release-blocking failure

## Problem

The release-promoter clean-room gate's canonical build/test command
discovery (operating protocol step 7) reads the parent repository's build
manifest and, when no manifest declares the commands, hard-fails
`MANIFEST_FAIL` with no retry (step 7.4). Step 8 forbids executing any
command not discovered from the manifest. A parent repository whose tree
carries no declared build manifest therefore can never satisfy the gate's
zero-failure build/test assertion: the release PR is permanently blocked on
missing paperwork, not on any failing build. Observed live (2026-11-12,
DoiUpdaterCurrent): the release run ended at `MANIFEST_FAIL` with every
repo verified at its remote trunk tip and the candidate untested. The
conflict is structural — the floor's build-tooling exclusivity sanctions
the parent's own wrapper (`./gradlew` for Gradle repos), while the gate
permits only manifest-discovered commands; `.opencode/AGENTS.md`, a common
manifest location, is prohibited from carrying rules or commands.

The developer's ruling (2026-11-12): only a real failure — an actual build
or test failure, or an equivalent verified failure — should block a
release. Manifest absence is not a real failure.

## Requirements

1. The clean-room gate resolves the canonical build and test commands from
   sanctioned, documented sources when the release tree declares no build
   manifest: the declared build manifest when one exists; otherwise the
   repository's own documented build framework — the wrapper the floor's
   build-tooling exclusivity rule sanctions for the repository's build
   system — and session-init per-root facts where they supply
   build/test commands. The resolution order is defined by the card text;
   the gate never hardcodes a build system and never substitutes a
   submodule's own tooling run in isolation for the parent's framework.
2. Manifest absence ceases to be a blocking assertion: `MANIFEST_FAIL` as
   a hard-fail-on-absence class is removed from the gate. Only real
   failures block the release — `DRIFT_FAIL`, an actual `BUILD_FAIL`
   (non-zero build or test exit), a tree mismatch, or an equivalent
   verified failure — under the existing no-retry-within-the-release
   discipline for assertion failures.
3. The gate text records which source supplied the resolved commands in
   the gate's work record, so the zero-failure assertion's provenance is
   auditable.

## Success criteria

| SC | Class | Criterion | Verification |
|----|-------|-----------|--------------|
| SC-1 | Behavioral | On a release tree with no declared build manifest, the clean-room gate resolves build/test commands from the sanctioned documented sources and proceeds to execute the zero-failure build/test assertion — it does not stop at manifest absence. | Executed gate run on a manifest-less candidate tree (live or scripted scenario) reaching build/test execution and completing or failing only on real build/test outcomes. |
| SC-2 | Content | The release-promoter card and operating protocol no longer hard-fail on manifest absence: command discovery states the sanctioned resolution order, `MANIFEST_FAIL` is removed as an assertion-failure class, and the blocking-failure list names only real failures. | Fact-decidable read of the card text against the requirements. |
| SC-3 | Content | The gate's work-record requirement states that the resolved commands and their supplying source are recorded. | Fact-decidable read of the card text. |

## Scope

- `skills/release-promoter/SKILL.md` (step 0 assertion-failure list)
- `skills/release-promoter/references/operating-protocol.md` (steps 7, 8, 10)
- Any related references citing `MANIFEST_FAIL`

Deck-consumption boundary: the change is authored in the deck's own
repository (this store) and lands through the deck governance flow and a
human-merged PR; consuming checkouts receive it only by pulling upstream.
