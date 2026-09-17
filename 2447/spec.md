> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2447/

# SPEC-FIX: .opencode/.issues/ Is Not an Agent-Managed Issue Folder

## Intent and Executive Summary

- **Problem Statement:** `.opencode/AGENTS.md` (§ Issues Path Resolution, § .issues/ Is a Worktree) and the session-init `## Local Issue Folders` output direct agents to route `.opencode` defect reports through `local-issues` into `.opencode/.issues/` and to create that path as an orphan-branch worktree. Following this guidance, an agent created the worktree, committed local tickets, and attempted a push that cannot succeed (`michael-newsrx` is denied push to `michael-conrad/.opencode`).
- **Root Cause / Motivation:** The guidance predates the owner directive (2026-09-14) that `.opencode/` is read-only for agents and that `.opencode` tickets go through the GitHub API against `michael-conrad/.opencode`. The defective guidance re-emits every session via the `opencode.jsonc` instructions array and the session-init plugin, so every new agent is re-exposed.
- **Approach Chosen:** Remove the `.opencode` worktree setup hint from session-init's `collect_issue_artifact_paths()`, rewrite the `.opencode/AGENTS.md` issue-routing sections to mandate GitHub API ticket filing for `.opencode`, and remove the `.opencode/.issues/` worktree registration (destructive; authorization-gated).
- **Alternatives Considered & Why Discarded:** (1) Annotate the session-init hint as "not for agent use" instead of removing it — discarded because a conditional annotation keeps a dead path reachable and re-invites the defect; removal is unambiguous. (2) Keep `.opencode/.issues/` as a read-only historical archive — discarded because local commits on `issues-data` are unsharable (push denied), so the archive has no durable value and the worktree registration keeps re-appearing in session output.
- **Key Design Decisions:** Fix delivery is a PR against `michael-conrad/.opencode` (label `approved-for-pr` present) — the defective files live inside the read-only `.opencode/` tree, so no local mutation of those files is permitted. SC-5 (worktree removal) is destructive and is marked as requiring explicit developer authorization beyond the existing `approved-for-pr` label (critical-rules-052); the removal step MUST NOT execute without that authorization.
- **User Intent / Original Prompt:** Issue michael-conrad/.opencode#2447 "[BUG] AGENTS.md needs clarification on when .opencode/.issues/ should (not) be checked out as a worktree" — the owner directive that `.opencode/.issues/` is not agent-managed and `.opencode` tickets go via the GitHub API.

## Not Included

- **Root-repo `.issues/` workflow** — the parent repo's `.issues/` worktree is legitimate, agent-managed, and functioning; no changes to `local-issues` routing for `opencode-config#N`.
- **session-init repo-info emission generally** — only the `.opencode` setup-hint branch of `collect_issue_artifact_paths()` changes; the root-repo entry and all other emission logic are unchanged.
- **Push-permission remediation on `michael-conrad/.opencode`** — the `michael-newsrx` push denial is an access-control fact, not a defect to fix here.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `collect_issue_artifact_paths()` emits no worktree-creation setup hint for a repo entry whose `.issues` directory does not exist (the `# setup: create worktree from orphaned branch issues-data` text no longer appears in session-init output). | behavioral | pytest in `.opencode/tests/` — call `collect_issue_artifact_paths()` with synthetic repo_info including the `.opencode` entry and no `.opencode/.issues` dir; assert the hint string is absent from the function's emitted output. |
| SC-2 | The session-init root-repo `.issues/` entry emission is unchanged after the hint-removal change. | behavioral | pytest in `.opencode/tests/` — call `collect_issue_artifact_paths()` with synthetic repo_info and assert the root-repo entry output is byte-identical to the pre-change emission. |
| SC-3 | `.opencode/AGENTS.md` issue-routing sections state that `.opencode` defect reports and tickets are filed via the GitHub API against `michael-conrad/.opencode`. | semantic | Clean-room sub-agent reads the revised sections and judges that the GitHub-API ticket-filing directive is unambiguous. |
| SC-4 | `.opencode/AGENTS.md` no longer routes `.opencode` tickets through `local-issues` into `.opencode/.issues/` (the `.opencode#N → .opencode/.issues/` mapping is removed). | string | grep asserts the `.opencode#N → .opencode/.issues/` mapping is absent from `.opencode/AGENTS.md`. |
| SC-5 | The `.opencode/.issues/` worktree registration is removed (`git -C .opencode worktree list` shows no `.issues` worktree). **⛔ REQUIRES EXPLICIT DEVELOPER AUTHORIZATION — destructive step; MUST NOT execute on the `approved-for-pr` label alone (critical-rules-052).** | structural | `git -C .opencode worktree list` output as evidence; execution gated on a separate explicit developer authorization. |

## Requirements

