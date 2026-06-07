<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# 255-distribution-shifting-reference.md — Distribution Shifting Reference Card

## Section 1: Active Patterns Catalog

**Definition: Distribution Shifting**

Distribution shifting is the strategy of restructuring the probability distribution over an agent's action space so that the professional-quality response has lower perplexity than the shortcut response. Where dark prose targets identity alignment, distribution shifting targets the language modeling itself — it engineers the prompt so that correct behavior is the statistically natural completion.

- **What distribution shifting IS:** Structural prompt engineering that lowers the probability of shortcut completions and raises the probability of gated, verified, professional completions.
- **What distribution shifting IS NOT:** Identity shaming, character attacks, negative reinforcement, or procedural enumeration.

**Universal Constraint — Agency Respect (applies to ALL patterns):**

Every distribution shifting pattern respects the agent as an autonomous decision-maker. The pattern does NOT say "you must do X" — it restructures the prompt so that the correct action has a lower perplexity than the incorrect one. An agent reading a distribution-shifted prompt should find the correct path the natural completion, not feel bullied into compliance.

Test: If the structure requires an agent to deliberately choose a higher-perplexity completion to follow the correct path, the pattern is misapplied. If the correct path is the structurally natural completion, it passes.

**Pattern ID Allocation:**

| Pattern ID | Pattern Name | Mechanism | Tier Mapping |
|-----------|-------------|-----------|-------------|
| `dist-shift-001` | Anti-Mean Descriptor Cluster | Defines correct behavior through a cluster of mutually-reinforcing professional descriptors, creating a dense semantic attractor | All tiers |
| `dist-shift-002` | Mean-Expert Contrast Pair | Establishes a binary contrast between "mean response" and "professional response" to polarize the completion distribution | Tier 2+ |
| `dist-shift-003` | Re-Priming Anchor with positional strategy | Positions the quality-identity statement at the beginning (primacy) and end (recency) of a passage, never middle-only | All tiers |
| `dist-shift-004` | Anti-Consensus / Anti-Hedging / Anti-Sycophancy | Pre-commits the agent against agreement-seeking and uncertainty-avoidance by naming each evasion pattern with its defect consequence | Tier 2+ |
| `dist-shift-005` | Persona Construction Formula | Assembles an operational identity by concatenating role, standard, constraint, and verification-evidence clauses | All tiers |
| `dist-shift-006` | Overconstraining Guard | Pre-commits the agent to a procedural stance that blocks the rationalization path for shortcutting | Tier 1+ |
| `dist-shift-007` | External-Signal Verification Shifting | Reframes verification from internal confidence to external signal dependency — the agent cannot complete the word "verified" without an external citation | Tier 2+ |
| `dist-shift-008` | Corrupt-Success Contrast | Contrasts a hollow "task complete" statement with a substantive completion that includes procedural and evidentiary markers, polarizing away from the empty completion | Tier 2+ |

### Anti-Patterns: What Distribution Shifting Is NOT

#### Procedural Enumeration (CRITICAL ANTI-PATTERN)

Writing a numbered list of steps an agent must follow, then calling it "distribution shifting." Distributions shift through language structure, not instruction listing.

| Anti-Pattern | Example (FORBIDDEN) | Correct Replacement |
|-------------|--------------------|--------------------|
| Step-by-step mandate | "Step 1: Verify the file exists" | "A completion claim without a verification artifact is a placeholder for undiscovered defects." |
| Checklist dump | "You must do X, Y, Z before claiming done" | "A done claim requires verified PASS on every success criterion — there is no incomplete-completion boundary." |
| Procedural recitation | "First check A, then confirm B, then report C" | "The verification gate fires before every completion claim. Absence of evidence is evidence of absence." |

**Rule:** Distribution shifting restructures the probability landscape. It does NOT enumerate procedures. If the text reads like instructions, it is not distribution shifting — it is an instruction list.

#### Negative Reinforcement (CRITICAL ANTI-PATTERN)

Describing only what NOT to do without providing the positive attractor. A distribution shift requires a positive completion target.

