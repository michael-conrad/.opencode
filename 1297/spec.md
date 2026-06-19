## Summary

The `writing-plans` skill&#39;s `create` task currently produces flat per-item dispatch tables. This is replaced with actionable, enumerated, flat-sequential checklists with sub-bullet metadata.

LLMs read linearly — they do not loop. Plans must list every step in sequence as a numbered `- [ ] N.` checkbox with sub-bullets containing gates, SC references, commands, verification data, and the dispatch mode. Dispatch tables are removed entirely.

## Motivation

The prior dispatch-table approach had these defects:

1. **Not action-oriented.** A table row says &#34;red-phase&#34; — the implementor must reconstruct what that means. A checklist says &#34;write test that FAILS&#34; with sub-bullets for the specific grep pattern, file, and expected exit code.
2. **Duplicate phase-level gates.** `sc-coherence-gate` appeared in every item&#39;s table when it should appear once per phase.
3. **No LLM reading order.** Tables require the reader to scan columns and compose meaning. A flat numbered list is executed from top to bottom.
4. **Metadata buried.** SC references and commands lived inside JSON in a &#34;Receives Context&#34; column — invisible unless the reader parsed a JSON snippet.
5. **Dispatch mode invisible.** The dispatch column distinguished clean-room sub-agent dispatches from orchestrator-inline actions. In a checklist, this must be explicit per step.

## Canonical Form Preservation — What Stays Unchanged

The following requirements are already part of the writing-plans canonical form and remain **fully mandated** in this spec. This spec changes only the output format (dispatch tables → enumerated checklists) and gate-source mechanism (hardcoded → dynamic). Everything below stays exactly as before:

### Structure (unchanged)

- **Prologue → Per Phase → Epilogue** three-part structure. Prologue contains Goal, Architecture, Files. Epilogue contains admonishment repeat and C1–C5 exit criteria.
- **Phase headers** with Concern, File(s), SCs covered, Dependencies, Entry/Exit conditions, Artifact path convention. Every field required.
- **Concern transition annotations** between phases — what concern is being left, what is being entered, what the next phase needs.
- **Phase startup** (coherence gate, pre-RED baseline, etc.) — runs once per phase before items.
- **Phase completion** (VbC, audit, cross-validate, regression, review prep) — runs once per phase after items.
- **Per-item RED+green chains** — each item gets exactly one RED+green cycle.
- **SC coverage requirement** — every SC referenced in at least one step via `→ SC-N`. Zero orphans.

### Prose/Presentation (unchanged)

- **Compliance admonishment** at top and bottom with full canonical text: &#34;All steps and sub-steps in this document MUST be followed in order...&#34;
- **No TBD/TODO/incomplete step placeholders.**
- **Phase dependency ordering** in Architecture section.
- **Artifact path convention** declared per phase: `./tmp/{issue-N}/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`.

### Validation Checks (unchanged, with additions for new format)

All existing validation checks remain. The validation section below adds new checks for the checklist format but does not remove any existing check.

### What Is Changing (exactly)

| What Was Before | What Replaces It |
|-----------------|------------------|
| Dispatch tables (`\| Gate \| Dispatch \| Blind \| Sub-Agent \| Receives Context \| SCs \|`) | Enumerated `- [ ] N.` checklists with sub-bullet metadata |
| Gate sequence hardcoded in `plan-structure.md` templates | Gate sequence discovered by reading `implementation-pipeline/SKILL.md` at plan-creation time |
| Gate ID conventions (`P1-I1-G3`) | Sequential numbering (`1.` through `N.`) |
| Per-item JSON context strings in &#34;Receives Context&#34; column | Prose sub-bullets and dispatch mode indicators |
| Dispatch mode implicit in table column | Dispatch mode indicator `(**clean-room**)` or `(**inline**)` in every step title |

## Z3 Validation

The flat-sequence form with per-item RED+green chains was validated via `solve check` — SAT confirmed.

```
SAT
```

## Canonical Plan Form

### Prologue

