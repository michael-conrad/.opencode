# Research Card: Instruction Position Problem — Position Sensitivity in LLM Instruction Following

## Source

Tian Pan (Apr 2026). "The Instruction Position Problem: Where You Place Things in Your Prompt Is an Architecture Decision." tianpan.co.

## Background

Cites the "lost in the middle" phenomenon (Stanford 2023), ICLR 2025 work on nuanced instruction following, and the SPEM methodology (arXiv 2024, 104 model-task combinations).

## Key Findings

### Finding 1: U-Shaped Attention Curve

When relevant information is placed at the beginning or end of a prompt, models use it correctly. When placed in the middle, performance degrades significantly. In multi-document QA, moving answer-relevant document from position 1 to a middle position in a 20-document context drops accuracy by **30% or more**.

**Root cause**: Rotary Position Embeddings (RoPE) introduce distance decay — attention between two tokens weakens as distance increases. Intentional for local context modeling, but structural side effect: middle tokens receive weaker aggregate attention.

### Finding 2: Instruction Compliance Degrades with Position

Modern models show up to **61.8% performance variance** when instructions are reworded or repositioned, even when semantic intent stays constant.

**Critical rules buried in the middle of a long system prompt degrade compliance by 30-50%** compared to the same rules at the beginning.

The model isn't ignoring them consciously. Its attention mechanism is structurally underfunding them.

### Finding 3: Primacy Beats Recency, but Both Beat Middle

| Position | Reliable compliance |
|----------|-------------------|
| Beginning (primacy) | ~73% |
| End (recency) | Good, but less consistent — exploitable by adversarial user input |
| Middle | 30-50% degradation |

### Finding 4: The Instruction Sandwich

For safety constraints that must hold regardless of user input, place them at **both** the beginning AND the end of the system prompt — exploiting primacy and recency simultaneously. It's redundant by design.

> "This is not a complete solution. It doesn't work against prompt injection from retrieved content that appears after the final safety block. But it materially improves compliance for well-defined behavioral constraints."

### Finding 5: Recommended Prompt Architecture Ordering

1. Core identity and role (~20 tokens) — FIRST
2. **Non-negotiable behavioral constraints** — safety rules, privacy, absolute prohibitions
3. Output format and structure requirements
4. Domain context and knowledge (middle — appropriate here)
5. Few-shot examples (middle — appropriate here)
6. Task-specific instructions (repeat at end if critical)

Categories 1-2 contain compliance-sensitive instructions and belong at the top. Categories 4-5 contain content the model should use but isn't required to follow as rules — middle is appropriate.

### Finding 6: Positional Sensitivity Is a CI Failure Mode

> "A change that adds 200 tokens of context to your system prompt changes the position of every instruction that follows it. The instructions didn't change. Their position did. If your compliance-critical rules were in the second quartile, they're now in the third."

**If compliance drops from 95% (first quartile) to 65% (middle quartile), that constraint is position-sensitive and must be pinned near the top.**

### Finding 7: Required Testing Protocol

Build a positional sensitivity test:
1. Take your 5 most compliance-critical instructions
2. Test each one at 3 positions: 0-20%, 40-60%, 80-100% of total prompt length
3. If any instruction shows **>15% compliance variance** across positions → treat as a structural issue requiring prompt architecture changes, not prompt wording changes

## Relevance to Our Architecture

| Application | Action |
|-------------|--------|
| Dispatch mandate placement | Must be in first 5% of system prompt tokens. Instruction sandwich: both beginning (default.txt) and end (AGENTS.md) |
| Pre-read cascade fix target | 45k → 5-8k words. At 45k, the dispatch mandate (which is ~200 tokens) is at position ~400 out of 45,000 — the model's attention valley. At 5k, the same 200-token instruction is at position ~400 out of 5,000 — first 10%, well within primacy zone |
| Positional sensitivity CI gate | After every guideline/skill change, measure dispatch mandate token position. If variance >15% across 3 test positions, BLOCK |
| Standardizing dispatch format | Checklist format's visual distinctiveness (markdown, hyphens, brackets, backticks) increases its signal-to-noise ratio — it doesn't look like the surrounding guideline prose, so it's less affected by position decay than prose-form instructions would be |

## Verified

Sat Jun 06 2026 — fetched from tianpan.co/blog/2026-04-14-the-instruction-position-problem