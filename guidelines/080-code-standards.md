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
- **Pipeline Rerun Constraint**: Changes to data processing pipelines that affect extracted metadata require a full
  pipeline rerun — performed by the user, not the agent. A change **affects extracted metadata** if it alters the
  values, presence, or format of any field written to the database or output files. Agent MUST NOT write DB
  remediation, backfill, or migration code to compensate for pipeline changes; the pipeline rerun handles data
  consistency. Flag the rerun requirement to the user after making such changes. Redundant "safety-net" updates
  in downstream processing steps prohibited.

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
  - All imports must reference concrete module paths (e.g., `from project.module import ClassName`, NOT `from project import ClassName`).
  - Rationale: Re-exports break IDE "Find Usages" and "Go to Definition" by creating false source locations.
  - Existing `__all__` entries in legacy files are assumed approved — do not remove them without explicit instruction.
  - When creating a NEW `__init__.py`, it must be docstring-only. When editing an existing `__init__.py`, do not add any imports or `__all__` entries.
- **Top-Level Documentation**: Every Python source file must include a brief top-level comment identifying the package's or class's purpose. Use a module docstring (preferred) or a leading `#` comment. Keep it to one or two concise sentences — enough for the project's tooling to display alongside the filename.
- **Docstring/Comment Determinism**: Pydoc/docstrings and code comments must use deterministic wording. Avoid ambiguous hedge/alternative phrasing such as `maybe`, `if ... or ...`, `and/or`, or `A + B or C` when describing required behavior, validation paths, or implementation intent.
- **Labels Over Index Numbers**: When editing structured artifacts (notebooks, migration lists, cell arrays, ordered configs), add and use stable labels/names so that inserts, deletes, and moves which change index numbers do not cause edit failures. Reference items by label, not by positional index.
- **Derivation Provenance**: Every element in agent output must trace to a specific consumer or first-principles derivation. Read [§critical-rules-XXX](000-critical-rules.md). "Because it's there in the other location" is not a valid justification.

## Modern Python

- **Pathlib**: `pathlib.Path` exclusively for file/dir ops. No `os.path.join`, `os.mkdir`, string concatenation. Use `/`
  operator.
- **f-strings**: For all string interpolation. No `.format()` or `%` unless required by external libs.
- **Metadata Integrity**: Use `shutil.copy2` (not `shutil.copy`). Never discard metadata unless explicitly instructed.

## Libraries & Packages

- Use domain-appropriate libraries for specialized tasks — no regex for NLP. NLP tasks include tokenization, stemming,
  lemmatization, part-of-speech tagging, named entity recognition, and sentence segmentation. Simple pattern matching
  or fixed-format extraction does not qualify and may use regex. For tasks requiring complex pattern logic beyond
  simple fixed-format extraction, prefer FSM or LALR-type grammars (e.g., `lark`, `pyparsing`) over regex — regex is
  brittle on live data.
- All DB/system ops use existing project libraries. Direct data file manipulation prohibited unless instructed.
- Use project-provided abstractions for all data file paths — never hardcode or assume data file locations.

## Dependency Injection

- **What DI is**: Dependency Injection (DI) is the pattern of supplying a component's dependencies from outside (via a container or explicit wiring) rather than having the component construct them itself. A service receives its collaborators as constructor or setter inputs instead of instantiating them internally.
- **Why it is required**: DI decouples a class from its dependencies, making it easy to test (swap real collaborators for fakes), refactor, and reason about. Components that construct their own dependencies are tightly coupled, hard to test in isolation, and resist change. DI is required so services remain easy to test and refactor.
- **Mandated library**: Use `dependency-injector` for all dependency wiring. Do not hand-roll DI containers, use ad-hoc module-level singletons, or wire dependencies through arbitrary parameter passing. Structure wiring through an `Injector`/`Container` from `dependency-injector`, with providers declared for each dependency.
- **Usage patterns**: Declare a container class that registers each dependency as a provider (e.g., `ConfigProvider`, `SecretsProvider`) and wires them into the service and its callers. Services declare their dependencies in their constructor; the container supplies them at composition time. Follow the container-first pattern — define the wiring graph once in the container and let the container resolve dependencies for all consumers.
- **Carveout for `.opencode/` infrastructure tools**: The DI mandate applies to application/service code only. It does NOT apply to infrastructure tooling under `.opencode/`. Scripts and tools in `.opencode/tools/`, `.opencode/scripts/`, and `.opencode/skills/*/scripts/` are exempt — they may use simple, direct wiring appropriate to their scope.

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
uvx ruff check <source_dir>/ <test_dir>/              # Lint (advisory)
uvx ruff format --check <source_dir>/ <test_dir>/     # Format check (advisory)
uvx pyright <source_dir>/                       # Type check
uvx vulture <source_dir>/                       # Dead code scan
```

**Markdown files (`.md`):**

```bash
uvx pymarkdownlnt scan -r <guidelines_dir>/ <docs_dir>/   # Lint
uvx mdformat --check <guidelines_dir>/ <docs_dir>/        # Format check (advisory)
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

## Enforcement Test Mandate

