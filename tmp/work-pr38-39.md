# Work State: PR for #38 + #39

## Authorization
- scope: for_pr
- halt_at: pr_created
- pr_strategy: stacked
- issues: #38, #39
- authorization_source: "approved for PR #38, #39"

## Dependency Graph
```
#38 (Schema & Registry Infrastructure)
  ├── Phase 1: Extend yaml+symbolic schema to v2.0
  ├── Phase 2: Extend sym-extract pipeline for new sections
  ├── Phase 3: skildeck CLI skeleton
  └── Phase 4: Registry bootstrap from 5 existing files
       │
       ▼
#39 (Exhaustive Analysis Engine) — depends on #38
  ├── sym-exhaustive: Exhaustive pairwise SAT
  ├── sym-entailment: Pre/post entailment checking
  ├── sym-guards: Guard completeness and disjointness
  ├── sym-enforcement: Critical rules → skill checkpoint mapping
  ├── sym-triggers: Trigger keyword ambiguity detection
  └── sym-decomposition: Missing mandatory decomposition entries
```

## Execution Strategy
- **Stack**: #38 first, then #39 stacked on top
- **Branch**: feature/38-39-skill-deck-formal-analysis (single branch for PR1)
- **PR**: Stacked PR targeting dev, containing both #38 and #39 changes

## Flat Item List

### #38 Implementation Items (4 phases)
1. Extend yaml+symbolic schema to v2.0 (tasks, decomposition, gates, evidence_artifacts)
2. Extend sym-extract pipeline for new section types
3. skildeck CLI skeleton (lint, analyze, gates, export, watch, extract)
4. Registry bootstrap from 5 existing files (migrate schema v1.0 → v2.0)

### #39 Implementation Items (6 modules)
5. sym-exhaustive: Exhaustive pairwise SAT (extends sym-conflicts)
6. sym-entailment: Pre/post entailment checking
7. sym-guards: Guard completeness and disjointness
8. sym-enforcement: Critical rules → skill checkpoint mapping
9. sym-triggers: Trigger keyword ambiguity detection
10. sym-decomposition: Missing mandatory decomposition entries

## Sub-issue Gap-fill
Both #38 and #39 have 0 sub-issues. Per for_pr gap-fill cascade, sub-issues should be auto-created under each issue for implementation phases. However, since this is a stacked PR with 10 flat items, sub-issues will be created as tracking items.

## Base Hash
dev: 3103ef2

## dispatch_context
worktree.path: <pending>
github.owner: michael-conrad
github.repo: opencode-config
dev.name: Michael Conrad
dev.email: m.conrad.202@gmail.com