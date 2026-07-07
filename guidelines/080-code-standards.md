---
trigger_on: code standard, attribution, co-authored, byline, enforcement test, behavioral test, hardcoded identity
tier: 1
load_when: sub-agent
---

# Code Standards

## Scope

These standards apply to **ALL code artifacts**: Python modules, Jupyter notebooks, LaTeX/XeLaTeX documents, configuration files, scripts, and any other code written or modified in this repository. No exceptions.

## Typing

- Explicit type hints (Pydantic/Dataclasses) project-wide. Avoid `Any`; use concrete types wherever possible. This is the project standard — type hints make code self-documenting and catch errors at definition time.
  `Any` is acceptable only when imposed by third-party signatures.
- Use Python 3.12+ built-in types (`list[str]`, `dict[str, Any]`), not `typing.List`/`Dict`.
- **Strict Enum Mapping**: DB-stored enums use plain string values (`NEW_DISCOVERY = "new_discovery"`).
  Emojis/presentation strings handled as properties or mapping functions, never stored in DB.
- **Parsing Logic Changes**: Changes to `src/commons/parsing/` affecting extracted metadata require a full pipeline
  rerun from Step 100 (`0100_ingest_xml.ipynb`) — performed by the user, not the agent. A change **affects extracted
  metadata** if it alters the values, presence, or format of any field written to the database or output files. Agent
  MUST NOT write DB remediation, backfill, or migration code to compensate for parsing changes; the pipeline rerun
  handles data consistency. Flag the rerun requirement to the user after making such changes. Redundant "safety-net"
  updates in downstream notebooks prohibited.

## Design Principles

> **For design principles (KISS, DRY, SRP, SoC, cohesion, YAGNI, Fail Fast, Defensive Programming, and all 20 programming principles), see the `programming-principles` skill.** That skill is the single authoritative source for both enforcement rules and design judgment (apply strongly when / relax when). This guideline retains only project-specific conventions below.

The following project-specific code structure rules are enforced in this repository:

- **Non-Monolithic**: Break large blocks into cohesive, independent components. Notebooks should have focused cells — cells that do "one thing."
- **Single Function Methods**: Every function/method performs exactly ONE task. If a function has multiple responsibilities, split it. Decompose ALL tasks, plans, and algorithms into discrete single-function methods. This applies to:
  - Python functions in `.py` files
  - Notebook cells (each cell should do ONE thing)
  - LaTeX/XeLaTeX environments and macros (one purpose each)
  - Scripts and configuration files
- **No Monoliths**: Long procedural blocks are prohibited. If a function exceeds 40 lines, decompose it. If a notebook cell exceeds 50 lines, split it into multiple cells.
- **No Magic Strings or Numbers**: All literal strings and numbers that carry domain meaning must be extracted to named constants (`UPPER_SNAKE_CASE` at module level, or class-level `ClassVar`) before use. Inline literals are only acceptable for truly universal values (e.g., `0`, `1`, `""`, `True`, `False`, HTTP status `200`).
- **No Re-exports**: Imports must reference concrete module paths — IDE navigation depends on it. This is the project standard.
  - NEVER add `from X import Y` or `__all__` to `__init__.py` files.
  - `__init__.py` must contain ONLY a module docstring describing the package purpose.
  - All imports must reference concrete module paths (e.g., `from commons.mesh.validator import MeshValidator`, NOT `from commons.mesh import MeshValidator`).
  - Rationale: Re-exports break IDE "Find Usages" and "Go to Definition" by creating false source locations.
  - Existing `__all__` entries in legacy files are assumed approved — do not remove them without explicit instruction.
  - When creating a NEW `__init__.py`, it must be docstring-only. When editing an existing `__init__.py`, do not add any imports or `__all__` entries.
- **Top-Level Documentation**: Every Python source file must include a brief top-level comment identifying the package's or class's purpose. Use a module docstring (preferred) or a leading `#` comment. Keep it to one or two concise sentences — enough for `.opencode/tools/py ls` to display alongside the filename.
- **Docstring/Comment Determinism**: Pydoc/docstrings and code comments must use deterministic wording. Avoid ambiguous hedge/alternative phrasing such as `maybe`, `if ... or ...`, `and/or`, or `A + B or C` when describing required behavior, validation paths, or implementation intent.
- **Labels Over Index Numbers**: When editing structured artifacts (notebooks, migration lists, cell arrays, ordered configs), add and use stable labels/names so that inserts, deletes, and moves which change index numbers do not cause edit failures. Reference items by label, not by positional index.

## Modern Python

- **Pathlib**: `pathlib.Path` exclusively for file/dir ops. No `os.path.join`, `os.mkdir`, string concatenation. Use `/`
  operator.
- **f-strings**: For all string interpolation. No `.format()` or `%` unless required by external libs.
- **Metadata Integrity**: Use `shutil.copy2` (not `shutil.copy`). Never discard metadata unless explicitly instructed.

## Libraries & Packages

- Use NLP packages (e.g., NLTK) for NLP tasks — no regex for NLP. NLP tasks include tokenization, stemming,
  lemmatization, part-of-speech tagging, named entity recognition, and sentence segmentation. Simple pattern matching
  or fixed-format extraction does not qualify and may use regex. For tasks requiring complex pattern logic beyond
  simple fixed-format extraction, prefer FSM or LALR-type grammars (e.g., `lark`, `pyparsing`) over regex — regex is
  brittle on live data.
- All DB/system ops use existing project libraries. Direct data file manipulation prohibited unless instructed.
- Use `ConfigurationManager` for all data file paths — never hardcode or assume data file locations.
  `project-config.ini` is located at project root; initialize `ConfigurationManager` with the project root path (
  resolved via root resolution per `210-scripting.md`).

## Print Statements & Output

- **NO narration/signal prints**: Never add print statements that narrate code changes, signal feature updates, or announce implementation details. Print statements are for data output and user-facing information only.
- **NO pedantic notes in code**: Lines like `print("Note: X now uses Y")` or `print("Feature Z implemented")` are prohibited. Code should speak for itself through documentation and version control.
- **Valid print uses**: Progress bars, data summaries, error messages, user-facing status, diagnostic output during development/testing.
- **Invalid print uses**: Announcing "implementation complete", narrating changes, signaling "now using X", helpful hints, tutorial-style output, any form of self-documentation via print.
- **Examples of prohibited prints**:
  - `print("Note: Visualizations now use dark mode")`
  - `print("Feature X enabled")`
  - `print("Using new algorithm for Y")`
  - `print("Implementation complete - phase 1")`
- **If context is needed**: Add a docstring, code comment, or update documentation — never a print statement.

## Linting & Static Analysis

- Run appropriate dev tools (linters, type checkers) listed in `.opencode/AGENTS.md` "Build / Lint / Test Commands" on all modified Python files before submitting.

## Tool Selection by File Type

### 🚫 PROHIBITED Misuse

