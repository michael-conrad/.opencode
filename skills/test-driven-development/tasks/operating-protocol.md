# Test-Driven Development Operating Protocol

## Entry Criteria

- Test writing or implementation about to begin
- Spec SC list and context available

## Five Core Principles

Read [Five Core Principles](skills/test-driven-development/SKILL.md) for enforcement rules.

## TDD Heading Format Requirement

All TDD task headings in plan documents MUST use the SC-ID parenthetical format:

```text
### TDD-<N>: <description> (SC-<ID>, SC-<ID>, ...)
```

### Examples

**✅ CORRECT:**
```text
### TDD-1: Update sc-coherence-gate with evidence-type uplift scan (SC-6)
### TDD-4: Add post-red-enforcement to routing table (SC-1, SC-5)
```

**🚫 INCORRECT:**
```text
### TDD-1: Update sc-coherence-gate with evidence-type uplift scan  ← missing SC-ID
### TDD-4: Add post-red-enforcement: SC-1, SC-5  ← wrong format
```

### Enforcement

The `pre-red-baseline` sub-agent parses plan TDD headings, extracts SC-IDs, and cross-references against the spec SC table. If any TDD heading references an SC-ID that does not exist in the spec, the gate returns BLOCKED with `MISSING-TRACEABILITY`.

### SC-ID Extraction Contract

| Field | Format | Required |
|-------|--------|----------|
| Prefix | `### TDD-<N>:` | Yes |
| Description | Any text | Yes |
| SC-ID reference | `(SC-<ID>, SC-<ID>, ...)` | Yes — must match spec SC table |
| Multiple SC-IDs | Comma-separated | Optional |
| Whitespace | Space after comma | Recommended |

## ASCII Cycle Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    TDD CYCLE (per item)                  │
│                                                         │
│   PHASE 0 ──► RED ──► GREEN ──► REFACTOR ──► PHASE 4    │
│   (baseline)   │        │          │         (verify)    │
│       ▲        │  fails │ passes   │            │        │
│       │        ▼        ▼          ▼            ▼        │
│       │     BLOCKED  BLOCKED    REVERT       BLOCKED      │
│       │     (fix or  (fix or    (bad        (2x fail     │
│       │      halt)    halt)     refactor)    = halt)      │
│       │                                                  │
│       └──────────── CYCLE RESET ──────────────────────────┘
```

## Procedure

- [ ] 1. **RED phase:** Write a failing test first. Confirm the test FAILS before proceeding.
- [ ] 2. **GREEN phase:** Implement the minimum code to make the test PASS.
- [ ] 3. **REFACTOR phase:** Clean up code while keeping tests GREEN.
- [ ] 4. **PHASE 4:** Verify with regression tests.
- [ ] 5. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. A slow correct answer is strictly better than a fast incorrect one. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

## Exit Criteria

- Test written and confirmed FAIL (RED pass)
- Implementation complete and tests PASS (GREEN pass)
- Code refactored (REFACTOR pass)
- Regression verified (PHASE 4 pass)
