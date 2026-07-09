> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| **Problem Statement** | Two related defects: (A) Procedure text in SKILL.md files enables orchestrator inline bypass — the orchestrator receives both routing metadata and procedure text from `skill()`, and the procedure text enables inline execution instead of sub-agent dispatch. (B) DISPATCH_GATE subsections are missing or incomplete on 3 skill cards, 2 template files, and the validation script. |
| **Root Cause / Motivation** | The DISPATCH_GATE protocol was retrofitted onto 33 skills but never back-ported into the canonical reference templates. Three cards were missed in the retrofit. The validation script was never updated to catch incomplete cards. The routing-only template (created in #1407 Phase 1) has no DISPATCH_GATE section. |
| **Approach Chosen** | Merge #1407 (routing-only restructure) and #1669 (DISPATCH_GATE completeness) into a single 9-phase spec. Add DISPATCH_GATE to the routing-only template so every new skill inherits it. Migrate procedure content from all 39 SKILL.md files to tasks/*.md. Add DISPATCH_GATE to 3 defective cards. Add validation check. Add behavioral tests. Add pre-commit structural gate. |
| **Alternatives Considered & Why Discarded** | Implement #1407 then rebase #1669 — discarded because the specs share the same files and the DISPATCH_GATE section belongs in the routing-only template definition, not as a separate add-on. |
| **Key Design Decisions** | DISPATCH_GATE is part of the routing-only template, not a separate section. Behavioral tests for routing behavior (SC-ROUTING) are separate from structural tests for DISPATCH_GATE presence (SC-DG). |

## Supersession

This spec **merges and supersedes** two prior specs:

| Superseded Issue | Title | Reason for Merge |
|-----------------|-------|------------------|
| **#1407** | [SPEC] Structural dispatch-gate enforcement — separate routing from procedure in SKILL.md files | Phase 1 complete (routing-only template exists). Remaining 5 phases merge with #1669's DISPATCH_GATE targets. |
| **#1669** | [SPEC] Add complete DISPATCH_GATE subsections to defective skill cards, templates, and validation | 5 of 6 targets unimplemented. Scope is a subset of #1407's remaining work. DISPATCH_GATE belongs in the routing-only template, not as a separate add-on. |

**Both #1407 and #1669 MUST be closed as superseded when this spec is approved.**

## Problem

Two related defects in the skill deck:

**Defect A — Procedure text in SKILL.md enables inline bypass.** The orchestrator receives both routing metadata (dispatch table) and procedure text (step definitions, entry/exit criteria, code snippets) from `skill()`. The procedure text enables inline execution — the orchestrator can read the steps and execute them directly instead of dispatching to a sub-agent. The dispatch table correctly says `sub-task`; the orchestrator ignores it because it has everything needed to execute inline.

**Defect B — DISPATCH_GATE subsections are missing or incomplete on 3 cards + 2 templates + validation.** The DISPATCH_GATE protocol was retrofitted onto 33 skills but never back-ported into the canonical reference templates. Three cards were missed in the retrofit. The validation script was never updated to catch incomplete cards. The routing-only template (created in #1407 Phase 1) has no DISPATCH_GATE section at all.

## Completed Work (Phase 1 of #1407)

The following is already implemented and merged to `dev`:

- **`skills/skill-creator/reference/routing-only-template.md`** — canonical routing-only SKILL.md template (PR #1409)
- **`skills/skill-creator/scripts/init_skill.py`** — `SKILL_TEMPLATE` replaced with routing-only structure
- **`skills/skill-creator/reference/skill-card-spec.md`** — cross-reference to routing-only template

**However:** The routing-only template has NO DISPATCH_GATE section. This merged spec adds DISPATCH_GATE to the template as part of the canonical structure.

## Scope

All 39 SKILL.md files in `skills/*/SKILL.md` plus their corresponding `tasks/*.md` files, plus 2 template files, plus the validation script.

## Phases

### Phase 1 (DONE) — Routing-only template defined

Already implemented. The routing-only template exists at `skills/skill-creator/reference/routing-only-template.md`. This phase is verified complete and will not be re-executed.

### Phase 2 — Add DISPATCH_GATE to routing-only template

The routing-only template (created in Phase 1) lacks a DISPATCH_GATE section. Add the canonical DISPATCH_GATE subsections (Dispatch Context Contract, Sub-Agent Entry Criteria, Orchestrator Entry Criteria, Forbidden in task() Prompts table, Sub-Agent Task File Discovery Directive) to the template. This ensures every new skill created from the template inherits the DISPATCH_GATE protocol.

Also update `skill-card-spec.md` to document DISPATCH_GATE as a required section in the routing-only template.

### Phase 3 — Audit all 39 SKILL.md files for procedure content

For each SKILL.md, identify:

| Category | Content to move to tasks/*.md | Content to keep in SKILL.md |
|----------|------------------------------|----------------------------|
| Step definitions | Numbered action lists, "Step 1: do X" | — |
| Entry/exit criteria | "Entry Criteria:" / "Exit Criteria:" sections | — |
| Operating protocol | "Operating Protocol:" numbered checklists | — |
| Procedure | "Procedure:" sections with sub-steps | — |
| Code snippets | Any code blocks, YAML examples, bash commands | — |
| Dispatch table | — | Trigger Dispatch Table (checkbox list) |
| Invocation | — | Canonical skill() + task() strings |
| Task file paths | — | Discovery directives |
| Context contract | — | What fields to pass to sub-agents |
| Cross-references | — | Related skills and guidelines |
| Mandatory Task Discipline | — | Checkboxes (routing metadata) |
| Persona | — | Persona section (orchestrator context) |
| Sub-Agent Routing | — | Routing rules (orchestrator context) |
| DISPATCH_GATE | — | All 7 canonical subsections |

### Phase 4 — Migrate procedure content to tasks/*.md

For each SKILL.md with procedure content:

1. Create or update the corresponding `tasks/*.md` file with the procedure content
2. Remove the procedure content from SKILL.md
3. Ensure the task file has proper entry/exit criteria, step definitions, and code snippets
4. Ensure the task file has a discovery directive reference in the SKILL.md dispatch table

### Phase 5 — Add DISPATCH_GATE to defective cards

Add complete DISPATCH_GATE subsections to the 3 cards that are missing or incomplete:

| Card | Current State | Work Required |
|------|--------------|---------------|
| `audit/SKILL.md` (renamed from `adversarial-audit`) | No DISPATCH_GATE section at all | Add full canonical section |
| `playwright-cli/SKILL.md` | Prose-only DISPATCH GATE block, no structured subsections | Replace with canonical section; only DISPATCH_GATE section modified (upstream provenance) |
| `solve/SKILL.md` | Has heading + Orchestrator Entry Criteria (from #864 batch), missing Dispatch Context Contract, Sub-Agent Entry Criteria, forbidden patterns table | Add missing subsections; preserve existing content |

### Phase 6 — Update validation script

Add a REQ check to `validate_skill_cards.py` that validates complete DISPATCH_GATE subsections. Use the same pattern as existing REQ checks (REQ-1 through REQ-5). The check MUST:

- Verify presence of all 7 canonical subsections
- Allow opt-out marker for skills with no sub-agent dispatch
- Not flag existing 33 working cards

### Phase 7 — Behavioral enforcement tests

Create behavioral tests that verify:

1. **SC-ROUTING-1**: After `skill("approval-gate")`, the orchestrator does NOT have procedure text (step definitions, entry/exit criteria) in its context — verified by clean-room sub-agent
2. **SC-ROUTING-2**: After `skill("approval-gate")`, the orchestrator HAS the dispatch table and canonical dispatch strings — verified by clean-room sub-agent
3. **SC-ROUTING-3**: When the orchestrator receives an approved spec, it dispatches sub-agents via `task()` rather than reading/editing files inline — verified by behavioral test (stderr shows task() calls, no direct file reads on task files)
4. **SC-DG-1**: `audit/SKILL.md` has complete DISPATCH_GATE with all 7 subsections — verified by grep
5. **SC-DG-2**: `playwright-cli/SKILL.md` has complete DISPATCH_GATE; only DISPATCH_GATE section modified — verified by grep + git diff
6. **SC-DG-3**: `solve/SKILL.md` gains missing subsections; existing content preserved — verified by grep
7. **SC-DG-4**: `routing-only-template.md` has DISPATCH_GATE section — verified by grep
8. **SC-DG-5**: `skill-card-spec.md` documents DISPATCH_GATE structure requirements — verified by grep
9. **SC-DG-6**: `validate_skill_cards.py` REQ check catches missing DISPATCH_GATE subsections — verified by behavioral test
10. **SC-DG-7**: Existing 33 working cards not broken by validation change — verified by regression test

### Phase 8 — Pre-commit structural gate

Add a pre-commit hook check that scans SKILL.md files for prohibited procedure content patterns:

- Numbered step lists (`- [ ] N.` or `N. **Step**`)
- "Entry Criteria:" / "Exit Criteria:" sections
- "Procedure:" sections
- "Operating Protocol:" sections
- Code blocks with bash/python/YAML

This is a structural gate, not a behavioral one — it catches violations at commit time.

### Phase 9 — Update guidelines

Update the following guidelines to reflect the new SKILL.md structure:

- `skill-creator` skill — validation rules for routing-only SKILL.md with DISPATCH_GATE
- `080-code-standards.md` — if it references SKILL.md structure

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-ROUTING-1 | After `skill("approval-gate")`, orchestrator has no procedure text | `behavioral` | Clean-room sub-agent reads orchestrator context |
| SC-ROUTING-2 | After `skill("approval-gate")`, orchestrator has dispatch table + canonical strings | `behavioral` | Clean-room sub-agent reads orchestrator context |
| SC-ROUTING-3 | Orchestrator dispatches sub-agents (not inline work) when processing approved spec | `behavioral` | `opencode-cli run` → stderr shows task() calls, no direct file reads on task files |
| SC-ROUTING-4 | All 39 SKILL.md files pass routing-only audit (no procedure text in body) | `structural` | Structural scan of all SKILL.md files |
| SC-ROUTING-5 | Pre-commit hook detects prohibited procedure patterns in SKILL.md files | `behavioral` | Create SKILL.md with procedure text → commit → hook blocks |
| SC-ROUTING-6 | Pre-commit hook does NOT block commits that only modify tasks/*.md files | `behavioral` | Modify tasks/*.md only → commit → hook passes |
| SC-ROUTING-7 | All task files that received migrated content have proper entry/exit criteria and step definitions | `semantic` | Sub-agent reads each migrated task file |
| SC-DG-1 | `audit/SKILL.md` has complete DISPATCH_GATE with all 7 subsections | `string` | grep for each subsection heading |
| SC-DG-2 | `playwright-cli/SKILL.md` has complete DISPATCH_GATE; only DISPATCH_GATE section modified | `string` | grep + git diff |
| SC-DG-3 | `solve/SKILL.md` gains missing subsections; existing content preserved | `string` | grep for new subsections; diff shows no changes to existing content |
| SC-DG-4 | `routing-only-template.md` has DISPATCH_GATE section with all 7 subsections | `string` | grep for DISPATCH_GATE heading |
| SC-DG-5 | `skill-card-spec.md` documents DISPATCH_GATE structure requirements | `string` | grep for DISPATCH_GATE |
| SC-DG-6 | `validate_skill_cards.py` REQ check catches missing DISPATCH_GATE subsections | `behavioral` | Create test SKILL.md with missing subsection → run validation → non-zero exit code |
| SC-DG-7 | Existing 33 working cards not broken by validation change | `behavioral` | Run validation against all cards → no new violations on previously working cards |

## Evidence Type Note

SC-DG-1 through SC-DG-5 are classified as `string` evidence type. These are structural changes to markdown files (grep for subsection headings). Per the BEH-EV substrate classification rule (`000-critical-rules.md` §critical-rules-BEH-EV), DISPATCH_GATE sections in SKILL.md files affect runtime behavior (orchestrator dispatch decisions). However, the verification method for these SCs is grep-based (checking that the text exists in the file), which is `string` evidence. The behavioral verification of whether the DISPATCH_GATE section actually changes orchestrator behavior is covered by SC-ROUTING-1 through SC-ROUTING-3 (behavioral tests that verify the orchestrator dispatches correctly). This separation of concerns — structural verification that the text exists + behavioral verification that the text works — is the correct pattern per the evidence type taxonomy.

## Non-Goals

- This spec does NOT change the sub-agent dispatch protocol (PRELOADED_CONTEXT_REJECTED, canonical dispatch strings, discovery directives — all remain)
- This spec does NOT change the `skill()` tool behavior (it returns whatever SKILL.md contains — this spec changes what SKILL.md contains)
- This spec does NOT add new critical rules — it restructures content to make existing rules structurally enforceable
- This spec does NOT change task file content — only moves it from SKILL.md to tasks/*.md

## Dependencies

- **#1561** (text-only clause replacement) — modifies the same 37 SKILL.md files. Implement #1561 first to avoid merge conflicts.
- **#1406** (bypass prevention) — modifies different files (session-enforcement.ts, pre-commit hooks). Independent.

## References

- https://opencode.ai/docs/skills/ — opencode.ai skill requirements (frontmatter only, body is free-form)
- `000-critical-rules.md` §critical-rules-034 (orchestrator inline work), §critical-rules-048 (pre-read + inline execution), §critical-rules-dispatch-gate-canonical (canonical dispatch string)
- `020-go-prohibitions.md` §1.1 (orchestrator context cost model)
- `skill-creator` skill — validation rules
- `routing-only-template.md` — canonical routing-only SKILL.md template (created in #1407 Phase 1)

## Decomposition Classification

| Classification | Number of Phases | Sub-Issue Requirements | PR Strategy |
| -------------- | ---------------- | ---------------------- | ----------- |
| multi-task | 9 (1 done, 8 remaining) | 8 sub-issues (one per remaining phase) | stacked |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Validation script | MUST | Update if subsection structure changes |

## Constraints

1. Phase 1 is DONE — do not re-execute
2. `playwright-cli` is upstream-adapted (Apache-2.0) — only the DISPATCH_GATE section MUST be modified
3. `solve/SKILL.md` existing Orchestrator Entry Criteria MUST be preserved unchanged
4. Existing 33 working cards with complete DISPATCH_GATE MUST remain unchanged
5. Validation MUST use same pattern as existing REQ checks (REQ-1 through REQ-5)
6. DISPATCH_GATE belongs in the routing-only template, not as a separate section

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep -r "DISPATCH_GATE" .opencode/skills/*/SKILL.md` | Identify which skills have complete vs incomplete DISPATCH_GATE |
| Direct source search | `grep -r "Dispatch Context Contract" .opencode/skills/*/SKILL.md` | Verify canonical subsection structure across 33 working skills |
| Direct source search | `grep -r "Sub-Agent Entry Criteria" .opencode/skills/*/SKILL.md` | Verify PRELOADED_CONTEXT_REJECTED protocol presence |
| Direct source search | `grep -r "Orchestrator Entry Criteria" .opencode/skills/*/SKILL.md` | Verify canonical dispatch string mandate presence |
| MCP search | `srclight_search_symbols("validate_skill_cards")` | Locate validation script and understand existing REQ structure |
| Issue audit | #1407, #1669, #1406, #1379, #1783, #864 | Identify supersession, conflict, and dependency relationships |
| File audit | `adversarial-audit` → `audit` rename (commit `5bc22ae6`) | Correct stale file path from #1669 |

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1784/plan.md` before implementation begins.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