Read [the Enforcement Test Mandate in test-driven-development/SKILL.md](skills/test-driven-development/SKILL.md).

## Cross-Reference Standards

**Cross-references in specs, issues, and documentation MUST use stable anchors, NOT line numbers.**

### Required Format

| Reference Type | Format | Example |
| -- | -- | -- |
| Function | `file.py` `function_name()` | `process_data()` in `data_client.py` |
| Class | `file.py` `ClassName` | `DataValidator` in `validator.py` |
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

## YAML Standard for LLM-to-LLM Data Transfers

All structured data exchanged between AI agents (result contracts, work state files, task context, evidence artifacts) MUST use YAML format. JSON is prohibited for LLM-to-LLM communication.

**Exceptions:**
- External API calls (GitHub API, GitBucket API)
- Configuration files that require JSON (`opencode.jsonc`)
- Data interchange with non-LLM systems

**Rationale:** YAML is more readable for AI agents in multi-line contexts. JSON is error-prone when embedded in agent prompts due to brace/quote escaping issues.

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

### [critical-rules-009] Enforcement Test Updates — guideline/skill changes without BEHAVIORAL enforcement tests
Adding a guideline or skill change without a BEHAVIORAL enforcement test means you are documenting, not enforcing — and documentation without enforcement is decoration. Every guideline and skill change that lacks a behavioral enforcement test is a suggestion, not a rule. Suggestions get ignored by the agents that need them most. Professional engineers ship behavioral tests with every rule change.


### [critical-rules-042] Model-Aware Clean-Room task() for Behavioral Testing
Running behavioral tests through grep and static analysis instead of `opencode run` means you are testing the wrong thing — text patterns, not agent behavior. Professional engineers test against real AI models in clean-room isolation. Amateurs grep for keywords and call it verified.


### [critical-rules-test-integrity] Test Integrity Mandate — No Lobotomizing Tests

Removing or weakening a behavioral (semantic, functional) test assertion to work around a timeout, failure, or infrastructure issue is the most expensive defect you can introduce. A lobotomized test passes by removing the signal it was designed to produce — producing a false PASS that masks a real defect.

**Read [test-driven-development/SKILL.md §Test Integrity Mandate](skills/test-driven-development/SKILL.md). Key provisions:**

- **Rule 1**: Removing or weakening behavioral assertions is a CRITICAL VIOLATION — equivalent to soft-passing a verification mismatch
- **Rule 2**: Timeout is always diagnosable — never assume model unavailability without tool-call evidence
- **Rule 3**: Research sub-agents for test infrastructure problems — mandatory after 2+ remediation failures
- **Rule 4**: FAIL is a hard gate — never proceed past FAIL. Only valid outcomes: PASS, FAIL (remediate and re-run), or INCONCLUSIVE after exhaustive remediation (escalate only)


### [critical-rules-BEH-EV] Runtime-Behavioral Evidence Classification Gate — structural evidence for behavioral changes is EVIDENCE_TYPE_MISMATCH

The question "does this change affect runtime behavior?" is substrate-determined — the change either alters runtime behavior or it does not. Intent, author assertion, and hope are irrelevant. When the answer is YES, submitting structural or string evidence is EVIDENCE_TYPE_MISMATCH, not a soft downgrade. The verdict is FAIL. No advisory, no "PASS with structural caveat," no INCONCLUSIVE. The classification gate enforces what the evidence type taxonomy already requires: behavioral changes demand behavioral evidence.

Runtime behavior includes: agent dispatch decisions, enforcement gate outcomes, tool selection, pipeline routing, conditional branching, test execution results, and any observable system output. A change that modifies WHAT a system DOES at runtime — as opposed to what it CONTAINS statically — is a runtime-behavioral change.

The uplift is automatic. Declaring an SC as `structural` or `string` does not exempt it from behavioral evidence requirements when the underlying change affects runtime behavior. Evidence type is determined by what the change DOES, not by what the author declares. A `string` SC that tests a runtime-behavioral change is automatically uplifted to `behavioral` — the declared type is overridden by the substrate classification.

🚫 FORBIDDEN:
- Submitting structural or string evidence for a runtime-behavioral change and reporting PASS
- Declaring an SC as `structural` to avoid behavioral testing when the change affects runtime behavior
- Classifying the evidence type question as intent-determined ("what did the author mean?") instead of substrate-determined ("does this change affect runtime behavior?")
- Producing an advisory or INCONCLUSIVE verdict when EVIDENCE_TYPE_MISMATCH is detected

✅ REQUIRED:
- Classify the change question as substrate-determined: "Does this change affect runtime behavior? YES/NO"
- When YES: automatically uplift declared evidence type to `behavioral` regardless of author declaration
- When the declared type is `structural` or `string` but the change is runtime-behavioral: report EVIDENCE_TYPE_MISMATCH with a FAIL verdict
- Apply the same remediation-first protocol as all hard failures: diagnose, remediate, re-verify

