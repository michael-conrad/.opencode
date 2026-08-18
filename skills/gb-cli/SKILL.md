---
name: gb-cli
description: "GitBucket CLI (gb) operations for authentication, issue and pull request workflows, labels, milestones, repository management, search and investigation, API passthrough, shell completion, and common end-to-end workflows. Each operation includes authentication verification, command construction, and output inspection. gb CLI operations without authentication checks fail silently — auth verification is REQUIRED before any gb command."
license: MIT
compatibility: opencode
provenance: AI-generated
---

# Skill: gb-cli

## Overview

GitBucket CLI (gb) operations for authentication, issue and PR workflows, labels, milestones, repository management, search and investigation, API requests, shell completion, and common end-to-end workflows. Each operation includes authentication verification, command construction, and output inspection.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Workflows

### Authenticate with GitBucket CLI
When the agent needs to verify or establish gb CLI authentication against a GitBucket host before running gb commands.

1. **Check authentication** — verify `gb auth status` succeeds, prompt login if missing, verify version >= 0.6.1
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [authenticate gb CLI](.opencode/skills/gb-cli/tasks/authenticate.md). issue_number: ", issue_number, ", project_root: ", project_root))`
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Create a pull request
When the agent needs to create a PR with title, body, head/base branches, and verify it was created.

1. **Create PR** — `gb pr create` with title/body/head/base, then `gb pr view` to verify (NOT merge — human-only per critical-rules-merge)
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [create gb pull request](.opencode/skills/gb-cli/tasks/create-pr.md). issue_number: ", issue_number, ", project_root: ", project_root))`
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Triage issues
When the agent needs to list, view, edit, comment on, or close GitBucket issues.

1. **List and view issues** — `gb issue list` with filters, `gb issue view` for details
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [triage gb issues](.opencode/skills/gb-cli/tasks/triage-issues.md). issue_number: ", issue_number, ", project_root: ", project_root))`
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Edit and close issues** — `gb issue edit` for labels/assignees, `gb issue comment`, `gb issue close`
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [triage gb issues](.opencode/skills/gb-cli/tasks/triage-issues.md). issue_number: ", issue_number, ", project_root: ", project_root, ", step1_artifact_path: ", step1_artifact_path))`
   - Context: `{issue_number, project_root, step1_artifact_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Review a pull request
When the agent needs to list, view diff, checkout, and comment on GitBucket PRs.

1. **List and view PRs** — `gb pr list` with filters, `gb pr view` / `gb pr diff` for changes
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [review gb pull request](.opencode/skills/gb-cli/tasks/review-pr.md). issue_number: ", issue_number, ", project_root: ", project_root))`
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Checkout and comment** — `gb pr checkout`, `gb pr comment` for review feedback (no formal review API — comment-based)
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [review gb pull request](.opencode/skills/gb-cli/tasks/review-pr.md). issue_number: ", issue_number, ", project_root: ", project_root, ", step1_artifact_path: ", step1_artifact_path))`
   - Context: `{issue_number, project_root, step1_artifact_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Manage repository
When the agent needs to create, fork, view, list, clone, or delete a GitBucket repository.

1. **Create, fork, or delete** — `gb repo create/fork/delete` with confirmation for delete
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [manage gb repositories](.opencode/skills/gb-cli/tasks/manage-repo.md). issue_number: ", issue_number, ", project_root: ", project_root))`
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **View and list** — `gb repo view` / `gb repo list` / `gb repo clone`
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [manage gb repositories](.opencode/skills/gb-cli/tasks/manage-repo.md). issue_number: ", issue_number, ", project_root: ", project_root, ", step1_artifact_path: ", step1_artifact_path))`
   - Context: `{issue_number, project_root, step1_artifact_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Manage labels
When the agent needs to list, create, edit, or delete GitBucket repository labels.

1. **List and create labels** — `gb label list`, `gb label create` with color
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [manage gb labels](.opencode/skills/gb-cli/tasks/manage-labels.md). issue_number: ", issue_number, ", project_root: ", project_root))`
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Edit or delete labels** — `gb label edit`, `gb label delete --yes` (post-creation label mutation documented limitation)
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [manage gb labels](.opencode/skills/gb-cli/tasks/manage-labels.md). issue_number: ", issue_number, ", project_root: ", project_root, ", step1_artifact_path: ", step1_artifact_path))`
   - Context: `{issue_number, project_root, step1_artifact_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Manage milestones
When the agent needs to list, view, create, edit, or delete GitBucket milestones (gb-specific workflow, no gh equivalent).

1. **List and create milestones** — `gb milestone list`, `gb milestone create`
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [manage gb milestones](.opencode/skills/gb-cli/tasks/manage-milestones.md). issue_number: ", issue_number, ", project_root: ", project_root))`
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Edit or delete milestones** — `gb milestone edit`, `gb milestone delete`
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [manage gb milestones](.opencode/skills/gb-cli/tasks/manage-milestones.md). issue_number: ", issue_number, ", project_root: ", project_root, ", step1_artifact_path: ", step1_artifact_path))`
   - Context: `{issue_number, project_root, step1_artifact_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Search and investigate
When the agent needs to search repositories, issues, or PRs on a GitBucket instance (no native search API — iterative listing + client-side filter).

1. **List and filter** — `gb issue list` / `gb pr list` / `gb repo list` with client-side filtering
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [search and investigate in gb](.opencode/skills/gb-cli/tasks/search-investigate.md). issue_number: ", issue_number, ", project_root: ", project_root))`
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **API and browse** — `gb api` passthrough to available endpoints, `gb browse` to open in browser
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [search and investigate in gb](.opencode/skills/gb-cli/tasks/search-investigate.md). issue_number: ", issue_number, ", project_root: ", project_root, ", step1_artifact_path: ", step1_artifact_path))`
   - Context: `{issue_number, project_root, step1_artifact_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Make API requests
When the agent needs to make authenticated REST API requests to a GitBucket instance.

1. **Make API request** — `gb api <endpoint>` with method and input
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [make gb API requests](.opencode/skills/gb-cli/tasks/api-requests.md). issue_number: ", issue_number, ", project_root: ", project_root))`
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Generate shell completion
When the agent needs to generate shell completion scripts for the gb CLI.

1. **Generate completion** — `gb completion <shell>` for bash/zsh/fish/powershell
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [generate gb shell completion](.opencode/skills/gb-cli/tasks/completion.md). issue_number: ", issue_number, ", project_root: ", project_root))`
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Common end-to-end workflows
When the agent needs to follow a complete multi-step workflow combining multiple gb operations.

1. **Execute workflow** — follow end-to-end workflow examples (PR creation, issue triage, milestone management)
   - Prompt: `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [reference gb end-to-end workflows](.opencode/skills/gb-cli/tasks/common-workflows.md). issue_number: ", issue_number, ", project_root: ", project_root))`
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

## Cross-References

Skills: `git-workflow` (branch operations, commits, pushes), `issue-operations` (issue CRUD via API), `gitbucket-api` (platform-specific routing, owner/repo resolution). Guidelines: `000-critical-rules.md` (critical-rules-merge: `gb pr merge` prohibition), `065-verification-honesty.md` (live-source verification), `075-docs-verification.md` (verify `gb <command> --help` before using flags).

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
