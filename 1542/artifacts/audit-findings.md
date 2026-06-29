# Audit Findings: Word/Line Count and Cost-Frame Patterns in Skills & Guidelines

**Audit scope:** All `.opencode/skills/*/SKILL.md`, `.opencode/skills/*/tasks/*.md`, `.opencode/guidelines/*.md`
**Date:** 2026-06-28
**Total findings:** 56

---

## Summary Table

| # | File | Lines | Classification | Severity |
|---|------|-------|----------------|----------|
| 1 | `guidelines/091-incremental-build.md` | 45-64 | `document-size-as-effort` | HIGH |
| 2 | `guidelines/091-incremental-build.md` | 137-138 | `document-size-as-effort` | HIGH |
| 3 | `skills/programming-principles/SKILL.md` | 13 | `document-size-as-effort` | HIGH |
| 4 | `skills/programming-principles/tasks/principles.md` | 418-444 | `document-size-as-effort` | HIGH |
| 5 | `skills/programming-principles/tasks/principles.md` | 425 | `document-size-as-effort` | MEDIUM |
| 6 | `skills/programming-principles/tasks/principles.md` | 429 | `document-size-as-effort` | MEDIUM |
| 7 | `skills/spec-creation/tasks/write.md` | 603 | `document-size-as-effort` | MEDIUM |
| 8 | `skills/brainstorming/tasks/explore/exploration-workflow.md` | 90 | `document-size-as-effort` | LOW |
| 9 | `skills/issue-operations/tasks/comment.md` | 208 | `document-size-as-effort` | LOW |
| 10 | `guidelines/060-tool-usage.md` | 11 | `operational-bookkeeping-as-complexity` | MEDIUM |
| 11 | `guidelines/060-tool-usage.md` | 201 | `operational-bookkeeping-as-complexity` | LOW |
| 12 | `guidelines/020-go-prohibitions.md` | 78-114 | `byte-dispatch-as-complexity` | HIGH |
| 13 | `guidelines/020-go-prohibitions.md` | 164-174 | `byte-dispatch-as-complexity` | HIGH |
| 14 | `guidelines/000-critical-rules.md` | 757-758 | `byte-dispatch-as-complexity` | MEDIUM |
| 15 | `guidelines/000-critical-rules.md` | 760-761 | `byte-dispatch-as-complexity` | MEDIUM |
| 16 | `guidelines/000-critical-rules.md` | 963-964 | `cost-language-as-effort` | LOW |
| 17 | `skills/writing-plans/tasks/write.md` | 121 | `cost-language-as-effort` | MEDIUM |
| 18 | `skills/issue-operations/platforms/github-mcp/SKILL.md` | 3 | `cost-language-as-effort` | LOW |
| 19-53 | 35 SKILL.md files (see §Context Cost Frame Instances) | various | `operational-bookkeeping-as-complexity` | LOW |
| 54 | `skills/approval-gate/tasks/screen-issue.md` | 38 | `document-size-as-effort` | LOW |
| 55 | `skills/approval-gate/tasks/screen/screen-issue-gate2.md` | 22, 179 | `document-size-as-effort` | LOW |
| 56 | `skills/approval-gate/enforcement/work-state-schema.md` | 53 | `document-size-as-effort` | LOW |

---

## Detailed Findings Grouped by File

### 1. `guidelines/091-incremental-build.md` — The Canonical Source

This file is the primary origin of word-count-as-complexity-metric in the system. It defines word count as the "canonical complexity metric" and hard-enforces size limits.

**Finding 1: Word count declared as canonical complexity metric** (HIGH)

Lines 45-64:
```markdown
## Complexity Metric: Word Count

Word count (`wc -w`) is the canonical complexity metric for all skill task files, SKILL.md files, and guideline files. Line counts are not used because line length varies by formatting conventions and does not correlate with semantic density.

### Artifact Size Limits

| Artifact Type | Max Words | Measurement |
| -- | -- | -- |
| Atomic task file | ≤3,000 | `wc -w` |
| Routing-tier SKILL.md | ≤4,000 | `wc -w` |
| Condensed-tier SKILL.md | ≤2,000 | `wc -w` |
| Guideline file | Per content needs | `wc -w` |

When a task file exceeds 3,000 words on first draft, it MUST be split into smaller atomic tasks, each with a single concern and entry/exit criteria. This is a hard constraint, not a guideline.
```

