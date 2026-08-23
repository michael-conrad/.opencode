---
remote_issue: 2306
remote_url: "https://github.com/michael-conrad/.opencode/issues/2306"
last_sync: 2026-08-23T18:04:00Z
source: github
---

> **Full spec and artifacts: [`.opencode/.issues/2306/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2306)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2306/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

**Problem:** The task card `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md` instructs syncing "dirty submodule pointers to latest trunk tip" without bounding scope to the parent repo's direct submodule pointers or forbidding recursion into nested submodules. A literal reading invites unbounded iteration that descends into nested submodules, violating the standing no-`--recursive` guideline in `060-tool-usage.md` §4 and producing false "changed submodule" (`+`) flags in the parent repo.

**Scope:**
- Bound the task card's sync operation to the parent repo's direct submodule pointers passed in `submodule_paths`.
- Forbid recursion into nested submodules.
- Permit explicit per-submodule operations, including `git submodule foreach` invoked without `--recursive` — guideline §4 forbids only the `--recursive` flag.
- Mirror the no-`--recursive` constraint from `060-tool-usage.md` §4.
- Direct explicit per-submodule operations and document false-pointer-flag avoidance.
- Preserve the existing `--ff-only` divergence handling unchanged.

**Out of scope:**
- `trunk-tip-verification.md`'s read-only verification concern.
- `reference/submodule-divergence.md`.
- `060-tool-usage.md` itself (already correct — authoritative source to mirror).
- Any git behavior, config, or runtime change.

**Approach:** Modify the task card text to explicitly bound scope to direct submodule pointers, forbid recursion into nested submodules, permit explicit per-submodule operations including `git submodule foreach` without `--recursive`, mirror the standing no-`--recursive` guideline, and document false-pointer-flag avoidance. The `--ff-only` divergence handling block is preserved byte-identical. This is a documentation/instruction fix with no runtime code path changes.

**Impact:**
- Risk 1: Wording diverges from the guideline — mitigation: mirror the guideline language verbatim.
- Risk 2: Divergence handling regresses — mitigation: preserve the block byte-identical and verify.
- Risk 3: Scope bound omitted — mitigation: explicit `submodule_paths` reference in the task card.
- Dependencies: `060-tool-usage.md` §4 (authoritative source).
- Call to action: Review the revised spec reflecting the developer ruling that non-recursive `foreach` is an authorized explicit per-submodule operation.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
🤖 Co-authored with AI: OpenCode (ox-alpha)
