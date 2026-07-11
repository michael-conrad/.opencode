# Plan: session-init Local Issue Folders refactor

## Goal

Rename `## Local Issue Artifacts` to `## Local Issue Folders`, change output format to inline `git -C` commands, reorder sections in `main()`, and remove the `path` field from the output.

## Architecture

Single file change to `.opencode/tools/session-init`. Two functions affected: `collect_issue_artifact_paths()` (return format change) and `main()` (emission code + section ordering). No new files, no new dependencies.

## Affected Files

- `.opencode/tools/session-init` — `collect_issue_artifact_paths()` (lines 650-681), `main()` (lines 705-784)

## Phase Table

| Phase | Description | Steps |
|-------|-------------|-------|
| 1 | Implement session-init output changes | 1.1–1.5 |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | Section header is `## Local Issue Folders` | 1 | 1.2 |
| SC-2 | Output format uses inline `git -C` commands | 1 | 1.1, 1.2 |
| SC-3 | No `path:` field in output | 1 | 1.1, 1.2 |
| SC-4 | Section emission order is correct | 1 | 1.3 |

## Safety/Rollback

**Phase 1 — Safety/Rollback:**
- Destructive operations: None (file edit only, no data mutation)
- Rollback plan: `git checkout -- .opencode/tools/session-init`
- Data loss risk: none

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `.opencode/tools/session-init` `collect_issue_artifact_paths()` | ✅ | `read` of file (lines 650-681) |
| 1.2 | `.opencode/tools/session-init` `main()` emission code (lines 770-777) | ✅ | `read` of file (lines 770-777) |
| 1.3 | `.opencode/tools/session-init` `main()` section ordering (lines 749-777) | ✅ | `read` of file (lines 749-777) |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| `collect_issue_artifact_paths()` returns `list[dict[str, str]]` with keys `path`, `issues` | `read` of file lines 650-681 | ✅ |
| `main()` emits sections in order: Repo Information, CLI Auth Status, Local Issue Artifacts | `read` of file lines 749-777 | ✅ |
| `main()` emits `## Local Issue Artifacts` header at line 772 | `read` of file line 772 | ✅ |

---

## Phase 1: Implement session-init output changes

### Step 1.1 — Modify `collect_issue_artifact_paths()` return format

**Chain:** none

**Action:** Change `collect_issue_artifact_paths()` to return a list of strings (inline `git -C` commands) instead of dicts with `path`/`issues` keys. Remove the `path` field from the output.

**Details:**
- Change return type from `list[dict[str, str]]` to `list[str]`
- Each entry format: `f"- {issues_rel}: git -C {issues_rel}"`
- Keep the `.issues/` worktree skip logic and `setup` key detection unchanged
- If `setup` is needed, emit: `f"- {issues_rel}: git -C {issues_rel}  # setup: create worktree from orphaned branch issues-data in repo {repo_name}"`

**SC coverage:** SC-2, SC-3

### Step 1.2 — Update `main()` emission code for new format

**Chain:** step_1.1

**Action:** Update the emission block in `main()` (lines 770-777) to:
1. Print `## Local Issue Folders` instead of `## Local Issue Artifacts`
2. Iterate over the new string list and print each entry directly (no `path:`/`issues:` sub-fields)

**SC coverage:** SC-1, SC-2, SC-3

### Step 1.3 — Reorder sections in `main()`

**Chain:** step_1.2

**Action:** Move the section emission blocks in `main()` to this order:
1. `## CLI Auth Status` (currently lines 759-764)
2. `## Local Issue Folders` (currently lines 770-777, renamed)
3. `## Repo Information` (currently lines 749-757)

**Details:**
- Current order: Repo Information → CLI Auth Status → Local Issue Artifacts
- New order: CLI Auth Status → Local Issue Folders → Repo Information
- The `project_root` line (line 767-768) and `## Agent Tools` section (lines 780-782) stay at their current relative positions (after Repo Information, at the end)

**SC coverage:** SC-4

### Step 1.4 — Update docstring

**Chain:** step_1.3

**Action:** Update the module docstring (line 17) to reference `## Local Issue Folders` instead of `## Local Issue Artifacts`.

**SC coverage:** SC-1

### Step 1.5 — Verify output

**Chain:** step_1.4

**Action:** Run `.opencode/tools/session-init` and verify:
- No `## Local Issue Artifacts` header (only `## Local Issue Folders`)
- No `path:` field in the Local Issue Folders section
- Format is `- <path>: git -C <path>`
- Section order: CLI Auth Status → Local Issue Folders → Repo Information

---

## Exit Criteria

- [ ] SC-1: `grep` for `## Local Issue Folders` in session-init output — must match
- [ ] SC-1: `grep` for `## Local Issue Artifacts` in session-init output — must NOT match
- [ ] SC-2: `grep` for `git -C` in session-init output — must match
- [ ] SC-3: `grep` for `path:` in session-init output's Local Issue Folders section — must NOT match
- [ ] SC-4: Section order verified by reading `main()` — CLI Auth Status first, Local Issue Folders second, Repo Information third
- [ ] All string SCs verified via `grep` (evidence type: `string`)
