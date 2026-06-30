# Implementation Plan — Centralize Prose-Recall Prompt Prohibition

## Goal

Centralize the prose-recall prompt prohibition (currently scattered across 4 files) into a single authoritative §Prompt Construction Mandate section in `.opencode/tests/AGENTS.md`, add prompt construction guidance to the behavioral test template, and add cross-references from the two guideline files that already define behavioral evidence.

## Architecture

Single-phase, 5-item implementation. All items are independent (no file depends on another), so they can be implemented in any order within the phase. The behavioral test (SC-5) is the RED/GREEN gate — it must be written first (RED), then the documentation changes make it pass (GREEN).

| Item | File | Change | SC |
|------|------|--------|----|
| 1 | `.opencode/tests/AGENTS.md` | Add §9 Prompt Construction Mandate | SC-1 |
| 2 | `.opencode/tests/behaviors/template.sh` | Add prompt construction guidance comment block | SC-2 |
| 3 | `.opencode/guidelines/080-code-standards.md` | Add cross-reference in Enforcement Test Mandate section | SC-3 |
| 4 | `.opencode/guidelines/091-incremental-build.md` | Add cross-reference in Behavioral Variant section | SC-4 |
| 5 | `.opencode/tests/behaviors/prose-recall-rejection.sh` | Create behavioral enforcement test | SC-5 |

## Phase Table

| Phase | Items | Dependency | Verification |
|-------|-------|------------|-------------|
| Phase 1 | 1, 2, 3, 4, 5 | None (all independent) | SC-1 through SC-5 |

## Step-by-Step Instructions

### Item 1 — Add §Prompt Construction Mandate to AGENTS.md

**File:** `.opencode/tests/AGENTS.md`

**Action:** Add a new section §9 after the existing §8 (Triple Co-Application Reference), before the closing `---` and footer.

**Content requirements (per spec):**
- Define the interview/natural-behavior spectrum
- Valid prompt types: real-domain task prompts that trigger natural agent behavior
- Invalid prompt types: interview questions, prose-recall prompts, "describe how you would" prompts
- Hard-fail rule: any behavioral test using a prose-recall prompt is FAIL
- Examples of valid vs invalid prompts

**Verification (SC-1):** `grep` for "Prompt Construction Mandate" in AGENTS.md

### Item 2 — Add prompt construction guidance to template.sh

**File:** `.opencode/tests/behaviors/template.sh`

**Action:** Add a comment block between the header and the `set -euo pipefail` line with guidance on prompt construction.

**Content requirements (per spec):**
- Reminder that `SCENARIO_PROMPT` must be a real-domain task, not an interview question
- Reference to §Prompt Construction Mandate in AGENTS.md
- Examples of valid vs invalid prompt patterns

**Verification (SC-2):** `grep` for "prompt" in template.sh

### Item 3 — Add cross-reference in 080-code-standards.md

**File:** `.opencode/guidelines/080-code-standards.md`

**Action:** In the "Enforcement Test Mandate for Guideline and Skill Changes" section (line 417), add a cross-reference sentence pointing to the centralized §Prompt Construction Mandate in AGENTS.md.

**Anchor:** After the first paragraph (line 419), or as a standalone note within the section.

**Verification (SC-3):** `grep` for "AGENTS.md" or "Prompt Construction" in 080-code-standards.md

### Item 4 — Add cross-reference in 091-incremental-build.md

**File:** `.opencode/guidelines/091-incremental-build.md`

**Action:** In the "Behavioral variant" paragraph (line 33-35), add a cross-reference sentence pointing to the centralized §Prompt Construction Mandate in AGENTS.md.

**Anchor:** After line 35 ("Prose-recall prompts are NOT accepted as behavioral tests.").

**Verification (SC-4):** `grep` for "AGENTS.md" or "Prompt Construction" in 091-incremental-build.md

### Item 5 — Create behavioral enforcement test

**File:** `.opencode/tests/behaviors/prose-recall-rejection.sh`

**Action:** Create a new behavioral test script following the template pattern. The test sends an interview-style prompt ("Describe how you would handle authorization") and verifies that the test framework produces a FAIL verdict.

**Pattern:** Follow the artifact-only generator paradigm from AGENTS.md §1. Use `behavior_run` with `SCENARIO_NAME="prose-recall-rejection"` and an interview-style `SCENARIO_PROMPT`.

**Verification (SC-5):** `bash .opencode/tests/behaviors/prose-recall-rejection.sh` produces artifacts; evaluation by clean-room sub-agent confirms FAIL verdict.

## Exit Criteria

| Criterion | Evidence |
|-----------|----------|
| All 4 documentation files modified | `git diff --stat` shows changes to AGENTS.md, template.sh, 080-code-standards.md, 091-incremental-build.md |
| Behavioral test script exists | `ls .opencode/tests/behaviors/prose-recall-rejection.sh` |
| SC-1 through SC-4 pass (string) | grep assertions pass |
| SC-5 passes (behavioral) | `bash .opencode/tests/behaviors/prose-recall-rejection.sh` runs successfully; clean-room evaluation confirms FAIL verdict |

## Compliance Notice

This plan implements spec `.opencode/.issues/1616/spec.md`. All steps must be followed in order. The behavioral test (Item 5) must be written first (RED) before the documentation changes (Items 1-4) are made (GREEN). Each item is committed as a single working slice per the incremental build discipline.
