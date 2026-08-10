# Task: reconcile-push — Post-push reconciliation of the Spec Reference Blockquote

## Category

PRODUCTION

## Purpose

Reconcile the Spec Reference Blockquote / artifact URL in the remote issue body against the `artifact_url` returned by the `push-artifacts` task. This task runs after `push-artifacts` has pushed the `.issues/{N}/` spec artifacts to the `issues-data` branch. It does NOT dispatch `push-artifacts` — the orchestrator dispatches `push-artifacts` and this task as separate workflow steps.

## Entry Criteria

- [ ] `issue_number` and `artifact_url` received in dispatch context
- [ ] `push-artifacts` has already run and returned the `artifact_url` for the `.issues/{N}/` spec artifacts
- [ ] The remote issue body exists and contains a Spec Reference Blockquote / artifact URL
- [ ] `project_root` available for path resolution

## Procedure

### Step 1: Read the current Spec Reference Blockquote

Read the remote issue body and locate the Spec Reference Blockquote / artifact URL:

- [ ] 1. Read the remote issue body via the platform's read API
- [ ] 2. Locate the Spec Reference Blockquote — the forward-reference link pointing to the issues-data branch URL
- [ ] 3. Record the current blockquote URL

### Step 2: Reconcile against the returned artifact_url

Compare the blockquote URL against the `artifact_url` returned by `push-artifacts`:

- [ ] 1. Verify the blockquote's `tree/issues-data/{N}/` link resolves to the same URL as the returned `artifact_url`
- [ ] 2. If the blockquote URL differs from the returned `artifact_url`, call `issue-operations → update-issue` to amend the remote issue body with the corrected Spec Reference Blockquote / artifact URL
- [ ] 3. If the blockquote URL matches the returned `artifact_url`, no amendment is needed

### Step 3: Confirm the reconciled URL

- [ ] 1. Confirm the reconciled Spec Reference Blockquote / artifact URL is present and correct in the remote issue body before completing

## Exit Criteria

- [ ] Spec Reference Blockquote / artifact URL in the remote issue body matches the `artifact_url` returned by `push-artifacts`
- [ ] No internal sub-agent dispatch performed — this task executes its steps directly

## Result Contract

```yaml
status: DONE | BLOCKED
issue_url: "https://github.com/{owner}/{repo}/issues/{issue_number}"
finding_summary: "Brief summary of the reconciliation result and any body amendment"
blocker_reason: "If BLOCKED: why the reconciliation could not complete"
```