- [ ] **Goal.** One-line statement of what the plan accomplishes.
- [ ] **Architecture.** Dependency graph of phases.
- [ ] **Files.** File → Phase → Responsibility table.

&gt; **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

### Per Phase

- [ ] **Phase header.** Concern, SCs covered, files, dependencies, entry/exit conditions, artifact path convention.
- [ ] **Phase startup.** Steps that run once before items (coherence gate, pre-RED baseline). Exact step count determined dynamically.
- [ ] **Per-item steps.** Each item gets a RED+green chain. The exact gate sequence for each item is NOT hardcoded in the plan writer — it is discovered at plan-creation time by reading `implementation-pipeline/SKILL.md` to get the current gate definitions and ordering. Each gate becomes a numbered `- [ ] N.` with sub-bullet metadata and a **dispatch mode indicator**. No dispatch tables.
- [ ] **Phase completion.** Steps that run once after all items (VbC, audit, cross-validate, regression, review prep). Exact step count determined dynamically.
- [ ] **Concern transition annotation.** When transitioning between phases: describe what concern being left, what concern being entered, what information the next phase needs.

### Epilogue

- [ ] Compliance admonishment repeated.
- [ ] C1 through C5 exit criteria.

### Dispatch Mode Indicators — Mandatory Per Step

Every numbered checklist step MUST include a dispatch mode indicator in parentheses, immediately after the gate name. Exactly two modes exist:

| Indicator | Meaning | Applies To |
|-----------|---------|------------|
| `(**clean-room**)` | Orchestrator dispatches a clean-room sub-agent via `task()` with scoped context. Sub-agent is blind — receives no prior gate results, no orchestrator reasoning, no cached state. Discovers scope independently. | All sub-task dispatches: RED, doublecheck, enforcement, VbC, coherence, baseline, structural checks, cross-validate, regression, review-prep |
| `(**inline**)` | Orchestrator executes the step directly. No sub-agent dispatch, no blind isolation. | checkpoint-commit, resolve-models |

The mode is determined by reading `implementation-pipeline/SKILL.md` §Dispatch Routing Table at plan-creation time. The table&#39;s &#34;Dispatch Type&#34; column maps as follows: `sub-task` → `(**clean-room**)`, everything else → `(**inline**)`.

**Examples:**

