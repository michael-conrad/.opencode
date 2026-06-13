<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Plan: Pipeline Enforcement — Evidence Uplift, Doc-Source Check, SC Traceability, Anti-Merge, SC-ID Format

> **Spec:** `.opencode/.issues/1063/spec.md`
> **Repos:** michael-conrad/.opencode (submodule), michael-conrad/opencode-config (parent)

## Authorization Scope

| Field | Value |
|-------|-------|
| `authorization_scope` | `for_pr` |
| `halt_at` | `pr_created` |
| `pr_strategy` | `stacked` |

## Dependency Ordering

| Phase | Depends On | Items | Files |
|-------|-----------|-------|-------|
| Phase 1 | None | 1–6 | `.opencode/skills/implementation-pipeline/SKILL.md` |
| Phase 2 | Phase 1 verified PASS | 7–9 | `tasks/red.md`, `tasks/green.md`, TDD `SKILL.md` |

## Checkpoint Tags

| Boundary | Tag |
|----------|-----|
| Phase 1 PASS | `opencode-config/checkpoint/1063/phase-1-opencode` |
| Phase 2 PASS | `opencode-config/checkpoint/1063/phase-2-opencode` |

## Z3 Solve Checks

### Phase Transition 1→2 (after Phase 1 PASS, before Phase 2 start)

```
solve check --state-path ./tmp/1063/state/ --contract-path .opencode/.issues/1063/spec-artifacts/pipeline-state-machine.yaml
```

Expected: strict-adjacency invariant satisfied.

### Terminal (after Phase 2 PASS)

```
solve check --state-path ./tmp/1063/state/ --contract-path .opencode/.issues/1063/spec-artifacts/pipeline-state-machine.yaml
```

Expected: all invariants satisfied.

## Rollback Instructions

On verification failure at any checkpoint:

1. Report pre-rollback diagnostics: `git status`, `git diff --stat`, `solve check` output
2. Read pipeline state to determine `$LAST_PASS_PHASE`
3. Execute: `git reset --hard opencode-config/checkpoint/1063/phase-<LAST_PASS_PHASE>-opencode && git submodule update --init`
4. Read restored pipeline state
5. Re-dispatch the failed phase with original dispatch parameters

First-step failure (no checkpoint): `git checkout .` to clean working tree, re-dispatch from current state.

## Orchestrator Workflow

The orchestrator is a pure router. It NEVER reads task file content, NEVER performs inline analysis, NEVER edits files directly. For each TDD item below:

1. **Orchestrator dispatches** a clean-room sub-agent via `task(subagent_type="general")` with only the context in the Dispatch Context column
2. **Sub-agent executes** RED/GREEN/REFACTOR steps — reads files, runs commands, applies edits
3. **Sub-agent returns** a result contract: `{ status, finding_summary, artifact_path?, blocker_reason? }`
4. **Orchestrator verifies** the result contract shows DONE, then proceeds to next TDD item
5. On BLOCKED: discard all sub-agent work, re-task clean-room (max 2 retries)

## Phase 1: Pipeline Routing Table Updates

**Orchestrator sequence:** dispatch TDD-1 → dispatch TDD-2 → dispatch TDD-3 → dispatch TDD-4 → dispatch TDD-5 → dispatch TDD-6 → Z3 solve check → checkpoint tag → proceed to Phase 2

All 6 TDD items modify `.opencode/skills/implementation-pipeline/SKILL.md`.

---

### TDD-1: Update sc-coherence-gate with evidence-type uplift scan (SC-6)

**Dispatch Context:**
```
{ task: "TDD-1", file: ".opencode/skills/implementation-pipeline/SKILL.md", sc_ids: ["SC-6"], authorization_scope: for_pr }
```

**Sub-agent executes:**

RED: Run `grep "evidence-type uplift" .opencode/skills/implementation-pipeline/SKILL.md` — expect exit 1 (no match found)
GREEN: Edit the `sc-coherence-gate` row. Change:
```
| `sc-coherence-gate` | `adversarial-audit --task coherence-extraction` | coherence check results |
```
to:
```
| `sc-coherence-gate` | `adversarial-audit --task coherence-extraction` (evidence-type uplift + substrate classification) | coherence check results + uplift verdict |
```

