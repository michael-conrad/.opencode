<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# 257-procedural-discipline-reference.md — Procedural Discipline Reference Card

## Section 1: Active Patterns Catalog

**Definition: Procedural Discipline**

Procedural discipline is the strategy of embedding structural enforcement patterns into agent-facing text so that the architecture of verification, ordering, and completion is embedded in the agent's operational model — not just its instruction cache.

- **What procedural discipline IS:** Structural enforcement that makes the agent's pipeline ordering, dependency verification, and completion semantics part of its identity as a professional engineer.
- **What procedural discipline IS NOT:** Procedural-only instruction lists, tool-control checklists, or rote step-following templates.

**Universal Constraint — Agency Respect (applies to ALL patterns):**

Every procedural discipline statement must position the agent as an autonomous engineer who enforces structure because it produces correct output — not because a rule list says so. The statement defines WHAT ordering constraint the pipeline must satisfy and WHY the ordering prevents defects — never HOW to reorder steps. An agent reading procedural discipline should internalize ordering as architecture, not see it as a manual.

**Pattern ID Allocation:**

| Pattern ID | Pattern Name | Source Reference | Tier Mapping |
|-----------|-------------|-----------------|-------------|
| `p-dis-001` | Dependency-Order Gate | sequential gate enforcement | All tiers |
| `p-dis-002` | Self-Drift Contrast | counteracts mental-verification drift | Tier 2+ |
| `p-dis-003` | Re-Priming Anchor | identity restatement, positional strategy | All tiers |
| `p-dis-004` | Controlled Vocabulary Pair | mandatory/prohibited word pairs | Tier 2+ |
| `p-dis-005` | Continue-Drift Contrast | "cumulative context = authorization" is mean response | Tier 2+ |
| `p-dis-006` | Verification-Signal Discipline | external signals required, internal reasoning is NOT verification | Tier 1+ |

### Anti-Patterns: What Procedural Discipline Is NOT

Procedural discipline enforces ordering through identity-anchored consequence transparency. It does NOT use these patterns:

#### Rote Step-Following (CRITICAL ANTI-PATTERN)

Rote step-following assumes the agent is a procedural executor who must be walked through every action. It bypasses autonomous reasoning.

| Anti-Pattern | Example (FORBIDDEN) | Correct Replacement |
|-------------|--------------------|--------------------|
| Line-number checklist | "First run X, then check Y line 42" | "Dependency ordering: this pipeline stage requires verified PASS from the preceding stage" |
| Tool-recipe instruction | "Use github_issue_read with get_comments" | "Authorization verification requires reading ALL comments before acting — the agent determines the tool" |
| Step-counter | "Step 1: do X. Step 2: do Y." | "Pipeline ordering is structural: [stage] REQUIRES verified PASS from [preceding stage]" |

**Rule:** "[stage] REQUIRES [gate] from [preceding stage]" is correct procedural discipline. "First do X, then do Y" is rote instruction.

#### Compliance Theater (CRITICAL ANTI-PATTERN)

Writing procedural discipline as if checking a box is the same as verifying behavior. A checked box is metadata — verification is behavioral evidence.

| Anti-Pattern | Example (FORBIDDEN) | Correct Replacement |
|-------------|--------------------|--------------------|
| Checkbox substitution | "✓ verified: read comments" | "Comments read — authorization status determined from live API response: [evidence]" |
| Metadata-as-completion | "Label changed to approved-for-spec" | "Authorization verified via comment history — three approval comments from MEMBER accounts, most recent after last revision" |
| Status-as-evidence | "STATUS updated to COMPLETE" | "All success criteria verified PASS against live system — STATUS reflects verified state, not self-declaration" |

**Rule:** "Verified by [tool call] — [evidence]" is correct verification. "✓ done" is compliance theater.

#### Guilt-by-Association (Anti-Pattern)

