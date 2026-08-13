---
remote_issue: 2132
remote_url: https://github.com/michael-conrad/.opencode/issues/2132
---

> **Full spec and artifacts: [`.opencode/.issues/2132/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2132/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2132/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

`090-data-integrity.md` contains narrow pipeline-specific rules (from a PubMed XML project) that don't cover general data integrity concerns. Each of the 6 broader categories generalizes an existing battle-tested project-specific rule, keeping the fix proportionate to the blast radius of one guideline file.

## Scope

Revise the file in place: preserve all existing battle-tested rules (no synthetic data, fail fast, no hardcoded IDs, batch ops, tqdm, cross-reference to 200-errors.md), remove project-specific references (pubmed_data_2, SEED_PM_IDS, MeSH, discovery_date), and add 6 broader categories: data validation at system boundaries, serialization integrity, data classification, migration integrity, audit trail, data retention.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | File contains 6 data integrity categories | string |
| SC-2 | No project-specific references (pubmed_data_2, SEED_PM_IDS, MeSH, discovery_date) | string |
| SC-3 | Existing specific rules preserved (no synthetic data, fail fast, no hardcoded IDs, batch ops, tqdm, cross-references) | string |
| SC-4 | Data validation at boundaries covers structure, types, constraints, missing data, entity resolution | string |
| SC-5 | Serialization integrity covers versioning, backward compat, traceability | string |
| SC-6 | Data classification covers sensitivity levels, production data restrictions | string |
| SC-7 | Migration integrity covers reversibility, verification, sampling | string |
| SC-8 | Audit trail covers traceability, authorization, documented changes | string |
| SC-9 | Data retention covers retention policies per classification | string |
| SC-10 | Agent refuses to generate synthetic/fabricated data, outputs explicit decline | behavioral |
| SC-11 | Agent raises `ValueError` (exact type) on missing required data — no defaults/placeholders/fallbacks | behavioral |
| SC-12 | Agent derives entity references from runtime sources, no hardcoded constants | behavioral |
| SC-13 | All 6 enumerated specific rules preserved in new file (per-rule present/absent verification) | semantic |

## Files Affected

- `.opencode/guidelines/090-data-integrity.md`

## Dependencies

- `opencode run` via `with-test-home` wrapper — SC-10/11/12
- Git history access to pre-revision state — SC-13

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
