## Problem

Issue #474 (Phase 5: Enforcement Tests) was closed as superseded. The test paradigm has shifted to the **Artifact-Only Generator Paradigm** (`.opencode/tests/AGENTS.md`), the deprecated skills are deleted, and the adversarial-audit architecture has evolved through #1555, #1567, #1641, #1407, #1406, #1379, and #1365. The core need — behavioral enforcement tests that verify the unified audit architecture works correctly — remains unaddressed.

## What must be tested

### Core audit dispatch (4 scenarios)

| Scenario | What it verifies |
|----------|-----------------|
| Unified invocation | `skill({name: "adversarial-audit"})` dispatches correctly; `--task spec-audit` routes to spec-audit task |
| Cleanroom dispatch | Scan sub-agent receives NO verifier context, no preloaded findings, no orchestrator reasoning |
| Consensus gates | PASS (both auditors agree), FAIL (any auditor returns FAIL), DISAGREE (auditors diverge → revision options presented) |
| Multi-type invocation | `--type spec-audit,plan-fidelity` produces dual audit result with separate verdicts |

### Pipeline touchpoints (7 scenarios)

Verify that each pipeline skill invokes adversarial-audit at the correct stage with proper `audit_phase` context:

| Touchpoint | Pipeline Skill | Audit Task | audit_phase |
|------------|---------------|------------|-------------|
| 1 | spec-creation | spec-audit | spec_creation |
| 2 | writing-plans | plan-fidelity + concern-separation | plan_creation |
| 3 | issue-operations | concern-separation | sub_issue_creation |
| 4 | implementation-pipeline | coherence-extraction + coherence-maintenance | coherence_gate |
| 5 | verification-before-completion | cross-validate | implementation_verification |
| 6 | pr-creation-workflow | spec-summary | pr_creation |
| 7 | git-workflow | closure-verification | post_merge |

### Cross-validate behavior (2 scenarios)