- R-1. The session-init `collect_issue_artifact_paths()` function SHALL NOT emit a worktree-creation setup hint for the `.opencode` repo entry (or any repo entry) when its `.issues/` directory does not exist.
- R-2. The session-init `## Local Issue Folders` output SHALL continue to list the root-repo `.issues/` entry unchanged.
- R-3. `.opencode/AGENTS.md` SHALL state that `.opencode/` is read-only for agents: agents SHALL NOT create, populate, or push `.opencode/.issues/`, and `.opencode` defect reports and tickets SHALL be filed via the GitHub API against `michael-conrad/.opencode`.
- R-4. The `.opencode/.issues/` worktree registration SHALL be removed — but only after explicit developer authorization for the destructive step.

## Items

### Item 1 (SC-1): Remove `.opencode` worktree setup hint from session-init

- RED: pytest unit test asserting `collect_issue_artifact_paths()` output for a synthetic `.opencode` entry with no `.issues` dir contains no `setup: create worktree` hint (SC-1) — fails before the change.
- GREEN: Remove the hint-append branch in `collect_issue_artifact_paths()` in `.opencode/tools/session-init` (delivered as PR against `michael-conrad/.opencode`; no direct local mutation).
- verify: run the unit test suite for `.opencode/tests/`; confirm the SC-1 assertion passes.
- commit: one commit on the `.opencode` feature branch scoped to session-init.

### Item 2 (SC-2): Root-repo `.issues/` emission invariance test

- RED: paired invariance pytest assertion in its own item — call `collect_issue_artifact_paths()` with synthetic repo_info and assert the root-repo entry emission is byte-identical to the pre-change output (SC-2) — passes before the change (invariance RED); it becomes the regression guard that fails if the hint removal perturbs the root entry.
- GREEN: Keep the root-repo emission path untouched while executing Item 1; the invariance assertion guards it.
- verify: run the unit test suite for `.opencode/tests/`; confirm the root entry assertion (SC-2) passes.
- commit: one commit on the `.opencode` feature branch scoped to session-init (may share the Item 1 commit only if both SCs land in the same atomic slice; the item remains a distinct SC with its own RED/GREEN cycle).

### Item 3 (SC-3): Mandate GitHub API ticket filing in `.opencode/AGENTS.md`

- RED: clean-room sub-agent reads the current § Issues Path Resolution / § .issues/ Is a Worktree sections and finds no unambiguous GitHub-API ticket-filing directive for `.opencode` (SC-3) — fails before the change.
- GREEN: Rewrite the sections to state that `.opencode` defect reports and tickets are filed via the GitHub API against `michael-conrad/.opencode` (SC-3).
- verify: clean-room sub-agent reads the revised sections and confirms the GitHub-API routing directive is unambiguous (SC-3).
- commit: one commit on the `.opencode` feature branch scoped to AGENTS.md.

### Item 4 (SC-4): Remove `.opencode#N` local-issues routing mapping

- RED: removal-assertion grep test in its own item — grep asserting `.opencode/AGENTS.md` contains no `.opencode#N → .opencode/.issues/` local-issues routing (SC-4) — fails before the change.
- GREEN: Remove the `.opencode#N → .opencode/.issues/` mapping and any prose routing `.opencode` tickets through `local-issues` (SC-4).
- verify: grep confirms the local-issues routing mapping is removed (SC-4).
- commit: one commit on the `.opencode` feature branch scoped to AGENTS.md.

### Item 5 (SC-5): Remove `.opencode/.issues/` worktree ⛔ AUTHORIZATION-GATED

- RED: `git -C .opencode worktree list` shows the `.issues` worktree — the removal test fails before execution.
- GREEN: Execute `git -C .opencode worktree remove .issues` (and prune the orphan-branch registration) — ONLY after explicit developer authorization beyond `approved-for-pr`.
- verify: `git -C .opencode worktree list` shows no `.issues` worktree.
- commit: no repo commit required (git-state operation); record removal evidence in the issue.

## Dependencies

