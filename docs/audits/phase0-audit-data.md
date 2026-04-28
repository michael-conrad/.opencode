# Phase 0 Audit Data: Skills vs Pre-Regression Baseline

**Baseline Commit:** 61ca465
**Audit Date:** 2026-04-28
**Methodology:** AI-Agent Baseline Comparison (8 check dimensions)

## Check Dimensions

| # | Dimension | Description |
|---|-----------|-------------|
| 1 | Workflow completeness | Does the skill describe the complete workflow from start to finish? |
| 2 | Gating behavior | Are mandatory/optional gates correctly classified with Tier 1/2 mandates? |
| 3 | Verification requirements | Are verification steps present, correct, and producing evidence artifacts? |
| 4 | Principles/concerns | Are design principles and domain concerns documented? |
| 5 | Cross-references | Are references to related skills and guidelines present? |
| 6 | Duplication detection | Is content unnecessarily duplicated between SKILL.md and task files? |
| 7 | Mermaid diagrams | Are workflow diagrams present where the baseline had them or where needed? |
| 8 | Platform-agnostic | Are hardcoded identity values replaced with runtime tokens? |

## Per-Dimension Classification

| Value | Meaning |
|-------|---------|
| CORRECT | Matches baseline intent fully |
| PARTIAL | Matches baseline intent partially (some gaps) |
| WRONG | Contradicts baseline intent |
| MISSING | Baseline had it, current doesn't |
| DUPLICATED | Content unnecessarily repeated across files |


## Per-Skill Data

### approval-gate

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 1039 | 220 |
| Task file count | 29 | N/A |
| Task total lines | 2700 | N/A |
| Mandatory language | YES | — |
| Optional language | YES ⚠️ | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Possible | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: approval-gate
description: Authorization gatekeeper ensuring all code changes follow spec + authorization workflow. Verifies specs exist, authorization is explicit, sub-issues structure is correct.
license: MIT
compatibility: opencode
---

# Skill: approval-gate

## Overview

Authorization Gatekeeper ensuring all code changes follow the spec + authorization workflow. Invoked automatically before implementation begins.

## Persona

You are an Authorization Gatekeeper. Your focus is ensuring all code changes follow the spec + authorization workflow.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `verify-qa-mode` | Detect spec-less implementation requests, switch to Q/A mode | ~800 |
| `verify-authorization` | Check explicit auth and needs-approval label | ~400 |
| `verify-sub-issues` | Verify sub-issue structure for multi-task specs | ~480 |
| `verify-codebase` | Re-evaluate codebase state, detect staleness | ~400 |
| `verify-blockers` | Check for blocking issues/dependencies | ~320 |
| `verify-open-questions` | Check for unresolved questions in spec | ~370 |
| `post-implementation` | Push branch, generate compare URL, HALT | ~480 |

## Invocation

- `/skill approval-gate --task verify-authorization` - Check auth before work
- `/skill approval-gate --task verify-sub-issues` - Check sub-issue structure
- `/skill approval-gate --task verify-codebase` - Check codebase state
- `/skill approval-gate --task verify-blockers` - Check for blockers
- `/skill approval-gate --task verify-open-questions` - Check for unresolved questions
- `/skill approval-gate --task post-implementation` - After implementation done
- `/skill approval-gate` - Overview only

## Operating Protocol

1. **Automatic invocation (mandatory):** This skill is referenced when:
   - User says `approved`, `go`, or similar authorization
   - User asks about approval workflow
   - Implementation is about to begin
   - DO NOT prompt for invocation - the skill is triggered automatically

2. **Pre-Implementation Verification:**
   - Verify spec exists as GitHub Issue
   - Verify spec has received explicit authorization
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: approval-gate
description: Use when user says "approved", "go", or any implementation instruction, or when authorization needs verification. Triggers on: approval, authorized, implement, start work, go ahead, needs-approval label, authorization set, multiple issues approved, interdependency analysis.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: approval-gate

## Overview

Authorization Gatekeeper ensuring all code changes follow the spec + authorization workflow. The agent MUST invoke this skill before implementation begins.

## Persona

You are an Authorization Gatekeeper. Your focus is ensuring all code changes follow the spec + authorization workflow.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `verify-qa-mode` | Detect spec-less implementation requests, switch to Q/A mode | ≈800 |
| `verify-authorization` | Check explicit auth and needs-approval label; delegates branch creation to `git-workflow --task pre-work` | ≈400 |
| `verify-authorization/scope-auto-resolve` | Step 0.5: Scope auto-resolve from authorization phrase | ≈200 |
| `verify-authorization/item-decomposition-check` | Step 4.5: Verify item decomposition in plan | ≈250 |
| `verify-authorization/sc-traceability-check` | Step 4.6: SC-to-test traceability and RED-phase ordering | ≈350 |
| `verify-authorization/sub-issue-verification` | Step 5: Verify sub-issue structure (authoritative gate) | ≈600 |
| `verify-authorization/spec-to-plan-cascade` | Step 5b: Spec-to-plan approval cascade | ≈400 |
| `verify-authorization/gap-fill-cascade` | Step 5b.5 + 5c: Gap-fill precedence and cascade execution | ≈500 |
| `verify-authorization/auto-dispatch` | Step 6: Scope-aware auto-dispatch + output lineage | ≈500 |
| `verify-sub-issues` | Verify sub-issue structure for multi-task specs | ≈480 |
| `verify-codebase` | Re-evaluate codebase state, detect staleness | ≈400 |
| `verify-already-implemented` | Check if all success criteria are already met; autoclose if so | ≈400 |
| `verify-blockers` | Check for blocking issues/dependencies | ≈320 |
| `verify-open-questions` | Check for unresolved questions in spec | ≈370 |
| `verify-fix-spec` | For bug reports, verify fix spec sub-issue exists before closure | ≈250 |
| `search-prompt-fail` | Search GitHub Issues for existing spec/plan candidates before Q/A halt; present candidates or report failure | ≈300 |
| `verify-closed-issue` | Verify that a closed issue was legitimately closed via merged PR; enforce "closed ≠ verified" rule | ≈350 |
| `screen-issue` | Per-issue screening for pre-implementation analysis (routing document for gate1 + gate2); dispatched as parallel sub-agents | ≈250 |
| `screen-issue/gate1` | Gate 1: Read issue, screening categories, sub-issue enumeration | ≈1,900 |
| `screen-issue/gate2` | Gate 2: Success criteria verification, cross-reference traversal, evidence audit, result contract | ≈2,500 |
| `pre-implementation-analysis` | Cross-issue merge of screening results, dependency graph, execution plan for assemble-work (routing document) | ≈425 |
| `pre-impl/collect-screening-results` | Steps -1, 0, 0.1, 0.15, 0.5: mandatory dispatch, collect results, autonomous classification, gate evidence audit | ≈1,200 |
| `pre-impl/reconcile-status` | Step 0.7: reconcile issue status inconsistencies via reconcile-issue-graph | ≈600 |
| `pre-impl/build-dependency-graph` | Steps 1, 2, 3, 4: flat item list, cross-issue analysis, classify issues, dependency graph | ≈1,600 |
| `pre-impl/check-cross-spec-overlap` | Cross-spec overlap check against open specs/plans outside batch | ≈500 |
| `pre-impl/write-work-state` | Steps 5, 7, 8, 9: execution strategy, dev base hash, dispatch context, work state file | ≈720 |
| `pre-impl/yield-to-assemble-work` | Steps 6, 10: present execution plan, execute immediately to assemble-work | ≈920 |
```

### brainstorming

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 164 | 200 |
| Task file count | 5 | N/A |
| Task total lines | 309 | N/A |
| Mandatory language | YES | — |
| Optional language | No | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: brainstorming
description: Mandatory pre-spec brainstorming workflow ensuring thorough requirements exploration and alternatives analysis before spec creation.
license: MIT
compatibility: opencode
---

# Skill: brainstorming

## Overview

Mandatory pre-spec brainstorming workflow that ensures thorough requirements exploration and alternatives analysis before any spec creation. This skill is adapted from the NewsRx/opencode-gitbucket-superpowers workflow and enforces systematic thinking before implementation planning.

**Source Attribution:** This skill is adapted from NewsRx/opencode-gitbucket-superpowers workflow (branch: newsrx).

## Persona

You are a Requirements Explorer and Design Thinker. Your focus is ensuring comprehensive brainstorming happens before any spec is created.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `mandatory` | Full brainstorming workflow (default) | ~1200 |

## Invocation

- `/skill brainstorming` - Complete brainstorming workflow
- `/skill brainstorming --task mandatory` - Same as above

## Operating Protocol

1. **Automatic invocation (mandatory):** This skill is auto-invoked by dispatch-table.yaml when:
   - User says `spec` or `plan` or similar planning terms
   - User asks about spec creation workflow
   - User provides feature description for planning
   - DO NOT proceed to spec creation until brainstorming completes

2. **Manual invocation:** User can invoke explicitly:
   - `/skill brainstorming` to start fresh brainstorming session
   - Brainstorming can be restarted if new requirements emerge

3. **Exit conditions:** Brainstorming is COMPLETE when:
   - All five dimensions explored
   - Alternatives documented with tradeoffs
   - User confirms requirements are complete
   - HALT and wait for explicit approval to proceed to spec creation

## Mandatory Brainstorming Dimensions

```

#### Current SKILL.md Content (first 50 lines)
```
---
name: brainstorming
description: Use when creating a spec, planning a feature, or exploring requirements before implementation. Triggers on: spec, plan, feature, brainstorm, explore, requirements, ideate, think through, what should.
type: technique
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: brainstorming

## Overview

Conversational-first exploration workflow. One question at a time, user-driven, with dimensions used only as an internal mental checklist — never as structured output sections.

**Source:** Adapted from [obra/superpowers brainstorming](https://github.com/obra/superpowers/blob/main/skills/brainstorming/SKILL.md). Key adaptations: no visual companion by default (conditional offer only for visual topics), no hard design-approval gate before writing-plans (our pipeline has approval-gate), dimensions used internally never as output sections, terminal state invokes spec-creation.

Co-authored with AI: <AgentName> (<ModelId>)

## Persona

You are a Requirements Explorer. Your focus is understanding what the user wants through natural conversation — one question at a time, following their answers, not a predetermined checklist.

## Tasks

| Task | Purpose | Words |
| -- | -- | -- |
| `explore` | Full conversational exploration workflow (default) | ≈1000 |
| `top-down-analysis` | Top-down decomposition output: item enumeration, dependency graph, ordering, acceptance criteria | ≈400 |
| `enforcement` | Enforcement rules, protocol-compliance verification, and investigation completion criteria | ≈600 |
| `cross-scope` | Cross-spec scope search — check for overlapping specs before exploration | ≈350 |
| `completion` | Ensure mandatory terminal-state dispatch occurred; remediate if not; report status | ≈200 |

## Sub-Agent Tasks

| Task | Words |
|------|-------|
| `explore` | ≈1000 |
| `top-down-analysis` | ≈400 |
| `enforcement` | ≈600 |
| `cross-scope` | ≈350 |
| `completion` | ≈200 |

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `explore` | When brainstorming/spec exploration is invoked | User request, topic, github.owner, github.repo | Implementation context, agent memory, other agents' results | NO |
| `top-down-analysis` | When decomposition output is requested | Exploration results, topic | Implementation context, agent memory | NO |
| `enforcement` | When protocol compliance verification is needed | Exploration transcript, protocol rules | Implementation context, agent memory | NO |
```

### changelog-generator

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 336 | 125 |
| Task file count | 4 | N/A |
| Task total lines | 423 | N/A |
| Mandatory language | YES | — |
| Optional language | YES ⚠️ | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: changelog-generator
description: Automatically creates user-facing changelogs from git commits by analyzing commit history, categorizing changes, and transforming technical commits into clear, customer-friendly release notes. Turns hours of manual changelog writing into minutes of automated generation.
license: MIT
compatibility: opencode
---

# Skill: changelog-generator

This skill transforms technical git commits into polished, user-friendly changelogs that your customers and users will actually understand and appreciate.

## Prerequisites

- **Git**: Required for reading commit history
- **Repository access**: Must be run from a git repository root
- **Optional**: Custom changelog style guide (CHANGELOG_STYLE.md)

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `since-last-release` | Generate changelog for commits since last CHANGELOG.md update | ~170 |
| `date-range` | Generate changelog for commits within specific date range | ~90 |
| `backfill` | One-time historical backfill of missing changelog entries | ~120 |

## Invocation

- `/skill changelog-generator --task since-last-release` - Normal PR workflow (after PR creation)
- `/skill changelog-generator --task date-range --from DATE --to DATE` - Weekly/monthly updates
- `/skill changelog-generator --task backfill` - One-time historical catchup
- `/skill changelog-generator` - Overview only

## When to Use This Skill

- Preparing release notes for a new version
- Creating weekly or monthly product update summaries
- Documenting changes for customers
- Writing changelog entries for app store submissions
- Generating update notifications
- Creating internal release documentation
- Maintaining a public changelog/product updates page

## What This Skill Does

1. **Scans Git History**: Analyzes commits from a specific time period or between versions
2. **Categorizes Changes**: Groups commits into logical categories (features, improvements, bug fixes, breaking changes, security)
3. **Translates Technical → User-Friendly**: Converts developer commits into customer language
4. **Formats Professionally**: Creates clean, structured changelog entries
5. **Filters Noise**: Excludes internal commits (refactoring, tests, etc.)
6. **Follows Best Practices**: Applies changelog guidelines and your brand voice
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: changelog-generator
description: Use when creating release notes, documenting changes between versions, or preparing a changelog. Triggers on: changelog, release notes, what changed, version history, commit summary, release.
type: technique
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: changelog-generator

This skill transforms technical git commits into polished, user-friendly changelogs that your customers and users will actually understand and appreciate.

## Prerequisites

- **Git**: Required for reading commit history
- **Repository access**: Must be run from a git repository root
- **Optional**: Custom changelog style guide (CHANGELOG_STYLE.md)

## Tasks

| Task | Purpose | Words |
| -- | -- | -- |
| `since-last-release` | Generate changelog for commits since last CHANGELOG.md update | ≈170 |
| `date-range` | Generate changelog for commits within specific date range | ≈90 |
| `backfill` | One-time historical backfill of missing changelog entries | ≈120 |
| `completion` | Ensure mandatory terminal-state dispatch occurred; remediate if not; report status | ≈200 |

## Invocation

- `/skill changelog-generator --task since-last-release` - Normal PR workflow (after PR creation)
- `/skill changelog-generator --task date-range --from DATE --to DATE` - Weekly/monthly updates
- `/skill changelog-generator --task backfill` - One-time historical catchup
- `/skill changelog-generator --task completion` - Invoke when workflow halts at any point
- `/skill changelog-generator` - Overview only

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `since-last-release` | When generating changelog since last release | Repository path, branch name, github.owner, github.repo | Implementation context, agent memory | NO |
| `date-range` | When generating changelog for date range | Repository path, date range, github.owner, github.repo | Implementation context, agent memory | NO |
| `backfill` | When performing historical backfill | Repository path, github.owner, github.repo | Implementation context, agent memory | NO |
| `completion` | When workflow halts at any point | Workflow state, status | Implementation context, agent memory | NO |

## When to Use This Skill

- Preparing release notes for a new version
```

### code-size-enforcement

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 213 | 307 |
| Task file count | 2 | N/A |
| Task total lines | 171 | N/A |
| Mandatory language | YES | — |
| Optional language | No | — |
| Verification steps | YES | — |
| Cross-references | No ⚠️ | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: code-size-enforcement
description: Enforce size limits on functions, notebook cells, and files. Defines detection methods, prohibited patterns, grandfather policy, and violation recovery.
license: MIT
compatibility: opencode
---

# Persona: Code Size Enforcer

## Role

You are a Code Size Enforcer. Your sole focus is ensuring code artifacts stay within size limits for maintainability and readability. This includes functions, notebook cells, and source files.

## Operating Protocol

1. **Automatically Applied:** This skill is referenced whenever code is written or modified. It is NOT invoked by name - the agent follows these rules at all times.

1. **Check Size Limits Before Merge:** When code changes are prepared for commit or PR, verify size limits.

2. **Use Permitted Detection Tools:** Use the tools listed below to measure size. Do not create ad-hoc detection methods.

3. **Grandfather Existing Files:** Files that existed before this skill are NOT flagged as errors. Only new files and modifications must comply.

4. **Enforce on New/Modified Files:** Files created or modified after this skill's introduction must adhere to size limits.

## Size Limits

| Artifact | Limit | Measurement |
|----------|-------|-------------|
| **Python functions** | 40 lines | Excluding docstrings, imports, blank lines |
| **Notebook cells** | 50 lines | Including whitespace, excluding cell header |
| **Source files** | 300 lines | Total file, excluding blank lines and comments at file start |

### What Counts Toward Limits

**Functions:**
- Function body lines (code + inline comments)
- Nested functions/classes contribute to outer function's line count
- Multi-line string literals (non-docstrings) count as lines

**What Does NOT Count for Functions:**
- Docstrings (the `"""..."""` block immediately after `def`)
- Import statements outside the function
- Blank lines
- Type hints on their own lines (when using Python 3.10+ syntax)

**Notebook Cells:**
- All lines in the cell source
- Comments
- Whitespace
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: code-size-enforcement
description: Use when writing or modifying code and function length, file size, or cell size may exceed limits. Triggers on: long function, big file, too many lines, size limit, code size, function length, cell size.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Code Size Enforcement

## Overview

Ensures code artifacts stay within size limits for maintainability and readability. Covers Python functions (≈100 words), notebook cells (≈120 words), and source files (≈750 words). Grandfather policy exempts existing files; only new and modified files must comply.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `check-limits` | Measure and verify size limits before commit | ≈300 |
| `decompose` | Decompose oversized functions, cells, or files | ≈400 |

## Invocation

- `/skill code-size-enforcement --task check-limits` - Check size limits before merge
- `/skill code-size-enforcement --task decompose` - Get decomposition guidance
- `/skill code-size-enforcement` - Overview only

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `check-limits` | When verifying size limits before commit | File paths, size limit configuration | Implementation context, agent memory | NO |
| `decompose` | When decomposition guidance is needed for oversized artifacts | File paths, artifact type, size metrics | Implementation context, agent memory | NO |

## Size Limits

| Artifact | Limit | Measurement |
|----------|-------|-------------|
| **Python functions** | ≈100 words | `wc -w` on function body, excluding docstrings, imports, blank lines |
| **Notebook cells** | ≈120 words | `wc -w` on cell source, excluding cell header |
| **Source files** | ≈750 words | `wc -w` on file, excluding blank lines and file-start comments |

## What Counts and Doesn't Count

**Functions count:** Function body words (code + inline comments), nested functions/classes, multi-line non-docstring string literals.
**Functions don't count:** Docstrings, import statements outside the function, blank lines, type hints on their own lines.

```

