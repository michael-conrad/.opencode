# AGENTS.md — .issues/ Workspace Guide

## Identity

`.issues/` is a standalone git repository with an `issues-data` orphan branch, stored as a git worktree of the parent repo at `.git/worktrees/-issues/`. It uses the same remote as the parent repo (determined at runtime via `git -C .issues remote -v`), on the `issues-data` branch.

**This is NOT a submodule.** It is an orphan branch worktree. Do not add it as a submodule or `.gitmodules` entry.

## Tool

All issue-tracking operations go through the `local-issues` tool. The tool's
operating contract — invocation, qualified `repo#N` names, command behavior,
sync/mirroring mechanics, session-start sequence — lives in the **`issues`
skill card** (`.opencode/skills/issues/SKILL.md`) and its detail cards under
`.opencode/skills/issues/references/`; the script's `--help` is the
flag-level source of truth. This guide does not duplicate tool usage
documentation. Do not manipulate `.issues/` files manually unless the tool
cannot perform the required operation.

## Workflow

**Remote-first issue-number reservation (MANDATORY when a remote issue tracker exists).** When the platform is not local (a remote issue tracker is reachable), file the remote issue FIRST — for EVERY issue creation (spec, bug, defect, artifact — anything that mints a number) — with clear intent and context sufficient for a clean-room restart — to reserve the issue number, BEFORE any local issue folder setup. Local-first reservation is a violation: it forks the number space and produces split-brain collisions (recorded precedent: issue 2450's local-vs-remote number divergence; recurrence 2026-10-05: `opencode-config#373` minted from a stale local number while remote-synced issues had reached 2161 — deleted unfiled). This mandate composes with (and does not duplicate) the numbers-must-match rule: the remote API is the sole number source whenever a remote exists; remoteless stores pick the next free number in that repo's own namespace.

All git operations (commit, push) on the issues worktree are handled automatically by the tool after mutation commands. You do NOT need to run `git -C .issues` commands manually.

### Session start

At session start, run the tool's `init` and `sync` sequence (bootstrap
worktrees, pull remote `issues-data`, commit + pull-rebase + push for
bidirectional currency) and reconcile remote issue content against local
`.issues/` — exact commands and failure handling are in the `issues` skill
card and its sync detail card.

> **Cross-reference:** [`lessons-learned/`](lessons-learned/) — per-session correction catalogs for systemic defect patterns. Agents read this at session start per §When to Read below.

## Directory Layout

```
.issues/
  {issue_number}/
    spec.md                    — The full authoritative spec (the store is primary; the remote body carries the structured summary per the deck's remote-body-format reference)
    plan.md                    — Implementation plan (RED/GREEN items, dependency graph)
    cards.md                   — Card catalogue with status and decision log
    dependency-contract.yaml   — Dependency contracts and phase ordering
    research/                  — Investigation findings, capability probes, evidence notes
    designs/                   — UI wireframes, architecture diagrams, design artifacts
    audit/                     — Adversarial audit verdicts, cross-validate consensus
  AGENTS.md                    — This file
  _legacy/                     — Archived pre-worktree-format content ({N}-{slug}/, open/, closed/ remnants); not parseable issue numbers — never create here
  lessons-learned/             — Per-session corrections and defect patterns for clean-room review
    session-YYYY-MM-DD/
      README.md                — Correction catalog with root cause analysis
      artifacts/               — Evidence (problem files, stderr, tool outputs)
```

### Example: Spec-Artifact Placement

| Artifact | Path |
|----------|------|
| Card catalogue with all card findings | `.issues/46/cards.md` |
| Implementation plan with RED/GREEN items | `.issues/46/plan.md` |
| Dependency contract for state machine | `.issues/46/dependency-contract.yaml` |
| FastMCP capability probe results | `.issues/46/research/fastmcp-capabilities.md` |
| In-memory client migration design | `.issues/46/designs/in-memory-fixture.md` |
| Adversarial audit consensus verdict | `.issues/46/audit/consensus.yaml` |
| Session 2026-06-06 corrections | `.issues/lessons-learned/session-2026-06-06/README.md` |

## Git Display Quirks Inside This Workspace

