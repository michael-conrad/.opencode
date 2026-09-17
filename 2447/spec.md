> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2447/

# SPEC-FIX: .opencode/.issues/ Is Not an Agent-Managed Issue Folder

## Intent and Executive Summary

- **Problem Statement:** `.opencode/AGENTS.md` (§ Issues Path Resolution, § .issues/ Is a Worktree) and the session-init `## Local Issue Folders` output direct agents to route `.opencode` defect reports through `local-issues` into `.opencode/.issues/` and to create that path as an orphan-branch worktree. Following this guidance, an agent created the worktree, committed local tickets, and attempted a push that cannot succeed (`michael-newsrx` is denied push to `michael-conrad/.opencode`).
- **Root Cause / Motivation:** The guidance predates the owner directive (2026-09-14) that `.opencode/` is read-only for agents and that `.opencode` tickets go through the GitHub API against `michael-conrad/.opencode`. The defective guidance re-emits every session via the `opencode.jsonc` instructions array and the session-init plugin, so every new agent is re-exposed.
- **Approach Chosen:** Remove the `.opencode` worktree setup hint from session-init's `collect_issue_artifact_paths()`, rewrite the `.opencode/AGENTS.md` issue-routing sections to mandate GitHub API ticket filing for `.opencode`, and remove the `.opencode/.issues/` worktree registration (destructive; authorization-gated).
- **Alternatives Considered & Why Discarded:** (1) Annotate the session-init hint as "not for agent use" instead of removing it — discarded because a conditional annotation keeps a dead path reachable and re-invites the defect; removal is unambiguous. (2) Keep `.opencode/.issues/` as a read-only historical archive — discarded because local commits on `issues-data` are unsharable (push denied), so the archive has no durable value and the worktree registration keeps re-appearing in session output.
- **Key Design Decisions:** Fix delivery is a PR against `michael-conrad/.opencode` (label `approved-for-pr` present) — the defective files live inside the read-only `.opencode/` tree, so no local mutation of those files is permitted. SC-3 (worktree removal) is destructive and is marked as requiring explicit developer authorization beyond the existing `approved-for-pr` label (critical-rules-052); the removal step MUST NOT execute without that authorization.
- **User Intent / Original Prompt:** Issue michael-conrad/.opencode#2447 "[BUG] AGENTS.md needs clarification on when .opencode/.issues/ should (not) be checked out as a worktree" — the owner directive that `.opencode/.issues/` is not agent-managed and `.opencode` tickets go via the GitHub API.

## Not Included

- **Root-repo `.issues/` workflow** — the parent repo's `.issues/` worktree is legitimate, agent-managed, and functioning; no changes to `local-issues` routing for `opencode-config#N`.
- **session-init repo-info emission generally** — only the `.opencode` setup-hint branch of `collect_issue_artifact_paths()` changes; the root-repo entry and all other emission logic are unchanged.
- **Push-permission remediation on `michael-conrad/.opencode`** — the `michael-newsrx` push denial is an access-control fact, not a defect to fix here.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `collect_issue_artifact_paths()` emits no worktree-creation setup hint for a repo entry whose `.issues` directory does not exist (the `# setup: create worktree from orphaned branch issues-data` text no longer appears in session-init output); the root-repo entry is unchanged. | structural | pytest in `.opencode/tests/` — call `collect_issue_artifact_paths()` with synthetic repo_info including the `.opencode` entry and no `.opencode/.issues` dir; assert the hint string is absent and the root entry is unchanged. |
| SC-2 | `.opencode/AGENTS.md` issue-routing sections state that `.opencode` defect reports and tickets are filed via the GitHub API against `michael-conrad/.opencode`, and no longer route `.opencode` tickets through `local-issues` into `.opencode/.issues/`. | semantic | Clean-room sub-agent reads the revised sections and judges that the routing directive is unambiguous; grep asserts the `.opencode#N → .opencode/.issues/` mapping is removed and a GitHub-API instruction is present. |
| SC-3 | The `.opencode/.issues/` worktree registration is removed (`git -C .opencode worktree list` shows no `.issues` worktree). **⛔ REQUIRES EXPLICIT DEVELOPER AUTHORIZATION — destructive step; MUST NOT execute on the `approved-for-pr` label alone (critical-rules-052).** | structural | `git -C .opencode worktree list` output as evidence; execution gated on a separate explicit developer authorization. |

## Requirements

- R-1. The session-init `collect_issue_artifact_paths()` function SHALL NOT emit a worktree-creation setup hint for the `.opencode` repo entry (or any repo entry) when its `.issues/` directory does not exist.
- R-2. The session-init `## Local Issue Folders` output SHALL continue to list the root-repo `.issues/` entry unchanged.
- R-3. `.opencode/AGENTS.md` SHALL state that `.opencode/` is read-only for agents: agents SHALL NOT create, populate, or push `.opencode/.issues/`, and `.opencode` defect reports and tickets SHALL be filed via the GitHub API against `michael-conrad/.opencode`.
- R-4. The `.opencode/.issues/` worktree registration SHALL be removed — but only after explicit developer authorization for the destructive step.

