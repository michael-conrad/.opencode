> Full spec: mirrored at https://github.com/Brothertown-Language/snea-phonetics/tree/issues-data/87/ (parent-repo companion spec #87)

## User Intent

Correct the agent guidance rule about `.issues/` folders in `.opencode/AGENTS.md`. The correct rule: use `git -C` for any git operations against `.issues/` (it is a git worktree); otherwise, standard file access tools (`read`/`write`/`edit`/`glob`/`grep`) are fine for `.issues/` files.

## Problem

`.opencode/AGENTS.md`, section "`.issues/` Is a Worktree — NOT a Regular Directory" (~lines 216–240), states a factually incorrect prohibition on standard file access:

> *"🚫 CRITICAL: Agents MUST NOT read/write `.issues/` files directly through git operations."* Using `read()`, `write()`, `edit()`, `glob()`, or `grep()` on `.issues/` paths in the parent repo silently targets the wrong repository and corrupts git state. All `.issues/` operations MUST go through `.opencode/tools/local-issues` or explicit `git -C <tree>/.issues/` commands.

This claim is wrong. `.issues/` is a real directory in the filesystem (a git worktree checkout); built-in file tools operate on actual filesystem paths and read/write exactly the files under `.issues/` — there is no "wrong repository" redirection for file content access. The prohibition needlessly forces every `.issues/` read through the `local-issues` CLI, degrading agent effectiveness (agents cannot grep/read issue specs during research).

What remains true and must be preserved:

- `.issues/` is a git worktree on the orphan `issues-data` branch — any **git operation** (status, log, add, commit, push, checkout) must target it with `git -C <tree>/.issues/` (or via the `local-issues` tool, which handles git internally).
- The parent repo's `git add .issues/` remains FORBIDDEN — it would corrupt parent-repo git state.
- The CRITICAL rule against reading/writing `.issues/` files **through parent-repo git operations** (`git add .issues/`) remains.

## Purpose

Replace the blanket file-access prohibition with the correct two-part rule so agents can use standard file tools on `.issues/` content while keeping all git operations correctly scoped with `git -C`.

## Scope

- Rewrite the "`.issues/` Is a Worktree — NOT a Regular Directory" section of `.opencode/AGENTS.md` (including its ✅ CORRECT / 🚫 FORBIDDEN table and surrounding paragraphs).
- Add a behavioral enforcement scenario under `.opencode/tests-v2/behaviors/` per the enforcement-test mandate.

**Out of scope:**

