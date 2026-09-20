# Plan Input Verification Ledger — .opencode#2449

Recorded once (2026-09-20). All subsequent plan steps re-read THIS ledger, not the sources.

## Issue State

- Issue: .opencode#2449 — `[SPEC] local-issues list reports [open] for artifact-only dirs without issue.yaml`
- Local `issue.yaml` status: `open`; labels: `approved-for-pr`
- Canonical local path: `.opencode/.issues/2449/issue.yaml`

## SC List (from spec.md)

| SC | Criterion (short) | Evidence Type |
|----|-------------------|---------------|
| SC-1 | `list` emits `[artifact-only]`, not `[open]`, for dirs without `issue.yaml` | behavioral |
| SC-2 | `search` marks yaml-less dirs `[artifact-only]`, no synthesized `status: open` | behavioral |
| SC-3 | `read` omits `status: open` for yaml-less dirs with plain-markdown specs | behavioral |
| SC-4 | Well-formed tickets keep real status; `[artifact-only]` marker never appears for them | behavioral |

## Structure Artifact Mappings

- Phase 1 → SC-1 (red/green/verify/commit-inline); depends: none
- Phase 2 → SC-2; depends: none
- Phase 3 → SC-3; depends: none
- Phase 4 → SC-4; depends: 1, 2, 3
- DAG check: PASS (all edges backward); triplet colocation: PASS

## CLI Surface (verified)

- `./.opencode/tools/local-issues update --number N --labels ...` — flags: `--number`, `--labels` (space/comma separated), `--title`, `--status`, `--phase`, `--body-file`, `--github`, `--remote-url`
- Label write REPLACES the entire labels array → must pass all existing labels plus `spec-cleared`: `--labels approved-for-pr spec-cleared`

## Dispatch Indicators

- `(**direct**)` = orchestrator executes in own context (default)
- `(**task-card**)` = orchestrator dispatches step's task card via `task()`

## Per-Task Cycle (from implementation-workflow reference card)

red → green → post-regression → verify → commit-inline (daisy-chained; commit includes test + change, no co-author trailers at implementation time)