Observed quirks when inspecting git from inside this workspace (#2548 C11):

- **`git worktree list` inside `.opencode`** reports the submodule's main
  worktree row as the module gitdir (`.git/modules/.opencode`) — not a real
  worktree path. `git -C .opencode rev-parse --show-toplevel` returns the
  correct `.opencode`; trust that over the worktree-list row.
- **`git submodule status` `+` prefix** means checked-out commit differs from
  the recorded gitlink pointer (parent `git status --porcelain` shows
  ` M .opencode`) — pointer drift for the next real parent-repo change to
  carry, NOT a request for `git submodule update` (which would check out the
  recorded SHA and disrupt in-progress submodule work).
- **This guide lives on the `issues-data` worktree** and is unreadable in a
  fresh clone before `local-issues init` runs. The tracked `issues` skill
  card (`.opencode/skills/issues/SKILL.md`) is the
  bootstrap-order-independent entry point.

## Exclusions — Content Boundary

`.issues/` holds issue metadata only — never source/test/fixture/code.

The `.issues/` worktree is a metadata-only store. The following content types MUST NOT live in `.issues/`:

- Source code (`.py`, `.ts`, `.js`, `.rs`, `.go`, `.java`, etc.)
- Test files and test fixtures
- Test configuration
- Application code of any language
- Build artifacts, lock files, or compiled outputs

`.issues/` is reserved for spec/plan/card/design/research/audit metadata and evidence artifacts associated with issue tracking. It is not a code directory. Never source/test/fixture/code.

## Authorization

Reading and writing `.issues/` is **authorization-free** — it is workspace-local metadata, not implementation code. All spec/plan/card operations within `.issues/` may proceed without `"approved"` or `"go"`.

Creating `feature/*` or `spec/*` branches for code changes still requires `for_implementation` or above scope.

### Issues-Data Hygiene Mandate

It is the agent's responsibility to repair, remediate, and revise as needed ALL issue-ticket data files in the issues-data branches to prevent problems. Issue-ticket data repairs (fixing malformed YAML, correcting stale metadata, reconciling drifted records) are **authorization-free agent hygiene** and do **NOT** require a spec.

This extends the authorization-free reading/writing rule above: the agent does not merely *may* touch `.issues/` files — it is *responsible* for their correctness. An agent that encounters drift or defects in issues-data records and leaves them unrepaired (or halts awaiting authorization or a spec) has failed its hygiene duty.

**Scope boundary (extends the rules above, does not contradict them):** Hygiene applies ONLY to issue-ticket data records inside `.issues/`. It never authorizes source-code changes — those still require spec + `for_implementation` per the repo-wide approval gate — and it never authorizes creating `feature/*` or `spec/*` branches; hygiene edits happen on the `issues-data` branch via the `local-issues` tool.

**Rationale:** Legacy drift across 374 issues-data files previously blocked pipelines that validate the whole workspace; repairs stalled because agents wrongly treated record fixes as implementation requiring spec + authorization. The developer directed on 2026-09-17 that issue-ticket data repairs are hygiene, not implementation.

## Relationship to Remote Issue Tracker

- **`.issues/` is the PRIMARY spec/plan store.** All authoritative content — specs, plans, card catalogues, dependency contracts, research — lives here in the `issues-data` branch.
- **GitHub/GitBucket is the mirrored user-facing surface.** The remote issue body's required shape is defined by the deck's [remote-body-format reference](../skills/spec/references/remote-body-format.md) — this guide carries no operational format rules.
- AI agents MUST read from `.issues/` — never treat the remote issue body as authoritative.
- `.issues/{N}/` contents beyond the record set (plan.md, cards.md, sub-directories) are NEVER mirrored to the remote tracker.
- When reading or acting on an issue, always read from `.issues/{N}/` first. Only use the remote issue body for user-facing context (comments, labels, assignees).

## Lessons Learned Registry

`lessons-learned/` captures per-session correction catalogs for clean-room agent review. Each session subdirectory contains:

| File | Purpose |
|------|---------|
| `README.md` | Correction catalog with root cause analysis, systemic vs. one-off classification, remediation targets |
| `artifacts/` | Evidence: problem files, stderr output, tool results |

### When to Read

At the START of every session, a clean-room agent MUST:

1. List `lessons-learned/` subdirectories
2. Read each `README.md` that has not been marked `consumed`
3. For each systemic lesson, file a bug/SPEC-FIX issue targeting the identified remediation file
4. After filing, add a `consumed: YYYY-MM-DD` marker to the lesson's frontmatter

A lesson is "consumed" when a bug-fix issue or PR has been created for it. The lesson stays in the directory for audit trail — do not delete it.
