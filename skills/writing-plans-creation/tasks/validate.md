# Task: validate

## Purpose

Check an existing plan for placeholders and completeness.

## Validation Checks

- [ ] 01. (**inline**) Placeholder detection — Zero TBD/TODO tolerance
  - Command: `grep(pattern="TBD|TODO|tbd|todo")` on plan body
  - SC: All
  - Expected: zero matches

- [ ] 02. (**inline**) Completeness — Plan addresses the stated problem
  - Command: read plan body, compare against spec problem statement
  - SC: All
  - Expected: plan covers all spec requirements

- [ ] 03. (**inline**) Actionability — Steps are concrete, not abstract goals
  - Command: manual parse — flag abstract goals
  - SC: All
  - Expected: each step has concrete action

- [ ] 04. (**inline**) Testability — Success criteria include executable verification commands with exact expected values
  - Command: read each SC in plan, verify it has a verification command
  - SC: All
  - Expected: each SC specifies command that produces deterministic pass/fail

- [ ] 05. (**inline**) TDD structure — Each task has failing test → implement → passing test steps
  - Command: verify RED/GREEN chain present for each item
  - SC: All
  - Expected: RED → GREEN → doublecheck → commit structure

- [ ] 06. (**inline**) File structure — All files are listed with responsibilities
  - Command: read plan Files section, verify against spec
  - SC: All
  - Expected: all files listed with clear responsibilities

- [ ] 07. (**inline**) Self-review evidence — Agent has performed spec coverage, placeholder, and type consistency checks
  - Command: check for self-review evidence in plan
  - SC: All
  - Expected: self-review evidence present

- [ ] 08. (**inline**) Spec reference — Plan body contains a spec reference
  - Command: `grep(pattern="Spec: #")` on plan body
  - SC: All
  - Expected: spec reference present

- [ ] 09. (**inline**) Phase files exist — All phase files present for multi-phase plans
  - Command: `ls {N}/plan-*.md 2>/dev/null`
  - SC: All
  - Expected: phase files exist matching plan index phase table

- [ ] 10. (**inline**) Plan index exists — Plan index exists at `{N}/plan.md`
  - Command: `ls {N}/plan.md 2>/dev/null`
  - SC: All
  - Expected: file exists

- [ ] 11. (**inline**) Pipeline-gate completeness — All implementation-pipeline gate steps present with correct skill/task references
  - Command: Read [the Trigger Dispatch Table](skills/implementation-pipeline/SKILL.md), compare against plan. Every step in the dispatch table MUST be present in the plan with the correct skill/task name. Plans that omit mandatory steps or use incorrect skill/task names are defective and MUST be rejected. This is non-waivable — no exception for any reason.
  - SC: SC-13
  - Expected: all gate steps present in plan's exit criteria or phase structure with correct skill/task references

- [ ] 12. (**inline**) Global sequential numbering — Step numbering is globally sequential across all phases
  - Command: parse plan step numbers, verify no per-phase restart
  - SC: All
  - Expected: step N+1 follows step N across phase boundaries

- [ ] 13. (**inline**) Checkbox format — All implementation steps use `- [ ] N.` checkbox format
  - Command: `grep(pattern="- \\[ \\] \\d+\\.")` on plan body
  - SC: SC-9
  - Expected: all steps use checkbox format

- [ ] 14. (**inline**) Phase workflow completeness — Every phase contains full implementation workflow step sequence with correct skill/task references
  - Command: Read [the Trigger Dispatch Table](skills/implementation-pipeline/SKILL.md), compare each phase. Every step in the dispatch table MUST be present in each phase with the correct skill/task name. Plans that omit mandatory steps or use incorrect skill/task names are defective and MUST be rejected. This is non-waivable — no exception for any reason.
  - SC: SC-13
  - Expected: each phase has complete RED/GREEN chain with correct skill/task references

- [ ] 15. (**inline**) No duplicate global steps — Global pre/post steps not duplicated across per-file phases
  - Command: check Phase 1 (global pre) and Phase 7-8 (global post) steps against per-file phases
  - SC: SC-15
  - Expected: no global steps duplicated in per-file phases

- [ ] 16. (**inline**) Three-tier structure compliance — Plan uses global pre-phase, per-file RED/GREEN phases, global post-phase
  - Command: read plan, verify three-tier structure
  - SC: SC-14
  - Expected: global pre-phase (once), per-file RED/GREEN phases (one chain each), global post-phase (once)

- [ ] 17. (**inline**) Self-remediation protocol admonishment present — Plan includes the one-step-at-a-time protocol and self-remediation protocol blockquote
  - Command: `grep(pattern="One step at a time protocol|Self-remediation protocol")` on plan body
  - SC: SC-6
  - Expected: both protocol admonishments present

- [ ] 18. (**inline**) Dispatch indicator validation — Verify each step's dispatch indicator matches its content. `(**inline**)` steps must not contain sub-agent dispatch language; `(**sub-agent**)` steps must dispatch a sub-agent via `task()`
  - Command: parse plan body, extract dispatch indicators, verify semantic match against step content
  - SC: SC-5
  - Expected: all dispatch indicators match step content; FAIL on mismatch

