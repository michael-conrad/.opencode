<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2557 (semver expectation); restored from defunct 087-no-backward-compat, .opencode#2557 -->

# Industry-Standard Practices

Expectations the industry treats as default professional practice. This card
states the expectations — the **what and why** — not the operations: where an
operation has an owning card, defer to it.

## Versioning discipline (semver)

Released artifacts carry version numbers that mean something. Under semver
discipline: breaking changes bump the major, new features the minor, fixes the
patch; pre-release and build metadata follow the same spec's forms.

- Choose the version that communicates the change honestly — a "patch" release
  that breaks consumers is a defect, not a version number.
- The expectation lives here; the operations live in `version-manager` (finding
  version strings, choosing the level from the changelog category, updating
  them consistently) and `changelog-generator` (the release-notes body). When a
  change needs a version bump, the expectation tells you which level is honest;
  those cards perform it.

## Compatibility and deprecation

**No backward-compatibility shims during internal refactoring.** When
refactoring internal (non-public API) code, do not create backward-compat
aliases, deprecation warnings, or compatibility shims — fix all callers
immediately. Clean breaks are less confusing and less wasteful.

**Exception — public APIs with external consumers:** use deprecation cycles per
standard practice. Announce the deprecation, keep the old surface working
through the cycle, and remove it on the announced schedule.

## Growth note

This card starts with the stated expectations above and grows evidence-gated: a
new practice enters when a real failure or a developer directive shows the
expectation is missing — never speculatively.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
