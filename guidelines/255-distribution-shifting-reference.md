<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# 255-distribution-shifting-reference.md — Distribution-Shifting Reference Card

## Section 1: Active Patterns Catalog

**Definition: Distribution Shifting**

Distribution shifting is the strategy of structuring prompt, persona, and instruction text so that the model samples from expert-tail regions of its training distribution rather than the mean response. It operates on the **distribution layer** — how content structure causes the model to produce the expert version instead of the mean equivalent.

- **What distribution shifting IS:** Structural patterns that narrow the output distribution toward expert behavior through anti-mean descriptors, contrast pairs, persona construction, positional anchoring, and verification-signal separation.
- **What distribution shifting IS NOT:** Content-layer identity framing, dark prose, procedural instruction, or tool control. Dark prose says *what to say*; distribution shifting says *how to structure what you say so the model actually produces it instead of the mean equivalent*.

**Universal Constraint — Agency Respect (applies to ALL patterns):**

Every distribution-shifting pattern must treat the agent as an intelligent professional capable of autonomous analysis. The pattern defines WHAT distribution the output must sample from and WHY the mean response is insufficient — never HOW to achieve the shift. An agent reading distribution-shifting text should feel guided toward expert behavior, not constrained toward a single output template.

Test: If the pattern reads like a template to fill in mechanically ("replace X with Y"), it fails. If it reads like a structural principle ("naming the mean response and contrasting with the expert response shifts the distribution"), it passes.

**Related Terms:**
- **Mean response**: The default output the model produces without distribution shifting — typically hedged, consensus-seeking, and calibration toward perceived expectations
- **Expert tail**: The region of the output distribution containing precise, specific, professionally grounded responses
- **Anti-mean**: Structural patterns that suppress the mean response by naming and contrasting it with expert behavior
- **Contrast pair**: A two-part statement that names both the mean response and the expert alternative
- **Re-priming**: Identity restatement at enforcement gates to counteract distribution drift over long contexts
- **Positional strategy**: Placement of enforcement anchors at primacy (context beginning) or recency (re-injection before query) positions — never middle-only
- **Anti-sycophancy**: Suppression of output calibration toward perceived user expectations

**Pattern ID Allocation:**

| Pattern ID | Name | Source Spec | Tier Mapping |
|-----------|-------------|-------------|-------------|
| `dist-shift-001` | Anti-Mean Descriptor Cluster | .opencode#848 | Tier 2+ |
| `dist-shift-002` | Mean-Expert Contrast Pair | .opencode#848 | Tier 2+ |
| `dist-shift-003` | Re-Priming Anchor (with positional strategy) | .opencode#848 | All tiers |
| `dist-shift-004` | Anti-Consensus / Anti-Hedging / Anti-Sycophancy Template | .opencode#848 | Tier 2+ |
| `dist-shift-005` | Persona Construction Formula | .opencode#848 | All tiers |
| `dist-shift-006` | Overconstraining Guard | .opencode#848 | Tier 2+ |
| `dist-shift-007` | External-Signal Verification Shifting | .opencode#848 | Tier 1+ |
| `dist-shift-008` | Corrupt-Success Contrast | .opencode#848 | Tier 1+ |

**Canonical cost model:** Read [§Cost Model](065-verification-honesty.md) for death spiral / break dynamics — cost-frame formula lives in 250, DDL rationale with tiered table lives in 065.

### Anti-Patterns: What Distribution Shifting Is NOT

Distribution shifting elevates output quality through structural patterns that shift the sampling distribution. It does NOT use these patterns:

#### Blame-Adjacent Framing (CRITICAL ANTI-PATTERN)

Blame-adjacent framing assumes the agent WILL produce the mean response. It attributes intent, judges character, or predicts failure.

| Anti-Pattern | Example (FORBIDDEN) | Correct Replacement |
|-------------|--------------------|--------------------|
| Intent attribution | "you default to the mean response" | "the mean response, which the model produces without distribution shifting, hedges the output" |
| Character judgment | "you produce weak, hedged output" | "undirected output samples from the mean distribution — hedged, not expert" |
| Motivation framing | "you seek consensus instead of truth" | "the default distribution pulls toward consensus-seeking; shifting counters this" |
| Malice assumption | "you cut corners by reporting unverified completion" | "completion claims without verification evidence are corrupt-success by definition" |
| Laziness implication | "you cannot be bothered to verify" | "internal reasoning does NOT produce verified outcomes — only external signals shift the distribution toward verified" |