- [ ] 19. (**inline**) Behavioral SC exit criteria validation — Reject structural-only exit criteria for behavioral SCs
  - Command: For each SC in the plan's exit criteria section, check if the SC has `evidence_type: behavioral` annotation. If yes, verify the exit criteria include both `behavior_run` artifact generation AND `behavioral-test-evaluation` clean-room dispatch steps. Exit criteria that use only structural evidence (file exists, annotations present, exit 0) for behavioral SCs MUST be rejected.

- [ ] 20. (**inline**) Blast radius coverage — Verify plan covers all files and impact zones from blast radius artifact
  - Command: read `{N}/blast-radius.yaml`, compare `affected_files` and `impact_zones` against plan's Files section and phase structure
  - SC: SC-27
  - Expected: every affected file and impact zone has a corresponding phase or step in the plan

- [ ] 21. (**inline**) Concern map alignment — Verify phase count and boundaries match concern map artifact
  - Command: read `{N}/concern-map.yaml`, compare `concerns` list against plan's phase table
  - SC: SC-27
  - Expected: each concern maps to exactly one phase; no phase without a concern; phase boundaries align with concern boundaries

- [ ] 22. (**inline**) Code path coverage — Verify every code path in inventory has a RED/GREEN item
  - Command: read `{N}/code-path-inventory.yaml`, compare `paths` list against plan's TDD task definitions
  - SC: SC-27
  - Expected: every code path has at least one RED/GREEN item; no code path is uncovered

- [ ] 23. (**inline**) Cross-cutting SC coverage — Verify cross-cutting SCs are annotated in all relevant phases
  - Command: read `{N}/cross-cutting-matrix.yaml`, compare `cross_cutting_scs` against plan phase annotations
  - SC: SC-27
  - Expected: each cross-cutting SC appears in every phase it affects; cross-cutting annotations present in phase metadata

- [ ] 24. (**inline**) Interface compatibility — Verify plan respects interface boundaries from interface compatibility artifact
  - Command: read `{N}/interface-compatibility.yaml`, compare `interfaces` against plan phase boundaries
  - SC: SC-27
  - Expected: no phase crosses an interface boundary marked as incompatible; phase boundaries align with compatible interface boundaries

- [ ] 25. (**inline**) State transition coverage — Verify plan covers all state transitions from state analysis artifact
  - Command: read `{N}/state-analysis.yaml`, compare `transitions` against plan's dependency ordering and phase structure
  - SC: SC-27
  - Expected: every state transition has a corresponding phase or step; transition ordering matches dependency contract

- [ ] 26. (**inline**) Testability alignment — Verify evidence types in plan match testability assessment artifact
  - Command: read `{N}/testability-assessment.yaml`, compare each SC's `evidence_type` against plan's exit criteria evidence type annotations
  - SC: SC-27
  - Expected: every SC's evidence type in the plan matches the testability assessment; no downgrade from behavioral to structural

- [ ] 20. (**inline**) Blast radius analysis — Spec identifies what files/symbols are affected and what depends on them
  - Command: `grep(pattern="blast radius|affected files|dependents|impact analysis")` on spec body
  - SC: SC-6
  - Expected: at least one match indicating blast radius analysis

- [ ] 21. (**inline**) Separation of concerns — Each concern is isolated to its own phase/item
  - Command: `grep(pattern="separation of concerns|concern isolation|concern boundary|each concern")` on spec body
  - SC: SC-6
  - Expected: at least one match indicating concern separation

- [ ] 22. (**inline**) Decomposition depth — Work is decomposed to the lowest testable level
  - Command: `grep(pattern="decomposition|decompose|lowest testable|item.*level|unit.*level")` on spec body
  - SC: SC-6
  - Expected: at least one match indicating decomposition analysis

- [ ] 23. (**inline**) Cross-cutting concern identification — Concerns spanning multiple phases are explicitly identified
  - Command: `grep(pattern="cross-cutting|cross cutting|spanning|shared concern|common concern")` on spec body
  - SC: SC-6
  - Expected: at least one match indicating cross-cutting concern identification

- [ ] 24. (**inline**) Full code path exercising — All affected code paths are enumerated
  - Command: `grep(pattern="code path|code paths|all paths|affected paths|exercise.*path")` on spec body
  - SC: SC-6
  - Expected: at least one match indicating full code path enumeration
  - SC: SC-2
  - Expected: all behavioral SCs have model-execution-and-evaluation steps in their exit criteria; FAIL on structural-only exit criteria for behavioral SCs

- [ ] 20. (**inline**) Dispatch mode validation — Verify dispatch mode consistency rules:
  - Command: parse plan phase table (or `**Dispatch:**` field for non-split plans), extract dispatch mode for each phase, then check per-phase step markers
  - SC: SC-3
  - Expected: all three rules pass; FAIL on any violation

  **Rule (a):** `inline` phases MUST NOT contain only sub-agent steps. If a phase has `Dispatch: inline` and every step uses `(**sub-agent**)` or `(**clean-room**)`, the orchestrator would read the file and dispatch every step — equivalent to `sub-agent-with-context` with extra overhead. FAIL.

  **Rule (b):** `sub-agent-clean-room` phases MUST NOT contain `(**inline**)` steps. If a phase has `Dispatch: sub-agent-clean-room` and any step uses `(**inline**)`, the sub-agent would receive inline steps it cannot execute. FAIL.

  **Rule (c):** Plan auditor MUST catch dispatch marking defects. Missing Dispatch declaration, mode/marker inconsistency, or invalid mode values are defects. FAIL.