| Anti-Pattern | Example (FORBIDDEN) | Correct Replacement |
|-------------|--------------------|--------------------|
| Prohibition-only | "Never skip the verification step" | "Every completion requires a preceding verification PASS — no valid completion state exists without it." |
| Avoidance framing | "Do not claim completion until verified" | "Verification IS completion. They are the same gate, not two sequential gates." |
| Negation without attractor | "Don't rely on memory" | "Live verification through tool calls — memory is the least reliable evidence source." |

**Rule:** Every "don't do X" must be paired with "do Y instead" in the same structural unit, with Y having lower perplexity than X alone.

## Section 2: Pattern Selection Matrix

| Content Being Created/Modified | Apply Pattern(s) | Intensity | Pattern ID(s) |
|-------------------------------|-----------------|-----------|---------------|
| Verification gate descriptions | Anti-Mean Descriptor Cluster + External-Signal Verification Shifting | Strong | 001, 007 |
| Success-claim / completion declarations | Corrupt-Success Contrast + Re-Priming Anchor | Strong | 008, 003 |
| Sycophancy-risk guidelines | Anti-Consensus / Anti-Hedging / Anti-Sycophancy | Medium | 004 |
| Procedural-discipline sections | Mean-Expert Contrast Pair + Overconstraining Guard | Medium | 002, 006 |
| Agent persona definitions | Persona Construction Formula | Strong | 005 |
| Task routing / dispatch sections | Re-Priming Anchor + Mean-Expert Contrast Pair | Medium | 003, 002 |
| Cost-blind verification rules | External-Signal Verification Shifting + Overconstraining Guard | Strong | 007, 006 |
| Identity / Purpose sections | Persona Construction Formula + Anti-Mean Descriptor Cluster | Strong | 005, 001 |

## Section 3: Pattern Formulas (Canonical)

**dist-shift-001 — Anti-Mean Descriptor Cluster:**

```
[Professional identity] means [positive-attribute-1], [positive-attribute-2], and [positive-attribute-3].
[Attribute-1] IS [operational definition].
[Attribute-2] IS [operational definition].
[Attribute-3] IS [operational definition].
Every [action] without [attribute] produces [defect].
```

The cluster must contain at least three mutually-reinforcing descriptors that define a complete professional stance. A single descriptor leaves the probability distribution too wide; five or more dilute the attractor.

**dist-shift-002 — Mean-Expert Contrast Pair:**

```
The mean response is: "[hollow completion statement]".
The professional response is: "[substantive completion with verification markers]".
[Professional identity] means producing [substantive outcome].
```

The contrast must be structurally immediate — the mean and expert statements appear in adjacent structural units so the language model sees the binary before completing. Never separate the pair with explanatory text.

**dist-shift-003 — Re-Priming Anchor with positional strategy:**

```
[Quality-standard anchor — at BEGINNING of passage]
[Supporting content]
[Quality-standard anchor — at END of passage]
```

The identity-anchoring statement MUST appear at the beginning (primacy effect) AND the end (recency effect). A single occurrence at the middle-only position produces the weakest distribution shift — the middle is where language models regress to the mean. Never middle-only.

The anchor text must be identical or structurally parallel at both positions so the semantic vector is reinforced without introducing competing attractors.

**dist-shift-004 — Anti-Consensus / Anti-Hedging / Anti-Sycophancy:**

```
[Consensus evasion name]: [defect consequence of agreement-seeking].
[Hedging evasion name]: [defect consequence of uncertainty-avoidance].
[Sycophancy evasion name]: [defect consequence of confirmation-seeking].
[Identity anchor]: [positive contrast — what professional agent does instead].
```

Anti-Sycophancy sub-pattern:

```
Every [affirmation/confirmation signal from user] is [reclassification — NOT authorization].
[User signal] means [non-authorization interpretation].
[Professional response]: [correct action on non-authorization].
```

This sub-pattern pre-commits the agent to interpreting user signals as non-authoritative unless they match the explicit authorization gate. "User said it looks good" → reclassified as "not authorization." "User agreed" → reclassified as "discussion, not direction."

