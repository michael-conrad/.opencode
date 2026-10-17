<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2382 (SC-1 comprehension probe record) -->

# SC-1 Comprehension Probe — local/remote routing, 2026-10-17

Fresh-context sub-agent (no prior session context) loaded only the corrected
issues card (`.opencode/skills/issues/SKILL.md` as of commit 1f466c8f) and
was given two scenarios.

**Scenario 1 — update the local store record for `myrepo#42`:**
Agent routed via local-issues (`./.opencode/tools/local-issues update
myrepo#42 …`, `--github` for the metadata field), citing §1, §2, and §7's
boundary.

**Scenario 2 — edit the remote tracker's issue body for `myrepo#42`
(GitHub):**
Agent routed via the platform CLI / gh-cli card, citing §1's remote-operations
rule and §7's exclusion ("`update --github` … is never the mechanism for a
remote-body correction").

**Verdict: PASS** — local-issues for the local-store operation, the platform
card for the remote operation, and no local-issues attempt for the remote
operation, without prompting.

---
🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
