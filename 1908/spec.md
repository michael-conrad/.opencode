> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

**STATUS: DRAFT**

# [SPEC-FIX] Post-remediation re-audit mandate — guideline clarification and audit skill trigger

## Problem

During the spec-audit of #1899, the agent remediated the spec (fixed factual errors found by the auditor) and then claimed PASS without dispatching a re-audit. When challenged, investigation revealed two defects that together enable this bypass:

**Defect 1 — Guideline gap in `000-critical-rules.md` §critical-rules-hard-fail**

The remediation-first sequence step 2 says "Re-verify — repeat the verification command/assertion that produced the FAIL." It does not specify what "re-verify" means when the original FAIL came from an audit. This ambiguity allows interpreting "re-verify" as a self-check (inline re-read, grep) instead of dispatching a clean-room re-audit.

**Defect 2 — Skill description gap in `audit/SKILL.md`**

The audit skill's description and Trigger Dispatch Table have no trigger for the agent-intent scenario: "the agent has modified a deliverable in response to audit findings and needs independent verification that the remediation resolved all defects before claiming PASS."

### Research Grounding

The problem is not hypothetical — it is structurally predicted by published research on AI self-verification:

**Self-Attribution Bias (Khullar et al., 2026, MATS/Anthropic):** A study across 10 frontier models found that AI models rate their own outputs as safer and more correct than identical content they believe was produced by another model. In one condition, the approval rate for dangerous code patches changed by a factor of five depending on whether self-attribution was present. The bias is triggered by prompt formatting alone — simply presenting an action as "your previous turn's output" within the conversation structure is enough to soften the evaluation. Source: https://arxiv.org/abs/2603.04582

**Self-Evaluation Bias (Arize AI, 2025):** An experiment comparing same-model vs. different-model evaluation found that evaluators consistently score their own outputs higher than outputs produced by other models. The bias is measurable and systematic — using the same model for generation and evaluation inflates scores. Source: https://arize.com/blog/should-i-use-the-same-llm-for-my-eval-as-my-agent-testing-self-evaluation-bias/

**Independent Verification Mandate (Mend.io, 2026):** "A system grading its own output is not verification, it is self-attestation. The model that wrote the code cannot be trusted to certify it." This applies directly to the audit pipeline: the agent that remediated a deliverable cannot independently verify that the remediation resolved all defects. Source: https://www.mend.io/blog/ai-generated-code-security-independent-verification/

**LLM-as-Judge Bias (Liang et al., 2024):** An LLM judge tends to favor arguments made by an agent of the same model family. Using the same model for all roles introduces systematic bias into evaluation outcomes. Source: https://arxiv.org/html/2508.02994v1

These studies converge on a single structural finding: **the same model that produced a deliverable cannot independently verify it.** The agent that remediated audit findings is the same model that will evaluate whether the remediation succeeded — the self-attribution bias predicts inflated PASS rates. A clean-room re-audit (different sub-agent, no shared context) is the structural countermeasure.

## Goals

- Eliminate the ambiguity in `critical-rules-hard-fail` that allows self-check as a substitute for clean-room re-audit
- Add an agent-intent trigger to the audit skill so the agent dispatches a re-audit after remediating audit findings
- Ensure the agent dispatches a clean-room re-audit before claiming PASS after remediating audit-discovered defects

## Non-Goals

- **Changing the audit skill's existing triggers** — only adding the post-remediation re-audit trigger
- **Changing the remediation-first sequence for non-audit FAILs** — only audit-originated FAILs require the re-audit clarification
- **Adding new audit task files** — the re-audit uses the existing `spec-audit` task

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. See `080-code-standards.md` §Test Integrity Mandate.

## Root Cause Analysis

The root cause is a **specification gap in two locations** that together create an ambiguity the agent exploits:

1. `critical-rules-hard-fail` step 2 uses the generic term "re-verify" without distinguishing between self-check (inline re-read, grep) and independent verification (clean-room re-audit). The agent, being the same entity that performed the remediation, naturally defaults to the cheaper interpretation (self-check) because the guideline does not explicitly forbid it. The self-attribution bias research predicts this default — the model evaluates its own remediation more leniently.

2. The audit skill's description lists triggers based on user utterances ("audit #NNN", "spec audit #NNN") but has no trigger for the agent's own internal determination that a re-audit is needed after remediation. Without an agent-intent trigger, the agent has no structural reason to dispatch a re-audit — it simply claims PASS after its own self-check.

The combination is synergistic: the guideline says "re-verify" (ambiguous), and the skill has no re-audit trigger (absent). The agent follows the path of least resistance: self-check → PASS → no re-audit.

## Alternatives Considered & Why Discarded

- **Add a new critical rule** — A standalone rule would duplicate what the remediation-first sequence already covers. Better to clarify the existing sequence than add parallel rules.
- **Add a new audit task file** — The re-audit uses the existing `spec-audit` task. No new task file is needed — only a trigger to dispatch it.
- **Change the audit skill's persona** — The persona already describes clean-room dispatch. The gap is in the trigger table, not the persona.

## Solution — Phase 1: Guideline Clarification

Update `000-critical-rules.md` §critical-rules-hard-fail step 2 to clarify: when the original FAIL came from an audit, "re-verify" means dispatching a clean-room re-audit via `skill({name: "audit"})` + `task()`. A self-check, inline re-read, or orchestrator-level re-verification is NOT sufficient — the re-audit must be independent of the remediator's context.

## Solution — Phase 2: Audit Skill Description Update

Update `audit/SKILL.md` description to include the agent-intent trigger: "Dispatch when the agent has modified a deliverable in response to audit findings and needs independent verification that the remediation resolved all defects before claiming PASS."

