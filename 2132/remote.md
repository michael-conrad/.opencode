---
remote_issue: 2132
remote_url: https://github.com/michael-conrad/.opencode/issues/2132
---

> **Full spec and artifacts: [`.opencode/.issues/2132/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2132/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2132/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

`090-data-integrity.md` contains narrow pipeline-specific rules that don't cover general data integrity concerns.

## Scope

Replace entire file with 6-category data integrity framework: data validation at boundaries, serialization integrity, data classification, migration integrity, audit trail, data retention.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | File contains 6 data integrity categories | string |
| SC-2 | No project-specific references (pubmed_data_2, SEED_PM_IDS, MeSH, discovery_date) | string |
| SC-3 | No cross-reference to 200-errors.md | string |
| SC-4 | No tqdm requirement | string |
| SC-5 | Data validation covers structure, types, constraints, missing data, entity resolution | string |
| SC-6 | Serialization integrity covers versioning, backward compat, traceability | string |
| SC-7 | Data classification covers sensitivity levels, production data restrictions | string |
| SC-8 | Migration integrity covers reversibility, verification, sampling | string |
| SC-9 | Audit trail covers traceability, authorization, documented changes | string |
| SC-10 | Data retention covers retention policies per classification | string |

## Files Affected

- `.opencode/guidelines/090-data-integrity.md`

## Dependencies

None.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