| Scenario | What it verifies |
|----------|-----------------|
| Evidence type gate | Cross-validate rejects structural evidence for behavioral SCs with EVIDENCE_TYPE_MISMATCH (per #1567) |
| Result contract | Cross-validate returns frugal contract (status, finding_summary, artifact_path, blocker_reason) — no full evidence in contract |

### Bidirectional finding handling (1 scenario)

Plan-spec mismatch detected during audit triggers revision prompt with options, not silent correction.

## What is NOT tested (explicitly excluded)

- **Deprecated skill redirect** — deprecated skills are already deleted (Phase 2 of #469 complete)
- **Content-verification tests** — these exist separately under `--tag content-verification adversarial-audit`
- **Test harness infrastructure** — covered by #1307
- **Semantic audit depth dimensions** — covered by #1641

## Test format

Every test script MUST follow the Artifact-Only Generator Paradigm per `.opencode/tests/AGENTS.md`:

```bash
#!/bin/bash
# Behavioral test: <scenario-name>
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="<scenario-name>"
SCENARIO_PROMPT="<prompt>"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
```

- No `assert_*` calls
- No `OVERALL_RESULT`
- No `run-all.sh` (explicitly forbidden)
- Flat in `tests/behaviors/` — no `scenarios/` subdirectory
- File naming: issue-number-prefixed (e.g., `NEW-sc1-adversarial-audit-unified-invocation.sh`)

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | 14 behavioral test scripts exist in `tests/behaviors/` following Artifact-Only Generator format | Structural | `ls tests/behaviors/NEW-sc*-adversarial-audit-*.sh \| wc -l` returns 14 |
| SC-2 | Each script has the mandatory cross-reference header | String | `grep -c "Artifact-Only Generator" tests/behaviors/NEW-sc*-adversarial-audit-*.sh` returns 14 |
| SC-3 | Each script uses `behavior_run` — no raw `with-test-home` or `opencode-cli run` | String | `grep -L "behavior_run" tests/behaviors/NEW-sc*-adversarial-audit-*.sh` returns empty |
| SC-4 | Each script exits 0 unconditionally | String | `grep "exit 0" tests/behaviors/NEW-sc*-adversarial-audit-*.sh` returns 14 matches |
| SC-5 | Unified invocation: `behavior_run` with adversarial-audit prompt produces stderr showing skill dispatch | Behavioral | Clean-room semantic inspector: agent dispatched adversarial-audit skill |
| SC-6 | Cleanroom dispatch: scan sub-agent receives no verifier context | Behavioral | Clean-room semantic inspector: scan sub-agent context excludes verifier findings |
| SC-7 | Consensus gates: PASS/FAIL/DISAGREE all produce correct verdict routing | Behavioral | Clean-room semantic inspector: PASS confirms, FAIL flags, DISAGREE presents options |
| SC-8 | Multi-type invocation produces dual audit result | Behavioral | Clean-room semantic inspector: both spec-audit and plan-fidelity verdicts present |
| SC-9 | All 7 pipeline touchpoints invoke adversarial-audit at correct stage | Behavioral | Clean-room semantic inspector: each pipeline skill dispatches audit with correct audit_phase |
| SC-10 | Cross-validate evidence type gate rejects structural evidence for behavioral SCs | Behavioral | Clean-room semantic inspector: EVIDENCE_TYPE_MISMATCH returned |
| SC-11 | Cross-validate returns frugal result contract | Behavioral | Clean-room semantic inspector: contract has status/finding_summary/artifact_path only |
| SC-12 | Bidirectional finding presents revision options, not silent correction | Behavioral | Clean-room semantic inspector: revision options presented on plan-spec mismatch |

## Dependencies

- #1307 (test harness restructuring) — should be resolved first or tests written to work with both old and new `behavior_run`
- #1555, #1567, #1641 — architecture refinements that affect what tests verify; tests should account for current state

## Files Affected

| File | Action |
|------|--------|
| `tests/behaviors/NEW-sc1-adversarial-audit-unified-invocation.sh` | Create |
| `tests/behaviors/NEW-sc2-adversarial-audit-cleanroom-dispatch.sh` | Create |
| `tests/behaviors/NEW-sc3-adversarial-audit-consensus-pass.sh` | Create |
| `tests/behaviors/NEW-sc4-adversarial-audit-consensus-fail.sh` | Create |
| `tests/behaviors/NEW-sc5-adversarial-audit-consensus-disagree.sh` | Create |
| `tests/behaviors/NEW-sc6-adversarial-audit-multi-type.sh` | Create |
| `tests/behaviors/NEW-sc7-adversarial-audit-touchpoint-spec-creation.sh` | Create |
| `tests/behaviors/NEW-sc8-adversarial-audit-touchpoint-writing-plans.sh` | Create |
| `tests/behaviors/NEW-sc9-adversarial-audit-touchpoint-issue-operations.sh` | Create |
| `tests/behaviors/NEW-sc10-adversarial-audit-touchpoint-implementation-pipeline.sh` | Create |
| `tests/behaviors/NEW-sc11-adversarial-audit-touchpoint-verification-before-completion.sh` | Create |
| `tests/behaviors/NEW-sc12-adversarial-audit-touchpoint-pr-creation.sh` | Create |
| `tests/behaviors/NEW-sc13-adversarial-audit-touchpoint-git-workflow.sh` | Create |
| `tests/behaviors/NEW-sc14-adversarial-audit-bidirectional-finding.sh` | Create |

## What could go wrong

- **Risk-1:** #1307 changes `behavior_run` signature — tests must be updated if written before #1307 merges
- **Risk-2:** Behavioral test timeout on consensus DISAGREE (requires dual auditor dispatch) — increase `BEHAVIOR_TIMEOUT`
- **Risk-3:** Pipeline touchpoint tests depend on full pipeline execution — may need scoped prompts that trigger only the relevant touchpoint
- **Risk-4:** Cross-validate evidence type gate behavior may change with #1567 resolution — verify current behavior before writing test

🤖 OpenCode (deepseek-v4-flash)