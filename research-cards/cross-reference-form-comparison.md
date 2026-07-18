---
title: Cross-Reference Form Comparison — Inline Link vs Resolution Table
created: 2026-07-18
source: "#1988"
confidence: 0.95
tags: cross-reference, form, inline-link, resolution-table, experiment
---

## Research Question

Which cross-reference form more reliably causes an AI agent to access referenced files: inline markdown links (`See [file](path)`) or symbol-only refs with a resolution table and admonition (`§Name` + table + `> Read all linked documents`)?

## Methodology

78 runs across 2 tiers:
- **Tier 1 (60 runs):** 4 fixture types × 5 forms × 3 runs. Agent reads a SKILL.md with references, must access files to complete a task.
- **Tier 2 (18 runs):** 2 fixtures × 3 forms × 3 runs. Clean-room sub-agent reads a task card with references, must access files.

Forms tested: A (inline link), B1 (bare §Name + table), B2 (bracketed [§Name] + table), B3 (conditional §Name + table), C (explicit verb + table).

## Key Findings

| Form | Tier 1 Access Rate | Tier 2 Access Rate |
|------|-------------------|-------------------|
| Form A (inline link) | **100%** (12/12) | 67% (4/6) |
| Form B1 (bare §Name) | 50% (6/12) | N/A |
| Form B2 (bracketed) | 42% (5/12) | N/A |
| Form B3 (conditional) | 58% (7/12) | 67% (4/6) |
| Form C (explicit verb) | 58% (7/12) | 83% (5/6) |

**Conclusion:** Inline link form is the only viable pattern at 100% Tier 1. The resolution table + admonition pattern achieves only 42-58% — the agent reads the table as text but does not follow the links. Not a viable replacement.

## Verb Sub-Test

8 verbs tested on Fixture A at Tier 2 (24 runs). "Load" was the only verb that triggered file access AND caused the agent to correctly apply the referenced value. "See" triggered access but the agent treated content as informational (read `timeout=30`, ran `sleep 1`). "Read" was a false positive (listed directory, never read content). "Fetch" caused web fetch attempts.

## Sources

- Full measurement data: `.opencode/.issues/1988/data/measurements.jsonl`
- Tier 2 data: `.opencode/.issues/1988/data/measurements-tier2.jsonl`
- Verb test data: `.opencode/.issues/1988/data/measurements-verb-test.jsonl`
- Test fixtures: `.opencode/.issues/1988/data/fixtures/`
- Audit artifacts: `.opencode/.issues/1988/data/artifacts/spec-audit/`
