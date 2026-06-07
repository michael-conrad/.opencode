# Sub-Agent Dispatch Audit Schema

Canonical table schema for all SKILL.md Sub-Agent Dispatch Audit sections.

## Schema

| Column | Description | Values |
|--------|-------------|--------|
| Scope of Context | What context is passed to the sub-agent | Comma-separated list of field names |
| Exclusions | What is explicitly excluded | Comma-separated or "None" |
| Pre-Analysis Contract | What pre-analysis receives | `{ issue_number, task_description, github.owner, github.repo }` |
| Includes Inline Work? | Whether the task does inline work | YES/NO |

## Requirements

1. Section heading MUST be `## Sub-Agent Dispatch Audit` (level 2 heading, not level 3).
2. Content MUST be a Markdown table with exactly these 4 columns in this order.
3. Every skill MUST have exactly one `## Sub-Agent Dispatch Audit` section.