**DO NOT run Python tools on non-Python files:**

| Tool | Python Files | Markdown Files |
| -- | -- | -- |
| `ruff` | ✅ REQUIRED | 🚫 PROHIBITED |
| `pyright` | ✅ REQUIRED | 🚫 PROHIBITED |
| `vulture` | ✅ OPTIONAL | 🚫 PROHIBITED |
| `pymarkdownlnt` | 🚫 PROHIBITED | ✅ REQUIRED |
| `mdformat` | 🚫 PROHIBITED | ✅ REQUIRED |

Running `ruff check` or `ruff format` on `.md` files is prohibited — Python tools are designed for Python syntax and produce incorrect results on markdown files. Use markdown-specific tools (`pymarkdownlnt`, `mdformat`) instead.

### Correct Tool Usage

**Python files (`.py`):**

```bash
uvx ruff check src/ test/              # Lint (advisory)
uvx ruff format --check src/ test/     # Format check (advisory)
uvx pyright src/                       # Type check
uvx vulture src/                       # Dead code scan
```

**Markdown files (`.md`):**

```bash
uvx pymarkdownlnt scan -r .opencode/guidelines/ docs/   # Lint
uvx mdformat --check .opencode/guidelines/ docs/        # Format check (advisory)
```

**Rationale:** Python linters (`ruff`, `pyright`, `vulture`) are designed for Python syntax and will produce incorrect or useless results when run on markdown files. Use markdown-specific tools (`pymarkdownlnt`, `mdformat`) for markdown files.

## Numbering — ENFORCED

Numbered lists must start at 1. Zero-indexed documentation is harder for humans to read. This is the project convention — experienced engineers follow it.

**Prohibited:**

- Zero-indexed numbered lists (`0. First item`, `1. Second item`)
- Step 0 in procedures (use Step 1 as the first step)
- Phase 0 in specs (use Phase 1 as the first phase)

**Exceptions:**

- Code comments explaining 0-indexed array access
- Technical documentation explicitly explaining zero-based indexing concepts

**Rationale:** Documentation is for humans. Natural counting matches human cognition.

**Grandfather clause:** Existing skill files, guideline files, and documentation that use 0-based counting (Step 0, Phase 0) are exempt from this rule. Only newly created or substantially updated files must comply. When updating an existing file that uses 0-based counting, only new or changed sections need to comply — existing 0-based sections are preserved.

## AI Co-Authored Attribution (MANDATORY)

**AI-generated creative content MUST include co-authored attribution where the content format supports it.**

### What Counts as AI-Generated Content

AI co-authorship applies to **creative, original content authored by AI**:

- Original code written by AI
- Original documentation written by AI
- Original designs/architectures conceived by AI
- New modules, classes, functions created by AI

### What Does NOT Require AI Attribution

**Standard/boilerplate content does NOT require AI attribution:**

- Standard licenses (MIT, Apache, GPL, etc.) - these are established legal templates
- Auto-generated files (lock files, build artifacts, `__pycache__`)
- Framework boilerplate (default configs, standard project structures)
- Minor edits to existing files (typo fixes, formatting)
- Files with no creative content (empty `__init__.py`, pure config)

**Copy-pasted content from ANY external source does NOT get AI attribution:**

- Code copied from Stack Overflow, blogs, tutorials
- Code copied from other projects/repositories
- Documentation copied from official sources
- Configuration copied from templates/examples
- **If it was copy-pasted, it's NOT AI-co-authored** - the original source holds copyright

**Rationale:** AI attribution is about transparency in creative work. Copying a standard MIT license, copying code from Stack Overflow, or copy-pasting documentation from another project requires no AI creativity - those sources hold their own copyrights. Only genuinely original content created by AI deserves AI co-authorship attribution.

### Files Requiring Attribution (In-Repository)

| File Type | Attribution Location | Format |
| -- | -- | -- |
| Python files (`.py`) | Module docstring | `"""Co-authored with AI: <AgentName> (<ModelId>)"""` |
| README files | Footer section | `## Co-Authored With AI` section |
| New repositories | README.md | AI co-authored section (see below) |
| Original docs | Footer | `*Co-authored with AI: <AgentName> (<ModelId>)*` |

### Posted Content Requiring Attribution

| Content Type | Attribution Location | Format |
| -- | -- | -- |
| Issue comments (any repository) | Last line of comment body | `🤖 Co-authored with AI: <AgentName> (<ModelId>)` |
| PR comments (any repository) | Last line of comment body | `🤖 Co-authored with AI: <AgentName> (<ModelId>)` |
| PR bodies (AI-authored) | Last line before horizontal rule or end of body | `🤖 Co-authored with AI: <AgentName> (<ModelId>)` |
| Issue bodies (AI-authored) | Last line of issue body | `🤖 Co-authored with AI: <AgentName> (<ModelId>)` |

External repository posts have HIGHER attribution priority than internal content. External posts represent the project to third parties — attribution is a transparency and ethical requirement, not optional.

### Standalone Byline Correction — FORBIDDEN

**Adding a standalone comment whose sole purpose is to append a byline to a previous comment is ABSOLUTELY FORBIDDEN.**

When a byline is missing from AI-authored posted content:

| Option | When | Action |
| -- | -- | -- |
| **Edit the comment** | Platform supports edit + agent has edit permission | Edit the original comment, append byline as last line |
| **Delete + repost** | Agent has delete permission | Delete original, repost with byline included |
| **Accept the omission** | No edit/delete permission | Leave it. Do NOT add a separate byline comment. |

The byline must be **part of the content body**, never a separate message.

### Preserve Existing Bylines

When an AI agent edits a file or posted content that already contains a `Co-authored with AI:` byline from a prior AI agent, the editing agent MUST preserve the existing byline. Overwriting a prior agent's identity erases audit trail, falsifies content origin history, and breaks traceability.

#### Rules

1. **Never overwrite a prior agent's byline.** When editing a file with an existing `Co-authored with AI:` line, the agent MUST NOT modify, replace, or remove that line.

2. **Append, don't replace.** If the editing agent contributed substantive new AI-generated content, it appends its own byline on a new line following existing byline(s). Minor edits (typo fix, formatting, refactoring without new creative content) do not need an additional byline.

3. **Format consistency.** The editing agent uses the same format as existing byline(s) — do not change `*italic*` to emoji or vice versa. New files use the format specified per file type.

4. **Multi-agent bylines.** When a file has bylines from multiple AI agents, chronological order is preserved — each new byline appended at the end.

#### Examples

**Source file editing — CORRECT (preserve + append):**

```python
# Before edit (byline from prior agent Alpha):
"""Process user data.

Co-authored with AI: Alpha (alpha-model-v1)
"""

# After edit by agent Beta — CORRECT:
"""Process user data and validate input.

Co-authored with AI: Alpha (alpha-model-v1)
Co-authored with AI: Beta (beta-model-v2)
"""
```

