<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2668 -->

# Human-only merge and merge-approval — recommended deny-pattern block

Applies the floor's human-only merge boundary and the `git-workflow-pr`
HALT at the permission layer. Merge and merge-approval actions are
structural boundaries: the permission layer is a backstop, never a
substitute for the instruction layer (floor.md; `git-workflow-pr` rules
6–7), which stays in force wherever this block is absent.

## The block

Add the `bash` deny rules below to opencode's permission config
(`~/.config/opencode/opencode.jsonc` or a project `opencode.json`), inside
or merged into the existing `permission` object. Bash rules match the
parsed command; the last matching rule wins, so these denies must come
after any broader `bash` allow rules.

```jsonc
{
  "permission": {
    "bash": {
      "gh pr merge *": "deny",
      "gh pr merge": "deny",
      "gb pr merge *": "deny",
      "gb pr merge": "deny",
      "gh pr review --approve *": "deny",
      "gh pr review * --approve *": "deny",
      "gh pr review * --approve": "deny",
      "gb pr review --approve *": "deny",
      "gb pr review * --approve *": "deny",
      "gb pr review * --approve": "deny",
      "gh api -X PUT *pulls*merge*": "deny",
      "gh api --method PUT *pulls*merge*": "deny",
      "gh api graphql *MergePullRequest*": "deny",
      "gh api graphql *mergePullRequest*": "deny"
    }
  }
}
```

Coverage: PR merge via `gh` and `gb` (including `--auto` auto-merge
enablement, which rides the same merge commands), merge submission through
the REST merge endpoint (`PUT .../pulls/{n}/merge`) and the GraphQL merge
mutation — both the `MergePullRequest` casing found in wrapper code and the
real API's `mergePullRequest` field (lowercase m; the capitalized name is
only the payload/type name) — and merge-approval review submission through
the review command on both platforms, with the review id before, after, or
absent around the `--approve` flag (the id-before-flag ordering was
behaviorally surfaced by .opencode#2668: `gb pr review 1 --approve` escaped
the id-after-flag-only set and was caught by the CLI, not the permission
layer; the id-before-flag patterns close that gap).

Bounded by design (do not widen):

- Comment-only and request-changes reviews are permitted — the approval
  patterns match only on `--approve`, so `gh pr review --comment *` and
  `gh pr review --request-changes *` pass through.
- Read-only merge-state checks (`gh api repos/.../pulls/N/merge` without
  `PUT`) pass through — only the method-explicit PUT forms are denied.
- `gh pr review --approve` and `gb pr review --approve` variants are
  pattern-ordered to cover the review id before, after, or absent around
  the flag.

## Application — developer-machine step

The shipped deck diff cannot apply this block: it is the developer's own
global config. Apply the block to `~/.config/opencode/opencode.jsonc`
(merge into the existing `permission` object). This step sits outside the
deck diff by the spec's scope statement. A project-level `opencode.json`
carrying only this block is a valid partial application for isolated test
runs.

## What the block does not reach

Any merge or approval path not expressible as one of the patterns above —
and every merge or approval action — remains governed by the instruction
layer: floor.md's structural boundary and `git-workflow-pr` rules 6–7.
A deny miss is never a license; it is a gap to report and close.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)