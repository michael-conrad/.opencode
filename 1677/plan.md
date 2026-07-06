# Plan: Canonical project_root variable for submodule-aware path resolution

## Goal

Emit `project_root` from session-init as `git rev-parse --show-toplevel`; update all task files, guidelines, and tools to use `{project_root}`-based paths instead of relative `./tmp/` and `*/.issues/` patterns; add behavioral enforcement tests.

## Architecture

| Component | Change |
|-----------|--------|
| `.opencode/tools/session-init` | Add `project_root` field emitting absolute top-level git root |
| `.opencode/guidelines/060-tool-usage.md` | Replace workdir-aware path composition with `project_root`-based resolution |
| `.opencode/skills/*/tasks/*.md` | Replace `./tmp/` → `{project_root}/tmp/`; replace `*/.issues/` → `{project_root}/{path}/.issues/{N}/` per repo entry |
| `.opencode/guidelines/*.md` | Same path replacements as task files |
| `.opencode/tools/local-issues` | Assess and update for `project_root`-based path resolution |
| `.opencode/tests/behaviors/` | New behavioral tests for `project_root` usage from submodule CWD |

## Files Affected

- `.opencode/tools/session-init` — Phase 1
- `.opencode/guidelines/060-tool-usage.md` — Phase 2
- `.opencode/skills/*/tasks/*.md` — Phase 3 (42+ files with `*/.issues/` patterns)
- `.opencode/guidelines/*.md` — Phase 3
- `.opencode/tools/local-issues` — Phase 3 (assess/update)
- `.opencode/tests/behaviors/` — Phase 4 (new files)

## Dependency Ordering

```
Phase 1 (session-init) ──→ Phase 2 (060-tool-usage) ──→ Phase 3 (task files) ──→ Phase 4 (behavioral tests)
       │                         │                            │
       │                         │                            └── SC-5 (local-issues) — parallel with task files
       │                         └── SC-7 (060-tool-usage) — standalone
       │
       └── SC-3 (dispatch context) — cross-cutting, verified in Phase 1
```

## Phase Table

| Phase | Description | SCs | Dependencies |
|-------|-------------|-----|--------------|
| 1 | session-init emission | SC-1, SC-2, SC-3 | None |
| 2 | 060-tool-usage.md update | SC-7 | Phase 1 |
| 3 | Task file migration | SC-4, SC-5 | Phase 1, Phase 2 |
| 4 | Behavioral enforcement tests | SC-6, SC-8 | Phase 1, Phase 2, Phase 3 |

---

## Phase 1: session-init emission

### Items

#### Item 1.1: RED — Write behavioral test for session-init `project_root` emission

| Field | Value |
|-------|-------|
| **SC** | SC-1, SC-2 |
| **Evidence Type** | `behavioral` |
| **Test File** | `.opencode/tests/behaviors/project-root-session-init.sh` |
| **RED Command** | `bash .opencode/tests/behaviors/project-root-session-init.sh` (expected: FAIL) |
| **GREEN Command** | Same command (expected: PASS) |

**Test logic:**
1. Run `./.opencode/tools/session-init` and grep for `project_root`
2. Verify value matches `git rev-parse --show-toplevel` from project root
3. `cd .opencode/` and re-run `./.opencode/tools/session-init`; verify `project_root` still matches project root, NOT `.opencode/`

#### Item 1.2: GREEN — Add `project_root` to session-init output

| Field | Value |
|-------|-------|
| **SC** | SC-1, SC-2 |
| **File** | `.opencode/tools/session-init` |
| **Change** | Add line: `project_root: $(git rev-parse --show-toplevel)` |
| **Verification** | Run `./.opencode/tools/session-init \| grep project_root`; verify absolute path |

#### Item 1.3: RED — Write behavioral test for `project_root` propagation in sub-agent dispatch context

| Field | Value |
|-------|-------|
| **SC** | SC-3 |
| **Evidence Type** | `behavioral` |
| **Test File** | `.opencode/tests/behaviors/project-root-dispatch-context.sh` |
| **RED Command** | `bash .opencode/tests/behaviors/project-root-dispatch-context.sh` (expected: FAIL) |
| **GREEN Command** | Same command (expected: PASS) |

**Test logic:**
1. Task a sub-agent with a prompt that triggers path resolution
2. Verify stderr shows `project_root`-based path in sub-agent context

#### Item 1.4: GREEN — Add `project_root` to dispatch context contract in skill SKILL.md files

