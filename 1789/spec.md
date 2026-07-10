# [SPEC-FIX] VbC verify task procedural gap — behavioral SC evidence is verified by file existence, not clean-room evaluation

## Problem

The VbC verify task's procedural workflow accepts file existence as sufficient evidence for behavioral SCs. The verify.md Steps 1-4 don't include a mandatory dispatch of `behavioral-test-evaluation`. The `behavioral-test-evaluation` task is optional in practice because nothing forces the orchestrator to dispatch it.

This is the consumer side of a systemic gap. The producer side (plan writer generating structural-only exit criteria for behavioral SCs) was tracked in #1791 and is now closed/completed.

## Root Cause Analysis

### 1. verify.md (VbC task analysis)

Steps 1-4 at lines 120-152 have no `behavioral-test-evaluation` dispatch. Strong prohibitions exist at lines 174-219 but are structurally disconnected from the workflow — they are declarative admonishments, not procedural gates.

Current Step 2 (Check for Evidence, lines 126-130):
```
- Review issue comments for evidence
- Check `{project_root}/tmp/{issue-N}/artifacts/` for verification artifacts
- Verify evidence matches criteria
```

This step checks the artifacts directory for ALL SCs — including behavioral SCs. For behavioral SCs, checking the artifacts directory is the wrong action. The correct action is to dispatch `behavioral-test-evaluation` to a clean-room sub-agent that evaluates the artifacts. The artifacts directory check is only valid for non-behavioral SCs.

### 2. Guideline enforcement (guideline analysis)

`critical-rules-047` (VbC Fabricated PASS), `critical-rules-060` (Functional/Behavioral Test Substitution Prohibition), and `EVIDENCE_TYPE_MISMATCH` rules all exist in guidelines but the VbC verify task doesn't enforce them in its procedural flow. The rules are correct; the workflow that should invoke them is incomplete.

### 3. Related prior work

- **#765** (Structural Evidence Must FAIL) — closed/completed. Added evidence type classification and structural-evidence=FAIL rules to verify.md. This is the classification layer; #1789 adds the procedural dispatch layer.
- **#767** (Dispatch Chain Enforcement) — closed/completed. Added Step 0.5 dispatch chain compliance check to verify.md. No conflict with #1789.
- **#1791** (Producer side — plan writer) — closed/completed. Fixed the plan writer to generate behavioral-test-evaluation steps for behavioral SCs.
- **#836** (Runtime-Behavioral Evidence Classification Gate) — closed/completed. Added classification infrastructure (uplift rules, coverage completeness gate at Step 0.75, anti-evasion rules) to verify.md and 38 other files. **Did NOT add the behavioral-test-evaluation dispatch step to Steps 1-4.** The classification infrastructure exists but the procedural dispatch step is still missing. #1789 is the remaining gap after #836.

### Root Cause

verify.md has no procedural step to dispatch behavioral-test-evaluation. The behavioral-test-evaluation task exists but is optional in practice — nothing in the verify workflow forces the orchestrator to call it before claiming PASS for behavioral SCs. #836 added the classification infrastructure (what to check) but not the dispatch step (how to act on the classification).

## Relevance Assessment

**Spec is still relevant.** #1791 (producer side) and #836 (classification infrastructure) are closed, but #1789 (consumer-side procedural dispatch) remains open. The verify.md Steps 1-4 still lack the behavioral-test-evaluation dispatch step. The spec intent — adding a mandatory procedural gate in the verify workflow — is unchanged and unaddressed.

## Conflict and Supersession Analysis

| Check | Result |
|-------|--------|
| **Conflicts with other open specs** | None. #765 (evidence type classification), #767 (dispatch chain), and #836 (classification gate) are closed. #675 (infrastructure references) is complementary — it adds infrastructure references to verify.md, while #1789 adds the dispatch step. They modify different parts of verify.md and can be sequenced. |
| **Superseded by another spec** | No. No open spec covers adding behavioral-test-evaluation dispatch to verify.md Steps 1-4. #836 added classification infrastructure but not the dispatch step. |
| **Supersedes other specs** | No. #1789 is a narrow procedural fix. |
| **Cross-cutting concerns** | #675 (Weave behavioral test infrastructure references) also modifies verify.md. The dispatch step added by #1789 should reference the existing behavioral test infrastructure (helpers.sh, behavior_run, with-test-home) that #675 aims to document. These specs should be sequenced: #1789 adds the dispatch step, #675 adds the infrastructure reference within that step. |

