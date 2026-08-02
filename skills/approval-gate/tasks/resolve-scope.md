---
name: resolve-scope
description: "Parse authorization text and resolve scope/halt_at from verb-prefix patterns. Returns resolved scope, halt_at, and authorization status."
provenance: AI-generated
---

# Task: resolve-scope

## Purpose

Parse authorization text (issue comments, user messages) and resolve the authorization scope and halt_at value using the verb-prefix parsing table from the parent SKILL.md.

## Entry Criteria

- Authorization text is available (issue comment or user message)
- Verb-prefix parsing table is defined in `approval-gate/SKILL.md`

## Steps

1. Read the authorization text from the provided context
2. Match against the verb-prefix parsing table in `approval-gate/SKILL.md` §Authorization Scope Model
3. Resolve scope, halt_at, and PR strategy
4. Write result contract to `{project_root}/tmp/{issue-N}/resolve-scope.yaml`

## Exit Criteria

- Scope resolved and written to artifact
- If no match found: return BLOCKED with `UNKNOWN_SCOPE`

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "Scope resolved: {scope}, halt_at: {halt_at}"
artifact_path: "{project_root}/tmp/{issue-N}/resolve-scope.yaml"
blocker_reason: null | "UNKNOWN_SCOPE: no matching verb-prefix pattern"
```