```
- [ ] 6. **GREEN (**clean-room**).** Implement the change.
  - Specific changes.
  - **→ SC-4**

- [ ] 8. **Checkpoint commit (**inline**).** `git commit -m &#34;fix header&#34;`
```

### Mandatory Sub-Step Expansion — All Workflows (CRITICAL)

**Every gate or workflow that contains sub-steps MUST be expanded into multiple numbered `- [ ] N.` entries in the plan. Sub-steps as prose within a single checkbox entry will be ignored by the executing agent and are PROHIBITED.**

This applies universally — not just to the adversarial-audit workflow, but to any gate whose pipeline definition contains sub-operations, multi-dispatch sequences, remediation loops, or conditional branches.

The plan writer MUST:

1. Read each gate&#39;s task file from the pipeline skill to determine if the gate contains sub-steps.
2. If the gate&#39;s dispatch type is `orchestrator` (multi-dispatch) or the task file defines a sequence of operations, expand each sub-step into its own `- [ ] N.` entry.
3. If the gate&#39;s task file references a remediation loop (conditionally re-run resolve-models, re-dispatch auditors, etc.), the loop entry point gets its own `- [ ] N.` entry AND the remediation condition is documented in sub-bullets.
4. Numbering is continuous across expansion — sub-steps do not restart at 1.

**Examples:**

✅ **Correct — adversarial-audit expanded into 3 numbered steps:**

```
- [ ] 20. **Resolve models (**inline**).** Run resolve-models to select cross-family auditors.
- [ ] 21. **Auditor 1: verification-audit (**clean-room**).** Dispatch audit to auditor_1. On non-clean-pass: remediate, re-run resolve-models, restart from Step 20.
- [ ] 22. **Auditor 2: verification-audit (**clean-room**).** Dispatch same task to auditor_2. On non-clean-pass: remediate, re-run resolve-models, restart from Step 20.
```

❌ **Prohibited — collapsed into one step:**

```
- [ ] 20. **Adversarial audit (**inline**).** resolve-models → 2 auditors.
```

✅ **Correct — any other workflow with sub-steps also expanded:**

```
- [ ] N. **Tag creation (**inline**).** Create checkpoint tag.
- [ ] N. **Git commit (**inline**).** Commit working state.
- [ ] N. **Git push (**inline**).** Push to remote.
```

❌ **Prohibited — sub-steps in prose:**

```
- [ ] N. **Checkpoint commit (**inline**).** Create tag, commit, and push.
```

### Gate Sequence — Discovered Dynamically (CRITICAL)

**The implementation workflow gate sequence MUST NOT be embedded as a static template in the plan writer skill card.** The plan writer skill card (`plan-structure.md`, `create-and-validate.md`) must NOT hardcode gate names, gate counts, gate ordering, or dispatch modes.

Instead, the plan writer MUST discover the gate sequence at plan-creation time:

1. Read `implementation-pipeline/SKILL.md` and its task files to discover the current gate definitions, ordering, and dispatch types.
2. For each discovered gate, read its corresponding task file to determine whether the gate contains sub-steps that must be expanded.
3. For each discovered gate (and each expanded sub-step), produce a numbered `- [ ] N.` checkbox step in the plan with the dispatch mode indicator derived from the pipeline&#39;s dispatch type.
4. If the pipeline is updated (gates added, renamed, removed, dispatch types changed, sub-steps modified), the plan writer automatically reflects those changes — no skill card template update required.

**What the plan writer skill card templates contain instead of a hardcoded gate sequence:**
- The output format specification (numbered checklists with sub-bullet metadata and dispatch indicators)
- The dispatch mode mapping: `sub-task` → `(**clean-room**)`, everything else → `(**inline**)`
- A discovery directive instructing the sub-agent to read the pipeline skill for gate sequence and dispatch types
- A mandatory sub-step expansion directive: read each gate&#39;s task file; if it contains sub-operations, produce one numbered entry per sub-step
- A no-collapse prohibition: sub-steps as prose within a single checkbox is PROHIBITED. Every sub-step gets its own `- [ ] N.`
- Validation rules (SC coverage, no gaps, admonishment presence, dispatch mode indicator present per step, sub-steps expanded)
- The SC reference convention (`→ SC-N`)

**What the plan writer skill card templates MUST NOT contain:**
- A fixed list of gate names
- A fixed gate count
- A fixed ordering of gates
- A fixed dispatch type per gate
- A fixed sub-step count per gate
- Any hardcoded step that would become stale when the pipeline changes

### Checklist Format (Output Shape)

Every step is a numbered checkbox with dispatch mode indicator:

```
- [ ] N. **Gate name (**mode**).** Description of what to do.
  - Sub-bullet with metadata, SC reference, command.
  - **→ SC-N** annotation where applicable.
```

The format is fixed. The content of each step (which gates exist, what they do, what dispatch mode) comes from reading the pipeline skill dynamically. Multi-step gates MUST produce multiple `- [ ] N.` entries.

### Phase Header Contents

Every phase section MUST contain:
- **Concern:** What concern this phase addresses.
- **File(s):** The file(s) being modified.
- **SCs covered:** Which SCs this phase covers.
- **Dependencies:** Which phases must complete first.
- **Entry condition:** What is true before this phase starts (the defect or missing state).
- **Exit condition:** What is true when this phase completes (the fixed or complete state).
- **Artifact path convention:** `./tmp/{issue-N}/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`

### Concern Transition Annotation

Between phases, the plan MUST include a prose annotation describing:
- What concern is being left
- What concern is being entered
- What information the next phase needs from the current one

### SC Reference Convention

SC references appear as sub-bullet annotations in GREEN and GREEN doublecheck steps:

```
- [ ] N. **GREEN (**clean-room**).**
  - Add function.
  - **→ SC-8**
