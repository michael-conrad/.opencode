---
name: issues
description: "Load when creating, reading, updating, commenting on, linking, or closing any issue — local .issues/ stores, GitHub, or GitBucket. Covers qualified issue names, platform routing via the authenticated CLIs, the local-issues tool, and the comment substantiveness gate: non-substantive progress updates stay in chat and never become issue comments."
license: MIT
provenance: AI-authored, .opencode#2490; tooling contract consolidated per .opencode#2543
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; .opencode#2543 -->

# issues — issue operations

1. **Routing.** Local stores go through `.opencode/tools/local-issues` with
   qualified names (`repo#N`) on every command that takes a number — bare
   numbers are rejected; remote operations go through the platform CLI
   (`gh` / `gb`) — authenticated tools, never raw API scripts. The script's
   `--help` is the flag-level source of truth; detail cards under
   `references/` carry the CLI and sync mechanics.
2. **Creation.** Remote first: when the store has a remote tracker, file the
   remote issue to reserve the number before any local folder setup — every
   issue type; the local `{N}/` mirror follows, linked via `update --github`.
   Remoteless stores pick the next free number in that repo's own namespace.
   The remote body is a detailed exec summary (why + final what); the full
   spec and artifacts live locally. Title states the work; labels describe
   pipeline state. Never derive the number by listing remote issues and never
   hand-create the `{N}/` folder — register it via
   `local-issues create --number repo#N`.
3. **Comment gate.** A remote comment is posted only for a major substantive
   change that needs special attention — findings or decisions a stakeholder
   must see. Progress narration ("working on it", "halfway done"), internal
   reasoning, and routine status stay in chat or the local store. Spec and
   plan corrections always edit the artifact in place — never route to
   comments.
4. **Relationships.** Link sub-issues to parents; the hierarchy carries the
   authorization cascade and closure order.
5. **Closure.** Issue closure follows delivered work (post-merge cleanup) or
   explicit developer instruction — never closure to tidy up.

## local-issues operating contract

- **Tool path:** `.opencode/tools/local-issues` — run it directly
  (`./.opencode/tools/local-issues <command> [flags]`). First mutation
  auto-initializes the `.issues/` orphan-branch worktree.
- **Invocation:** every number argument uses the qualified `repo#N` form;
  bare numbers exit with the available-qualifier list.
- **Session start:** `init` (bootstrap worktrees + pull remote `issues-data`
  for all repos), then `sync` (commit + pull-rebase + push) for bidirectional
  currency.
- **Fail-fatal worktree:** if worktree establishment fails, the tool exits
  non-zero with a remediation command — never continue in plain-file mode.
- **Mutation commands** (`create`, `update`, `comment`, `close`, `delete`,
  `link`, `renumber`) auto-commit and auto-push to the `issues-data` branch.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