## Affected Files

- `skills/verification-before-completion/tasks/verify.md` — Steps 1-4 must include mandatory dispatch of `behavioral-test-evaluation` for behavioral SCs. Specifically, Step 2 (Check for Evidence) must be split: for behavioral SCs, dispatch `behavioral-test-evaluation`; for non-behavioral SCs, check artifacts directory.
- `skills/verification-before-completion/SKILL.md` — Operating Protocol must reference the verify task's behavioral-test-evaluation step instead of being a separate note. (Currently Operating Protocol §7 in operating-protocol.md is correct but lives in a separate file — verify.md's workflow should be the canonical source.)

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | verify.md Step 2 MUST check the SC evidence type: for behavioral SCs, dispatch `behavioral-test-evaluation`; for non-behavioral SCs, check artifacts directory. Step 2 MUST NOT check artifacts directory for behavioral SCs. | `string` | grep for evidence type check + behavioral-test-evaluation dispatch in Step 2 |
| SC-2 | verify.md workflow includes a mandatory gate after artifact collection: for any behavioral SC, `behavioral-test-evaluation` MUST be dispatched before PASS can be claimed | `string` | grep for mandatory gate text referencing behavioral-test-evaluation dispatch |
| SC-3 | SKILL.md Operating Protocol §7 (behavioral test evaluation) references verify.md's behavioral-test-evaluation step as a mandatory gate, not a separate optional dispatch | `string` | grep for cross-reference in operating-protocol.md |
| SC-4 | Behavioral test verifying: when verify.md processes behavioral SCs, it dispatches `behavioral-test-evaluation` (not file-existence check) | `behavioral` | `opencode-cli run` with behavioral test prompt → stderr shows `behavioral-test-evaluation` dispatch |
| SC-5 | Behavioral test verifying: agent does NOT report PASS for behavioral SC based on artifact file existence alone | `behavioral` | `opencode-cli run` with behavioral test prompt → stderr shows clean-room evaluation dispatch, not file-existence check |

## Enforcement Gate — SC_FAIL_ALL Clause

**ALL success criteria MUST pass before implementation is considered complete. There is NO exception, NO deferral, NO partial credit.**

- If ANY SC fails, ALL SCs are marked as FAIL. The PR MUST be immediately rejected and trashed as defective and unusable.
- Skipping, deferring, or otherwise attempting to bypass an SC marks ALL SCs as FAIL.
- A skipped SC is indistinguishable from a failed SC — both produce the same result: the implementation is not complete.
- The only valid path from FAIL is remediation: diagnose the root cause, fix it, re-verify all SCs from scratch, and confirm 100% clean PASS.
- If remediation fails after 2+ attempts: report BLOCKED with all failure evidence. Do NOT proceed past FAIL.

### Per-SC Remediation

| SC Type | Remediation Action |
|---------|-------------------|
| `string` SCs (SC-1, SC-2, SC-3) | Remediate the procedural text in the affected file and re-verify via grep |
| `behavioral` SCs (SC-4, SC-5) | Remediate the agent behavior, re-run the behavioral test, and re-verify via clean-room evaluation |

## Documentation Sources

| File | Path | Purpose |
|------|------|---------|
| verify.md | `skills/verification-before-completion/tasks/verify.md` | Primary target — add behavioral-test-evaluation dispatch to Steps 1-4 |
| SKILL.md | `skills/verification-before-completion/SKILL.md` | Update Operating Protocol §7 to reference verify.md's mandatory gate |
| operating-protocol.md | `skills/verification-before-completion/tasks/operating-protocol.md` | Update §7 to cross-reference verify.md's procedural step |
| behavioral-test-evaluation.md | `skills/verification-before-completion/tasks/behavioral-test-evaluation.md` | Reference only — NOT to be modified |

## Non-Goals

- Changes to the `behavioral-test-evaluation` task itself — only the verify.md workflow that dispatches it
- Changes to any file beyond verify.md and SKILL.md/operating-protocol.md
- Creating or modifying behavioral test scripts
- Changes to `with-test-home`, `helpers.sh`, or any test infrastructure file
- Adding infrastructure references (helpers.sh, behavior_run, with-test-home) — that is #675's scope
- Dark prose reference card, goal hijacking, confirmshaming weave, or tier recalibration (separate specs)

## Constraints

