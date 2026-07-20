# Task: revise-remote-body

## Purpose

Update the remote issue body with correct folder links after the local spec workflow completes. Returns SKIPPED if platform is local.

## Entry Criteria

- Spec body exists at `{project_root}/{path}/.issues/{N}/spec.md`
- Session-init values are available for URL construction
- Remote issue exists (for remote platforms)

## Procedure

- [ ] 1. **Check platform** — Read `github.platform` from session-init. If `local`, return SKIPPED.
- [ ] 2. **Read spec body** — Read `{project_root}/{path}/.issues/{N}/spec.md` to extract the exec summary content.
- [ ] 3. **Construct folder URL** — Build the spec folder URL from session-init values: `{html_url}/{owner}/{repo}/tree/issues-data/{N}/`
- [ ] 4. **Update remote issue body** — Prepend the spec reference blockquote to the existing issue body via the platform API. The blockquote format:
     ```
     > **Full spec and artifacts: [`{path}/.issues/{N}/`]({html_url}/{owner}/{repo}/tree/issues-data/{path}/.issues/{N}/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
     >
     > **Local artifacts:** `{path}/.issues/{N}/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings
     ```
- [ ] 5. **Verify** — Confirm the remote body was updated with correct links.

## Result Contract

| Field | Value |
|-------|-------|
| `status` | `DONE` \| `SKIPPED` |
| `finding_summary` | `"Remote body updated"` \| `"No remote API — skipped"` |
| `artifact_path` | `null` |
| `blocker_reason` | `null` |
