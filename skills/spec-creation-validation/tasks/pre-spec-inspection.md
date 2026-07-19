# Task: pre-spec-inspection

## Purpose

Check for superseding issues, overlapping specs, and codebase conflicts before spec creation begins. Returns BLOCKED if blocking conflicts are found.

## Entry Criteria

- Spec number `N` is known (from `create-remote-stub`)
- GitHub API access is available (for remote platform)

## Procedure

- [ ] 1. **Search for open [SPEC] issues** — Query GitHub Issues for open issues with `[SPEC]` label. Compare titles and file references against the proposed spec topic.
- [ ] 2. **Check merged PRs** — Search for recently merged PRs that may have implemented related functionality, making the proposed spec stale.
- [ ] 3. **Read codebase state** — Check if referenced code locations have been modified since the spec was conceived.
- [ ] 4. **Classify findings** — Use the four-tier classification:
     - **FULL-SUPERSESSION:** Another spec's scope entirely covers this spec's scope → BLOCKED
     - **PARTIAL-OVERLAP:** Specs share files/symbols but have different core concerns → Surface to developer
     - **CONFLICT-RISK:** Same files modified with conflicting intent → BLOCKED
     - **INDEPENDENT:** No meaningful overlap → Proceed
- [ ] 5. **Write findings** — Save to `.issues/{N}/artifacts/pre-spec-inspection.yaml` with classification and evidence.

## Result Contract

| Field | Value |
|-------|-------|
| `status` | `DONE` \| `BLOCKED` |
| `finding_summary` | `"Pre-spec inspection: <classification> — <summary>"` |
| `artifact_path` | `.issues/{N}/artifacts/pre-spec-inspection.yaml` |
| `blocker_reason` | `<why if BLOCKED>` |
