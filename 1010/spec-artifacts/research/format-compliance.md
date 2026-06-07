# Research Card: Format Effect on LLM Procedural Compliance

## Source

McMillan, Damon (Feb 2026). "Structured Context Engineering for File-Native Agentic Systems." arXiv:2602.05447.

## Method

9,649 experiments across 11 models. Compared YAML, Markdown, JSON, TOON formats on schemas from 10 to 10,000 tables.

## Finding (Aggregate)

No statistically significant format effect at aggregate level for frontier models (Claude Opus 4.5, GPT-5.2, Gemini 2.5 Pro). Chi-squared 2.45, p=0.484.

## Finding (Procedural Compliance)

Format structure measurably affects procedural compliance — how consistently the model follows a structured process vs. optimizing locally. Smaller and open-source models still show format sensitivity.

## Key Insight

Model capability dwarfs format choice (21 percentage-point accuracy gap between frontier and open-source). But procedural compliance is distinct from accuracy — a model can get the right answer via the wrong process.

## Relevance

Format choice alone won't fix the problem. The checklist format is necessary but not sufficient — it must be paired with a behavioral enforcement mechanism that detects procedural non-compliance (step skipping, inlining).

## Verified

Sat Jun 06 2026 — fetched from arxiv.org/abs/2602.05447