Classification: `document-size-as-effort` — Directly tells agents to use word count as the metric for implementation complexity and splitting decisions.

**Finding 2: Symbolic rule enforcing word-count limit** (HIGH)

Lines 137-138:
```yaml
  - id: incremental-build-006
    title: "Task files must not exceed 3000 words"
```

Classification: `document-size-as-effort` — Enforceable rule treating word count as a complexity boundary.

---

### 2. `skills/programming-principles/SKILL.md` — Code Size Limits

**Finding 3: Word-count-based code size limits** (HIGH)

Line 13:
```
20 engineering principles as single authoritative source for design judgment and enforcement.
Also includes code size limits (formerly `code-size-enforcement` skill): Python functions ≈100 words,
notebook cells ≈120 words, source files ≈750 words. Grandfather policy exempts existing files;
only new/modified files must comply.
```

Classification: `document-size-as-effort` — Presents word count as the complexity threshold for code decomposition.

---

### 3. `skills/programming-principles/tasks/principles.md` — Decomposition Thresholds

**Finding 4: Line-count-based decomposition thresholds** (HIGH)

Lines 434-444:
```markdown
### Decomposition Thresholds

| Threshold | Action |
|-----------|--------|
| File > 400 lines | Split into multiple files |
| Function > 30 lines | Extract helper functions |
| Method > 50 lines | Extract sub-methods or delegate |
| Class > 7 methods | Extract to delegate class |
| Class file > 300 lines | Split into focused sub-classes |
```

Classification: `document-size-as-effort` — Directly tells agents to use line counts as triggers for implementation decisions (splitting code).

**Finding 5: Word count as measurement method** (MEDIUM)

Line 425:
```
For word counts, use `wc -w` on specific function ranges.
```

Classification: `document-size-as-effort` — Instruction to measure function complexity by word count.

**Finding 6: Line count as measurement method** (MEDIUM)

Lines 428-430:
```
**Source Files:**
wc -l <filepath>
```

Classification: `document-size-as-effort` — Instruction to measure file complexity by line count.

---

### 4. `skills/spec-creation/tasks/write.md` — Spec Length Constraints

**Finding 7: Word-count-based spec length constraint** (MEDIUM)

Line 603:
```
| Length | 150-300 words, 1 page max |
```

Classification: `document-size-as-effort` — Presents word count as a constraint on spec content volume.

---

### 5. `skills/brainstorming/tasks/explore/exploration-workflow.md` — Design Section Scaling

**Finding 8: Word-count-based section scaling guidance** (LOW)

Line 90:
```
- Scale each section: a few sentences if straightforward, 200-300 words if nuanced
```

Classification: `document-size-as-effort` — Suggests word count as a proxy for design complexity.

---

### 6. `skills/issue-operations/tasks/comment.md` — Comment Length

**Finding 9: Word-count-based comment length guidance** (LOW)

Line 208:
```
| Summary too long | Reduce to 1-2 sentences |
```

Classification: `document-size-as-effort` — Treats word/sentence count as a complexity signal for comment content.

---

### 7. `guidelines/060-tool-usage.md` — Progressive Disclosure

**Finding 10: Word-count budget for orchestrator context** (MEDIUM)

Line 11:
```
The orchestrator holds only `.opencode/guidelines/INDEX.md` (trigger-pattern pairs, ≤1,500 words)
for routing decisions.
```

Classification: `operational-bookkeeping-as-complexity` — Uses word count to describe context budget as an operational constraint.

**Finding 11: Word-count comparison for task files vs. result contracts** (LOW)

