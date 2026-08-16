---
name: gh-cli
description: "GitHub CLI (gh) operations for repository management, issue/PR workflows, releases, codespaces, Actions, secrets, search, organization management, gists, labels, projects, aliases, extensions, SSH/GPG keys, and API requests. Each operation includes authentication verification, command construction, and output inspection. gh CLI operations without authentication checks fail silently — auth verification is REQUIRED before any gh command."
license: MIT
provenance: AI-generated
---

# Skill: gh-cli

## Overview

GitHub CLI (gh) operations for repository management, issue/PR workflows, releases, codespaces, Actions, secrets, search, organization management, gists, labels, projects, aliases, extensions, SSH/GPG keys, and API requests. Each operation includes authentication verification, command construction, and output inspection.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Workflows

### Authenticate with GitHub CLI
When the agent needs to verify or establish gh CLI authentication before running gh commands.

1. **Check authentication** — verify `gh auth status` succeeds, prompt login if missing
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/authenticate.md](.opencode/skills/gh-cli/tasks/authenticate.md). issue_number: ", issue_number, ", project_root: ", project_root))
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Create a pull request
When the agent needs to create a PR with title, body, labels, and reviewers.

1. **Sync repository** — `gh repo sync` to update local state
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/create-pr.md](.opencode/skills/gh-cli/tasks/create-pr.md). issue_number: ", issue_number, ", project_root: ", project_root))
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Create PR** — `gh pr create` with title/body/labels/reviewers, then `gh pr view` to verify
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/create-pr.md](.opencode/skills/gh-cli/tasks/create-pr.md). issue_number: ", issue_number, ", project_root: ", project_root, ", step1_artifact_path: ", step1_artifact_path))
   - Context: `{issue_number, project_root, step1_artifact_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Triage issues
When the agent needs to list, view, edit, comment on, or close GitHub issues.

1. **List and view issues** — `gh issue list` with filters, `gh issue view` for details
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/triage-issues.md](.opencode/skills/gh-cli/tasks/triage-issues.md). issue_number: ", issue_number, ", project_root: ", project_root))
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Edit and close issues** — `gh issue edit` for labels/assignees, `gh issue comment`, `gh issue close`
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/triage-issues.md](.opencode/skills/gh-cli/tasks/triage-issues.md). issue_number: ", issue_number, ", project_root: ", project_root, ", step1_artifact_path: ", step1_artifact_path))
   - Context: `{issue_number, project_root, step1_artifact_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Review a pull request
When the agent needs to list, view diff, checkout, and review PRs.

1. **List and view PRs** — `gh pr list` with filters, `gh pr view --diff` for changes
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/review-pr.md](.opencode/skills/gh-cli/tasks/review-pr.md). issue_number: ", issue_number, ", project_root: ", project_root))
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Checkout and review** — `gh pr checkout`, `gh pr review` with approve/comment/request-changes
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/review-pr.md](.opencode/skills/gh-cli/tasks/review-pr.md). issue_number: ", issue_number, ", project_root: ", project_root, ", step1_artifact_path: ", step1_artifact_path))
   - Context: `{issue_number, project_root, step1_artifact_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Do a release
When the agent needs to create a git tag, create a GitHub Release, upload assets, and verify.

1. **Create tag and release** — `git tag -a`, `gh release create` with title/notes/assets
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/do-release.md](.opencode/skills/gh-cli/tasks/do-release.md). issue_number: ", issue_number, ", project_root: ", project_root))
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Upload and verify** — `gh release upload` assets, `gh release view --web` to confirm
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/do-release.md](.opencode/skills/gh-cli/tasks/do-release.md). issue_number: ", issue_number, ", project_root: ", project_root, ", step1_artifact_path: ", step1_artifact_path))
   - Context: `{issue_number, project_root, step1_artifact_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Search and investigate
When the agent needs to search repositories, issues, PRs, or code on GitHub.

1. **Search** — `gh search repos/issues/prs/code` with filters
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/search-investigate.md](.opencode/skills/gh-cli/tasks/search-investigate.md). issue_number: ", issue_number, ", project_root: ", project_root))
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Browse** — `gh browse` to open results in browser
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/search-investigate.md](.opencode/skills/gh-cli/tasks/search-investigate.md). issue_number: ", issue_number, ", project_root: ", project_root, ", step1_artifact_path: ", step1_artifact_path))
   - Context: `{issue_number, project_root, step1_artifact_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Manage repository
When the agent needs to create, fork, or edit repository settings.

1. **Create or fork** — `gh repo create/fork` with visibility and settings
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/manage-repo.md](.opencode/skills/gh-cli/tasks/manage-repo.md). issue_number: ", issue_number, ", project_root: ", project_root))
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Edit settings** — `gh repo edit` for topics, visibility, description, default branch
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/manage-repo.md](.opencode/skills/gh-cli/tasks/manage-repo.md). issue_number: ", issue_number, ", project_root: ", project_root, ", step1_artifact_path: ", step1_artifact_path))
   - Context: `{issue_number, project_root, step1_artifact_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Run CI/CD
When the agent needs to list, view, rerun, or cancel GitHub Actions workflow runs.

1. **List and view runs** — `gh run list` with filters, `gh run view` for details
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/run-ci-cd.md](.opencode/skills/gh-cli/tasks/run-ci-cd.md). issue_number: ", issue_number, ", project_root: ", project_root))
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Rerun or cancel** — `gh run rerun` failed jobs, `gh run cancel` stuck runs
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/run-ci-cd.md](.opencode/skills/gh-cli/tasks/run-ci-cd.md). issue_number: ", issue_number, ", project_root: ", project_root, ", step1_artifact_path: ", step1_artifact_path))
   - Context: `{issue_number, project_root, step1_artifact_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Manage secrets and variables
When the agent needs to set, list, or delete GitHub Actions secrets and variables.

1. **Manage secrets** — `gh secret list/set/delete` for repos, orgs, environments
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/manage-secrets.md](.opencode/skills/gh-cli/tasks/manage-secrets.md). issue_number: ", issue_number, ", project_root: ", project_root))
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Manage variables** — `gh variable list/set/delete` for repos, environments
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/manage-secrets.md](.opencode/skills/gh-cli/tasks/manage-secrets.md). issue_number: ", issue_number, ", project_root: ", project_root, ", step1_artifact_path: ", step1_artifact_path))
   - Context: `{issue_number, project_root, step1_artifact_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Manage codespaces
When the agent needs to create, list, connect to, or delete GitHub Codespaces.

1. **List and create** — `gh codespace list`, `gh codespace create` with branch/machine
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/manage-codespaces.md](.opencode/skills/gh-cli/tasks/manage-codespaces.md). issue_number: ", issue_number, ", project_root: ", project_root))
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Connect and delete** — `gh codespace ssh/code`, `gh codespace delete`
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/manage-codespaces.md](.opencode/skills/gh-cli/tasks/manage-codespaces.md). issue_number: ", issue_number, ", project_root: ", project_root, ", step1_artifact_path: ", step1_artifact_path))
   - Context: `{issue_number, project_root, step1_artifact_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Manage organization
When the agent needs to view org details, list members, or manage org repos.

1. **View org and list members** — `gh org view`, `gh org list-members`
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/manage-org.md](.opencode/skills/gh-cli/tasks/manage-org.md). issue_number: ", issue_number, ", project_root: ", project_root))
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Manage org repos** — `gh repo list/create` for org
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/manage-org.md](.opencode/skills/gh-cli/tasks/manage-org.md). issue_number: ", issue_number, ", project_root: ", project_root, ", step1_artifact_path: ", step1_artifact_path))
   - Context: `{issue_number, project_root, step1_artifact_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Manage gists
When the agent needs to create, list, view, edit, or delete gists.

1. **Create or list gists** — `gh gist create/list` with visibility
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/manage-gists.md](.opencode/skills/gh-cli/tasks/manage-gists.md). issue_number: ", issue_number, ", project_root: ", project_root))
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **View, edit, or delete** — `gh gist view/edit/delete`
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/manage-gists.md](.opencode/skills/gh-cli/tasks/manage-gists.md). issue_number: ", issue_number, ", project_root: ", project_root, ", step1_artifact_path: ", step1_artifact_path))
   - Context: `{issue_number, project_root, step1_artifact_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Manage SSH and GPG keys
When the agent needs to list, add, or delete SSH and GPG keys.

1. **Manage SSH keys** — `gh ssh-key list/add/delete`
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/ssh-gpg-keys.md](.opencode/skills/gh-cli/tasks/ssh-gpg-keys.md). issue_number: ", issue_number, ", project_root: ", project_root))
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Manage GPG keys** — `gh gpg-key list/add/delete`
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/ssh-gpg-keys.md](.opencode/skills/gh-cli/tasks/ssh-gpg-keys.md). issue_number: ", issue_number, ", project_root: ", project_root, ", step1_artifact_path: ", step1_artifact_path))
   - Context: `{issue_number, project_root, step1_artifact_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Manage labels
When the agent needs to list, create, edit, or delete repository labels.

1. **List and create labels** — `gh label list`, `gh label create` with color/description
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/label-management.md](.opencode/skills/gh-cli/tasks/label-management.md). issue_number: ", issue_number, ", project_root: ", project_root))
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Edit or delete labels** — `gh label edit`, `gh label delete`
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/label-management.md](.opencode/skills/gh-cli/tasks/label-management.md). issue_number: ", issue_number, ", project_root: ", project_root, ", step1_artifact_path: ", step1_artifact_path))
   - Context: `{issue_number, project_root, step1_artifact_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Manage projects
When the agent needs to list or view GitHub Projects (beta).

1. **List and view projects** — `gh project list`, `gh project view` with items
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/project-management.md](.opencode/skills/gh-cli/tasks/project-management.md). issue_number: ", issue_number, ", project_root: ", project_root))
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Check status
When the agent needs to check overall GitHub status for issues, PRs, and notifications.

1. **Check status** — `gh status` with optional repo/limit filters
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/status.md](.opencode/skills/gh-cli/tasks/status.md). issue_number: ", issue_number, ", project_root: ", project_root))
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Manage aliases and extensions
When the agent needs to set, list, or delete gh CLI aliases and manage extensions.

1. **Manage aliases** — `gh alias set/list/delete`
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/aliases-extensions.md](.opencode/skills/gh-cli/tasks/aliases-extensions.md). issue_number: ", issue_number, ", project_root: ", project_root))
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

2. **Manage extensions** — `gh extension install/list/remove`
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/aliases-extensions.md](.opencode/skills/gh-cli/tasks/aliases-extensions.md). issue_number: ", issue_number, ", project_root: ", project_root, ", step1_artifact_path: ", step1_artifact_path))
   - Context: `{issue_number, project_root, step1_artifact_path}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Make API requests
