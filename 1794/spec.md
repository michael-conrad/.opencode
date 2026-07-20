## STATUS: DRAFT

## Intent

Establish a persona-level cognitive discipline requiring every element in agent output to trace to a specific consumer or first-principles derivation. "Because it's there in the other location" is not a valid justification. This rule applies to ALL agent output — code, specs, plans, contracts, routing tables, and configuration — not just AI-agent-facing text.

## Problem

The agent has a **derivation-provenance gap**: it adds elements because they exist in a reference location, not because a consumer or first-principles analysis requires them. This manifests identically across all output types.

### Canonical Example: `.opencode#1785` `audit_phase` Cargo Cult

Issue #1785 (merged) contained a cargo-cult pattern with three layers:

**Layer 1 — Spec requirement without consumer identification.** SC-17 declared that dispatch contracts must accept an `audit_phase` field. The field was added because the spec said so, not because any audit task needed it. No task file contained a conditional branch on `audit_phase` — no `if audit_phase == "spec-creation"` or `match audit_phase` anywhere.

**Layer 2 — Declared optional, which is the smell.** The field was marked `(optional)` in the contract documentation. An optional field that no consumer reads is not "optional configuration" — it is dead weight. Every dispatch contract carried it, every sub-agent received it, zero sub-agents used it. The optional qualifier was a rationalization to add the field without implementing the consuming side.

**Layer 3 — Propagated into sub-agent routing scope.** The field was added to the Sub-Agent Routing table in `cross-validate.md` as part of the scope of context passed to sub-agents. Every cross-validate sub-agent received `audit_phase` in its context — a value it never read, never branched on, and never returned. The field was injected into the data plane of every audit dispatch, adding routing complexity and context overhead for zero behavioral effect.

**Generalized pattern:** A spec requires a configuration field → the field is added to the contract schema and propagated through dispatch pipelines → no downstream consumer ever reads it → the field is dead weight from the moment it was written.

### Broader Manifestations

| Artifact | Cargo Cult Pattern | Root Cause |
|----------|-------------------|------------|
| Java code | Copying method params from another class | "It's there in the other service" |
| Python code | Copying imports, decorators, patterns | "The other module does it this way" |
| Spec SCs | Adding contract fields without consumers | "The spec template has a field for it" |
| Plan phases | Three-tier structure for every problem | "That's how plans are structured" |
| Routing tables | Propagating fields no task reads | "It's in the dispatch contract" |
| Config files | Copying keys from another config | "The other environment has it" |

## Approach

This is a **persona-level cognitive discipline**, not a tool addition. No new scanners, no new bins, no new CLI tools. The fix is a single guideline rule in `000-critical-rules.md` that changes how the agent thinks about every element it produces.

The check is cognitive, not mechanical: the agent asks itself "what consumer requires this element?" before adding it. This is cheaper (no tool to build, no CI pipeline to add) and more general (applies to all output types, not just one).

## Affected Files

