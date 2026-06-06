# Research Card: Context Rot — Performance Degradation with Input Length

## Source

Chroma Research (Jul 2025). "Context Rot: How Increasing Input Tokens Impacts LLM Performance." Kelly Hong, Anton Troynikov, Jeff Huber. 18-model evaluation.

## Method

Controlled experiments holding task complexity constant while varying input length. Four experiments: (1) Needle-Question Similarity, (2) Impact of Distractors, (3) Needle-Haystack Similarity, (4) Haystack Structure. 18 models tested including GPT-4.1, Claude Sonnet 4, Qwen3-32B, Gemini 2.5 Flash.

## Findings

### Finding 1: Performance degrades non-uniformly with input length

Even on simple tasks with task complexity held constant, performance degrades as input length increases. The degradation is not uniform — it varies by model family, task type, and content structure.

### Finding 2: Distractors compound degradation

A single distractor (topically related but irrelevant content) reduces performance relative to baseline (no distractors). Four distractors compounds the degradation further. Distractors have non-uniform impact — some are more "distracting" than others, and this becomes more pronounced at longer input lengths.

### Finding 3: Lower semantic similarity accelerates degradation

Needle-question pairs with lower cosine similarity (more semantic ambiguity) cause faster performance degradation as input length increases. This reflects realistic scenarios where exact matches are rare.

### Finding 4: Needle-haystack similarity has non-uniform effect

The similarity between the target information (needle) and the surrounding context (haystack) does not have a uniform effect on performance. The relationship varies by model and task.

### Finding 5: Distinct model behaviors

- Claude models: lowest hallucination rates, abstain when uncertain (explicitly state "no answer found")
- GPT models: highest hallucination rates, generate confident but incorrect responses when distractors present

## Relevance to Checklist Dispatch

Our 45,014 words of session-start instructions = the "haystack." The dispatch mandate / checklist instruction = the "needle."

- Lower semantic similarity between dispatch instruction and surrounding guideline prose means faster degradation — the model is less likely to notice the checklist instruction buried in the haystack
- Distractors (guideline content, rule enumerations) compete with the checklist for attention — 45k words means many distractors
- Reducing haystack size (pre-read cascade fix) directly improves needle retrieval reliability
- Even frontier models degrade non-uniformly — the checklist format needs enforcement backing, not just placement

## Model-Specific Takeaways for Enforcement Tests

- If using Claude-based models: behavioral tests should catch refusal/abstention patterns, not just wrong answers
- If using GPT-based models: behavioral tests must catch confident-but-wrong inline execution (hallucination of correct dispatch)
- Needle-Question Similarity finding: the less the checklist "looks like" the surrounding guideline content (distinct format, positioning), the more reliably it will be attended to

## Verified

Sat Jun 06 2026 — fetched from trychroma.com/research/context-rot