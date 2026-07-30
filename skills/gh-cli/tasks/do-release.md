<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Creates an annotated git tag, publishes a GitHub Release with title, notes, and assets, uploads additional assets, and opens the release in the browser for verification.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gh auth status` exits 0 (authenticated session)
- The target repository (`owner/repo`) is known
- The release tag (e.g., `v1.2.3`), title, and notes body are provided in the task context
- Any asset file paths to upload exist on disk and are readable
- `gh` CLI must be installed and on PATH

## Procedure

1. Create an annotated git tag on the current commit:
   - `git tag -a <tag> -m "<release title>"`
   - Verify the tag was created: `git tag --list '<tag>'` — confirm the tag appears in the output.
   - If the tag already exists locally, return BLOCKED with `reason: "Tag <tag> already exists locally"`.
2. Push the tag to the remote:
   - `git push origin <tag>`
   - If the push fails (tag exists on remote, permission denied), return BLOCKED with the failure reason.
3. Create the GitHub Release using `gh release create`:
   - `gh release create <tag> --repo <owner/repo> --title "<title>" --notes "<notes>"`
   - If there are asset files to include at creation time, append them: `gh release create <tag> --repo <owner/repo> --title "<title>" --notes "<notes>" <asset1> <asset2>`
   - If the notes body is long, write it to a temp file and use `--notes-file <path>`.
   - Use `--draft` to create a draft release, `--prerelease` to mark as pre-release, `--latest` to mark as latest.
   - Capture the release URL from the command output.
4. Upload additional assets (if any remain after creation):
   - `gh release upload <tag> --repo <owner/repo> <asset1> <asset2>`
   - Verify each asset was uploaded: `gh release view <tag> --repo <owner/repo> --json assets` and confirm the asset names appear in the list.
5. Open the release in the browser for visual verification:
   - `gh release view <tag> --repo <owner/repo> --web`
   - Note: this opens the browser; the agent captures the URL from the output for the artifact.
6. Write the release summary (tag, title, URL, assets, draft/prerelease/latest flags) to the artifact path.

## Exit Criteria

- The annotated tag has been created and pushed to the remote
- The GitHub Release has been created with the correct title, notes, and assets
- All uploaded assets have been verified via `gh release view`
- The release URL has been captured
- The release summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<tag, title, release URL, asset count, flags>"
artifact_path: "<path to release summary>"
blocker_reason: "<reason if BLOCKED>"
```
