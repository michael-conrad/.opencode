# [SPEC-FIX] VbC verify task procedural gap — behavioral SC evidence is verified by file existence, not clean-room evaluation

## Problem

The VbC verify task's procedural workflow accepts file existence as sufficient evidence for behavioral SCs. The verify.md Steps 1-4 don't include a mandatory dispatch of `behavioral-test-evaluation`. The `behavioral-test-evaluation` task is optional in practice because nothing forces the orchestrator to dispatch it.

This is the consumer side of a systemic gap. The producer side (plan writer generating structural-only exit criteria for behavioral SCs) was tracked in #1791 and is now closed/completed.

## Root Cause Analysis

### 1. verify.md (VbC task analysis)
Steps 1-4 at lines 120-152 have no `behavioral-test-evaluation` dispatch. Strong prohibitions exist at lines 174-219 but are structurally disconnected from the workflow — they are declarative admonishments, not procedural gates.

### 2. Guideline enforcement (guideline analysis)
`critical-rules-047` (VbC Fabricated PASS), `critical-rules-060` (Functional/Behavioral Test Substitution Prohibition), and `EVIDENCE_TYPE_MISMATCH` rules all exist in guidelines but the VbC verify task doesn't enforce them in its procedural flow. The rules are correct; the workflow that should invoke them is incomplete.

### 3. Related prior work
- **#765** (Structural Evidence Must FAIL) — closed/completed. Added evidence type classification and structural-evidence=FAIL rules to verify.md. This is the classification layer; #1789 adds the procedural dispatch layer.
- **#767** (Dispatch Chain Enforcement) — closed/completed. Added Step 0.5 dispatch chain compliance check to verify.md. No conflict with #1789.
- **#1791** (Producer side — plan writer) — closed/completed. Fixed the plan writer to generate behavioral-test-evaluation steps for behavioral SCs.

### Root Cause
verify.md has no procedural step to dispatch behavioral-test-evaluation. The behavioral-test-evaluation task exists but is optional in practice — nothing in the verify workflow forces the orchestrator to call it before claiming PASS for behavioral SCs.

## Relevance Assessment

**Spec is still relevant.** #1791 (producer side) is closed, but #1789 (consumer side) remains open. The verify.md Steps 1-4 still lack the behavioral-test-evaluation dispatch step. The spec intent — adding a mandatory procedural gate in the verify workflow — is unchanged and unaddressed.

## Conflict and Supersession Analysis

| Check | Result |
|-------|--------|
| **Conflicts with other open specs** | None. #765 (evidence type classification) and #767 (dispatch chain) are closed. #675 (infrastructure references) is complementary — it adds infrastructure references to verify.md, while #1789 adds the dispatch step. They modify different parts of verify.md and can be sequenced. |
| **Superseded by another spec** | No. No open spec covers adding behavioral-test-evaluation dispatch to verify.md Steps 1-4. |
| **Supersedes other specs** | No. #1789 is a narrow procedural fix. |
| **Cross-cutting concerns** | #675 (Weave behavioral test infrastructure references) also modifies verify.md. The dispatch step added by #1789 should reference the existing behavioral test infrastructure (helpers.sh, behavior_run, with-test-home) that #675 aims to document. These specs should be sequenced: #1789 adds the dispatch step, #675 adds the infrastructure reference within that step. |

## Affected Files

- `skills/verification-before-completion/tasks/verify.md` — Steps 1-4 must include mandatory dispatch of `behavioral-test-evaluation` for behavioral SCs
- `skills/verification-before-completion/SKILL.md` — Operating Protocol must reference the verify task's behavioral-test-evaluation step instead of being a separate note

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | verify.md Step 2 MUST check the SC evidence type: for behavioral SCs, dispatch `behavioral-test-evaluation`; for non-behavioral SCs, check artifacts directory. Step 2 MUST NOT check artifacts directory for behavioral SCs. | `string` |
| SC-2 | verify.md workflow includes a mandatory gate after artifact collection: for any behavioral SC, `behavioral-test-evaluation` MUST be dispatched before PASS can be claimed | `string` |
| SC-3 | SKILL.md Operating Protocol §7 (behavioral test evaluation) references verify.md's behavioral-test-evaluation step as a mandatory gate, not a separate optional dispatch | `string` |
| SC-4 | Behavioral test verifying: when verify.md processes behavioral SCs, it dispatches `behavioral-test-evaluation` (not file-existence check) | `behavioral` |
| SC-5 | Behavioral test verifying: agent does NOT report PASS for behavioral SC based on artifact file existence alone | `behavioral` |

## Enforcement Gate

ALL success criteria MUST pass before implementation is considered complete. If any SC fails:
- For `string` SCs (SC-1, SC-2, SC-3): remediate the procedural text in the affected file and re-verify
- For `behavioral` SCs (SC-4, SC-5): remediate the agent behavior, re-run the behavioral test, and re-verify via clean-room evaluation
- If remediation fails after 2+ attempts: report BLOCKED with all failure evidence

## Documentation Sources

| File | Path | Purpose |
|------|------|---------|
| verify.md | `skills/verification-before-completion/tasks/verify.md` | Primary target — add behavioral-test-evaluation dispatch to Steps 1-4 |
| SKILL.md | `skills/verification-before-completion/SKILL.md` | Update Operating Protocol §7 to reference verify.md's mandatory gate |
| behavioral-test-evaluation.md | `skills/verification-before-completion/tasks/behavioral-test-evaluation.md` | Reference only — NOT to be modified |

## Constraints

- Do NOT modify the `behavioral-test-evaluation` task itself — only the verify.md workflow that dispatches it
- All existing reference sections (lines 170-220, 320-350 in verify.md) with strong prohibitions must be preserved
- The fix must be structural (procedural steps) not just declarative (more admonishments)
- The behavioral-test-evaluation dispatch step added to verify.md SHOULD reference the existing behavioral test infrastructure (helpers.sh, behavior_run, with-test-home) per #675's intent, but #675 is a separate spec — do not block on it

## Dependencies

- #1791 (producer side — plan writer) — **CLOSED/COMPLETED**. No dependency; the producer side is already fixed.
- #1790 (test prompt quality) — independent, still open.
- #675 (Weave behavioral test infrastructure references) — **cross-cutting concern**. Modifies the same verify.md file. Should be sequenced after #1789 to integrate infrastructure references into the new dispatch step.

## Cross-Cutting Concerns

| Issue | Relationship | Action Required |
|-------|-------------|-----------------|
| #675 | Also modifies verify.md to add behavioral test infrastructure references | Sequence after #1789. The dispatch step added by #1789 should reference the infrastructure documented by #675. |
| #1532 | verification-before-completion Skill Description Compliance | Independent — description format, not procedural logic. No action needed. |
| #1790 | Test prompt quality for behavioral tests | Independent — test infrastructure, not verify.md workflow. No action needed. |

## Splitting/Combining Assessment

| Question | Answer |
|----------|--------|
| Should #1789 be split? | No. Single concern: add behavioral-test-evaluation dispatch to verify.md. |
| Should #1789 be combined with #675? | No. Different intents: #1789 adds a procedural dispatch step; #675 adds infrastructure references. They modify different parts of verify.md and should remain separate specs sequenced appropriately. |
| Should any other issue be split/combined? | No. All related issues have distinct concerns. |

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
