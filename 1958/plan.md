# Implementation Plan — [#1958](https://github.com/michael-conrad/.opencode/issues/1958) — Canonical cross-reference format rollout

**Goal:** Replace all non-conforming cross-references in `.opencode/` with the canonical `Load [descriptive text](relative/path.md)` form.

**Files:**
- `.opencode/.issues/1958/plan.md` — This index
- `.opencode/.issues/1958/plan-00-pre-work.md` — Pre-work: branch, submodule tagging
- `.opencode/.issues/1958/plan-01-discovery.md` — Phase 1: Discovery and inventory
- `.opencode/.issues/1958/plan-02-replacement.md` — Phase 2: Replace all non-conforming references (per-item TDD)
- `.opencode/.issues/1958/plan-03-close.md` — Phase 3: Close and inform
- `.opencode/.issues/1958/plan-99-post.md` — Post-implementation: VbC, finishing checklist, review-prep, behavioral verification
- `.opencode/.issues/1958/data/cross-reference-inventory.yaml` — Phase 1 output

## Blast Radius

- `.opencode/guidelines/*.md` — All guideline files
- `.opencode/skills/*/SKILL.md` — All SKILL.md files
- `.opencode/skills/*/tasks/*.md` — All task files
- `.opencode/prompts/default.txt` — Cross-reference directive
- `.opencode/scripts/*.py` — May contain cross-references in docstrings

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Items | Dispatch |
|-------|------|---------|-----|-------------|-------|----------|
| 0 | Pre-work | Branch, submodule tagging | — | None | 1 | `git-workflow --task pre-work` |
| 1 | Discovery and Inventory | Scan all files, classify cross-references, output inventory YAML | SC-1 | Phase 0 | 1 | Clean-room sub-agent |
| 2 | Replace All Non-Conforming References | Per-item TDD: RED (behavioral test) → GREEN (edit) → REFACTOR → COMMIT | SC-2 through SC-7 | Phase 1 | N items (one per file group) | `implementation-pipeline` |
| 3 | Close and Inform | Close #1953, comment on #1925 and #1926 | SC-8, SC-9 | Phase 2 | 3 | `issue-operations` |
| 4 | Post-Implementation | VbC, finishing checklist, review-prep, behavioral verification | All SCs | Phase 3 | 4 | `verification-before-completion`, `finishing-a-development-branch`, `git-workflow --task review-prep` |

## SC-to-Step Traceability

| SC ID | Criterion | Evidence Type | Phase | Item(s) |
|-------|-----------|---------------|-------|---------|
| SC-1 | Cross-reference inventory produced | structural | 1 | 1.1 |
| SC-2 | 000-critical-rules.md updated to `Load [Text](path)` | behavioral | 2 | 2.1 |
| SC-3 | No `See [` or `Read [` in any SKILL.md | behavioral | 2 | 2.2 |
| SC-4 | No `See [` or `Read [` in any guideline | behavioral | 2 | 2.3 |
| SC-5 | No `§N` or `§Name` bare references in any SKILL.md | behavioral | 2 | 2.4 |
| SC-6 | No resolution table patterns in any SKILL.md | behavioral | 2 | 2.5 |
| SC-7 | No non-linked text references in any SKILL.md | behavioral | 2 | 2.6 |
| SC-8 | #1953 closed as superseded | structural | 3 | 3.1 |
| SC-9 | #1925 and #1926 have comments linking to this spec | structural | 3 | 3.2, 3.3 |

**Note:** SC-2 through SC-7 are auto-uplifted from `string` to `behavioral` per [critical-rules-BEH-EV] — changing cross-reference patterns IS a runtime-behavioral change (it affects how agents interpret and act on cross-references). Each item in Phase 2 requires a behavioral enforcement test (RED) before the edit (GREEN).

## Pipeline Chain

```
pre-work → implementation-pipeline (per-item TDD) → VbC → finishing-checklist → review-prep
```

Every step is MANDATORY. No step may be skipped.

## Safety/Rollback

- Phase 1: Read-only — no rollback needed
- Phase 2: `git checkout .opencode/` to restore originals; checkpoint tags at each item boundary
- Phase 3: Reopen #1953 if closed in error
- Phase 4: All verification gates must PASS before PR creation

## Exit Criteria

- [ ] C1: Phase 0 complete — feature branch created, submodule tagged
- [ ] C2: Phase 1 complete — cross-reference inventory produced
- [ ] C3: Phase 2 complete — all items through TDD cycle, all behavioral tests PASS
- [ ] C4: Phase 3 complete — #1953 closed, #1925 and #1926 have comments
- [ ] C5: Phase 4 complete — VbC PASS, finishing checklist PASS, review-prep complete
- [ ] C6: All SCs verified PASS with correct evidence type
- [ ] C7: No SC weakened, deferred, or reclassified