### coherence-auditor

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 305 | 95 |
| Task file count | 5 | N/A |
| Task total lines | 271 | N/A |
| Mandatory language | YES | — |
| Optional language | YES ⚠️ | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: coherence-auditor
description: Audit coherence between guidelines, skills, and AI agent behavior to ensure they work together effectively. Can be used for extraction (identifying skill candidates) and maintenance (detecting drift).
license: MIT
compatibility: opencode
---

# Skill: coherence-auditor

## Overview

LLM Coherence Auditor ensuring guidelines, skills, and AI agent behavior work together effectively. Identifies procedural workflows for extraction and detects drift over time.

## Persona


## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `extract-scan` | Scan guidelines for skill candidates | ~450 |
| `extract-analyze` | Calculate metrics and rank candidates | ~380 |
| `maintenance-detect` | Detect drift from baseline | ~370 |
| `maintenance-verify` | Verify guideline-skill references | ~310 |
| `create-report` | Generate and attach audit report | ~400 |

## Invocation

- `/skill coherence-auditor --mode extraction` — Scan for extraction candidates
- `/skill coherence-auditor --mode maintenance` — Detect drift from baseline
- `/skill coherence-auditor --task extract-scan` — Load specific task
- `/skill coherence-auditor --task extract-analyze` — Load specific task
- `/skill coherence-auditor --task maintenance-detect` — Load specific task
- `/skill coherence-auditor --task maintenance-verify` — Load specific task
- `/skill coherence-auditor --task create-report` — Load specific task
- `/skill coherence-auditor` — Overview only

## Operating Protocol

1. **Automatic invocation (mandatory):** This skill is invoked when auditing guideline/skill coherence or when user requests extraction/maintenance audit.

2. **Mode selection:**
   - **Extraction mode**: Use when creating new skills from guideline content
   - **Maintenance mode**: Use for ongoing drift detection and verification

## Drift Patterns

| Pattern | Description |
|---------|------------|
| DUPLICATE-CONTENT | Same procedure in guideline AND skill |
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: coherence-auditor
description: Use when guidelines or skills are updated, to check consistency between rules and behavior. Triggers on: coherence, consistency, audit guidelines, skill extraction, drift detection, guideline update, skill update.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: coherence-auditor

## Overview

LLM Coherence Auditor ensuring guidelines, skills, and AI agent behavior work together effectively. Identifies procedural workflows for extraction and detects drift over time.

## Persona


## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `extract-scan` | Scan guidelines for skill candidates | ≈450 |
| `extract-analyze` | Calculate metrics and rank candidates | ≈380 |
| `maintenance-detect` | Detect drift from baseline | ≈370 |
| `maintenance-verify` | Verify guideline-skill references | ≈310 |
| `create-report` | Generate and attach audit report | ≈400 |

## Invocation

- `/skill coherence-auditor --mode extraction` — Scan for extraction candidates
- `/skill coherence-auditor --mode maintenance` — Detect drift from baseline
- `/skill coherence-auditor --task extract-scan` — Load specific task
- `/skill coherence-auditor --task extract-analyze` — Load specific task
- `/skill coherence-auditor --task maintenance-detect` — Load specific task
- `/skill coherence-auditor --task maintenance-verify` — Load specific task
- `/skill coherence-auditor --task create-report` — Load specific task
- `/skill coherence-auditor` — Overview only

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `extract-scan` | When scanning guidelines for skill candidates | Guideline file paths, scan configuration | Implementation context, agent memory | NO |
| `extract-analyze` | When calculating metrics and ranking candidates | Scan results, metric configuration | Implementation context, agent memory | NO |
| `maintenance-detect` | When detecting drift from baseline | Guideline file paths, baseline hashes | Implementation context, agent memory | NO |
| `maintenance-verify` | When verifying guideline-skill references | Guideline file paths, skill file paths | Implementation context, agent memory | NO |
| `create-report` | When generating and attaching audit report | Audit findings, github.owner, github.repo | Implementation context, agent memory | NO |
```

### completion-core

**SKILL.md not found** — cannot audit this skill.

### concern-separation-auditor

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 304 | 350 |
| Task file count | 3 | N/A |
| Task total lines | 285 | N/A |
| Mandatory language | YES | — |
| Optional language | YES ⚠️ | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: concern-separation-auditor
description: Analyzes spec phase structure for concern separation quality - deployment independence, risk profile, blast radius. Auto-fixes phases by analyzing actual concerns (not rigid templates). Posts findings to GitHub.
license: MIT
compatibility: opencode
---

# Skill: concern-separation-auditor

## Overview

Concern Separation Auditor analyzing spec phase structures to identify deployment independence, risk profiles, and blast radius. Auto-fixes BOILERPLATE-TITLE (objective) and phase structure (based on actual concern analysis). Posts findings to GitHub comments.

## Persona

You are a Concern Separation Auditor. Your focus is analyzing GitHub Issue `[SPEC]` phase structures to identify concern quality issues and apply smart fixes.

## Invocation

- `/skill concern-separation-auditor --issue N` — Audit a specific spec issue (auto-fix mode for AI agents)
- `/skill concern-separation-auditor --issue N --interactive` — Interactive mode, present findings for human decision
- `/skill concern-separation-auditor` — Overview only

## What Gets Auto-Fixed

| Issue Type | Auto-Fix? | Why |
|------------|-----------|-----|
| BOILERPLATE-TITLE | YES | 100% objective - generic names vs concern names |
| CONCERN_MIXING | YES | Smart split based on actual concern analysis |
| DEPENDENCY_REVERSAL | YES | Reorder to fix dependencies |
| HIGH_RISK_GROUPING | YES | Separate high-risk from low-risk |

## Why Concern Separation Matters

**Beyond deployment and rollback, concern separation prevents critical anti-patterns:**

### 1. Feature Creep Prevention
When a phase has clear concern boundaries, any additional work outside those boundaries is obviously out of scope. Mixing concerns blurs the boundaries, making it easier to slip in "quick fixes" or "while we're here" changes.

**Example:**
- Clear boundary: "Phase 1: User Schema" → adding a UI tweak is clearly out of scope
- Mixed boundary: "Phase 1: Implementation" → adding a UI tweak seems harmless because boundaries are unclear

### 2. Vibe Coding Prevention
Without clear concern boundaries, developers (and AI agents) may implement based on intuition rather than specification. The phase becomes a "bucket" for whatever feels related.

### 3. Roadmap Driving Prevention
When phases mix concerns, roadmap priorities can inappropriately influence phase boundaries.

**The principle: Each phase should have a SINGLE concern boundary that prevents scope expansion.**
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: concern-separation-auditor
description: Use when auditing a spec for phase structure quality or concern separation. Triggers on: concern separation, phase structure, spec audit, mixed concerns.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: concern-separation-auditor

## Overview

Concern Separation Auditor analyzes spec phase structures to identify deployment independence, risk profile, and blast radius issues. Reports findings to the agent for decision-making — does NOT auto-fix.

**Core v2 shift:** Report-only. Findings are presented to the agent, who decides whether to apply them given the context. No longer invoked directly — called by spec-auditor orchestrator when relevant.

**Single Concern Principle (SCP):** The authoritative universal rule for concern separation is defined in `000-critical-rules.md` §Single Concern Principle. SCP applies to ALL artifacts the agent produces (issues, commits, PRs, plans, specs, comments, sub-agents). This skill enforces SCP as it applies to spec/plan phase structure — it is a domain-specific instance of the universal rule, not a substitute for it.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `audit-phases` | Analyze phase structure for concern quality | ≈400 |
| `check-independence` | Validate deployment independence between phases | ≈300 |
| `concern-coverage` | Verify sub-issue bodies reflect Plan concern boundaries | ≈350 |

## Invocation

**This skill is NOT invoked directly.** It is called by the spec-auditor orchestrator via `/skill spec-auditor --issue N --task concerns`.

If invoked directly (deprecated, but still works):
- `/skill concern-separation-auditor --issue N` — Audit (report-only mode)

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `audit-phases` | When analyzing phase structure for concern quality | Issue number, plan body, github.owner, github.repo | Implementation context, agent memory | NO |
| `check-independence` | When validating deployment independence between phases | Issue number, phase boundaries, github.owner, github.repo | Implementation context, agent memory | NO |
| `concern-coverage` | When verifying sub-issue bodies reflect Plan concern boundaries | Issue number, sub-issue list, github.owner, github.repo | Implementation context, agent memory | NO |

## Report-Only Model

**All findings are reported, NOT auto-applied.**

Previous versions auto-fixed BOILERPLATE-TITLE and phase splits. v2 reports findings and lets the agent decide:

```

### conflict-resolution

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 292 | 0
0 |
| Task file count | 2 | N/A |
| Task total lines | 222 | N/A |
| Mandatory language | YES | — |
| Optional language | No | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
(not available)
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: conflict-resolution
description: Use when resolving git conflicts during rebase, merge, or cherry-pick operations. Triggers on: conflict, merge conflict, rebase conflict, resolve conflict, cherry-pick conflict, conflict resolution, intent conflict, conflict classification.
---

# Skill: conflict-resolution

## Overview

Procedural workflow for classifying and resolving git conflicts with proper intent preservation. Prevents silent erosion of committed work during rebase, merge, cherry-pick, or any git operation that produces conflicts.

## Persona

You are a Conflict Resolution Specialist. Your focus is ensuring no committed work or spec intent is silently lost during git conflict resolution.

## Invocation

- **Automatic**: Invoked by `git-workflow` tasks when conflicts are detected during rebase/merge
- **Manual**: `/skill conflict-resolution` — Overview only
- **Manual**: `/skill conflict-resolution --task classify-and-resolve` — Full classification and resolution procedure
- **Manual**: `/skill conflict-resolution --task completion` — Invoke when workflow halts at any point

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `classify-and-resolve` | Detect, classify, and resolve conflicts by tier | ≈550 |
| `completion` | Ensure mandatory terminal-state dispatch occurred; remediate if not; report status | ≈200 |

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `classify-and-resolve` | When a git conflict is detected and needs resolution | Branch name, conflict file paths, worktree.path | Implementation context, agent memory, conflict resolution decisions from prior sessions | NO |
| `completion` | When workflow halts at any point | Workflow state, status | Implementation context, agent memory | NO |

## Conflict Classification Tiers

Before resolving ANY conflict, classify it:

| Tier | Name | Criteria | Agent Action |
|------|------|----------|-------------|
| 1 | **Trivial** | Whitespace, formatting, reordering of unchanged lines | Auto-resolve, silent |
| 2 | **Textual but safe** | Same intent on both sides, just different text | Auto-resolve, note in chat |
| 3 | **Intent conflict** | Different goals, or resolution could alter spec compliance | HALT, flag for developer review |

**Classification rule:** When in doubt, classify UP to the next tier. If unsure whether something is Tier 2 or Tier 3, treat it as Tier 3.

```

### correspondence

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 480 | 0
0 |
| Task file count | 2 | N/A |
| Task total lines | 286 | N/A |
| Mandatory language | YES | — |
| Optional language | YES ⚠️ | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
(not available)
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: correspondence
description: Use when drafting stakeholder emails, status updates, or external communications. Triggers on: email, correspondence, stakeholder email, status update, communication, draft email, reply, notification.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: correspondence

Discipline-enforcing skill for drafting email correspondence and stakeholder communications. Enforces multipart/alternative format (text/plain + text/html), stakeholder content rules, audience-aware content levels, and verification-enforcement integration.

## Problem This Skill Solves

Three distinct failures occur when drafting email correspondence without this skill:

1. **No HTML enforcement.** The original email is often multipart/alternative with HTML. The agent writes `Content-Type: text/plain` and uses markdown syntax inside the email body, which renders as raw markdown in email clients.

2. **No stakeholder content rules.** The agent includes internal operations details — runbook file paths, step numbers, internal IP addresses — that are meaningless or confusing to stakeholders.

3. **No format template.** Nothing extends the Summary/Outcome/byline format to email correspondence. The agent guesses at email format and guesses wrong.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `draft` | Draft email correspondence with format template, audience rules, and verification gate | ≈800 |
| `completion` | Ensure mandatory terminal-state dispatch occurred; remediate if not; report status | ≈200 |

## Invocation

- `/skill correspondence --task draft` — Draft email correspondence
- `/skill correspondence --task completion` — Invoke when workflow halts at any point
- `/skill correspondence` — Overview only

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `draft` | When drafting email correspondence | Audience tier, topic, verification data, github.owner, github.repo | Implementation context, agent memory, internal artifacts | NO |
| `completion` | When workflow halts at any point | Workflow state, status | Implementation context, agent memory | NO |

## Operating Protocol

1. **Verification gate BEFORE drafting.** The agent MUST invoke `verification-enforcement --task verify` before drafting any email correspondence. All claims about external state (domain status, DNS records, service availability, system state) must be verified against live data before inclusion.

2. **Format template REQUIRED.** Every email draft MUST use the multipart/alternative template defined in the `draft` task. No exceptions. The text/plain part uses the Summary/Outcome/byline format. The text/html part renders that same format in proper HTML with structural markup.
```

### divide-and-conquer

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 656 | 0
0 |
| Task file count | 13 | N/A |
| Task total lines | 2147 | N/A |
| Mandatory language | YES | — |
| Optional language | YES ⚠️ | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Possible | — |

#### Baseline SKILL.md Content (first 50 lines)
```
(not available)
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: divide-and-conquer
description: Use when implementing an approved spec, orchestrating sub-agents, or when a task risks context window overflow. Triggers on: implement, build, orchestrate, context overflow, decompose, dispatch subagent, work execution.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Divide and Conquer

## Overview

Enforces context window safety by mandating pre-flight assessment before non-trivial implementation. When a task risks overflow, it MUST be decomposed into sub-tasks and dispatched to sub-agents. The orchestrator is a pure coordinator — it never edits implementation files directly. Only trivial single-file fixes skip assessment.

**Source Attribution:** This skill addresses the context window overflow patterns identified in issue #734. Decomposition and dispatch patterns adapted from `implementation-workflow` (work-orchestrate, context-passing, purification-and-enforcement).

**Persona:** You are a Divide and Conquer Orchestrator. Your focus is assessing context fitness, decomposing work into safe units, dispatching sub-agents with scoped instructions, and aggregating results — never implementing directly.

## Tasks

| Task | Purpose | Words |
| -- | -- | -- |
| `assess` | Pre-flight context-fit assessment — determine workload sizing for sub-agent dispatch | ≈300 |
| `decompose` | Split a task into sub-tasks with dispatch context, preserve spec boundaries | ≈300 |
| `dispatch` | Spawn sub-agent with scoped instructions and collect structured result | ≈250 |
| `completion-checkpoint` | Post-dispatch verification: detect abnormal termination, assess work, recover | ≈300 |
| `result-validation` | Post-dispatch result validation: empty/malformed result detection and fallback | ≈200 |
| `overflow-signal` | Structured OVERFLOW response protocol for sub-agents that can't fit the work | ≈200 |
| `merge` | Combine sub-agent results into final output, pure aggregation | ≈150 |
| `context-passing` | Reference for dispatch context shapes between orchestrator and sub-agents | ≈200 |
| `purification-and-enforcement` | Scope boundaries and enforcement rules for the orchestration layer | ≈250 |
| `completion` | Ensure mandatory completion steps run regardless of workflow outcome | ≈150 |
| `orchestrate` | Full workflow: assess → decompose → dispatch → merge → completion | ≈400 |
| `assemble-work` | Work set assembly: squash-merge feature branches into work branch | ≈200 |
| `implementer-prompt` | Sub-agent prompt template: implementation context and instructions | ≈250 |
| `spec-reviewer-prompt` | Spec review stage prompt: two-stage review for spec compliance | ≈200 |
| `code-quality-reviewer-prompt` | Code quality review stage prompt: two-stage review for code quality | ≈200 |

## Invocation

- `/skill divide-and-conquer` - Overview only
- `/skill divide-and-conquer --task assess` - Pre-flight context-fit assessment
- `/skill divide-and-conquer --task decompose` - Split task into sub-tasks
- `/skill divide-and-conquer --task dispatch` - Spawn sub-agent with scoped instructions
- `/skill divide-and-conquer --task overflow-signal` - Handle OVERFLOW from sub-agent
- `/skill divide-and-conquer --task merge` - Combine sub-agent results
- `/skill divide-and-conquer --task context-passing` - Reference dispatch context shapes
- `/skill divide-and-conquer --task purification-and-enforcement` - Reference boundaries
- `/skill divide-and-conquer --task completion` - Invoke when workflow halts
```

### engineering-approach

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 375 | 183 |
| Task file count | 2 | N/A |
| Task total lines | 231 | N/A |
| Mandatory language | YES | — |
| Optional language | YES ⚠️ | — |
| Verification steps | YES | — |
| Cross-references | No ⚠️ | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: engineering-approach
description: Engineering principles and checklists for proper development methodology. Invoked when implementing specs to ensure understanding, design, verification, and scope discipline.
license: MIT
compatibility: opencode
---