Line 201:
```
Result contracts (≈100-500 words) are read instead of the full task file (>1,000 words)
```

Classification: `operational-bookkeeping-as-complexity` — Presents word count as a proxy for context cost.

---

### 8. `guidelines/020-go-prohibitions.md` — The Context Cost Model

This file defines the byte-dispatch formulas and the "Cost-Frame Dark Prose" blocks that propagate across all skills.

**Finding 12: Byte-dispatch formulas as complexity model** (HIGH)

Lines 78-114:
```markdown
**Orchestrator Context Cost:**
```
orchestrator_cost = size × remaining_dispatches²
```
- `size` = bytes held by orchestrator
- `remaining_dispatches` = number of future `task()` calls in the pipeline

Example: holding a 500-byte inline analysis artifact when 12 dispatches remain:
- `500 × 12² = 500 × 144 = 72,000 byte-dispatches`

**Sub-Agent Context Cost:**
```
sub_agent_cost = size × 1
```

**Result Contract Cost:**
```
result_contract_cost = size × (remaining_dispatches - 1)
```
```

Classification: `byte-dispatch-as-complexity` — Presents byte-dispatch formulas as implementation complexity measures. The formulas are framed as "cost" metrics that drive architectural decisions.

**Finding 13: Cost-Frame Dark Prose blocks** (HIGH)

Lines 164-174:
```markdown
**Orchestrator Context Lean:**
> The orchestrator's context is the most expensive resource in the pipeline. Every byte held
> costs `byte × remaining_dispatches²` — and context is monotonic, never shrinking. Loading a
> task file inline costs 3,000 words × 144 = 432,000 word-dispatches for a 12-step pipeline.

**Sub-Agent Context Generosity:**
> The sub-agent's context is a disposable resource. Every byte burned in the sub-agent is a byte
> the orchestrator does not have to hold.

**Result Contract Frugality:**
> The only thing that returns from a sub-agent enters the orchestrator's cost function. Every byte
> in the result contract costs `byte × (remaining_dispatches - 1)`.
```

Classification: `byte-dispatch-as-complexity` — These prose blocks present byte-dispatch arithmetic as relevant to implementation decisions. The word-dispatch calculation (`3,000 words × 144 = 432,000 word-dispatches`) directly conflates document size with pipeline cost.

---

### 9. `guidelines/000-critical-rules.md` — Critical Rules Propagation

**Finding 14: Byte-dispatch formula in critical rules** (MEDIUM)

Lines 757-758:
```markdown
### [critical-rules-063] Orchestrator Context Lean — orchestrator holds routing metadata only
The orchestrator's context is the most expensive resource in the pipeline. Every byte held costs
`byte × remaining_dispatches²` — and context is monotonic, never shrinking.
```

Classification: `byte-dispatch-as-complexity` — Critical rule presenting the formula as a binding constraint.

**Finding 15: Result contract cost formula in critical rules** (MEDIUM)

Lines 760-761:
```markdown
### [critical-rules-065] Result Contract Frugality — result contracts limited to routing-significant data
The only thing that returns from a sub-agent enters the orchestrator's cost function. Every byte
in the result contract costs `byte × (remaining_dispatches - 1)`.
```

Classification: `byte-dispatch-as-complexity` — Presents the formula as a cost driver for implementation.

**Finding 16: Terminology standardization for cost language** (LOW)

Lines 963-964:
```markdown
### [critical-rules-066] Terminology Standardization — all context cost references must use standardized vocabulary
All references to "context budget", "context cost", and "context awareness" must use the
standardized vocabulary: "orchestrator context", "sub-agent context", and "orchestrator context discipline".
```

Classification: `cost-language-as-effort` — Codifies cost language as a standard vocabulary, reinforcing the cost-as-effort framing.

---

### 10. `skills/writing-plans/tasks/write.md` — Cost of an Extra Step

**Finding 17: "Cost of an extra step" language** (MEDIUM)

Line 121:
```
No step may be omitted because the plan writer judges it "not needed." If a step appears
unnecessary, include it anyway — the cost of an extra step is negligible compared to the
cost of rework from a skipped step.
```

