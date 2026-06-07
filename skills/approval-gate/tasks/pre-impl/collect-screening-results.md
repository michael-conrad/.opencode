Sub-Agent Task Context Audit

| Scope of Context | Exclusions | Pre-Analysis Contract | Includes Inline Work? |
|---|---|---|---|
| `issue_number`, `work_peers`, `authorization_scope`, `halt_at`, `pr_strategy`, `github.owner`, `github.repo`, `dev.name`, `dev.email`, `worktree.path` | Issue bodies (never read into orchestrator context), orchestrator reasoning, prior screening results | N/A — screen-issue sub-agents receive full task context directly | NO |