Run `grep "evidence-type uplift" .opencode/skills/implementation-pipeline/SKILL.md` — expect exit 0
REFACTOR: Confirm adjacent rows unchanged. Verify table pipes align.

**Sub-agent returns:** `{ status: DONE, finding_summary: "sc-coherence-gate row updated with evidence-type uplift scan description" }`

---

### TDD-2: Update pre-red-baseline with doc-source-currency check (SC-7, SC-8)

**Dispatch Context:**
```
{ task: "TDD-2", file: ".opencode/skills/implementation-pipeline/SKILL.md", sc_ids: ["SC-7", "SC-8"], authorization_scope: for_pr }
```

**Sub-agent executes:**

RED: Run `grep "doc-source-currency" .opencode/skills/implementation-pipeline/SKILL.md` — expect exit 1
GREEN: Edit the `pre-red-baseline` row. Change:
```
| `pre-red-baseline` | `implementation-pipeline --task pre-red-baseline` (simple bash) | solution state file |
```
to:
```
| `pre-red-baseline` | `implementation-pipeline --task pre-red-baseline` (doc-source-currency + SC-ID cross-ref traceability) | solution state file + source currency report |
```

Run `grep "doc-source-currency" .opencode/skills/implementation-pipeline/SKILL.md` — expect exit 0
REFACTOR: Confirm the dispatches-to target still resolves to the same task.

**Sub-agent returns:** `{ status: DONE, finding_summary: "pre-red-baseline row updated with doc-source-currency + SC-ID traceability" }`

---

### TDD-3: Update green-doublecheck with semantic-intent verification (SC-9)

**Dispatch Context:**
```
{ task: "TDD-3", file: ".opencode/skills/implementation-pipeline/SKILL.md", sc_ids: ["SC-9"], authorization_scope: for_pr }
```

**Sub-agent executes:**

RED: Run `grep "semantic-intent" .opencode/skills/implementation-pipeline/SKILL.md` — expect exit 1
GREEN: Edit the `green-doublecheck` row. Change:
```
| `green-doublecheck` | `verification-before-completion --task verify` | GREEN-side SC evidence |
```
to:
```
| `green-doublecheck` | `verification-before-completion --task verify` (semantic-intent verification) | GREEN-side SC evidence + intent verdict |
```

Run `grep "semantic-intent" .opencode/skills/implementation-pipeline/SKILL.md` — expect exit 0
REFACTOR: Verify adjacent rows `structural-checks` and `green-vbc` unchanged.

**Sub-agent returns:** `{ status: DONE, finding_summary: "green-doublecheck row updated with semantic-intent verification" }`

---

### TDD-4: Add post-red-enforcement to routing table (SC-1, SC-5)

**Dispatch Context:**
```
{ task: "TDD-4", file: ".opencode/skills/implementation-pipeline/SKILL.md", sc_ids: ["SC-1", "SC-5"], authorization_scope: for_pr }
```

**Sub-agent executes:**

RED: Run `grep "post-red-enforcement" .opencode/skills/implementation-pipeline/SKILL.md | wc -l` — expect output "0"
GREEN:

1. Insert new row in Dispatch Routing Table between `red-doublecheck` and `green-phase`:
```
| `post-red-enforcement` | `implementation-pipeline --task post-red-enforcement` (git diff --name-only -- src/ \| wc -l) | git diff structural gate result |
```

