<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 -->
---
name: changelog-generator
description: Load when creating release notes or a changelog, documenting changes between versions, or preparing the body of a release. Every entry traces to a real commit between release tags — nothing is invented, nothing generic. Also load when a release PR needs its changelog body.
license: MIT
provenance: AI-authored, .opencode#2490
---

# changelog-generator

1. **Source of truth:** the commit log since the last release tag
   (`git log <last-tag>..HEAD --oneline`) — every entry maps to a commit.
2. **Categorize** Added / Changed / Fixed / Removed, in human-readable
   language; group by issue where commits carry issue numbers.
3. **Breaking changes lead** and are stated plainly with migration impact.
4. **No fabrication.** If the log is unclear, read the commit; never invent an
   entry to fill a category.
5. **Format** matches the repo's existing changelog style.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
