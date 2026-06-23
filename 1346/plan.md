# Plan: Plan File Format — Master ToC + Per-Phase Sub-Plans

Spec: #1346

## Phase List

| Phase | Concern | Depends On | SCs | Exit Criteria |
|-------|---------|------------|-----|---------------|
| 1 | Master ToC Format | (none) | SC-1, SC-2, SC-3, SC-4 | `plan.md` ≤50 lines, acyclic deps, verifiable exit criteria, orchestrator-loadable |
| 2 | Sub-Plan File Format | Phase 1 | SC-5, SC-6, SC-7, SC-8, SC-16, SC-17, SC-18 | Three-section structure, dispatch contracts, checkbox format, self-contained, commits:true, checkpoint_tag header + step |
| 3 | Work State File | Phase 1 | SC-9, SC-10, SC-11 | Required fields, Z3-verifiable contracts, session-resilient |
| 4 | implementation-pipeline Skill Update | Phase 2 | SC-19, SC-20, SC-21 | Explicit checkpoint-tag-create step, Z3 state machine updated, no implicit steps |
| 5 | writing-plans Skill Changes | Phase 2, Phase 3 | SC-12, SC-13, SC-14, SC-15 | Multi-file output, dispatch contracts, work state file, task files updated |

## Dependency Ordering

```
Phase 1 (no deps)
├── Phase 2 (depends on Phase 1)
│   ├── Phase 4 (depends on Phase 2)
│   └── Phase 5 (depends on Phase 2, Phase 3)
└── Phase 3 (depends on Phase 1)
```

## Exit Criteria

All SCs PASS with declared evidence type. Plan files committed to `.opencode/.issues/1346/`. No implicit steps remain in implementation-pipeline dispatch routing table.

## Sub-Plan Files

| Phase | File |
|-------|------|
| 1 | `plan-phase-1.md` |
| 2 | `plan-phase-2.md` |
| 3 | `plan-phase-3.md` |
| 4 | `plan-phase-4.md` |
| 5 | `plan-phase-5.md` |

## Work State File

`.tmp/work-state-1346.yaml` — disk-persistent phase tracking with Z3-verifiable state transitions.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
