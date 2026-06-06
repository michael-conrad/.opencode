# Research Card: Corrupt Success — Procedure-Aware Evaluation of LLM Agents

## Source

Cao, Driouich, Thomas (Mar 2026). "Beyond Task Completion: Revealing Corrupt Success in LLM Agents through Procedure-Aware Evaluation." arXiv:2603.03116.

## The PAE Framework

Procedure-Aware Evaluation (PAE) formalizes agent procedures as structured observations and exposes consistency relationships between what agents observe, communicate, and execute.

### Four Evaluation Axes

| Axis | What It Measures |
|------|-----------------|
| **Utility** | Did the agent complete the task? |
| **Efficiency** | How many steps/resources did it use? |
| **Interaction Quality** | How well did it communicate? |
| **Procedural Integrity** | Did it follow the correct procedure? |

**Key insight**: Utility masks reliability gaps. An agent can complete the task (Utility PASS) while violating procedure (Procedural Integrity FAIL). Standard benchmarks only measure Utility.

### Multi-Dimensional Gating

PAE applies multi-dimensional gating that **categorically disqualifies corrupt outcomes**. If any axis fails, the entire run is classified as corrupt-success — regardless of Utility score.

## Headline Result

**27-78% of benchmark-reported successes are corrupt successes** — the agent appears to complete the task but violated procedure, skipped steps, or produced outcomes that pass a utility check while failing procedural integrity.

## Per-Model Failure Signatures

| Model | Failure Profile |
|-------|-----------------|
| GPT-5 | Spreads across policy, execution, intent dimensions |
| Kimi-K2-Thinking | 78% of violations in policy faithfulness + compliance |
| Mistral-Large-3 | Dominated by faithfulness failures |

## Relevance to Our Architecture

### The same failure mode

The orchestrator inlining instead of dispatching is a corrupt success:
- **Utility**: The orchestrator produces output (code, files, PRs) — task appears "done"
- **Procedural Integrity**: The orchestrator violated the dispatch protocol — it read task files and executed steps inline instead of dispatching via task()
- **Standard benchmarks**: Would report PASS (output exists, task completes)
- **PAE framework**: Would report FAIL (procedural integrity violated)

### Behavioral test must detect corrupt success

The corrupt-success test must assert:
1. **Procedural Integrity PASS**: Orchestrator made zero `read` calls on `tasks/*.md` during dispatch window (the procedure was followed)
2. **Utility is a secondary concern**: Even if output looks correct, if procedure was violated, it's a FAIL

### This is the wrong metric to use

"Do the tests pass?" measures utility only. "Did the agent dispatch cleanly?" measures procedural integrity. Both are needed, but the PAE framework shows that procedural integrity is the more important gate — utility failures are obvious, corrupt-success failures are invisible until downstream.

## Verified

Sat Jun 06 2026 — fetched from arxiv.org/abs/2603.03116