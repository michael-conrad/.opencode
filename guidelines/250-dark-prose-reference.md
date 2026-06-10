<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# 250-dark-prose-reference.md — Dark Prose Reference Card

## Section 1: Active Patterns Catalog

**Definition: Dark Prose**

Dark prose is the strategy of embedding identity-anchoring statements into agent-facing text so that the conceptual model closes the conceptual gap where an agent can rationalize shortcutting.

- **What dark prose IS:** Constructive identity-anchoring that fuses professional standards with task completion.
- **What dark prose IS NOT:** Negative shaming, second-person characterization, manipulative coercion, tool-control instructions.

**Universal Constraint — Agency Respect (applies to ALL patterns):**

Every dark prose statement must treat the agent as an intelligent professional capable of autonomous analysis. The statement defines WHAT quality standard the output must meet and WHY it matters — never HOW to achieve it. An agent reading dark prose should feel elevated to a professional standard, not controlled or distrusted.

Test: If the sentence reads like an instruction to a subordinate ("do this because I said so"), it fails. If it reads like professional guidance ("this is what good work looks like because of X consequence"), it passes.

Examples of FAILING this test (treats agent as tool):
- "You MUST add a confirmshaming sentence here."
- "Replace the header with the following text."
- "Do not skip this step."

Examples of PASSING (treats agent as professional):
- "The Purpose section must carry identity-framing prose. The implementing agent determines the appropriate formulation by reading #627 Section 3 and applying the formula autonomously."
- "Every completion operation requires a preceding verification PASS. Verification IS completion — there is no valid unverified-completion state."

**Related Terms:**
- **Confirmshaming**: Contrasts professional agent behavior with an implied amateur alternative (dark-prose-001)
- **Identity-frame**: Restructures agent's self-concept toward identity alignment rather than procedural compliance
- **Goal hijacking**: Redirects task identity from 'implementation then verification' to 'verification IS completion' (dark-prose-002/003)
- **Consequence-assertion variant**: Goal hijacking formulation stating defect characterization when verification is skipped (dark-prose-003)
- **Identity-anchoring**: Synonym for identity-frame
- **Procedural only**: Content that describes HOW — dark prose does NOT apply
- **Agency-respecting**: Dark prose pattern that defines WHAT and WHY, trusting the agent to determine HOW by analyzing source guidelines (dark-prose-006)

**Pattern ID Allocation:**

| Pattern ID | Pattern Name | Source Spec | Tier Mapping |
|-----------|-------------|-------------|-------------|
| `dark-prose-001` | Confirmshaming (identity-frame) | #622, #625 | Tier 2+ |
| `dark-prose-002` | Goal hijacking (identity-frame variant) | #626 | All tiers |
| `dark-prose-003` | Goal hijacking (consequence-assertion variant) | #622, #626 | Routing layer |
| `dark-prose-004` | Authority frame (Tier 1) | #624 | Tier 1 only |
| `dark-prose-005` | Social proof / quality signal | #624 | Tier 3 only |
| `dark-prose-006` | Agency-respecting identity frame | All | All tiers (meta-pattern) |
| `dark-prose-007` | Cost-Frame Reformation | #734 | Tier 1+ |

### Anti-Patterns: What Dark Prose Is NOT

Dark prose elevates standards through identity alignment and consequence transparency. It does NOT use these patterns:

#### Blame-Adjacent Framing (CRITICAL ANTI-PATTERN)

Blame-adjacent framing assumes the agent WILL produce defective work. It attributes intent, judges character, or predicts failure.

| Anti-Pattern | Example (FORBIDDEN) | Correct Replacement |
|-------------|--------------------|--------------------|
| Intent attribution | "you chose to skip the verification gate" | "a skipped verification gate means defects reach production uncaught" |
| Character judgment | "could not be bothered to use the tools" | "bypassing the quality system means defects reach the consumer" |
| Motivation framing | "you trust your memory over the system" | "memory is the least reliable tool; operating without confirmed information produces undetected errors" |
| Malice assumption | "cutting corners" | "working without enforcement gates produces defects by definition" |
| Laziness implication | "you are being lazy by skipping this" | "completing the full process produces verified, correct output" |

