# Task: completion

Idempotent completion subtask for git-workflow. Ensures mandatory steps run regardless of where the workflow halted.

## State Check Phase

- [ ] 0. **Merge gate:** Check that `github_merge_pull_request` has NOT been called during this session. If it has, HALT immediately — agents MUST NOT merge PRs. Only the developer can merge.
   ```bash
   # Check session history for merge API calls
   # If merge was called: HALT with "CRITICAL VIOLATION — Agent attempted to merge PR"
   ```
- [ ] 1. **Git status:** Check for uncommitted changes
   ```bash
   git status --porcelain
   ```
- [ ] 2. **Push status:** Check for unpushed commits
   ```bash
   git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null
   ```
- [ ] 3. **Lifecycle event:** Check if lifecycle event already appended to `{project_root}/tmp/{issue-N}/lifecycle.yaml` (if applicable)

## Skill-Specific Completion

- [ ] 1. **If review-prep not yet run:** Delegate to `git-workflow --task review-prep`
   - This handles: commit, push, compare URL generation
   - Check if compare URL was already generated (look for URL in recent chat output)
   - If missing: invoke review-prep
- [ ] 2. **If on cleanup path:** Verify PR merge via GitHub API before closing issues
- [ ] 3. **Ticket status reconciliation:** After the completion summary is produced, BEFORE reporting completion, check the ticket's current status and update it to reflect the PR-created state (`for_pr`/`approved-for-pr`) if an update is warranted. **The read is a mandatory precondition for any update. You MUST perform the `local-issues read` first and record the current status and labels from its output before any decision — you may NOT assume, recall, or infer the ticket's status from earlier context, memory, or conversation. If you have not just performed a successful `local-issues read` in this step, you MUST NOT perform an update, and you MUST NOT report completion.**

   > **MANDATORY — do NOT skip.** This step runs via the `local-issues` CLI (`.opencode/tools/local-issues`) against the local `.issues/` worktree. It does NOT require a git remote, GitHub credentials, or a remote issue tracker. A local-only repo, a test environment, or a missing/absent remote is NOT a valid reason to skip the status read and update. If the ticket is in a pre-PR state and the workflow is complete, you MUST perform BOTH the read and the update. Skipping this step makes the completion result INVALID (see Completion Dependency Chain).

   - [ ] 1. **Read current ticket status — MUST run first** — Execute the `local-issues` read command now and base the update decision ONLY on its output: `./.opencode/tools/local-issues read --number <repo>#<N>` (the `--number` flag is required; the qualified `<repo>#<N>` form is accepted for reads, and a bare `--number <N>` also works when the repo qualifier is unknown). Capture and record the current `status` field and the labels array from the actual command output.
   - [ ] 2. **Evaluate whether an update is warranted** — Using ONLY the status and labels read in step 1, an update is warranted when the ticket is still in a pre-PR state: `status: open` combined with the absence of a PR-created marker (e.g., no `approved-for-pr`, `approved-for-pr-only`, or equivalent PR-created label in the labels array).
   - [ ] 3. **Update only when warranted** — When step 2 determined an update is warranted, transition the ticket to the PR-created state: apply the PR-created label (e.g., `approved-for-pr`) via the `local-issues` CLI: `./.opencode/tools/local-issues update --number <repo>#<N> --labels approved-for-pr` (the `--number` flag is required and mutations MUST use the qualified `{repo}#{N}` form). Confirm the update succeeded (exit 0, `updated: true`).
   - [ ] 4. **Skip when already correct** — When the read in step 1 shows the ticket already carries the PR-created marker, do NOT update the ticket status. **An already-present PR-created label is a skip condition — do NOT re-apply it.** When skipping, record the reason in the result contract, citing the label observed in the step 1 read.

## Shared Completion Delegation

Reference `.opencode/skills/completion-core/completion-core.md` for steps 3-6:

- [ ] 1. Push branch (with idempotency check)
- [ ] 2. Generate compare URL ($DEFAULT_BRANCH...branch)
- [ ] 3. Append completion event to lifecycle manifest at `{project_root}/tmp/{issue-N}/lifecycle.yaml`
- [ ] 4. Report executive summary in chat (always runs)

## Report Phase

Generate executive summary in chat:

```
**Summary:**

<Git operation result and its impact>

**Outcome:** <What changed for stakeholders>

<URL if applicable, ALWAYS LAST>
```

URL is ALWAYS last per `000-critical-rules.md`.

🤖 <AgentName> (<ModelId>) <status>

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Merge gate → INVALID if skipped
- [ ] 1. Git status → INVALID if skipped
- [ ] 2. Push status → INVALID if skipped
- [ ] 3. Ticket status reconciliation → INVALID if skipped
- [ ] 4. Push branch → INVALID if skipped
- [ ] 5. Generate compare URL → INVALID if skipped
- [ ] 6. Append completion event → INVALID if skipped
- [ ] 7. Report executive summary → INVALID if skipped

## Result Contract

```yaml
status: DONE | FAIL | BLOCKED
finding_summary: "<1-2 sentences of routing-significant output>"
status_checked: false | true
status_updated: false | true
ticket_status: "<current ticket status or label state>"
```

## Pipeline Signal

```
HALT
```
