# Phase 1 — Contract schema alignment

**Concern:** Align the `interface-compatibility.yaml` schema contract between the producer (`backfill.md` step 4) and the consumer (`research.md` step 9) so the producer emits (or the consumer derives) a `dependency_contract` section the downstream Z3 tools can consume.

**Files:**
- `.opencode/skills/writing-plans/tasks/backfill.md`
- `.opencode/skills/writing-plans/tasks/research.md`

**SCs:** SC-1, SC-2

**Dependencies:** None

**Entry Conditions:**
- Spec #2311 approved and `spec-cleared`.
- Feature branch exists and is up to date; `.opencode` submodule on `main` at tracked pointer; working tree clean (steps 1-2 passed).
- Structure artifact (`structure.yaml`) exists with phase_1 → phase_2 DAG and SC mapping.

**Exit Conditions:**
- `backfill.md` step 4 and `research.md` step 9 agree on the `interface-compatibility.yaml` schema (SC-2).
- The producer task instructs inclusion of a `dependency_contract` section, or the consumer task derives the contract from existing keys — either consistently (SC-1).

## Code Path Coverage

(from `code-path-inventory.yaml`)

- `.opencode/skills/writing-plans/tasks/backfill.md` step 4, `interface-compatibility.yaml` bullet — SC-1: add a `dependency_contract` section to the backfill instruction so the producer emits the key `research.md` step 9 consumes.
- `.opencode/skills/writing-plans/tasks/research.md` step 9 — SC-1: update to derive the dependency contract from the producer's actual keys (`interface_boundaries` / `compatibility` / `compatibility_conclusion`) if path (2) is chosen, so it no longer requires a section no producer creates.
- Cross-file grep `grep dependency_contract .opencode/skills/writing-plans/` — SC-2: verify the `dependency_contract` schema reference is consistent across `backfill.md` and `research.md`.
- Cross-check against `skills/writing-plans/contracts/solve-input-template.yaml` and `structure-output-template.yaml` — SC-1: verify the schema matches the Z3 tools' expected contract (Risk 1 mitigation).

## Cross-Cutting SCs

(from `cross-cutting-matrix.yaml`)

- `producer_consumer_coupling` — SC-1: the fix is inherently two-sided; fixing only one side leaves the mismatch in place.
- `schema_definition_consistency` — SC-2: the schema must be defined in one place and referenced consistently across both task files.
- `downstream_z3_tool_contract` — SC-1, SC-3: the `dependency_contract` schema must match what `solve`/`plan` and the `solve-input-template`/`structure-output-template` contracts expect.

## Interface Boundaries

(from `interface-compatibility.yaml`)

- `interface_compatibility_yaml_schema` — the shared contract between producer (`backfill.md` step 4) and consumer (`research.md` step 9). Producer writes `interface_boundaries` / `compatibility` / `compatibility_conclusion`; consumer reads and extracts a `dependency_contract` section. This mismatch is the defect.
- `dependency_contract_extraction` — consumer extracts the contract and writes it to `{issues_prefix}/{N}/dependency-contract.yaml`, consumed by `solve` (model/check) and `plan`.

## State Transitions

(from `state-analysis.yaml`)

- `backfill_artifacts_complete` → `dependency_contract_extracted` (trigger: `research.md` step 9 extracts `dependency_contract`).
- `backfill_artifacts_complete` → `contract_missing` (trigger: step 9 cannot find `dependency_contract` — returns BLOCKED `DEPENDENCY_CONTRACT_NOT_FOUND`). **Forbidden state** — must never block retroactive-backfill plan creation (SC-3).

## Step-by-step

- [ ] 3. **RED (**sub-agent**).** Write an enforcement test that `backfill.md` step 4 (path 1) instructs inclusion of a `dependency_contract` section, or `research.md` step 9 (path 2) derives the contract from the existing artifact keys, for `interface-compatibility.yaml`. Test FAILS on the current task files. **→ SC-1**
- [ ] 4. **GREEN (**sub-agent**).** Update `backfill.md` step 4 and/or `research.md` step 9 to produce/consume a consistent `dependency_contract` section. Apply the chosen path consistently across both task files. **→ SC-1**
- [ ] 5. **GREEN doublecheck (**clean-room**).** Verify the producer (backfill.md) and consumer (research.md) reference the same `interface-compatibility.yaml` schema via cross-file grep; confirm the schema cross-checks against `solve-input-template.yaml` and `structure-output-template.yaml`. **→ SC-1**
- [ ] 6. **Checkpoint commit (**inline**).** Stage and commit the enforcement test and the task-file change atomically. **→ SC-1**

- [ ] 7. **RED (**sub-agent**).** Write a consistency check that the producer (`backfill.md`) and consumer (`research.md`) agree on the `interface-compatibility.yaml` schema. Test FAILS because the schema text is not yet aligned in both files. **→ SC-2**
- [ ] 8. **GREEN (**sub-agent**).** Align the schema contract text in both task files so the producer contract matches the consumer expectation. **→ SC-2**
- [ ] 9. **GREEN doublecheck (**clean-room**).** Verify both task files reference the same agreed schema and no residual mismatch remains between producer and consumer. **→ SC-2**
- [ ] 10. **Checkpoint commit (**inline**).** Stage and commit the consistency test and the schema-alignment change atomically. **→ SC-2**

#### Phase 1 VbC

- [ ] 11. **VbC (**clean-room**).** Verify SC-1 and SC-2 against their evidence types: SC-1 behavioral (opencode run showing `backfill.md` step 4 or `research.md` step 9 producing/deriving the contract), SC-2 structural (cross-file grep showing schema agreement). **→ SC-1, SC-2**

**Concern transition:** Leaving contract schema alignment → entering end-to-end plan creation verification. Phase 2 depends on Phase 1's producer/consumer schema agreement.

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*