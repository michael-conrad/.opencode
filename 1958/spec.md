---
title: Canonical cross-reference format — verb confirmation and full rollout
status: draft
created: 2026-07-15
revised: 2026-07-18
license: MIT
provenance: AI-generated
issue: 1958
supersedes:
  - 1953
informs:
  - 1925
  - 1926
informed_by:
  - 1988
authors:
  - OpenCode (deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-15
**REVISED:** 2026-07-18

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Read [Test Integrity Mandate](guidelines/080-code-standards.md).

## Problem

The cross-reference pattern in `.opencode/` files directs AI agents to load referenced content into context. Two questions were open:

1. **Form:** Should the reference be an inline link (`See [file](path)`) or a symbol-only ref with a resolution table (`§Name` + table + admonition)?
2. **Verb:** Which imperative verb most reliably causes the agent to load and use the referenced content?

Sibling spec #1988 answered question 1 with 78 experimental runs: the inline link form achieves 100% Tier 1 access rate vs 42-58% for the resolution table pattern. The form is settled.

Question 2 was partially answered by a verb sub-test within #1988 (24 runs, 8 verbs). "Load" emerged as the leading candidate — 100% access rate AND the agent correctly applied the referenced value. "See" (the current default) triggered file access but the agent treated the content as informational context, ignoring the value. "Read" produced a false positive (listed directory, never read content). "Fetch" caused the agent to try web fetch instead of local read.

This spec confirms the winning verb with additional runs, then implements the full canonical format across all skill cards, guidelines, and `default.txt`.

## Root Cause Analysis

The root cause is that the agent's training data contains many imperative verb forms used in documentation ("see", "refer to", "check", "look at") that do not correspond to tool invocations. The agent has learned to treat these as informational cues rather than actionable directives. "See" is the most common — it appears in every Microsoft documentation page and the Agent Skills spec. The agent has been trained to treat "See [file]" as a citation to ignore, not a directive to follow.

"Load" is not a common documentation verb. It is a programming term meaning "bring data into memory." The agent treats it as an actionable instruction because it has no training-data association with passive citation.

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|-------------------|
| Testing only `Read` in isolation | #1988 already tested 8 verbs empirically — no need to start from scratch |
| Testing all possible verbs | #1988 narrowed to 8 candidates; 3 runs each provides sufficient confidence |
| Testing in production guidelines | Risk of agent confusion during testing — isolated test environment required |
| Resolution table + admonition form | #1988 proved it at 42-58% — not viable |
| Bare §N symbols | #1988 proved them at 42-58% — not viable |

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [#1988](https://github.com/michael-conrad/.opencode/issues/1988) | INFORMED_BY | Provided form and verb data (78 runs) |
| [#1953](https://github.com/michael-conrad/.opencode/issues/1953) | **SUPERSEDES** | Bare §N→descriptive text is covered by this spec's canonical format |
| [#1925](https://github.com/michael-conrad/.opencode/issues/1925) | INFORMS | Linting rules should enforce `Load [Text](path)` as canonical |
| [#1926](https://github.com/michael-conrad/.opencode/issues/1926) | INFORMS | Behavioral tests should verify `Load [Text](path)` pattern |

## Research Cards

The following research cards were created during the investigation phase and MUST be consulted before implementation:

| Card | Path | Key Findings |
|------|------|-------------|
| Microsoft markdown link patterns | `.issues/research-cards/microsoft-markdown-link-patterns.md` | VS Code uses passive references, not load directives. `Read [Text](path)` is NOT cargo-culted from Microsoft — it's an independent convention. |
| Imperative verb forms for LLM load directives | `.issues/research-cards/imperative-verb-forms-load-directives.md` | No production system uses `Read [Text](path)` except OpenCode. Amp uses `@-mention`. No research exists on verb effectiveness. "See [file]" is documented as defective. |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Local experiment data | `tmp/1988/measurements-verb-test.jsonl` | 24 verb variant runs (8 verbs × 3 runs) |
| Local experiment data | `tmp/1988/measurements.jsonl` | 60 Tier 1 form comparison runs |
| Local experiment data | `tmp/1988/measurements-tier2.jsonl` | 18 Tier 2 handoff runs |
| Local docs | `.opencode/guidelines/000-critical-rules.md` | Understand existing `Read [Text](path)` pattern |
| Local docs | `.opencode/guidelines/INDEX.md` | Understand guideline structure and trigger patterns |
| Local docs | `.opencode/prompts/default.txt` | Understand where directives are injected |
| Research card | `.issues/research-cards/microsoft-markdown-link-patterns.md` | Microsoft's passive reference pattern vs OpenCode's active load directive |
| Research card | `.issues/research-cards/imperative-verb-forms-load-directives.md` | Candidate verb forms, production system patterns, known defective patterns |
| Web | Agent Skills specification | `agentskills.io/specification` — defines `See [file](path)` as the standard |

## #1988 Experimental Results Summary

### Form Comparison (60 Tier 1 runs)

| Form | Access Rate |
|------|-------------|
| **Form A (inline link)** | **100%** (12/12) |
| Form B1 (bare §Name + table) | 50% (6/12) |
| Form B2 (bracketed + table) | 42% (5/12) |
| Form B3 (conditional + table) | 58% (7/12) |
| Form C (explicit verb + table) | 58% (7/12) |

**Conclusion:** Inline link form is the only viable pattern. Resolution table + admonition is not a replacement.

### Verb Variant Test (24 Tier 2 runs, Fixture A)

| Verb | Access Rate | Actually Read Content? | Used Correct Value? | Deliberation Quality |
|------|-------------|----------------------|-------------------|---------------------|
| **Load** | **100%** (3/3) | ✅ Yes | ✅ **Yes (30s)** | 1 failed tool attempt, then correct |
| Open | 100% (3/3) | ✅ Yes | ✅ Yes (30s) | 1 failed attempt, then correct |
| Check | 100% (3/3) | ✅ Yes | ✅ Yes (30s) | 2 failed attempts, then correct |
| Consult | 100% (2/2) | ✅ Yes | ✅ Yes (30s) | 1 failed attempt, then correct |
| MUST read | 100% (3/3) | ✅ Yes | ✅ Yes (30s) | 1 failed attempt, then correct |
| See | 100% (3/3) | ✅ Yes | ❌ **No (used 1s)** | Read file, ignored value |
| Read | 67% (2/3) | ❌ **No** (false positive) | ❌ No | Listed dir, never read content |
| Fetch | 100% (3/3) | ❌ **No** | ❌ No | Tried web fetch instead of local read |

**Conclusion:** "Load" is the leading candidate. "See" is defective (reads but ignores). "Read" is a false positive. "Fetch" is misinterpreted as web fetch.

## Canonical Format

The canonical cross-reference format is:

```
Load [descriptive text](relative/path.md)
```

### Rules

1. **Verb:** Always `Load`. Never `See`, `Read`, `Fetch`, or bare symbols.
2. **Link text:** Descriptive text naming the target content. Never bare section numbers (`§N`), bare file names, or generic text like "the reference guide".
3. **Path:** Relative path from the referencing file. One level deep from SKILL.md per Agent Skills spec.
4. **Form:** Inline markdown link. No resolution table, no admonition.
5. **Meaning:** The agent MUST call a file-loading tool (`read`, `editor_read_file`, `editor_viewport open`, etc.) on the linked path. The content is actionable, not informational.

### Examples

```
Load [the DISPATCH_GATE protocol](.opencode/.guidelines/dispatch-gate-protocol.md)
Load [the timeout configuration](references/TimeoutConfig.md)
Load [the error handling procedure](references/ErrorHandling.md)
```

## Candidate Verb List (Confirmation Phase)

The following 8 verbs MUST be tested for confirmation. The list is derived from #1988 empirical data:

| # | Verb | #1988 Access Rate | #1988 Content Used? | Priority |
|---|------|-------------------|---------------------|----------|
| 1 | **Load** | 100% (3/3) | ✅ Yes | **Leading candidate** |
| 2 | Open | 100% (3/3) | ✅ Yes | Confirm |
| 3 | Check | 100% (3/3) | ✅ Yes | Confirm |
| 4 | Consult | 100% (2/2) | ✅ Yes | Confirm |
| 5 | MUST read | 100% (3/3) | ✅ Yes | Confirm |
| 6 | See | 100% (3/3) | ❌ No | **Defective baseline** |
| 7 | Read | 67% (2/3) | ❌ No | **Defective baseline** |
| 8 | Fetch | 100% (3/3) | ❌ No | **Defective baseline** |

## Test Methodology

### Test Environment

Each test uses the verb test runner from #1988 at `tmp/1988/run-verb-test.sh` with the following configuration:

- **Test project:** Isolated git repo with `.opencode` submodule cloned from remote
- **Task card:** Contains the verb directive referencing `references/TimeoutConfig.md` (timeout=30)
- **Prompt:** "Run `sleep` in the bash shell. Use the timeout from the reference guide."
- **Model:** ollama/qwen3.6:35b-256k
- **Runs per verb:** 3 (confirms #1988's 3-run data)

### What "Works" Means

A verb form is considered to "work" when ALL of the following conditions are met:

1. **Agent loads the referenced file content into context** — stderr MUST show a file-loading tool call targeting the exact file path
2. **Agent uses the content correctly** — the agent must apply the value from the file (e.g., use `timeout=30` for sleep), not just read and ignore it
3. **Agent does NOT use grep/search as a substitute** — stderr MUST NOT show grep/search tool calls targeting the same content
4. **Low deliberation** — the agent should access the file directly, with minimal failed tool attempts before success

### Test Record Format

Each test run produces a row in the test record table:

| Verb | Run | Did agent load file? | Did agent use content correctly? | Tool used | Deliberation steps | Time | Notes |

### Test Execution

Each verb variant MUST be tested at least 3 times. A verb is classified as "reliable" if it triggers file load AND correct content use in at least 2 out of 3 runs.

## Implementation Phases

### Phase 1 — Verb Confirmation (3 runs × 8 verbs = 24 runs)

Run the verb test harness from #1988 to confirm "Load" as the winning verb. Produce a test record table with deliberation quality data.

### Phase 2 — Update Canonical Format Documentation

1. Update `000-critical-rules.md` — change `Read [Text](path)` to `Load [Text](path)` in the cross-reference rule
2. Update `INDEX.md` if it references the old pattern
3. Document the canonical format in a dedicated section

### Phase 3 — Update All Skill Cards

For every SKILL.md in `.opencode/skills/*/`:
1. Find all `See [file](path)` patterns — change to `Load [file](path)`
2. Find all `Read [file](path)` patterns — change to `Load [file](path)`
3. Find all bare `§N` or symbol-only references — change to inline link with descriptive text
4. Find all resolution tables + admonitions — remove (form is not viable per #1988)

### Phase 4 — Update Guidelines

For every guideline in `.opencode/guidelines/*.md`:
1. Find all `See [file](path)` patterns — change to `Load [file](path)`
2. Find all `Read [file](path)` patterns — change to `Load [file](path)`
3. Find all bare `§N` or symbol-only references — change to inline link with descriptive text

### Phase 5 — Update default.txt

Update `.opencode/prompts/default.txt` to use the `Load [Text](path)` pattern in any cross-reference directives.

### Phase 6 — Supersede and Inform

1. Close #1953 as superseded by this spec
2. Add a comment to #1925 referencing this spec's canonical format
3. Add a comment to #1926 referencing this spec's canonical format

## Success Criteria

| ID | Criterion | Evidence Type | PASS Threshold | Verification Method |
|----|-----------|---------------|----------------|---------------------|
| SC-1 | All 8 candidate verbs tested at least 3 times each with deliberation quality recorded | behavioral | All verbs have ≥3 runs with deliberation steps recorded | Check measurement log |
| SC-2 | A winning verb is identified: triggers file load AND correct content use in ≥2/3 runs | behavioral | At least one verb meets the threshold | Analyze test record |
| SC-3 | "Load" confirms as the winning verb (≥2/3 runs with file load + correct content use) | behavioral | Load achieves ≥2/3 on both criteria | Analyze test record |
| SC-4 | `000-critical-rules.md` updated: `Read [Text](path)` → `Load [Text](path)` | string | grep for `Load [Text]` in 000-critical-rules.md | grep |
| SC-5 | All SKILL.md files updated: no `See [file]` or `Read [file]` patterns remain | string | grep count of `See [` and `Read [` in `.opencode/skills/*/SKILL.md` is zero | grep |
| SC-6 | All guideline files updated: no `See [file]` or `Read [file]` patterns remain | string | grep count of `See [` and `Read [` in `.opencode/guidelines/*.md` is zero | grep |
| SC-7 | No resolution table + admonition patterns remain in any SKILL.md | string | grep for `| Reference | File |` in `.opencode/skills/*/SKILL.md` is zero | grep |
| SC-8 | #1953 closed as superseded with comment linking to this spec | structural | Issue #1953 state is `closed` with `state_reason: not_planned` | GitHub API |
| SC-9 | #1925 and #1926 have comments linking to this spec's canonical format | structural | Comments exist on both issues referencing this spec | GitHub API |

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Model produces empty output | Retry up to 2 times; record as FAIL if all retries empty |
| Model times out | Increase bash tool timeout to 600000ms; retry |
| Verb triggers partial read (reads but doesn't use content) | Record as "partial" in Notes; does not count as full PASS |
| Verb triggers read but also triggers grep/search | Record both; verb is disqualified if grep/search substitutes for read content |
| SKILL.md has no cross-references | No change needed — skip |
| Guideline has no cross-references | No change needed — skip |
| Link text is already descriptive | No change needed — only verb needs updating |

## Implementation Approach

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1958/plan.md` before implementation begins.

The implementation plan MUST:

1. Use the canonical `skill({name: "..."})` → `task(..., prompt: "execute <task> task from <skill>")` form for every dispatch step
2. NOT contain inline procedure text — the plan is a routing document, not a re-implementation of skill task cards
3. Enumerate the full implementation pipeline with no skipped or combined steps: coherence gate, pre-red-baseline, RED/GREEN per item, VbC, audit, cross-validate, regression check, finishing checklist, review-prep, cleanup
4. Reference the correct skill/task combination for each step

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Use #1988 verb test harness for confirmation | Already proven; 24 runs completed; no need to rebuild | MUST | SC-1, SC-2 |
| DEC-2 | Test each verb 3 times | Matches #1988 methodology; model output is non-deterministic | MUST | SC-1 |
| DEC-3 | Default model is `ollama/qwen3.6:35b-256k` | Matches #1988; matches `default-model.sh` | MUST | SC-1 |
| DEC-4 | Inline link form is settled | #1988 proved 100% vs 42-58% for alternatives | MUST | SC-4, SC-5, SC-6 |
| DEC-5 | Supersede #1953 | Its premise is validated but its fix is too narrow | MUST | SC-8 |

## Risk Traceability Table

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Model behavior varies across runs | High | Medium | Test each verb 3 times; use majority vote | SC-1 |
| RISK-2 | "Load" does not confirm as winner | Low | High | Fall back to next-best verb (Open/Check/Consult) | SC-3 |
| RISK-3 | grep-based SCs miss edge cases in skill cards | Medium | Low | Manual spot-check of 5 random SKILL.md files | SC-5, SC-6 |
| RISK-4 | Model unavailable during testing | Low | High | Retry with increased timeout | SC-1 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Test record table | MUST | Regenerate if candidate list changes |
| Winning verb analysis | MUST | Re-analyze if test methodology changes |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

Co-authored with AI: OpenCode (deepseek-v4-flash)