## Items

### Item 1 (SC-1): Remove `.opencode` worktree setup hint from session-init

- RED: pytest unit test asserting `collect_issue_artifact_paths()` output for a synthetic `.opencode` entry with no `.issues` dir contains no `setup: create worktree` hint — fails before the change.
- GREEN: Remove the hint-append branch in `collect_issue_artifact_paths()` in `.opencode/tools/session-init` (delivered as PR against `michael-conrad/.opencode`; no direct local mutation).
- verify: run the unit test suite for `.opencode/tests/`; confirm root entry assertion still passes.
- commit: one commit on the `.opencode` feature branch scoped to session-init.

### Item 2 (SC-2): Rewrite `.opencode/AGENTS.md` issue-routing guidance

- RED: grep/semantic test asserting `.opencode/AGENTS.md` contains no `.opencode#N → .opencode/.issues/` local-issues routing and does contain the GitHub API ticket-filing mandate — fails before the change.
- GREEN: Rewrite the § Issues Path Resolution and § .issues/ Is a Worktree sections to mandate GitHub API filing for `.opencode` tickets and prohibit creating/pushing `.opencode/.issues/`.
- verify: clean-room sub-agent reads the revised sections and confirms unambiguous routing.
- commit: one commit on the `.opencode` feature branch scoped to AGENTS.md.

### Item 3 (SC-3): Remove `.opencode/.issues/` worktree ⛔ AUTHORIZATION-GATED

- RED: `git -C .opencode worktree list` shows the `.issues` worktree — the removal test fails before execution.
- GREEN: Execute `git -C .opencode worktree remove .issues` (and prune the orphan-branch registration) — ONLY after explicit developer authorization beyond `approved-for-pr`.
- verify: `git -C .opencode worktree list` shows no `.issues` worktree.
- commit: no repo commit required (git-state operation); record removal evidence in the issue.

## Dependencies

- **Reference:** `michael-conrad/.opencode` push/PR access — Relationship: fix delivery requires a PR against the `.opencode` repo; Status: pending (push currently denied for `michael-newsrx` — PR must be created from an authorized account).
- **Reference:** Owner directive (2026-09-14, recorded in issue #2447 body) — Relationship: defines the required end-state guidance; Status: satisfied.
- **Reference:** critical-rules-052 (file/destructive-state removal requires spec + authorization) — Relationship: gates Item 3; Status: spec satisfied, explicit destructive-step authorization pending.

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Item 1 |
| R-2 | SC-1 | Item 1 |
| R-3 | SC-2 | Item 2 |
| R-4 | SC-3 | Item 3 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| Issue #2447 bug report | issue | https://github.com/michael-conrad/.opencode/issues/2447 | read (gh issue view) |
| session-init `collect_issue_artifact_paths()` | code | `.opencode/tools/session-init` | read (sed 495-535) |
| `.opencode/AGENTS.md` routing sections | doc | `.opencode/AGENTS.md` § Issues Path Resolution / § .issues/ Is a Worktree | grep + read |
| Owner directive | discussion | recorded in issue #2447 body (2026-09-14) | read |
| Pre-spec inspection artifact | artifact | `.opencode/.issues/2447/artifacts/pre-spec-inspection.yaml` | copied from analysis step |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted. SC-3 additionally requires explicit developer authorization for the destructive step and MUST NOT be counted complete without it.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Running the session-init unit test costs minutes of execution time. Skipping means the defective setup hint re-emits into every future session's system prompt, re-exposing every agent to the forbidden worktree creation for weeks.
- **SC-2:** The clean-room read + grep costs minutes. Skipping means agents keep filing `.opencode` tickets into an unsharable local branch, losing defect reports and repeating the removal cleanup each time.
- **SC-3:** `git worktree list` verification costs seconds. Skipping the authorization gate risks a destructive removal executed without consent — an irreversible loss of local ticket history. Correctness (and consent) is the only metric.

## Edge Cases

- **Input boundaries:** `collect_issue_artifact_paths()` with a repo list lacking the `.opencode` entry — SHALL behave unchanged (root entry only). With both root and `.opencode` entries and both `.issues` dirs present — SHALL emit both listing lines unchanged.
- **State transitions:** After SC-3 executes, `local-issues` qualified-name operations against `.opencode#N` SHALL resolve to a nonexistent folder and fail fast with a clear error — not silently recreate the directory.
- **Failure modes:** If the `.opencode` PR cannot be pushed from the current account, Items 1-2 remain BLOCKED on delivery; the spec content in this issue is the durable record.
- **Concurrency:** Another agent holding the `.opencode/.issues` worktree during SC-3 removal — `git worktree remove` fails on a dirty worktree; resolution: require a clean worktree state before removal.
- **Recovery:** If SC-3 removal is executed in error, the `issues-data` branch in `.opencode` still holds committed history until branch deletion; recovery is re-registering the worktree from the branch — before branch deletion, after which recovery is impossible.

---

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)

---

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
