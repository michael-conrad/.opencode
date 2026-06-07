# Research Card: Corrupt Success in LLM Agent Procedural Compliance

## Source

Cao, Driouich, Thomas (Mar 2026). "Beyond Task Completion: Revealing Corrupt Success in LLM Agents through Procedure-Aware Evaluation." arXiv:2603.03116.

## Method

Procedure-Aware Evaluation (PAE) framework on tau-bench. Multi-dimensional gating across Utility, Efficiency, Interaction Quality, Procedural Integrity.

## Finding

**27-78% of benchmark-reported successes are corrupt successes** — the agent appears to complete the task but violates procedure, skips steps, or produces outcomes that pass a utility check while failing procedural integrity.

## Per-Model Failure Signatures

| Model | Dominant Failure Mode |
|-------|----------------------|
| GPT-5 | Spreads across policy, execution, intent |
| Kimi-K2-Thinking | 78% in policy faithfulness + compliance |
| Mistral-Large-3 | Dominated by faithfulness failures |

## Relevance

Directly confirms observed failure mode: orchestrator skips steps in checklist/procedure, produces output that "looks done" but skipped gates. Standard benchmarks miss this because they measure task completion, not procedural compliance.

## Verified

Sat Jun 06 2026 — fetched from arxiv.org/abs/2603.03116