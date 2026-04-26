# Planning: Spec Structure Requirements

## Spec File Format

**All specs use GitHub Issues as the authoritative source.**

For archive and closure workflow, see the `git-workflow` skill `cleanup` task.

______________________________________________________________________

## 6. Spec Structure Requirements

### Two Workflow Stages

**Stage 1: Investigation & Planning (CRITICAL CHECKPOINT)**

- Investigation phases: **MANDATORY** research, analysis, exploration — MUST complete before spec creation
- Planning phases: design, architecture, breakdown — MUST complete before spec creation
- **These are HARD GATES — not automatic, not optional**
- **A spec cannot be finalized without completed investigation and planning**
- **NOT included in the spec file — but VERIFIED before proceeding**

#### Investigation Tools and Methods

During investigation, the agent MAY:

| Activity | Allowed? | Notes |
| -- | -- | -- |
| Read production code | ✅ YES | Read-only exploration |
| Read production data | ✅ YES | Read-only analysis |
| Create test scripts in `./tmp/` | ✅ YES | Isolated from production |
| Run test scripts in `./tmp/` | ✅ YES | No production impact |
| Create isolated test fixtures | ✅ YES | Dedicated test databases/schemas |
| Run static analysis (lint, typecheck) | ✅ YES | Code verification |
| Modify production code | 🚫 NO | Requires approved spec |
| Modify production data | 🚫 NO | Requires approved spec |
| Run code against production DB | 🚫 NO | Requires explicit user authorization |

**Test Scripts for Investigation:**

Test code created during investigation MUST:

- Be placed in `./tmp/` directory only
- Use isolated test fixtures (dedicated test DB, test schemas)
- NOT modify production code, data, or systems
- Be deleted after investigation completes (temp artifacts)

**Example Permissible Investigation:**

```python
# ✅ ALLOWED: Create test script to validate hypothesis
# File: ./tmp/test_mesh_lookup.py

from commons.mesh.validator import MeshValidator

# Use test fixture, NOT production
validator = MeshValidator(test_mode=True)
result = validator.lookup_term("coronary artery disease")
print(f"Validation result: {result}")
```

#### Investigation Completion Criteria

Before creating a spec, the agent MUST verify:

| Requirement | Evidence |
| -- | -- |
| Problem understood | Clearly stated problem, context, stakeholders |
| Codebase explored | Existing patterns, reusable components identified |
| Hypotheses tested | Test scripts run, results documented |
| Alternatives considered | At least 2 approaches documented with tradeoffs |
| Risks identified | Risk assessment with mitigation strategies |
| Success criteria defined | Testable, measurable completion criteria |

#### 🚫 CRITICAL VIOLATION: Spec Without Investigation

Creating a spec without completed investigation is a CRITICAL GUIDELINE VIOLATION:

- **PROHIBITED**: Creating specs from vague requirements without exploration
- **PROHIBITED**: Skipping codebase analysis before planning
- **PROHIBITED**: Finalizing specs before investigating edge cases
- **PROHIBITED**: Proceeding without success criteria defined
- **PROHIBITED**: Running test code against production systems

#### ✅ ALLOWED During Investigation

- **ALLOWED**: Creating `./tmp/` test scripts to validate hypotheses
- **ALLOWED**: Running isolated test fixtures
- **ALLOWED**: Static analysis (lint, typecheck) on production code
- **ALLOWED**: Read-only exploration of production code and data
- **ALLOWED**: Documenting findings for the spec

**Stage 2: Requires Approval (In Spec)**

- Implementation phases: build, code, integrate
- Verification phases: test, review, validate
- Completion phases: ship, deploy
- **These appear in the spec with numbered phases/steps**

### Spec Template

```markdown
# Spec: [Title]

STATUS: 1.1
CREATED: YYYY-MM-DD

---

## Phase 1: [Concern Name] (Gated)

### Steps
1. ☐ [first task for this concern]
2. ☐ [second task for this concern]
3. ☐ [third task for this concern]

### Content
[Implementation details from planning phase]

---

## Phase 2: [Next Concern] (auto-progress)

### Steps
1. ☐ [first task for this concern]
2. ☐ [second task for this concern]

---

## Phase 3: [Verification Concern] (requires approval)

### Steps
1. ☐ [first review task]
2. ☐ [second review task]

---



**⚠️ CRITICAL: Phase names MUST describe specific concerns, NOT generic activities.**
- ✅ Good: "Database Schema Setup", "API Endpoint Integration", "Error Handling Layer"
- ❌ Bad: "Implementation", "Testing", "Development", "Build"
```

### What NOT to Include in Specs

**DO NOT include:**

- Investigation phases (already done)
- Planning phases (already done)
- Research notes (that was investigation)
- Architecture decisions (that was planning)

The spec starts **AFTER** investigation and planning are complete.