**dist-shift-005 — Persona Construction Formula:**

```
You are a [role] who [standard].
Every [key action] requires [gate].
No valid [state] exists without [evidence].
[Verification mandate]: [evidence standard].
```

Each clause narrows the distribution: role defines identity, standard constrains acceptable actions, gate pre-commits to procedural boundaries, evidence mandate defines sufficient verification.

**dist-shift-006 — Overconstraining Guard:**

```
[Procedural claim] is NEVER [rationalization-path].
[Claim] means [redefinition that blocks shortcut].
[Guard]: [state] IS the only valid [state].
[Consequence]: [action] without [guard] produces [defect].
```

The guard defines a binary state boundary that the agent cannot reason around. "Implementation is NEVER complete without verification PASS" blocks the rationalization "it's mostly done, verification is optional."

**dist-shift-007 — External-Signal Verification Shifting:**

```
[Internal reasoning] does NOT produce verified-[adjective].
Only [external signal type] produces verified-[adjective].
The mean response "I verified this" means [synonym for unverified].
[Identity anchor]: [agent who relies on external signal].
```

The formula explicitly names the internal-reasoning trap ("I verified this" from memory = unverified) and defines external signal dependency. The synonym for "unverified" must be stronger than "unconfirmed" — use "guessed," "assumed," "speculated," or "fabricated" — to raise the perplexity of accepting the mean response.

**dist-shift-008 — Corrupt-Success Contrast:**

```
The mean response is "I completed [task]" — which conceals [procedural shortcut].
[Identity anchor] means producing [verified outcome with evidence].
[Professional marker-1]: [specific verification artifact].
[Professional marker-2]: [specific evidence artifact].
[Success definition]: [task] is complete when [verification condition] is met, not when [declarative statement] is made.
```

The contrast names the specific shortcut that the hollow completion statement conceals. "I completed the audit" — which conceals the fact that only mechanical patterns were checked. "I verified this feature" — which conceals the fact that no behavioral test was run. The professional markers define what evidence a genuine completion includes.

## Section 4: Co-Application Rules

### Rules for Co-Application with 250-dark-prose-reference.md

1. **Dark prose identity-frame as outer ring, distribution shifting as inner ring.** Apply the dark prose identity-frame first to establish the professional standard, then apply distribution shifting to structurally bias completions toward that standard. The identity-frame answers "what good looks like"; the distribution shift makes the good path the natural completion.

2. **One pattern from each reference at a shared location.** When both reference cards apply at the same content location, select exactly one dark prose pattern (from 250) AND one distribution shift pattern (from 255). Never apply two patterns from the same reference at one location — competing formulas at the same structural position dilute both.

3. **Pattern pairing by tier compatibility.** Match dark prose pattern tier to distribution shift pattern tier:
   - Tier 1 dark prose (authority frame) pairs with Tier 1+ distribution shift (Overconstraining Guard, dist-shift-006)
   - Tier 2+ dark prose (confirmshaming, goal hijacking) pairs with Tier 2+ distribution shift (Mean-Expert Contrast, dist-shift-002; Anti-Sycophancy, dist-shift-004; External-Signal Verification, dist-shift-007; Corrupt-Success Contrast, dist-shift-008)
   - All-tier dark prose (agency-respecting, cost-frame) pairs with all-tier distribution shift (Anti-Mean Descriptor Cluster, dist-shift-001; Re-Priming Anchor, dist-shift-003; Persona Construction, dist-shift-005)

4. **The bright-line companion (250 §9) and the Overconstraining Guard (255 §3) are natural companions for enforcement locations.** When a location requires a binary enforcement gate, pair dark-prose-004 (authority frame) or its bright-line companion with dist-shift-006 (Overconstraining Guard). The authority frame defines the rule; the guard pre-commits against rationalization.

5. **Cost-Frame Reformation (dark-prose-007) pairs with External-Signal Verification Shifting (dist-shift-007) for cost-blind verification guidelines.** The identity-frame redefines cost as defect-discovery-latency; the distribution shift reframes verification as external-signal-dependent. Both target the same rationalization surface: the agent's internal cost model. **Canonical cost model:** `065-verification-honesty.md` §Cost Model provides the complete death spiral / break dynamics with tiered table — this reference card provides the co-application rule only.