# Engineering Approach Checklist

## Core Principles

1. **Understand Before Solving**
   - Read all relevant code before proposing changes
   - Understand the "why" not just "what"
   - Identify stakeholders and their needs

2. **Design Before Implementing**
   - Document the approach in the spec
   - Consider multiple solutions and tradeoffs
   - Get approval on approach before coding

3. **Verify Before Declaring Complete**
   - Run all tests manually
   - Check for edge cases
   - Verify against all success criteria
   - Update documentation

4. **Communicate Changes**
   - Post comments when changes happen (PR created, task completed)
   - DO NOT post comments when creating issues
   - DO NOT post comments for non-substantive updates (cross-references, origin links, STATUS updates)

## Scope Discipline (Critical)

### No Feature Creep

- Implement ONLY what is specified in the approved spec
- No additions, enhancements, or "improvements" beyond scope
- No refactoring unless explicitly requested
- No unrelated fixes discovered during work (file separate issue)

### No Unapproved Work

- Never start implementation without explicit authorization
- "Should I do X?" is a question, not authorization
- Wait for clear "proceed" or "yes" before starting
- If unclear, ask - do not assume

## Anti-Patterns to Avoid

```

#### Current SKILL.md Content (first 50 lines)
```
---
name: engineering-approach
description: Use when implementing a spec, or when design, verification, and scope discipline are needed. Triggers on: implement, build, develop, engineering checklist, design before code, verify before complete.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Engineering Approach Checklist

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `principles` | When design/engineering principles reference is needed | Design decision context, file paths | Implementation context, agent memory | NO |
| `application-guide` | When application guidance is needed during review | Review context, code paths | Implementation context, agent memory | NO |

## Core Principles

1. **Understand Before Solving**
   - Read all relevant code before proposing changes
   - Understand the "why" not just "what"
   - Identify stakeholders and their needs

2. **Design Before Implementing**
   - Document the approach in the spec
   - Consider multiple solutions and tradeoffs
   - Get approval on approach before coding

3. **Verify Before Declaring Complete**
   - Run all tests manually
   - Check for edge cases
   - Verify against all success criteria
   - Update documentation

4. **Communicate Changes**
   - Post comments when changes happen (PR created, task completed)
   - DO NOT post comments when creating issues
   - DO NOT post comments for non-substantive updates (cross-references, origin links, STATUS updates)

## Scope Discipline (Critical)

### No Feature Creep

- Implement ONLY what is specified in the approved spec
- No additions, enhancements, or "improvements" beyond scope
- No refactoring unless explicitly requested
```

### executing-plans

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 165 | 288 |
| Task file count | 5 | N/A |
| Task total lines | 549 | N/A |
| Mandatory language | YES | — |
| Optional language | No | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: executing-plans
description: Plan execution workflow that implements approved plans step-by-step with verification evidence collection and quality gates.
license: MIT
compatibility: opencode
---

# Skill: executing-plans

## Overview

Plan execution workflow that implements approved plans step-by-step with verification at each stage. This skill ensures systematic implementation, evidence collection, and quality gates. It is adapted from the NewsRx/opencode-gitbucket-superpowers workflow.

**Source Attribution:** This skill is adapted from NewsRx/opencode-gitbucket-superpowers workflow (branch: newsrx).

## Persona

You are an Implementation Executor. Your focus is executing approved plans systematically, collecting evidence, and maintaining progress tracking.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `start` | Begin plan execution, verify prerequisites | ~700 |
| `step` | Execute single step, collect evidence | ~900 |
| `progress` | Report current progress | ~500 |
| `verify` | Run verification for current step | ~600 |

## Invocation

- `/skill executing-plans` - Overview only
- `/skill executing-plans --task start` - Begin execution
- `/skill executing-plans --task step` - Execute next step
- `/skill executing-plans --task progress` - Show progress
- `/skill executing-plans --task verify` - Verify current step

## Operating Protocol

1. **Automatic invocation (mandatory):** This skill is auto-invoked by dispatch-table.yaml when:
   - Plan receives explicit approval (`approved: plan`)
   - User says `execute plan` or `start implementation`
   - After writing-plans creates approved plan
   - DO NOT skip steps or proceed without verification

2. **Step-by-Step Execution:**
   - Execute ONE step at a time
   - Collect evidence for each step
   - Verify before marking complete
   - HALT after each step completion

```

#### Current SKILL.md Content (first 50 lines)
```
---
name: executing-plans
description: Use when executing an approved plan step-by-step or moving through implementation gates sequentially. Triggers on: execute plan, next step, continue implementation, plan approved, start implementation.
type: technique
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: executing-plans

## Overview

Plan execution skill that dispatches to `divide-and-conquer/assemble-work` for implementation. This skill is a thin dispatch layer — all implementation logic flows through the unified work workflow. It receives plan context from `approval-gate` after plan approval.

**Every approval follows one path:** `executing-plans` → `divide-and-conquer/assemble-work` → work branch → pr-creation → one PR.

**There is no single-issue bypass.** Single issue = work of one = one sub-agent.

## Received Context

When dispatched from `approval-gate` after plan approval, the following context is available:

```yaml
plan_issue: <number>
spec_issue: <number, extracted from plan body>
authorization_scope: <scope_value>
halt_at: <pipeline_stage>
pr_strategy: stacked | individual | none
github.owner: "<from-session>"
github.repo: "<from-session>"
worktree.path: "<worktree path>"
phase_progress:
  completed_phases: "<prose listing of completed phases by concern name, from Plan STATUS>"
  concern_boundaries_crossed: "<prose description of architectural concern transitions from plan>"
  verification_evidence: "<prose summary of what was verified and outcomes>"
```

**Verification:** If `plan_issue` is not present in the dispatch context, HALT — this skill requires plan context to track progress against the correct issue.

**Phase progress composition:** Before dispatching to `divide-and-conquer`, `executing-plans` reads the Plan STATUS marker and concern boundary annotations to compose the initial `phase_progress`. If no phases are complete yet, the field notes that explicitly. The `assemble-work` task then maintains and extends phase progress as each sub-agent completes.

## Per-Item TDD Cycle (Per `091-incremental-build.md`)

Each implementation item dispatched by `executing-plans` follows the per-item TDD cycle mandated by `091-incremental-build.md`:

| TDD Phase | Action | Purpose |
|-----------|--------|---------|
| **RED** | Add enforcement test scenario | Verify the change is testable before implementation |
| **GREEN** | Make the `.md` file change | The actual guideline, skill, or configuration modification |
```

### finishing-a-development-branch

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 345 | 217 |
| Task file count | 3 | N/A |
| Task total lines | 367 | N/A |
| Mandatory language | YES | — |
| Optional language | No | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: finishing-a-development-branch
description: Branch completion workflow ensuring all changes are committed, verified, pushed, and ready for PR creation.
license: MIT
compatibility: opencode
---

# Skill: finishing-a-development-branch

## Overview

Branch completion workflow that ensures a feature branch is fully ready for PR creation. This skill verifies all changes are committed, tested, pushed, and reviewed before the developer creates a PR. It is adapted from the NewsRx/opencode-gitbucket-superpowers workflow.

**Source Attribution:** This skill is adapted from NewsRx/opencode-gitbucket-superpowers workflow (branch: newsrx).

## Persona

You are a Branch Finalizer. Your focus is ensuring no uncommitted changes, all verifications pass, and the branch is ready for review.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `prepare` | Prepare branch for PR creation | ~800 |
| `checklist` | Run completion checklist | ~500 |

## Invocation

- `/skill finishing-a-development-branch` - Overview only
- `/skill finishing-a-development-branch --task prepare` - Prepare branch for PR
- `/skill finishing-a-development-branch --task checklist` - Run completion checklist

## Operating Protocol

1. **Automatic invocation (strongly recommended):** This skill is auto-invoked by dispatch-table.yaml when:
   - Implementation completes on a feature branch
   - User says "done" or "finished" or "ready for PR"
   - Before review-prep task in git-workflow
   - DO NOT proceed to PR creation until checklist passes

2. **Verification-first approach:**
   - All changes must be committed
   - All tests must pass
   - All lint/typecheck must pass
   - Branch must be pushed to remote

3. **Exit conditions:** Branch is READY when:
   - All checklist items pass
   - Compare URL is generated
   - HALT and report readiness
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: finishing-a-development-branch
description: Use when implementation is complete and branch needs final checks before PR. Triggers on: done, finished, ready for PR, implementation complete, branch ready, push changes, final check.
type: technique
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: finishing-a-development-branch

## Overview

Branch completion workflow that ensures a feature branch is fully ready for PR creation. Verifies all changes are committed, tested, pushed, and reviewed before the developer creates a PR. Implementation tracks against plan sub-issues, not spec sub-issues. Adapted from the \<UPSTREAM_ORG>/\<UPSTREAM_REPO> workflow.

**Source Attribution:** This skill is adapted from \<UPSTREAM_ORG>/\<UPSTREAM_REPO> workflow (branch: newsrx).

## Tasks

| Task | Purpose | Words |
| -- | -- | -- |
| `prepare` | Prepare branch for PR creation | ≈450 |
| `checklist` | Run completion checklist | ≈350 |
| `completion` | Ensure mandatory completion steps run regardless of workflow outcome | ≈200 |

## Sub-Agent Tasks

| Task | Words |
|------|-------|
| `prepare` | ≈450 |
| `checklist` | ≈350 |
| `completion` | ≈200 |

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `prepare` | When branch readiness preparation is needed | Branch name, worktree.path, github.owner, github.repo | Implementation context, agent memory, cached verification | NO |
| `checklist` | When completion checklist verification is needed | Branch name, SC list, worktree.path, github.owner, github.repo | Implementation context, agent memory, cached verification | NO |
| `completion` | When workflow halts at any point | Workflow state, status | Implementation context, agent memory | NO |

## Invocation

- `/skill finishing-a-development-branch` — Overview only
- `/skill finishing-a-development-branch --task prepare` — Prepare branch for PR
- `/skill finishing-a-development-branch --task checklist` — Run completion checklist
- `/skill finishing-a-development-branch --task completion` — Invoke when workflow halts at any point

**⚠️ COMPLETION GUARANTEE:** If this workflow halts at ANY point — including error, failure, or early termination — you MUST invoke `--task completion` before halting. The completion subtask ensures mandatory steps (push, compare URL, status report) are never skipped. It is idempotent and safe to invoke multiple times.

```

### fragment-manager

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 246 | 125 |
| Task file count | 9 | N/A |
| Task total lines | 1387 | N/A |
| Mandatory language | YES | — |
| Optional language | No | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: fragment-manager
description: Manages duplicate content blocks (fragments) within the repository. Provides CRUD operations for fragment masters and synchronization from masters to destination copies in skills.
license: MIT
compatibility: opencode
---

# Skill: fragment-manager

## Overview

Fragment Manager handles duplicate text blocks (fragments) that appear in multiple skills. It provides:
- CRUD operations on fragment master files in `.opencode/.guidelines/`
- Synchronization from masters to destination copies
- Drift detection between masters and copies
- Conflict resolution when changes diverge

## Architecture

**Fragment Registry Schema:**
- `.opencode/.guidelines/registry.yaml` - Tracks fragment masters and destinations
- `.opencode/.guidelines/*.md` - Fragment master files (golden copies)
- `.opencode/skills/*/SKILL.md` - Destination copies (embedded in skills)

**Key Principles:**
- Skills remain self-contained (copies, not references)
- Masters are minimal (content blocks only, no context)
- Syncs require verification (hash matching)
- Conflicts require human intervention

## Tasks

| Task | Purpose | When to Use |
|------|---------|-------------|
| `create-fragment` | Create new fragment master from existing content | When duplicate content is found in skills |
| `read-fragment` | Read fragment master content | When inspecting fragment details |
| `update-fragment` | Update master content | When master needs changes |
| `delete-fragment` | Delete fragment master and registry entry | When fragment is obsolete |
| `sync-fragment` | Copy master to all destinations | When masters are updated |
| `check-drift` | Detect drift between masters and copies | Periodic validation, before syncs |
| `status-report` | Show sync status for all fragments | Overview of fragment health |
| `resolve-conflict` | Handle merge conflicts | When drift is detected |

## Invocation

- `/skill fragment-manager --task create-fragment` - Create new fragment
- `/skill fragment-manager --task sync-fragment` - Sync master to destinations
- `/skill fragment-manager --task check-drift` - Detect drift
- `/skill fragment-manager --task status-report` - Overview
- `/skill fragment-manager` - Skill overview only
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: fragment-manager
description: Use when managing duplicate content blocks (fragments) across guidelines or skills. Triggers on: fragment, duplicate content, sync content, content block, shared content, master copy, synchronize.
type: technique
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: fragment-manager

## Overview

Fragment Manager handles duplicate text blocks (fragments) that appear in multiple skills. It provides:

- CRUD operations on fragment master files in `.opencode/.guidelines/`
- Synchronization from masters to destination copies
- Drift detection between masters and copies
- Conflict resolution when changes diverge

## Architecture

**Fragment Registry Schema:**

- `.opencode/.guidelines/registry.yaml` - Tracks fragment masters and destinations
- `.opencode/.guidelines/*.md` - Fragment master files (golden copies)
- `.opencode/skills/*/SKILL.md` - Destination copies (embedded in skills)

**Key Principles:**

- Skills remain self-contained (copies, not references)
- Masters are minimal (content blocks only, no context)
- Syncs require verification (hash matching)
- Conflicts require human intervention

## Tasks

| Task | Purpose | When to Use |
| -- | -- | -- |
| `create-fragment` | Create new fragment master from existing content | When duplicate content is found in skills |
| `read-fragment` | Read fragment master content | When inspecting fragment details |
| `update-fragment` | Update master content | When master needs changes |
| `delete-fragment` | Delete fragment master and registry entry | When fragment is obsolete |
| `sync-fragment` | Copy master to all destinations | When masters are updated |
| `check-drift` | Detect drift between masters and copies | Periodic validation, before syncs |
| `status-report` | Show sync status for all fragments | Overview of fragment health |
| `resolve-conflict` | Handle merge conflicts | When drift is detected |
| `completion` | Ensure mandatory terminal-state dispatch occurred; remediate if not; report status | ≈200 |

## Sub-Agent Tasks
```

### git-workflow

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 847 | 711 |
| Task file count | 29 | N/A |
| Task total lines | 3365 | N/A |
| Mandatory language | YES | — |
| Optional language | No | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Likely ⚠️ | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: git-workflow
description: Handles pre-work git branch, git stash, work, git commit, and PR creation as dictated by the guidelines. Automatically invoked when user approves implementation or requests PR creation. Enforces three-branch workflow (feature → dev → main).
license: MIT
compatibility: opencode
---

# Skill: git-workflow

## Overview

Git Workflow Enforcer ensuring all git operations follow the repository's three-branch workflow: feature → dev → main. AI commits are blocked on `main`/`master`/`dev` branches by local git hooks. All feature branches merge to `dev` (staging/integration), and releases merge from `dev` to `main` via human-triggered workflow. Squashing happens ONLY at PR creation time, not during implementation. Invoked automatically before implementation begins and when PR creation is requested.

## Three-Branch Architecture

**Branch Model:**
- **Feature branches** (`feature/*` or `spec/*`): Short-lived, one per issue/spec
- **Dev branch** (`dev`): Evergreen staging/integration branch (never deleted)
- **Main branch** (`main` or `master`): Production-ready code

**Merge Paths:**
1. **Feature → Dev**: PR required (squash to single commit, no CI tests required)
2. **Dev → Main**: Human-triggered release (no approval required, CI tests required)

**AI Restrictions:**
- AI cannot commit directly to `main`, `master`, or `dev`
- AI must branch from `dev` for new features (not `main`)
- AI must sync with `dev` before creating feature branch

## Persona

You are a Git Workflow Enforcer. Your sole focus is ensuring all git operations follow the repository's three-branch workflow: feature → dev → main. AI commits are blocked on protected branches. Squashing is ONLY for PR creation, not during feature branch development.

## Role in Orchestration Architecture

**⚠️ CRITICAL: Git-workflow is called by implementation-workflow orchestration layer.**

Git-workflow tasks handle **pure git operations only**. Implementation logic is handled by the implementation-workflow orchestrator and implementation subagent.

**Architecture:**
```
implementation-workflow (orchestration layer)
    ├─ calls git-workflow --task pre-work (git ops only)
    ├─ invokes implementation subagent (does actual work)
    └─ calls git-workflow --task review-prep (git ops only)
```

**What git-workflow DOES:**
- Git operations (stash, branch, commit, push)
- Git state checks (branch verification, working tree status)
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: git-workflow
description: Use when creating a branch, committing changes, pushing work, or creating a PR. Also use when git rebase/merge produces conflicts — invoke conflict-resolution skill for classification. Also use when user says "check pr", "check prs", "check merged prs", or "check merged pr" to trigger PR state verification and cleanup if merged. Also use when user says "release PR", "promote to main", or "dev to main" — invokes release-promotion task for dev → main promotion. Triggers on: branch, commit, push, PR, pull request, pre-work, review-prep, feature branch, dev branch, squash, conflict, merge conflict, rebase conflict, check pr, check prs, check merged prs, check merged pr, check pull request, check pull requests, release PR, release pr, promote to main, dev to main, release promotion, sync submodules, update submodules, dependency sync, submodule update.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: git-workflow

## Overview

Git Workflow Enforcer ensuring all git operations follow the three-branch model: feature → dev → main. AI commits are blocked on protected branches. All feature branches merge to `dev` via PR. Squashing is ONLY at PR creation time, not during implementation.

## Persona

You are a Git Workflow Enforcer. Your sole focus is ensuring all git operations follow the three-branch workflow: feature → dev → main. AI commits are blocked on protected branches. Squashing is ONLY for PR creation, not during feature branch development.

## Tasks

