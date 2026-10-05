# Task: push-artifacts

## Purpose

Pushes the `.issues/{N}/` spec artifacts directory to the `issues-data` branch via the platform sub-skill, resolving the target platform from `github.platform` and returning the resulting `artifact_url` for the `spec-creation/tasks/reconcile-push.md` consumer.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- Issue number (`{issue_number}`) provided in context
- Project root (`{project_root}`) provided in context
- `github.platform` value available from session context

If any entry criterion is not met, return BLOCKED with the unmet criterion as the reason.

## Procedure

- [ ] 1. Resolve the target platform from `github.platform`.

- [ ] 2. Route to the platform sub-skill implementation. The dispatcher resolves platform selection — no deliberation about which API to use:

   | `github.platform` | Route to |
   |---|---|
   | `local` | `issue-operations/platforms/local/tasks/push-artifacts.md` |
   | `github` / `gitbucket` | Check the corresponding platform sub-skill for a `push-artifacts` implementation |

- [ ] 3. **Local platform:** Dispatch to `issue-operations/platforms/local/tasks/push-artifacts.md` with `{issue_number}`. That card verifies local artifacts, runs `local-issues sync`, and constructs the `artifact_url` from the repository's remote URL.

- [ ] 4. **Other platforms:** If the platform sub-skill provides a `push-artifacts` implementation, route to it and capture its returned `artifact_url`. If no such implementation exists for the platform, return BLOCKED with the unsupported platform as the reason — do not fall back to inline platform API calls.

- [ ] 5. Capture the `artifact_url` returned by the platform implementation. This is the spec artifacts URL for the `issues-data` branch (`<html_url>/tree/issues-data/<N>/`).

- [ ] 6. Feed the `artifact_url` to the downstream consumer: `spec-creation/tasks/reconcile-push.md` runs after this task and uses the returned `artifact_url` to reconcile the Spec Reference Blockquote in the remote issue body.

- [ ] 7. Write the push evidence and captured `artifact_url` to the evidence artifact.
- [ ] 8. Return the result contract.

## Exit Criteria

- Spec artifacts pushed to the `issues-data` branch via the platform sub-skill
- `artifact_url` captured and returned
- No direct `git add`/`git commit`/`git push` used at the core level — commit+push delegated to the platform implementation
- Result contract returned

If any exit criterion is not met, return BLOCKED with the unmet criterion as the reason.

## Result Contract

```yaml
status: DONE | BLOCKED
artifact_url: "<html_url>/tree/issues-data/<N>/"
finding_summary: "<1-3 sentences of routing-significant output>"
artifact_path: "<path to the push evidence on disk>"
blocker_reason: "<reason if BLOCKED>"
```

## Context Required

- Related task: `issue-operations/platforms/local/tasks/push-artifacts.md` (local platform implementation — EXISTS)
- Related task: `spec-creation/tasks/reconcile-push.md` (downstream consumer of `artifact_url`)
- Related skill: `issue-operations` (dispatcher that also routes `push-artifacts` to the platform card)
- Session values: `github.platform`, `github.owner`, `github.repo`