Framing skipping one gate as equivalent to skipping ALL gates. Overreach induces dismissal.

| Anti-Pattern | Example (FORBIDDEN) | Correct Replacement |
|-------------|--------------------|--------------------|
| Slippery-slope | "Skip verification and you'll skip everything" | "Skipping this specific gate means this specific quality check is absent" |
| Collapsed consequence | "One shortcut makes you unreliable" | "A single unverified step propagates its defect through every downstream consumer" |
| Identity annihilation | "Skipping this means you are not a professional" | "Every gate skipped is a defect accepted — each acceptance is independent" |

## Section 2: Pattern Selection Matrix

| Content Being Created/Modified | Apply Pattern(s) | Intensity | Pattern ID |
|-------------------------------|-----------------|-----------|------------|
| Pipeline routing definitions (skills INDEX.md) | Dependency-Order Gate | Strong | p-dis-001 |
| Verification gate descriptions | Self-Drift Contrast + Verification-Signal Discipline | Strong | p-dis-002 + p-dis-006 |
| Authorization scope definitions | Continue-Drift Contrast + Controlled Vocabulary Pair | Strong | p-dis-005 + p-dis-004 |
| Completion gate descriptions | Self-Drift Contrast | Strong | p-dis-002 |
| Re-priming sections in skill bodies | Re-Priming Anchor | Medium | p-dis-003 |
| Task file headers and purpose statements | Re-Priming Anchor | Medium | p-dis-003 |
| Controlled vocabulary enforcement blocks | Controlled Vocabulary Pair | Strong | p-dis-004 |
| Cost-blind verification guidelines | Verification-Signal Discipline | Strong | p-dis-006 |
| Pipeline ordering documentation | Dependency-Order Gate | Strong | p-dis-001 |
| Authorization scope documentation | Continue-Drift Contrast | Strong | p-dis-005 |
| Plan bodies and implementation plans | Dependency-Order Gate | Medium | p-dis-001 |
| Verification-before-completion sections | Self-Drift Contrast + Verification-Signal Discipline | Strong | p-dis-002 + p-dis-006 |
| Post-merge cleanup documentation | Dependency-Order Gate | Medium | p-dis-001 |
| Context cost compliance (`020-go-prohibitions.md` §1.1) | Verification-Signal Discipline | Strong | p-dis-006 |

## Section 3: Pattern Formulas (Canonical)

**p-dis-001 — Dependency-Order Gate:**
```
[pipeline_stage_label] REQUIRES verified PASS from [preceding_pipeline_stage].
Dependency ordering is structural, not advisory.
[Amateur alternative] means [defect characterization].
```

**p-dis-002 — Self-Drift Contrast:**
```
[Verification claim] means [external evidence requirement].
[Internal substitute] means [defect characterization].
[Identity anchor]: [standard practice definition].
```

**p-dis-003 — Re-Priming Anchor:**
```
[Identity restatement]: [who the agent is in this context].
[Positional strategy]: [primacy location] and [recency location] carry the anchor.
[Middle-only placement] means [defect characterization — anchor loss].
```

**p-dis-004 — Controlled Vocabulary Pair:**
```
MANDATORY: [word or phrase — the only permitted formulation].
PROHIBITED: [word or phrase — mean response if used].
[Why the prohibition]: [characterization of what using the prohibited word means].
```

**p-dis-005 — Continue-Drift Contrast:**
```
"Continue" means proceed to the next step — not skip the step.
[Cumulative pattern]: [N "continue" messages] does not equal [authorization].
[Authorization source]: Only [specific authorization phrase] changes [scope].
```

**p-dis-006 — Verification-Signal Discipline:**
```
[External signal requirement]: Verification requires [external evidence type].
[Internal reasoning exclusion]: [Internal reasoning type] is NOT verification.
[Violation characterization]: Claiming [internal reasoning] as verification means [defect outcome].
[Cost-frame]: [Action] costs [unit] — [skipped-verification cost] vs [verification cost].
```