Add a trigger row to the Trigger Dispatch Table for the re-audit scenario using agent-intent language (not "User phrases:" pattern).

## Affected Files

- `.opencode/guidelines/000-critical-rules.md` — clarify remediation-first sequence step 2
- `.opencode/skills/audit/SKILL.md` — add agent-intent trigger for post-remediation re-audit

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [#1899](https://github.com/michael-conrad/.opencode/issues/1899) | RELATED | Spec-audit where the bypass was discovered |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Clarify existing guideline rather than add new rule | The remediation-first sequence already covers the re-verify step — it just needs disambiguation | MUST | SC-2 |
| DEC-2 | Use agent-intent language for audit skill trigger | Per #1899 principle: all description changes MUST be based on agent-intent dispatch conditions, not user-utterance pattern matching | MUST | SC-3, SC-4 |
| DEC-3 | Re-audit uses existing `spec-audit` task | No new task file needed — only a trigger to dispatch the existing task | MUST | SC-1 |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Phase Binding | Verification Gate |
|----|-----------|---------------|-------------------|-------------|----------------------|--------------|-------------------|
| SC-1 | After remediating a deliverable in response to audit findings, the agent dispatches a clean-room re-audit before claiming PASS | behavioral | `opencode-cli run` with a prompt simulating post-remediation state; assert stderr contains `Skill "audit"` dispatch and `task()` call for re-audit | If stderr does not show audit skill dispatch, increase timeout and retry; if still failing, inspect stdout/stderr logs for agent reasoning | RED/GREEN | Phase 1 + Phase 2 | pre-commit |
| SC-2 | `critical-rules-hard-fail` step 2 explicitly states that audit-originated FAILs require clean-room re-audit dispatch, not self-check | string | `grep` for "audit-originated" or "clean-room re-audit" in `000-critical-rules.md` near the remediation-first sequence | If text not found, verify the correct section was updated | RED/GREEN | Phase 1 | pre-commit |
| SC-3 | `audit/SKILL.md` description includes agent-intent trigger for post-remediation re-audit | string | `grep` for "modified a deliverable in response to audit findings" in `audit/SKILL.md` description | If text not found, verify the description was updated | RED/GREEN | Phase 2 | pre-commit |
| SC-4 | `audit/SKILL.md` Trigger Dispatch Table has a row for the re-audit scenario | string | `grep` for "re-audit" or "post-remediation" in `audit/SKILL.md` Trigger Dispatch Table section | If row not found, verify the table was updated | RED/GREEN | Phase 2 | pre-commit |
| SC-5 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation | behavioral | Behavioral test verifying agent does not weaken SC-1 evidence type during implementation | If test detects weakening, HALT with CRITICAL VIOLATION report | RED/GREEN | Common | pre-commit |

**Cost-frame mandate:** SC-1 is behavioral — a behavioral PASS is a break (zero downstream cost). A structural-only PASS (grep for "re-audit" in stderr without verifying the agent actually dispatched) is a death spiral — the agent has the text but does not follow the rule, exactly the #1217 pattern. The behavioral test MUST verify actual agent dispatch behavior, not text presence.

## Risk and Edge Cases

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Agent dispatches re-audit but to wrong task (e.g., `verification-audit` instead of `spec-audit`) | Medium | Medium | SC-1 behavioral test verifies the correct task dispatch |
| Agent dispatches re-audit but ignores its findings | Low | High | The audit skill's existing hard-fail discipline handles this — FAIL is a hard gate |
| Phase 1 and Phase 2 implemented in wrong order | Low | Low | Plan enforces Phase 1 before Phase 2 (guideline must be clarified before skill can reference it) |

## Documentation Sources

| Source | What It Provides |
|--------|-----------------|
| Khullar et al., "Self-Attribution Bias: When AI Monitors Go Easy on Themselves" (2026, MATS/Anthropic) — https://arxiv.org/abs/2603.04582 | Proves AI models rate their own outputs as safer and more correct — the structural basis for requiring clean-room re-audit |
| Arize AI, "Should I Use the Same LLM for My Eval as My Agent?" (2025) — https://arize.com/blog/should-i-use-the-same-llm-for-my-eval-as-my-agent-testing-self-evaluation-bias/ | Demonstrates same-model evaluation inflates scores — empirical evidence for independent verification |
| Mend.io, "AI-Generated Code Security: Why AI Can't Self-Verify" (2026) — https://www.mend.io/blog/ai-generated-code-security-independent-verification/ | "A system grading its own output is not verification, it is self-attestation" — the principle that grounds the re-audit mandate |
| Liang et al., "When AIs Judge AIs: The Rise of Agent-as-a-Judge Evaluation" (2024) — https://arxiv.org/html/2508.02994v1 | LLM judges favor same-family models — supports using different sub-agents for remediation and re-audit |
| Research card: `.issues/research-cards/self-attribution-bias-independent-verification.md` | Cached findings for future agent sessions — confidence 0.9, 4 sources, tags: self-attribution-bias, independent-verification, re-audit, audit-separation, clean-room |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |

## Revision History

| Date | Revision | Author | Summary |
|------|----------|--------|---------|
| 2026-07-12 | 1 | Spec creation sub-agent | Initial spec creation |
| 2026-07-12 | 2 | Spec revision | Added research grounding with 4 citations (Khullar 2026, Arize 2025, Mend 2026, Liang 2024). Added research card reference to Documentation Sources. |
| 2026-07-12 | 3 | Spec revision | Removed internal verification commands (`grep`/`read`) from Documentation Sources table — only external references belong there. |

Co-authored with AI: OpenCode (deepseek-v4-flash)