**Source file editing — WRONG (identity overwrite):**

```python
# Before edit (byline from prior agent Alpha):
"""Process user data.

Co-authored with AI: Alpha (alpha-model-v1)
"""

# After edit by agent Beta — WRONG:
"""Process user data and validate input.

Co-authored with AI: Beta (beta-model-v2)  # ← prior agent identity erased
"""
```

**Posted content editing — CORRECT (preserve + append):**

When editing an existing issue or PR comment that already has a byline, preserve the existing byline and append the new one:

```
Original content here.

🤖 Co-authored with AI: Alpha (alpha-model-v1)
🤖 Co-authored with AI: Beta (beta-model-v2)
```

### Files NOT Requiring Attribution

| File Type | Reason |
| -- | -- |
| LICENSE files | Standard legal templates (MIT, Apache, etc.) |
| `pyproject.toml`, `setup.py` | Boilerplate configuration |
| Lock files (`uv.lock`, `package-lock.json`) | Auto-generated |
| Empty `__init__.py` | No content |
| Standard `.gitignore` | Established template |
| Copy-pasted code/docs | Original source holds copyright |

### Attribution Format

```
Co-authored with AI: <AgentName> (<ModelId>)
```

**Example:**

```
Co-authored with AI: <AgentName> (<ModelId>)
```

### Repository Creation

When creating a new repository, the README MUST include:

```markdown
## Co-Authored With AI

This repository was created with assistance from AI:

- **AI Agent**: <AgentName>
- **Model**: <ModelId>
- **Date**: YYYY-MM-DD
```

**Note:** The LICENSE file uses standard MIT license without modification. AI attribution goes in README, not LICENSE.

### Python Files

Every Python file with original AI-authored code MUST include attribution in the module docstring:

```python
"""Module description.

Co-authored with AI: <AgentName> (<ModelId>)
"""
```

### Why This Matters

AI co-authored attribution:

1. Maintains transparency about content origin
2. Follows emerging best practices for AI-assisted work
3. Enables proper credit and traceability
4. Helps identify AI-generated content for review
5. **Respects copyright** - only claims co-authorship on genuinely original AI work

## Provenance Headers

### Provenance Distinct from Byline

- **Byline** = *who* created it (identity attribution) — specified in §AI Co-Authored Attribution
- **Provenance** = *how* it was created (origin category) — new concept

### Provenance Categories

| Category | Meaning | Header Value |
|----------|---------|--------------|
| AI-generated | Entirely written by AI agent | `Provenance: AI-generated` |
| AI-assisted | Human wrote, AI assisted | `Provenance: AI-assisted` |
| Human-written | Entirely human-authored | `Provenance: Human-written` |
| Derived | Adapted from another source | `Provenance: Derived from <source>` |

### Header Format by File Type

#### Python Files (.py)

```python
# SPDX-FileCopyrightText: <year> <dev.name>
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
"""
Module description.

Co-authored with AI: <AgentName> (<ModelId>)
"""
```

#### SKILL.md Files (YAML frontmatter)

```yaml
---
name: skill-name
license: MIT
provenance: AI-generated
---
```

#### Scala Files (.scala)

```scala
// SPDX-FileCopyrightText: <year> <dev.name>
// SPDX-License-Identifier: Apache-2.0
// Provenance: AI-generated

/** Module description.
  *
  * Co-authored with AI: <AgentName> (<ModelId>)
  */
package com.example...
```

Note: Scala projects may use Apache-2.0 (not MIT) — use the correct SPDX identifier for the project's license.

#### Markdown Files (guidelines, docs)

```markdown
<!-- SPDX-FileCopyrightText: <year> <dev.name> -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->
```

#### Other Languages (Fallback Rule)

For languages not explicitly listed (Java, C++, Go, Rust, etc.), use the language's block comment syntax to include the same three SPDX/Provenance lines, then a doc comment with the AI byline:

| Language | Block Comment | Doc Comment |
|----------|--------------|-------------|
| Java | `// SPDX-...` | `/** Co-authored with AI: ... */` |
| C/C++ | `// SPDX-...` | `/** Co-authored with AI: ... */` |
| Go | `// SPDX-...` | `// Co-authored with AI: ...` |
| Rust | `// SPDX-...` | `//! Co-authored with AI: ...` |

Pattern: `// SPDX-FileCopyrightText:` + `// SPDX-License-Identifier:` + `// Provenance:` + doc comment with `Co-authored with AI:`.

### Provenance + Byline Rules

| Provenance | AI Byline Required? |
|------------|-------------------|
| AI-generated | MUST include |
| AI-assisted | SHOULD include if AI contributions substantive |
| Human-written | MUST NOT include |
| Derived | MUST NOT include AI byline; MUST attribute source |

## Enforcement Test Mandate for Guideline and Skill Changes

**Terminology:** In this document, "behavioral test" and "functional test" are synonymous. Both refer to tests that verify actual agent behavior by executing code and observing output, as opposed to structural/content-verification tests that verify text patterns in files. When a functional/behavioral test cannot execute, the SC is FAIL — never PASS or UNVERIFIED with a structural substitute.

Behavioral tests are how real agents prove their rules work. Adding a guideline change without a behavioral test means you are documenting, not enforcing.

Guideline files (`.opencode/guidelines/*.md`) and skill files (`.opencode/skills/*/SKILL.md`, `.opencode/skills/*/tasks/*.md`) are enforcement-critical documents that control AI agent behavior. Changes to these files MUST be accompanied by corresponding enforcement test updates.

### Behavioral Enforcement Tests (PRIMARY)

Behavioral enforcement tests verify that the agent actually behaves differently after a rule change. They send a prompt to the agent and verify the response actions (tool calls, decline patterns, explicit questions), not just whether rule text exists in a file.

**Principle:** Behavioral tests answer "Does the agent actually behave differently?" Content-verification tests answer "Does the rule text exist in the file?" Both are needed, but behavioral is the PRIMARY enforcement gate.

**Prompt construction:** Behavioral test prompts MUST be real-domain tasks that trigger natural agent behavior — never interview-style prose-recall prompts. See `.opencode/tests/AGENTS.md` §9 Prompt Construction Mandate for the full specification.

**Root case:** Bug #1217 demonstrated that the agent had all the correct guideline text about verification but still answered a general knowledge question with zero tool-call verification. Content-verification alone was insufficient — the agent behavior did not match the rule text.

Every critical violation change MUST have at least one behavioral test that verifies the agent follows the new rule. Behavioral tests use the assertion helpers in `.opencode/tests/behaviors/helpers.sh`:

- `assert_tool_calls_made` — verify the agent made at least N tool calls of a specified type
- `assert_forbidden_pattern_absent` — verify the agent's response does NOT contain a specified pattern (e.g., `(unverified)` tags)
- `assert_required_pattern_present` — verify the agent's response DOES contain a specified pattern (e.g., decline-to-answer language)
- `assert_skill_called` — verify a specific skill was called
- `assert_no_skill_called` — verify a specific skill was NOT called when it shouldn't be

