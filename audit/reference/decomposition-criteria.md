<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Decomposition Criteria — Master Reference

> **Maintainer note:** Inline copies of these criteria are maintained in the following files. When this file changes, update ALL three:
> - `spec-creation/tasks/validate.md`
> - `audit/tasks/spec-audit-evaluator.md`
> - `writing-plans/tasks/validate.md`

This file defines the canonical decomposition criteria used across the spec-creation, audit, and writing-plans pipelines. Each criterion includes a binary decision tree with explicit PASS/FAIL branches, trigger-word sub-checks where applicable, and examples.

---

## Spec-Level Criteria

### 1. Atomicity

**Purpose:** Each success criterion (SC) must represent exactly one atomic concern. A non-atomic SC bundles multiple concerns, making it impossible to verify independently.

#### Decision Tree

```
Is the SC a single, indivisible concern?
├── YES → Is it free of coordinating conjunctions (and, or) and comma-separated lists?
│   ├── YES → PASS — SC is atomic
│   └── NO → FAIL — SC contains trigger words indicating multiple concerns
└── NO → FAIL — SC bundles multiple concerns
```

#### Trigger-Word Sub-Check

Flag any SC containing:
- `and` — coordinating conjunction joining two requirements
- `or` — disjunctive alternative (two separate paths)
- Comma-separated lists — enumerating multiple items as one SC

**PASS example:** "The system validates email format on registration."
**FAIL example:** "The system validates email format AND sends confirmation email AND logs the attempt."

---

### 2. Single Deliverable

**Purpose:** Each SC must produce exactly one deliverable (file, function, config change, etc.). An SC that requires changes to multiple files or multiple independent deliverables is not a single item.

#### Decision Tree

```
Does the SC produce exactly one deliverable?
├── YES → Is the deliverable a single file, function, or configuration change?
│   ├── YES → PASS — SC has a single deliverable
│   └── NO → FAIL — SC spans multiple deliverables
└── NO → FAIL — SC produces zero or multiple deliverables
```

**PASS example:** "Create `audit/reference/decomposition-criteria.md` with all 7 criteria headings."
**FAIL example:** "Create the reference file AND update the validation task file AND add a behavioral test."

---

### 3. Binary Verifiability

**Purpose:** Each SC must be verifiable as PASS or FAIL with no gray area. An SC that uses vague terms or disjunctive patterns cannot be verified deterministically.

#### Decision Tree

```
Can the SC be verified as PASS or FAIL with no interpretation?
├── YES → Is the SC free of disjunctive patterns (either/or, alternatively, one of)?
│   ├── YES → Is the SC free of vague terms (should, could, ideally, as appropriate)?
│   │   ├── YES → PASS — SC is binary-verifiable
│   │   └── NO → FAIL — SC contains vague terms
│   └── NO → FAIL — SC contains disjunctive patterns
└── NO → FAIL — SC requires interpretation to verify
```

#### Disjunctive Pattern Sub-Check

Flag any SC containing:
- `either/or` — presents two alternatives as one SC
- `alternatively` — suggests a second path
- `one of` — selects from multiple options

#### Vague Term Sub-Check

Flag any SC containing:
- `should` — aspirational, not mandatory
- `could` — optional, not required
- `ideally` — preference, not specification
- `as appropriate` — subjective judgment required

**PASS example:** "File `audit/reference/decomposition-criteria.md` exists at the expected path."
**FAIL example:** "The system should ideally validate email format or alternatively use a regex pattern as appropriate."

---

### 4. PR-Gate Viability

**Purpose:** Each SC must be deliverable as a single PR that can be reviewed and merged independently. An SC that depends on unreviewed code or spans multiple PR boundaries is not viable.

#### Decision Tree

```
Can the SC be delivered as a single, independently reviewable PR?
├── YES → Does the SC represent a single RED/GREEN cycle?
│   ├── YES → PASS — SC is PR-gate viable
│   └── NO → FAIL — SC spans multiple RED/GREEN cycles
└── NO → FAIL — SC requires unreviewed dependencies
```

#### Meta RED/GREEN Principle

Each spec is a **RED** — it defines what must be true. Each PR merge is a **GREEN** — it makes that truth permanent. An SC that requires multiple PR merges to satisfy is not PR-gate viable; it must be decomposed into sub-SCs, each with its own RED/GREEN cycle.

**PASS example:** "Create `audit/reference/decomposition-criteria.md` with all 7 criteria headings." (One file, one PR, one RED/GREEN cycle.)
**FAIL example:** "Implement the full decomposition audit chain across all 6 phases." (Spans multiple PRs and RED/GREEN cycles.)

---

## Plan-Level Criteria

### 5. Acyclic DAG

**Purpose:** Phase dependencies must form a directed acyclic graph (DAG). Circular dependencies make it impossible to order phases deterministically.

#### Decision Tree

```
Do the phase dependencies form a DAG?
├── YES → Is there a topological ordering that satisfies all dependencies?
│   ├── YES → PASS — Phase graph is acyclic
│   └── NO → FAIL — No valid execution order exists
└── NO → FAIL — Circular dependency detected
```

**PASS example:** Phase 1 → Phase 2 → Phase 3 (linear chain, no cycles).
**FAIL example:** Phase A depends on Phase B, Phase B depends on Phase A (circular).

---

### 6. File Collision Freedom

**Purpose:** No two phases may modify the same file. File collisions create merge conflicts and make phases non-independent.

#### Decision Tree

```
Does each phase modify a unique set of files?
├── YES → Do any two phases share a file?
│   ├── NO → PASS — No file collisions
│   └── YES → FAIL — File collision detected between phases
└── N/A → PASS — No files modified (analysis-only phase)
```

**PASS example:** Phase 1 modifies `file-a.md`, Phase 2 modifies `file-b.md`.
**FAIL example:** Phase 1 and Phase 2 both modify `file-a.md`.

---

### 7. Explicit Dependency Declaration

**Purpose:** Every phase dependency must be explicitly declared. Implicit dependencies (e.g., "Phase 2 should come after Phase 1 because it makes sense") are not acceptable.

#### Decision Tree

```
Are all phase dependencies explicitly declared?
├── YES → Is each dependency justified with a reason?
│   ├── YES → PASS — All dependencies are explicit and justified
│   └── NO → FAIL — Dependency exists without justification
└── NO → FAIL — Undeclared dependency detected
```

**PASS example:** "Phase 2 depends on Phase 1 because Phase 1 creates the file that Phase 2 modifies."
**FAIL example:** "Phase 2 should come after Phase 1." (No justification — implicit dependency.)

---

## Summary Table

| # | Criterion | Level | Decision Tree | Trigger Sub-Checks |
|---|-----------|-------|---------------|-------------------|
| 1 | Atomicity | Spec | ✅ | and, or, comma-separated lists |
| 2 | Single Deliverable | Spec | ✅ | — |
| 3 | Binary Verifiability | Spec | ✅ | either/or, alternatively, one of; should, could, ideally, as appropriate |
| 4 | PR-Gate Viability | Spec | ✅ | RED/GREEN meta principle |
| 5 | Acyclic DAG | Plan | ✅ | — |
| 6 | File Collision Freedom | Plan | ✅ | — |
| 7 | Explicit Dependency Declaration | Plan | ✅ | — |