- **Reference:** `michael-conrad/.opencode` push/PR access — Relationship: fix delivery requires a PR against the `.opencode` repo; Status: pending (push currently denied for `michael-newsrx` — PR must be created from an authorized account).
- **Reference:** Owner directive (2026-09-14, recorded in issue #2447 body) — Relationship: defines the required end-state guidance; Status: satisfied.
- **Reference:** critical-rules-052 (file/destructive-state removal requires spec + authorization) — Relationship: gates Item 5 (SC-5); Status: spec satisfied, explicit destructive-step authorization pending.

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Item 1 |
| R-2 | SC-2 | Item 2 |
| R-3 | SC-3, SC-4 | Items 3, 4 |
| R-4 | SC-5 | Item 5 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| Issue #2447 bug report | issue | https://github.com/michael-conrad/.opencode/issues/2447 | read (gh issue view) |
| session-init `collect_issue_artifact_paths()` | code | `.opencode/tools/session-init` — `collect_issue_artifact_paths()` function | read (`collect_issue_artifact_paths()`) |
| `.opencode/AGENTS.md` routing sections | doc | `.opencode/AGENTS.md` § Issues Path Resolution / § .issues/ Is a Worktree | grep + read |
| Owner directive | discussion | recorded in issue #2447 body (2026-09-14) | read |
| Pre-spec inspection artifact | artifact | `.opencode/.issues/2447/artifacts/pre-spec-inspection.yaml` | copied from analysis step |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted. SC-5 additionally requires explicit developer authorization for the destructive step and MUST NOT be counted complete without it.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1 / SC-2:** Running the session-init unit test costs minutes of execution time. Skipping means the defective setup hint re-emits into every future session's system prompt, re-exposing every agent to the forbidden worktree creation for weeks.
- **SC-3 / SC-4:** The clean-room read + grep costs minutes. Skipping means agents keep filing `.opencode` tickets into an unsharable local branch, losing defect reports and repeating the removal cleanup each time.
- **SC-5:** `git worktree list` verification costs seconds. Skipping the authorization gate risks a destructive removal executed without consent — an irreversible loss of local ticket history. Correctness (and consent) is the only metric.

## Edge Cases

- **Input boundaries:** `collect_issue_artifact_paths()` with a repo list lacking the `.opencode` entry — SHALL behave unchanged (root entry only). With both root and `.opencode` entries and both `.issues` dirs present — SHALL emit both listing lines unchanged.
- **State transitions:** After SC-5 executes, `local-issues` qualified-name operations against `.opencode#N` SHALL resolve to a nonexistent folder and fail fast with a clear error — not silently recreate the directory.
- **Failure modes:** If the `.opencode` PR cannot be pushed from the current account, Items 1-2 remain BLOCKED on delivery; the spec content in this issue is the durable record.
- **Concurrency:** Another agent holding the `.opencode/.issues` worktree during SC-5 removal — `git worktree remove` fails on a dirty worktree; resolution: require a clean worktree state before removal.
- **Recovery:** If SC-5 removal is executed in error, the `issues-data` branch in `.opencode` still holds committed history until branch deletion; recovery is re-registering the worktree from the branch — before branch deletion, after which recovery is impossible.

---

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)

---

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-09-17 | Decomposed SC-1 into SC-1 (no worktree hint, behavioral) + SC-2 (root entry unchanged, structural); decomposed former SC-2 into SC-3 (GitHub API filing mandate, semantic) + SC-4 (no local-issues routing, structural); renumbered former SC-3 → SC-5 with authorization marker intact; renumbered Items/traceability/cost-frame/edge-case references accordingly; declared SC-1 behavioral (pytest execution is behavioral evidence). | Validation findings: compound-SC decomposition atomicity failure (SC-1, SC-2) and EVIDENCE_TYPE_MISMATCH (SC-1 declared structural but verified via pytest test execution). | Validation gate findings on spec revision (spec-creation revise pipeline) |
| 2026-09-17 | Updated `testability-assessment.yaml` (SC numbering, evidence types: SC-1 behavioral, SC-2 structural, SC-3 semantic, SC-4 structural) and `interface-compatibility.yaml` (session-init change: hint removal not annotation; AGENTS.md routing contract change: removal of `.opencode#N` mapping) to match the revised spec. Artifacts directory NOT wholesale-deleted (revise Step 7 superseded): validation finding (4) explicitly requires the artifacts to be updated to match the revised spec, and they serve as the referenced validation evidence; stale-SC references in both updated artifacts were corrected in place. | Validation warnings: artifact/spec divergence on SC-2 evidence type and interface change kind; revise Step 7 conflict with finding (4). | Validation gate findings on spec revision |
| 2026-09-17 (iteration 2) | Redeclared SC-2 evidence type structural → behavioral (verified by pytest execution) and SC-4 structural → string (verified by grep) per EVIDENCE_TYPE_MISMATCH findings (1). Split compound Items 1-2 into five per-SC items (Item 1 SC-1, Item 2 SC-2 invariance, Item 3 SC-3, Item 4 SC-4 removal-assertion, Item 5 SC-5 unchanged) with own RED/GREEN cycles per SC↔Item mapping finding (2). Updated `blast-radius.yaml` and `concern-map.yaml` SC numbering to SC-1..SC-5 per finding (3). Replaced line-number verification cell "read (sed 495-535)" with stable anchor `collect_issue_artifact_paths()` per finding (4). SC-5 authorization marker preserved. Regenerated sc-summary.yaml (5 SCs) and remote exec-summary body. | Validation findings, iteration 2 (spec-creation revise pipeline). | Validation gate findings on spec revision |
| 2026-09-17 (iteration 3) | Dependencies section: corrected stale cross-reference "gates Item 3" → "gates Item 5 (SC-5)" for the critical-rules-052 entry. | Single-line validation finding: reference was stale after Item renumbering — the destructive step gated by critical-rules-052 is now Item 5 (SC-5). | Validation gate finding on spec revision (spec-creation revise pipeline) |