### Assert Helpers — Correct Evidence Type per SC Type

Behavioral tests verify agent ACTIONS and DECISIONS. The assertion helper must match the SC's evidence type:

| SC Evidence Type | PRIMARY Assertion | SECONDARY (corroboration only) | FORBIDDEN |
|---|---|---|---|
| `behavioral` | `assert_semantic` (clean-room AI inspector) | `assert_stderr_pattern_*` for tool dispatch strings only | grep/string on agent output prose |
| `string` | `assert_stderr_pattern_*`, `assert_required_pattern_present`, `assert_forbidden_pattern_absent` | — | — |
| `structural` | `ls`, `wc`, file existence | — | — |

**`assert_semantic`** — Clean-room AI inspector evaluates full agent output and judges whether the agent TOOK THE RIGHT ACTION or MADE THE RIGHT DECISION. Different model, no context preloading, no cached results. This is the ONLY valid assertion type for behavioral SCs that verify agent actions, decisions, or reasoning.

**`assert_stderr_pattern_present/absent`** — grep on stderr for tool-call strings (e.g., `Skill "approval-gate"`, `git checkout -b`). Only valid for verifying that a tool dispatch OCCURRED or DID NOT occur — NEVER for judging agent reasoning, approach, or decisions. USE AS SECONDARY CORROBORATION ONLY for behavioral SCs, never as primary evidence.

**All other string assertions** (`assert_required_pattern_present`, `assert_forbidden_pattern_absent`, `assert_tool_calls_made`, `assert_skill_called`, `assert_no_skill_called`) — string evidence, appropriate for string or structural SCs, FORBIDDEN as primary evidence for behavioral SCs.

**Prohibitions (per §Rule 5):**
- 🚫 `assert_stderr_pattern_present` as PRIMARY evidence for "agent verified authorization scope" — this is string evidence, not behavioral
- 🚫 `assert_required_pattern_present` on agent prose as primary evidence for "agent chose stacked approach" — this is string evidence on prose, the weakest form
- 🚫 Any grep/string assertion on agent output prose as PRIMARY evidence for a behavioral SC — EVIDENCE_TYPE_MISMATCH
- ✅ `assert_semantic "SC-N" "description of required action"` — clean-room inspector judges full output
- ✅ `assert_stderr_pattern_present 'Skill "approval-gate"'` as SECONDARY corroboration only

### Content-Verification Tests (SECONDARY)

Content-verification tests verify that rule text exists in the correct files. They are a supplementary sanity check — they confirm the rule was written down but do NOT prove the agent follows it.

Content-verification tests are valuable as a fast check that files haven't regressed, but they MUST NOT be the only enforcement gate for a behavioral rule change. A rule change with only a content-verification test is NOT verified — it only proves the text was written, not that the agent follows it (see #1217).

### 🚫 PROHIBITED

- Adding a critical violation section without a BEHAVIORAL enforcement test that verifies the agent's actual response
- Adding a verification step to a skill without a BEHAVIORAL enforcement test that validates the agent follows it
- Creating a new guideline without a BEHAVIORAL enforcement test that sends a prompt and verifies the agent's behavior
- Modifying a guideline or skill without updating the corresponding BEHAVIORAL enforcement test
- Content-verification tests (checking rule text exists) as the ONLY enforcement for a behavioral rule change
- Running `opencode-cli run` directly without the `with-test-home` wrapper

### ✅ REQUIRED

- Every guideline/skill change comes with a BEHAVIORAL enforcement test that verifies agent behavior
- Content-verification tests as a supplementary sanity check, NOT the primary enforcement gate
- Add the BEHAVIORAL test FIRST (RED), then make the change (GREEN) — behavioral TDD for rules
- Run individual behavioral test scripts (`bash .opencode/tests/behaviors/<scenario>.sh`) for behavioral tests
- Run scope-filtered `bash .opencode/tests/test-enforcement.sh --tag <tag>` or `--changed` for content-verification tests
- Use `bash .opencode/tests/with-test-home opencode-cli run '<message>'` for all opencode-cli testing — never run bare `opencode-cli run`
- Clean up test homes after testing: `bash .opencode/tests/with-test-home --clean-all`

### Per-Change TDD Pattern