Authority sources: Read [test-driven-development/SKILL.md §Evidence Type Taxonomy](skills/test-driven-development/SKILL.md), Read [test-driven-development/SKILL.md §Test Integrity Mandate](skills/test-driven-development/SKILL.md), Read [020-go-prohibitions.md §1 ALWAYS DO — Cost-blind verification](guidelines/020-go-prohibitions.md). Read [065-verification-honesty.md](guidelines/065-verification-honesty.md) §Cost Model for the death-spiral cost rationale underlying this classification gate — automatic uplift from structural→behavioral prevents the death spiral at the earliest possible gate.


### [critical-rules-XXX] Derivation Provenance — every element must have a consumer or first-principles justification

Adding a parameter, field, method, class, configuration key, contract entry, routing scope variable, or code block whose sole justification is "it exists in another location" is a process-integrity failure. Every element must trace to:

1. A specific consumer (task file, function call, code path) that reads or branches on it, OR
2. A first-principles derivation from the problem statement, spec SC, or requirements

"Because it's there in the other file/service/spec/plan" is NOT a valid justification.

#### Applies to ALL agent output

| Artifact Type | Examples of Cargo Cult | Correct Pattern |
|---------------|----------------------|-----------------|
| Code (Java, Python, etc.) | Copying method params, imports, class structure from another file | Derive from consumer callsites or API contract |
| Specs | Adding contract fields without identifying consuming task file | Each field must name at least one consumer |
| Plans | Applying three-tier phase structure without evaluating fit | Derive phase structure from spec SCs |
| Contracts | Propagating fields through dispatch pipelines with no reader | Field without consumer = dead weight |
| Routing tables | Adding scope variables no sub-agent branches on | Each scope variable must be read by ≥1 task file |
| Config files | Copying keys from another environment without verifying consumer | Each key must be read by at least one code path |

#### Remediation

When a derivation-provenance violation is detected (by the agent during self-review, or by an auditor):
- Remove the unjustified element
- If the element is needed, identify the consumer or first-principles derivation
- Do NOT add a placeholder consumer to satisfy the rule — the consumer must be real

#### Why This Matters

| Violation Pattern | Consequence |
|-------------------|-------------|
| Adding contract field without consumer | Dead weight in every dispatch — context overhead with zero behavioral effect |
| Copying method params from reference class | Wrong parameter set for the new domain — produces incorrect API |
| Propagating routing scope variable no task reads | Every sub-agent receives unused context — routing complexity with no benefit |
| Applying template structure without evaluation | Every artifact looks the same regardless of problem shape — misses domain-specific concerns |

Rules that prevent **inconsistency or tech debt**: naming conventions, numbering, comment style, tool selection. Violations are flagged but do not halt.
### Tier 3 — Workflow-Standard (FLAG — Convention/Consistency)

### [critical-rules-023] Missing AI Co-Authored Attribution
Format: `Co-authored with AI: <AgentName> (<ModelId>)`. Read [080-code-standards.md](guidelines/080-code-standards.md).


### [critical-rules-023] Hardcoded Identity Values in Skills and Guidelines
Use `<AgentName>`, `<ModelId>`, `<github.owner>` placeholders. Read [080-code-standards.md](guidelines/080-code-standards.md).


### [critical-rules-023] Posting AI-Authored Content Without Byline Verification
Verify byline presence before ANY API call posting AI-authored content.


### [critical-rules-060] Functional/Behavioral Test Substitution Prohibition — substituting structural/grep/metadata checks when behavioral tests cannot execute

"Functional test" and "behavioral test" are synonymous — both verify actual agent behavior by executing code and observing output. When a behavioral/functional test CANNOT be executed (model unavailable, timeout, infrastructure failure, `opencode` not installed), the ONLY valid outcome is FAIL. The agent MUST NEVER substitute grep, string matching, metadata checks, pattern scanning, or file-existence checks for behavioral/functional test execution.

#### Authority Sources

- Read [080-code-standards.md §Terminology Note](guidelines/080-code-standards.md) — functional test and behavioral test are synonymous
- Read [test-driven-development/SKILL.md §Behavioral RED/GREEN gate](skills/test-driven-development/SKILL.md) — behavioral evidence is PRIMARY
- Read [020-go-prohibitions.md §1 ALWAYS DO — Cost-blind verification](guidelines/020-go-prohibitions.md): substitution is forbidden
- Read [skills/verification-before-completion/tasks/verify.md §"When Behavioral/Functional Tests Cannot Execute"](skills/verification-before-completion/tasks/verify.md) — FAIL is the only valid outcome when the test cannot run

#### Forbidden Substitutions
- Grep/string matching/pattern scanning as behavioral evidence
- Metadata checks (file existence, label state, PR merge status) as behavioral evidence
- File-existence checks as behavioral evidence
- "Spot-checking" as behavioral test substitute
- Any structural check reported as PASS for a behavioral SC

#### Required Actions
1. When a behavioral/functional test cannot execute: report FAIL with explanation
2. Attempt remediation (alternative model selection, infrastructure check)
3. Exhaustive remediation before escalation: only after ALL available model selection, infrastructure check, and alternative model paths have been verified as failed may the agent HALT with escalation
4. There is NO valid path from "test cannot run" to "PASS" or "UNVERIFIED with structural substitute"


