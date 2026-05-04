---
name: correspondence
description: Use when drafting stakeholder emails, status updates, or external communications. Triggers on: email, correspondence, stakeholder email, status update, communication, draft email, reply, notification.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: correspondence

## Overview

Enforces multipart/alternative format (text/plain + text/html) for email, stakeholder content rules, audience-aware content levels, and verification-enforcement integration. Prevents markdown in email bodies, internal artifact leakage, and format guessing.

## Tasks

| Task | Words |
|------|-------|
| `draft` | ≈800 |
| `completion` | ≈200 |

## Invocation

`/skill correspondence --task draft` (draft email), `--task completion` (halt guarantee). Overview with no flag.

## Operating Protocol

1. **Verification gate before drafting** (`verification-enforcement --task verify`).
2. **Multipart/alternative mandatory** for email output.
3. **Audience separation:** stakeholder tier MUST NOT include internal artifacts (runbook paths, step numbers, internal IPs, file paths, CLI commands).
4. **Audience classification before drafting.** Default to stakeholder tier when unclear.
5. **Revisit after self-review** (`verification-enforcement --task revisit`).
6. **AI byline mandatory** in all correspondence.
7. **Content-type propagation:** match source email format (inspect Content-Type header).
8. **Attribution verification:** no role-proximity inference — only evidence-backed attribution.

## Sub-Agent Dispatch Audit

`draft` dispatches with `{ context, audience_tier, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description }`. No inline work.

## Cross-References

Skills: `verification-enforcement`. Guidelines: `000-critical-rules.md` (audience separation).

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: correspondence-002
    title: "Multipart/alternative format mandatory for email"
    conditions:
      all: ["output_format == email", "multipart_alternative_parts_present == false"]
    actions: [REJECT(draft)]
    source: "correspondence/SKILL.md"

  - id: correspondence-003
    title: "Audience separation — no internal artifacts in stakeholder tier"
    conditions:
      all: ["audience_tier == stakeholder", "content_contains_internal_artifacts == true"]
    actions: [REJECT, FILTER(internal)]
    source: "correspondence/SKILL.md"

  - id: correspondence-006
    title: "AI byline mandatory in all correspondence"
    conditions:
      all: ["ai_byline_present == false"]
    actions: [APPEND(byline)]
    source: "correspondence/SKILL.md"