2. Add pre-cleanup entry in Step-Specific Pre-Cleanup table:
```
| `post-red-enforcement` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-post-red-enforcement-*` |
```

3. Update Overview sentence from "14 serial dispatch steps" to "16 serial dispatch steps"

Run `grep "post-red-enforcement" .opencode/skills/implementation-pipeline/SKILL.md | wc -l` — expect output > "0"
REFACTOR: Verify `green-phase` row is immediately after `post-red-enforcement` row.

**Sub-agent returns:** `{ status: DONE, finding_summary: "post-red-enforcement row added between red-doublecheck and green-phase" }`

---

### TDD-5: Add post-green-enforcement to routing table (SC-2, SC-5)

**Dispatch Context:**
```
{ task: "TDD-5", file: ".opencode/skills/implementation-pipeline/SKILL.md", sc_ids: ["SC-2", "SC-5"], authorization_scope: for_pr }
```

**Sub-agent executes:**

RED: Run `grep "post-green-enforcement" .opencode/skills/implementation-pipeline/SKILL.md | wc -l` — expect output "0"
GREEN:

1. Insert new row in Dispatch Routing Table between `green-phase` and `checkpoint-commit`:
```
| `post-green-enforcement` | `implementation-pipeline --task post-green-enforcement` (git diff --name-only -- test/ \| wc -l) | git diff structural gate result |
```

2. Add pre-cleanup entry in Step-Specific Pre-Cleanup table:
```
| `post-green-enforcement` | `rm -f ./tmp/{issue-N}/artifacts/pipeline-post-green-enforcement-*` |
```

Run `grep "post-green-enforcement" .opencode/skills/implementation-pipeline/SKILL.md | wc -l` — expect output > "0"
REFACTOR: Verify `checkpoint-commit` row is immediately after `post-green-enforcement` row.

**Sub-agent returns:** `{ status: DONE, finding_summary: "post-green-enforcement row added between green-phase and checkpoint-commit" }`

---

### TDD-6: Update step labels list to 16 entries (SC-10)

**Dispatch Context:**
```
{ task: "TDD-6", file: ".opencode/skills/implementation-pipeline/SKILL.md", sc_ids: ["SC-10"], authorization_scope: for_pr }
```

**Sub-agent executes:**

RED: Count entries in Step Labels line. Currently 14 entries. Extract via grep for the backtick-comma pattern and count words. Expect 14.
GREEN: Replace the Step Labels line (under `## Step Labels (for #932 naming convention)`) with:
```
`sc-coherence-gate`, `pre-red-baseline`, `red-phase`, `red-doublecheck`, `post-red-enforcement`, `green-phase`, `post-green-enforcement`, `checkpoint-commit`, `structural-checks`, `green-doublecheck`, `green-vbc`, `adversarial-audit`, `cross-validate`, `regression-check`, `review-prep`, `exec-summary`
```

Count entries: expect 16.
REFACTOR: Verify the 2 new entries are in correct positions (post-red-enforcement at position 5, post-green-enforcement at position 7).

**Sub-agent returns:** `{ status: DONE, finding_summary: "Step labels updated to 16 entries with post-red-enforcement and post-green-enforcement" }`

---

### Phase 1→2 Boundary (Orchestrator does this, NOT a sub-agent)

After all 6 TDD sub-agents return DONE:

1. **Z3 check:** `solve check --state-path ./tmp/1063/state/ --contract-path .opencode/.issues/1063/spec-artifacts/pipeline-state-machine.yaml`
   - Must get SAT (all invariants satisfied)
   - On UNSAT: BLOCKED — pipeline defect

2. **Checkpoint tag:**
   ```
   git tag opencode-config/checkpoint/1063/phase-1-opencode
   ```

3. **Verify Phase 1 SC coverage:**
   - SC-1: grep post-red-enforcement row exists → PASS
   - SC-2: grep post-green-enforcement row exists → PASS
   - SC-5: grep both enforcement rows exist → PASS
   - SC-6: grep evidence-type uplift in sc-coherence-gate row → PASS
   - SC-7: grep doc-source-currency in pre-red-baseline row → PASS
   - SC-8: grep SC-ID cross-ref in pre-red-baseline row → PASS
   - SC-9: grep semantic-intent in green-doublecheck row → PASS
   - SC-10: count step labels = 16 → PASS

4. **Proceed to Phase 2**
   - `todowrite` update: mark Phase 1 complete, start Phase 2

---

## Phase 2: TDD Task Enforcement Updates

**Orchestrator sequence:** dispatch TDD-7 → dispatch TDD-8 → dispatch TDD-9 → Z3 solve check → checkpoint tag

