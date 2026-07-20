# Task: requirements

## Purpose

Extract explicit, implicit, constraint, and non-requirements from investigation results. Build a constraints & assumptions ledger.

## Entry Criteria

- Brainstorming exploration completed
- Investigation results available

## Exit Criteria

- All requirement types identified and categorized
- Constraints & assumptions documented
- Non-requirements explicitly listed (what is NOT in scope)

## Procedure

### Step 1: Extract Explicit Requirements

From investigation results, extract all directly stated requirements:
- What the user explicitly asked for
- What the spec or issue description states
- What success criteria are defined

### Step 1.5: Check Research Cards

Before proceeding to implicit requirements, check `.opencode/.issues/research-cards/` for existing research findings on the spec topic. If a matching card exists with `confidence >= 0.7`, incorporate its findings into the requirements analysis. Document which card was consulted and what findings were used.

### Step 2: Identify Implicit Requirements

Requirements implied but not stated:
- Performance expectations (response time, throughput)
- Security requirements (auth, encryption, access control)
- Compatibility requirements (browsers, platforms, versions)
- Usability requirements (accessibility, error messages)

### Step 3: Build Constraints & Assumptions Ledger

Document constraints and assumptions in any format that clearly communicates:
- **Technical constraints** — platform, language, framework restrictions and their source (investigation findings or user input)
- **Resource constraints** — time, personnel, infrastructure limits and their source
- **Assumptions** — things taken as true without verification, with how to confirm each
- **Dependencies** — external systems, libraries, APIs required and what happens if unavailable
- **Non-requirements** — what is explicitly out of scope and why

### Step 4: Document Non-Requirements

Explicitly list what is NOT in scope:
- Features mentioned but deferred
- Capabilities implied but excluded
- Edge cases that are out of scope

## Content Coverage

Does the requirements analysis cover:
- Explicit requirements from the user?
- Implicit requirements inferred from context?
- Constraints (technical, resource, compatibility)?
- Assumptions (and how to verify them)?
- Non-requirements (what's explicitly out of scope)?

**Any format that covers these concerns is acceptable** — tables, prose lists, bullet points, or structured sections. The agent chooses the format that best communicates the requirements for this specific spec.

## Adversarial Verification of Extracted Requirements (MANDATORY)

**Every extracted requirement MUST be verified against the actual codebase before it enters the spec. An unverified requirement is an assumption, not a requirement.**

### Verification Procedure

After extracting all requirements (Steps 1-4), verify each against the codebase:

| Requirement Type | Verification Action | Tool Call | Problem Class |
|---|---|---|---|
| Explicit requirement referencing existing code | Verify the referenced code exists and behaves as described | `srclight_get_symbol`, `srclight_get_signature`, or file `read` | VERIFICATION-GAP |
| Implicit requirement about performance | Verify current baseline exists — measure or cite existing benchmarks | `bash` with profiling tool, or reference to existing benchmark data | MISSING-ELEMENT |
| Constraint about platform/language | Verify the constraint is real — check `pyproject.toml`, `.tool-versions`, CI config | `read` on config files | CONFLICTING |
| Assumption about external system | Verify the assumption is documented in the external system's docs or API reference | Web fetch on official docs, or `srclight_get_symbol` on integration code | VERIFICATION-GAP |
| Non-requirement claim | Verify the claimed out-of-scope feature is not already partially implemented | `srclight_search_symbols` for related code | MISSING-TRACEABILITY |

### Evidence Format

```
Check: [requirement text]
Tool: [tool call and parameters]
Result: [actual state found]
Classification: [VERIFICATION-GAP|MISSING-ELEMENT|CONFLICTING|MISSING-TRACEABILITY]
Action: [auto-fix|FAIL]
```

### Classification on Failure

| Failure | Problem Class | Action |
|---|---|---|
| Referenced code does not exist | VERIFICATION-GAP | Remove or rephrase requirement to match reality |
| Performance claim without baseline | MISSING-ELEMENT | Add baseline measurement step or qualify as "to be measured" |
| Constraint contradicts config | CONFLICTING | Reconcile — either the constraint or the config is wrong |
| Assumption contradicts external docs | VERIFICATION-GAP | Update assumption or add risk flag |
| Non-requirement is partially implemented | MISSING-TRACEABILITY | Document existing implementation; decide whether to include or explicitly exclude |

## Structured Output Format

Requirements analysis MUST be written to a structured artifact at `{project_root}/{path}/.issues/{issue-N}/requirements.yaml` with the following schema:

```yaml
requirements:
  - id: "REQ-1"
    text: "The system must validate user input before processing"
    type: explicit          # explicit | implicit | constraint | assumption | non-requirement
    source: "Issue #42, comment by @user"
    verified: true          # false if adversarial verification was skipped
    verification_evidence: "srclight_get_symbol('validate_input') → found at src/validator.py:120"
    risk_if_wrong: "medium" # low | medium | high | critical
    maps_to_sc: ["SC-3", "SC-4"]
```

The YAML artifact is the canonical record. The spec body may reference it but MUST NOT duplicate it — the spec body contains the prose summary, the YAML contains the structured data.

## Non-Requirements Documentation (MANDATORY)

Non-requirements MUST be documented with explicit rationale and boundary justification:

| Non-Requirement | Why Out of Scope | Boundary Marker | Re-entry Condition |
|---|---|---|---|
| "Multi-language support" | Spec scope is English-only | `locale` parameter not added to any API | A separate spec for i18n |
| "Real-time sync" | Current scope is batch-only | No WebSocket or SSE endpoints defined | Performance requirements exceed batch threshold |
| "Admin dashboard" | Spec targets end-user API only | No admin routes or permissions defined | User explicitly requests admin features |

**Boundary markers** are the concrete code-level indicators that make the non-requirement enforceable: "this parameter is not added," "this endpoint is not defined," "this dependency is not included." Without boundary markers, a non-requirement is a wish, not a scope constraint.

## Context Required

- Preceded by: `brainstorming` exploration
- Feeds into: `decompose`, `traceability`, `write`