Classification: `cost-language-as-effort` — Uses "cost of an extra step" and "cost of rework" as effort-estimation language. While the intent is correct (don't skip steps), the framing presents step count as a quantifiable cost.

---

### 11. `skills/issue-operations/platforms/github-mcp/SKILL.md` — Wasted Effort

**Finding 18: "Wasted effort" language** (LOW)

Line 3 (description):
```
API calls without owner/repo verification target the wrong repository. Every misrouted call
is wasted effort.
```

Classification: `cost-language-as-effort` — "Wasted effort" frames misrouted calls in effort/cost terms.

---

### 12. Context Cost Frame Instances (35 SKILL.md Files)

**Finding 19-53: Identical context cost frame block in 35 SKILL.md files** (LOW per file, HIGH aggregate)

Each of the following files contains the identical block:
```markdown
> **Context cost frame:** The orchestrator's context is the most expensive resource in the pipeline
> — sub-agents do the work, not the orchestrator. Every byte held by the orchestrator costs
> `byte × remaining_dispatches²`. See `020-go-prohibitions.md` §1.1.
```

Files and line numbers:

| # | File | Line |
|---|------|------|
| 19 | `skills/approval-gate/SKILL.md` | 66 |
| 20 | `skills/brainstorming/SKILL.md` | 74 |
| 21 | `skills/changelog-generator/SKILL.md` | 63 |
| 22 | `skills/completeness-gate/SKILL.md` | 48 |
| 23 | `skills/completion-core/SKILL.md` | 121 |
| 24 | `skills/conflict-resolution/SKILL.md` | 72 |
| 25 | `skills/correspondence/SKILL.md` | 69 |
| 26 | `skills/engineering-approach/SKILL.md` | 72 |
| 27 | `skills/executing-plans/SKILL.md` | 84 |
| 28 | `skills/finishing-a-development-branch/SKILL.md` | 74 |
| 29 | `skills/git-workflow/SKILL.md` | 139 |
| 30 | `skills/implementation-pipeline/SKILL.md` | 156 |
| 31 | `skills/issue-operations/SKILL.md` | 122 |
| 32 | `skills/issue-review/SKILL.md` | 78 |
| 33 | `skills/mcp-tool-usage/SKILL.md` | 50 |
| 34 | `skills/multimodal-dispatch/SKILL.md` | 64 |
| 35 | `skills/plan/SKILL.md` | 57 |
| 36 | `skills/pr-creation-workflow/SKILL.md` | 86 |
| 37 | `skills/pre-analysis/SKILL.md` | 56 |
| 38 | `skills/programming-principles/SKILL.md` | 64 |
| 39 | `skills/receiving-code-review/SKILL.md` | 73 |
| 40 | `skills/research/SKILL.md` | 61 |
| 41 | `skills/requesting-code-review/SKILL.md` | 57 |
| 42 | `skills/skill-creator/SKILL.md` | 77 |
| 43 | `skills/solve/SKILL.md` | 70 |
| 44 | `skills/spec-creation/SKILL.md` | 95 |
| 45 | `skills/sre-runbook/SKILL.md` | 71 |
| 46 | `skills/sync-guidelines/SKILL.md` | 66 |
| 47 | `skills/systematic-debugging/SKILL.md` | 69 |
| 48 | `skills/test-driven-development/SKILL.md` | 172 |
| 49 | `skills/using-git-worktrees/SKILL.md` | 70 |
| 50 | `skills/verification/SKILL.md` | 61 |
| 51 | `skills/verification-before-completion/SKILL.md` | 89 |
| 52 | `skills/verification-enforcement/SKILL.md` | 73 |
| 53 | `skills/issue-operations/platforms/local/SKILL.md` | 207 |

Classification: `operational-bookkeeping-as-complexity` — Each instance propagates the byte-dispatch formula as a relevant consideration for orchestrator behavior. The formula itself is operational bookkeeping (context management), but presenting it in every SKILL.md as a "cost frame" implies it is an implementation complexity measure.

---

### 13. Result Contract Word-Count Constraints

**Finding 54-56: Word-count limits on result contracts** (LOW)

| File | Line | Text |
|------|------|------|
| `skills/approval-gate/tasks/screen-issue.md` | 38 | `Compact result contract produced (≈100-500 words, YAML-structured)` |
| `skills/approval-gate/tasks/screen/screen-issue-gate2.md` | 22 | `Compact result contract produced (≈100-500 words, YAML-structured)` |
| `skills/approval-gate/tasks/screen/screen-issue-gate2.md` | 179 | `The result contract MUST be YAML-structured, compact (≈100-500 words)` |
| `skills/approval-gate/enforcement/work-state-schema.md` | 53 | `Task results MUST be compact (≤500 words per section)` |

Classification: `document-size-as-effort` — Treats word count as a proxy for result contract complexity.

---

## Classification Breakdown

### By Classification

| Classification | Count | Severity Range |
|----------------|-------|----------------|
| `document-size-as-effort` | 22 | LOW to HIGH |
| `operational-bookkeeping-as-complexity` | 37 | LOW to MEDIUM |
| `byte-dispatch-as-complexity` | 5 | HIGH |
| `cost-language-as-effort` | 3 | LOW to MEDIUM |
| **Total** | **56** (some overlap) | |

### By Severity

| Severity | Count | Description |
|----------|-------|-------------|
| **HIGH** | 10 | Directly tells agents to use these metrics for implementation decisions (splitting, decomposition, architecture) |
| **MEDIUM** | 10 | Presents them as relevant to implementation (cost framing, measurement methods, critical rules) |
| **LOW** | 36 | Incidental mention or propagation (context cost frame blocks, minor references) |

### High-Severity Findings (Actionable)

These findings directly instruct agents to make implementation decisions based on document size or cost formulas:

1. **`091-incremental-build.md:47`** — Declares word count as "canonical complexity metric" with hard split thresholds
2. **`091-incremental-build.md:58`** — "MUST be split" when exceeding 3,000 words
3. **`091-incremental-build.md:138`** — Symbolic rule: "Task files must not exceed 3000 words"
4. **`programming-principles/SKILL.md:13`** — Word-count-based code size limits (≈100/120/750 words)
5. **`programming-principles/tasks/principles.md:434-444`** — Line-count-based decomposition thresholds (400/30/50/7/300 lines)
6. **`020-go-prohibitions.md:78-114`** — Byte-dispatch formulas presented as cost/complexity model
7. **`020-go-prohibitions.md:164-174`** — Cost-Frame Dark Prose blocks with word-dispatch arithmetic

---

## Observations

1. **The `091-incremental-build.md` guideline is the root cause** of word-count-as-complexity-metric. It explicitly declares "Word count (`wc -w`) is the canonical complexity metric" and propagates this through symbolic rules and size-limit tables.

2. **The `020-go-prohibitions.md` §1.1 Context Cost Model is the root cause** of byte-dispatch formulas. The formulas (`size × remaining_dispatches²`) are operational bookkeeping for context management, but they are presented as cost metrics that influence dispatch decisions.

3. **The 35 SKILL.md context cost frame blocks are copy-paste propagation** from the §1.1 model. Each instance reinforces the byte-dispatch formula as relevant to agent behavior.

4. **The `programming-principles/tasks/principles.md` decomposition thresholds** (File > 400 lines → Split) are a separate but related pattern: line counts as implementation complexity triggers.

5. **The "cost of an extra step" language in `writing-plans/tasks/write.md`** is the only instance of step-count-as-cost framing, but it is framed correctly (don't skip steps).

6. **The `document-size-as-effort` and `byte-dispatch-as-complexity` classifications overlap** in the context cost frame — word count (`3,000 words × 144 = 432,000 word-dispatches`) appears inside the byte-dispatch formula block, conflating document size with pipeline cost.