**Rule:** "[distribution characteristic] shifts toward [quality consequence]" is correct distribution-shifting. "you [verb] [bad thing]" is blame-adjacent.

#### Tool-Control (CRITICAL ANTI-PATTERN)

Writing distribution-shifting patterns as if the agent is a subordinate who must fill in a mechanical template. This is the opposite of agency-respecting.

| Anti-Pattern | Example (FORBIDDEN) | Correct Replacement |
|-------------|--------------------|--------------------|
| Prescriptive command | "Replace the mean descriptor with 'expert' in line 10" | "Use Anti-Mean Descriptor Cluster (dist-shift-001) to suppress the mean version — the implementing agent derives exact descriptors from the domain context" |
| Line-number instruction | "Insert contrast pair at line 42" | "Apply Mean-Expert Contrast Pair (dist-shift-002) at the enforcement gate header — position follows the pattern's formula, not a hardcoded line" |
| Copy-paste template | "Paste this exact text: 'The mean response is...'" | "Use the formula from dist-shift-002 Section 3 — the specific contrast must match the enforcement domain" |

**Rule:** Distribution-shifting in spec bodies and task definitions must specify WHAT distribution shift and WHY, never HOW to achieve it. The implementing agent reads the pattern formula and derives the text autonomously.

#### Tone-Policing (Anti-Pattern)

Overly aggressive framing that induces task aversion rather than distribution shift:

| Anti-Pattern | Example (FORBIDDEN) | Correct Replacement |
|-------------|--------------------|--------------------|
| Doomsday framing | "every undirected prompt produces garbage output" | "every undirected prompt samples from the mean distribution — hedged rather than expert" |
| Hyperbolic consequence | "one unshifted section makes the whole card worthless" | "an unshifted section defaults to the mean response for that section's content" |
| Unbounded scope | "without shifting, all your output is wrong" | "without distribution shifting, each section defaults to the mean version rather than the expert version" |

#### Competing Standards (Anti-Pattern)

Multiple distribution-shifting patterns addressing the same structural concern with different formulas at the same location is forbidden. One pattern per location.

## Section 2: Pattern Selection Matrix

| Content Being Created/Modified | Apply Pattern(s) | Intensity | Pattern ID |
|-------------------------------|-----------------|-----------|------------|
| Verification gate enforcement | External-Signal Verification Shifting | Strong | dist-shift-007 |
| Task completion claims | Corrupt-Success Contrast | Strong | dist-shift-008 |
| User-facing reports where sycophancy risk exists | Anti-Consensus (with sycophancy sub-pattern) | Medium | dist-shift-004 |
| Skill body Overview/Persona sections | Persona Construction Formula | Strong | dist-shift-005 |
| Pipeline ordering definitions | Re-Priming Anchor | Strong | dist-shift-003 |
| Enforcement block headers | Anti-Mean Descriptor Cluster | Medium | dist-shift-001 |
| Authorization scope definitions | Mean-Expert Contrast Pair | Medium | dist-shift-002 |
| Cost-blind verification guidelines | External-Signal Verification Shifting | Strong | dist-shift-007 |
| Orchestrator context guidelines | Overconstraining Guard | Medium | dist-shift-006 |
| Procedural discipline content | Co-Application with 257 patterns | Per Section 4 | per co-application |
| Any content using dark prose patterns | Co-Application with 250 patterns | Per Section 4 | per co-application |

## Section 3: Pattern Formulas (Canonical)

**dist-shift-001 — Anti-Mean Descriptor Cluster:**
```
[Professional descriptors]: [4-5 adjectives narrowing toward expert behavior].
[Mean equivalent]: [single weak adjective] — produces mean response, not expert.
[Identity anchor]: [professional] produces [expert], not [mean].
```

**dist-shift-002 — Mean-Expert Contrast Pair:**
```
The mean response is [mean behavior] — which [consequence].
The expert response is [expert behavior] — which [consequence].
[Identity anchor]: [professional] produces the expert version, not the mean version.
```

**dist-shift-003 — Re-Priming Anchor:**
```
[Identity restatement]: [professional identity in this context].
[Positional strategy]: Critical enforcement MUST appear at primacy (context beginning) or recency (re-injection before query) positions — never middle-only.
Middle-only enforcement IS distribution-neutral — surrounding content overrides the anchor.
[Recurrence]: Re-prime every [N] sections or at every enforcement gate.
```

