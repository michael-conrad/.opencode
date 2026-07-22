---
name: dispatch-mode-verification
description: "Pre-execution gate that verifies no plan step uses per-phase or batched dispatch modes. Blocks execution if any step lacks an explicit dispatch indicator or uses eliminated modes."
license: MIT
provenance: AI-generated
---

# Dispatch Mode Verification Gate

Pre-execution verification gate that runs after `assemble-work` creates the dispatch plan but before `pipeline-executor` begins execution. Rejects any plan containing `per-phase` or `batched` dispatch modes, or steps without explicit dispatch indicators.

## Entry Criteria

- [ ] 1. Work state file exists at `{project_root}/tmp/{issue-N}/work.md`
- [ ] 2. Plan is available at `{plan_path}`
- [ ] 3. All plan steps are identified with step numbers

## Procedure

### 1. Scan for Prohibited Modes

Check the entire plan for any occurrence of:
- `per-phase` — forbidden
- `batched` — forbidden
- `batch` — forbidden
- `Dispatch: sub-agent-with-context` — forbidden
- `Dispatch: sub-agent-clean-room` — forbidden
- Phase-level dispatch without per-step indicators — forbidden

**If any prohibited mode found:**
1. Record the exact location (file, line, step)
2. Return `status: BLOCKED` with `reason: PROHIBITED_DISPATCH_MODE`
3. Include `artifact_path` pointing to the scan output

### 2. Verify Every Step Has an Explicit Indicator

Check every step in the plan for an explicit dispatch indicator:
- `` — valid
- `(**sub-agent**)` — valid
- `(**clean-room**)` — valid

**If any step lacks an indicator:**
1. Record the step number and name
2. Return `status: BLOCKED` with `reason: MISSING_DISPATCH_INDICATOR`
3. Include the list of steps missing indicators in `blocker_reason`

### 3. Verify No Default Mode

Confirm that the plan does not document any "default dispatch mode" or "fallback dispatch" — every step must be explicit.

**If any default/fallback dispatch documentation found:**
1. Return `status: BLOCKED` with `reason: DEFAULT_DISPATCH_FOUND`

### 4. Return PASS

If all checks pass:
- `status: DONE`
- `finding_summary: "All steps have valid dispatch indicators. No prohibited modes found. {N} steps verified."`
- `artifact_path: {project_root}/tmp/{issue-N}/verify/dispatch-mode-verification.yaml`

## Verification

- [ ] grep for `per-phase` in plan → absent
- [ ] grep for `batched` in plan → absent
- [ ] grep for `batch` in plan → absent
- [ ] Every step matches `\(\*\*(inline|sub-agent|clean-room)\*\*\)` pattern
- [ ] No step matches `\(\*\*(per-phase|batched)\*\*\)` pattern

## Cross-References

- `assemble-work.md` — Calls this gate before handoff to pipeline-executor
- `pipeline-executor.md` — Requires this gate to have passed before execution
- `SKILL.md` §Overview — Step-level dispatch mandate
- `000-critical-rules.md` §critical-rules-034 — Clean-room sub-agent requirement
