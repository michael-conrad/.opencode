---
name: wiki-operations
description: "Load before any wiki edit, creation, or sync on a GitHub or GitBucket project wiki — cloning or finding the wiki checkout (.wiki.git repo), creating or editing wiki pages, maintaining _Sidebar/_Footer navigation, provisioning a wiki checkout for a repo, publishing (pushing) wiki changes, or recovering a stale or conflicted wiki checkout. Also load when a page renders wrong, links break, or sidebar navigation breaks after a wiki push. Wikis are direct-publish: verify before push, there is no PR gate."
license: MIT
provenance: AI-authored, .opencode#169
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#169 -->

# wiki-operations — GitHub & GitBucket wiki editing

A project wiki is a plain git repo of markdown files (`<derived>.wiki.git`).
Clone, edit, commit, push — all through generic mechanisms. What this card adds
is the domain rules that keep wiki pages rendering correctly and navigation
intact. All mechanics stay generic: file-editing tools for the markdown,
`git -C <wiki-checkout>` for sync/commit/push, `gh` / `gb` for platform
queries. No wiki-specific tooling exists or is needed.

1. **Checkout before edit.** Never edit a wiki blind. Locate or provision a
   checkout first (see [references/provisioning.md](references/provisioning.md)):
   inherited submodule → existing sub-repo → probe availability → provision →
   stand down when no wiki exists. Setup happens only when a wiki operation is
   actually needed; the checkout is kept after use.
2. **Sync before edit, publish after.** Pull and reconcile — including
   conflicts — before touching a page; commit and push immediately after
   editing. Never force-push; never discard remote edits wholesale (the remote
   tip is the rendered state; human web-UI edits are likely).
3. **Verify before push.** A wiki push is direct-publish — no branch, PR, or
   hook can gate it — so a diff review plus the rule-based checks in
   [references/publish-discipline.md](references/publish-discipline.md) are the
   review substitute. Local preview via the gollum Docker image is an
   opportunistic enhancement when Docker exists, never a blocker.
4. **Gollum layout conventions.** `Home.<ext>`, `_Sidebar.<ext>`,
   `_Footer.<ext>` are the semantic layout files; the extension controls that
   file's rendering format. Details and per-platform link gotchas:
   [references/layout-and-syntax.md](references/layout-and-syntax.md).
5. **Link syntax.** `[[Page Name]]` is the internal-link form both platforms
   parse; GitBucket sidebars accept only `[[...]]` or absolute links (relative
   markdown links resolve to broken `_blob/` paths — gitbucket#2629).
6. **Human edits own content intent.** You are the primary maintainer of any
   wiki you manage — styling and semantic structuring — but adapt human edits
   by integrate-and-normalize, never revert their meaning. Maintain structure
   only within the footprint of the current task (responsive-only posture);
   see [references/maintainer-posture.md](references/maintainer-posture.md).
7. **Submodule wikis are observed, never converted.** If the wiki is already
   wired as a submodule, operate it in place under these same rules. Converting
   a wiki submodule to an ignored sub-repo happens only when the developer
   directs it for a specific repo — procedure in
   [references/remediation-submodule-to-subrepo.md](references/remediation-submodule-to-subrepo.md).

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