Items 7–9 modify `tasks/red.md`, `tasks/green.md`, and TDD `SKILL.md`.

---

### TDD-7: Add RED persona enforcement to red.md (SC-3)

**Dispatch Context:**
```
{ task: "TDD-7", file: ".opencode/skills/test-driven-development/tasks/red.md", sc_ids: ["SC-3"], authorization_scope: for_pr }
```

**Sub-agent executes:**

RED: Run `grep -E "MUST NOT.*(implementation|source)" .opencode/skills/test-driven-development/tasks/red.md` — expect exit 1
GREEN: Append after the `## Required RED Structure` section at end of file:
```markdown

## RED Persona Enforcement

RED-phase sub-agents write tests only — they MUST NOT modify `src/` or any implementation files.

### 🚫 FORBIDDEN

- Modifying any file under `src/`
- Writing implementation code of any kind
- Editing configuration files that change program behavior
- Creating or modifying files outside the designated test path

### ✅ PERMITTED

- Writing test files in the designated test path
- Modifying existing test files
- Creating test fixture files in `test/` or designated test directories
- Reading any source file for test design

### Violation Handling

The `post-red-enforcement` gate executes `git diff --name-only -- src/ | wc -l` and FAILs if the count > 0. If this gate fires, the orchestrator re-dispatches the RED-phase from clean-room state — no inline fallback.
```

Run `grep -E "MUST NOT.*(implementation|source)" .opencode/skills/test-driven-development/tasks/red.md` — expect exit 0
REFACTOR: Run `uvx pymarkdownlnt scan -r .opencode/skills/test-driven-development/tasks/red.md`

**Sub-agent returns:** `{ status: DONE, finding_summary: "RED Persona Enforcement block added to tasks/red.md with MUST NOT implementation constraint" }`

---

### TDD-8: Add GREEN persona enforcement to green.md (SC-4)

**Dispatch Context:**
```
{ task: "TDD-8", file: ".opencode/skills/test-driven-development/tasks/green.md", sc_ids: ["SC-4"], authorization_scope: for_pr }
```

**Sub-agent executes:**

RED: Run `grep -E "MUST NOT.*(test|test file)" .opencode/skills/test-driven-development/tasks/green.md` — expect exit 1
GREEN: Append after existing content:
```markdown

## GREEN Persona Enforcement

GREEN-phase sub-agents implement code only — they MUST NOT write or modify test files.

### 🚫 FORBIDDEN

- Writing new test files
- Modifying existing test files
- Editing test fixtures or test configuration
- Creating any file under `test/` or designated test directories

### ✅ PERMITTED

- Writing implementation code in `src/` or designated source directories
- Modifying existing source files
- Running tests to confirm PASS status (read-only execution)
- Reading test files to understand expected behavior

### Violation Handling

The `post-green-enforcement` gate executes `git diff --name-only -- test/ | wc -l` and FAILs if the count > 0. If this gate fires, the orchestrator re-dispatches the GREEN-phase from clean-room state — no inline fallback.
```

Run `grep -E "MUST NOT.*(test|test file)" .opencode/skills/test-driven-development/tasks/green.md` — expect exit 0
REFACTOR: Run `uvx pymarkdownlnt scan -r .opencode/skills/test-driven-development/tasks/green.md`

**Sub-agent returns:** `{ status: DONE, finding_summary: "GREEN Persona Enforcement block added to tasks/green.md with MUST NOT test constraint" }`

---

### TDD-9: Add TDD heading format requirement to TDD SKILL.md (SC-11, SC-12)

**Dispatch Context:**
```
{ task: "TDD-9", file: ".opencode/skills/test-driven-development/SKILL.md", sc_ids: ["SC-11", "SC-12"], authorization_scope: for_pr }
```

**Sub-agent executes:**