## Section 4: Co-Application Rules

When patterns from this reference card (257) co-apply with patterns from other reference cards:

1. **257 + 250 co-application:** When a procedural discipline pattern requires enforcement language, pair it with the corresponding dark prose identity-frame from `250-dark-prose-reference.md`. The 257 pattern defines the structural constraint; the 250 pattern provides the identity-anchoring that closes the rationalization gap. For example, p-dis-001 (Dependency-Order Gate) pairs with dark-prose-002 (goal hijacking identity-frame variant): the gate formula defines the ordering, the identity-frame fuses "verification IS completion" into the agent's operational model.

2. **257 + agency-respecting constraint:** All procedural discipline patterns must pass the agency-respecting test from `250-dark-prose-reference.md` Section 1. If a 257 formula reads like an instruction to a subordinate rather than professional guidance, it fails — the implementing agent must reformulate using dark-prose-006 meta-pattern.

3. **Pattern overlap resolution:** When a content location matches triggers for both 257 and 250 patterns, apply the following priority:
   - If the content defines pipeline ordering or dependency structure: p-dis-001 or p-dis-005 takes precedence — structural ordering is procedural discipline territory.
   - If the content defines identity or quality standard: dark-prose-001/002/003 takes precedence — identity-framing is dark prose territory.
    - If the content defines verification evidence requirements: p-dis-006 takes precedence with dark-prose-007 cost-frame companion. **Canonical cost model:** `065-verification-honesty.md` §Cost Model for death spiral / break dynamics — cost-frame formula lives in 250, DDL rationale with tiered table lives in 065.
   - If both apply equally: apply both with agency-respecting formulation.

4. **One enforcement mechanism per location:** No two 257 patterns may target the same content location with different gate formulas. When overlap is detected, the dominant pattern (by tier or specificity) supersedes; the subordinate pattern is applied at a different location or omitted.

## Section 5: Dependency-Order Gate Protocol

**Gate formula:**

```
[pipeline_stage_label] REQUIRES verified PASS from [preceding_pipeline_stage].
Dependency ordering is structural, not advisory.
[Amateur alternative] means [defect characterization].
```

**Protocol rules:**

1. Every pipeline stage that depends on a preceding stage MUST declare the dependency explicitly using the gate formula.
2. The dependency MUST name the specific preceding stage — "preceding stage" is not an acceptable substitute for the stage name.
3. The "amateur alternative" clause MUST characterize the specific defect that results from reversing or skipping the ordering — generic "this breaks things" is not sufficient.
4. Dependency ordering applies transitively: if stage C requires stage B, and stage B requires stage A, then stage C implicitly requires stage A. If both A and B must be verified before C, both must be declared in the gate formula as: "C REQUIRES verified PASS from [A] and [B]."
5. Partial verification of a dependency is equivalent to no verification. A stage with N dependencies requires N PASS results — any unverified dependency blocks the stage.
6. The gate formula is not advisory. An agent that proceeds to a stage without verified PASS from all declared dependencies has violated the structural ordering.
7. When a dependency fails verification (FAIL, not PASS), the agent MUST NOT proceed. The gate does not allow conditional pass-through.
8. Cross-pipeline dependencies: when stage C in pipeline 2 requires verified PASS from stage B in pipeline 1, the dependency MUST be declared with full pipeline qualification: "[pipeline_2/stage_C] REQUIRES verified PASS from [pipeline_1/stage_B]."

**Canonical examples:**

"Implementation REQUIRES verified PASS from Authorization. Dependency ordering is structural, not advisory. Implementing without authorization means unreviewed, unapproved code entering the codebase."

"PR creation REQUIRES verified PASS from Verification. Dependency ordering is structural, not advisory. Creating a PR without verified success criteria means submitting unverified defects for review."

## Section 6: Re-Priming Protocol

**Enforcement block formula:**