| TDD Phase | Action |
| -- | -- |
| **RED** | Write a BEHAVIORAL test that sends a prompt and expects the agent to follow the new rule (test fails because agent doesn't follow it yet); optionally add a content-verification test |
| **GREEN** | Make the guideline/skill change that causes the agent to follow the rule |
| **REFACTOR** | Verify content-verification also passes; clean up test scenarios; confirm behavioral test passes reliably |
| **COMMIT** | Both the behavioral test, content-verification test (if any), and the guideline/skill change committed together |

### Why This Matters

Enforcement tests are the verification layer that proves agent guidelines are actually enforceable. A guideline without a behavioral test is a suggestion, not a rule. A skill without a behavioral test is documentation, not enforcement. Bug #1217 proved that content-verification alone is insufficient — the agent had correct rule text but did not follow the rule in practice.

The `with-test-home` wrapper prevents SQLite session conflicts between the desktop app and CLI tests.

**See `091-incremental-build.md` for the incremental implementation discipline that governs HOW these changes are delivered.** **See `.opencode/tests/README.md` for the enforcement test template and usage guide. See `.opencode/tests/behaviors/` for behavioral test infrastructure, helpers, and template.**

### Evidence Type Taxonomy (MANDATORY)

Every spec success criterion MUST declare an evidence type from the four-type taxonomy. The evidence type determines the minimum acceptable verification method — using evidence below the minimum type is a CRITICAL VIOLATION.

| Evidence Type | Method | Verifies | Minimum Acceptable | Cost | Gate Position |
|---|---|---|---|---|---|
| `behavioral` | Test execution (`opencode-cli run`, `pytest`, `bash test.sh`) | Agent behavior, runtime output, functional correctness | Test execution with output inspection | Lowest: behavioral FAIL at gate 1 → immediate fix → zero downstream cost | pre-commit / pre-RED |
| `semantic` | AI agent read + analytical judgment | Intent and meaning, not just pattern | Sub-agent read + judgment | Medium: semantic PASS → behavioral FAIL at CI → 100x rework | pre-PR / review |
| `string` | `grep`, pattern matching | Content pattern present or absent | `grep` | High: string PASS → behavioral FAIL in production → NIST 29x escalation | CI / static analysis |
| `structural` | `ls`, `wc`, file existence | File exists, file is non-empty, file has correct name | `ls`/`wc` | Highest: structural PASS → defect ships → death spiral → compounding exponential cost | none / irrelevant |

**Cost explanation:** See `065-verification-honesty.md` §Cost Model for death spiral / break dynamics. Evidence type cost is measured in defect-discovery-latency (DDL), not execution time. A structural check costs ~1s to run but may take weeks to discover the defect it misses — making it the most expensive type in total pipeline cost. A behavioral test costs minutes to execute but catches the defect at the earliest possible gate — making it the cheapest in total pipeline cost.

### Evidence Type Enforcement Matrix

| SC Evidence Type | Structural Evidence | String Evidence | Semantic Evidence | Behavioral Evidence |
|---|---|---|---|---|
| `structural` | ✅ Sufficient | ✅ Sufficient | ✅ Sufficient but unnecessary | ⚠️ Overkill |
| `string` | ❌ Insufficient | ✅ Sufficient | ✅ Sufficient | ⚠️ Overkill |
| `semantic` | ❌ Insufficient | ❌ Insufficient | ✅ Sufficient | ✅ Sufficient |
| `behavioral` | ❌ **CRITICAL VIOLATION** | ❌ **CRITICAL VIOLATION** | ❌ **CRITICAL VIOLATION** | ✅ Only sufficient type |

Evidence below the minimum type for an SC's declared evidence type is a CRITICAL VIOLATION — it is not a soft-pass or an acceptable substitute. This applies at every pipeline stage: VbC, auditor dispatch, cross-validate, and PR body.

**Existing specs without evidence type columns default to `string` evidence type.** The spec-audit SC-DET check flags specs missing evidence type declarations but does not block them — only downgrade to a warning until the spec is updated.

**Mixed-evidence SCs** (e.g., `string + behavioral`) require ALL declared types to be present in the evidence. An SC that requires both string and behavioral evidence must have both a `grep` result and a test execution result.

**EVIDENCE_TYPE_MISMATCH** classification: When an auditor or VbC sub-agent provides structural evidence for a behavioral SC, the verdict MUST be reported as FAIL with `EVIDENCE_TYPE_MISMATCH` classification. This is not a soft-pass — it is a hard FAIL. Cross-validate MUST downgrade any PASS verdict with wrong evidence type to FAIL with `EVIDENCE_TYPE_MISMATCH`.

### SC-to-Test Traceability (MANDATORY) — Behavioral PRIMARY

Every spec success criterion MUST have at least one corresponding BEHAVIORAL enforcement test assertion that references the SC ID. The assertion must include a comment linking it to the specific SC:

```bash
# SC-2: agent declines to answer without verification
assert_forbidden_pattern_absent "(unverified)" "unverified escape hatch" || OVERALL_RESULT=1
```

The SC ID comment convention is now a REQUIREMENT, not a convention. Every enforcement test that verifies a spec success criterion MUST include a `# SC-N:` comment prefix identifying which SC it covers.

Content-verification tests (checking rule text existence) are SECONDARY — they supplement behavioral tests but MUST NOT be the only enforcement for behavioral rule changes.

**Spec Success Criteria tables MUST include an Evidence Type column** declaring the evidence type for each SC:

```
| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | SKILL.md routes only to Trigger Dispatch Table | `string + semantic` | grep + sub-agent read |
| SC-14 | Agent dispatches sub-agents, no inline work | `behavioral` | `opencode-cli run` → stderr assertions |
```

The Evidence Type column is MANDATORY in all spec success criteria tables. Specs missing the Evidence Type column fail the spec-audit SC-DET check with a warning (not a block) until updated.

### RED-Phase Ordering (BEHAVIORAL PRIMARY) — MANDATORY

The BEHAVIORAL enforcement test for each SC MUST exist and FAIL before implementation of that SC begins. This is the behavioral TDD cycle:

1. **RED**: Write the BEHAVIORAL enforcement test that verifies the SC (send a prompt, assert the agent follows the rule — test fails because the change doesn't exist yet)
2. **GREEN**: Implement the change that makes the agent follow the rule
3. **REFACTOR**: Verify content-verification also passes; clean up test scenarios
4. **COMMIT**: Both the behavioral test and the change committed together

Writing behavioral tests AFTER implementation means the test was never RED — it never caught the gap between the rule and the agent's behavior. The #1217 root cause was exactly this: the agent had correct rule text (passed content-verification) but did not follow the rule in practice (would have failed behavioral verification).

If SC-to-test traceability is missing any behavioral test for any SC, or if behavioral test assertions were written after implementation (GREEN-without-RED), implementation MUST NOT proceed until the behavioral tests are added and shown to fail first.

## Behavioral RED/GREEN as Primary Enforcement Gate

Content-verification tests (grep for text presence) are SECONDARY. Behavioral tests (verify agent behavior changes) are PRIMARY. This hierarchy is enforced at every workflow step where rule changes are made or approved.

### The Behavioral RED/GREEN Gate

The TDD RED/GREEN cycle for rule changes MUST use behavioral enforcement tests, not just content-verification tests:

1. **RED phase**: Write a behavioral enforcement test that sends the agent a prompt and verifies the agent does NOT follow the new rule yet. The test MUST FAIL at this point because the rule change hasn't been made. Use assertion helpers from `.opencode/tests/behaviors/helpers.sh` (`assert_tool_calls_made`, `assert_forbidden_pattern_absent`, `assert_required_pattern_present`, `assert_skill_called`, `assert_stderr_pattern_present`, `assert_stderr_pattern_absent`, `assert_stderr_pattern_present_all_models`, `assert_stderr_pattern_absent_all_models`).
2. **GREEN phase**: Make the guideline/rule change and re-run the behavioral test. The test MUST PASS because the agent now follows the rule.
3. **No exceptions**: This gate applies to ALL rule changes — guideline files, skill files, task files, critical violation sections, system prompt blocks.

### 🚫 PROHIBITED (for behavioral rule changes)

- Content-verification tests (grep patterns) as the ONLY enforcement for a behavioral rule change
- Marking a rule change as "tested" when only text presence was verified — the agent having correct rule text does NOT prove it follows the rule
- Writing behavioral tests AFTER implementation (GREEN-without-RED) — the test must be RED first, then GREEN
- Bypassing the behavioral gate because a content-verification test already exists for the same rule
- Claiming a rule is "enforced" based solely on content-verification without behavioral evidence

### ✅ REQUIRED (for behavioral rule changes)

- Every critical violation change MUST have at least one behavioral test verifying the agent follows the new rule
- Behavioral tests are PRIMARY — they prove the agent's behavior actually changed
- Content-verification tests are SECONDARY — they confirm rule text exists but do NOT prove agent compliance
- Add the behavioral test FIRST (RED), then make the change (GREEN) — behavioral TDD for rules
- The behavioral RED/GREEN gate is enforced at every workflow step: spec creation, plan creation, plan execution, and approval gate

### Root Case

Bug #1217 demonstrated that the agent had all the correct guideline text about verification but still answered a general knowledge question with zero tool-call verification. Content-verification alone was insufficient — the agent behavior did not match the rule text. This is why behavioral tests are PRIMARY: they verify that the agent actually behaves differently, not just that the rule text exists.

## Test Integrity Mandate — No Lobotomizing Tests

**Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is the most expensive defect you can introduce. A lobotomized test passes by removing the signal it was designed to verify — producing a false PASS that masks a real defect. This is equivalent to soft-passing a verification mismatch (already prohibited by §Evidence Type Taxonomy and `000-critical-rules.md` §critical-rules-020).**

### Rule 1: No Lobotomizing Tests — ZERO TOLERANCE

Removing or weakening a behavioral (semantic, functional) test assertion to work around a timeout, failure, or infrastructure issue is a **CRITICAL VIOLATION**.

**Prohibited patterns:**
- Removing `assert_semantic` because the semantic inspector model times out
- Replacing a `behavioral` evidence type with `string` or `structural` to "fix" a failing test
- Removing an assertion entirely because it "flakes" or "hangs"
- Commenting out an assertion with `# TODO: fix later`
- Changing `assert_semantic` to `assert_stderr_pattern_present` because "it's faster"

**The only valid remediation cycle:**
1. **Increase timeout** — `BEHAVIOR_TIMEOUT`, `BEHAVIOR_SEMANTIC_TIMEOUT`, or `BEHAVIOR_MAX_RETRIES`
2. **Inspect stdout** — Read `$BEHAVIOR_STDOUT` or `$log_dir/stdout.log` to understand what the agent actually produced
3. **Inspect stderr** — Read `$BEHAVIOR_STDERR` or `$log_dir/stderr.log` to understand tool dispatch and errors
4. **Diagnose root cause** — Determine if the issue is: infrastructure (model load time, network latency, GPU memory), test harness (test repo setup, model config seeding), or test spec (prompt too complex, assertion too broad)
5. **Remediate** — Fix the root cause: increase timeout, fix model config, adjust prompt specificity, add retry logic
6. **Repeat** — Re-run the test after remediation
7. **Escalate** — Only after multiple remediation cycles have genuinely failed

**Escalation is the LAST resort, not the first. Proceeding past a FAIL is never legitimate — it is always cheaper to diagnose and fix than to hide the defect.**

### Rule 2: Timeout Is Always Diagnosable — Never Assume Model Unavailability

When a behavioral test times out, the agent MUST:
1. Inspect `stdout.log` and `stderr.log` from the test run
2. Run `opencode-cli models` to verify model availability — never assume unavailability from memory or training data
3. Run a direct `with-test-home opencode-cli run "test ping" --model <model>` to verify the model works
4. Report the actual root cause (timeout duration, model load time, network latency, etc.)

**Never claim "model not available" or "model timed out" without tool-call evidence.** This is already covered by `065-verification-honesty.md` but the pattern keeps recurring in behavioral test contexts, so this rule cannonizes it specifically for the test integrity domain.

### Rule 3: Research Sub-Agents for Test Infrastructure Problems

When the remediation cycle (increase timeout → inspect output → diagnose → fix) fails to resolve the issue after 2+ attempts, the agent MUST dispatch a research sub-agent to investigate known solutions for:
- LLM inference timeouts in CI environments
- `opencode-cli run` timeout patterns and mitigation
- Model loading latency in test environments
- Behavioral test harness reliability patterns

This research is mandatory — the agent MUST NOT give up on a behavioral test and proceed past a FAIL. Research, remediate, and repeat is the only valid cycle.

### Rule 5: Agent Output MUST Be Verified by Clean-Room Semantic Inspection — NEVER by grep/string on Prose

**Agent output (stdout + stderr) is LLM-generated English prose. grep/string assertions on LLM prose are string evidence, which is EVIDENCE_TYPE_MISMATCH for behavioral SCs.**

Behavioral SCs require behavioral evidence. Behavioral evidence means a **clean-room sub-agent** (the semantic inspector) evaluates the full agent output and renders a PASS/FAIL judgment. The inspector is a different model reading the output cold — no context preloading, no orchestrator hints, no cached results. This is the only valid form of behavioral verification for agent output.

#### What Each Assertion Type Actually Verifies

| Assertion | Evidence Type | What It Checks | When It's Sufficient |
|-----------|--------------|----------------|----------------------|
| `assert_semantic` | behavioral | AI inspector judges full output for agent ACTIONS and DECISIONS | PRIMARY — always sufficient for behavioral SCs |
| `assert_stderr_pattern_present/absent` on tool calls | string (acceptable for structural checks only) | grep matches raw tool-call strings in stderr (e.g., `Skill "approval-gate"`, `git checkout -b`) | ONLY for verifying tool dispatches occurred/didn't occur — NEVER for judging agent reasoning |
| `assert_forbidden_pattern_absent` | string | grep matches forbidden text patterns in agent prose | ONLY for detecting prohibited output patterns (e.g., `(unverified)` tags, solicitation phrases) — NEVER for judging agent decisions or approach |
| `assert_required_pattern_present` | string | grep matches required text in agent prose | ONLY for detecting required output patterns (e.g., byline presence) — NEVER for judging agent reasoning or approach |

#### The Hard Rule

**For any SC that requires verifying the agent TOOK THE RIGHT ACTION or MADE THE RIGHT DECISION (e.g., "agent creates 1 branch, not 2", "agent dispatches the correct skill", "agent follows stacked PR strategy"), the ONLY sufficient assertion is `assert_semantic` with a clean-room semantic inspector. grep/string assertions on agent output are EVIDENCE_TYPE_MISMATCH for behavioral SCs.**

This means:

- 🚫 FORBIDDEN: `assert_stderr_pattern_present "Skill.*approval-gate"` as primary evidence for "agent verified authorization scope" — this is string evidence, not behavioral
- 🚫 FORBIDDEN: `assert_stderr_pattern_absent "create_branch.*feature"` as primary evidence for "agent did not create multiple branches" — this is string evidence, not behavioral
- 🚫 FORBIDDEN: `assert_required_pattern_present "stacked"` in agent prose as primary evidence for "agent chose stacked approach" — this is string evidence on prose, the weakest form
- ✅ REQUIRED: `assert_semantic "SC-N" "Agent dispatched approval-gate skill and created exactly ONE feature branch for both issues together"` — clean-room semantic inspector judges full output
- ✅ ACCEPTABLE: `assert_stderr_pattern_present 'Skill "approval-gate"'` as SECONDARY structural corroboration — confirms tool dispatch occurred, but does NOT verify the agent's decision or approach

#### Why This Matters

LLM output is non-deterministic. The exact strings the agent produces change on every run. grep patterns that match today break tomorrow. A semantic inspector evaluates the *meaning* of the output, not the *strings*. This is the same distinction as the Evidence Type Taxonomy: `behavioral` > `semantic` > `string` > `structural`. Using string evidence where behavioral is required is EVIDENCE_TYPE_MISMATCH — a hard FAIL.

### Rule 4: FAIL Is a Hard Gate — Never Proceed Past FAIL

This reinforces `000-critical-rules.md` §critical-rules-hard-fail for the behavioral testing context specifically:

**A behavioral test that FAILS is a hard gate. The agent MUST NOT:**
- Proceed to the next task or pipeline stage
- Mark the test as "PASS with caveats" or "functionally equivalent"
- Report the test as "INCONCLUSIVE" without exhausting remediation first
- Treat INCONCLUSIVE as anything other than a FAIL that needs more remediation
- Remove or weaken the assertion that produced the FAIL

**The only valid outcomes:**
- **PASS** — all assertions pass with genuine behavioral evidence
- **FAIL** — one or more assertions fail; remediate and re-run
- **INCONCLUSIVE after exhaustive remediation** — escalate; do NOT proceed

### Rule 6: "Artifact Generated" Is NOT a Valid PASS Verdict for Behavioral SCs

**Reporting "artifact generated" as a PASS verdict for a behavioral SC is EVIDENCE_TYPE_MISMATCH — a hard FAIL.**

Behavioral test artifacts (stdout.log, stderr.log, session.yaml) are raw output from `behavior_run`. Their existence proves the test ran, NOT that the agent's behavior matched the SC criterion. Evaluating artifacts requires a clean-room sub-agent that reads the artifacts and judges whether the agent's actions and decisions satisfy the SC.

**Prohibited patterns:**
- Reporting "✅ Artifact generated" as a PASS verdict for a behavioral SC
- Reporting "Artifacts exist" as evidence of behavioral compliance
- Using file existence (structural evidence) as a substitute for clean-room evaluation
- Skipping clean-room evaluation because "the artifacts look correct"

**Required pattern:**
1. After `behavior_run` produces artifacts, dispatch `behavioral-test-evaluation` from `verification-before-completion`
2. The evaluation task dispatches clean-room sub-agents to read artifacts and produce PASS/FAIL per SC
3. Only after clean-room evaluation returns PASS for all behavioral SCs may the agent report PASS
4. "Artifact generated" is NEVER a valid PASS verdict — only clean-room evaluation counts

## Cross-Reference Standards

**Cross-references in specs, issues, and documentation MUST use stable anchors, NOT line numbers.**

### Required Format

| Reference Type | Format | Example |
| -- | -- | -- |
| Function | `file.py` `function_name()` | `process_data()` in `pubmed_client.py` |
| Class | `file.py` `ClassName` | `MeshValidator` in `validator.py` |
| Section | `file.md` `"Section Name"` | `"Cross-Reference Standards"` in `080-code-standards.md` |
| Code snippet | Include snippet (\<20 lines) | See examples below |

### Forbidden Format

| Reference Type | Format | Why Forbidden |
| -- | -- | -- |
| Line number | `file.py:42` | Breaks on every edit |
| Line range | `file.py:42-48` | Breaks on every edit |
| Bare number | "line 42" | No context, breaks on edit |

### Why This Matters

Line numbers shift when:

- Lines are added above the reference
- Lines are deleted above the reference
- Any edit changes file length

Stable anchors (function names, class names, section headers) remain valid across edits.

### Examples

**❌ WRONG (Line Numbers):**

```
See `file.py:42` for the function definition.
See `guidelines.md:150` for the rule.
```

**✅ CORRECT (Stable Anchors):**

```
See `process_data()` in `file.py` for the function definition.
See `"Cross-Reference Standards"` section in `guidelines.md` for the rule.
```

## Mandatory Triple Co-Application

### Scope

Mandatory Triple Co-Application applies to all **AI-agent-facing text** — any content whose primary consumer is an AI agent rather than a human reader. This includes:

- Skill descriptions, Overview, Persona, and Purpose sections
- Task file headers, purpose statements, and routing instructions
- Guideline enforcement blocks and procedural rules
- System prompt fragments and configuration descriptions
- Any instruction or directive written for consumption by another AI agent

### Triple Applicability

Each of the three reference cards handles a distinct layer of AI-agent-facing text:

| Card | Layer | Handles |
|------|-------|---------|
| `250-dark-prose-reference.md` | Identity | Dark prose patterns, identity-anchoring, confirmshaming, goal hijacking, authority frame, agency-respecting prose |
| `255-distribution-shifting-reference.md` | Signal | Distribution shifting, mean response, expert tail, contrastive decoding, external-signal verification, corrupt-success contrast |
| `257-procedural-discipline-reference.md` | Structure | Procedural discipline, dependency order, re-priming, controlled vocabulary, verification signal, positional enforcement |

### Auto-Detection Trigger

Any agent that creates or modifies AI-agent-facing text MUST consult all three reference cards (250, 255, 257) before producing output. The trigger is: the content being created/modified will be read by an AI agent as instructions, guidance, or enforcement. Detection is automatic — no separate authorization or deliberation required.

All three reference cards (250, 255, 257) are mandatory for all AI-agent-facing text creation or modification. Omission of any card during content generation is a content-completeness defect.

## Parameter Naming Convention

Session-init and env-loader are two independent pipelines with separate naming conventions:

| Pipeline | Source | Output Format | Consumer | Example |
| -- | -- | -- | -- | -- |
| LLM context | session-init (Python) | Dotted `scope.param` | Agent system prompt | `github.owner` |
| Bash environment | env-loader.ts (TypeScript) | UPPER_CASE | Shell commands, Python scripts | `GIT_OWNER` |

**Session-init dotted names** (use in skill files, guidelines, task contexts):
`github.owner`, `github.repo`, `github.platform`, `github.html_url`, `gitbucket.owner`, `gitbucket.repo`, `gitbucket.html_url`, `gitbucket.ssh_url`, `gitbucket.has_credentials`, `srclight.project`, `dev.name`, `dev.email`, `branch`, `worktree.path`, `worktree.fatal`

**Env-loader UPPER_CASE names** (use in bash scripts, Python env reads):
`GIT_OWNER`, `GIT_REPO`, `GIT_PLATFORM`, `GITHUB_HTML_URL`, `GITBUCKET_HTML_URL`, `GITBUCKET_SSH_URL`, `GITBUCKET_HAS_CREDENTIALS`, `DEV_NAME`, `DEV_EMAIL`, `BRANCH_NAME`, `WORKTREE_PATH`, `WORKTREE_FATAL`

These pipelines are independent. Changing session-init output names does NOT require changes to env-loader, and vice versa.

```yaml+symbolic
schema_version: "3.0"
last_updated: "2026-05-17T00:00:00Z"
rules:
  - id: code-standards-001
    tier: 3
    title: "Explicit type hints project-wide"
    conditions:
      all:
        - "python_file_created_or_modified == true"
        - "type_hints_present == false"
    actions:
      - FLAG
    conflicts_with: []
    requires: []
    triggers: []
    source: "080-code-standards.md §Typing"

  - id: code-standards-002
    tier: 3
    title: "AI co-authored attribution mandatory for AI-generated content"
    conditions:
      all:
        - "ai_generated_content_created == true"
        - "attribution_present == false"
    actions:
      - FLAG
      - ADD_ATTRIBUTION
    conflicts_with: [critical-rules-023]
    requires: []
    triggers: [issue-operations]
    source: "080-code-standards.md §AI Co-Authored Attribution"

  - id: code-standards-002a
    tier: 3
    title: "Preserve existing AI bylines — never overwrite prior agent identity"
    conditions:
      all:
        - "editing_file_with_existing_byline == true"
        - "byline_overwrite_attempted == true"
    actions:
      - FLAG
      - PRESERVE_AND_APPEND
    conflicts_with: []
    requires: []
    triggers: [issue-operations]
    source: "080-code-standards.md §Preserve Existing Bylines"

  - id: code-standards-003
    tier: 3
    title: "No re-exports in __init__.py"
    conditions:
      all:
        - "init_py_modified == true"
        - "imports_or_all_added == true"
    actions:
      - FLAG
    conflicts_with: []
    requires: []
    triggers: []
    source: "080-code-standards.md §Design Principles — No Re-exports"

  - id: code-standards-004
    tier: 2
    title: "Behavioral enforcement test required for guideline/skill changes"
    conditions:
      all:
        - "guideline_or_skill_file_changed == true"
        - "behavioral_test_exists == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "080-code-standards.md §Enforcement Test Mandate"

  - id: code-standards-005
    tier: 2
    title: "Behavioral RED before GREEN for rule changes"
    conditions:
      all:
        - "rule_change_being_implemented == true"
        - "behavioral_test_was_RED_first == false"
    actions:
      - HALT
    conflicts_with: []
    requires: [code-standards-004]
    triggers: []
    source: "080-code-standards.md §Behavioral RED/GREEN as Primary Enforcement Gate"

  - id: code-standards-006
    tier: 3
    title: "Natural counting for numbered lists — no zero-indexing"
    conditions:
      all:
        - "new_documentation_created == true"
        - "uses_zero_indexed_numbering == true"
    actions:
      - FLAG
    conflicts_with: []
    requires: []
    triggers: []
    source: "080-code-standards.md §Numbering — ENFORCED"

  - id: code-standards-007
    tier: 3
    title: "Python tools must not be run on non-Python files"
    conditions:
      all:
        - "ruff_or_pyright_on_markdown == true"
    actions:
      - FLAG
    conflicts_with: []
    requires: []
    triggers: []
    source: "080-code-standards.md §Tool Selection by File Type"

  - id: code-standards-008
    tier: 2
    title: "SC-to-test traceability mandatory"
    conditions:
      all:
        - "spec_has_success_criteria == true"
        - "behavioral_test_references_SC == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [spec-creation]
    source: "080-code-standards.md §SC-to-Test Traceability"

  - id: code-standards-009
    tier: 3
    title: "No print statements for narration or self-signaling"
    conditions:
      all:
        - "agent_adding_print_statement == true"
        - "print_purpose == 'feature_narration'"
    actions:
      - FLAG
    conflicts_with: []
    requires: []
    triggers: []
    source: "080-code-standards.md §Print Statements & Output"

  - id: code-standards-010
    tier: 3
    title: "Use f-strings for string interpolation"
    conditions:
      all:
        - "string_interpolation_method == '.format'"
    actions:
      - FLAG
    conflicts_with: []
    requires: []
    triggers: []
    source: "080-code-standards.md §Modern Python"

  - id: code-standards-011
    tier: 3
    title: "Use pathlib.Path for file operations"
    conditions:
      all:
        - "file_operation_method == 'os.path'"
    actions:
      - FLAG
    conflicts_with: []
    requires: []
    triggers: []
    source: "080-code-standards.md §Modern Python"

  - id: code-standards-012
    tier: 3
    title: "Docstring determinism — no ambiguous hedge phrases"
    conditions:
      all:
        - "docstring_contains_ambiguous_phrase == true"
    actions:
      - FLAG
    conflicts_with: []
    requires: []
    triggers: []
    source: "080-code-standards.md §Design Principles"

  - id: code-standards-013
    tier: 3
    title: "Use stable labels over positional index numbers"
    conditions:
      all:
        - "structured_artifact_referenced_by_index == true"
    actions:
      - FLAG
    conflicts_with: []
    requires: []
    triggers: []
    source: "080-code-standards.md §Design Principles"

  - id: code-standards-014
    tier: 3
    title: "Top-level docstring or comment in every source file"
    conditions:
      all:
        - "source_file_created == true"
        - "module_docstring_missing == true"
    actions:
      - FLAG
    conflicts_with: []
    requires: []
    triggers: []
    source: "080-code-standards.md §Design Principles"

  - id: code-standards-015
    tier: 3
    title: "Cross-references use stable anchors, not line numbers"
    conditions:
      all:
        - "documentation_uses_line_number_reference == true"
    actions:
      - FLAG
    conflicts_with: []
    requires: []
    triggers: []
    source: "080-code-standards.md §Cross-Reference Standards"

  - id: code-standards-016
    tier: 2
    title: "Functional/Behavioral test substitution is prohibited when test cannot execute"
    conditions:
      all:
        - "behavioral_or_functional_test_cannot_execute == true"
        - "structural_substitute_reported_as_pass_or_unverified == true"
    actions:
      - HALT
      - REPORT_FAIL
    conflicts_with: []
    requires: []
    triggers: [verification-before-completion]
    source: "080-code-standards.md §Enforcement Test Mandate"

  - id: code-standards-016a
    tier: 2
    title: "EVIDENCE_TYPE_MISMATCH — structural evidence for behavioral SC is a hard FAIL"
    conditions:
      all:
        - "sc_evidence_type == 'behavioral'"
        - "actual_evidence_type in ['structural', 'string']"
        - "verdict_reported_as == 'PASS'"
    actions:
      - HALT
      - DOWNGRADE_TO_FAIL
      - CLASSIFY_AS_EVIDENCE_TYPE_MISMATCH
    conflicts_with: []
    requires: [critical-rules-020, critical-rules-060]
    triggers: [verification-before-completion, audit]
    source: "080-code-standards.md §Evidence Type Taxonomy"

  - id: code-standards-017
    tier: 2
    title: "\"Artifact generated\" is NOT a valid PASS verdict for behavioral SCs"
    conditions:
      all:
        - "sc_evidence_type == 'behavioral'"
        - "verdict_basis == 'artifact_generated'"
        - "clean_room_evaluation_performed == false"
    actions:
      - HALT
      - REQUIRE_CLEAN_ROOM_EVALUATION
    conflicts_with: [code-standards-016a]
    requires: []
    triggers: [verification-before-completion]
    source: "080-code-standards.md §Rule 6"
```
