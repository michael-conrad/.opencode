## Executive Summary

**Finding:** C50 — 37 SKILL.md files contain "unless explicitly marked as inline/orchestrator in this skill" in their Mandatory Task Discipline checklist item 3.

**Problem:** The "unless" clause is a structural escape hatch that allows any skill to self-declare inline steps, exempting itself from the sub-agent dispatch requirement. Each skill author (or the agent creating/modifying the skill) decides which steps are "inline/orchestrator," undermining the entire sub-agent dispatch discipline. If a skill marks too many steps as inline, the orchestrator inline work prohibition in `critical-rules-034` (Tier 2) is bypassed.

**Fix:** Remove "unless explicitly marked as inline/orchestrator in this skill" from all 37 SKILL.md files. Replace with: "Each step MUST be dispatched to a sub-agent via task(). No inline execution."

**Files affected:** All 37 SKILL.md files — checklist item 3 in the Mandatory Task Discipline section.

**Behavioral test needed:** Prompt agent to execute a skill task. Assert agent dispatches to sub-agent via `task()`, does not execute steps inline.

**Dependencies:** None