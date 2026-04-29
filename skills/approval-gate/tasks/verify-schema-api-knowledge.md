# Task: verify-schema-api-knowledge

Verify that the agent has performed live verification before making schema, API, or code implementation claims. This is a gate that prevents the agent from proceeding with unverified knowledge.

## Purpose

Agents frequently make claims about API signatures, config schemas, or code behavior based on training data — which is always stale per the staleness axiom in `065-verification-honesty.md`. This task enforces the verification gate: before an agent can proceed with implementation that relies on specific schema fields, API parameters, or code behavior, the agent MUST produce tool-call evidence confirming those claims.

**This task enforces `000-critical-rules.md` §Implementing Without Verifying and §Verification Dishonesty.**

## Pre-Conditions

- Agent is about to proceed with implementation
- Implementation depends on specific schema fields, API parameters, or code behavior
- Agent has not yet verified these claims against live sources

## Trigger Conditions

This task is invoked when:

1. An agent references a specific API endpoint, method signature, or config schema field as part of implementation planning
2. An agent claims knowledge of how a library, framework, or internal module works without citing verification evidence
3. A screening or verification task identifies unverified schema/API/code knowledge in the agent's context

## Steps

### Step 1: Identify Unverified Claims

Scan the agent's current context for claims about:

| Claim Type | Examples |
|------------|----------|
| API signatures | "The function takes (a, b, c)" without `srclight_get_signature` call |
| Config schema | "The config has field X" without reading the schema file |
| Code behavior | "Module Y processes Z" without `srclight_get_symbol` or `read` call |
| Library versions | "Library X supports Y" without checking live docs |

### Step 2: Require Verification Evidence

For each unverified claim, require a tool-call artifact:

| Claim Type | Acceptable Verification |
|------------|------------------------|
| API signatures | `srclight_get_signature(name="<symbol>")` or live doc fetch |
| Config schema | `read` of the schema file or live doc fetch |
| Code behavior | `srclight_get_symbol(name="<symbol>")` or `read` of source file |
| Library versions | Web search or `read` of package manifest |

### Step 3: Classify Verification Results

| Result | Classification | Action |
|--------|---------------|--------|
| Tool call confirms claim | VERIFIED | Proceed |
| Tool call contradicts claim | CONTRADICTED | HALT, report discrepancy, revise approach |
| Tool call unavailable or fails | CANNOT_VERIFY | Mark claim as UNVERIFIED; decline to state; suggest contingent on user acceptance for general knowledge; DECLINE for code/API claims |
| No tool call produced | UNVERIFIED | HALT, require tool call before proceeding |

### Step 4: Gate Decision

```
IF all implementation-critical claims are VERIFIED:
    PROCEED with implementation
ELSE IF any claim is CONTRADICTED:
    HALT — report contradiction, revise approach
ELSE IF any code/API claim is CANNOT_VERIFY:
    DECLINE to state the claim — do NOT proceed with that unverified claim as a dependency
ELSE IF any code/API claim is UNVERIFIED:
    HALT — require tool-call verification before proceeding
ENDIF
```

## Result Contract

```json
{
  "status": "verified | contradicted | cannot_verify | unverified_claims_exist",
  "claims_checked": [
    {
      "claim": "string",
      "type": "api | schema | code | library",
      "result": "VERIFIED | CONTRADICTED | CANNOT_VERIFY | UNVERIFIED",
      "evidence_artifact": "tool_call_reference | null"
    }
  ],
  "blocking_claims": ["list of claim IDs that block implementation"]
}
```

## Relationship to Other Tasks

| Task | Relationship |
|------|---------------|
| `verify-authorization` Step 4.4 | Checks schema/API knowledge as part of authorization verification |
| `verification-enforcement --task verify` | Broader verification gate for content generation |
| `065-verification-honesty.md` | Authority document for staleness axiom and evidence requirements |

## Completion Guarantee

If this task halts at any point, invoke `approval-gate --task completion` before halting.