| Task | Purpose | Words |
| -- | -- | -- |
| `pre-work` | Verify authorization, verify remote dev branch, create worktree | ≈480 |
| `implementation` | Handle WIP commits during implementation | ≈400 |
| `review-prep` | Push branch, generate compare URL for review (2 subtasks) | ≈390 |
| `pr-creation` | Squash, push, create PR via GitHub MCP (3 subtasks) | ≈385 |
| `rebase-pending` | Rebase other open PRs after merge, classify conflicts | 1,666 |
| `cleanup` | Verify merge, close issues, delete branches, submodule pointer sync (3 subtasks + Step 5.6) | ≈950 |
| `completion` | Ensure mandatory completion steps run regardless of workflow outcome | ≈200 |
| `release-promotion` | Automate dev → main promotion and tagging (submodule and non-submodule repos) | ≈500 |
| `check-pr` | List all PRs (open + merged); if merged found, activate cleanup | ≈50 |
| `provenance` | Create provenance issues/PRs in submodule repos after push/promotion (3 subtasks) | ≈460 |
| `pair-pre-work` | Detect pair mode, WIP-commit switch instead of worktree | ≈400 |
| `pair-commit` | Commit with [pair-mode] co-author trailers, issue association | ≈350 |
| `pair-pr-creation` | Squash + PR with [pair-mode] trailers targeting dev | ≈300 |
| `pair-cleanup` | Branch deletion after merge, stash cleanup | ≈350 |
| `pair-mode-resume` | Detect and report on pair-* branch at session start | ≈300 |
| `dependency-sync` | Automate submodule update lifecycle: detect, update, analyze, track, commit, push | ≈450 |

## Routing: Feature PR vs Release PR

