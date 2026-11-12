---
name: version-manager
description: "Load when discovering version strings in a codebase or bumping a version for a release — before editing any version number anywhere. Finds every location a version lives (config, metadata, constants), determines the semver level from the changelog category, and updates all of them consistently."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; release versioning is a parent-repo surface, .opencode#2592 -->

# version-manager

1. **Discover, don't assume.** Scan for version patterns across file types
   (package metadata, constants, configs); the locations list comes from the
   scan, not memory.
2. **Bump level** from the changelog: breaking → major, feature → minor,
   fix → patch.
3. **Update every location** in one commit; a missed location is a broken
   release artifact.
4. **Verify** the release tooling reads the new version before proceeding.
5. **Release versioning is a parent-repo surface.** In a parent/submodule
   repository family, the version locations that gate a release are the
   parent repository's; a submodule's own package metadata versions its
   tooling independently and is a release-version location only when the
   parent's release names it.
6. **Dev line.** Between releases the repo's canonical version declaration
   reads `X.Y.Z-dev.N`: the dev base targets the next release; a merge that
   changes the versioned surface (the surface rule 2 bumps) advances N;
   docs-only and CI-only changes display the current version without
   advancing N. N is derived, not stored — the next N is the highest existing
   `v<base>-dev.*` tag + 1, so declaration and tags are the only state and
   drift self-heals by recomputation. Dev merges are tagged `v{base}-dev.N`
   on the squashed merge commit, agent-applied after the human merge (the
   same sequencing the release-promoter protocol uses for its tag), making
   dev points diffable. When accumulated changelog categories outgrow the dev
   base, the agent re-derives the base targeting the new next release.
7. **Numbering authority.** The agent selects and justifies every version
   number — counter advance, base selection, first base — stating the
   justification in the PR body at version-bump time; an explicit developer
   version directive overrides any derivation.
8. **First-semver adoption.** A managed repo without a semver history adopts
   semver at its next versioned change or release; the agent selects and
   justifies the first version from repository evidence — `0.x` for
   initial-development repos, the `1.0.0` family for production-history
   repos — and an explicit developer version directive overrides the
   selection. Date-based historical tags remain untouched.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