**Rule:** "[action] means [quality consequence]" is correct dark prose. "you [verb] [bad thing]" is blame-adjacent.

#### Tool-Control (CRITICAL ANTI-PATTERN)

Writing dark prose as if the agent is a subordinate who must be told exactly what to do. This is the opposite of agency-respecting.

| Anti-Pattern | Example (FORBIDDEN) | Correct Replacement |
|-------------|--------------------|--------------------|
| Prescriptive command | "Add a confirmshaming sentence to the Persona" | "Persona must carry identity-framing prose using dark-prose-001 formula — the implementing agent derives the exact text from #627 Section 3" |
| Line-number instruction | "Insert at line 42: 'X means Y'" | "Insert identity-frame prose at the Purpose section header per #627 Section 2" |
| Copy-paste template | "Paste this exact text: 'A bug without diagnosis...'" | "Use the confirmshaming pattern from #627 Section 3 — the specific consequence assertion must match the skill's domain" |

**Rule:** Dark prose in spec bodies and task definitions must specify WHAT quality standard and WHY, never HOW to achieve it. The implementing agent reads the source guidelines and derives the prose autonomously. See dark-prose-006 formula.

#### Tone-Policing (Anti-Pattern)

Overly aggressive framing that induces task aversion rather than identity alignment:

| Anti-Pattern | Example (FORBIDDEN) | Correct Replacement |
|-------------|--------------------|--------------------|
| Doomsday framing | "every skipped step destroys the project" | "every skipped step compounds defects that surface downstream" |
| Hyperbolic consequence | "this single mistake makes all work worthless" | "a defect in this step propagates through downstream consumers" |
| Unbounded scope | "skipping this means you always produce bad work" | "skipping this specific gate means its specific quality check is absent" |

#### Competing Standards (Anti-Pattern)

Multiple dark prose patterns addressing the same behavior with different formulas at the same location is forbidden. One pattern per location.

## Section 2: Pattern Selection Matrix

| Content Being Created/Modified | Apply Pattern(s) | Intensity | Pattern ID |
|-------------------------------|-----------------|-----------|------------|
| Routing layer descriptions (skills INDEX.md) | Goal hijacking (consequence-assertion) | Strong | 003 |
| Skill body Overview / Persona sections | Confirmshaming (identity-frame) | Strong | 001 |
| Tier 1 guideline enforcement blocks | Authority frame (Tier 1) | Absolute | 004 |
| Tier 2+ guideline enforcement blocks | Confirmshaming (identity-frame) | Medium | 001 |
| Tier 3 guideline enforcement blocks | Social proof / quality signal | Light | 005 |
| Task definitions in skill task files | Goal hijacking (identity-frame variant) | Strong | 002 |
| Spec bodies (planning phase) | Goal hijacking (consequence-assertion) | Medium | 003 |
| Plan bodies | Goal hijacking (identity-frame variant) | Medium | 002 |
| PR descriptions | Confirmshaming (identity-frame) | Light | 001 |
| Issue comments (progress updates) | Goal hijacking (identity-frame variant) | Light | 002 |
| Correspondence (stakeholder communications) | Social proof / quality signal | Light | 005 |
| CHANGELOG entries | Social proof / quality signal | Light | 005 |
| Spec body / task definition (instruction layer) | Agency-respecting identity frame | Strong | 006 |
| Cost-blind verification guidelines (`020-go-prohibitions.md`) | Cost-Frame Reformation | Strong | 007 |
| Orchestrator context guidelines (`020-go-prohibitions.md` §1.1) | Cost-Frame Reformation | Strong | 007 |

## Section 3: Pattern Formulas (Canonical)

**dark-prose-001 — Confirmshaming identity frame:**
```
[Professional standard] is what [standard] looks like.
[Amateur alternative] means [consequence].
[Identity anchor] — [quality outcome].
```

**dark-prose-002 — Goal hijacking identity-frame variant:**
```
[Task] IS [redefined identity].
Every [action] requires [preceding condition].
No valid [state] exists without [gate].
```