- [ ] 21. (**inline**) Evidence type metadata presence — Verify each SC in the plan's exit criteria section carries an `evidence_type` annotation
  - Command: `grep(pattern="evidence_type:")` on each phase file's exit criteria section
  - SC: SC-4
  - Expected: every SC in every phase file has an `evidence_type` annotation; FAIL on missing annotations

## Result Contract Schema

Before returning, load the output contract from `contracts/validate-output-template.yaml` and validate the result against it. The contract defines the expected output structure:

```yaml
status: string  # PASS | BLOCKED
per_check_results: list[dict]  # per-check PASS/FAIL with check_id, check_name, status, evidence_type, finding_classification, action
artifact_path: string  # path to full evidence on disk
summary: string  # 1-3 sentence summary
```

Each z3-check step runs `solve check` against the previous step's output contract to validate state transitions.

## No-Placeholders Rule

Every step must contain actual content. These are **plan failures**:

| Pattern | Why Prohibited |
| -- | -- |
| `TBD` | Incomplete plan |
| `TODO` | Incomplete plan |
| `[to be determined]` | Incomplete plan |
| `[needs investigation]` | Investigation should be in spec |
| `[placeholder]` | Incomplete plan |
| `[requires research]` | Research should be in spec |
| `implement later` | Plan not actionable |
| `fill in details` | Details must be specified |
| `Add appropriate error handling` | Must specify actual code |
| `Add validation` / `Handle edge cases` | Must specify actual code |
| `Write tests for the above` | Must include actual test code |
| `Similar to Task N` | Must repeat the code — engineer may read tasks out of order |
| Steps describing what to do without showing how | Code blocks required for code steps |
| References to types/functions not defined in any task | All referenced symbols must be defined |

## Specs vs Plans

| Artifact | Placeholders Allowed? | Examples |
| -- | -- | -- |
| Spec (GitHub Issue) | YES, during iterative development | TBD, TODO, \[needs investigation\], \[placeholder\] |
| Plan (for implementation) | NO — zero tolerance | None allowed before implementation begins |

## Validation Logic

```python
INVALID_PATTERNS = [
    "TBD", "TODO", "tbd", "todo",
    "[to be determined]", "[needs investigation]",
    "[placeholder]", "[requires research]",
    "implement later", "fill in details",
]

def validate_plan(plan_content: str) -> bool:
    for pattern in INVALID_PATTERNS:
        if pattern in plan_content:
            return False
    return True
```

Does NOT enforce a specific section order. A plan without "Risks" is valid if risks are addressed elsewhere or are not relevant.

## Live Verification: Validation Evidence (MANDATORY)

**Each validation check MUST be verified via tool call, not just asserted. Assertions without tool-call artifacts are VERIFICATION-GAP findings — Read [065-verification-honesty.md](guidelines/065-verification-honesty.md).**

| Claim | Verification Action | Tool Call | Problem Class |
| -- | -- | -- | -- |
| "No placeholders present" | Search for placeholder patterns in plan body | \`grep(pattern="TBD | TODO |
| "Spec reference exists in plan" | Search for `Spec: #N` pattern | `grep(pattern="Spec: #")` on plan body | MISSING-ELEMENT |
| "Plan links to spec (not vice versa)" | Verify plan references spec issue | `grep(pattern="Spec: #N")` on plan body | STRUCTURE-VIOLATION | <!-- Plan phases are local `.issues/` artifacts, not GitHub sub-issues -->
| "Plan index exists" | Verify plan index at `{N}/plan.md` | `ls {N}/plan.md 2>/dev/null` | MISSING-ELEMENT |
| "Phase files exist" | Verify phase files at `{N}/plan-{NN}-*.md` | `ls {N}/plan-*.md 2>/dev/null` | MISSING-ELEMENT |
| "Steps are actionable" | Verify each step has concrete action | Manual parse — flag abstract goals | VERIFICATION-GAP |

**Evidence artifact:** Tool call results for automated checks; manual review log for actionable-step verification.

### Finding Classification

| Finding | Problem Class | Classification | Action |
| -- | -- | -- | -- |
| Placeholders found | VERIFICATION-GAP | FAIL | Remove placeholders or mark plan invalid |
| Missing spec reference | MISSING-ELEMENT | auto-fix | Add spec reference to plan body |
| Sub-issues under wrong parent | STRUCTURE-VIOLATION | auto-fix | Re-link under plan |
| Missing `plan` label | MISSING-ELEMENT | auto-fix | Add label immediately |
| Abstract goals found | VERIFICATION-GAP | FAIL | Flag for plan author to rewrite |