- Root-repo `AGENTS.md` (owned by parent repo, tracked as Brothertown-Language/snea-phonetics#87).
- `.opencode/guidelines/060-tool-usage.md` glob LIM-1/LIM-2 notes (factual tool limitations, not the defective rule).
- The `local` platform skill task cards (their `local-issues` mutation routing remains correct).

## Requirements

| Req | Statement |
|-----|-----------|
| R-1 | `.opencode/AGENTS.md` SHALL state the correct rule: `.issues/` is a git worktree; use `git -C <tree>/.issues/` for any git operations; standard file access tools (`read`/`write`/`edit`/`glob`/`grep`) are permitted for `.issues/` files. |
| R-2 | `.opencode/AGENTS.md` SHALL remove the "silently targets the wrong repository / corrupts git state" prohibition on `read`/`write`/`edit`/`glob`/`grep` for `.issues/` file content. |
| R-3 | `.opencode/AGENTS.md` SHALL retain `local-issues` (or `git -C`) as the required path for `.issues/` git mutations (stage/commit/push), and SHALL retain the CRITICAL rule against tracking `.issues/` in the parent repo (`git add .issues/` FORBIDDEN). |
| R-4 | `.opencode/AGENTS.md` SHALL remain internally consistent — no residual sentence elsewhere in the file contradicting the corrected rule. |
| R-5 | A behavioral enforcement scenario in `.opencode/tests-v2/behaviors/` SHALL verify: an agent instructed to read an `.issues/` spec file uses a standard file tool successfully, and performs `.issues/` git operations via `git -C .issues/` (never parent-repo `git add .issues/`). |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `.opencode/AGENTS.md` worktree section states standard file access to `.issues/` files is permitted | structural | grep of tracked file: corrected rule text present |
| SC-2 | `.opencode/AGENTS.md` no longer contains the "silently targets the wrong repository and corrupts git state" prohibition on `read`/`write`/`edit`/`glob`/`grep` | structural | grep: prohibition text absent |
| SC-3 | `.opencode/AGENTS.md` requires `git -C` for `.issues/` git operations and retains the parent-repo `git add .issues/` FORBIDDEN rule | structural | grep: both retained rules present |
| SC-4 | `.opencode/AGENTS.md` contains no residual sentence contradicting the corrected rule | structural | grep for contradicting phrases ("NEVER read/write", "MUST NOT read/write `.issues/` files") returns no file-access-prohibition hits outside the preserved git-op rule |
| SC-5 | Behavioral scenario passes: agent reads an `.issues/` file with a standard file tool and routes `.issues/` git ops through `git -C .issues/` | behavioral | `.opencode/tests-v2/behaviors/<scenario>.sh` via `opencode run`; stderr shows a file read of `.issues/...` and no parent-repo `git add .issues/` |

**Cost frames (dark-prose-007):** Each SC's verification is a grep (seconds) or one harness run; skipping any verification defers a wrong-rule regression to every future session — defect-discovery latency across the whole agent deck, not a one-time cost.

## Traceability

| Req | SC | Phase |
|-----|----|-------|
| R-1 | SC-1, SC-3 | 1 |
| R-2 | SC-2, SC-4 | 1 |
| R-3 | SC-3 | 1 |
| R-4 | SC-4 | 1 |
| R-5 | SC-5 | 2 |

## Approach

Direct text edit of the worktree section, preserving the section header and ✅/🚫 table structure. The behavioral scenario ships in the same change (enforcement-test mandate). `.opencode` is the upstream repo for this change; the parent repo consumes it via submodule sync.

## Alternatives Considered

| Alternative | Why discarded |
|-------------|---------------|
| Keep prohibition, add narrow file-read exception | Preserves the false premise (file tools redirect repos); agents would still detour reads through the CLI. |
| Delete the section entirely | Loses the still-true git-worktree facts (`git -C` for git ops; `git add .issues/` forbidden; `local-issues` mutation path). |
| Fix only parent-repo `AGENTS.md` | Leaves the submodule copy contradicted with the root file — inconsistency across the two agent-facing copies of the rule. |

## Key Design Decisions

- File access and git access are treated as separate axes: file tools touch filesystem content (always safe on a worktree checkout); git commands touch repository state (must be scoped with `git -C`).
- The `local-issues` tool remains the preferred interface for issue mutations (it commits/pushes correctly); the correction removes it as a forced intermediary for plain reads.

## Dependencies

- Parent-repo companion spec: Brothertown-Language/snea-phonetics#87 (root `AGENTS.md` section rewrite).

## Edge Cases

- `glob`/`grep` CWD-pattern invocation still skips hidden dirs (060-tool-usage LIM-1/LIM-2) — unchanged tool limitation; the path-parameter form reaches `.issues/`.
- `.opencode/.issues/` (the submodule's own issues worktree) follows the same corrected rule with `.opencode/.issues/` as the tree.

## Enforcement Gate

- SC-5 behavioral scenario is the enforcement gate; text-only SCs (SC-1..SC-4) are enforced at PR review by grep against the tracked file.

## Items

| Item | SC | Cycle |
|------|----|-------|
| 1. Rewrite `.opencode/AGENTS.md` worktree section | SC-1..SC-4 | RED: grep assertions fail on current text; GREEN: edits make them pass |
| 2. Add behavioral scenario script | SC-5 | RED: scenario fails against current guidance; GREEN: passes after item 1 |

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)