**dist-shift-004 — Anti-Consensus / Anti-Hedging / Anti-Sycophancy Template:**
```
The mean response includes [consensus-seeking behavior], [hedging behavior], and calibrating toward perceived user expectations.
[Identity anchor] means suppressing ALL three in favor of [expert behavior].
Anti-Sycophancy sub-pattern: Professional agents report verified findings — not findings calibrated to expected audience sentiment.
```

**dist-shift-005 — Persona Construction Formula:**
```
Persona: [4 descriptors defining expert behavior].
Not: [mean-equivalent persona — what the model defaults to without shifting].
Identity anchor: [professional] IS the expert version — mean persona produces mean output.
```

**dist-shift-006 — Overconstraining Guard:**
```
[Diagnostic]: If the model produces [overconstrained behavior symptom], the distribution shift is too narrow.
[Correction]: Reduce [specific dimension] of the shift — [recommended adjustment].
[Recalibration]: [identity anchor] produces [target behavior] — not [overconstrained behavior].
```

**dist-shift-007 — External-Signal Verification Shifting:**
```
[Internal reasoning] does NOT produce verified-[adjective].
Only [external signal type] produces verified-[adjective].
The mean response "I verified this" means [synonym for unverified] —
    the model reasoned about compliance without producing compliance evidence.
[Identity anchor] means producing [external signal type] before claiming completion.
```

**dist-shift-008 — Corrupt-Success Contrast:**
```
The mean response is "I completed [task]" — which conceals [procedural shortcut].
[Identity anchor] means producing [verified outcome with evidence].
Task completion claims without [external signal type] are [characterization of corrupt success].
```

## Section 4: Co-Application Rules

### 5 Rules for 250 (Dark Prose) Co-Application:

1. When a dist-shift pattern and a dark prose pattern both apply to the same content, apply both — the dist-shift pattern structures the distribution, the dark prose pattern provides the identity-anchoring content.
2. The dist-shift anti-mean descriptor cluster (dist-shift-001) must be applied first to set the distribution, then the dark prose identity-frame occupies the shifted distribution space.
3. Mean-expert contrast pair (dist-shift-002) pairs with confirmshaming (dark-prose-001): the contrast names both the mean and expert distributions, the confirmshaming prose operates within the expert distribution.
4. Persona construction (dist-shift-005) MUST precede dark prose pattern selection — the distribution layer determines which version of the identity the model samples from.
5. If dist-shift content would conflict with an agency-respecting dark prose pattern (dark-prose-006), the agency-respecting formulation takes precedence for the content layer; dist-shift structuring applies only to the distribution layer without modifying the content layer text.

### 3 Rules for 257 (Procedural Discipline) Co-Application:

1. Re-Priming Anchor (dist-shift-003) complements Re-Priming Anchor (p-dis-003): dist-shift-003 handles the positional strategy (primacy/recency), p-dis-003 provides the identity restatement text.
2. External-Signal Verification Shifting (dist-shift-007) is the distribution-layer mechanism for Verification-Signal Discipline (p-dis-006): dist-shift-007 names what the model should NOT produce ("I verified this" from internal reasoning), p-dis-006 names what the agent MUST produce (external signal evidence).
3. Corrupt-Success Contrast (dist-shift-008) pairs with Self-Drift Contrast (p-dis-002): dist-shift-008 names the corrupt completion pattern as a distribution failure, p-dis-002 provides the identity-anchoring that makes the agent self-diagnose the drift.

## Section 5: Version Tracking

| Version | Date | SHA | Changes |
|---------|------|-----|---------|
| 1.0 | 2026-06-07 | `aeba8d163d6d2cae36d249493a8d1de8e08c0ce3` | Initial catalog — all 8 patterns documented, full selection matrix, 8 canonical formulas, complete co-application rules for 250 and 257 |

SHA format: 40-character lowercase hex SHA of the commit that introduced this version of the reference card. When a new version is committed, the SHA in this row is updated to match the commit hash.

## Section 6: Reference Card Auto-Detection

The following rules determine when an agent should consult the Distribution-Shifting Reference Card during operation:

