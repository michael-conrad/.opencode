# Plan Input Verification Ledger — Issue 2314

Verified once at plan-creation entry; all subsequent plan composition reads THIS ledger, not the sources.

## Issue State

- Issue number: 2314
- Spec: `.opencode/.issues/2314/spec.md` — exists, status open, remote_issue 2314
- Local labels (`issue.yaml`, canonical): `approved-for-for_pr` (single label as of verification)
- Spec defect: spec-creation → implementation dispatch can bypass writing-plans; fix is an enforcement gate checking local plan.md existence before allowing implementation dispatch; BLOCK with `PLAN_MISSING` when absent

## SC List (source: structure.yaml — sc-summary.yaml absent; substitution disclosed in structure artifact)

| SC | Statement (condensed) | Evidence Type | Phase |
|----|----------------------|---------------|-------|
| SC-1 | Gate exists at spec-creation → implementation dispatch boundary checking plan.md existence before allowing dispatch | structural | phase-1 |
| SC-2 | When no plan exists, implementation dispatch is BLOCKED with PLAN_MISSING | behavioral | phase-1 |
| SC-3 | When plan.md exists at expected path, dispatch proceeds without false-positive block | behavioral | phase-1 |
| SC-4 | Behavioral enforcement test demonstrates gate blocks plan-less dispatch and permits plan-bearing dispatch | behavioral | phase-2 |

## Structure Artifact Mappings

- phase-1 `dispatch-gate-logic`: SC-1, SC-2, SC-3 (triplet colocation verified — RED/GREEN/COMMIT all in phase-1)
- phase-2 `behavioral-enforcement`: SC-4
- DAG: phase-1 → phase-2 (SC-4 GREEN behavioral run requires SC-1/SC-2/SC-3 gate outputs committed); intra-phase ordering SC-1 → SC-2/SC-3
- Cross-phase dependency check: verified — no RED depends on a later phase's output

## Deck Change Surface (SC-1 GREEN)

- `.opencode/skills/spec-creation/SKILL.md` — gate routing entry at the spec-creation → implementation dispatch boundary
- `.opencode/skills/executing-plans/SKILL.md` — gate routing entry
- `.opencode/guidelines/000-critical-rules.md` — CRITICAL VIOLATION entry (PLAN_MISSING)
- PLAN_MISSING vocabulary registration — canonical dispatch-vocabulary table at `.opencode/reference/skill-card-description-standards.md`

## Behavioral Run Surface

- Instrument: `bash .opencode/tests-v2/with-test-home opencode run '<message>'` (timeout ≥600s) for SC-2/SC-3
- Phase-2 scenario registered in `.opencode/tests-v2/test-enforcement.sh --scenario <name>` (timeout ≥600s)
- Behavioral evidence = agent actions in stderr; structural/grep substitution prohibited

## CLI Surface Flags Needed

- `./.opencode/tools/local-issues update .opencode#2314 --labels approved-for-for_pr,spec-cleared` — local-issues `update` REPLACES the entire labels array, so every label write must carry all existing labels plus the new one

## Authorization Context

- Label `approved-for-for_pr` ⇒ authorization_scope `for_pr`, pr_strategy `stacked`
