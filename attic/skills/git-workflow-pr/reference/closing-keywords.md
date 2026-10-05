# Task: closing-keywords

## Purpose

Centralized closing-keyword formatter for PR bodies. Ensures all PR bodies use only valid GitHub closing keywords with correct cross-repo formatting.

## Valid Keywords

| Keyword | Auto-Closes | Use Case |
|---------|-------------|----------|
| `Fixes` | Yes | Bug fixes, single-issue specs |
| `Closes` | Yes | Feature completion, issue closure |
| `Resolves` | Yes | Complex issues, multi-faceted changes |
| `Implements` | No | Multi-task plans, specs with sub-issues, pair-mode PRs |

## Format Rules

### Same-Repo References

When the issue is in the same repository as the PR:

```
Fixes #<issue-number>
Closes #<issue-number>
Resolves #<issue-number>
Implements #<issue-number>
```

### Cross-Repo References

When the issue is in a different repository than the PR (e.g., submodule issue referenced from parent repo PR):

```
Fixes <owner>/<repo>#<issue-number>
Closes <owner>/<repo>#<issue-number>
Resolves <owner>/<repo>#<issue-number>
Implements <owner>/<repo>#<issue-number>
```

### Bare #N Prohibition

🚫 **NEVER use bare `#N` without a keyword.** GitHub does not recognize bare `#N` as a closing keyword. Always prefix with `Fixes`, `Closes`, `Resolves`, or `Implements`.

🚫 **NEVER use bare `#N` for cross-repo references.** Cross-repo references MUST include `owner/repo#N` format.

## Usage

When generating PR body closing keyword lines:

1. Determine if the referenced issue is in the same repo or a different repo
2. Select the appropriate keyword from the Valid Keywords table
3. Format per the Format Rules above
4. Include one line per referenced issue
