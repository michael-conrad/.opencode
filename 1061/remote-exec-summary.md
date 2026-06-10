> **Full spec and artifacts: [`.issues/1061/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1061)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/1061/spec-artifacts/` — card catalogue, solve contracts, SC coverage summary, lifecycle manifest, dependency-ordering verification, verification consistency contract, revision re-entry contract

## Exec Summary

Structured artifact infrastructure layer — solve contracts, plan validations, SC coverage YAML, lifecycle manifests, blocker documentation, and verification consistency checks — codified as permanent, append-only, machine-parseable artifacts integrated into spec-creation and writing-plans at invocation time.

### Cards (dependency order)
1. **Spec-level permanent artifacts** (Phase 1) — SC coverage YAML, verification consistency contract, lifecycle manifest, revision re-entry protocol, solve utility invocations after Step 5.5, artifact path column mandate, expanded pre-approval gate
2. **Plan-level consumption** (Phase 2) — Phase dependency solve contracts, plan utility validation, SC-ID mapping, spec-to-plan handoff artifact check
3. **Pipeline integration** (Phase 3) — Lifecycle manifest event emission points, artifact retention policy, step-specific pre-cleanup

### Key Decisions
- **DEC-1**: Permanent artifacts under `spec-artifacts/`, ephemeral under `./tmp/{issue-N}/` — survives pipeline restarts, cleaned at PR merge
- **DEC-3**: Solve contracts are spec-level, not plan-level — dependency ordering is a spec concern
- **DEC-4**: Utility invocations at artifact creation time, not downstream verification — catches defects before pipeline commits

### Risk Callouts
- **RISK-5**: `solve`/`plan` utilities may not be installed — fallback: agent models constraints manually, emits WARNING in lifecycle manifest
- **RISK-3**: SC coverage YAML desync from prose SC table — self-review validation + pre-approval gate re-check mitigates
- **Write amplification**: 3+ artifact files touched per spec change, but all generated during Step 1 assembly, not hand-maintained

🤖 OpenCode (deepseek-v4-flash) updated