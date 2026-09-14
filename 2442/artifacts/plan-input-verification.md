# Plan Input Verification Ledger — issue 2442

Written once from sources (spec.md, structure.yaml, issue.yaml, implementation-workflow.md, plan-structure-standards.md, plan-artifact-format.md §3.5, cost-model-standards.md, blast-radius.yaml). All later plan-writing steps read THIS file, not the sources.

## Issue State

- Issue: 2442 (local `.opencode/.issues/2442/`), title: `[SPEC-FIX] Correct .issues/ file-access rule in .opencode/AGENTS.md: git -C for git operations, standard file access otherwise`
- Status: open; Labels (local issue.yaml, canonical): `approved-for-pr`
- Platform: github.com (owner michael-conrad, repo .opencode) — remote available for best-effort label write
- Authorization scope: for_pr (approved-for-pr); pr_strategy: stacked

## Success Criteria (from spec.md table)

| SC | Criterion (short) | Evidence Type |
|----|-------------------|---------------|
| SC-1 | AGENTS.md worktree section states standard file access to .issues/ files is permitted | structural |
| SC-2 | "silently targets the wrong repository / corrupts git state" prohibition on read/write/edit/glob/grep absent | structural |
| SC-3 | git -C requirement for .issues/ git ops + parent-repo `git add .issues/` FORBIDDEN rule retained | structural |
| SC-4 | No residual contradicting file-access-prohibition phrases in .opencode/AGENTS.md | structural |
| SC-5 | Behavioral scenario passes via opencode run (stderr shows .issues/ file read via standard tool; no parent-repo git add .issues/) | behavioral |

## Structure Artifact Mappings

- Phase 1: "Correct the .issues/ worktree rule in .opencode/AGENTS.md" — SC-1..SC-4, each own red/green/verify/commit cycle, skill test-driven-development; commit via commit-inline (orchestrator)
- Phase 2: "Behavioral enforcement scenario" — SC-5, red/green/verify/commit (behavioral variant: commit+push before behavioral run), skill test-driven-development
- DAG: 1 → 2 (SC-5 verifies phase-1 corrected rule); no cycles
- Triplet colocation: verified; SC-5 RED depends only on SC-1..SC-4 committed outputs

## CLI Surface Flags (verified via --help)

- `./.opencode/tools/local-issues update --number N --labels [LABELS ...]` — labels flag REPLACES entire array; every write must include all existing labels (currently `approved-for-pr`) plus new one. Qualified name form: `.opencode#2442`.

## Format Pins (from plan-structure-standards.md, pinned — not re-litigated)

- Frontmatter field order: plan_schema_version, issue, title, authorization_scope, pr_strategy, phase_count, dispatch (array of skill+task refs per phase)
- Phase-table columns: Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch
- Continuous step numbering 1..N across pre-impl, phases, post-impl
- Dispatch cell style: summary form like `direct (1-4) + task-card (5-14)`
- No fenced code blocks in body; frontmatter is sole YAML; exit criteria C1..Cn; no timestamps; no identifier IDs
- Split-file format REQUIRED (2 phases): plan.md + plan-01-{slug}.md + plan-02-{slug}.md
- Guard block copied verbatim from plan-artifact-format.md §3.5 (reason code ORCHESTRATOR_ONLY_PLAN)
- Per-phase cost frames: `**Cost frame:** [action cost]. [skipping cost].` (dark-prose-007)
