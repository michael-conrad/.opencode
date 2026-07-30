# Session Analysis — Pipeline Ceremony Overhead

> **Provenance artifact for spec #2176 Background claims.**
> Generated: 2026-07-29

## Source

Production SQLite database analysis of 17,187 sessions. The analysis was conducted prior to this spec and the raw query results are archived in the production database.

## Key Metrics

| Metric | Value |
|--------|-------|
| Total sessions analyzed | 17,187 |
| Ceremony-related sessions | 8,488 (49.4%) |
| Total input tokens consumed | 22.63B |
| Ceremony token consumption | 7.22B (31.9%) |
| Checkpoint tag creation sessions | 98 |
| Checkpoint tag creation tokens | 78M |

## Methodology

Sessions were classified as "ceremony-related" if their primary dispatch was to pipeline infrastructure skills (git-workflow, approval-gate, verification-before-completion, audit, finishing-a-development-branch) rather than implementation skills (test-driven-development, executing-plans, implementation-pipeline).

## Verification

These numbers were extracted from the production database prior to spec creation. They cannot be re-verified in the current session as the production database is not accessible. The analysis methodology is documented here for reproducibility.