______________________________________________________________________

## 7. Required Elements

Every spec file MUST include:

1. **Title**: `# Spec: [Feature Name]`
2. **STATUS Header**: `STATUS: phase.step` (e.g., `STATUS: 1.2`)
3. **CREATED Date**: `CREATED: YYYY-MM-DD`
4. **Numbered Phases**: Phase 1, Phase 2, Phase 3...
5. **Numbered Steps**: 1, 2, 3 within each phase
6. **Status Markers**: `☐`/`↻`/`☑`/`☒` for each step
7. **Byline Footer**: A footer line with AI attribution: `🤖 <AgentName> (<ModelId>) created`

## 8. Phase Naming Quality (MANDATORY)

**Phase names MUST represent actual separation of concerns, not generic activities.**

### Boilerplate Phase Names (PROHIBITED)

Phase names that describe generic activities without specifying the concern:

- "Implementation" — activity, not concern boundary
- "Testing" — activity, not concern boundary
- "Build" / "Create" / "Develop" — activities, not concerns
- "Verify" / "Validate" / "Check" — activities, not concerns
- "Deploy" / "Ship" / "Release" — activities, not concerns

### Meaningful Phase Names (REQUIRED)

Phase names that describe specific concern boundaries:

- "Database Schema Setup" — specific concern boundary
- "API Endpoint Integration" — specific concern boundary
- "Error Handling Layer" — specific concern boundary
- "Configuration Migration" — specific concern boundary
- "Unit Testing Infrastructure" — specific concern (infrastructure for testing)
- "Integration Testing Suite" — specific concern (integration test setup)

### Validation Rules

| Pattern | Status | Reason |
| -- | -- | -- |
| Single-word activity name | BOILERPLATE-TITLE | No concern boundary specified |
| "Testing" alone | BOILERPLATE-TITLE | Generic activity |
| "Testing Infrastructure" | ACCEPTABLE | Specific concern (infrastructure) |
| "Unit Testing" | ACCEPTABLE | Specific testing type |
| "Implementation" with specific steps | REVIEW | May be acceptable if steps define concern |

### Examples

**❌ BOILERPLATE (Wrong):**

```markdown
## Phase 1: Implementation (Gated)
### Steps
1. ☐ Write the code
2. ☐ Make it work
3. ☐ Fix bugs
```

**✅ MEANINGFUL (Correct):**

```markdown
## Phase 1: Database Schema Setup (Gated)
### Steps
1. ☐ Create user table with authentication fields
2. ☐ Add indexes for login queries
3. ☐ Write migration script
```

______________________________________________________________________

*Source: Content migrated from `040-plan-delivery.md`*

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: spec-structure-001
    title: "Investigation must complete before spec creation"
    conditions:
      all:
        - "action == 'create_spec'"
        - "investigation_complete == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [brainstorming, spec-creation]
    source: "142-planning-archive-workflow.md §6 Stage 1"

  - id: spec-structure-002
    title: "Never modify production code during investigation"
    conditions:
      all:
        - "phase == 'investigation'"
        - "action == 'modify_production_code'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "142-planning-archive-workflow.md §Investigation Tools"

  - id: spec-structure-003
    title: "Never run code against production DB during investigation"
    conditions:
      all:
        - "phase == 'investigation'"
        - "target == 'production_database'"
        - "explicit_user_authorization == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "142-planning-archive-workflow.md §Investigation Tools"

  - id: spec-structure-004
    title: "Spec without investigation is critical violation"
    conditions:
      any:
        - "spec_created_without_exploration == true"
        - "codebase_analysis_skipped == true"
        - "edge_cases_not_investigated == true"
        - "success_criteria_undefined == true"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "142-planning-archive-workflow.md §CRITICAL VIOLATION"

  - id: spec-structure-005
    title: "Spec must not include investigation or planning phases"
    conditions:
      any:
        - "spec_contains == 'investigation_phase'"
        - "spec_contains == 'planning_phase'"
        - "spec_contains == 'research_notes'"
        - "spec_contains == 'architecture_decisions'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [spec-creation]
    source: "142-planning-archive-workflow.md §What NOT to Include"

  - id: spec-structure-006
    title: "Phase names must describe concerns not generic activities"
    conditions:
      all:
        - "phase_name in ['Implementation', 'Testing', 'Build', 'Development', 'Verify', 'Deploy']"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [spec-creation, writing-plans]
    source: "142-planning-archive-workflow.md §8. Phase Naming Quality"

  - id: spec-structure-007
    title: "Every spec must include required elements"
    conditions:
      any:
        - "has_title == false"
        - "has_status_header == false"
        - "has_created_date == false"
        - "has_numbered_phases == false"
        - "has_status_markers == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [spec-creation]
    source: "142-planning-archive-workflow.md §7. Required Elements"
```