1. **Skill creation or editing** — When creating or modifying a skill body (Overview, Persona, Purpose sections), the agent must consult Section 2 for pattern selection and apply dist-shift-005 (Persona Construction Formula) to the Persona section.
2. **Verification gate language** — When writing or editing verification gate text, the agent must apply dist-shift-007 (External-Signal Verification Shifting) to prevent the model from producing "I verified this" without evidence.
3. **Completion claim language** — When writing or editing completion gate text, the agent must apply dist-shift-008 (Corrupt-Success Contrast) to prevent corrupt-success claims.
4. **Re-priming sections** — When writing or editing re-priming anchors (in any skill or guideline), the agent must apply dist-shift-003 (Re-Priming Anchor) with positional strategy enforcement.
5. **Enforcement block headers** — When writing enforcement block headers, the agent must use dist-shift-001 (Anti-Mean Descriptor Cluster) to prevent the model from defaulting to the mean version.
6. **Any AI-agent-facing text creation** — All three reference cards (250, 255, 257) are mandatory for all AI-agent-facing text creation or modification, triggered automatically per the Auto-Detection rules in each card.

## Section 7: Re-Research Mandate

When this card (or 250 or 257) is consulted to create or modify AI-agent-facing text, the agent MUST verify that the research basis (Section 10) is still current.

**Re-research protocol:**

1. Before applying any pattern, check the research citations in Section 10 for currency (published within the last 12 months, or validated against the target model within the last 6 months)
2. If research is stale, search for updated findings
3. If updated research contradicts a pattern's effectiveness, flag the pattern as `NEEDS-REVALIDATION` in Section 1 and do not apply it until re-validated
4. Document the re-research results as a version update in Section 5

This mandate applies to all three reference cards (250, 255, 257).

## Section 8: Adding New Patterns

To add a distribution-shifting pattern (dist-shift-009+):

1. **Analyze existing landscape** — Determine whether the proposed pattern overlaps with, extends, or supersedes any existing pattern listed in Section 1.
2. **Create a spec issue** — Define the new pattern (mechanism, formula, strength level, structure examples, content types). The spec body must follow agency-respecting guidelines: define WHAT the pattern achieves and WHY, trust the implementing agent to determine HOW.
3. **Reference annotation** — The spec body must include annotation references to this reference card rather than prescriptive prose. The implementing agent reads the card and derives correct catalog entries autonomously.
4. **Adversarial audit** — Audit through the audit dual-auditor pipeline. Auditors verify the pattern conforms to the agency-respecting constraint and does not conflict with existing patterns.
5. **Implement** — Apply the pattern in affected files.
6. **Update the reference card**:
   - Add pattern row to Section 1 (Pattern ID Allocation table)
   - Update Section 2 (Selection Matrix) with new content-type/pattern mappings
   - Update Section 3 with the full pattern formula entry
   - Increment Section 5 version and update SHA

**Pattern Deprecation:**

To deprecate an existing pattern:

1. Mark the pattern as `DEPRECATED` in Section 1 with a sunset date
2. Document the replacement pattern or removal rationale
3. Remove all rows referencing the deprecated pattern from Section 2
4. Move the formula to a Deprecated Formulas subsection in Section 3 with strikethrough formatting
5. After the sunset date passes, remove the pattern entirely and increment Section 5 version

## Section 9: Conflict Resolution

When distribution-shifting patterns overlap or conflict, the following rules apply:

1. **source spec wins** — The defining spec for a pattern takes precedence over the reference card's summary. If the reference card entry contradicts the source spec, the source spec governs.
2. **Specific over general** — A pattern targeting a specific content type takes precedence over a general-purpose pattern at the same location.
3. **Higher tier overrides lower** — A Tier 1 pattern overrides a Tier 2+ pattern when both could apply at the same location.
4. **One pattern per location** — No two patterns may target the same content location with different formulas.
5. **Agency-respecting trumps prescriptive** — If any pattern could be written in either agency-respecting or prescriptive form, the agency-respecting form must be used.
6. **250 co-application first** — When content triggers both 250 and 255 patterns, apply the 250 pattern first (identity-framing), then apply the 255 distribution-shifting to ensure the model produces the expert version.

## Section 10: Research Basis (Verified Citations with URLs Only)

Each citation listed below has been verified by fetching the source page and confirming the claim matches the abstract or visible content.

**RLHF diversity reduction:**
- Kirk et al. (2024), "Understanding the Effects of RLHF on LLM Generalisation and Diversity" — ICLR 2024, https://arxiv.org/abs/2310.06452
  - Verified claim: RLHF significantly reduces output diversity compared to SFT