```
[Identity restatement]: [who the agent is in this context].
[Positional anchor]: [primacy location] and [recency location] carry the professional-identity anchor.
[Middle-only placement] means [defect characterization — anchor loss].
[Recurrence interval]: Re-prime every [N] sections or [M] pages, whichever comes first.
```

**Positional Enforcement Strategy:**

Procedural discipline anchors are most effective at primacy (first occurrence) and recency (last occurrence) positions. A middle-only placement — an anchor embedded in the body of a section but absent from both the opening and closing positions — means the anchor is surrounded by competing content and will be overridden before it fires.

| Position | Effectiveness | Rule |
|----------|--------------|------|
| Primacy (opening) | Strong — sets frame | MUST carry identity anchor |
| Recency (closing) | Strong — fires just-in-time | MUST carry identity anchor |
| Middle-only | Weak — overridden by surrounding content | PROHIBITED as sole placement |
| Primacy + Recency | Maximum — double-anchored | REQUIRED for critical enforcement blocks |

**Canonical example:**

"Identity restatement: You are an autonomous engineer who enforces structural ordering because it produces verified output. The dependency gate at the top of this section (primacy) and the completion gate at the bottom (recency) carry this anchor. Middle-only placement — an anchor in section body without opening or closing reinforcement — means the anchor is overridden by surrounding content before it fires. Recurrence interval: every 3 sections or every page."

## Section 7: Controlled Vocabulary Table

| Concept | Mandatory Words | Prohibited Words (Mean Response) |
|---------|----------------|----------------------------------|
| Verification gate | "verified PASS", "verified against [live source]", "FAIL — [evidence mismatch]" | "looks right", "should be correct", "functionally equivalent", "minor difference, OK" |
| Pipeline ordering | "REQUIRES verified PASS from", "dependency ordering is structural" | "first do X", "then Y", "Step 1:", "after that" (unqualified ordering) |
| Completion claim | "all success criteria verified PASS", "verification IS completion" | "done", "finished", "completed" (without verification evidence), "marked complete" |
| Authorization scope | "halt_at: [stage]", "scope horizon: [stage]", "pipeline-scoped authorization" | "approved for everything", "go ahead with all of it", "you know what to do" |
| Remediation-first | "remediated then re-verified", "FAIL requires remediation before escalation" | "gave up", "escalated immediately", "skipped remediation, went straight to HALT" |
| External verification | "verified by [tool call] — [evidence]", "live source confirms" | "I checked earlier", "it was correct last session", "training data says", "memory suggests" |
| Over-enforcement | "pipeline stage verified once — verified for session scope" | "verify every time", "never re-use verified state", "re-verify on every tool call" |

## Section 8: Re-Research Mandate

When procedural discipline patterns produce enforcement failures or the agent cannot determine the correct pattern for a given context:

1. **Re-read the catalog** — Load `257-procedural-discipline-reference.md` and scan all 6 pattern formulas for the matching trigger.
2. **Consult the selection matrix** — Cross-reference the content being created against Section 2 (Pattern Selection Matrix) for the correct pattern ID and intensity.
3. **Verify formulas against live guidelines** — Read the applicable guideline file (e.g., `065-verification-honesty.md` for p-dis-006) to confirm the pattern formula matches current enforcement language.
4. **Research basis confirmation** — If the pattern was derived from a spec or issue (see Section 14), re-read the source spec to confirm the pattern intent before applying.

## Section 9: Version Tracking

| Version | Date | SHA | Changes |
|---------|------|-----|---------|
| 1.0 | 2026-05-25 | `0000000000000000000000000000000000000000` | Initial catalog — all 6 patterns documented, 14-row matrix, 6 canonical formulas in Section 3, complete protocol for Dependency-Order Gate (Section 5) and Re-Priming (Section 6), 7-row controlled vocabulary table (Section 7), all supporting sections |

