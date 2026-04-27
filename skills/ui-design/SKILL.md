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
design:
  status: DONE | DONE_WITH_CONCERNS | OVERFLOW | BLOCKED
  artifacts: [list of file paths relative to worktree]
  summary: string
  concerns: string (empty if none)

wireframe:
  status: DONE | DONE_WITH_CONCERNS | OVERFLOW | BLOCKED
  artifact_path: string (relative to worktree)
  summary: string
  concerns: string (empty if none)

mockup:
  status: DONE | DONE_WITH_CONCERNS | OVERFLOW | BLOCKED
  artifact_path: string (relative to worktree)
  summary: string
  concerns: string (empty if none)

interaction-spec:
  status: DONE | DONE_WITH_CONCERNS | OVERFLOW | BLOCKED
  artifact_path: string (relative to worktree)
  summary: string
  concerns: string (empty if none)

screenshot:
  status: DONE | DONE_WITH_CONCERNS | OVERFLOW | BLOCKED
  artifact_path: string (relative to worktree)
  summary: string
  concerns: string (empty if none)

review:
  status: PASS | CONCERNS | FAIL
  findings: [list of {severity, description, recommendation}]
  summary: string

completion:
  status: DONE
  cleaned_up: [list of temp resources cleaned]
  summary: string
```

## Invocation

```
/skill ui-design --task design
/skill ui-design --task wireframe
/skill ui-design --task mockup
/skill ui-design --task interaction-spec
/skill ui-design --task screenshot
/skill ui-design --task review
/skill ui-design --task completion
```

Dispatch context for sub-agents MUST include: `worktree.path`, `github.owner`, `github.repo`, `dev.name`, `dev.email`, plus any spec or context parameters relevant to the task.

## Operating Protocol

1. **Load spec/context before designing.** Read the relevant spec issue, plan, and any referenced context files before producing any design artifact.
2. **Produce toolkit-agnostic artifacts only.** Wireframes use SVG, mockups use HTML+CSS, interaction specs use YAML per `interaction_spec_schema.yaml`. No framework-specific markup, classes, or patterns.
3. **Never reference specific UI frameworks in design artifacts.** Artifacts must not contain Streamlit, React, Vue, Godot, Flutter, Android, or any other framework-specific terminology. Framework binding is `ui-engineer`'s responsibility.
4. **Use PEP 723 scripts from `scripts/` for rendering and validation.** Call `render_svg_to_png.py`, `render_html_screenshot.py`, `validate_svg.py`, `validate_interaction_spec.py`, etc. via `uv run --script` — never install dependencies globally.
5. **Completion guarantee.** Every task invocation MUST end with the `completion` subtask to clean up temporary resources and produce a final summary. The `completion` task is idempotent and safe to invoke multiple times.

## Trigger Self-Identification (Three Tiers)

### Tier 1: Intelligence (Context Inference)

When the context involves designing screens, layouts, navigation structures, component relationships, or visual hierarchies, and no other skill is more specific, `ui-design` should activate.

### Tier 2: Keyword-Enhanced

- Issue body contains `[UI]` label or `requires-ui: true` field
- Plan phase mentions "wireframe", "mockup", "interaction spec", "visual layout"
- Spec includes UI-related success criteria

### Tier 3: Direct

- `/skill ui-design` explicit invocation
- `--task <task-name>` explicit task selection

## Model Assignment

| Task | Model | Rationale |
|------|-------|-----------|
| All tasks | `kimi-k2.6:cloud` | Strong visual design reasoning, good at structured output |

## Cross-References

- **`ui-engineer`**: Consumes `ui-design` artifacts and binds them to a specific UI framework. The handoff point is the interaction spec and wireframe/mockup files.
- **`divide-and-conquer`**: Dispatches `ui-design` as a sub-agent via `assemble-work` when the plan includes UI design phases.
- **`issue-operations`**: Used for posting progress comments and linking design artifacts to issues.
- **`verification-before-completion`**: Validates design artifacts against spec success criteria before marking the phase complete.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: ui-design-001
    title: "Design artifacts MUST be verified against spec requirements"
    conditions:
      all:
        - "design_artifact_produced == true"
        - "spec_requirements_verified == false"
    actions:
      - INVOKE(review)
    conflicts_with: []
    requires: []
    triggers: [verification-before-completion]
    source: "ui-design/SKILL.md §Operating Protocol"

  - id: ui-design-002
    title: "Design artifacts MUST be toolkit-agnostic — no framework-specific markup"
    conditions:
      all:
        - "design_artifact_produced == true"
        - "contains_framework_specific_markup == true"
    actions:
      - REMOVE_FRAMEWORK_MARKUP
    conflicts_with: []
    requires: []
    triggers: []
    source: "ui-design/SKILL.md §Operating Protocol"

tasks:
  - id: wireframe
    skill: ui-design
    preconditions:
      - "spec_or_context_loaded == true"
    postconditions:
      - "svg_wireframe_produced == true"
      - "framework_agnostic == true"
    mandatory: false
    bypass_violation: "wireframe contains framework-specific markup"
    source: "ui-design/SKILL.md §Sub-Agent Tasks"

  - id: mockup
    skill: ui-design
    preconditions:
      - "spec_or_context_loaded == true"
    postconditions:
      - "html_css_mockup_produced == true"
      - "framework_agnostic == true"
    mandatory: false
    bypass_violation: "mockup contains framework-specific markup"
    source: "ui-design/SKILL.md §Sub-Agent Tasks"

  - id: interaction-spec
    skill: ui-design
    preconditions:
      - "spec_or_context_loaded == true"
    postconditions:
      - "yaml_interaction_spec_produced == true"
      - "navigation_routes_defined == true"
      - "component_states_defined == true"
      - "accessibility_requirements_defined == true"
    mandatory: false
    bypass_violation: "interaction spec missing required sections"
    source: "ui-design/SKILL.md §Sub-Agent Tasks"

decomposition: []
gates:
  - id: spec-verification-gate
    type: postcondition
    check: "design artifacts verified against spec success criteria"
    on_fail: INVOKE(review)
    source: "ui-design/SKILL.md §Operating Protocol"
evidence_artifacts:
  - "wireframe.svg file path"
  - "mockup.html file path"
  - "interaction-spec.yaml file path"
  - "review task findings"
```