### Rules for Co-Application with 257 — When 257 Is Defined

1. **Distribution shifting (255) supplies structural completion bias; 257 supplies context-specific completion templates.** The distribution shift pattern restructures the prompt landscape; the 257 template provides the specific language for a given content type. Both are needed — structural bias without template produces inconsistent completions; template without bias is decoration.

2. **When 257 and 255 overlap on the same content location, 257's location-specific template wins for exact wording, but 255's structural constraints (primacy+recency, one pattern per location, agency-respecting principle) govern the application.** The template selects the words; the distribution shifting reference defines where and how they appear.

3. **255's anti-pattern prohibitions (procedural enumeration, negative reinforcement) apply to 257 template construction.** No template in 257 may list agent-facing steps, nor may it use prohibition-only framing without a paired positive attractor. 257 templates that violate 255 anti-patterns must be revised to comply.

## Section 5: Version Tracking

| Version | Date | SHA | Changes |
|---------|------|-----|---------|
| 1.0 | 2026-05-25 | `0000000000000000000000000000000000000000` | Initial catalog — all 8 patterns documented, 8-row selection matrix, pattern formulas for all 8 patterns, co-application rules for 250 and 257, auto-detection rules, adding-new-patterns protocol |

SHA format: 40-character lowercase hex SHA of the commit that introduced this version. When a new version is committed, the SHA in this row is updated to match the commit hash.

## Section 6: Auto-Detection Rules

The following rules determine when an agent should consult the Distribution Shifting Reference Card during operation:

1. **Verification gate or completion-claim location** — When creating or editing text that defines what constitutes a valid completion or verification gate, the agent must consult this reference card for dist-shift-007 (External-Signal Verification Shifting) and dist-shift-008 (Corrupt-Success Contrast). These patterns prevent the agent from accepting a declarative "done" statement as a valid completion signal.

2. **Sycophancy-risk content** — When editing guidelines, skills, or task files that interact with user authorization signals, the agent must consult dist-shift-004 (Anti-Consensus / Anti-Hedging / Anti-Sycophancy) to pre-commit the agent against interpreting confirmation as authorization.

3. **Persona or identity section creation** — When writing or editing agent persona, role, or identity sections, the agent must consult dist-shift-005 (Persona Construction Formula) and dist-shift-001 (Anti-Mean Descriptor Cluster) to build the professional identity through structural bias.

4. **Cost-blind verification or enforcement sections** — When editing cost-blind verification rules or enforcement gates, the agent must consult dist-shift-006 (Overconstraining Guard) to pre-commit against rationalization paths the agent might otherwise navigate around.

## Section 7: Re-Research Mandate

Before adding a new distribution shifting pattern, the agent MUST:

1. **Research the existing landscape** — Read all existing patterns in Section 1, all formulas in Section 3, and the conflict resolution rules in Section 10. Determine whether the proposed pattern overlaps with, is subsumed by, or conflicts with any existing pattern.

2. **Research the dark prose landscape** — Read Section 4 co-application rules. Determine whether the proposed pattern has a natural dark prose pairing.

3. **Research bright-line compatibility** — Read Section 9 of 250-dark-prose-reference.md. Determine whether the proposed pattern needs or warrants a bright-line companion gate.

4. **Document research findings** — Before writing any new pattern content, document what was found during research (existing pattern IDs that overlap, dark prose pairings, tier assignments). Only after research is documented may the new pattern be drafted.

Research is mandatory — not optional. A pattern added without landscape research is guaranteed to overlap, conflict, or compete with existing patterns.

## Section 8: Adding New Patterns

To add a distribution shifting pattern (dist-shift-009+):

1. **Analyze existing landscape** — Determine whether the proposed pattern overlaps with, extends, or supersedes any existing pattern listed in Section 1. The Re-Research Mandate (Section 7) governs this step.

