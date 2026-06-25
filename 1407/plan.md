# Plan: Phase 1 — Define Canonical SKILL.md Routing-Only Template

**Issue:** [#1407](https://github.com/michael-conrad/.opencode/issues/1407)
**Phase:** 1 of 6
**Scope:** Template definition, generator update, reference update

## Items (Dependency Order)

### Item 1: Create routing-only SKILL.md template

Create `.opencode/skills/skill-creator/reference/routing-only-template.md` with the canonical structure:

- YAML frontmatter (`name`, `description`, `license`, `provenance`)
- Overview (1-2 sentences, no procedure)
- Mandatory Task Discipline (5-item checkbox list, matching `skill-card-spec.md` SKILL.md variant)
- Trigger Dispatch Table (checkbox list format with sub-items)
- Invocation (canonical `skill()` + `task()` strings)
- Sub-Agent Routing (routing rules)
- Cross-References
- Symbolic rules (if any)

**Success criteria:**
- Template contains NO procedure text (no step definitions, no entry/exit criteria, no code snippets, no "Operating Protocol", no "Procedure" sections)
- Template contains NO "Structuring This Skill", "Measurement Standard", "Context Window Hygiene", "Correctness-First Economics", or "Resources" sections
- Template uses the Trigger Dispatch Table format from the spec: `- [ ] **"trigger phrase"** → \`task-name\` (dispatch-type)` with sub-bullets for Context and Task file
- Template uses the Mandatory Task Discipline block from `skill-card-spec.md` (5-item SKILL.md variant)
- Template is compliant with opencode.ai frontmatter requirements (only `name` required, `description` required, `license` optional)

### Item 2: Update `init_skill.py` to generate routing-only SKILL.md

Replace the `SKILL_TEMPLATE` constant in `.opencode/skills/skill-creator/scripts/init_skill.py` with a routing-only template matching the structure from Item 1.

**Success criteria:**
- Generated SKILL.md contains only: frontmatter, Overview, Mandatory Task Discipline, Trigger Dispatch Table, Invocation, Sub-Agent Routing, Cross-References
- Generated SKILL.md does NOT contain: "Structuring This Skill", "Measurement Standard", "Context Window Hygiene", "Correctness-First Economics", "Resources" sections
- Generated SKILL.md does NOT contain procedure text, step definitions, or code snippets
- Generated SKILL.md uses the Trigger Dispatch Table format from the spec
- Generated SKILL.md uses the Mandatory Task Discipline block from `skill-card-spec.md`
- The `init_skill.py` script still creates `scripts/`, `references/`, and `assets/` directories (those are resource scaffolding, not SKILL.md content)

### Item 3: Update `skill-card-spec.md` to reference routing-only template

Add a reference in `.opencode/skills/skill-creator/reference/skill-card-spec.md` pointing to the new `routing-only-template.md` as the canonical SKILL.md structure.

**Success criteria:**
- `skill-card-spec.md` contains a cross-reference to `routing-only-template.md`
- The reference explains when to use the routing-only template (all new skills) vs. the existing card spec (task cards only)
- No existing content in `skill-card-spec.md` is removed — only the reference is added
