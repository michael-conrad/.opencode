---
skill: engineering-approach
task: design-before-code
type: discipline-enforcing
license: MIT
---

# Task: design-before-code

## Purpose

Enforce the design-before-implementing discipline per engineering-approach Operating Protocol §2.

## Procedure

### Step 1: Verify Spec Approval

Confirm the spec has been approved before proceeding to design.

### Step 2: Document Approach

- [ ] 1. Identify the components affected by the change
- [ ] 2. Document the design approach with alternatives considered
- [ ] 3. Surface edge cases and trade-offs
- [ ] 4. Present design for approval

### Step 3: Obtain Approval

HALT and wait for explicit authorization before proceeding to implementation. The design must be approved before any code is written.

## Entry Criteria

- Approved spec exists
- Implementation requested

## Exit Criteria

- Design documented
- Design approved by developer

## Context Required

- Spec issue content
- Session values: <github.owner>, <github.repo>

## Result Contract

```yaml
status: DESIGNED | DESIGN_REJECTED
design_documented: true | false
approval_received: true | false
```


Co-authored with AI: <AgentName> (<ModelId>)