When the agent needs to make authenticated REST API requests to GitHub.

1. **Make API request** — `gh api` with method, endpoint, and parameters
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/api-requests.md](.opencode/skills/gh-cli/tasks/api-requests.md). issue_number: ", issue_number, ", project_root: ", project_root))
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Generate shell completion
When the agent needs to generate shell completion scripts for gh CLI.

1. **Generate completion** — `gh completion -s <shell>` for bash/zsh/fish/powershell
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/completion.md](.opencode/skills/gh-cli/tasks/completion.md). issue_number: ", issue_number, ", project_root: ", project_root))
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

### Common end-to-end workflows
When the agent needs to follow a complete multi-step workflow combining multiple gh operations.

1. **Execute workflow** — follow one of 3 end-to-end workflow examples (PR creation, issue triage, release management)
   - Prompt: task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [gh-cli/tasks/common-workflows.md](.opencode/skills/gh-cli/tasks/common-workflows.md). issue_number: ", issue_number, ", project_root: ", project_root))
   - Context: `{issue_number, project_root}`
   - Returns: `{status, finding_summary, artifact_path, blocker_reason}`

## Cross-References

Skills: `git-workflow` (branch operations, commits, pushes), `issue-operations` (issue CRUD via API), `release-promoter` (tag/release operations). Guidelines: `000-critical-rules.md` (critical-rules-merge: `gh pr merge` prohibition), `065-verification-honesty.md` (live-source verification), `075-docs-verification.md` (verify `gh <command> --help` before using flags).

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
