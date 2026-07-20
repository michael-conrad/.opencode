## Intent

Full audit of the skill deck's AI-agent-facing guideline files to identify all instances where word counts, line counts, token counts, or byte-dispatch formulas are presented as measures of implementation complexity or work involved. Then apply a holistic fix that removes these proxy metrics and replaces them with the correct principle: **the only valid metric for determining whether implementation is complete is tested verified correct code operations passing with 100% clean PASS.**

## Problem

The skill deck's AI-agent-facing guideline files across multiple SKILL.md files and `.opencode/guidelines/` files incorrectly assert in different ways that word counts, line counts, or agent context byte-dispatch formulas should be considered as part of implementation complexity calculations. This is defective reasoning — document size metrics do not measure implementation effort.

The specific defects identified during initial investigation:

1. **`.opencode/guidelines/091-incremental-build.md`** (line 47): Declares word count (`wc -w`) as "the canonical complexity metric for all skill task files, SKILL.md files, and guideline files" with artifact size limits (3,000 words per atomic task file). This conflates document cognitive load with implementation effort.

2. **~35+ SKILL.md files** containing identical "Context cost frame" blocks: *"The orchestrator's context is the most expensive resource in the pipeline — sub-agents do the work, not the orchestrator. Every byte held by the orchestrator costs `byte × remaining_dispatches²`."* These frames present internal agent operational bookkeeping as if it were an implementation complexity metric that agents should consider when formulating steps or estimating work.

3. **`.opencode/skills/writing-plans/tasks/write.md:121`**: Uses "cost of an extra step" language to justify mandatory gates, implying quantifiable step costs relevant to effort estimation.

4. **`.opencode/skills/programming-principles/tasks/principles.md:416-443`**: Uses line counts (`wc -l`) and word counts (`wc -w`) as function/class complexity thresholds (e.g., "File > 400 lines → Split"), implicitly telling agents that these metrics measure implementation complexity.

## Scope of Fix

All files containing the above patterns need revision to:
- Remove or reframe word/line count usage so they clearly only apply to document quality/cognitive load — NEVER as proxies for implementation effort
- Replace context cost frame blocks with language that explicitly states agent operational bookkeeping metrics are NOT relevant to implementation complexity estimation
- Establish a single authoritative principle: **Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS (no caveats, no notes).**

## Approach

This spec requires two phases: audit (full scan of all affected files at time of approval) + fix (holistic revision applying findings). A full re-scan is mandatory because the initial investigation may have missed instances or the codebase state may have changed.

🤖 Co-authored with AI: OpenCode (qwen3.6:35b-256k)