> **Full spec and artifacts: [`.issues/2041/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2041/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/2041/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

4 naming inconsistency patterns exist across the skill deck, making it difficult for the orchestrator to resolve task card references:

1. **Hyphenated vs underscored subdirectories** — `pre-implementation-analysis.md` (hyphenated) vs `pre_impl/` subdirectory (underscored) in `approval-gate-scope`
2. **Task name vs subdirectory name mismatch** — `screen-issue.md` exists as top-level file but subdirectory is named `screen/` (not `screen-issue/`)
3. **TDT name vs actual file name mismatch** — `multimodal-dispatch` TDT references task `route` but actual files are `dispatch.md` and `dispatch-multi.md`
4. **writing-plans task routing split** — `writing-plans` SKILL.md TDT references `create`, `update`, `retroactive`, `holistic-self-check` but has no `tasks/` directory

## Root Cause

Inconsistent naming conventions were applied during skill creation. Some TDT entries were written before the corresponding task files were created.

## Fix

1. Convert `pre_impl/` to `pre-impl/`
2. Rename `screen/` to `screen-issue/`
3. Update TDT to reference `dispatch.md` instead of `route`
4. Add `tasks/` directory to `writing-plans` or update TDT to reference sibling skill paths

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | All subdirectory names match their parent task file names | `string` | Verify each subdirectory name matches the parent file name |
| SC-2 | All TDT task names match actual file names | `string` | Cross-reference all TDT entries against filesystem |
| SC-3 | `writing-plans` has a `tasks/` directory or TDT references sibling skills | `string` | Verify resolution of pattern 4 |

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Load [Test Integrity Mandate](guidelines/080-code-standards.md).

After this spec is approved, invoke `writing-plans` to create `.issues/2041/plan.md` before implementation begins.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