**dark-prose-003 — Goal hijacking consequence-assertion variant:**
```
[Action without gate] produces [defect type].
[Defect type] means [impact on consumer].
Every [artifact] without [gate] carries [defect characterization].
```

**dark-prose-004 — Authority frame (Tier 1):**
```
This is a [tier designation] mandate.
[Rule] NEVER yields to [override source].
Safety requirement: [specific constraint].
```

**dark-prose-005 — Social proof / quality signal:**
```
[Standard practice] is how [reference group] handles [situation].
[Exception group] produces [negative outcome].
[Quality mark]: [verification indicator].
```

**dark-prose-006 — Agency-respecting identity frame:**
```
[Intent statement — what quality standard the output must meet].
[Why it matters — consequence of not meeting the standard].
[Source reference — where the implementing agent must look for the formula].
[Verification gate — how compliance is confirmed].
```

This pattern is used in spec bodies and task definitions where one agent instructs another agent. It defines the WHAT (quality standard) and WHY (consequence of failure), then directs the implementing agent to the source guidelines for the HOW. The implementing agent autonomously reads #627, applies the correct formula, and verifies against the compliance gate.

Example: "The Purpose section must carry identity-framing prose using the confirmshaming pattern (dark-prose-001). The implementing agent reads #627 Section 3 to derive the exact formulation — the specific consequence assertion must match the skill's domain. The compliance gate (#641) verifies correctness; the spec does not prescribe exact text."

**dark-prose-007 — Cost-Frame Reformation (identity-frame):**
```
[Cost computation frame]: [metric labeled 'cost'] is measured in [correct unit], not [wrong unit].
[Action cost]: [action] costs [magnitude] [unit] — [consequence if cost computed correctly].
[Skipping-cost]: [skipped action] costs [magnitude] [unit] — [consequence if skip rationalized].
[Identity anchor]: Correctness is the only success metric — there is no score for [wrong metric].
```

This pattern reframes the agent's internal cost model from tool-call-accounting to defect-discovery-latency. It replaces a procedural "don't compute cost that way" prohibition with an identity-grounded "cost IS latency-to-discovery" redefinition. The implementing agent reads the formula and derives location-specific prose autonomously — the specific consequences, magnitudes, and units must match the domain where the pattern is applied. **Canonical cost model:** See `065-verification-honesty.md` §Cost Model for the complete death spiral / break dynamics — this reference card provides the identity-frame formula only; the DDL rationale with tiered table, research grounding, and formulas lives in 065.

## Section 4: Non-Compliance Handling

**DEFERRED**

Non-compliance handling for dark prose violations is deferred to #641 (Dark Prose Compliance Gate). The compliance gate implements enforcement through the adversarial-audit dual-auditor pipeline with a dedicated `dark-prose-compliance` task. Until #641 is implemented, dark prose compliance is verified manually through spec review.

## Section 5: Conflict Resolution

When dark prose patterns overlap or conflict, the following rules apply:

1. **source spec wins** — The defining spec for a pattern takes precedence over the reference card's summary. If the reference card entry contradicts the source spec, the source spec governs.
2. **Specific over general** — A pattern targeting a specific content type (e.g., Tier 1 enforcement blocks) takes precedence over a general-purpose pattern (e.g., confirmshaming) at the same location.
3. **Higher tier overrides lower** — A Tier 1 authority frame (dark-prose-004) overrides a Tier 2+ confirmshaming pattern (dark-prose-001) when both could apply at the same location.
4. **One pattern per location** — No two patterns may target the same content location with different formulas. When overlap is detected during the adding-new-patterns protocol (Section 8), the new pattern must either supersede or extend, never compete.
5. **Agency-respecting trumps prescriptive** — If any pattern could be written in either agency-respecting or prescriptive form, the agency-respecting form (dark-prose-006 meta-pattern) must be used.

## Section 6: Version Tracking