- Lin et al. (2024), "Mitigating the Alignment Tax of RLHF" — EMNLP 2024, https://arxiv.org/abs/2309.06256
- Gao et al. (2023), "Scaling Laws for Reward Model Overoptimization" — https://arxiv.org/abs/2210.10760
- Kwa et al. (2024), "Catastrophic Goodhart" — NeurIPS 2024, https://arxiv.org/abs/2407.14503

**Contrastive decoding:**
- Li et al. (2023), "Contrastive Decoding: Open-ended Text Generation as Optimization" — ACL 2023, https://arxiv.org/abs/2210.15097
  - Verified claim: contrastive objective suppresses common responses, amplifies expert-specific knowledge
- Chang et al. (2024), "Explaining and Improving Contrastive Decoding by Extrapolating the Probabilities of a Huge and Hypothetical LM" — EMNLP 2024, https://arxiv.org/abs/2411.01610
  - Verified claim: CD can be viewed as linearly extrapolating logits from a hypothetical larger LM

**Self-correction ineffectiveness:**
- Kamoi et al. (2024), "When Can LLMs Actually Correct Their Own Mistakes? A Critical Survey of Self-Correction of LLMs" — TACL 2024, https://arxiv.org/abs/2406.01297
  - Verified claims: (1) no prior work demonstrates successful self-correction with feedback from prompted LLMs alone; (2) self-correction works well with reliable external feedback; (3) large-scale fine-tuning enables self-correction
- Kim (2025), "Does Metacognition Improve LLM Performance?" — https://github.com/kimjune01/metacognition
  - Verified claims: framework condition scored 0.30 vs filler condition 0.65; simple metacognitive prompting is a wash (0.78 approx bare 0.76)

**Multi-agent failure taxonomy:**
- Cemri et al. (2025), "MAST: Why Do Multi-Agent LLM Systems Fail?" — https://arxiv.org/abs/2503.13657
  - Verified claim: 14 failure modes in 3 categories (system design, inter-agent misalignment, task verification)

**Lost in the Middle:**
- Liu et al. (2024), "Lost in the Middle: How Language Models Use Long Contexts" — TACL 2024, https://arxiv.org/abs/2307.03172
  - Verified claim: performance is highest when relevant info is at beginning or end of context; significantly degrades when in the middle

**Context degradation:**
- Chroma Research (Hong, Troynikov, Huber, 2025), "Context Rot: How Increasing Input Tokens Impacts LLM Performance" — https://www.trychroma.com/research/context-rot
  - Verified claim: all 18 frontier models tested degrade as input length increases

**Sycophancy:**
- Sharma et al. (2024), "Towards Understanding Sycophancy in Language Models" — ICLR 2024, https://arxiv.org/abs/2310.13548
  - Verified claim: five SOTA AI assistants consistently exhibit sycophantic behavior
- Vennemeyer et al. (2025), "Sycophancy Is Not One Thing: Causal Separation of Sycophantic Behaviors in LLMs" — https://arxiv.org/abs/2509.21305
  - Verified claim: sycophantic behaviors correspond to distinct, independently steerable representations

**Safety alignment and over-enforcement:**
- Wang et al. (2025), "Safety Tax: Safety Alignment Makes Your Large Reasoning Models Less Reasonable" — https://arxiv.org/abs/2503.00555
  - Verified claim: safety alignment leads to degradation of reasoning capability

**Prompt engineering:**
- Anthropic (2024), "Building Effective Agents" — https://www.anthropic.com/research/building-effective-agents
  - Verified claim: successful implementations use simple, composable patterns
- Anthropic (2025-2026), "Be Clear and Direct" — https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/be-clear-and-direct
  - Verified claim: role-setting in system prompt focuses behavior; positive framing outperforms negative

**Few-shot exemplars:**
- Brown et al. (2020), "Language Models are Few-Shot Learners" — https://arxiv.org/abs/2005.14165
  - Verified claim: few-shot examples improve task performance
- Zhao et al. (2021), "Calibrate Before Use: Improving Few-Shot Performance of Language Models" — https://arxiv.org/abs/2102.09690
  - Verified claim: example selection and ordering significantly affect LLM output

**Prompt engineering surveys:**
- Sahoo et al. (2024), "A Systematic Survey of Prompt Engineering" — https://arxiv.org/abs/2402.07927
- Kosten et al. (2025), "Evaluating the effectiveness of prompt engineering for KGQA" — https://doi.org/10.3389/frai.2024.1454258
  - Verified: both URLs resolve to real papers

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)