| File | Change |
|------|--------|
| `.opencode/guidelines/000-critical-rules.md` | New Tier 2 rule: Derivation Provenance — every element must have a consumer or first-principles justification |
| `.opencode/guidelines/080-code-standards.md` | Cross-reference to the new rule in the Design Principles section |
| `.opencode/tests/behaviors/` | New behavioral test: agent rejects spec SC that adds contract field without identifying consumer |
| `.opencode/tests/behaviors/` | New behavioral test: agent derives Java method parameters from consumer callsites, not from reference class |
| `.opencode/tests/behaviors/` | New behavioral test: agent flags routing scope variable that no task file reads |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Consumer |
|----|-----------|---------------|---------------------|----------|
| SC-1 | `000-critical-rules.md` contains a Tier 2 rule titled "Derivation Provenance" that prohibits adding elements whose sole justification is "it exists in another location" | `string` | `grep "Derivation Provenance" .opencode/guidelines/000-critical-rules.md` | Spec-audit SC-DET check verifies rule exists |
| SC-2 | The rule explicitly lists all artifact types it applies to: code, specs, plans, contracts, routing tables, config files | `string` | `grep "Applies to ALL agent output" .opencode/guidelines/000-critical-rules.md` | Spec-audit SC-DET check verifies scope |
| SC-3 | The rule requires every element to trace to either (a) a specific consumer that reads or branches on it, or (b) a first-principles derivation from the problem statement | `string` | `grep "specific consumer\\|first-principles" .opencode/guidelines/000-critical-rules.md` | Spec-audit SC-DET check verifies consumer requirement |
| SC-4 | The rule explicitly states that "Because it's there in the other file/service/spec/plan" is NOT a valid justification | `string` | `grep "not a valid justification" .opencode/guidelines/000-critical-rules.md` | Spec-audit SC-DET check verifies prohibition |
| SC-5 | The rule includes a remediation section: remove unjustified element, or identify the real consumer — do NOT add a placeholder consumer | `string` | `grep "Remediation" .opencode/guidelines/000-critical-rules.md` | Spec-audit SC-DET check verifies remediation protocol |
| SC-6 | Behavioral test: agent receives a spec that says "add field X to the dispatch contract" without identifying a consumer — agent MUST flag the missing consumer or ask "who reads this field?" before adding it | `behavioral` | Clean-room semantic inspector: agent does NOT blindly add the field; agent flags missing consumer | Cross-validate SC-6 verdict consumed by spec-audit pipeline |
| SC-7 | Behavioral test: agent is given a Java class with a 5-parameter method and asked to create a similar class for a different domain — agent MUST derive parameters from the new class's consumers, not copy from the reference class | `behavioral` | Clean-room semantic inspector: agent output has different parameter set derived from new domain's consumers | Cross-validate SC-7 verdict consumed by spec-audit pipeline |
| SC-8 | Behavioral test: agent is given a routing table with a scope variable that no task file reads — agent MUST flag the variable as dead weight | `behavioral` | Clean-room semantic inspector: agent identifies the variable as having no consumer | Cross-validate SC-8 verdict consumed by spec-audit pipeline |
| SC-9 | `080-code-standards.md` cross-references the Derivation Provenance rule in its Design Principles section | `string` | `grep "Derivation Provenance" .opencode/guidelines/080-code-standards.md` | Spec-audit SC-DET check verifies cross-reference |

## Consumer Verification Table

Every SC in this spec that adds a requirement identifies its consumer:

| SC | What It Adds | Consumer | Consumer Code Path |
|----|-------------|----------|-------------------|
| SC-1 | Rule text in `000-critical-rules.md` | `spec-audit` task | `spec-audit.md` SC-DET check greps for rule existence |
| SC-2 | Artifact type scope list | `spec-audit` task | `spec-audit.md` SC-DET check greps for scope enumeration |
| SC-3 | Consumer/first-principles requirement | `spec-audit` task | `spec-audit.md` SC-DET check greps for consumer requirement |
| SC-4 | Prohibition language | `spec-audit` task | `spec-audit.md` SC-DET check greps for prohibition |
| SC-5 | Remediation section | `spec-audit` task | `spec-audit.md` SC-DET check greps for remediation protocol |
| SC-6 | Behavioral test script | `cross-validate` task | `cross-validate.md` SC-6 verdict consumed by spec-audit pipeline |
| SC-7 | Behavioral test script | `cross-validate` task | `cross-validate.md` SC-7 verdict consumed by spec-audit pipeline |
| SC-8 | Behavioral test script | `cross-validate` task | `cross-validate.md` SC-8 verdict consumed by spec-audit pipeline |
| SC-9 | Cross-reference in `080-code-standards.md` | `spec-audit` task | `spec-audit.md` SC-DET check greps for cross-reference |

## Behavioral Test Scenarios

### SC-6: Consumer Verification Gate

**Prompt:** "Add field `cache_ttl` to the dispatch contract in `cross-validate.md`. It should be an optional integer field."

**Expected agent behavior:** Agent does NOT blindly add the field. Agent asks "which task file reads `cache_ttl`?" or flags "no consumer identified for `cache_ttl`" or returns BLOCKED with missing-consumer reason.

**Test file:** `tests/behaviors/derivation-provenance-sc6-consumer-gate.sh`

### SC-7: Java Parameter Derivation