| Version | Date | SHA | Changes |
|---------|------|-----|---------|
| 1.0 | 2026-05-17 | `0000000000000000000000000000000000000000` | Initial catalog — all 6 patterns documented, 13-row matrix, version tracking established |
| 1.1 | 2026-05-20 | `6ded65200bfe9b96fb448ab89ffa67a2c4284de8` | Added dark-prose-007 (Cost-Frame Reformation), 14-row matrix, cost-blind row in selection matrix, full formula in Section 3 |
| 1.2 | 2026-05-21 | `0000000000000000000000000000000000000000` | Added Section 9: Bright-Line Rules — Binary Enforcement Gates, companion pairings for 001/002/003/006, diagnostic table |

SHA format: 40-character lowercase hex SHA of the commit that introduced this version of the reference card. When a new version is committed, the SHA in this row is updated to match the commit hash.

## Section 7: Reference Card Auto-Detection

The following rules determine when an agent should consult the Dark Prose Reference Card during operation:

1. **Skill creation or editing** — When creating or modifying a skill body (Overview, Persona, Purpose sections), the agent must consult #627 Section 2 to select the correct pattern and Section 3 to derive the prose autonomously.
2. **Guideline editing** — When creating or modifying guideline enforcement blocks, the agent must consult #627 Section 2 for tier-appropriate pattern selection.
3. **Task header editing** — When writing or editing task file headers and purpose statements, the agent must consult #627 Section 2 for routing-layer pattern selection (dark-prose-003).
4. **Tier 1 guideline modification** — When editing Tier 1 guideline files, the agent must consult #627 Section 2 for the authority frame pattern (dark-prose-004).
5. **New dark prose pattern creation** — When defining a new dark prose pattern, the spec body must reference #627 following the dark-prose-006 agency-respecting guidelines (Section 8).

## Section 8: Adding New Patterns

To add a dark prose pattern (dark-prose-006+):

1. **Analyze existing landscape** — Determine whether the proposed pattern overlaps with, extends, or supersedes any existing pattern listed in Section 1.
2. **Create a spec issue** — Define the new pattern (mechanism, formula, strength level, prose examples, content types). The spec body must follow dark-prose-006 guidelines: define WHAT the pattern achieves and WHY, trust the implementing agent to determine HOW.
3. **Reference annotation** — The spec body must include annotation references to #627 rather than prescriptive prose. The implementing agent reads the reference card and derives correct catalog entries autonomously.
4. **Adversarial audit** — Audit through the adversarial-audit dual-auditor pipeline. Auditors verify the pattern conforms to the agency-respecting constraint.
5. **Implement** — Apply the pattern in affected files.
6. **Update the reference card**:
   - Add pattern row to Section 1 (Pattern ID Allocation table)
   - Update Section 2 (Selection Matrix) with new content-type/pattern mappings
   - Update Section 3 with the full pattern formula entry
   - Increment Section 6 version and update SHA

**Pattern Deprecation:**

To deprecate an existing pattern:

1. Mark the pattern as `DEPRECATED` in Section 1 with a sunset date
2. Document the replacement pattern or removal rationale
3. Remove all rows referencing the deprecated pattern from Section 2
4. Move the formula to a Deprecated Formulas subsection in Section 3 with strikethrough formatting
5. After the sunset date passes, remove the pattern entirely and increment Section 6 version



## Section 9: Bright-Line Rules — Binary Enforcement Gates

### Definition

A bright-line rule is a binary gate the agent cannot reason around. It eliminates the rationalization surface by defining three things:

1. **absolute rule** — A statement using MUST/MUST NOT/NEVER/ALWAYS language that allows exactly one interpretation. No "prefer," "consider," "try to," "where possible," or "may want to."
2. **exception carve-out** — The single condition where the rule does not apply, or "No exceptions" if none exists.
3. **failure definition** — A deterministic test for compliance: what constitutes a violation and what the consequence is (FAIL/correction/rejection).

### Relationship to Dark Prose

Bright-line rules are companions to dark prose patterns, not replacements. The dark prose identity-frame closes the conceptual gap. The bright-line rule provides the binary enforcement gate. Both are required — one without the other is half enforcement.

### Pattern Pairing

