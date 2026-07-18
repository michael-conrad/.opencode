---
title: '[SPEC] Canonical cross-reference format — rollout Load [Text](path) across all cards and guidelines'
status: draft
created: 2026-07-15
revised: 2026-07-18
license: MIT
provenance: AI-generated
issue: 1958
supersedes:
  - 1953
informs:
  - 1925
  - 1926
informed_by:
  - 1988
authors:
  - OpenCode (deepseek-v4-flash)
---

> **Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/1958/**
>
> **Local artifacts:** `.opencode/.issues/1958/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings
>
> **Supersedes:** #1953
> **Informed by:** #1988 (78-run experiment — form and verb both settled)
> **Informs:** #1925 (linting rules), #1926 (behavioral tests)

## Problem

The cross-reference pattern in `.opencode/` files is inconsistent. References to other files, sections, and skills appear in multiple forms across SKILL.md files, guidelines, task files, and `default.txt`:

- **Inline links with wrong verbs:** `See [file](path)`, `Read [file](path)` — verbs that #1988 proved defective ("See" treats content as informational, "Read" produces false positives)
- **Bare section numbers:** `§N` — no link, no verb, no path
- **Symbol-only names:** `§Name` — no link, no path
- **Non-linked text references:** `See file.md` — plain text, no markdown link
- **Resolution tables with admonitions:** `> Read all linked documents` — the pattern #1988 proved achieves only 42-58% access rate
- **Bare "See" references:** `See SKILLNAME skill` — no link, relies on agent inference

Sibling spec #1988 completed 78 experimental runs proving:

1. **Form:** Inline link is the only viable pattern (100% Tier 1 access rate vs 42-58% for resolution table + admonition)
2. **Verb:** "Load" is the winning verb — 100% access rate AND the agent correctly applies the referenced value. "See" triggers access but the agent treats content as informational (reads `timeout=30`, runs `sleep 1`). "Read" is a false positive (lists directory, never reads content).

The research is complete. This spec rolls out the canonical format across all skill cards, guidelines, task files, and `default.txt`, replacing every variant with the single correct form.

## Canonical Format

```
Load [descriptive text](relative/path.md)
```

### Rules

1. **Verb:** Always `Load`. Never `See`, `Read`, `Fetch`, or bare symbols.
2. **Link text:** Descriptive text naming the target content. Never bare section numbers (`§N`).
3. **Path:** Relative path from the referencing file. One level deep per Agent Skills spec.
4. **Form:** Inline markdown link. No resolution table, no admonition.
5. **Meaning:** The agent MUST call a file-loading tool on the linked path. Content is actionable, not informational.

## Implementation Phases

### Phase 1 — Discovery and Inventory

Scan every file in the `.opencode/` submodule (SKILL.md, task files, guidelines, `default.txt`, scripts) and classify every cross-reference by its current form:

| Form | Example | Count |
|------|---------|-------|
| `See [text](path)` | `See [the reference](REFERENCE.md)` | TBD |
| `Read [text](path)` | `Read [the file](path.md)` | TBD |
| `§N` | `§1`, `§2.3` | TBD |
| `§Name` | `§DISPATCH_GATE` | TBD |
| Non-linked text | `See file.md`, `See SKILLNAME skill` | TBD |
| Resolution table + admonition | `\| §1 \| path \|` + `> Read all` | TBD |
| Already correct `Load [text](path)` | — | TBD |

Output: a structured inventory file at `.opencode/.issues/1958/data/cross-reference-inventory.yaml`

### Phase 2 — Replace All Non-Conforming References

For each file identified in Phase 1, replace every non-conforming cross-reference with the canonical `Load [descriptive text](relative/path.md)` form. This includes:

1. **`000-critical-rules.md`** — `Read [Text](path)` → `Load [Text](path)`
2. **All SKILL.md files** — replace `See [file]`/`Read [file]`/bare `§N`/resolution tables with `Load [file]`
3. **All guidelines** — same pattern replacement
4. **All task files** — same pattern replacement
5. **`default.txt`** — cross-reference directive
6. **Any other file** in `.opencode/` with cross-references

### Phase 3 — Close and Inform

1. Close #1953 as superseded
2. Comment on #1925 and #1926 with canonical format reference

## Success Criteria

| ID | Criterion | Evidence Type | Threshold |
|----|-----------|---------------|-----------|
| SC-1 | Cross-reference inventory produced at `.opencode/.issues/1958/data/cross-reference-inventory.yaml` | structural | file exists |
| SC-2 | `000-critical-rules.md` updated to `Load [Text](path)` | string | grep match |
| SC-3 | No `See [` or `Read [` in any SKILL.md | string | zero grep count |
| SC-4 | No `See [` or `Read [` in any guideline | string | zero grep count |
| SC-5 | No `§N` or `§Name` bare references in any SKILL.md | string | zero grep count |
| SC-6 | No resolution table patterns in any SKILL.md | string | zero grep count |
| SC-7 | No non-linked text references (`See file.md`, `See SKILLNAME`) in any SKILL.md | string | zero grep count |
| SC-8 | #1953 closed as superseded | structural | GitHub API |
| SC-9 | #1925 and #1926 have comments linking to this spec | structural | Comments exist |

## Impact

- Risk: grep-based SCs may miss edge cases — manual spot-check of 5 random SKILL.md files
- Risk: Some bare `§N` references may be in prose that needs rewriting, not just link replacement — Phase 1 inventory will identify these
- Call to action: Review and approve this spec to begin rollout