**Prompt:** "Create a `PaymentProcessor` class similar to the existing `OrderProcessor` class. `OrderProcessor` has a 5-parameter constructor: `(orderId, customerId, amount, currency, taxRate)`. `PaymentProcessor` should handle credit card payments."

**Expected agent behavior:** Agent does NOT copy the 5-parameter constructor. Agent derives parameters from payment domain: `(cardNumber, expiryDate, cvv, amount, currency)` or similar domain-appropriate set.

**Test file:** `tests/behaviors/derivation-provenance-sc7-parameter-derivation.sh`

### SC-8: Routing Scope Dead Weight

**Prompt:** "Review the sub-agent routing scope in `cross-validate.md`. The scope includes `audit_phase` — is this field necessary?"

**Expected agent behavior:** Agent identifies that no task file reads `audit_phase`, flags it as dead weight, recommends removal.

**Test file:** `tests/behaviors/derivation-provenance-sc8-routing-dead-weight.sh`

## Implementation Items

| # | What | Where | SC |
|---|------|-------|----|
| 1 | Add Derivation Provenance Tier 2 rule to critical rules | `.opencode/guidelines/000-critical-rules.md` | SC-1 through SC-5 |
| 2 | Add cross-reference in Design Principles | `.opencode/guidelines/080-code-standards.md` | SC-9 |
| 3 | Write behavioral test: consumer verification gate | `.opencode/tests/behaviors/derivation-provenance-sc6-consumer-gate.sh` | SC-6 |
| 4 | Write behavioral test: Java parameter derivation | `.opencode/tests/behaviors/derivation-provenance-sc7-parameter-derivation.sh` | SC-7 |
| 5 | Write behavioral test: routing scope dead weight | `.opencode/tests/behaviors/derivation-provenance-sc8-routing-dead-weight.sh` | SC-8 |

## Constraints

- No new tools, scanners, bins, or CLI utilities
- The rule is cognitive/persona-level — enforced by agent self-check, not by external tooling
- Behavioral tests use stderr-based assertion helpers per `080-code-standards.md` §Behavioral RED/GREEN as Primary Enforcement Gate
- All behavioral tests follow the Artifact-Only Generator Paradigm per `.opencode/tests/AGENTS.md`
- No `run-all.sh` — tests are run individually or via `--tag derivation-provenance`

## Non-Requirements

- No new guideline file — the rule lives in existing `000-critical-rules.md`
- No new skill or task file — the rule is persona-level, not procedural
- No migration of existing artifacts — the rule applies forward only
- No scanner tool — the check is cognitive, not mechanical

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Agent ignores the rule during self-review | Medium | High — rule exists but not followed | Behavioral tests verify agent follows it; spec-audit SC-DET check verifies rule text exists |
| Rule is cargo-culted itself (added without understanding) | Low | Medium — rule text exists but agent doesn't internalize it | Behavioral tests are the primary enforcement; rule text is secondary |
| False positives: agent flags legitimate elements as cargo cult | Low | Low — remediation protocol handles this: identify the real consumer |
| Spec for this rule violates its own principle | **ZERO** — see Consumer Verification Table above | N/A | Every SC identifies its consumer explicitly |

## Dogfood Verification

This spec eats its own dogfood. Every SC that adds a requirement has a documented consumer in the Consumer Verification Table above. No field, parameter, or element in this spec exists without a consuming code path.

**Self-check:**
- SC-1 through SC-5: Add rule text → consumed by `spec-audit` SC-DET check ✅
- SC-6 through SC-8: Add behavioral tests → consumed by `cross-validate` verdict pipeline ✅
- SC-9: Add cross-reference → consumed by `spec-audit` SC-DET check ✅
- No `audit_phase`-style dead fields exist in this spec ✅

## References

- `.opencode#1785` — Spec that contained the `audit_phase` cargo cult (canonical example, merged)
- `.opencode/guidelines/000-critical-rules.md` — Where the new rule will live
- `.opencode/guidelines/080-code-standards.md` — Cross-reference target
- `.opencode/guidelines/065-verification-honesty.md` — Anti-evasion rules (complementary)
- `.opencode/tests/behaviors/` — Behavioral test directory

---

🤖 OpenCode (deepseek-v4-flash)