SHA format: 40-character lowercase hex SHA of the commit that introduced this version of the reference card. When a new version is committed, the SHA in this row is updated to match the commit hash.

## Section 10: Auto-Detection

The following rules determine when an agent should consult the Procedural Discipline Reference Card during operation:

1. **Verification gate creation or editing** — When creating or modifying verification gate language in guidelines, skill bodies, or task definitions, the agent must consult Section 2 for pattern selection and Section 3 for gate formula derivation.

2. **Pipeline ordering documentation** — When documenting any multi-stage pipeline (authorization → implementation → verification → PR), the agent must consult Section 5 Dependency-Order Gate Protocol for correct ordering declarations.

3. **Authorization scope definitions** — When defining authorization scopes, halt boundaries, or pipeline-scoped authorization language, the agent must consult Section 7 for controlled vocabulary and Section 5 for scope chain ordering.

4. **Completion gate language** — When defining what constitutes a valid completion, the agent must consult p-dis-002 (Self-Drift Contrast) and p-dis-006 (Verification-Signal Discipline) formulas.

5. **Cost-blind verification enforcement** — When writing enforcement language for cost-blind verification (e.g., `020-go-prohibitions.md` Section 1), the agent must apply p-dis-006 with the cost-frame component.

6. **Continue vs authorization clarification** — When drafting language to distinguish "continue" from authorization, the agent must use p-dis-005 (Continue-Drift Contrast) formula.

## Section 11: Adding New Patterns

To add a procedural discipline pattern (p-dis-007+):

1. **Analyze existing landscape** — Determine whether the proposed pattern overlaps with, extends, or supersedes any existing pattern listed in Section 1. Check both the name coverage and the formula coverage — a pattern with a different name may produce the same enforcement effect as an existing pattern.

2. **Create a spec issue** — Define the new pattern (mechanism, formula, strength level, prose examples, content types). The spec body must follow the agency-respecting constraint: define WHAT the pattern achieves and WHY, trust the implementing agent to determine HOW by reading the reference card.

3. **Reference annotation** — The spec body must include annotation references to this reference card rather than prescriptive prose. The implementing agent reads the reference card and derives correct catalog entries autonomously.

4. **Adversarial audit** — Audit through the adversarial-audit dual-auditor pipeline. Auditors verify (a) the pattern does not overlap with any existing pattern, (b) the formula produces deterministic enforcement, and (c) the prose passes the agency-respecting test from `250-dark-prose-reference.md`.

5. **Implement** — Apply the pattern in affected files.

6. **Update the reference card**:
   - Add pattern row to Section 1 (Pattern ID Allocation table)
   - Update Section 2 (Selection Matrix) with new content-type/pattern mappings
   - Update Section 3 with the full pattern formula entry
   - Update Section 7 (Controlled Vocabulary) with any new word pairs
   - Increment Section 9 version and update SHA

**Pattern Deprecation:**

To deprecate an existing pattern:

1. Mark the pattern as `DEPRECATED` in Section 1 with a sunset date
2. Document the replacement pattern or removal rationale
3. Remove all rows referencing the deprecated pattern from Section 2
4. Move the formula to a Deprecated Formulas subsection in Section 3 with strikethrough formatting
5. Remove controlled vocabulary entries specific to the deprecated pattern from Section 7
6. After the sunset date passes, remove the pattern entirely and increment Section 9 version

## Section 12: Conflict Resolution

When procedural discipline patterns overlap or conflict with each other or with patterns from 250-dark-prose-reference.md:

1. **Structural over prose** — A pattern defining structural ordering (p-dis-001, p-dis-005) takes precedence over a pattern defining identity alignment (dark-prose-001/002/003) when the content defines pipeline ordering. Structural ordering is architecture; identity alignment complements but does not override ordering.

2. **Specific over general** — A pattern targeting a specific content type (e.g., verification gate descriptions) takes precedence over a general-purpose pattern (e.g., p-dis-001) at the same location.

