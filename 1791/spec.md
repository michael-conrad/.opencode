## Problem

The plan writer (writing-plans skill) generates plans that treat behavioral test scripts as file-creation deliverables. When a spec has SCs with `evidence_type: behavioral`, the generated plan's exit criteria check file existence, annotations present, and exit codes — but never include model-execution-and-evaluation steps.

This means every plan for a spec with behavioral SCs is structurally incapable of verifying behavior. The plan exit criteria pass based on structural properties alone, and no downstream gate catches the gap because the verify.md task also accepts file existence as evidence.

## Root Cause

The writing-plans create/validate tasks have no rule requiring model-execution-and-evaluation steps for behavioral SCs. The plan generation templates treat "test file exists" and "script exits 0" as sufficient verification — conflating artifact generation with behavioral evidence.

This was discovered during root cause analysis of #1789 (VbC verify task procedural gap). Both issues share a common root cause (structural evidence accepted for behavioral SCs) but have different fix targets: #1789 fixes the verification gate (consumer side), this issue fixes the plan writer (producer side).

## Affected Files

- `skills/writing-plans/tasks/create.md` — Plan generation template must include model-execution-and-evaluation steps for behavioral SCs
- `skills/writing-plans/tasks/validate.md` — Plan validation must reject structural-only exit criteria for behavioral SCs

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | writing-plans create task generates phase exit criteria for behavioral SCs that include both `behavior_run` artifact generation AND `behavioral-test-evaluation` clean-room dispatch steps | `string` |
| SC-2 | writing-plans validate task rejects plan exit criteria that use structural-only evidence (file exists, annotations present, exit 0) for behavioral SCs, using the plan's evidence type metadata to distinguish behavioral SCs from structural ones | `string` |
| SC-3 | Generated plan's VbC section for behavioral SCs includes a mandatory gate: after artifact generation, dispatch `behavioral-test-evaluation` before allowing PASS verdict | `string` |
| SC-4 | Generated plan includes evidence type metadata annotation for each SC in its exit criteria section (e.g., `evidence_type: behavioral`), enabling the validate task to distinguish behavioral SCs from structural ones | `string` |

## Constraints

- The fix must be in the plan generation logic (create/validate tasks), not in downstream verification gates
- The behavioral-test-evaluation task itself must NOT be modified — only the steps that dispatch it
- Existing plans with structural-only exit criteria are NOT grandfathered; they must be regenerated or fixed
- The generated plan must carry evidence type metadata for each SC in its exit criteria section (SC-4 is a prerequisite for SC-2)

## Dependencies

- #1789 (consumer-side fix) — independent fix, no structural dependency, but both are needed to close the systemic behavioral verification gap
- #1790 (test prompt quality) — independent

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)