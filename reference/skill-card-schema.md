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

## Description Pattern (Observed Across All 40 Cards)

Every SKILL.md in this repository uses the same description structure. This is a project convention, not a binary constraint, but it is universally followed:

```
"<Noun phrase> that <verb phrase>. Dispatch when <trigger conditions>. Also dispatch when <additional conditions>. <Context/qualification>. User phrases: <comma-separated trigger phrases>."
```

### Structural Elements

| Element | Example | Required? |
|---------|---------|-----------|
| **Noun phrase identity** | "Authorization gatekeeper that verifies scope..." | Yes |
| **"Dispatch when" clause** | "Dispatch when creating a branch, committing, pushing..." | Yes |
| **"Also dispatch when" clauses** | "Also dispatch when verifying authorization state..." | Optional |
| **Context/qualification** | "All conditions are MANDATORY — no implementation without authorization." | Optional |
| **"User phrases:" clause** | "User phrases: create branch, commit, push, create PR..." | Yes |

### Examples

**Valid (from `approval-gate/SKILL.md`):**

```yaml
description: "Authorization gatekeeper that verifies scope, cascade, and halt boundaries. Dispatch when checking or enforcing authorization scope, approval cascade, pipeline halt boundaries, label application, spec-to-plan cascade, revision revocation, or bug discovery protocol. Also dispatch when verifying authorization state, applying approved-for-* labels, or handling re-implementation after spec revision. All conditions are MANDATORY — no implementation without authorization. User phrases: check authorization, verify scope, enforce cascade, apply label, approve, go, authorized, revision revokes approval, bug discovery protocol."
```

**Valid (from `git-workflow/SKILL.md`):**

```yaml
description: "Git branch, commit, push, and PR workflow manager with cleanup and provenance tracking. Dispatch when creating a branch, committing, pushing, or creating a PR. Also dispatch when handling rebase/merge conflicts (invoke conflict-resolution), checking PR state and cleanup, or running provenance tracking. Branch-and-PR discipline is REQUIRED — always follow the workflow. User phrases: create branch, commit, push, create PR, rebase, merge, check pr, check prs, check merged prs, pr merged, provenance, sync submodules, release PR."
```

**Valid (from `spec-creation/SKILL.md`):**

```yaml
description: "Specification authoring skill that decomposes problems into success criteria and documents requirements. Dispatch when creating a spec, writing a specification, drafting requirements, authoring a spec document, or specifying a feature. Also dispatch when decomposing a problem into success criteria, extracting requirements, or documenting change control. Also use when running holistic self-checks on specs before completion, or verifying spec quality against the 11-dimension holistic gate. Invoke for: holistic check, self-check, pre-completion check, spec quality verification. Spec creation is REQUIRED before implementation. User phrases: write spec, create spec, draft spec, write specification, create specification, draft specification, spec out, author spec, document requirements, specify feature, define success criteria, extract requirements, holistic check, spec quality verification."
```

---

## Project Conventions (Advisory)

These conventions are followed by all cards in this repository but are **not enforced by the binary**. They are project-level quality standards.

### `DISPATCH_GATE` Section

Every SKILL.md body includes a `DISPATCH_GATE` section documenting the sub-agent dispatch protocol, orchestrator entry criteria, and preloaded-context rejection rules.

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
description: "Noun phrase that verb phrase. Dispatch when trigger. User phrases: trigger."
---
```

## Valid Frontmatter (Full — Project Standard)

```yaml
---
name: my-skill
description: "Noun phrase that verb phrase. Dispatch when trigger. Also dispatch when additional. Context. User phrases: trigger1, trigger2, trigger3."
license: MIT
compatibility: opencode
---
```

---

## References

- **Binary schema (authoritative):** https://opencode.ai/docs/skills
- **Project skill cards:** `.opencode/skills/*/SKILL.md`
- **Change type taxonomy:** `.opencode/skills/reference/skill-card-change-types.md`
