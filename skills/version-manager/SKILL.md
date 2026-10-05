<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 -->
---
name: version-manager
description: Load when discovering version strings in a codebase or bumping a version for a release — before editing any version number anywhere. Finds every location a version lives (config, metadata, constants), determines the semver level from the changelog category, and updates all of them consistently.
license: MIT
provenance: AI-authored, .opencode#2490
---

# version-manager

1. **Discover, don't assume.** Scan for version patterns across file types
   (package metadata, constants, configs); the locations list comes from the
   scan, not memory.
2. **Bump level** from the changelog: breaking → major, feature → minor,
   fix → patch.
3. **Update every location** in one commit; a missed location is a broken
   release artifact.
4. **Verify** the release tooling reads the new version before proceeding.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
