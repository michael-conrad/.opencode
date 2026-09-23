# Not-Applicable Artifact Justifications

| Artifact | Status | Justification |
|----------|--------|---------------|
| concern-map | not-applicable | Single-concern change: routing text of one skill card. Multi-concern mapping applies only to multi-concern specs; deck-wide and pipeline-wiring concerns are explicit non-goals per developer scope ruling (2026-09-23) |
| cross-cutting | not-applicable | No concern boundaries crossed — change is confined to `.opencode/skills/playwright-cli/` plus its own tests-v2 test scripts; no shared infrastructure touched |
| interface-compat | not-applicable | No public code API modified. The description is the skill's routing interface; its compatibility constraints (≤1024 chars, required frontmatter fields, unchanged non-description fields) are fully covered by SC-3 within testability.md |
| state-analysis | not-applicable | No persistent state touched — description is static agent-facing configuration text; no stateful component exists in the change set |
