> **Full spec and artifacts: [`.issues/2039/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2039/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/2039/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

Spec #2039 was filed 2026-07-21 claiming "28 task cards referenced in Trigger Dispatch Tables are missing." Since then the skill deck has been substantially restructured: two skills (`approval-gate-scope`, `plan-creation-pipeline`) were merged or deleted, and several skills were consolidated into flat architectures. A live research analysis (2026-08-29, see `tmp/opencode-2039-card-analysis.md`) confirmed that only **10** of the 28 cards are still genuinely missing. The other 18 are stale: 3 already exist, 12 are obsolete (skills merged/deleted, functionality folded), and 3 were renamed/folded.

The durable requirement is **TDT-reference integrity** — no Trigger Dispatch Table or Invocation references a non-existent task card. This spec is re-scoped to the 10 confirmed STILL-MISSING cards plus the two special-case dangling references that require explicit resolution.

## Affected Skills

The 10 STILL-MISSING cards, grouped by current skill names:

| Skill | Missing Task Cards |
|-------|-------------------|
| `brainstorming` | `top-down-analysis`, `cross-scope` — see [§Brainstorming Task Card Requirements](#brainstorming-task-card-requirements) |
| `programming-principles` | `check-limits`, `decompose` |
| `skill-creator` | `init`, `package`, `fragment-management` |
| `using-git-worktrees` | `verify-worktree` |
| `issue-operations-core` | `push-artifacts` (special case — see [§Special-Case Decisions](#special-case-decisions)) |
| `multimodal-dispatch` | `route` (special case — see [§Special-Case Decisions](#special-case-decisions)) |

**Out of scope:** The original 28-card list included 3 already-existing cards (`apply-label`, `principles`, `create`), 12 obsolete cards from the merged/deleted `approval-gate-scope` and `plan-creation-pipeline` skills (functionality folded into surviving skills), and 3 renamed/folded cards (`browse`/`test` → `commands-reference`, `update` → `revise`, `retroactive` → `backfill`). These 18 cards are intentionally NOT in scope — creating them would duplicate existing or obsolete functionality.

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

## Special-Case Decisions

Two of the 10 STILL-MISSING cards require an explicit resolution decision during implementation because their dangling references may be better resolved by TDT cleanup than by card creation. **SC-4 requires** that whichever decision is made, no dangling reference remains.

### `multimodal-dispatch/tasks/route.md`

The routing function is fully implemented by `dispatch.md` + `resolve.md`. The `route` TDT row and Invocation in `multimodal-dispatch/SKILL.md` are stale dangling references — no `route.md` file exists, and the skill operates correctly via `dispatch`/`dispatch-multi`/`resolve`.

**Recommended fix: remove the stale `route` TDT row and Invocation, rerouting the `"route" / "route task" / "dispatch to model"` triggers to `dispatch`** — rather than creating a redundant card that duplicates `dispatch.md`.

**Decision required:** remove the stale `route` TDT row + Invocation (recommended), OR create a thin alias card that reads modality, resolves the model via `resolve.md`, and calls the model.

### `issue-operations-core/tasks/push-artifacts.md`

The platform sub-skill card EXISTS at `issue-operations/platforms/local/tasks/push-artifacts.md`, and `issue-operations/SKILL.md` already routes `push-artifacts` correctly to that platform-level card. The core-level card is absent; `issue-operations-core/SKILL.md` has a stale TDT row + Invocation referencing the non-existent `issue-operations-core/tasks/push-artifacts.md`.

**Recommended fix: create a thin core dispatcher card** that resolves the target platform (`github.platform`) and routes to the platform sub-skill implementation, capturing the returned `artifact_url` for the documented `spec-creation/tasks/reconcile-push.md` consumer.

**Decision required:** create a thin core dispatcher card (recommended), OR remove the stale core-level TDT row + Invocation and rely on the platform-level card (as `issue-operations` already does).

## Root Cause

Trigger Dispatch Tables were written with task references before the corresponding task card files were created. Since the spec was filed, the skill deck was restructured, making 18 of the original 28 references stale (cards already created, skills merged/deleted, or cards renamed/folded). The remaining 10 references are genuine dangling references.

## Fix

1. Create the 10 confirmed STILL-MISSING task cards as `.md` files in their respective `tasks/` directories, each with entry criteria, inline-only steps, and exit criteria.
2. Resolve the two special-case decisions (`route`, `push-artifacts`): either remove the stale TDT row + Invocation, or create a thin card — such that no dangling TDT reference remains (SC-3, SC-4).

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The 10 confirmed STILL-MISSING task cards exist as `.md` files (or, for the two special cases, the dangling reference is resolved per SC-4) | `string` | Verify each file exists, or TDT row removed |
| SC-1.1 | Brainstorming task cards (`top-down-analysis.md`, `cross-scope.md`) contain all required procedure per §Brainstorming Task Card Requirements | `string` | Verify both files exist and contain the required sections |
| SC-2 | Each of the 10 new task cards has entry criteria, inline steps, exit criteria | `string` | Sample audit of the new task cards |
| SC-3 | No TDT references a non-existent task card | `string` | Cross-reference all TDTs against filesystem |
| SC-4 | The two special-case decisions (`route`, `push-artifacts`) are resolved — either the stale TDT row is removed OR a thin card is created, with no dangling reference remaining | `string` | Verify the `route` and `push-artifacts` TDT rows/Invocation reference an existing card or are removed |

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Load [Test Integrity Mandate](guidelines/080-code-standards.md).

After this spec is approved, invoke `writing-plans` to create `.issues/2039/plan.md` before implementation begins.

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-29 | Re-scoped from 28 cards to the 10 STILL-MISSING cards; updated Affected Skills table; added Special-Case Decisions section; rewrote SC-1 and SC-2; added SC-4 | Live research analysis (`tmp/opencode-2039-card-analysis.md`) confirmed 18 of the original 28 cards are stale (3 exist, 12 obsolete, 3 renamed/folded) | Developer (revision request) |

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
