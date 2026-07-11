# Phase 2: Spec-Audit Holistic Gate + DRAFT Protocol

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-9
**Dependencies:** Phase 1 (cross-reference file exists)

## Steps

1. Read `.opencode/skills/audit/tasks/spec-audit.md` to understand current structure (Steps 1-14)

2. Insert holistic semantic evaluation as **Step 2** (before current Step 3 "Build Evaluation Criteria"):
   - Dispatch clean-room sub-agent with spec body
   - Sub-agent evaluates 11 dimensions: Implementability, Internal Consistency, Completeness, Scope Discipline, Testability, Escape Hatches, Provenance, Feasibility, Safety, Traceability, Correctness
   - Each dimension gets single PASS/FAIL
   - If any FAIL → halt with DRAFT verdict, narrow criteria never run
   - If all PASS → proceed to narrow criteria (current Step 3+)

3. Add DRAFT status protocol:
   - Read spec's STATUS marker from issue body
   - If STATUS not already DRAFT, set STATUS to DRAFT
   - Post comment: "Spec marked DRAFT: [dimension(s)] failed. [Explanation]. Resolution: [guidance]."
   - Include DRAFT status change in verdict artifact

4. Preserve all existing narrow criteria (SC-1 through SC-14, SC-DET, SC-REASONING, SC-CLAIM, etc.) as secondary gates after holistic gate

5. Add sync header comment referencing cross-reference file

## Verification

- SC-1: `grep` for holistic evaluation step positioned before Step 3 in spec-audit.md
- SC-2: `grep` for all 11 dimension names in holistic evaluation step
- SC-3: `behavioral` — `opencode-cli run` with ambiguous spec → audit halts at holistic gate, DRAFT verdict
- SC-4: `behavioral` — `opencode-cli run` with ambiguous spec → issue comment posted with DRAFT status
- SC-9: `grep` for all existing criteria still present in evaluation table