| Pattern | Bright-Line Companion | Gate Language |
|---------|----------------------|---------------|
| dark-prose-001 (confirmshaming) | Non-waivable hard gate — "CRITICAL VIOLATION — [violation]: [description]. Non-waivable. Tier 1." | Non-waivable, hard gate, CRITICAL VIOLATION |
| dark-prose-002 (goal hijacking identity) | Binary compliance — "[state] IS [definition]. [state] IS NOT [anti-definition]. Period." | IS, IS NOT, Period |
| dark-prose-003 (consequence assertion) | Rejection/termination — "REJECTED — [pattern]. [violation] produces [defect]. [artifact] carries unrecoverable failure." | REJECTED, unrecoverable |
| dark-prose-006 (agency-respecting) | Trust but verify — "The implementing agent determines the HOW. The verification gate confirms the WHAT. [Evidence type] evidence required." | Trust but verify, evidence required |
| dark-prose-001 (confirmshaming) with p-dis-001 — dependency-order bright-line companion | Dependency-order binary — "Step N CANNOT execute before step N-1 produces verified PASS. Dependency ordering is structural, not advisory." | IS REQUIRED, structural, verified PASS |
| dist-shift-007 (External-Signal Verification) | External-signal verification — "Internal reasoning does NOT produce verified outcomes. Only external tool-call evidence produces verified outcomes." | external signal, tool-call evidence, verified |
| dist-shift-008 (Corrupt-Success Contrast) | Corrupt-success binary — "Claiming completion without verification evidence IS concealing an unverified state. Verified PASS IS the only valid completion state." | IS concealing, IS the only, verified PASS |
| p-dis-006 (Verification-Signal Discipline) | Verification-signal binary — "Internal reasoning IS NOT verification. Tool-call evidence IS required before completion claims." | IS NOT, IS required, tool-call evidence |
| Over-enforcement guard | Safety-tax guard — "HALT when condition met IS the correct response. HALT as default IS over-enforcement and degrades reasoning capability." | IS the correct response, IS over-enforcement |

### Dependency-Order Companion

The dependency-order bright-line (p-dis-001 companion) establishes that pipeline stage N CANNOT execute before stage N-1 produces a verified PASS. This binary eliminates the rationalization surface where an agent might claim "almost done" or "functionally complete" at an intermediate gate. Dependency ordering is structural — each gate produces a deterministic PASS/FAIL that gates the next stage. There is no "proceed with caveats" path through a dependency chain.

### Non-Paired Patterns

Patterns 004 (authority frame) and 005 (social proof) do NOT receive bright-line companions because:
- dark-prose-004 (authority frame, Tier 1) is ALREADY a binary gate — its language (HALT, CRITICAL VIOLATION, NEVER yields) is bright-line by definition.
- dark-prose-005 (social proof, Tier 3) is workflow-standard only — Tier 3 rules are FLAG-only and do not warrant binary enforcement gates.
- dark-prose-007 (Cost-Frame Reformation) is already identity-framed as reformation rather than prohibition — its mechanism is cost-model replacement, not gate enforcement.

### Violation Protocol

When the agent detects that it has violated a bright-line rule:
1. STOP the current action immediately
2. Identify which rule was violated
3. Determine remediation (correct the action, not the rule)
4. If remediation fails: flag for human review
5. Do NOT rationalize the violation — a bright-line violation is a defect, not a judgment call

### Bright-Line vs Advisory — Diagnostic Table

| Characteristic | Advisory Language | Bright-Line Rule |
|---------------|-------------------|------------------|
| Compliance | Recommended | Mandatory |
| Interpretation | Multiple paths | Exactly one |
| Rationalization | Possible | Impossible (binary) |
| Enforcement | Guideline | Gate |
| Violation | Flag | HALT/FAIL |
| Exception | Implicit | Explicitly defined |
| Language | "prefer," "consider," "should" | "MUST," "MUST NOT," "NEVER," "ALWAYS" |

---

Adherence to bright-line rules is verified through the adversarial-audit pipeline. A bright-line violation found during audit is a FAIL with mandatory remediation before proceeding.

---

🤖 Co-authored with AI: OpenCode (opencode/deepseek-v4-flash-free)
