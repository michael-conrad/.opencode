# Task: classify

## Purpose

Intelligently classify files as core (sync bidirectionally) or project-specific (never sync) by reading and understanding file content. This is NOT pattern-based classification — every file must be read and analyzed for its actual content and purpose.

## Operating Protocol

1. Invoked by: `/skill sync-guidelines --task classify`
2. When to use: When discovering files that need classification during a sync operation
3. Exit criteria: All discovered files classified with reasoning documented

## Classification Framework

### Core Indicators (Sync Bidirectionally)

A file is **core** if it:
- Defines generic workflows (git operations, github MCP usage)
- Contains universal engineering standards (code style, testing discipline)
- Describes cross-project concepts (approval gates, spec creation, error handling)
- Has NO project-specific imports, paths, or configuration
- Can be dropped into ANY project and work without modification

Examples of core content:
- `## Operating Protocol` — workflow definition applicable to any project
- `git checkout`, `github_issue_write` — generic operations available everywhere
- `## Critical Requirements` — universal engineering standards
- Generic error handling, data integrity rules that apply across projects
- Skill definitions that describe agent behavior independent of project domain

### Project-Specific Indicators (Never Sync)

A file is **project-specific** if it:
- References project name in imports or code
- Contains project-specific database paths (e.g., specific table names or schemas)
- Has project-specific API endpoints or domain logic
- Contains project-specific configuration values
- Would break if copied to another project without modification

Examples of project-specific content:
- `pubmed_data_3/` — project-specific database path
- `<repo>` substitutions that reference a particular project
- `project_root /` — project-specific path handling
- Domain-specific business logic unique to one project
- Configuration files with project-specific values (ports, URLs, timeouts)

### Uncertain Classification

If classification is unclear after reading the full file content:
- Note the specific uncertainty in the classification
- Provide detailed analysis of what was found
- Classify as ⚠️ Uncertain for human reviewer decision
- NEVER classify uncertain files as core — they default to project-specific

## Classification Process

### Step 1: Read Full File Content

Read the entire file using the `read` tool. Do NOT classify based on:
- File path or directory patterns
- File name conventions
- Previous classifications from other files
- Assumptions about what "should" be core

### Step 2: Analyze Content Semantically

Examine the content for:
- **Generic terms vs project-specific references:** Does it mention any project by name?
- **Portability test:** Could this file be copied to a different project and work without changes?
- **Dependencies:** Does it import from project-specific modules or reference project paths?
- **Scope of applicability:** Is the described workflow/standard useful in any project?

### Step 3: Document Classification

For each classified file, document:

```
**Content Read:** Yes (full file analyzed)

**Analysis:**
- {finding_1}: specific content observation
- {finding_2}: specific content observation
- {finding_3}: specific content observation

**Project-Specific Content Found:**
- {specific content or "None"}

**Classification:** ✅ Core / 🚫 Project-Specific / ⚠️ Uncertain
```

### Step 4: Produce Classification Report

Generate a summary of all classifications:

| File | Classification | Key Reason |
|------|---------------|------------|
| {path} | Core | Generic workflow definition |
| {path} | Project-Specific | References project-specific paths |
| {path} | Uncertain | Mixed generic and specific content |

## Classification Rule

**When in doubt, classify as project-specific.** Syncing project-specific content to another repository is destructive — it overwrites project-specific configurations with content that doesn't belong. Missing core content is recoverable (it can be re-synced from the source). Overwritten project-specific content may be lost permanently.

## Error Handling

| Error | Resolution |
|-------|-----------|
| File not found | Mark as "missing" in report, skip classification |
| File too large to read | Read first 500 lines, classify based on available content, flag as "partial" |
| Binary file | Mark as "binary" in report, auto-classify as project-specific |

## Context Required

- Related skills: `sync-guidelines` (parent skill)
- Related tasks: `sync-push`, `sync-pull`