```

### What Is Removed (from output and templates)

- **Dispatch tables.** No `| Gate | Dispatch | Blind | Sub-Agent | Receives Context | SCs |` tables. Gate metadata moves into sub-bullets; dispatch mode moves into step title.
- **Static gate sequence in plan writer.** No hardcoded gate list. Sequence comes from reading `implementation-pipeline/SKILL.md` at plan-creation time.
- **Gate ID conventions.** No `P1-I1-G3` notation. Steps are sequentially numbered `1.` through `N.`
- **Per-item JSON context strings.** No inline JSON in steps. Gate names, SC refs, dispatch modes, and commands are prose sub-bullets and title indicators.

## Affected Files

| File | Change |
|------|--------|
| `skills/writing-plans/tasks/create/plan-structure.md` | Remove dispatch table template. Add output-format specification (numbered checklists with sub-bullets + dispatch indicators). Add discovery directive and mandatory sub-step expansion directive with no-collapse prohibition. Add dispatch mode mapping table. |
| `skills/writing-plans/tasks/create/create-and-validate.md` | Remove dispatch table validation. Add checklist validation: SC coverage, no gaps, admonishment present, dispatch indicator present per step, gate sequence matches pipeline source, sub-steps expanded (no collapsed multi-operation steps). |
| `skills/writing-plans/contracts/create-output-template.yaml` | Update output schema: checklist steps instead of gate tables. |
| `skills/adversarial-audit/tasks/spec-audit.md` | Update SC-PIPELINE-GATES to validate checklist format requirements (not per-unit gate tables). Add SC-CANONICAL-PLAN-FORM for specs that define plan output format requirements. |
| `skills/adversarial-audit/tasks/plan-fidelity.md` | Update PF-Z3-CONTRACT (14-boolean per-unit → hierarchical phase→item→gate booleans). Update PF-6 (add dispatch indicator check in every step title). Add PF-CHECKLIST-FORMAT, PF-DISPATCH-MODE, PF-SUBSTEP-EXPAND, PF-ADMONISHMENT, PF-SEQUENCE-MATCHES criteria. |

## Auditor Updates

The two adversarial-audit task files that validate plan output format reference the old dispatch-table conventions and must be updated to validate the new checklist format.

### spec-audit.md — SC-PIPELINE-GATES (line 100)

**Current text:** &#34;Pipeline gates stated once as a shared cross-reference at top → VIOLATION. Expect per-unit gate tables.&#34;

This criterion assumes per-unit gate tables. In the new format, each gate is a numbered `- [ ] N.` with dispatch indicator, not a table row. **New behavior:** Validate that the spec requires the canonical checklist format with dispatch indicators, not gate tables. The criterion name stays (SC-PIPELINE-GATES) — only the validation text changes.

**New criterion: SC-CANONICAL-PLAN-FORM.** If the spec defines plan output format requirements, validate that those requirements use the canonical checklist format (no dispatch tables, no shared cross-references).

### plan-fidelity.md — PF-Z3-CONTRACT (line 69)

**Current text:** &#34;Pipeline gate booleans exist (14 per unit, e.g., P1_p1..P1_p14).&#34;

The 14-boolean per-unit contract was part of the old dispatch-table format. The new format eliminates per-unit booleans. The phase-level solve contract (step 3.3 in `plan-structure.md`) is preserved. **New behavior:** Validate that the Z3 contract has hierarchical phase→item→gate booleans rather than 14 flat booleans per unit.

### plan-fidelity.md — PF-6 (line 65)

**Current text:** &#34;RED GREEN REFACTOR structure present; RED and GREEN are separate phases, not combined&#34;

**New behavior:** Add: &#34;Every step has `(**clean-room**)` or `(**inline**)` dispatch mode indicator in title.&#34;

### plan-fidelity.md — New Criteria

Five new criteria specific to the checklist format:

| Criterion | What It Checks |
|-----------|----------------|
| PF-CHECKLIST-FORMAT | All steps use `- [ ] N.` format with sub-bullets |
| PF-DISPATCH-MODE | Every step has `(**clean-room**)` or `(**inline**)` indicator |
| PF-SUBSTEP-EXPAND | No collapsed multi-operation steps — every sub-operation gets its own `- [ ] N.` |
| PF-ADMONISHMENT | Compliance admonishment blockquote at top and bottom with full canonical text |
| PF-SEQUENCE-MATCHES | Gate sequence matches `implementation-pipeline/SKILL.md` dispatch routing table |

## Validation Checks

When validating a plan:

1. Every step is `- [ ] N.` with at least one sub-bullet.
2. Every step title contains `(**clean-room**)` or `(**inline**)` — exactly one of the two.
3. Gate sequence matches the current `implementation-pipeline/SKILL.md` gate definitions (read dynamically — no hardcoded comparison).
4. No step describes more than one atomic action. Every sub-operation from the pipeline task files gets its own `- [ ] N.` entry.
5. All SCs referenced at least once via `→ SC-N` annotations.
6. No TBD/TODO placeholders.
7. Compliance admonishment blockquote present at top and bottom with full canonical text.
8. Phase dependency ordering matches spec architecture.
9. Each phase has entry/exit conditions and concern transition annotations.
10. Artifact path convention declared per phase.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Plan emits numbered `- [ ] N.` checklists, not dispatch tables | `behavioral` | Generate a test plan, verify dispatch table pattern absent |
| SC-2 | Gate sequence matches `implementation-pipeline/SKILL.md` gates — read dynamically, not hardcoded | `behavioral` | Update pipeline gate set, regenerate plan, verify new gates appear and old ones absent |
| SC-3 | No static gate sequence template in plan writer skill card (`plan-structure.md`) | `string` | grep for hardcoded gate names in plan-structure.md — absent |
| SC-4 | SC references appear as `→ SC-N` annotations in sub-bullets | `string` | grep for `SC-\d+` in plan output |
| SC-5 | Compliance admonishment present at top and bottom with full canonical text | `string` | grep for &#34;rework from scratch and loss of all prior work&#34; — 2 matches |
| SC-6 | No dispatch tables in output | `string` | grep for `\| Gate \|` — absent |
| SC-7 | Every step has a valid dispatch mode indicator | `string` | grep for `\(\*\*clean-room\*\*\)` or `\(\*\*inline\*\*\)` in every step |
| SC-8 | No step contains multiple actions collapsed into one checkbox — every sub-operation from pipeline task files expanded into its own `- [ ] N.` | `behavioral` | Generate a plan, verify multi-operation gates (resolve-models + auditor dispatch) produce multiple entries |
| SC-9 | Each phase has entry/exit conditions, concern transition, and artifact path | `string` | grep for &#34;Entry condition&#34;, &#34;Exit condition&#34;, &#34;Artifact path&#34;, &#34;Concern transition&#34; |
| SC-10 | All existing validation features pass (phase ordering, concern boundaries, SC coverage, no placeholders) | `behavioral` | Run existing plan validation tests |
| SC-11 | spec-audit SC-PIPELINE-GATES validates checklist format requirements (not per-unit gate tables) | `string` | grep for `per-unit gate tables` — absent; grep for `dispatch indicator` — present near SC-PIPELINE-GATES |
| SC-12 | plan-fidelity PF-Z3-CONTRACT references hierarchical phase→item→gate structure, not 14-boolean per-unit | `string` | grep for `14 per unit` at PF-Z3-CONTRACT — absent |
| SC-13 | plan-fidelity has PF-CHECKLIST-FORMAT, PF-DISPATCH-MODE, PF-SUBSTEP-EXPAND, PF-ADMONISHMENT, PF-SEQUENCE-MATCHES criteria | `string` | grep for all 5 criterion names — all present |
| SC-14 | plan-fidelity PF-6 updated to require dispatch indicators in step titles | `string` | grep for `dispatch indicator` near `PF-6` — present |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