| Field | Value |
|-------|-------|
| **SC** | SC-3 |
| **Files** | All `.opencode/skills/*/SKILL.md` files with dispatch context contracts |
| **Change** | Add `project_root` as mandatory field in dispatch context |
| **Verification** | Grep for `project_root` in all SKILL.md files |

#### Item 1.5: Verify Phase 1

- [ ] Run behavioral test: `bash .opencode/tests/behaviors/project-root-session-init.sh` → PASS
- [ ] Run behavioral test: `bash .opencode/tests/behaviors/project-root-dispatch-context.sh` → PASS
- [ ] Run `./.opencode/tools/session-init | grep project_root` → value matches `git rev-parse --show-toplevel`
- [ ] Run from `.opencode/` subdirectory → `project_root` still shows project root

---

## Phase 2: 060-tool-usage.md update

### Items

#### Item 2.1: RED — Write behavioral test for `project_root` reference in 060-tool-usage.md

| Field | Value |
|-------|-------|
| **SC** | SC-7 |
| **Evidence Type** | `behavioral` |
| **Test File** | `.opencode/tests/behaviors/project-root-guideline.sh` |
| **RED Command** | `bash .opencode/tests/behaviors/project-root-guideline.sh` (expected: FAIL) |
| **GREEN Command** | Same command (expected: PASS) |

**Test logic:**
1. Read `060-tool-usage.md` and verify workdir-aware composition section is replaced with `project_root`-based resolution
2. Verify all path examples use `{project_root}` prefix

#### Item 2.2: GREEN — Replace workdir-aware path composition in 060-tool-usage.md

| Field | Value |
|-------|-------|
| **SC** | SC-7 |
| **File** | `.opencode/guidelines/060-tool-usage.md` |
| **Change** | Replace §2 "Workdir-Aware Path Composition" section with `project_root`-based resolution. Update all path examples. Remove `.opencode/.opencode/` nesting prohibition (now handled by `project_root`). |

**Replacement content:**
- Remove the "Workdir-Aware Path Composition — CRITICAL" subsection
- Add new subsection: "`project_root`-Based Path Resolution"
- All path examples use `{project_root}/tmp/`, `{project_root}/.issues/{N}/`, `{project_root}/{path}/.issues/{N}/`
- Keep the `.issues/` Worktree Exemption section (still valid)

#### Item 2.3: Verify Phase 2

- [ ] Read `060-tool-usage.md` — verify no remaining workdir-aware composition references
- [ ] Verify `project_root` is referenced in path rules
- [ ] Run behavioral test: `bash .opencode/tests/behaviors/project-root-guideline.sh` → PASS

---

## Phase 3: Task file migration

### Items

#### Item 3.1: RED — Write content-verification test for `./tmp/` and `*/.issues/` patterns

| Field | Value |
|-------|-------|
| **SC** | SC-4 |
| **Evidence Type** | `string` |
| **Test File** | `.opencode/tests/behaviors/project-root-task-files.sh` |
| **RED Command** | `bash .opencode/tests/behaviors/project-root-task-files.sh` (expected: FAIL — patterns still exist) |
| **GREEN Command** | Same command (expected: PASS — zero remaining instances) |

**Test logic:**
1. `grep -rn '\./tmp/' .opencode/skills/*/tasks/*.md .opencode/guidelines/*.md` — expect zero matches
2. `grep -rn '\*/.issues/' .opencode/skills/*/tasks/*.md .opencode/guidelines/*.md` — expect zero matches

#### Item 3.2: GREEN — Replace `./tmp/` with `{project_root}/tmp/` in all task files

| Field | Value |
|-------|-------|
| **SC** | SC-4 |
| **Scope** | All `.opencode/skills/*/tasks/*.md` and `.opencode/guidelines/*.md` |
| **Pattern** | `./tmp/` → `{project_root}/tmp/` |
| **Method** | Automated `sed` or script-based replacement across all matching files |
| **Verification** | `grep -rn '\./tmp/' .opencode/skills/*/tasks/*.md .opencode/guidelines/*.md` → zero matches |

#### Item 3.3: GREEN — Replace `*/.issues/` with `{project_root}/{path}/.issues/{N}/` per repo entry