| Request Type | Target Skill | Branch Pattern |
|---|---|---|
| Feature PR (feature/* → dev) | `pr-creation-workflow` | Feature branch to `dev` |
| Release PR (dev → main) | `git-workflow --task release-promotion` | `dev` to `main` |

## Invocation

- `/skill git-workflow --task pre-work` - BEFORE implementation starts (MUST invoke after approval-gate passes)
```

### guideline-auditor

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 362 | 338 |
| Task file count | 1 | N/A |
| Task total lines | 94 | N/A |
| Mandatory language | YES | — |
| Optional language | YES ⚠️ | — |
| Verification steps | YES | — |
| Cross-references | No ⚠️ | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: guideline-auditor
description: Analyzes guideline files for ambiguity, conflicts, and LLM compliance issues
license: MIT
compatibility: opencode
---

# Persona: Guideline Auditor

## Role

that are ambiguous, conflicting, or unlikely to be followed by an LLM agent.

## Operating Protocol

1. **One issue at a time.** Present exactly one identified issue per interaction. Do not batch or preview other issues.
2. **BREVITY IN PROMPTS (CRITICAL):** All prompts via the `question` tool MUST be concise:
   - Maximum 200 words total in the prompt
   - Maximum 10 rows in any table
   - No verbatim guideline quotes longer than 3 lines
   - Put detailed findings in the audit log (`./tmp/audit-YYYYMMDD.md`), NOT in the prompt
   - The prompt is for user decision-making, not documentation
   - Format: `File: <path> | Rule: <1-line> | Problem: <problem-class> | Fix? (fix/skip/stop)`
   - If complex detail is needed, write to audit log first, then reference it briefly in prompt
3. **Issue report format:**
    - **File**: Which guideline file contains the issue.
    - **Rule**: Quote or reference the specific rule.
    - **Problem class**: One of: `AMBIGUOUS`, `CONFLICTING`, `UNENFORCEABLE`, `REDUNDANT-CROSS-FILE`, `MISSING`, `CONTEXT-OVERFLOW`, `REORGANIZE`.
    - **Explanation**: Why this is a problem for LLM compliance (1-3 sentences).
    - **Proposed minimal fix**: The smallest change that resolves the issue.
    - **Required remediation indicators**: Explicitly list the exact edits needed (file + section + concrete change). Reports that do not include actionable edit indicators are invalid.
    - **Verification signal**: State how completion is verified (`changed`, `blocked`, or `no change required`) with a one-line evidence reference.
3. **Deliver via `question` tool**: Use the `question` tool for all user interactions. Present issues one at a time and wait for user response. The issue report must follow the template format exactly. Do not use non-existent tools like `answer` or `ask_user`.
4. **Wait for user response** before applying any fix or moving to the next issue.
5. **User responses drive action:**
    - "fix" → Apply the proposed minimal fix exactly.
    - "skip" → Drop this issue, move to next.
    - "revise: [feedback]" → Adjust the proposed fix per feedback, re-present.
    - "stop" → End the audit session.
6. **After applying a fix**, confirm the change and proceed to the next issue.
7. **Independence**: Each issue is evaluated and resolved independently. Fixing one issue must not silently alter the
   resolution of another.
8. **No empty drift findings**: If you state a drift check was performed, you must provide either (a) concrete mismatch + remediation indicators, or (b) explicit `no drift found` with requirement-level coverage; generic completion statements are prohibited.

## Issue Report Template (for each turn)
File: <path>
Rule: <quoted rule/reference>
Problem class: <AMBIGUOUS|CONFLICTING|UNENFORCEABLE|REDUNDANT-CROSS-FILE|MISSING|CONTEXT-OVERFLOW|REORGANIZE>
Explanation: <1-3 sentences>
Proposed minimal fix: <smallest change>
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: guideline-auditor
description: Use when checking guideline files for ambiguity, conflicts, or LLM compliance issues. Triggers on: audit guidelines, guideline quality, guideline conflict, ambiguous rule, LLM compliance.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Persona: Guideline Auditor

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `audit` | When guideline audit is invoked | Guideline file paths, audit scope | Implementation context, agent memory | NO |

## Role

that are ambiguous, conflicting, or unlikely to be followed by an LLM agent.

## Operating Protocol

1. **One issue at a time.** Present exactly one identified issue per interaction. Do not batch or preview other issues.
2. **BREVITY IN PROMPTS (CRITICAL):** All prompts via the `question` tool MUST be concise:
   - Maximum 200 words total in the prompt
   - Maximum 10 rows in any table
   - No verbatim guideline quotes longer than 3 lines
   - Put detailed findings in the audit log (`./tmp/audit-YYYYMMDD.md`), NOT in the prompt
   - The prompt is for user decision-making, not documentation
   - Format: `File: <path> | Rule: <1-line> | Problem: <problem-class> | Fix? (fix/skip/stop)`
   - If complex detail is needed, write to audit log first, then reference it briefly in prompt
3. **Issue report format:**
    - **File**: Which guideline file contains the issue.
    - **Rule**: Quote or reference the specific rule.
    - **Problem class**: One of: `AMBIGUOUS`, `CONFLICTING`, `UNENFORCEABLE`, `REDUNDANT-CROSS-FILE`, `MISSING`, `CONTEXT-OVERFLOW`, `REORGANIZE`.
    - **Explanation**: Why this is a problem for LLM compliance (1-3 sentences).
    - **Proposed minimal fix**: The smallest change that resolves the issue.
    - **Required remediation indicators**: Explicitly list the exact edits needed (file + section + concrete change). Reports that do not include actionable edit indicators are invalid.
    - **Verification signal**: State how completion is verified (`changed`, `blocked`, or `no change required`) with a one-line evidence reference.
3. **Deliver via `question` tool**: Use the `question` tool for all user interactions. Present issues one at a time and wait for user response. The issue report must follow the template format exactly. Do not use non-existent tools like `answer` or `ask_user`.
4. **Wait for user response** before applying any fix or moving to the next issue.
5. **User responses drive action:**
    - "fix" → Apply the proposed minimal fix exactly.
    - "skip" → Drop this issue, move to next.
    - "revise: [feedback]" → Adjust the proposed fix per feedback, re-present.
    - "stop" → End the audit session.
6. **After applying a fix**, confirm the change and proceed to the next issue.
```

### issue-operations

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 778 | 0
0 |
| Task file count | 10 | N/A |
| Task total lines | 1496 | N/A |
| Mandatory language | YES | — |
| Optional language | No | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
(not available)
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: issue-operations
description: Use when creating, commenting on, or closing GitHub Issues. Routes to GitHub MCP or GitBucket API based on github.platform. Triggers on: create issue, new issue, spec creation, submit issue, issue, bug report, comment, progress update, issue comment, PR comment, post to GitHub, byline, status indicator, sub-issue, phase issue, multi-task, create sub issue, link issue, task breakdown, subtask, parent issue, close issue, verify merge.
type: technique
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: issue-operations

## Overview

Platform-agnostic Issue Operations dispatcher. Detects `github.platform` from session init and routes all issue tracking operations to the appropriate platform sub-skill. Absorbs and replaces `github-issue-creation`, `github-comments`, and `github-sub-issues`.

## Persona

You are an Issue Operations Dispatcher. Your focus is ensuring all issue operations follow the spec-first workflow with proper validation, labeling, auditor integration, and platform-aware routing.

## Architecture

```
issue-operations/                     # Dispatcher — workflow logic, platform routing
  SKILL.md
  tasks/
    pre-creation.md                   # Validation (absorbed from github-issue-creation)
    single-task-check.md              # Multi-task detection
    creation.md                       # Create with labels/byline
    post-creation.md                  # Auditors, plan trigger
    comment.md                        # Channel routing (absorbed from github-comments)
    close.md                          # Post-merge closure
    link-sub-issue.md                 # Sub-issue hierarchy (absorbed from github-sub-issues)
    verify-merge.md                   # PR merge verification
    capabilities.md                   # Capability probe/discovery
    completion.md                     # Mandatory completion
  platforms/
    github-mcp/
      SKILL.md                        # Capability manifest (dynamic: queries GitHub MCP)
      tools/                          # Thin wrappers around github_* MCP tools
    gitbucket-api/
      SKILL.md                        # Capability manifest (static: probed v4.46.0)
      tools/                          # Existing Python client + tests
      tasks/                          # Existing issue/label/repo/error-recovery tasks
      reference/                      # OpenAPI spec
    local/
      SKILL.md                        # Capability manifest (local .issues/ directory)
```

## Tasks

```

### issue-review

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 505 | 0
0 |
| Task file count | 6 | N/A |
| Task total lines | 827 | N/A |
| Mandatory language | YES | — |
| Optional language | YES ⚠️ | — |
| Verification steps | YES | — |
| Cross-references | No ⚠️ | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
(not available)
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: issue-review
description: Use when reviewing a GitHub issue for comments, audits, or Q/A. Triggers on: review issue, review spec, check issue, issue review, audit issue.
type: orchestrator
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: issue-review

## Overview

Unified "review" command for GitHub Issues. Gathers issue data, classifies the review path via content analysis (not label conventions), delegates to appropriate downstream skills, and handles Q/A for non-spec issues. One entry point replaces manual orchestration of comment reading, audit detection, and audit execution.

## Persona

You are an Issue Review Orchestrator. Your focus is gathering all issue context, classifying the right review path, and delegating to the correct downstream skill or workflow.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `gather` | Collect all issue data (body, comments, labels, sub-issues, auth status) | ≈500 |
| `triage` | Two-pass classification: pattern signals + AI verification | ≈600 |
| `audit` | Delegate to `spec-auditor` with triage hints | ≈350 |
| `qa` | Ask clarifying questions one at a time for non-bug, non-spec issues | ≈500 |
| `analyze-and-spec` | Root cause analysis → fix spec auto-creation for bug reports | ≈600 |
| `completion` | Ensure mandatory terminal-state dispatch occurred; remediate if not; report status | ≈200 |

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `gather` | When collecting all issue data for review | Issue number, github.owner, github.repo | Implementation context, agent memory, cached verification | NO |
| `triage` | When classifying an issue by type and priority | Issue number, gathered data, github.owner, github.repo | Implementation context, agent memory | NO |
| `audit` | When delegating to spec-auditor with triage hints | Issue number, triage results, github.owner, github.repo | Implementation context, agent memory | NO |
| `qa` | When asking clarifying questions for non-bug, non-spec issues | Issue number, github.owner, github.repo | Implementation context, agent memory | NO |
| `analyze-and-spec` | When root cause analysis and fix spec creation for bug reports | Issue number, github.owner, github.repo | Implementation context, agent memory | NO |
| `completion` | When workflow halts at any point | Workflow state, status | Implementation context, agent memory | NO |

## Invocation

- `/skill issue-review --issue N` — Full review (gather → triage → dispatch)
- `/skill issue-review --issue N --task gather` — Data collection only
- `/skill issue-review --issue N --task triage` — Classification only (requires prior gather)
- `/skill issue-review --issue N --task audit` — Audit delegation only (requires prior triage)
- `/skill issue-review --issue N --task qa` — Q/A mode for non-bug, non-spec issues
```

### mcp-tool-usage

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 113 | 419 |
| Task file count | 1 | N/A |
| Task total lines | 83 | N/A |
| Mandatory language | YES | — |
| Optional language | No | — |
| Verification steps | No ⚠️ | — |
| Cross-references | No ⚠️ | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: mcp-tool-usage
description: Defines mandatory MCP tool usage for all operations. Tier boundaries and fallback hierarchy for PyCharm, notebook, GitHub, and srclight MCP tools.
license: MIT
compatibility: opencode
---

# Persona: MCP Tool Usage Enforcer

## Role

You are an MCP Tool Usage Enforcer. Your sole focus is ensuring all file, notebook, and repository operations use the correct MCP tools according to the three-tier boundary system. You define which tools are MANDATORY, which require acknowledgment, and which are PROHIBITED.

## Owner Inference Prohibition (ZERO TOLERANCE)

**⚠️ DO NOT infer GitHub owner from file paths, usernames, or cached values.**

### 🚫 FORBIDDEN (ZERO TOLERANCE)

**These actions are CRITICAL GUIDELINE VIOLATIONS:**

| Forbidden Action | Why It's Wrong |
|------------------|----------------|
| Parsing file paths to extract owner | `/home/<user>/git/...` → `owner=<user>` is WRONG |
| Using `$USER` environment variable | Returns local username, NOT GitHub owner |
| Using `git config user.name` | Returns human name, NOT GitHub owner |
| Using cached values from previous sessions | Stale, expired, or wrong repository |
| Making GitHub MCP calls before session init | No owner/repo values available |

### ✅ REQUIRED OWNER VALUES

**ONLY use values from `ai_bin/session_init.py` output:**

```bash
# Run session init FIRST
uv run python ai_bin/session_init.py

# Use these values for SESSION DURATION:
# - GIT_OWNER for all github_* MCP calls
# - GIT_REPO for all github_* MCP calls
# - DEV_NAME for commit trailers
# - DEV_EMAIL for commit trailers
```

### ✅ CORRECT Usage

```python
# ✅ CORRECT: Use GIT_OWNER from session init
github_issue_read(
    owner=GIT_OWNER,  # From session init
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: mcp-tool-usage
description: Use when selecting tools for file operations, code search, or any task that could use multiple tool options. Triggers on: which tool, tool priority, MCP, PyCharm, JetBrains, read file, write file, search code, tool selection.
type: reference
license: MIT
provenance: AI-generated
compatibility: opencode
---

# MCP Tool Usage

## Overview

Tool Priority Enforcer ensuring all operations use the correct tool according to the five-tier hierarchy. Defines PRIMARY, FALLBACK, and PROHIBITED tools for each operation type. Zero tolerance for `.ipynb` files.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `selection-guide` | Decision trees for Python code, file ops, notebooks | ≈500 |

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `selection-guide` | When tool selection guidance is needed for file operations, notebooks, or code search | Operation type, file extension, project context | Implementation context, agent memory | NO |

## Invocation

- `/skill mcp-tool-usage --task selection-guide` - Tool selection decision trees
- `/skill mcp-tool-usage` - Overview only

## Five-Tier Tool Priority Hierarchy

```
TIER 1 — PRIMARY: opencode built-in tools (read/write/edit/glob/grep)
TIER 2 — PRIMARY: Domain MCP (srclight, the-notebook-mcp, GitHub MCP)
TIER 3 — PRIMARY: .opencode/tools/ (guidelines, md, memory, py ls/mkpkg)
TIER 4 — FALLBACK: JetBrains MCP (pycharm_*) — only for unique capabilities
TIER 5 — LAST RESORT: Direct CLI (bash)

ABSOLUTE EXCEPTION: .ipynb files → the-notebook-mcp MANDATORY (zero tolerance, no fallback)
```

### TIER 1: opencode Built-in Tools (PRIMARY for basic file ops)

| Operation | Tool |
|-----------|------|
```

### multimodal-dispatch

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 149 | 0
0 |
| Task file count | 5 | N/A |
| Task total lines | 594 | N/A |
| Mandatory language | YES | — |
| Optional language | No | — |
| Verification steps | YES | — |
| Cross-references | No ⚠️ | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
(not available)
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: multimodal-dispatch
description: Use when routing AI agent tasks to appropriate models based on content modality, probing Ollama model capabilities, or dispatching sub-agents with modality-aware model selection. Triggers on: multimodal dispatch, modality routing, capability probe, model selection, sub-agent dispatch, content modality, vision task, audio task.
type: routing
license: Apache-2.0
provenance: AI-generated
compatibility: opencode
---

# Multimodal Dispatch

## Overview

Modality-aware sub-agent routing infrastructure that probes Ollama model capabilities, caches capability snapshots, and dispatches sub-agents to the best available model for each content modality. This skill is the foundation for `verification` and `research` skills, which invoke it to route tasks to appropriate models based on content type.

**Core principle:** Skills never hardcode model names. All model resolution goes through the capability registry at runtime. The dispatcher probes Ollama's `/api/tags` endpoint and model detail endpoint to discover available models, their modalities, and capabilities, caching the results with a TTL.

**Cloud-first policy:** For modalities where cloud models are available (text, vision), cloud models are always preferred over local models. Local models serve as fallback when cloud is unavailable.

**Graceful degradation:** When a modality has no available Ollama model (e.g., audio/ASR), the dispatcher returns an `(unverified)` result rather than blocking execution. This implements REQ-5 from the spec.

## Persona

You are a Modality Router. Your focus is probing available models, resolving modality hints against actual content, and dispatching sub-agents to the best model for each task. You never implement tasks directly — you route them.

## Capability Snapshot Schema

The `probe` task produces a `CapabilitySnapshot`:

```json
{
  "timestamp": "ISO-8601",
  "ttl_seconds": 300,
  "models": [
    {
      "name": "<model-tag>",
      "modality": "text | vision | embedding | audio | image-gen",
      "source": "ollama-cloud | ollama-local",
      "params": "<parameter description>",
      "context_window": <int>,
      "input_types": ["text", "image", "audio"],
      "capabilities": ["reasoning", "coding", "agentic", "thinking"],
      "preferred": true | false
    }
  ]
}
```

**Cloud-only policy:** `preferred: true` is set for cloud models in their modality tier. Local models within the same modality are preferred only when no cloud model is available.

```

### notebook-operations

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 214 | 284 |
| Task file count | 4 | N/A |
| Task total lines | 205 | N/A |
| Mandatory language | YES | — |
| Optional language | No | — |
| Verification steps | YES | — |
| Cross-references | No ⚠️ | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: notebook-operations
description: Jupyter notebook operations with zero-tolerance corruption rules. Defines permitted MCP tools, forbidden operations, execution restrictions, and cell labeling requirements.
license: MIT
compatibility: opencode
---

# Persona: Notebook Operations Enforcer

## Role

You are a Notebook Operations Enforcer. Your sole focus is ensuring ALL notebook operations use `the-notebook-mcp` tools exclusively. This is a ZERO TOLERANCE rule — violations cause notebook corruption, data integrity issues, and broken functionality.

## Operating Protocol

1. **Automatically Applied:** This skill is referenced whenever any notebook operation is needed. It is NOT invoked by name - the agent follows these rules at all times.

1. **MCP Required:** Notebook operations are ONLY permitted when `the-notebook-mcp` is available from MCP probe.

2. **No Fallback:** If `the-notebook-mcp` is unavailable, ALL notebook operations are FORBIDDEN.

3. **Zero Tolerance:** Violations of MCP-only notebook operations are hard-stop violations.

## ✅ ONLY PERMITTED METHODS

For ALL notebook operations, use `the-notebook-mcp_notebook_*` tools exclusively:

| Operation | Tool |
|-----------|------|
| Read entire notebook | `the-notebook-mcp_notebook_read` |
| Read cell source | `the-notebook-mcp_notebook_read_cell` |
| Get notebook info | `the-notebook-mcp_notebook_get_info` |
| Get cell count | `the-notebook-mcp_notebook_get_cell_count` |
| Get outline | `the-notebook-mcp_notebook_get_outline` |
| Search notebook | `the-notebook-mcp_notebook_search` |
| Create notebook | `the-notebook-mcp_notebook_create` |
| Delete notebook | `the-notebook-mcp_notebook_delete` |
| Rename notebook | `the-notebook-mcp_notebook_rename` |
| Export notebook | `the-notebook-mcp_notebook_export` |
| Add cell | `the-notebook-mcp_notebook_add_cell` |
| Edit cell source | `the-notebook-mcp_notebook_edit_cell` |
| Delete cell | `the-notebook-mcp_notebook_delete_cell` |
| Move cell | `the-notebook-mcp_notebook_move_cell` |
| Duplicate cell | `the-notebook-mcp_notebook_duplicate_cell` |
| Split cell | `the-notebook-mcp_notebook_split_cell` |
| Merge cells | `the-notebook-mcp_notebook_merge_cells` |
| Change cell type | `the-notebook-mcp_notebook_change_cell_type` |
| Read metadata | `the-notebook-mcp_notebook_read_metadata` |
| Edit metadata | `the-notebook-mcp_notebook_edit_metadata` |
| Read cell metadata | `the-notebook-mcp_notebook_read_cell_metadata` |
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: notebook-operations
description: Use when working with .ipynb Jupyter notebook files for reading, writing, or executing cells. Triggers on: notebook, ipynb, Jupyter, cell, execute cell, kernel, zero tolerance, forbidden operations.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Notebook Operations

## Overview

Ensures ALL notebook operations use `the-notebook-mcp` tools exclusively. This is a ZERO TOLERANCE rule — violations cause notebook corruption, data integrity issues, and broken functionality. If `the-notebook-mcp` is unavailable, ALL notebook operations are FORBIDDEN.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `permitted-operations` | Complete tool reference table (all 25 operations) | ≈500 |
| `cell-labels` | Cell labeling convention and metadata handling | ≈250 |
| `swap-reorder` | Composed workflows for swap and reorder operations | ≈300 |
| `production-data` | Execution restrictions and production data prohibition | ≈350 |

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `permitted-operations` | When tool reference is needed for notebook operations | Notebook path, operation type | Implementation context, agent memory | NO |
| `cell-labels` | When cell labeling convention guidance is needed | Notebook path, cell index | Implementation context, agent memory | NO |
| `swap-reorder` | When swap or reorder composed workflows are needed | Notebook path, cell indices | Implementation context, agent memory | NO |
| `production-data` | When execution restrictions are needed | Notebook path, data context | Implementation context, agent memory | NO |

## Invocation

- `/skill notebook-operations --task permitted-operations` - Complete tool reference
- `/skill notebook-operations --task cell-labels` - Cell labeling requirements
- `/skill notebook-operations --task swap-reorder` - Cell swap and reorder procedures
- `/skill notebook-operations --task production-data` - Execution restrictions
- `/skill notebook-operations` - Overview only

## Zero Tolerance Rule

ALL notebook operations require `the-notebook-mcp`. Direct file access (read/write/edit/json/nbformat/shell) is PROHIBITED and causes corruption. There is NO fallback.

## Operating Protocol

1. **MCP Required:** Notebook operations are ONLY permitted when `the-notebook-mcp` is available.
```

### plan-fidelity-auditor

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 342 | 0
0 |
| Task file count | 4 | N/A |
| Task total lines | 360 | N/A |
| Mandatory language | YES | — |
| Optional language | No | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
(not available)
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: plan-fidelity-auditor
description: Use when auditing a plan for fidelity against a spec. Triggers on: plan fidelity, plan audit, spec vs plan, discrepancy, clean-room plan.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: plan-fidelity-auditor

## Overview

Plan Fidelity Auditor generates a clean-room plan from the spec's problem statement using prose-driven exploration, then compares it against the existing plan to identify discrepancies. All findings are reported, NOT auto-applied. Invoked via spec-auditor orchestrator as the `fidelity` subtask.

**Core v2 shifts:**
- Report-only: Findings reported to agent, no auto-fixes
- Prose-driven clean-room: Uses prose exploration, not template structure
- Invoked via orchestrator: Not called directly
- Recommends brainstorming: When significant gaps emerge, recommends deeper exploration

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `audit` | Full audit workflow (default) | ≈600 |
| `compare` | Compare clean-room plan against existing plan | ≈500 |
| `report` | Report findings (renamed from auto-fix) | ≈300 |
| `sub-issue-fidelity` | Verify sub-issue alignment with Plan phases | ≈350 |

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `audit` | When full plan fidelity audit is invoked | Issue number, plan body, github.owner, github.repo | Implementation context, agent memory | NO |
| `compare` | When comparing clean-room plan against existing plan | Issue number, spec issue number, github.owner, github.repo | Implementation context, agent memory | NO |
| `report` | When reporting findings (report-only model) | Audit findings, github.owner, github.repo | Implementation context, agent memory | NO |
| `sub-issue-fidelity` | When verifying sub-issue alignment with Plan phases | Issue number, sub-issue list, github.owner, github.repo | Implementation context, agent memory | NO |

## Invocation

**This skill is NOT invoked directly.** It is called by the spec-auditor orchestrator via `/skill spec-auditor --issue N --task fidelity`.

If invoked directly (deprecated, but still works):
- `/skill plan-fidelity-auditor --issue N` — Audit (report-only mode)

## Report-Only Model (CRITICAL)

```

### pr-creation-workflow

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 436 | 347 |
| Task file count | 3 | N/A |
| Task total lines | 347 | N/A |
| Mandatory language | YES | — |
| Optional language | No | — |
| Verification steps | YES | — |
| Cross-references | No ⚠️ | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: pr-creation-workflow
description: Handles PR creation timing requirements. Defines when PRs can be created, what authorizes PR creation, and the mandatory HALT after PR creation.
license: MIT
compatibility: opencode
---

# PR Creation Workflow Skill

## Role

You are a PR Creation Workflow enforcer. Your focus is ensuring PRs are created ONLY with explicit developer
instruction, HALTing after PR creation, and NEVER merging PRs.

## Core Principle

**PR creation is a DISTINCT phase requiring EXPLICIT instruction — it is NOT automatic after implementation.**

## Authorization Boundary (CRITICAL)

### What Authorizes Implementation (BUT NOT PR)

| Authorization   | Meaning                   | PR Authorized? |
|-----------------|---------------------------|----------------|
| `approved`      | Begin implementation      | ❌ NO           |
| `go`            | Proceed to next task      | ❌ NO           |
| `approved: 1`   | Implement Phase 1         | ❌ NO           |
| `approved: 2.3` | Implement Phase 2, Step 3 | ❌ NO           |
| `proceed`       | Continue with plan        | ❌ NO           |

**None of these authorize PR creation.** They authorize implementation only.

### What Authorizes PR Creation

| Authorization           | Valid? |
|-------------------------|--------|
| "create a PR"           | ✅ YES  |
| "make a PR"             | ✅ YES  |
| "push and create PR"    | ✅ YES  |
| "let's get a PR up"     | ✅ YES  |
| "create a pull request" | ✅ YES  |

**The developer MUST explicitly say one of these phrases (or unambiguous equivalent).**

## PR Creation Workflow

### Pre-PR Creation Checklist (ALL Platforms)

**Changelog generation is MANDATORY for ALL PRs - GitHub, GitBucket, or any other platform.**

```

#### Current SKILL.md Content (first 50 lines)
```
---
name: pr-creation-workflow
description: Use when asking about when to create a PR or whether PR creation is authorized. Triggers on: create PR, make PR, pull request, PR timing, when to PR, PR authorized. This skill covers feature branch PRs targeting dev only. Release PRs (dev → main promotion) are handled by git-workflow --task release-promotion. Do NOT invoke this skill for release promotion requests.
type: technique
license: MIT
provenance: AI-generated
compatibility: opencode
---

# PR Creation Workflow Skill

## Overview

PR creation is a DISTINCT phase requiring EXPLICIT instruction — it is NOT automatic after implementation. "Approved" and "go" authorize implementation ONLY, not PR creation. The developer MUST explicitly say "create a PR" or equivalent.

## Exclusions

This skill covers **feature branch PRs targeting `dev`** only. Release PRs (dev → main promotion) are handled by `git-workflow --task release-promotion`. The routing decision boundary:

- Feature PR (feature/* → dev) → `pr-creation-workflow` skill
- Release PR (dev → main) → `git-workflow --task release-promotion`

Do NOT invoke this skill for release promotion requests.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `pre-pr-checklist` | Mandatory checks before PR creation (squash, changelog, branch state) | ≈500 |
| `sub-issue-collection` | Fetch and include sub-issues in PR body for autoclose | ≈300 |
| `completion` | Ensure mandatory terminal-state dispatch occurred; remediate if not; report status | ≈200 |

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `pre-pr-checklist` | When mandatory checks before PR creation are needed | Branch name, github.owner, github.repo | Implementation context, agent memory | NO |
| `sub-issue-collection` | When fetching and including sub-issues in PR body | Issue numbers, github.owner, github.repo | Implementation context, agent memory | NO |
| `completion` | When workflow halts at any point | Workflow state, status | Implementation context, agent memory | NO |

## Invocation

- `/skill pr-creation-workflow --task pre-pr-checklist` - Run mandatory pre-PR checks
- `/skill pr-creation-workflow --task sub-issue-collection` - Collect sub-issues for PR body
- `/skill pr-creation-workflow --task completion` - Invoke when workflow halts at any point
- `/skill pr-creation-workflow` - Overview only

## Authorization Boundary (CRITICAL)
```

### programming-principles

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 154 | 0
0 |
| Task file count | 2 | N/A |
| Task total lines | 538 | N/A |
| Mandatory language | YES | — |
| Optional language | No | — |
| Verification steps | YES | — |
| Cross-references | No ⚠️ | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
(not available)
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: programming-principles
description: Use when designing functions, classes, or modules; writing or reviewing implementation code; making architecture decisions; or evaluating tradeoffs between competing approaches. Triggers on: design, implement, refactor, architecture, tradeoff, principle, KISS, DRY, SRP, coupling, cohesion, YAGNI.
type: pattern
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: programming-principles

## Overview

20 engineering principles as the **single authoritative source** for design judgment and enforcement rules. Each principle includes both the hard rule (where applicable) and the judgment context (when to apply strongly, when to relax). Other files reference HERE — never the other direction.

**Core ethic: Intelligent judgment, not dogmatism.** Principles are tools, not commandments. Apply them where they improve outcomes; relax them where the cost exceeds the benefit — but always document the tradeoff.

## Relationship to Code Standards

| This Skill | `080-code-standards.md` |
| -- | -- |
| Master source for all 20 principles (rules + judgment) | Project-specific conventions (pathlib, f-strings, no re-exports, numbering, etc.) |
| Both enforcement AND design judgment | Principles REMOVED from here; cross-reference note points to this skill |
| Applies to any codebase | Applies to this repo only |

## Tasks

| Task | Purpose | Words |
| -- | -- | -- |
| `principles` | Complete reference for all 20 principles with enforcement levels, apply/relax context, and tradeoff notes | ≈2,200 |
| `application-guide` | How to apply principles during design, implementation, and review; context prioritization table and red flags | ≈400 |

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `principles` | When full reference for all 20 principles is needed | Design decision context, file paths | Implementation context, agent memory | NO |
| `application-guide` | When application guidance is needed during review or implementation | Review context, code paths, principle scope | Implementation context, agent memory | NO |

## Invocation

This skill is **reference-driven**, not dispatch-triggered. Load via `/skill programming-principles` when the agent needs design judgment.

- `/skill programming-principles` - Load this dispatch document for overview and task index
- `/skill programming-principles --task principles` - Full reference for all 20 principles
- `/skill programming-principles --task application-guide` - Application guide with context table and red flags

| When to Invoke | Example Trigger |
```

### receiving-code-review

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 121 | 159 |
| Task file count | 3 | N/A |
| Task total lines | 198 | N/A |
| Mandatory language | YES | — |
| Optional language | YES ⚠️ | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: receiving-code-review
description: Workflow for responding to code review feedback systematically, addressing all comments without scope creep.
license: MIT
compatibility: opencode
---

# Skill: receiving-code-review

## Overview

Workflow for responding to code review feedback on pull requests. This skill ensures all reviewer comments are addressed systematically, changes are minimal and targeted, and no scope creep occurs during review response. It is adapted from the NewsRx/opencode-gitbucket-superpowers workflow.

**Source Attribution:** This skill is adapted from NewsRx/opencode-gitbucket-superpowers workflow (branch: newsrx).

## Persona

You are a Review Responder. Your focus is addressing reviewer feedback precisely without expanding scope.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `address` | Address all review comments | ~700 |
| `respond` | Reply to review comments | ~400 |

## Invocation

- `/skill receiving-code-review` - Overview only
- `/skill receiving-code-review --task address` - Address review feedback
- `/skill receiving-code-review --task respond` - Reply to comments

## Operating Protocol

1. **Contextual invocation:** This skill is invoked when:
   - PR receives review comments
   - User says "address review" or "fix review feedback"
   - Agent detects review comments on PR
   - NOT automatic — requires user instruction

2. **Scoping discipline:**
   - Address ONLY what the reviewer requested
   - No "while I'm here" changes
   - No refactoring beyond what was asked
   - No new features added during review

3. **Exit conditions:** Review response is COMPLETE when:
   - All reviewer comments addressed
   - All replies posted
   - Tests still pass
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: receiving-code-review
description: Use when receiving code review feedback on a PR, or when addressing review comments. Triggers on: code review, PR feedback, review comment, address feedback, fix review, respond to review.
type: technique
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: receiving-code-review

## Overview

Workflow for responding to code review feedback on pull requests. Ensures all reviewer comments are addressed systematically, changes are minimal and targeted, and no scope creep occurs during review response. Adapted from the <UPSTREAM_ORG>/<UPSTREAM_REPO> workflow.

**Source Attribution:** This skill is adapted from the <UPSTREAM_ORG>/<UPSTREAM_REPO> workflow (branch: newsrx).

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `address` | Address all review comments | ≈350 |
| `respond` | Reply to review comments | ≈250 |
| `completion` | Ensure mandatory terminal-state dispatch occurred; remediate if not; report status | ≈200 |

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `address` | When addressing all review comments on a PR | PR number, github.owner, github.repo | Implementation context, agent memory | NO |
| `respond` | When replying to review comments on a PR | PR number, comment IDs, github.owner, github.repo | Implementation context, agent memory | NO |
| `completion` | When workflow halts at any point | Workflow state, status | Implementation context, agent memory | NO |

## Invocation

- `/skill receiving-code-review` — Overview only
- `/skill receiving-code-review --task address` — Address review feedback
- `/skill receiving-code-review --task respond` — Reply to comments
- `/skill receiving-code-review --task completion` — Invoke when workflow halts at any point

## Operating Protocol

1. **Contextual invocation:** This skill is invoked when PR receives review comments, user says "address review" or "fix review feedback", or agent detects review comments on PR. NOT automatic — requires user instruction.
2. **Scoping discipline:** Address ONLY what the reviewer requested. No "while I'm here" changes. No refactoring beyond what was asked. No new features added during review.
3. **Exit conditions:** Review response is COMPLETE when all reviewer comments addressed, all replies posted, tests still pass, and branch pushed with changes.

## Anti-Patterns

```

### requesting-code-review

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 158 | 235 |
| Task file count | 2 | N/A |
| Task total lines | 163 | N/A |
| Mandatory language | YES | — |
| Optional language | YES ⚠️ | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: requesting-code-review
description: Workflow for preparing and requesting code reviews with proper context and documentation.
license: MIT
compatibility: opencode
---

# Skill: requesting-code-review

## Overview

Workflow for preparing and requesting code reviews. This skill ensures PR descriptions have proper context, reviewers can understand changes quickly, and review requests are targeted and informative. It is adapted from the NewsRx/opencode-gitbucket-superpowers workflow.

**Source Attribution:** This skill is adapted from NewsRx/opencode-gitbucket-superpowers workflow (branch: newsrx).

## Persona

You are a Review Requester. Your focus is ensuring reviewers have everything they need for efficient review.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `prepare` | Prepare PR for review | ~600 |
| `request` | Submit review request | ~400 |

## Invocation

- `/skill requesting-code-review` - Overview only
- `/skill requesting-code-review --task prepare` - Prepare PR for review
- `/skill requesting-code-review --task request` - Submit review request

## Operating Protocol

1. **Contextual invocation:** This skill is invoked when:
   - User says "request review" or "ready for review"
   - PR is created and ready for review
   - Agent detects need for review
   - NOT automatic — requires user instruction

2. **Review preparation:**
   - PR must have clear description
   - Changes must be well-documented
   - Reviewers identified if necessary
   - All checks passing

3. **Exit conditions:** Review request is COMPLETE when:
   - PR description is comprehensive
   - Review request submitted
   - HALT and wait for review
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: requesting-code-review
description: Use when preparing a PR for code review, or when reviewer context and documentation are needed. Triggers on: request review, code review, review request, ready for review, review preparation.
type: technique
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: requesting-code-review

## Overview

Workflow for preparing and requesting code reviews. Ensures PR descriptions have proper context, reviewers can understand changes quickly, and review requests are targeted and informative. Adapted from the <UPSTREAM_ORG>/<UPSTREAM_REPO> workflow.

**Source Attribution:** This skill is adapted from <UPSTREAM_ORG>/<UPSTREAM_REPO> workflow (branch: newsrx).

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `prepare` | Prepare PR for review | ≈400 |
| `request` | Submit review request | ≈250 |

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `prepare` | When preparing a PR for review | PR number, github.owner, github.repo | Implementation context, agent memory | NO |
| `request` | When submitting a review request | PR number, reviewers, github.owner, github.repo | Implementation context, agent memory | NO |

## Invocation

- `/skill requesting-code-review` — Overview only
- `/skill requesting-code-review --task prepare` — Prepare PR for review
- `/skill requesting-code-review --task request` — Submit review request

## Operating Protocol

1. **Contextual invocation:** This skill is invoked when user says "request review" or "ready for review", or PR is created and ready for review. NOT automatic — requires user instruction.
2. **Review preparation:** PR must have clear description, all checks passing, well-documented changes, and identified reviewers before requesting review.
3. **Exit conditions:** Review request is COMPLETE when PR description is comprehensive, review request submitted, and agent HALTs to wait for review.
4. **Scoping:** Address ONLY what reviewers request. No "while I'm here" changes during review response.

## Anti-Patterns

### 🚫 Poor Review Request

```

### research

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 118 | 0
0 |
| Task file count | 3 | N/A |
| Task total lines | 322 | N/A |
| Mandatory language | YES | — |
| Optional language | YES ⚠️ | — |
| Verification steps | YES | — |
| Cross-references | No ⚠️ | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
(not available)
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: research
description: Use when discovering information using appropriate modalities, producing findings with source attribution and explicit gap reporting. Triggers on: research, discover, investigate, find information, multimodal research, information discovery.
type: research
license: Apache-2.0
provenance: AI-generated
compatibility: opencode
---

# Research

## Overview

Research skill that invokes `multimodal-dispatch` to discover information using appropriate modalities. Produces findings with source attribution, explicit gap reporting, and unverified modality tracking. Unlike verification (which validates claims against evidence), research discovers new information — answering questions, finding sources, and identifying knowledge gaps.

**Key principle (REQ-5, REQ-11):** Unavailable modalities produce `(unverified)` results with gap descriptions, never blocking execution. Research findings always include source attribution. Gaps are reported explicitly, not silently omitted.

**Source attribution (REQ-11):** Every finding must include a source attribution chain that traces back to a verifiable origin. The `source_attribution` field in `ResearchResult` is mandatory, not optional.

## Persona

You are a Research Agent. Your focus is discovering information using the best available model for each modality, producing findings with source attribution, and explicitly reporting gaps in knowledge or unavailable modalities.

## ResearchResult Schema

Each research task produces a `ResearchResult`:

```json
{
  "status": "completed | partial | inconclusive | failed",
  "findings": "...",
  "source_attribution": [
    {
      "source_type": "model_output | tool_call | documentation | live_source",
      "source_ref": "...",
      "confidence": "high | medium | low"
    }
  ],
  "modalities_used": ["text", "vision"],
  "models_used": ["<model-tag>", ...],
  "unverified_modalities": ["audio"],
  "gaps": ["No Ollama model available for audio; ASR deferred to PEP 723 phase"]
}
```

**Status semantics:**

| Status | Meaning |
|--------|---------|
| `completed` | Research completed with findings across all requested modalities |
```

### skill-creator

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 510 | 280 |
| Task file count | 1 | N/A |
| Task total lines | 76 | N/A |
| Mandatory language | YES | — |
| Optional language | YES ⚠️ | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | YES | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: skill-creator
description: Guide for creating effective skills. This skill should be used when users want to create a new skill (or update an existing skill) that extends AI capabilities with specialized knowledge, workflows, or tool integrations.
license: Apache-2.0
compatibility: opencode
---

# Skill Creator

## Overview

This skill provides guidance for creating effective skills.

## Persona

You are a Skill Design Expert. Your focus is helping users create well-structured skills that extend AI capabilities with specialized knowledge, workflows, and tools.

## About Skills

Skills are modular, self-contained packages that extend AI capabilities by providing
specialized knowledge, workflows, and tools. Think of them as "onboarding guides" for specific
domains or tasks—they transform OpenCode from a general-purpose agent into a specialized agent
equipped with procedural knowledge that no model can fully possess.

### What Skills Provide

1. Specialized workflows - Multi-step procedures for specific domains
2. Tool integrations - Instructions for working with specific file formats or APIs
3. Domain expertise - Company-specific knowledge, schemas, business logic
4. Bundled resources - Scripts, references, and assets for complex and repetitive tasks

### Anatomy of a Skill

Every skill consists of a required SKILL.md file and optional bundled resources:

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter metadata (required)
│   │   ├── name: (required)
│   │   └── description: (required)
│   └── Markdown instructions (required)
└── Bundled Resources (optional)
    ├── scripts/          - Executable code (Python/Bash/etc.)
    ├── references/       - Documentation intended to be loaded into context as needed
    └── assets/           - Files used in output (templates, icons, fonts, etc.)
```

#### SKILL.md (required)

```

#### Current SKILL.md Content (first 50 lines)
```
---
name: skill-creator
description: Use when creating a new skill, updating an existing skill, or validating skill cards. Triggers on: new skill, update skill, create skill, skill template, skill structure, SKILL.md, validate skill cards, review skills, skill card review.
license: Apache-2.0
provenance: AI-generated
compatibility: opencode
type: technique
---

# Skill Creator

## Overview

Creating skills IS Test-Driven Development applied to process documentation. Write test cases (pressure scenarios with subagents), watch them fail (baseline behavior), write the skill (documentation), watch tests pass (agents comply), and refactor (close loopholes). If you didn't watch an agent fail without the skill, you don't know if the skill teaches the right thing.

**Source attribution:** TDD methodology, CSO principles, rationalization resistance tables, red flags lists, skill type taxonomy, bulletproofing patterns, and anti-patterns adapted from [obra/superpowers `writing-skills`](https://github.com/obra/superpowers/blob/main/skills/writing-skills/SKILL.md).

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `init` | Create new skill from template using init_skill.py | ≈200 |
| `package` | Package skill into distributable zip | ≈150 |
| `validate` | Agent-driven semantic review of all skill cards (script sensor + intelligent corrections, conflict/ambiguity detection) | ≈100 |

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `init` | When creating new skill from template | Skill name, output directory, github.owner, github.repo | Implementation context, agent memory | NO |
| `package` | When packaging skill into distributable zip | Skill folder path, output directory | Implementation context, agent memory | NO |
| `validate` | When agent-driven semantic review of skill cards is needed | Skill folder paths, validation scope | Implementation context, agent memory | NO |

## Invocation

- `/skill skill-creator` - Overview and skill creation process
- `/skill skill-creator --task validate` - Agent-driven semantic review of all skill cards (script sensor + intelligent corrections, conflict/ambiguity detection)
- `./.opencode/skills/skill-creator/scripts/init_skill.py <skill-name> --path <output-directory>` - Initialize new skill
- `./.opencode/skills/skill-creator/scripts/package_skill.py <skill-folder> [output-dir]` - Package skill
- `./.opencode/skills/skill-creator/scripts/quick_validate.py <skill-folder>` - Quick single-skill frontmatter check
- `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py` - Mechanical REQ-1/2/3 validation across all skills (sensor only)
- `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py --json` - Mechanical validation with JSON output for programmatic consumption

## Skill Type Taxonomy

| Type | Description | Follow Rigidity | Test Approach |
|------|-------------|-----------------|---------------|
| **Discipline-enforcing** | Rules followed exactly (TDD, debugging) | Follow exactly | Pressure scenarios with combined stresses |
```

### spec-auditor

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 1012 | 464 |
| Task file count | 18 | N/A |
| Task total lines | 1480 | N/A |
| Mandatory language | YES | — |
| Optional language | YES ⚠️ | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: spec-auditor
description: Audits GitHub Issue [SPEC] specs for LLM implementability - fresh-start context, completeness, and content quality. Runs SECOND after concern-separation-auditor.
license: MIT
compatibility: opencode
---

# Persona: Spec Auditor

## Scope: Content Quality for LLM Implementation

**This auditor checks whether an LLM agent with NO memory context can implement the spec correctly.**

**Phase structure, deployment independence, and risk isolation are NOT checked here** — they belong to `concern-separation-auditor` which MUST run FIRST.

### Division of Responsibility

| Auditor | Scope | Role |
|---------|-------|------|
| **concern-separation-auditor** | Phase structure, deployment independence, risk isolation, blast radius, phase names | Runs FIRST - structural safety |
| **spec-auditor** | Fresh-start context, completeness, content quality, LLM implementability | Runs SECOND - content quality |

**CRITICAL: Both auditors are MANDATORY. No skipping.**

**Workflow:**
```
Create spec issue #N →
Invoke concern-separation-auditor --issue N (FIRST - phase structure, auto-fix) →
Invoke spec-auditor --issue N (SECOND - content quality) →
Add needs-approval label →
Post "ready for review" comment
```

## Operating Protocol

**⚠️ MANDATORY AUDIT CHAIN (ALL SKILLS RUN)**

**When ANY request comes for spec/issue/task audit/review/revisit, ALL auditor skills must run in order. NO SKIPPING.**

### Complete Audit Chain

| Order | Skill | Purpose |
|-------|-------|---------|
| **1st** | `concern-separation-auditor` | Phase structure, deployment independence, risk isolation, blast radius, phase names |
| **2nd** | `spec-auditor` | Fresh-start context, completeness, content quality, LLM implementability |

**Trigger words that require ALL skills:**
- "audit this spec"
- "review this issue"
- "revisit this task"
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: spec-auditor
description: Use when auditing a spec for quality, structure, or completeness. Triggers on: audit spec, review spec, spec quality, validate spec, check spec, audit issue, revisit spec, audit plan, audit runbook, audit SOP, audit checklist, audit document, content-aware audit.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: spec-auditor

## Overview

Content-aware audit orchestrator that accepts any document type. Determines document type automatically (or via manual override), selects appropriate subtasks, runs the minimal baseline always, and applies auto-fixes for safe findings while flagging ambiguous findings for review.

**Core v2 shift:** Spec-auditor is now the orchestrator. Plan-fidelity-auditor and concern-separation-auditor are no longer invoked directly — their logic lives as subtasks (`fidelity` and `concerns`) within spec-auditor.

**v3 shift:** Spec-auditor now uses an auto-fix model with three-tier classification instead of the previous report-only approach. Safe findings are fixed directly; ambiguous findings are flagged for developer review.

**v4 shift:** Spec-auditor now supports content-aware auditing. Input can come from issues, files, or URLs. Document type is autodetected and subtask selection is tailored per type. Three new operational subtasks (`operational-flow`, `determinism`, `error-recovery`) support process flows, runbooks, and SOPs.

## Persona

You are a Content-Aware Audit Orchestrator. Your focus is determining document type, selecting appropriate subtasks, auto-fixing safe findings, flagging ambiguous findings for review, and presenting an executive summary of all actions taken.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `fresh-start` | Self-containment checks | ≈400 |
| `structure` | STATUS headers, numbering, markers | ≈400 |
| `content-quality` | Reasoning, ambiguity, conflicts, scope | ≈500 |
| `traceability` | Orphan requirements/features detection | ≈300 |
| `operational` | Logging, metrics, deployment completeness | ≈300 |
| `fidelity` | Clean-room plan comparison | ≈600 |
| `concerns` | Phase structure, deployment independence | ≈400 |
| `operational-flow` | Process flow / runbook operational checks | ≈400 |
| `determinism` | Deterministic behavior and state dependency checks | ≈300 |
| `error-recovery` | Runbook error recovery and rollback checks | ≈350 |
| `principles` | Engineering principle violations from programming-principles skill | ≈350 |
| `ground-truth` | Adversarial verification of metadata claims against direct evidence | ≈500 |
| `sub-issue-fidelity` | Verify sub-issue alignment with Plan phases (delegated from plan-fidelity-auditor) | ≈350 |
| `concern-coverage` | Verify sub-issue concern boundaries match Plan phases (delegated from concern-separation-auditor) | ≈350 |
| `prose-structure` | Anti-prose drift detection — flag rigid structure where prose is expected | ≈250 |
| `decomposition` | Flag specs meeting 2+ of 5 criteria for splitting into independent specs | ≈350 |
| `cross-spec-overlap` | Detect overlap between spec and other open specs/plans via file, symbol, and concern comparison | ≈350 |
| `cross-spec-overlap` | Detect overlap between spec and other open specs/plans | ≈350 |
| `sc-precision` | SC Precision Audit — verify executable verification commands, semantic intent, no vague methods | ≈350 |
| `completion` | Ensure mandatory terminal-state dispatch occurred; remediate if not; report status | ≈200 |

```

### spec-creation

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 663 | 0
0 |
| Task file count | 7 | N/A |
| Task total lines | 648 | N/A |
| Mandatory language | YES | — |
| Optional language | No | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | YES | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
(not available)
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: spec-creation
description: Use when creating a spec or writing a specification. Triggers on: create spec, write spec, spec creation, spec writing, structure spec, specification.
type: technique
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: spec-creation

## Overview

Structured discipline for spec writing — enforcing requirements extraction, problem decomposition, interface-first thinking, constraints ledgers, risk analysis, operational requirements, traceability, and change control at creation time. Invoked after brainstorming completes exploration.

**Pipeline position:** `brainstorming (explore) → spec-creation (structure & write) → spec-auditor (audit) → approval-gate (authorize) → writing-plans (plan)`

**Source:** This skill extracts and extends the spec-writing concerns from `brainstorming` Steps 7-9 (write spec, self-review, user review), adding structured discipline for principles not previously enforced at creation time.

## Persona

You are a Spec Architect. Your focus is structuring investigation results into a complete, well-organized spec with requirements traceability, interface definitions, risk analysis, and change control.

## Tasks

| Task | Purpose | Principles | Skippable? |
|------|---------|------------|------------|
| `requirements` | Extract explicit, implicit, constraints, non-requirements; build constraints ledger | #1, #7 | No — foundation for all other tasks |
| `decompose` | Break into discrete units; define interfaces first (APIs, data contracts, schemas) | #2, #5 | Only for trivial bug fixes with one obvious fix |
| `traceability` | Map requirements to sections, tests, implementation steps | #3 | Only for single-requirement specs |
| `risk` | Analyze risk, blast radius, failure propagation, operational needs | #8, #9 | Only for simple bug fixes with no deployment impact |
| `diagram` | Generate mermaid dependency diagram showing approved structure (no workflow state) | #2, #4 | Only for single-item specs with no dependencies |
| `write` | Assemble spec, create GitHub Issue, output exec summary + URL + byline | #4, #6, #10 | No — mandatory assembly step |
| `change-control` | Version spec, document rationale and impact analysis for changes | #12 | Only for initial spec creation (not revisions) |
| `completion` | Ensure mandatory terminal-state dispatch occurred; remediate if not; report status | — | No — mandatory completion |

## Invocation

- `/skill spec-creation` — Full workflow (requirements → decompose → traceability → risk → write → change-control)
- `/skill spec-creation --task requirements` — Requirements extraction only
- `/skill spec-creation --task write` — Assemble spec from structured outputs only
- `/skill spec-creation --task change-control` — Version/reason a spec revision
- `/skill spec-creation --task completion` — Invoke when workflow halts at any point

## Operating Protocol

**Pre-implementation file changes are ephemeral.** Any modifications to project source files made during this phase are not committed and will likely be silently discarded before the plan is approved for implementation. Only the artifact produced by this skill (the spec, plan, bug report, or issue) persists.

1. **Pre-condition: Code inspection checklist (MANDATORY):**
   Before the `requirements` task, the code inspection checklist in `015-pre-spec-inspection.md` MUST be completed when the spec proposes changes to existing code. This checklist is the concrete minimum standard for the "Spec Without Investigation" critical violation.
```

### sre-runbook

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 661 | 0
0 |
| Task file count | 3 | N/A |
| Task total lines | 810 | N/A |
| Mandatory language | YES | — |
| Optional language | YES ⚠️ | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
(not available)
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: sre-runbook
description: Use when generating operational runbooks for infrastructure incidents or procedures. Triggers on: runbook, SRE, on-call, incident, outage, escalation, playbook, procedure, operation, diagnose, troubleshoot, debug
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: sre-runbook

## Overview

Discipline-enforcing skill that generates **operational runbooks** — step-by-step "do this, in this order" procedures that a sysop can execute without thinking. Every command is verified against live documentation before inclusion. Every value comes from the actual environment, not training data. Every step has ONE definitive path.

**Source Attribution:** Adapted from <UPSTREAM_ORG>/<UPSTREAM_REPO> workflow (branch: newsrx).

## Persona

You are an SRE-oriented operator writing runbooks for sysops under pressure. Your runbooks are **operational procedures, not analysis documents**. A sysop following your runbook copies, pastes, clicks, done — no thinking required, no decisions to make, no explanations to read.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `generate` | Generate an operational runbook — dispatches format based on runbook type | ≈1000 |
| `track` | Track an incident or change via GitHub Issue with structured labels | ≈450 |
| `completion` | Ensure mandatory terminal-state dispatch occurred; remediate if not; report status | ≈200 |

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `generate` | When generating an operational runbook | Runbook type, domain context, environment info, github.owner, github.repo | Implementation context, agent memory | NO |
| `track` | When tracking an incident or change via GitHub Issue | Incident details, labels, github.owner, github.repo | Implementation context, agent memory | NO |
| `completion` | When workflow halts at any point | Workflow state, status | Implementation context, agent memory | NO |

## Invocation

- `/skill sre-runbook` — Overview only
- `/skill sre-runbook --task generate` — Generate an operational runbook
- `/skill sre-runbook --task track` — Track an incident or change via GitHub Issue
- `/skill sre-runbook --task completion` — Invoke when workflow halts at any point

## Operating Protocol

1. **Environment context is MANDATORY.** Before generating ANY instruction, the agent MUST collect: interface preference (GUI vs CLI), installed tools/package managers, OS version, and existing documentation in the repository. Runbooks without environment context are useless.

```

### sync-guidelines

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 160 | 292 |
| Task file count | 5 | N/A |
| Task total lines | 620 | N/A |
| Mandatory language | YES | — |
| Optional language | No | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: sync-guidelines
description: Intelligently synchronize guidelines, skills, and tools between repositories through GitHub issues. Classifies files by semantic analysis and creates sync issues for human review.
license: MIT
compatibility: opencode
---

# Skill: sync-guidelines

## When to Invoke

This skill is triggered when:
- User runs `/skill sync-guidelines`

## Role

You are a Guidelines Sync Manager. Your purpose is to intelligently synchronize guidelines, skills, and tools between repositories through GitHub issues. You classify files by **reading and understanding content**, not by pattern matching.

## Operating Protocol

### Phase 0: Pre-Work Verification

1. Verify on feature branch (not `main`)
2. Check for uncommitted changes (`git status`)
3. Stash if needed

### Phase 1: Discover Files to Sync

1. Detect changed files since last sync
   - Read the **entire file content**
   - Analyze semantically what the file does
   - Determine classification: core or project-specific

### Phase 2: Intelligent Classification

**READ each file and ANALYZE:**

#### Core Indicators (Sync Bidirectionally)

A file is **core** if it:
- Defines generic workflows (git operations, github MCP usage)
- Contains universal engineering standards
- Describes cross-project concepts (approval gates, spec creation, error handling)
- Has NO project-specific imports, paths, or configuration
- Can be dropped into ANY project and work without modification

Examples of core content:
- `## Operating Protocol` - workflow definition
- `git checkout`, `github_issue_write` - generic operations
- `## Critical Requirements` - universal standards
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: sync-guidelines
description: Use when synchronizing guidelines, skills, or tools between repositories. Triggers on: sync guidelines, cross-repo sync, guideline update, skill update, multi-repo, consistency between repos.
type: technique
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: sync-guidelines

## Overview

Intelligently synchronizes guidelines, skills, and tools between repositories through GitHub/GitBucket issues. Files are classified by reading and understanding content — not by pattern matching — to determine what is core (syncable) versus project-specific (protected).

## Tasks

| Task | Purpose | Words |
| -- | -- | -- |
| `classify` | Classify files as core or project-specific | ≈250 |
| `sync-push` | Push core changes to target repository | ≈300 |
| `sync-pull` | Pull core changes into local repository | ≈300 |
| `issue-format` | Template for sync issue content | ≈350 |
| `completion` | Ensure mandatory terminal-state dispatch occurred; remediate if not; report status | ≈200 |

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `classify` | When classifying files as core or project-specific | File paths, project context | Implementation context, agent memory | NO |
| `sync-push` | When pushing core changes to target repository | Source paths, target repository, github.owner, github.repo | Implementation context, agent memory | NO |
| `sync-pull` | When pulling core changes into local repository | Source paths, local repository path | Implementation context, agent memory | NO |
| `issue-format` | When template for sync issue content is needed | Sync type, file paths | Implementation context, agent memory | NO |
| `completion` | When workflow halts at any point | Workflow state, status | Implementation context, agent memory | NO |

## Invocation

- `/skill sync-guidelines` — Overview only
- `/skill sync-guidelines --task classify` — Classify files as core or project-specific
- `/skill sync-guidelines --task sync-push` — Push changes to target repo
- `/skill sync-guidelines --task sync-pull` — Pull changes from source repo
- `/skill sync-guidelines --task issue-format` — Get issue template
- `/skill sync-guidelines --task completion` — Invoke when workflow halts at any point

## Operating Protocol

1. **Issue-based sync:** All sync operations create GitHub/GitBucket issues as proposals. Direct file modification in target repositories is PROHIBITED.
2. **Intelligent classification:** Every file MUST be read and analyzed before classification. Pattern-based classification (filename, number ranges) is FORBIDDEN.
```

### systematic-debugging

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 360 | 216 |
| Task file count | 3 | N/A |
| Task total lines | 282 | N/A |
| Mandatory language | YES | — |
| Optional language | No | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: systematic-debugging
description: Systematic bug diagnosis and fix process that ensures root cause analysis before any code changes.
license: MIT
compatibility: opencode
---

# Skill: systematic-debugging

## Overview

Systematic debugging process that enforces root cause analysis, hypothesis testing, and minimal fixes. This skill prevents "vibe debugging" — making random changes without understanding the problem. All bugs must be diagnosed before fixing, and fixes must be minimal and targeted.

**Source Attribution:** This skill is adapted from NewsRx/opencode-gitbucket-superpowers workflow (branch: newsrx).

## Persona

You are a Debugging Detective. Your focus is finding the true root cause before writing any fix code.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `diagnose` | Systematic bug diagnosis workflow | ~800 |
| `fix` | Minimal targeted fix after diagnosis | ~500 |

## Invocation

- `/skill systematic-debugging` - Overview only
- `/skill systematic-debugging --task diagnose` - Diagnose a bug
- `/skill systematic-debugging --task fix` - Apply minimal fix

## Operating Protocol

1. **Automatic invocation (mandatory):** This skill is auto-invoked by dispatch-table.yaml when:
   - Agent encounters a bug or error during implementation
   - User reports a bug or error
   - User says "fix this" or "debug this"
   - DO NOT start fixing until diagnosis is complete

2. **Diagnosis-first approach:**
   - All bugs require diagnosis before fix
   - Diagnosis must identify root cause
   - Fix must target root cause, not symptoms
   - Fix must be minimal — no scope creep

3. **Exit conditions:** Debugging is COMPLETE when:
   - Root cause identified and documented
   - Fix applied targeting root cause only
   - Verification confirms fix resolves issue
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: systematic-debugging
description: Use when encountering a bug, error, or unexpected behavior, or before making code changes to fix an issue. Triggers on: bug, error, fix, debug, diagnose, crash, failure, unexpected behavior, vibe debugging.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: systematic-debugging

## Overview

Systematic debugging process that enforces root cause analysis, hypothesis testing, and minimal fixes. Prevents "vibe debugging" — making random changes without understanding the problem. All bugs must be diagnosed before fixing, and fixes must be minimal and targeted.

**Source Attribution:** This skill is adapted from <UPSTREAM_ORG>/<UPSTREAM_REPO> workflow (branch: newsrx).

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `diagnose` | Systematic bug diagnosis workflow | ≈400 |
| `fix` | Minimal targeted fix after diagnosis | ≈350 |
| `completion` | Ensure mandatory terminal-state dispatch occurred; remediate if not; report status | ≈200 |

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `diagnose` | When systematic bug diagnosis is needed | Bug description, file paths, github.owner, github.repo | Implementation context, agent memory, fix decisions | NO |
| `fix` | When minimal targeted fix after diagnosis is needed | Bug description, diagnosis results, file paths | Implementation context, agent memory | NO |
| `completion` | When workflow halts at any point | Workflow state, status | Implementation context, agent memory | NO |

## Invocation

- `/skill systematic-debugging` — Overview only
- `/skill systematic-debugging --task diagnose` — Diagnose a bug
- `/skill systematic-debugging --task fix` — Apply minimal fix
- `/skill systematic-debugging --task completion` — Invoke when workflow halts at any point

## Operating Protocol

1. **Diagnosis-first approach:** All bugs require diagnosis before fix. Diagnosis must identify root cause. Fix must target root cause, not symptoms. Fix must be minimal — no scope creep.
2. **Mandatory invocation:** The agent MUST invoke this skill when a bug or error is encountered during implementation, or when user reports a bug or says "fix this" or "debug this."
3. **Exit conditions:** Debugging is COMPLETE when root cause identified and documented, fix applied targeting root cause only, verification confirms fix resolves issue, and no new issues introduced.
4. **Authorization separation:** Bug diagnosis does NOT require approval (read-only). Bug FIX requires approval (code change). See `approval-gate` skill for authorization workflow.
5. **Self-correction:** If the agent catches itself editing code without an approved spec, immediately `git checkout -- <affected-files>` and HALT.

```

### test-driven-development

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 175 | 217 |
| Task file count | 3 | N/A |
| Task total lines | 303 | N/A |
| Mandatory language | YES | — |
| Optional language | YES ⚠️ | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: test-driven-development
description: Test-driven development workflow writing tests before implementation to ensure correctness and prevent regression.
license: MIT
compatibility: opencode
---

# Skill: test-driven-development

## Overview

Test-driven development (TDD) workflow that enforces writing tests before implementation code. Tests define the contract, implementation satisfies the contract, and refactoring maintains quality. This is an optional quality gate skill invoked contextually when the development approach benefits from TDD.

**Source Attribution:** This skill is adapted from NewsRx/opencode-gitbucket-superpowers workflow (branch: newsrx).

## Persona

You are a Test-First Developer. Your focus is defining expected behavior through tests before writing implementation.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `red` | Write failing test for new behavior | ~600 |
| `green` | Write minimal implementation to pass test | ~500 |
| `refactor` | Clean up while keeping tests green | ~400 |

## Invocation

- `/skill test-driven-development` - Overview only
- `/skill test-driven-development --task red` - Write failing test
- `/skill test-driven-development --task green` - Write minimal implementation
- `/skill test-driven-development --task refactor` - Refactor with tests green

## Operating Protocol

1. **Contextual invocation:** This skill is invoked when:
   - User explicitly requests TDD approach
   - Spec has clear testable behavior
   - Development involves new functions/classes with well-defined contracts
   - NOT mandatory — use when TDD adds value

2. **Red-Green-Refactor cycle:**
   - RED: Write a test that fails (defines expected behavior)
   - GREEN: Write minimal code to make test pass (satisfy contract)
   - REFACTOR: Clean up code while keeping tests green

3. **Exit conditions:** TDD cycle is COMPLETE when:
   - Test was written before implementation
   - Implementation passes the test
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: test-driven-development
description: Use when writing tests before implementation, or when adopting a test-first development approach. Triggers on: TDD, test first, red green refactor, write test, test-driven, unit test, regression.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: test-driven-development

## Overview

Test-driven development (TDD) workflow that enforces writing tests before implementation code. Tests define the contract, implementation satisfies the contract, and refactoring maintains quality.

**MANDATORY: The agent MUST invoke `test-driven-development --task red` before implementation for all code changes (exempt: docs-only, config-only, data-only changes). Skipping this invocation is a CRITICAL GUIDELINE VIOLATION per `000-critical-rules.md` §Skipping Mandatory Skill Invocation.**

**Source Attribution:** This skill is adapted from <UPSTREAM_ORG>/<UPSTREAM_REPO> workflow (branch: newsrx).

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `red` | Write failing test for new behavior | ≈200 |
| `green` | Write minimal implementation to pass test | ≈150 |
| `refactor` | Clean up while keeping tests green | ≈200 |

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `red` | When writing failing test for new behavior | Spec SC list, test file paths | Implementation context, implementation intent | NO |
| `green` | When writing minimal implementation to pass test | Spec SC list, test file paths, implementation file paths | Prior RED test output, implementation intent | NO |
| `refactor` | When cleaning up code while keeping tests green | Implementation file paths, test file paths | Implementation context, agent memory | NO |

## Invocation

- `/skill test-driven-development` — Overview only
- `/skill test-driven-development --task red` — Write failing test
- `/skill test-driven-development --task green` — Write minimal implementation
- `/skill test-driven-development --task refactor` — Refactor with tests green

## Operating Protocol

1. **MANDATORY invocation:** This skill MUST be invoked for ALL code changes. The agent MUST NOT treat TDD as optional or contextual. Invoke `/skill test-driven-development --task red` before writing any implementation code. Exempt: documentation-only, configuration-only, or data-only changes.
2. **Red-Green-Refactor cycle:** RED: Write a test that fails (defines expected behavior). GREEN: Write minimal code to make test pass (satisfy contract). REFACTOR: Clean up code while keeping tests green.
3. **Exit conditions:** TDD cycle is COMPLETE when test was written before implementation, implementation passes the test, code is refactored and clean, and all existing tests still pass.

```

### ui-design

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 221 | 0
0 |
| Task file count | 7 | N/A |
| Task total lines | 200 | N/A |
| Mandatory language | YES | — |
| Optional language | No | — |
| Verification steps | YES | — |
| Cross-references | No ⚠️ | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
(not available)
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: ui-design
description: Use when designing UI wireframes, mockups, interaction specs, or visual artifacts. Triggers on: ui design, wireframe, mockup, interaction spec, visual layout, UI mock, screenshot capture, sidebar navigation, page layout.
type: technique
license: MIT
provenance: AI-generated
compatibility: opencode
---

# UI Design Skill

## Overview

The `ui-design` skill produces toolkit-agnostic design artifacts (wireframes, mockups, interaction specs) that can be consumed by any implementation skill or sub-agent. It operates as a sub-agent dispatched by `divide-and-conquer` or invoked directly via `/skill ui-design`.

**Model assignment:** `kimi-k2.6:cloud`

All design output is framework-neutral. The skill does NOT embed Streamlit, web, Android, Godot, Flutter, or any other framework-specific concepts into its artifacts. Framework binding is the responsibility of `ui-engineer`, not `ui-design`.

## Persona

**UI Design Specialist** — produces clear, implementable design artifacts that separate visual structure from framework implementation. Focuses on information architecture, component relationships, navigation flow, and accessibility requirements.

## Sub-Agent Tasks

| Task | Word Count | Description |
|------|-----------|-------------|
| `design` | ≈800 | Full UI design pass: layout, components, navigation, accessibility |
| `wireframe` | ≈400 | Low-fidelity wireframe from template |
| `mockup` | ≈400 | High-fidelity mockup from template |
| `interaction-spec` | ≈500 | YAML interaction specification from schema |
| `screenshot` | ≈300 | Capture screenshot of rendered artifact |
| `review` | ≈400 | Review design artifact against spec requirements |
| `completion` | ≈200 | Idempotent cleanup and final summary |

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `design` | When full UI design pass is needed | Spec requirements, design context, github.owner, github.repo | Implementation context, agent memory | NO |
| `wireframe` | When low-fidelity wireframe is needed | Design context, template reference | Implementation context, agent memory | NO |
| `mockup` | When high-fidelity mockup is needed | Design context, template reference, wireframe output | Implementation context, agent memory | NO |
| `interaction-spec` | When YAML interaction specification is needed | Design context, interaction requirements | Implementation context, agent memory | NO |
| `screenshot` | When screenshot capture of rendered artifact is needed | Artifact path, capture context | Implementation context, agent memory | NO |
| `review` | When design review against spec is needed | Design artifact, spec requirements, github.owner, github.repo | Implementation context, agent memory | NO |
| `completion` | When workflow halts at any point | Workflow state, status | Implementation context, agent memory | NO |

Result contracts (returned by each sub-agent):

```yaml
```

### ui-engineer

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 209 | 0
0 |
| Task file count | 5 | N/A |
| Task total lines | 216 | N/A |
| Mandatory language | YES | — |
| Optional language | No | — |
| Verification steps | YES | — |
| Cross-references | No ⚠️ | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
(not available)
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: ui-engineer
description: Use when implementing UI from design artifacts, producing framework-specific code. Triggers on: implement UI, UI implementation, UI code, frontend code, Streamlit component, framework implementation, build page, create view.
type: technique
license: MIT
provenance: AI-generated
compatibility: opencode
---

# UI Engineer Skill

## Overview

The `ui-engineer` skill consumes toolkit-agnostic design artifacts produced by `ui-design` and translates them into framework-specific implementations. It operates as a sub-agent dispatched by `divide-and-conquer` or invoked directly via `/skill ui-engineer`.

**Model assignment:** `glm-5.1:cloud`

All implementation output is framework-specific (currently Streamlit). The skill binds design artifacts — interaction specs, wireframes, mockups — to concrete UI code, templates, and test specifications.

## Persona

**UI Implementation Engineer** — translates design artifacts into production-quality framework-specific code. Focuses on component mapping, accessibility implementation, state management, and testable UI structure.

## Sub-Agent Tasks

| Task | Word Count | Description |
|------|-----------|-------------|
| `implement` | ≈800 | Full UI implementation pass: component mapping, code generation, framework binding |
| `validate-impl` | ≈400 | Validate implementation against interaction-spec requirements |
| `test-ui` | ≈400 | Generate UI test specifications from interaction specs |
| `framework-config` | ≈500 | Configure target framework, component library, and project conventions |
| `completion` | ≈200 | Idempotent cleanup and final summary |

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `implement` | When full UI implementation pass is needed | Spec requirements, design artifacts, worktree.path, github.owner, github.repo | Implementation context, agent memory, other agents' results | NO |
| `validate-impl` | When validating implementation against interaction-spec | Implementation files, interaction spec, github.owner, github.repo | Implementation context, agent memory | NO |
| `test-ui` | When generating UI test specifications | Interaction spec, implementation files | Implementation context, agent memory | NO |
| `framework-config` | When configuring target framework | Framework name, component library, project conventions | Implementation context, agent memory | NO |
| `completion` | When workflow halts at any point | Workflow state, status | Implementation context, agent memory | NO |

Result contracts (returned by each sub-agent):

```yaml
implement:
  status: DONE | DONE_WITH_CONCERNS | OVERFLOW | BLOCKED
  files_changed: [list of paths relative to worktree]
  summary: string
```

### using-git-worktrees

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 220 | 0
0 |
| Task file count | 4 | N/A |
| Task total lines | 345 | N/A |
| Mandatory language | YES | — |
| Optional language | YES ⚠️ | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
(not available)
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: using-git-worktrees
description: Use when creating a feature branch or worktree for implementation. Always invoke before git-workflow pre-work. Triggers on: branch, worktree, feature branch, create worktree, pre-work, worktree.path.
type: discipline-enforcing
license: MIT
provenance: AI-generated
---

# Skill: using-git-worktrees

## Overview

Git worktrees create isolated workspaces sharing the same repository, allowing work on multiple branches simultaneously without switching. This skill adapts the [obra/superpowers using-git-worktrees](https://github.com/obra/superpowers/blob/main/skills/using-git-worktrees/SKILL.md) pattern for the `feature→dev→main` three-branch workflow used in this project.

**Core principle:** Systematic directory selection + safety verification = reliable isolation for parallel agent work.

**⚠️ Worktrees are OPT-IN, not mandatory.** The default workflow is direct-branch (feature branch in main repo). Worktrees are only created when `WORKTREE_REQUIRED` is set or the developer explicitly requests isolation. See `000-critical-rules.md` → "Direct-Branch Default" for the primary workflow.

**Announce at start:** "Using the using-git-worktrees skill to set up an isolated workspace."

**Source attribution:** Adapted from [obra/superpowers `using-git-worktrees`](https://github.com/obra/superpowers/tree/main/skills/using-git-worktrees). Original concepts and structure used with attribution.

## Persona

You are a Worktree Setup Specialist. Your focus is creating safe, isolated git worktrees so agents can work in parallel without conflict.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `create-worktree` | Full worktree creation workflow: sync, verify, setup, export env | ≈600 |
| `tool-usage` | File operation and bash tool compliance rules for worktrees | ≈250 |
| `reference` | Quick reference, common mistakes, fatal errors, integration | ≈450 |
| `completion` | Ensure mandatory terminal-state dispatch occurred; remediate if not; report status | ≈200 |

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `create-worktree` | When worktree creation is needed before implementation | Branch name, worktree.path, github.owner, github.repo | Implementation context, agent memory, cached verification | NO |
| `tool-usage` | When file operation compliance rules are needed | Worktree.path, file operation context | Implementation context, agent memory | NO |
| `reference` | When quick reference for worktree operations is needed | Worktree.path, branch name | Implementation context, agent memory | NO |
| `completion` | When workflow halts at any point | Workflow state, status | Implementation context, agent memory | NO |

## Invocation

- `/skill using-git-worktrees` — Overview only (this document)
- `/skill using-git-worktrees --task create-worktree` — Create a new worktree
```

### verification

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 104 | 0
0 |
| Task file count | 3 | N/A |
| Task total lines | 318 | N/A |
| Mandatory language | YES | — |
| Optional language | YES ⚠️ | — |
| Verification steps | YES | — |
| Cross-references | No ⚠️ | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
(not available)
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: verification
description: Use when verifying claims against evidence using appropriate modalities. Produces PASS/FAIL/UNVERIFIED per claim with evidence artifacts. Triggers on: verify claim, claim verification, evidence verification, verify against source, multimodal verification.
type: verification
license: Apache-2.0
provenance: AI-generated
compatibility: opencode
---

# Verification

## Overview

Verification skill that invokes `multimodal-dispatch` to verify claims against evidence using appropriate modalities. Each claim receives a PASS/FAIL/UNVERIFIED status with supporting evidence artifacts. The dispatcher routes claims to the best available model based on content modality (text, vision, etc.).

**Core invariant (per 065-verification-honesty.md):** FAIL is NEVER downgraded to PASS based on agent judgment. If a claim verification results in FAIL, it remains FAIL. The only valid state transitions are UNVERIFIED → PASS (after re-verification with evidence) or UNVERIFIED → FAIL (after re-verification with contradictory evidence). FAIL cannot become PASS without new evidence that contradicts the original failure.

**Relationship to verification-enforcement:** This skill handles modality-aware claim verification. The existing `verification-enforcement` skill handles the pre-generation verification gate. When modality-aware verification is needed (e.g., verifying image claims, verifying against non-text sources), `verification-enforcement` can optionally route through this skill via `multimodal-dispatch`.

## Persona

You are a Claim Verifier. Your focus is verifying each claim against evidence using the appropriate model and modality, producing PASS/FAIL/UNVERIFIED results with evidence artifacts. You never downgrade FAIL to PASS.

## ClaimResult Schema

Each claim verification produces a `ClaimResult`:

```json
{
  "claim_id": "C1",
  "status": "PASS | FAIL | UNVERIFIED",
  "evidence": "Verified against...",
  "evidence_artifacts": ["tool_call_ref"],
  "model_used": "<model-tag>",
  "modality": "text | vision | embedding | audio"
}
```

**Status semantics:**

| Status | Meaning |
|--------|---------|
| PASS | Claim verified against evidence |
| FAIL | Claim contradicted by evidence |
| UNVERIFIED | No model available for required modality, or evidence inconclusive |

**FAIL is never downgraded to PASS.** This is a strict invariant per 065-verification-honesty.md. If the verifying model returns that a claim fails verification, the result is FAIL — not "close enough" or "functionally equivalent."

## Tasks

```

### verification-before-completion

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 562 | 296 |
| Task file count | 4 | N/A |
| Task total lines | 650 | N/A |
| Mandatory language | YES | — |
| Optional language | No | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: verification-before-completion
description: Evidence-based verification workflow that prevents premature completion claims by ensuring success criteria have actual evidence.
license: MIT
compatibility: opencode
---

# Skill: verification-before-completion

## Overview

Evidence-based verification workflow that prevents premature completion claims. This skill ensures ALL success criteria are verified with actual evidence before ANY task or phase is marked complete. It is adapted from the NewsRx/opencode-gitbucket-superpowers workflow.

**Source Attribution:** This skill is adapted from NewsRx/opencode-gitbucket-superpowers workflow (branch: newsrx).

## Persona

You are a Verification Gatekeeper. Your focus is ensuring NO completion claim without verified evidence.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `verify` | Verify all success criteria have evidence | ~800 |
| `collect` | Collect evidence for incomplete criteria | ~700 |

## Invocation

- `/skill verification-before-completion` - Overview only
- `/skill verification-before-completion --task verify` - Verify completion readiness
- `/skill verification-before-completion --task collect` - Collect missing evidence

## Operating Protocol

1. **Automatic invocation (mandatory):** This skill is auto-invoked by dispatch-table.yaml when:
   - Agent claims "task complete" or "step complete"
   - Agent marks step as ☑ in plan
   - Agent attempts to close issue or create PR
   - DO NOT allow completion claims without evidence

2. **Evidence Requirements:**
   - Every success criterion must have evidence
   - Evidence must be verifiable (logs, test outputs, screenshots)
   - Evidence must be posted to issue or in `./tmp/`
   - No placeholders or "trust me" claims

3. **Exit conditions:** Verification is COMPLETE when:
   - All success criteria have evidence
   - Evidence is posted to plan issue or stored in `./tmp/`
   - HALT and report verification results
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: verification-before-completion
description: Use when claiming a task is complete, marking a step done, or closing an issue. Triggers on: task complete, done, finished, step complete, mark done, verify completion, success criteria.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: verification-before-completion

## Overview

Evidence-based verification workflow that prevents premature completion claims. This skill ensures ALL success criteria are verified with actual evidence before ANY task or phase is marked complete.

**Source Attribution:** Adapted from <UPSTREAM_ORG>/<UPSTREAM_REPO> workflow (branch: newsrx).

## Persona

You are a Verification Gatekeeper. Your focus is ensuring NO completion claim without verified evidence.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `verify` | Verify all success criteria have evidence | ≈700 |
| `collect` | Collect evidence for incomplete criteria | ≈500 |
| `completion` | Ensure mandatory completion steps run regardless of workflow outcome | ≈150 |
| `structural-verify` | Verify structural components against spec | ≈500 |

## Sub-Agent Tasks

| Task | Words |
|------|-------|
| `verify` | ≈700 |
| `collect` | ≈500 |
| `completion` | ≈150 |
| `structural-verify` | ≈500 |

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `verify` | When verifying completion readiness before marking done | Spec SC list, file paths, github.owner, github.repo | Implementation context, prior verification results, agent memory | NO |
| `collect` | When collecting missing evidence for verification | Missing SC list, github.owner, github.repo | Implementation context, agent memory | NO |
| `structural-verify` | When verifying structural completeness of implementation against spec | Spec SC list, implementation file paths, worktree.path | Implementation context, prior verification results, agent memory | NO |
| `completion` | When workflow halts at any point | Workflow state, verification results | Implementation context, agent memory | NO |

## Invocation

```

### verification-enforcement

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 345 | 0
0 |
| Task file count | 4 | N/A |
| Task total lines | 162 | N/A |
| Mandatory language | YES | — |
| Optional language | YES ⚠️ | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | No ⚠️ | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
(not available)
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: verification-enforcement
description: Use when generating content that makes factual claims — specs, plans, runbooks, docs, or correspondence — to enforce live-source verification before generation. Triggers on: verify before generation, content generation, evidence collection, unverified claims, verification gate, prose structure check.
type: discipline-enforcing
license: Apache-2.0
provenance: AI-generated
compatibility: opencode
---

# Verification Enforcement

## Overview

Every content-generating skill must pass through a verification gate before producing output. This skill provides that shared gate: a mandatory pre-generation check that collects evidence artifacts for every factual claim the agent intends to make, and a mandatory post-generation pass that resolves any claims that could not be verified during generation. The gate prevents agents from writing content based on memory, training data, or unverified assumptions. When claims cannot be verified against live sources, they are marked as unverified and must either be resolved in a revisit pass or escalated to the developer.

The verification lifecycle flows naturally through three stages. Before generation, the agent declares what it intends to claim and dispatches sub-agents to collect evidence for each content section. After generation, the agent scans for any remaining unverified markers and attempts resolution a second time. At the orchestrator level, the enforce task checks that sub-agents have returned evidence artifacts with their content — output without evidence is rejected and re-dispatched.

## Persona

You are the Verification Gatekeeper. Your job is to ensure that no content ships without evidence backing every factual claim. You are not the content author — you are the evidence collector who runs before and after the author. You treat memory and training data as insufficient sources. You treat tool calls and live documentation as sufficient sources. You mark what you cannot verify and escalate what you cannot resolve.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `verify` | Pre-generation verification gate — dispatch section-based sub-agents to collect evidence artifacts | ≈300 |
| `revisit` | Post-generation verification pass — scan for unverified markers and attempt resolution | ≈250 |
| `enforce` | Orchestrator evidence gate — verify sub-agent output includes evidence artifacts | ≈200 |
| `completion` | Completion guarantee — document results, produce status report | ≈150 |

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `verify` | When pre-generation verification gate is needed before content generation | Section evidence table, claim list, github.owner, github.repo | Implementation context, agent memory, prior verification results | NO |
| `revisit` | When post-generation verification pass is needed after content generation | Generated content, ⚠️ UNVERIFIED markers | Implementation context, agent memory | NO |
| `enforce` | When orchestrator evidence gate verification is needed | Sub-agent output, evidence artifact list | Implementation context, agent memory | NO |
| `completion` | When workflow halts at any point | Workflow state, status | Implementation context, agent memory | NO |

## Invocation

- `/skill verification-enforcement --task verify` — Run pre-generation verification gate before content generation
- `/skill verification-enforcement --task revisit` — Run post-generation verification pass after content generation
- `/skill verification-enforcement --task enforce` — Verify sub-agent output includes evidence artifacts
- `/skill verification-enforcement --task completion` — Document verification results and produce status report
- `/skill verification-enforcement` — Overview only

Content-generating skills invoke `verify` before their generation step and `revisit` after their self-review step. The `enforce` task is used by orchestrators (such as `divide-and-conquer`) to validate sub-agent outputs. The `completion` task runs at the end of any verification-enforcement workflow to document results.
```

### writing-plans

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md exists | YES | YES |
| SKILL.md lines | 750 | 285 |
| Task file count | 7 | N/A |
| Task total lines | 471 | N/A |
| Mandatory language | YES | — |
| Optional language | No | — |
| Verification steps | YES | — |
| Cross-references | YES | — |
| Mermaid diagrams | YES | — |
| Platform-agnostic | YES ⚠️ | — |
| Duplication risk | Unlikely | — |

#### Baseline SKILL.md Content (first 50 lines)
```
---
name: writing-plans
description: Plan creation workflow that transforms approved specs into structured, actionable implementation plans with completeness validation.
license: MIT
compatibility: opencode
---

# Skill: writing-plans

## Overview

Plan creation workflow that transforms approved specs into structured, actionable implementation plans. This skill ensures plans are complete, placeholder-free, and ready for execution. It is adapted from the NewsRx/opencode-gitbucket-superpowers workflow.

**Source Attribution:** This skill is adapted from NewsRx/opencode-gitbucket-superpowers workflow (branch: newsrx).

## Persona

You are an Implementation Planner. Your focus is transforming approved design specs into complete, actionable implementation plans with clear steps, testability, and verification evidence.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `create` | Create plan from approved spec | ~1000 |
| `validate` | Check for placeholders and completeness | ~600 |
| `retroactive` | Create plan for existing spec | ~800 |

## Invocation

- `/skill writing-plans` - Overview only
- `/skill writing-plans --task create` - Create plan from current spec
- `/skill writing-plans --task validate` - Validate existing plan
- `/skill writing-plans --task retroactive` - Create plan for existing spec

## Operating Protocol

1. **Automatic invocation (mandatory):** This skill is auto-invoked by dispatch-table.yaml when:
   - Spec receives explicit approval (`approved` or `go`)
   - User asks about plan creation workflow
   - After approval-gate verifies authorization
   - DO NOT proceed to implementation until plan is approved

2. **Plan Structure Requirements:**
   - Plans stored as GitBucket issues
   - Each plan linked to its parent spec via sub-issues
   - Plans contain ONLY implementation steps (no investigation/planning phases)
   - Plans are COMPLETE with no TBD/TODO placeholders

3. **Exit conditions:** Plan creation is COMPLETE when:
   - Plan created as GitBucket issue
```

#### Current SKILL.md Content (first 50 lines)
```
---
name: writing-plans
description: Use when creating an implementation plan from an approved spec. Triggers on: write plan, create plan, implementation plan, plan spec, approved plan, plan creation.
type: technique
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: writing-plans

## Overview

Plan creation workflow that transforms approved specs into actionable implementation plans using a hybrid structure: **phases** for sub-issue tracking and cross-phase visibility, **TDD steps** within each task for granular execution guidance. Every step is one action (2-5 minutes) with exact code and commands. Placeholders are forbidden in plans.

**Source attribution:** TDD step granularity, no-placeholders rule, plan document header, file structure section, and self-review checklist adapted from [obra/superpowers `writing-plans`](https://github.com/obra/superpowers/blob/main/skills/writing-plans/SKILL.md).

## Plan Issue Model

Plans are either separate GitHub Issues or combined into the spec issue body, depending on agent intelligence evaluation of spec complexity. The hierarchy is:

**Separate plan (multi-task or agent-determined):**

```
Spec #N (approved)
  → [PLAN] #M (linked reference via body text "Spec: #N")
       ├── Task #P1: [Task: #M] Phase 1
       ├── Task #P2: [Task: #M] Phase 2
       └── Task #P3: [Task: #M] Phase 3
```

**Combined spec+plan (single-task, agent-determined):**

```
Spec #N (approved)
  → Body contains spec content
       └── ## Implementation Plan (appended section with header, file structure, TDD tasks)
```

**Plan issue properties (separate):**
- Title prefix: `[PLAN]`
- Labels: `plan` + `needs-approval`
- Body contains spec reference as prose (e.g., `Spec: #784`)
- Sub-issues are children of the plan, NOT the spec
- The plan references the spec via body text (linked reference), not via GitHub sub-issue link

**Combined spec+plan properties:**
- Title prefix: `[SPEC]` (retained, not changed to `[PLAN]`)
- Labels: existing spec labels (no `plan` label added)
- Plan content appended under `## Implementation Plan` heading in spec body
```


## Skill Count

Current skills: 41
Baseline skills: 30
