---
remote_issue: 1222
remote_url: "https://github.com/michael-conrad/.opencode/issues/1222"
last_sync: 2026-06-14T20:50:47Z
source: github.com
---

## Summary

Standardized hand-off contract schema for all pipeline stage transitions. Every hand-off carries mandatory `gate_result`, `verifier_identity`, and `artifact_hash` fields enforced by pre-dispatch Z3 gate. Supersedes or reduces scope of 13 pending issues.

## Background

The pipeline hand-off contracts carry routing metadata (which sub-agent, which phase, which file) but carry zero enforcement metadata. The result contract status field (`DONE | BLOCKED | DONE_WITH_CONCERNS | OVERFLOW`) is prose-interpreted, not schema-enforced. No `gate_result`, `verifier_identity`, or `evidence_hash` fields exist. As a result:

1. Orchestrator soft-passes FAIL (#1023, #1027) — no structural field to halt on
2. Z3 validates step position only, never artifact content (#1021, #1198)
3. Work state files are self-certifying prose (#1194)

## Design — 4 Parts

### Part 1: Standard Hand-Off Contract Schema

Every pipeline stage transition produces a YAML contract with these mandatory fields:

```yaml
contract:
  phase: <phase>
  source_step: <step>
  target_step: <step>
  gate:
    gate_result: PASS | FAIL | BLOCKED       # NEVER advisory, NEVER unset
    verdict_source: <model-id>               # resolves to model family
    artifact_hashes:                         # evidence paths + sha256, mandatory for behavioral SCs
      - path: ./tmp/behavioral-evidence-SC-3.log
        sha256: abc123...
  evidence_types:                            # per-SC evidence type for mismatch detection
    - sc_id: SC-3
      declared_type: behavioral
      actual_type: behavioral
  routing:
    next_dispatches: [<step>, ...]
    reroute_on_blocked: <step>
    max_retries: 3
```

`gate.gate_result`, `gate.verdict_source`, and `gate.artifact_hashes` are REQUIRED. Missing or null = structurally invalid contract.

The `gate_result` field replaces prose `status: DONE | BLOCKED` with a schema-enforced tri-state Z3 can inspect. No prose interpretation — the field IS the verdict.

`DONE_WITH_CONCERNS` is removed as a valid pipeline step status. Per #1023 root cause: any per_criterion FAIL → overall `gate_result = FAIL`.

### Part 2: Z3 Gate Transition — Mandatory Pre-Dispatch (NOT a Hook)

Before every `task()` call for the next pipeline step, the orchestrator MUST:

1. Read the previous step's hand-off contract YAML
2. Call `solve check` with a contract-validation theorem:
   - `gate.gate_result == PASS` — FAIL or BLOCKED prevents transition SAT
   - `artifact_hashes` non-empty for every behavioral SC in `evidence_types[]` — missing evidence prevents SAT
   - `verdict_source` matches the dispatch table's `auditor_type` for that step — type mismatch prevents SAT
   - No `evidence_types[].declared_type != actual_type` — EVIDENCE_TYPE_MISMATCH prevents SAT
3. Only if `solve check` returns SAT: proceed to next `task()` call
4. If UNSAT: orchestrator MUST NOT dispatch. Routes to researcher sub-agent with unsat core as context.

This is NOT a commit hook (bypassable). It is a pre-dispatch gate in the orchestrator's task() loop. No git hooks, no bypass surface.

### Part 3: Verifier Identity at Dispatch Table Level

Every pipeline dispatch table row in every relevant SKILL.md MUST include an `auditor_type` field:

```yaml
tasks:
  - step: spec-audit
    dispatch: sub-task
    auditor_type: dual_cross_family
    subagent_type: from_resolve
```

`auditor_type` maps to `resolve-models` result contract. The orchestrator sets `verdict_source` to the dispatched sub-agent's model family. Z3 rejects SAT if `verdict_source` doesn't match the table's `auditor_type`.

This catches #1019/#1020 at structural level: dispatching `general` to step 10 produces verdict_source mismatch detected by Z3, not discovered downstream.

### Part 4: Contract Schema Linter (Pre-Dispatch Gate)

The `skildeck contract lint` subcommand validates every contract YAML against the schema. Runs as a pre-dispatch gate in the orchestrator's loop (same call as Z3 check):

- All required fields present (`gate.gate_result`, `gate.verdict_source`, `gate.artifact_hashes`)
- `gate_result` is PASS/FAIL/BLOCKED (not null, "advisory", or "warning")
- `artifact_hashes` paths resolve to existing files
- Every behavioral SC in `evidence_types[]` has a corresponding `artifact_hashes` entry
- No evidence type mismatch (declared vs actual)

Non-zero exit = no dispatch. Same bypass surface as Z3 gate (none — it's in the orchestrator loop, not a hook).

## Supersession Map

### Fully Superseded (Close) — 5 Issues

| Issue | Why Moot |
|-------|----------|
| #1023 | Orchestrator verdict-softening — `gate_result: FAIL` in contract schema is structurally un-ignorable; Z3 rejects transition before next dispatch |
| #1027 | No halt between sub-steps — Z3 gate enforces halt on every transition; UNSAT = no dispatch |
| #1021 | Z3 never executed — mandatory Z3 gate on every hand-off, no opt-out path |
| #1194 | Work state file gate removal — replaced by contract schema artifact hashes in hand-off contract |
| #951 | Solve contract/state integration — subsumed by standardized contract schema + Z3 gate wiring |

### Partially Superseded (Revise Scope) — 8 Issues

| Issue | Remaining Scope |
|-------|----------------|
| #1198 | Retitle to "Contract schema → Z3 state wiring" (state transition wiring remains; the evidence-gating is now part of holistic schema) |
| #909 | 14-step pipeline structure unchanged; enforcement fields added to per-step contracts |
| #955 | Standard contract schema replaces need for per-skill custom contracts; skill-specific fields may remain |
| #954 | Frugal contract size limits still apply; enforcement fields add ~5 fields to minimum contract |
| #1213 | Merge into `skildeck contract lint` — dispatch table validation and contract schema linting are one tool |
| #1019/1020 | Dispatch routing fix still needed at source (dispatch table assignment); verifier identity catches it downstream but correct assignment is independent |
| #1013 | Artifact hash protects evidence at hand-off (can't delete pinned files while contract active); deletion-at-cleanup remains separate |
| #912 | SC coherence checking remains pre-dispatch; contract schema gates on evidence types, doesn't replace coherence analysis |

### Untouched — 10 Issues

| Issue | Reason |
|-------|--------|
| #936 | Deterministic consensus gate — upstream computation tool, not a hand-off contract |
| #1189 | Cross-reference invalidation in screen-issue-gate2 — pre-pipeline screening gate, not hand-off contract |
| #1210 | Trigger dispatch tables — separate concern (SKILL.md routing triggers, not hand-off contracts) |
| #1199 | DISPATCH_GATE protocol extraction — separate concern (task() prompt discipline, not contract schema) |
| #1214 | Plan writer dispatch table format — plan-level concern, not pipeline hand-off |
| #952 | Solve tool enforcement tests — still needed for new Z3 gate wiring |
| #1016 | Pre-commit Gate 4 checkpoint blocks — unrelated pre-commit hook issue |
| #1011 | Cleanup sub-agent scope — sub-agent scope boundary, not contract enforcement |
| #1064 | Writing-plans consumer awareness — spec→plan metadata consumption, distinct from pipeline hand-off contracts |
| #920 | Sycophancy audit — auditor-facing text audit, not contract enforcement |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Hand-off contract standard schema defined in pipeline SKILL.md and enforced | `string + semantic` | grep for schema fields in skill files + sub-agent read |
| SC-2 | Z3 gate transition mandatory before every task() dispatch | `behavioral` | opencode-cli run: stderr assertion for solve check call |
| SC-3 | gate_result = FAIL prevents task() dispatch (Z3 UNSAT) | `behavioral` | opencode-cli run: FAIL contract → Z3 rejects SAT → no dispatch |
| SC-4 | gate_result = BLOCKED prevents task() dispatch (Z3 UNSAT) | `behavioral` | opencode-cli run: BLOCKED contract → Z3 rejects SAT → no dispatch |
| SC-5 | Missing artifact_hashes for behavioral SC prevents dispatch | `behavioral` | opencode-cli run: empty hashes → Z3 rejects SAT |
| SC-6 | verdict_source mismatch against dispatch table auditor_type prevents dispatch | `behavioral` | opencode-cli run: wrong auditor type → Z3 rejects SAT |
| SC-7 | Evidence type mismatch detected at hand-off boundary (declared !== actual) | `behavioral` | opencode-cli run: EVIDENCE_TYPE_MISMATCH → contract FAIL |
| SC-8 | DONE_WITH_CONCERNS removed as valid pipeline step status | `string` | grep for absence of DONE_WITH_CONCERNS in pipeline task files |
| SC-9 | Contract schema linter runs as pre-dispatch gate, not hook | `string` | grep for linter invocation in orchestrator task() loop |
| SC-10 | All dispatch table rows have auditor_type field | `string` | grep for auditor_type in all pipeline-relevant SKILL.md files |
| SC-11 | Superseded issues closed with supersession body update | `structural` | GitHub issue state closed, no noise comments |
| SC-12 | Partially superseded issue bodies updated with revised scope | `structural` | GitHub issue body revised with reduced-scope summary |
| SC-13 | Artifact-hash pinned files protected from deletion while contract is active | `behavioral` | opencode-cli run: tool refuses deletion of hash-pinned file before gate_result read |
| SC-14 | Pre-dispatch gate is NOT a git hook — no pre-commit, no bypass surface | `string` | grep for absence of gate in pre-commit hook; grep for presence in pipeline-executor |

## Non-Goals

- Not changing the 14-step pipeline structure (#909 structure remains)
- Not replacing deterministic consensus gate (#936 — separate upstream tool)
- Not replacing cross-reference invalidation (#1189 — separate pre-pipeline screening gate)
- Not replacing trigger dispatch tables (#1210 is separate)
- Not replacing DISPATCH_GATE protocol (#1199 is separate)
- Not replacing plan writer dispatch table format (#1214 is separate)
- Not a commit hook — pre-dispatch gate only, zero git hooks involved
- Not replacing sycophancy audit (#920 remains independent)
- Not replacing evidence artifact cleanup rules (#1013 deletion-at-cleanup remains separate)
- Not replacing SC coherence checking (#912 coherence analysis remains pre-dispatch)

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)