| Field | Value |
|-------|-------|
| **SC** | SC-4 |
| **Scope** | All `.opencode/skills/*/tasks/*.md` and `.opencode/guidelines/*.md` |
| **Pattern** | `*/.issues/` → `{project_root}/{path}/.issues/{N}/` (where `path` comes from session-init's `## Repo Information` entry) |
| **Method** | Manual per-file replacement — each `*/.issues/` instance must be resolved to the correct repo entry path |
| **Verification** | `grep -rn '\*/.issues/' .opencode/skills/*/tasks/*.md .opencode/guidelines/*.md` → zero matches |

**Note:** The `*/.issues/` pattern appears in two contexts:
- As a glob for submodule issues: `*/.issues/{N}/spec.md` → `{project_root}/.opencode/.issues/{N}/spec.md`
- As a glob for root issues: `.issues/{N}/spec.md` → `{project_root}/.issues/{N}/spec.md`
- Each instance must be evaluated in context to determine which repo entry it targets

#### Item 3.4: Assess and update `local-issues` tool for `project_root`

| Field | Value |
|-------|-------|
| **SC** | SC-5 |
| **File** | `.opencode/tools/local-issues` |
| **Change** | Assess if `local-issues` needs `project_root` for path resolution; update if needed |
| **Verification** | Run `local-issues` commands from inside `.opencode/` submodule; verify correct `.issues/` resolution |

#### Item 3.5: Verify Phase 3

- [ ] `grep -rn '\./tmp/' .opencode/skills/*/tasks/*.md .opencode/guidelines/*.md` → zero matches
- [ ] `grep -rn '\*/.issues/' .opencode/skills/*/tasks/*.md .opencode/guidelines/*.md` → zero matches
- [ ] Run behavioral test: `bash .opencode/tests/behaviors/project-root-task-files.sh` → PASS
- [ ] Run `local-issues` commands from `.opencode/` submodule → correct resolution
- [ ] Verify regression: existing `local-issues` qualified name resolution still works

---

## Phase 4: Behavioral enforcement tests

### Items

#### Item 4.1: RED — Write behavioral test for agent using `project_root` from submodule CWD

| Field | Value |
|-------|-------|
| **SC** | SC-6 |
| **Evidence Type** | `behavioral` |
| **Test File** | `.opencode/tests/behaviors/project-root-submodule-cwd.sh` |
| **RED Command** | `bash .opencode/tests/behaviors/project-root-submodule-cwd.sh` (expected: FAIL) |
| **GREEN Command** | Same command (expected: PASS) |

**Test logic:**
1. `opencode-cli run` with prompt that triggers path resolution from submodule CWD
2. Verify stderr shows `project_root`-based path (not relative path resolving to submodule root)

#### Item 4.2: RED — Write behavioral test for RED state verification (SC-8)

| Field | Value |
|-------|-------|
| **SC** | SC-8 |
| **Evidence Type** | `behavioral` |
| **Test File** | `.opencode/tests/behaviors/project-root-red-state.sh` |
| **RED Command** | `bash .opencode/tests/behaviors/project-root-red-state.sh` (expected: FAIL) |
| **GREEN Command** | Same command (expected: PASS) |

**Test logic:**
1. Verify behavioral test files exist in `.opencode/tests/behaviors/`
2. Run each test and confirm FAIL before implementation (RED state)
3. After implementation, confirm PASS (GREEN state)

#### Item 4.3: Verify Phase 4

- [ ] Run `bash .opencode/tests/behaviors/project-root-submodule-cwd.sh` → PASS
- [ ] Run `bash .opencode/tests/behaviors/project-root-red-state.sh` → PASS
- [ ] All behavioral tests pass with `with-test-home` wrapper

---

## Exit Criteria

- [ ] All 4 phases complete with all items GREEN
- [ ] All SCs (SC-1 through SC-8) verified PASS
- [ ] Zero remaining `./tmp/` or `*/.issues/` patterns in task files and guidelines
- [ ] `project_root` emitted by session-init, propagated in dispatch context
- [ ] `060-tool-usage.md` references `project_root` instead of workdir-aware composition
- [ ] Behavioral tests pass in clean-room `with-test-home` environment
- [ ] Regression: existing `local-issues` qualified name resolution unchanged
- [ ] Regression: session-init output format unchanged for existing fields

## Self-Review Evidence

- [ ] All items have RED/GREEN phases
- [ ] Dependency ordering enforced (Phase 1 → 2 → 3 → 4)
- [ ] Cross-cutting SCs (SC-3, SC-8) verified in their respective phases
- [ ] Regression invariants documented and verifiable
- [ ] Phase-scoped test assertions — no cross-phase over-verification