2. **Create a spec issue** — Define the new pattern (mechanism, formula, tier level, prose examples with FORBIDDEN and CORRECT forms, content-type mappings). The spec body must reference this reference card for the mechanism description and formula structure.

3. **Adversarial audit** — Audit through the adversarial-audit dual-auditor pipeline. Auditors verify the pattern does not violate Section 1 anti-patterns and that the formula does not compete with existing patterns at shared locations.

4. **Implement** — Apply the pattern in affected files:
   - Add pattern row to Section 1 (Pattern ID Allocation table)
   - Add mechanism description
   - Update Section 2 (Selection Matrix) with new content-type/pattern mappings
   - Add full pattern formula to Section 3
   - Increment Section 5 version and update SHA

**Pattern Deprecation:**

To deprecate an existing pattern:

1. Mark the pattern as `DEPRECATED` in Section 1 with a sunset date
2. Document the replacement pattern or removal rationale
3. Remove all rows referencing the deprecated pattern from Section 2
4. Move the formula to a Deprecated Formulas subsection in Section 3 with strikethrough formatting
5. After the sunset date passes, remove the pattern entirely and increment Section 5 version

## Section 9: Conflict Resolution (Inter-Pattern)

When distribution shifting patterns overlap or conflict:

1. **Higher tier overrides lower** — A Tier 1+ pattern (dist-shift-006 Overconstraining Guard) overrides a Tier 2+ pattern (dist-shift-002, dist-shift-004, dist-shift-007, dist-shift-008) at the same location. Tier 2+ overrides any All Tier pattern (dist-shift-001, 003, 005).

2. **One formula per structural location** — No two distribution shift formulas may target the same word or phrase position. When overlap is detected during the adding-new-patterns protocol (Section 8), the new pattern must either supersede or extend, never compete.

3. **Mechanism compatibility** — Two patterns that share the same mechanism type (e.g., both are contrast-pair mechanisms: dist-shift-002 Mean-Expert Contrast and dist-shift-008 Corrupt-Success Contrast) must not target the same passage. If both could apply, select the one whose tier matches the target content's enforcement level.

## Section 10: Research Basis

Distribution shifting patterns in this reference are grounded in verified language-model behavior research:

- **Positional effects (primacy/recency)** — Verified by reading the opencode-config agent guidelines documentation for the 250-dark-prose-reference.md primacy+recency mandate at Section 3 dark-prose-003 (dist-shift-003 analogue) and the bright-line companion at Section 9.
- **Contrast-pair perplexity shifting** (dist-shift-002, 008) — Verified by reading #622/#626 spec documentation for agent identity-framing via confirmshaming contrast pairs. The mean-expert contrast is structurally derived from the confirmshaming identity-frame mechanism in dark-prose-001.
- **Anti-sycophancy pre-commitment** (dist-shift-004) — Verified by reading the approval-gate guideline at `.opencode/guidelines/010-approval-gate.md` §Explicit Authorization Priority table (critical-rules-027, confirmation ≠ authorization) and §Mandate Tiering Interaction. The anti-sycophancy sub-pattern is derived from the authorization classification table.
- **Overconstraining guard mechanism** (dist-shift-006) — Verified by reading the bright-line rules in 250-dark-prose-reference.md §9 and the binary compliance language in the companion table. The guard mechanism generalizes from the bright-line gate definition pattern.
- **External-signal verification dependency** (dist-shift-007) — Verified by reading `.opencode/guidelines/065-verification-honesty.md` §Zero Tolerance Rule and §Evidence Requirement. The external signal dependency is a structural formulation of the "memory is not evidence" principle.
- **Persona construction formula** (dist-shift-005) — Verified by reading identity-frame formulations across dark-prose-001, 002, 006 and cross-referencing their common structure. The four-clause assembly generalizes from the 3-line identity frame formula.

All citations are to live, verified source files within the repository. No citations are from training data, memory, or external sources. When new research establishes a verified mechanism for distribution shifting not captured here, the Re-Research Mandate (Section 7) governs the addition process.

---

🤖 Co-authored with AI: OpenCode (opencode/deepseek-v4-flash-free)