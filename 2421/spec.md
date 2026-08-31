---
remote_issue: 2421
remote_url: https://github.com/michael-conrad/.opencode/issues/2421
promoted_at: 2026-08-31T16:08:00Z
---

# [SPEC] Mandatory live-registry verification of dependency versions before pinning

## Problem

Agents adding dependencies to a project (pyproject.toml, package.json, etc.) recall version numbers from training data instead of verifying the current stable release against the live package registry (PyPI, npm, crates.io, etc.). Training data is always stale for version numbers — a version that was current at training time may be outdated, superseded by security fixes, or yanked. The existing guidelines (065-verification-honesty, 075-docs-verification) prohibit memory-based claims and mandate live verification, and 070-environment.md governs HOW a dependency is added (edit pyproject.toml + uv sync, `~=` pinning), but no directive governs WHERE the version number comes from. The directive: before pinning any new dependency version, the agent MUST verify the current stable version against the live registry and pin that (or document a justified older pin); NEVER recall dependency versions from training data.

Full spec body to be written by the spec-creation pipeline.