- Do NOT modify the `behavioral-test-evaluation` task itself — only the verify.md workflow that dispatches it
- All existing reference sections (lines 170-220, 320-350 in verify.md) with strong prohibitions must be preserved
- The fix must be structural (procedural steps) not just declarative (more admonishments)
- The behavioral-test-evaluation dispatch step added to verify.md SHOULD reference the existing behavioral test infrastructure (helpers.sh, behavior_run, with-test-home) per #675's intent, but #675 is a separate spec — do not block on it
- The dispatch step must be placed between Step 2 (Check for Evidence) and Step 2a (Todowrite Cleanup), or as a substep within Step 2 that branches on evidence type
- Do NOT add blame-adjacent language ("you chose to skip", "cutting corners") — use neutral procedural language
- Do NOT add tool-control instructions (line numbers, copy-paste templates) — let the implementing sub-agent discover scope independently

## Interdependency Map

### Forward Dependencies (issues that depend on #1789)

| Issue | Relationship | Dependency Type | Action Required |
|-------|-------------|-----------------|-----------------|
| #675 | Weave behavioral test infrastructure references into verify.md, start.md, checklist.md | **SEQUENCE** — #675 modifies the same verify.md file. The behavioral-test-evaluation dispatch step added by #1789 must exist before #675 can weave infrastructure references into it. | Implement #1789 first, then #675. The dispatch step should reference the infrastructure (helpers.sh, behavior_run, with-test-home) that #675 documents. |
| #1790 | Fix test prompts in vbfc-behavioral-evidence-distinction.sh and structural-evidence-fail.sh | **INDEPENDENT** — #1790 modifies behavioral test scripts, not verify.md. No file conflict. | No sequencing constraint. Can be implemented in any order. |
| #1532 | Fix verification-before-completion SKILL.md description | **FILE-OVERLAP** — #1532 modifies the SKILL.md frontmatter description field; #1789 modifies SKILL.md Operating Protocol §7. Different sections of the same file. | Implement in any order, but both must be aware of each other's changes to avoid merge conflicts in SKILL.md. |

### Backward Dependencies (issues that #1789 depends on)

| Issue | Relationship | Dependency Type | Status |
|-------|-------------|-----------------|--------|
| #1791 | Producer side — plan writer generates behavioral-test-evaluation steps | **CLOSED/COMPLETED** — was the counterpart to #1789. No remaining dependency. | ✅ Closed |
| #765 | Structural Evidence Must FAIL — evidence type classification in verify.md | **CLOSED/COMPLETED** — added the classification layer that #1789's dispatch step operationalizes. | ✅ Closed |
| #767 | Dispatch Chain Enforcement — Step 0.5 in verify.md | **CLOSED/COMPLETED** — added dispatch log check that #1789's step integrates with. | ✅ Closed |
| #836 | Runtime-Behavioral Evidence Classification Gate | **CLOSED/COMPLETED** — added classification infrastructure (Step 0.75, uplift rules, anti-evasion) to verify.md. #1789 builds on this by adding the procedural dispatch step. | ✅ Closed |

### Dependency Type Definitions

| Type | Meaning | Sequencing Rule |
|------|---------|-----------------|
| **SEQUENCE** | Issue B must be implemented after Issue A (file conflict or logical dependency) | A → B |
| **FILE-OVERLAP** | Issues modify different sections of the same file | Any order, but coordinate to avoid merge conflicts |
| **INDEPENDENT** | No file or logical dependency | Any order |
| **CLOSED/COMPLETED** | Issue is already implemented | No action needed |

## Research References

- `skills/verification-before-completion/tasks/behavioral-test-evaluation.md` — The task that verify.md must dispatch
- `skills/verification-before-completion/tasks/operating-protocol.md` §7 — Currently mandates behavioral-test-evaluation dispatch but as a separate note, not integrated into verify.md's workflow
- `guidelines/000-critical-rules.md` §critical-rules-047 — VbC Fabricated PASS prohibition
- `guidelines/000-critical-rules.md` §critical-rules-060 — Functional/Behavioral Test Substitution Prohibition
- `guidelines/080-code-standards.md` §Evidence Type Taxonomy — behavioral > semantic > string > structural hierarchy
- `guidelines/080-code-standards.md` §Test Integrity Mandate — no lobotomizing tests

---

> **Full spec and artifacts: [`.opencode/.issues/1789/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1789)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1789/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
