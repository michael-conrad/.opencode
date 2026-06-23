# Task: completion

Idempotent completion subtask for verification-before-completion. Ensures mandatory steps run regardless of where the workflow halted.

## State Check Phase

- [ ] 1. **Verification result determined:** Was an evidence-based verification completed?

## Skill-Specific Completion

- [ ] 1. **Record verification result** in `./tmp/{issue-N}/artifacts/` if not already recorded

## Shared Completion Delegation

Reference `.opencode/skills/completion-core/completion-core.md` for reporting:

- [ ] 1. Report executive summary in chat (always runs)
- [ ] 2. Action URL (issue URL) if applicable (ALWAYS last)

## Report Phase

### Step N: EXTRACT URL FROM API RESPONSE

- [ ] 1. The Issue URL MUST be copied verbatim from the `issue-operations -> update-issue (platform_issue_write` API response's `html_url` field. <!-- Routes through issue-operations per SPEC #683 -->
- [ ] 2. Do NOT retype, reconstruct, or assemble the URL from known values (org, repo, number).
- [ ] 3. Paste the URL exactly as returned. If the API response is `{ "html_url": "{browser_url}/Org/Repo/issues/42" }`, the output URL is `{browser_url}/Org/Repo/issues/42` — character for character.
- [ ] 4. Verification checkpoint: Compare the pasted URL character-by-character against the `html_url` field in the API response before sending.

Generate executive summary in chat:

```
**Summary:**

<Verification result: pass/fail with criteria count>

**Outcome:** <What stakeholders know — task is verified/not verified>

Issue URL: <html_url from issue-operations -> update-issue API response — NEVER construct from template> <!-- Routes through issue-operations per SPEC #683 -->
```

URL is ALWAYS last per `000-critical-rules.md`.

## Byline Verification Checkpoint (MANDATORY)

**Before generating completion summary, verify all AI-authored content posted during this session includes bylines.**

This checkpoint catches direct API calls that bypassed the `issue-operations` skill's byline check.

**Verification actions:**

| Content | Verification Action | Tool Call |
|---------|-------------------|-----------|
| Issue body/comment created via `issue-operations -> update-issue` on created issue | <!-- Routes through issue-operations per SPEC #683 -->
| PR created via `github_create_pull_request` | Review PR body for byline | `github_pull_request_read(method="get")` on PR |
| Issue comment via `issue-operations -> comment (platform_add_issue_comment` | Review comment for byline | Review issue comments | <!-- Routes through issue-operations per SPEC #683 -->

**Failure:** If any AI-authored content is missing a byline → `STRUCTURE-VIOLATION`. Add missing byline via `issue-operations -> update-issue` (only if `len(new_body) >= 0.8 * len(original_body)` per body-preservation rule) or append a follow-up comment with the proper byline. <!-- Routes through issue-operations per SPEC #683 -->

**Per `000-critical-rules.md` §Critical Violation: Posting AI-Authored Content Without Byline Verification.**

## Live Verification: Completion Claims (MANDATORY)

**Before claiming verification complete, verify claims against actual evidence.**

| Claim | Verification Action | Tool Call | Problem Class |
|-------|-------------------|-----------|---------------|
| "Verification completed" | Verify evidence artifacts exist | `glob(pattern="./tmp/{issue-N}/artifacts/verification-*")` | VERIFICATION-GAP |
| "All criteria passed" | Verify each criterion has PASS evidence | Read collection output | MISSING-ELEMENT |

**Evidence artifact:** File existence check or collection output confirming verification was performed.

### Finding Classification

| Finding | Problem Class | Classification | Action |
|--------|---------------|----------------|--------|
| No verification report found | VERIFICATION-GAP | conditional | Re-run verification |
| Criterion lacks evidence | MISSING-ELEMENT | conditional | Collect evidence for missing criterion |

## Pipeline Signal

```
CONTINUE: finishing-a-development-branch --task checklist
HALT
```