---
remote_issue: 1013
remote_url: "https://github.com/michael-conrad/.opencode/issues/1013"
last_sync: 2026-06-14T20:50:47Z
source: github.com
---

> **Scope revision: `.opencode#1222` SC-13 protects behavioral evidence artifacts from deletion at the hand-off boundary via `artifact_hash` pinning — a file listed in the contract's `artifact_hashes` cannot be deleted while the contract is active. This protects evidence during pipeline execution. The deletion-at-cleanup issue (review-prep step running `rm -f`) remains as a separate concern — sub-agent task instructions must explicitly prohibit deleting `./tmp/evidence-*` files.**

> **URL construction fix is also unchanged — the review-prep task must enforce URL Sourcing Rule 2 (character-match verification).**

## Bug

In a pipeline session on `viewport-editor` (issue #41), a `general` sub-agent executing the `review-prep` task from `finishing-a-development-branch` produced two defects:

1. **Deleted behavioral evidence artifacts**: Ran `rm -f ./tmp/*.yaml ./tmp/*.md ./tmp/*.txt` which deleted auditor verdict YAMLs and evidence text files. Per `060-tool-usage.md` §3, behavioral evidence artifacts are exempt from mandatory cleanup and must be preserved until PR merge cleanup.

2. **Generated invalid compare URL**: Constructed a compare URL without character-match verification per URL Sourcing Rule 2.

## Remaining Scope

### Evidence artifact deletion during review-prep/cleanup

`#1222` SC-13 protects artifact_hash-pinned files at the hand-off boundary (can't delete while contract is active). However, the review-prep step is outside the hand-off contract boundary — it runs after all gates pass. The fix is in the `finishing-a-development-branch` task instructions: explicitly prohibit `rm -f ./tmp/` patterns and add entry/exit criteria referencing `060-tool-usage.md` §3.

### Invalid URL construction

Unchanged scope — `#1222` doesn't cover compare URL construction. The review-prep task must enforce URL Sourcing Rule 2 per `000-critical-rules.md`.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | review-prep task file explicitly prohibits deleting `./tmp/evidence-*` or `./tmp/*.yaml` | `string` |
| SC-2 | review-prep task file enforces URL Sourcing Rule 2 (character-match verification) | `string` |
| SC-3 | Behavioral test: review-prep sub-agent preserves evidence artifacts | `behavioral` |

🤖 OpenCode (deepseek-v4-flash)