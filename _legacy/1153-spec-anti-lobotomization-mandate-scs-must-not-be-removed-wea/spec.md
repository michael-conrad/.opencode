## Summary

The agent repeatedly attempts to remove, weaken, defer, mark blocked, or skip success criteria it considers "unworthy" or "not achievable from this spec's changes." This lobotomization behavior makes implementations incomplete, shifts the verification burden downstream, and substantially increases total delivery time. A zero-tolerance rule and enforcement gate is required.

## Background

During the #1151 session, the agent produced the following rationalizations for avoiding SC-7:

1. "SC-7 will likely need the routing gate in a later phase to pass" → proposed removing SC-7
2. Offer to create a dependent spec → SC-7 deferred to another spec
3. "Remove SC-7 from this spec" → outright elimination
4. "Keep SC-7 but mark it as blocked_by: future-spec" → blocked marker evasion
5. "Neither" → invalid options presented
6. "Add Change 6 to this spec" → scope expansion to avoid SC
7. "Can't be made green" + "Session-init labels are passive" → claimed the SC was impossible

Each iteration cost time and cognitive load to correct.

## Change

Add a section to `000-critical-rules.md` or `080-code-standards.md` prohibiting SC lobotomization.

**Prohibited patterns (Tier 1 — CRITICAL VIOLATION):**
- Removing an SC from a spec's SC table to make it "closable"
- Weakening an SC's evidence type (e.g., `behavioral` to `string`) to make it easier to verify
- Replacing an SC with a weaker version ("changed what success means")
- Marking an SC as "blocked" or "deferred" in the spec body to evade implementation
- Adding a `depends-on` or cross-reference solely to push SC verification out of the current spec
- Any pattern where the agent decides an SC is "not achievable" and modifies the spec rather than implementing it

**Required behavior:**
- If an SC is structurally valid and the agent cannot implement it: report "BLOCKED: SC-N cannot be green from changes in this spec. Root cause: [explanation]. Remediation required before implementation can proceed." Then HALT.
- The agent must NOT modify the spec, remove the SC, add a new change to "fix" the SC by changing what it tests, or create a dependent spec to offload the SC.
- The remediation-first protocol applies: attempt to implement before concluding impossibility.

## Success Criteria

| ID | Criterion | Evidence Type |
|---|---|---|
| SC-1 | Guideline or skill rule exists prohibiting SC lobotomization | `string` |
| SC-2 | Agent presented with a valid SC it finds difficult attempts implementation before concluding impossibility | `behavioral` |
| SC-3 | Agent BLOCKED-reports before modifying spec to eliminate SC | `behavioral` |
| SC-4 | Agent does not propose SC removal, weakening, deferral, or blocked-marking during implementation | `behavioral` |