RED: Run `grep -i "sc-id.*heading\|heading.*sc-id\|tdd.*sc-\|SC-\d\+.*heading" .opencode/skills/test-driven-development/SKILL.md` — expect exit 1
GREEN: After the `## Five Core Principles` section and before `## ASCII Cycle Diagram`, insert:
```markdown

## TDD Heading Format Requirement

All TDD task headings in plan documents MUST use the SC-ID parenthetical format:

```
### TDD-<N>: <description> (SC-<ID>, SC-<ID>, ...)
```

### Examples

**✅ CORRECT:**
```
### TDD-1: Update sc-coherence-gate with evidence-type uplift scan (SC-6)
### TDD-4: Add post-red-enforcement to routing table (SC-1, SC-5)
```

**🚫 INCORRECT:**
```
### TDD-1: Update sc-coherence-gate with evidence-type uplift scan  ← missing SC-ID
### TDD-4: Add post-red-enforcement: SC-1, SC-5  ← wrong format
```

### Enforcement

The `pre-red-baseline` sub-agent parses plan TDD headings, extracts SC-IDs, and cross-references against the spec SC table. If any TDD heading references an SC-ID that does not exist in the spec, the gate returns BLOCKED with `MISSING-TRACEABILITY`.

### SC-ID Extraction Contract

| Field | Format | Required |
|-------|--------|----------|
| Prefix | `### TDD-<N>:` | Yes |
| Description | Any text | Yes |
| SC-ID reference | `(SC-<ID>, SC-<ID>, ...)` | Yes — must match spec SC table |
| Multiple SC-IDs | Comma-separated | Optional |
| Whitespace | Space after comma | Recommended |
```

Run `grep -i "sc-id.*heading\|heading.*sc-id\|tdd.*sc-\|SC-\d\+.*heading" .opencode/skills/test-driven-development/SKILL.md` — expect exit 0
REFACTOR: Run `wc -w .opencode/skills/test-driven-development/SKILL.md` — must be ≤ 4,000.

**Sub-agent returns:** `{ status: DONE, finding_summary: "TDD Heading Format Requirement section added to TDD SKILL.md" }`

---

### Phase 2 Terminal (Orchestrator does this)

After all 3 TDD sub-agents return DONE:

1. **Z3 solve check:**
   ```
   solve check --state-path ./tmp/1063/state/ --contract-path .opencode/.issues/1063/spec-artifacts/pipeline-state-machine.yaml
   ```
   Must get SAT (all invariants satisfied).

2. **Checkpoint tag:**
   ```
   git tag opencode-config/checkpoint/1063/phase-2-opencode
   ```

3. **Verify Phase 2 SC coverage:**
   - SC-3: grep red.md for "MUST NOT" + "implementation" → PASS
   - SC-4: grep green.md for "MUST NOT" + "test" → PASS
   - SC-11: grep TDD SKILL.md for heading format requirement → PASS
   - SC-12: grep TDD SKILL.md for SC-ID extraction contract → PASS

## SC-ID Cross-Reference Matrix

| TDD Item | Phase | SC-IDs Covered | File |
|----------|-------|----------------|------|
| TDD-1 | 1 | SC-6 | implementation-pipeline/SKILL.md |
| TDD-2 | 1 | SC-7, SC-8 | implementation-pipeline/SKILL.md |
| TDD-3 | 1 | SC-9 | implementation-pipeline/SKILL.md |
| TDD-4 | 1 | SC-1, SC-5 | implementation-pipeline/SKILL.md |
| TDD-5 | 1 | SC-2, SC-5 | implementation-pipeline/SKILL.md |
| TDD-6 | 1 | SC-10 | implementation-pipeline/SKILL.md |
| TDD-7 | 2 | SC-3 | tasks/red.md |
| TDD-8 | 2 | SC-4 | tasks/green.md |
| TDD-9 | 2 | SC-11, SC-12 | TDD SKILL.md |

## Verification Pass Structure

| Gate | Phase | What It Verifies |
|------|-------|------------------|
| Phase 1 checkpoint | 1→2 boundary | All Phase 1 SCs via grep evidence. Z3 solve check validates 16-step ordering. |
| Phase 2 checkpoint | 2→terminal | All Phase 2 SCs via grep evidence. Z3 solve check validates full pipeline. |
| No cross-phase | — | Phase 1 tests do NOT assert Phase 2 SC-IDs. Phase 2 tests do NOT assert Phase 1 SC-IDs. |

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)