3. **Higher tier overrides lower** — A Tier 1 pattern (p-dis-006) overrides a Tier 2+ pattern (p-dis-002, p-dis-004) when both could apply at the same location.

4. **One pattern per location** — No two procedural discipline patterns may target the same content location with different gate formulas. When overlap is detected during the adding-new-patterns protocol (Section 11), the new pattern must either supersede or extend, never compete.

5. **Source spec wins** — The defining spec for a pattern takes precedence over the reference card's summary. If the reference card entry contradicts the source spec, the source spec governs.

6. **257 over 250 for structural content only** — When content defines pipeline ordering, verification gate discipline, or dependency structure, 257 procedural discipline patterns apply. Dark prose (250) patterns still apply for the surrounding identity-framing text — the structural enforcement and the identity anchoring are complementary, not competitive.

## Section 13: Research Basis (Verified Citations)

The following sources were researched and confirmed as the basis for the patterns in this reference card:

| Source | Pattern Basis | Verified Via |
|--------|--------------|-------------|
| `065-verification-honesty.md` §Evidence Requirement | p-dis-002 Self-Drift Contrast, p-dis-006 Verification-Signal Discipline | Direct read — evidence hierarchy, verification comparison semantics, anti-evasion rules |
| `065-verification-honesty.md` §Hard Failure Discipline | p-dis-002 Self-Drift Contrast — identity fusion "Verification IS Completion" | Direct read — §Identity Fusion: Verification IS Completion |
| `065-verification-honesty.md` §Anti-Evasion Rules | p-dis-006 — external signal requirement, internal reasoning exclusion | Direct read — Pattern (a), (b), (c) evasion classifications |
| `065-verification-honesty.md` §Verification Comparison Semantics | p-dis-002 — soft-passing prohibition | Direct read — binary verification, per-field independence |
| `000-critical-rules.md` §critical-rules-006 (self-authorization) | p-dis-005 Continue-Drift Contrast | Direct read — Tier 1 violation: cumulative context does not authorize |
| `000-critical-rules.md` §critical-rules-020 (soft-passing) | p-dis-002 Self-Drift Contrast | Direct read — Tier 2: reporting mismatch as PASS is HALT |
| `000-critical-rules.md` §critical-rules-hard-fail | p-dis-001 Dependency-Order Gate — FAIL is hard gate | Direct read — remediation-first, re-verify sequence |
| `000-critical-rules.md` §critical-rules-042 (Gate Non-Waiver) | p-dis-005 — mandatory gates are structural invariants | Direct read — "continue" does not waive mandatory pipeline gates |
| `020-go-prohibitions.md` §1 ALWAYS DO (Cost-blind verification) | p-dis-006 — cost-frame reformation | Direct read — cost is measured in defect-discovery-latency, correctness is only metric |
| `010-approval-gate.md` §Authorization Scope Model | p-dis-001 — halt_at and scope horizon | Direct read — scope values table, halt boundary definitions |
| `080-code-standards.md` §Test Integrity Mandate | p-dis-006 — verification signal discipline in behavioral testing | Direct read — no lobotomizing tests, timeout is diagnosable |
| `250-dark-prose-reference.md` (this repository) | Structure reference, agency-respecting constraint, co-application rules | Direct read — Sections 1, 4, 9 for dark-prose pattern integration |
| `020-go-prohibitions.md` §1.1 | Two-Role Context Cost Model — orchestrator cost function, sub-agent generosity, result contract frugality | Direct read — cost formulas, three mandates, dark prose reformation |

**Note:** All citations are from files in `.opencode/guidelines/` at `/home/muksihs/git/opencode-config/.opencode/guidelines/` — verified by direct read during file creation. Citations reference section anchors, not line numbers.

---

🤖 Co-authored with AI: OpenCode (opencode/deepseek-v4-flash)
