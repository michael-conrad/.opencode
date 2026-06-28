# [SPEC] Fix: Platform Sub-Skill Descriptions and Trigger Dispatch Tables

**Parent Issue**: [#1467](https://github.com/michael-conrad/.opencode/issues/1467)
**Labels**: spec, fix
**Created**: 2026-06-27

## Problem Summary

Audit #1384 identified defects in four SKILL.md files across two groups. Three platform sub-skills (gitbucket-api, github-mcp, local) share a common defect pattern: missing Trigger Dispatch Table (NO_TDT), lacking mandatory dispatch language (D4 FAIL), and containing narrative-only sentences that add zero dispatch information (D5). The fourth skill (completion-core) has a description that doesn't map to its actual dispatch triggers (D2), is incomplete against its TDT (D3), and uses borderline D4 language about output quality rather than dispatch requirement.

## Defect Inventory

### Group 1: Platform Sub-Skills (gitbucket-api, github-mcp, local)

| Skill | NO_TDT | D4 FAIL | D5 |
|-------|--------|---------|-----|
| gitbucket-api | YES | YES — no MUST/REQUIRED/mandatory language | YES — narrative-only sentences |
| github-mcp | YES | YES — no MUST/REQUIRED/mandatory language | YES — narrative-only sentences |
| local | YES | YES — no MUST/REQUIRED/mandatory language | YES — narrative-only sentences |

### Group 2: completion-core

| Skill | D2 FAIL | D3 INCOMPLETE | Borderline D4 |
|-------|---------|---------------|---------------|
| completion-core | YES — desc doesn't map to TDT triggers | YES — doesn't cover all TDT dispatch conditions | YES — "MUST be clear and structured" is output quality, not dispatch requirement |

## Current vs Proposed Descriptions

### Group 1: Platform Sub-Skills

| Skill | Current Description | Proposed Description |
|-------|---------------------|---------------------|
| gitbucket-api | "Use when GitBucket platform operations are needed. GitBucket platform sub-skill for issue-operations..." | "Use when GitBucket platform operations are needed for GitHub Issue tracking. Routes to gb CLI command reference for all GitBucket API calls. REQUIRED before any GitBucket operation — always use the platform-aware routing." |
| github-mcp | "Use when GitHub MCP platform operations are needed. GitHub MCP platform sub-skill..." | "Use when GitHub MCP platform operations are needed for GitHub Issue tracking. Thin wrappers around github_* MCP tools with owner/repo verification. REQUIRED before any GitHub API call — always verify routing." |
| local | "Use when local .issues/ directory tracking is needed. Local .issues/ directory platform..." | "Use when local .issues/ directory tracking is needed for GitHub Issues on platforms without remote access. Routes all issue operations to YAML frontmatter and markdown files. REQUIRED before any local issue operation — always use the platform-aware routing." |

### Group 2: completion-core

| Skill | Current Description | Proposed Description |
|-------|---------------------|---------------------|
| completion-core | "Use when completing skill task workflows with push, URL generation, lifecycle event append, and executive summary reporting. Completion signals MUST be clear and structured — always required." | "Use when signaling workflow completion after a sub-agent returns: pushing branches, generating URLs, or appending lifecycle events. Dispatch via skill() + task() — REQUIRED for all audit completions." |

## Required Actions

1. **Add Trigger Dispatch Tables** to the three platform sub-skills (gitbucket-api, github-mcp, local)
2. **Update descriptions** with mandatory dispatch language (REQUIRED/MUST/always/not optional) and non-narrative content for all four skills
3. **Verify** each updated SKILL.md passes D4 and D5 checks

## Scope

- In scope: exactly gitbucket-api, github-mcp, local, completion-core SKILL.md files only
- Out of scope: changes to skill body content or task files not listed above

## Sub-Issues

| # | Title | URL |
|-|-------|-----|
| 1468 | [PLAN] Fix platform sub-skill descriptions and add Trigger Dispatch Tables | https://github.com/michael-conrad/.opencode/issues/1468 |
| 1469 | [PLAN] Fix completion-core description and dispatch mapping | https://github.com/michael-conrad/.opencode/issues/1469 |

Both must be implemented and verified before parent closure.
