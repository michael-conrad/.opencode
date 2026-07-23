# Skill Card Schema — SKILL.md Frontmatter Reference

**Derived from the opencode binary.** The opencode binary is the authoritative source for frontmatter parsing. This document records observed behavior and project conventions — it does not override the binary.

**Source:** https://opencode.ai/docs/skills

---

## Binary Constraints (Hard-Fail)

These constraints are enforced by the opencode binary. Violations cause the skill to be invisible to agents.

### `name` (required)

| Property | Value |
|----------|-------|
| Required | Yes |
| Length | 1–64 characters |
| Regex | `^[a-z0-9]+(-[a-z0-9]+)*$` |
| Must match | The directory name containing `SKILL.md` |

**Regex breakdown:**
- `^[a-z0-9]+` — starts with one or more lowercase alphanumeric chars
- `(-[a-z0-9]+)*$` — zero or more hyphen-separated segments, each with one or more lowercase alphanumeric chars
- No leading/trailing hyphens, no consecutive hyphens

### `description` (required)

| Property | Value |
|----------|-------|
| Required | Yes |
| Length | 1–1024 characters |

### `license` (optional)

Free-form string. No binary validation beyond YAML parsing.

### `compatibility` (optional)

Free-form string. No binary validation beyond YAML parsing.

### `metadata` (optional)

String-to-string map (`map[string,string]`). No binary validation beyond YAML parsing.

### Unknown Fields

**Ignored.** The binary silently discards unrecognized frontmatter keys. They do not cause errors and do not affect skill loading.

---

## Description Pattern (Agent-Intent Format)

The `description` field is a **semantic router** — the agent evaluates its OWN intent against the description, not the user's literal utterance. The description must describe what the agent needs to DO, not what the user SAYS.

```
"<Agent task description>. <Context/qualification>."
```

### Structural Elements

| Element | Example | Required? |
|---------|---------|-----------|
| **Agent task description** | "Create and validate specification documents with success criteria, evidence types, traceability, and analytical artifacts from requirements and problem statements." | Yes |
| **Context/qualification** | "Spec creation is REQUIRED before implementation." | Optional |

### What to Exclude

| Element | Why Excluded |
|---------|-------------|
| "Load via skill() when..." | Meta-instruction — dilutes the semantic vector. The agent decides when to load. |
| "User phrases: ..." | Describes user utterance, not agent intent. Semantic matching is agent-intent-based. |
| "Dispatch when..." | Same as above — describes trigger conditions, not agent task. |
| "Also dispatch when..." | Same as above. |

### Examples

**Agent-intent format (correct):**

```yaml
description: "Create and validate specification documents with success criteria, evidence types, traceability, and analytical artifacts from requirements and problem statements."
```

```yaml
description: "Verify authorization scope, apply approval labels, handle spec revision revocation, and execute bug discovery protocol. Authorization verification is REQUIRED before any implementation."
```

```yaml
description: "Create and manage git branches, commit changes, push to remote, create pull requests, handle rebase and merge conflicts, and clean up after PR merges."
```

**Deprecated format (do not use):**

```yaml
description: "Authorization gatekeeper that verifies scope, cascade, and halt boundaries. Dispatch when checking or enforcing authorization scope. User phrases: check authorization, verify scope."
```

---

## Project Conventions (Advisory)

These conventions are followed by all cards in this repository but are **not enforced by the binary**. They are project-level quality standards.

### Workflows Section (Replaces Trigger Dispatch Table + Invocation)

Every SKILL.md body uses a **Workflows** section instead of separate Trigger Dispatch Table and Invocation sections. Each workflow is a numbered list of clean-room `task()` dispatch steps. Each step has sub-bullets for the dispatch parameters (Prompt, Context, Returns). This keeps the dispatch contract colocated with the sequencing step.

### `license: MIT` + `compatibility: opencode`

All 40 cards use `license: MIT` and `compatibility: opencode`. These are not binary requirements but are project standards.

### SPDX + Provenance Headers

Cards include SPDX license and provenance headers in the body (not frontmatter):

```markdown
<!-- SPDX-FileCopyrightText: <year> <dev.name> -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->
```

### AI Co-Authored Byline

Cards include a byline in the body:

```markdown
Co-authored with AI: <AgentName> (<ModelId>)
```

---

## Invalid Frontmatter Examples

These would cause the skill to be rejected or invisible:

```yaml
# INVALID: name has uppercase
name: MySkill
description: "Does something."
```

```yaml
# INVALID: name has consecutive hyphens
name: my--skill
description: "Does something."
```

```yaml
# INVALID: name starts with hyphen
name: -my-skill
description: "Does something."
```

```yaml
# INVALID: name does not match directory name
# File is at .opencode/skills/other-name/SKILL.md
name: wrong-name
description: "Does something."
```

```yaml
# INVALID: description too long (>1024 chars)
name: my-skill
description: "A" x 1025
```

```yaml
# INVALID: missing required name
description: "Does something."
```

```yaml
# INVALID: missing required description
name: my-skill
```

---

## Valid Frontmatter (Minimal)

```yaml
---
name: my-skill
description: "Create and validate specification documents with success criteria, evidence types, traceability, and analytical artifacts from requirements and problem statements."
---
```

## Valid Frontmatter (Full — Project Standard)

```yaml
---
name: my-skill
description: "Create and validate specification documents with success criteria, evidence types, traceability, and analytical artifacts from requirements and problem statements."
license: MIT
compatibility: opencode
---
```

---

## References

- **Binary schema (authoritative):** https://opencode.ai/docs/skills
- **Project skill cards:** `.opencode/skills/*/SKILL.md`
- **Change type taxonomy:** `.opencode/skills/reference/skill-card-change-types.md`
