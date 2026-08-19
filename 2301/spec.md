> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/N/

## Problem

The `import-remote` workflow (`.opencode/skills/issue-operations-sync/tasks/import-remote.md`) HALTs with "issue already imported" whenever the local issue directory exists, but it does NOT verify that all required mirror files are actually present and complete. A directory that exists with only a partial mirror (e.g., `issue.yaml`, `comments.yaml`, `links.yaml`, `remote.md` but no `spec.md`) is treated as fully imported, so the missing `spec.md` is never materialized. This incomplete local spec folder then breaks downstream pipelines (e.g., the spec-creation revise pipeline loops because its entry criteria require `spec.md` at the spec path).

## Scope

- **In-scope:**
  - Modify `import-remote` so that when the local issue directory exists, it checks ALL required mirror files (`spec.md`, `comments.md`, `remote.md`, `state.md`, and frontmatter with `github_issue`/`remote_url`) and materializes any that are missing rather than halting on directory existence alone.
  - Add a behavioral/structural test proving a folder that exists without `spec.md` is completed (spec.md materialized) rather than halted.
  - Update the Edge Cases table entry for "Issue already imported" to reflect the new completeness-check behavior.
- **Out of scope:**
  - Changing the remote issue import content itself (body, comments, frontmatter format).
  - Altering the `.counter` advancement logic.
  - Changes to other sync tasks (`sync-pull-to-local`, `retroactive-import`).

## Approach

Replace the directory-existence-only halt with a completeness gate. When the local issue directory exists, `import-remote` must enumerate the required mirror files and materialize any that are absent (fetching the remote body/comments/frontmatter as needed), only halting when the directory is genuinely complete. The completeness check covers `spec.md`, `comments.md`, `remote.md`, `state.md`, and frontmatter fields `github_issue`/`remote_url`. A behavioral/structural test asserts that a pre-existing directory lacking `spec.md` results in `spec.md` being created (not a HALT), closing the loop that currently causes the spec-creation revise pipeline to loop.

## Impact

- **Risk 1:** Materializing files could overwrite divergent local content. *Mitigation:* only create files that are missing; never overwrite existing files.
- **Risk 2:** The completeness check may be too strict/loose on which files are required. *Mitigation:* align the required-file set with the existing `import-remote` Exit Criteria and Live Verification table.
- **Risk 3:** Behavioral test may be flaky under model variance. *Mitigation:* use a structural assertion (file existence after run) alongside the behavioral assertion.
- **Dependencies:** `issue-operations-sync` skill deck; local `.issues/` worktree tooling.
- **Call to action:** Approve this spec so the fix can be implemented and the #2117-class incomplete-mirror failure is eliminated.

🤖 OpenCode (ollama-cloud/deepseek-v4-flash) created
