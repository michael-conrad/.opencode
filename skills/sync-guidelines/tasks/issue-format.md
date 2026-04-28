# Task: issue-format

## Purpose

Provide the structured template for creating sync issues on GitHub/GitBucket with classification analysis and file contents. This template ensures every sync issue includes intelligent inspection results, not pattern-based classification.

## Template

```markdown
# [SYNC] {direction}: {count} files from {source_repo}

**Source:** {source_owner}/{source_repo}
**Commit:** [{short_sha}](commit_url)
**Direction:** Push | Pull
**Sync Method:** Issue-based (intelligent inspection, no patterns)

## Classification Analysis

### File: {filepath}

**Content Read:** Yes (full file analyzed)

**Analysis:**
- {finding_1}
- {finding_2}
- {finding_3}

**Project-Specific Content Found:**
- {specific content or "None"}

**Classification:** ✅ Core / 🚫 Project-Specific / ⚠️ Uncertain

---

{Repeat for each file}

## Files to Sync (Core Only)

| File | Classification | Key Reason |
|------|---------------|------------|
| {path} | Core | {reason} |

## Files Not Synced

| File | Classification | Key Reason |
|------|---------------|------------|
| {path} | Project-Specific | {reason} |

## File Contents

### {filename}

```{language}
{full file content}
```

## Verification

- Source commit: [{sha[:8]}](url)
- All files read and analyzed: Yes
- Pattern-based classification used: No

---
*Created by sync-guidelines skill*
*Classification via intelligent content inspection*
```

## Key Requirements

Every sync issue MUST include:

1. **Intelligent content inspection** — Each file is read in full and analyzed semantically, not classified by filename patterns or directory location. The analysis section MUST explain what the file does and why it is core or project-specific.

2. **Classification reasoning documented in issue** — The issue body MUST show the reasoning for each classification decision. "Core because it's in guidelines/" is NOT valid reasoning. "Core because it defines a generic approval-gate workflow applicable to any project" IS valid reasoning.

3. **Project-specific content explicitly identified** — Any project-specific paths, references, or configurations found in core files MUST be called out. This enables the target repo to adapt the content during pull syncs.

4. **File contents included for human review** — Full file contents MUST be included in the issue body or as collapsible sections so the target repo maintainer can review before syncing.

5. **Verification section MUST confirm intelligent inspection** — The verification section explicitly states that pattern-based classification was NOT used and that all files were read and analyzed.

## Classification Best Practices

| File Type | Usually Core | Usually Project-Specific |
|----------|-------------|------------------------|
| Workflow definitions | ✅ | |
| Project configuration | | ✅ |
| Error handling patterns | ✅ | |
| Database paths/queries | | ✅ |
| API endpoint definitions | | ✅ |
| Engineering standards | ✅ | |
| Project-specific imports | | ✅ |

When in doubt, classify as **Project-Specific**. Syncing project-specific content to another repo is destructive; missing core content is recoverable.

## Key Principles

### Intelligent Inspection Over Pattern Matching

File classification must be based on reading and analyzing the actual content of each file. Directory location and filename patterns are NOT classification criteria. A file in `guidelines/` may be project-specific if it references project-specific paths; a file in `tools/` may be core if it implements a generic workflow. The analysis section in the issue template exists specifically to document the content-based reasoning.

### Err on the Side of Caution

When classification is uncertain, default to Project-Specific. Syncing project-specific content to another repository can overwrite custom configurations and break workflows. Missing core content is a gap that can be filled in a future sync; accidentally synced project-specific content is damage that requires manual remediation.

### Full File Contents Enable Human Review

Including complete file contents in the sync issue is not optional — it is a verification requirement. The target repository maintainer must be able to review the proposed changes without checking out the source repository. Collapsible sections (`<details>`) may be used for large files to keep the issue readable.

## Result Contract

```yaml
status: DONE
task: issue-format
direction: push | pull
files_classified: <int>
core_count: <int>
project_specific_count: <int>
uncertain_count: <int>
```

## Context Required

- Related skills: `sync-guidelines` (parent skill)
- Related tasks: `sync-push`, `sync-pull`