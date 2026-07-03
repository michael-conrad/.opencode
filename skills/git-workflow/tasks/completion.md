# Task: completion

Idempotent completion subtask for git-workflow. Ensures mandatory steps run regardless of where the workflow halted.

## State Check Phase

- [ ] 1. **Git status:** Check for uncommitted changes
   ```bash
   git status --porcelain
   ```
- [ ] 2. **Push status:** Check for unpushed commits
   ```bash
   git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null
   ```
- [ ] 3. **Lifecycle event:** Check if lifecycle event already appended to `./tmp/{issue-N}/lifecycle.yaml` (if applicable)

## Skill-Specific Completion

- [ ] 1. **If review-prep not yet run:** Delegate to `git-workflow --task review-prep`
   - This handles: commit, push, compare URL generation
   - Check if compare URL was already generated (look for URL in recent chat output)
   - If missing: invoke review-prep
- [ ] 2. **If on cleanup path:** Verify PR merge via GitHub API before closing issues

## Shared Completion Delegation

Reference `.opencode/skills/completion-core/completion-core.md` for steps 3-6:

- [ ] 1. Push branch (with idempotency check)
- [ ] 2. Generate compare URL (dev...branch)
- [ ] 3. Append completion event to lifecycle manifest at `./tmp/{issue-N}/lifecycle.yaml`
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

## Pipeline Signal

```
HALT
```
