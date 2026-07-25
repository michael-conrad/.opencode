---
remote_issue: 2137
remote_url: https://github.com/michael-conrad/.opencode/issues/2137
promoted_at: 2026-07-25T00:00:00Z
labels: [spec, needs-approval]
---

> **Full spec and plan artifacts:** https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2137/ — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2137/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

The entire `.opencode/` infrastructure — guidelines, skill cards, task files, enforcement blocks — is formatted as if it is going through a mechanical parser. Content uses machine-parseable ID prefixes (`[critical-rules-NNN]`), enforcement labels (`CRITICAL VIOLATION —`, `🚫 FORBIDDEN`, `✅ REQUIRED`), fixed-width structured sections, and template-like formatting that no tool, script, or parser actually consumes.

The only consumer is an LLM reading natural language prose. The structured formatting is cargo-culted from a mental model of "this needs to be machine-parseable" when in reality no parser exists.

## Scope

Audit the entire `.opencode/` directory for this defective pattern:

1. **Machine-parseable ID prefixes** — `[critical-rules-NNN]`, `[approval-gate-NNN]`, `[SC-NNN]`, `[TASK-NNN]`, or any `[WORD-NUMBER]` prefix with no parser consuming it
2. **Enforcement label prefixes** — `CRITICAL VIOLATION —`, `🚫 FORBIDDEN`, `✅ REQUIRED`, `⚠️ WARNING`, `Tier 1/2/3` labels that are prose-only
3. **Fixed-width structured sections** — `#### 🚫 FORBIDDEN` / `#### ✅ REQUIRED` subsection pairs, `| Violation Pattern | Consequence |` tables, template-like structures designed for mechanical extraction
4. **Evidence type declarations** — `evidence_type: behavioral|string|semantic|structural` in specs/task files that no tool validates
5. **Frontmatter fields with no consumer** — YAML frontmatter fields in SKILL.md or task files that no tool or script reads

**Out of scope:** Removing any content that has a verifiable consumer (tool, script, parser, or enforcement gate). This audit identifies dead weight — it does not prescribe removal without consumer verification.

## Approach

A research sub-agent will search all files in `.opencode/` for each pattern category, verify whether any tool/script/parser actually consumes each pattern by checking `.opencode/tools/`, `.opencode/plugins/`, `.opencode/scripts/`, and `.opencode/hooks/`, then report counts, file locations, and consumer status per category. Patterns confirmed as having zero consumers will be flagged for remediation in a follow-up spec.

## Impact

| Risk | Mitigation |
|------|-----------|
| False positives — patterns that appear dead but have an obscure consumer | Cross-verify every pattern against all tool/plugin/script directories before classifying |
| Scope creep into content reformatting | Strictly limit to audit + consumer verification; remediation is a separate spec |
| Audit fatigue from large file count | Use automated search (grep/glob) per category, not manual review |

**Dependencies:** None — this is a standalone audit.

🤖 OpenCode (ollama-cloud/deepseek-v4-flash) created
