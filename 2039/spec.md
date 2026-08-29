> **Full spec and artifacts: [`.issues/2039/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2039/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/2039/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

28 task cards are referenced in SKILL.md Trigger Dispatch Tables but do not exist as `.md` files in the corresponding `tasks/` directories. When the orchestrator dispatches these tasks via `task()`, the sub-agent has no task file to execute.

## Affected Skills

| Skill | Missing Task Cards |
|-------|-------------------|
| `approval-gate-scope` | `spec-to-plan-cascade`, `approval-cascade`, `check-halt-boundary`, `apply-label`, `revision-revocation`, `bug-discovery-protocol` |
| `brainstorming` | `top-down-analysis`, `cross-scope` — see [§Brainstorming Task Card Requirements](#brainstorming-task-card-requirements) |
| `executing-plans` | `execute`, `tdd-cycle-enforcement` |
| `playwright-cli` | `browse`, `test` |
| `programming-principles` | `principles`, `check-limits`, `decompose` |
| `skill-creator` | `init`, `package`, `fragment-management` |
| `multimodal-dispatch` | `route` |
| `using-git-worktrees` | `verify-worktree` |
| `plan-creation-pipeline` | `plan-creation`, `completion` |
| `issue-operations-core` | `push-artifacts` |
| `writing-plans` | `create`, `update`, `retroactive`, `holistic-self-check` |

## Brainstorming Task Card Requirements

### `top-down-analysis.md`

**Sub-agent task — produces code-level analytical artifacts as preliminary drafts.**

**TDT triggers:** `"top-down analysis" / "decompose"`, `"blast-radius analysis needed"`, `"code-path-inventory needed"`, `"interface-compatibility needed"`, `"state-analysis needed"`, `"testability-assessment needed"`

**Entry criteria:**
- Pre-spec inspection completed (results available from `explore/pre-spec-inspection.md`)
- Issue number and project_root provided in context
- `srclight` tools available for code analysis

**Content requirements (what the task card must instruct):**
1. Read pre-spec-inspection results from exploration artifacts
2. For each affected symbol/file identified, use `srclight` tools to trace dependents, callers, callees, and signatures
3. Write preliminary artifact files to `{project_root}/tmp/{issue-N}/artifacts/preliminary/`:
   - `blast-radius.md` — Files/symbols affected by the change, with impact classification (direct consumer, indirect consumer, data-flow dependent)
   - `code-paths.md` — Execution paths through affected code, with path inventory
   - `interface-compat.md` — Public API compatibility assessment with signature verification
   - `state-analysis.md` — Persistent state affected by the change, with state transition model
   - `testability.md` — Existing test coverage evaluation of affected paths
4. Each artifact is a MARKDOWN file with structured YAML frontmatter (name, status, source_issue)
5. Status is `complete`, `partial`, or `not-applicable` — with justification for non-complete statuses

**Exit criteria:**
- All applicable preliminary artifacts written to disk
- Handoff contract updated (or report back to parent for handoff assembly)
- Result contract: `{status: complete|partial|failed, artifact_paths: [...], finding_summary}`

**Existing source material (task card author MUST read these for procedure content):**
- `explore/exploration-workflow.md` Step 2.5 — artifact paths, content, handoff contract format
- `explore/pre-spec-inspection.md` lines 33-36 — verification actions for each artifact
- `enforcement.md` Investigation Completion Criteria lines 101-107 — per-artifact completion requirements

**Context passed from TDT:** `{issue_number}`

### `cross-scope.md`

**Sub-agent task — produces concern-boundary artifacts and runs cross-spec scope search.**

**TDT triggers:** `"cross-scope" / "scope analysis"`, `"concern-map needed"`, `"cross-cutting-matrix needed"`

**Entry criteria:**
- Pre-spec inspection completed (results available)
- Issue number and project_root provided in context

**Content requirements:**
1. **Cross-spec scope search:** Query open GitHub Issues for specs/plans with overlap. Classify as FULL-SUPERSESSION, PARTIAL-OVERLAP, CONFLICT-RISK, or INDEPENDENT using the four-tier classification from `explore/pre-spec-inspection.md` Step 0.5.
2. **Concern map:** Map affected areas to concern boundaries. Identify where one concern spans multiple units or one unit addresses multiple concerns.
3. **Cross-cutting matrix:** Identify concerns spanning multiple phases/components. Produce a concern-to-phase matrix.
4. Write preliminary artifact files to `{project_root}/tmp/{issue-N}/artifacts/preliminary/`:
   - `concern-map.md` — Concern boundaries mapped to affected areas
   - `cross-cutting.md` — Cross-cutting concerns with propagation map

**Exit criteria:**
- Cross-spec scope search complete with classification
- Concern map and cross-cutting artifacts written to disk
- If FULL-SUPERSESSION found: return BLOCKED with supersession details (parent task route to existing spec instead)
- If CONFLICT-RISK found: return BLOCKED with conflict details
- Result contract: `{status: complete|partial|blocked|failed, artifact_paths: [...], supersession_details?: {...}, finding_summary}`

**Existing source material (task card author MUST read these for procedure content):**
- `explore/pre-spec-inspection.md` Step 0.5 — cross-spec scope search procedure
- `explore/exploration-workflow.md` Step 2.5 — artifact format and paths
- `explore/pre-spec-inspection.md` line 32 — concern map verification action

**Context passed from TDT:** `{issue_number}`

## Root Cause

Trigger Dispatch Tables were written with task references before the corresponding task card files were created.

## Fix

For each missing task card, create a `.md` file in the skill's `tasks/` directory with entry criteria, inline-only steps, and exit criteria.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | All 28 missing task cards exist as `.md` files | `string` | Verify each file exists |
| SC-1.1 | Brainstorming task cards (`top-down-analysis.md`, `cross-scope.md`) contain all required procedure per §Brainstorming Task Card Requirements | `string` | Verify both files exist and contain the required sections |
| SC-2 | Each new task card has entry criteria, inline steps, exit criteria | `string` | Sample audit of 5 new task cards |
| SC-3 | No TDT references a non-existent task card | `string` | Cross-reference all TDTs against filesystem |

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Load [Test Integrity Mandate](guidelines/080-code-standards.md).

After this spec is approved, invoke `writing-plans` to create `.issues/2039/plan.md` before implementation begins.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
