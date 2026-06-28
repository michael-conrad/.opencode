# Implementation Plan — [.opencode#1456](https://github.com/michael-conrad/.opencode/issues/1456) — Fix adversarial-audit description completeness (D3)

- **Spec:** [#1456](https://github.com/michael-conrad/.opencode/issues/1456)
- **Goal:** Replace the `description` field in `.opencode/skills/adversarial-audit/SKILL.md` YAML frontmatter to list all 14 dispatch targets, retain mandatory language, remove narrative-only sentence, and match proposed text exactly.
- **Architecture:** Single-phase, single-file YAML frontmatter edit. No structural changes to skill logic, task files, or guidelines.
- **Files:** `.opencode/skills/adversarial-audit/SKILL.md` — `description` field only

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Each numbered step is a single unit of work. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel.

## Phase 1 — Replace description field in YAML frontmatter

**Concern:** Update the `description` field in `.opencode/skills/adversarial-audit/SKILL.md` YAML frontmatter to match the proposed text exactly.

**Files:**
- `.opencode/skills/adversarial-audit/SKILL.md` — `description` field

**SCs:**
- SC-1: Description lists all 14 dispatch targets
- SC-2: Description retains mandatory language
- SC-3: Narrative-only sentence removed
- SC-4: Description matches proposed text exactly

**Dependencies:** None

**Entry conditions:** Feature branch created from dev, spec approved with `for_pr` scope

**Exit conditions:** Description field updated, all 4 SCs verified PASS

- [ ] 1. **Coherence gate (**clean-room**).** Verify the spec is coherent: single file, single field, no structural changes needed. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 2. **Pre-RED baseline (**clean-room**).** Read the current `description` field from `.opencode/skills/adversarial-audit/SKILL.md` YAML frontmatter. Record the exact current text for diff comparison. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 3. **RED phase — string-verification test (**sub-agent**).** Write a content-verification test that greps the `description` field for the proposed text and asserts it does NOT match yet (RED). Place test in `./tmp/behavioral-evidence-SC-1456/`. **→ SC-4**
- [ ] 4. **Z3 check — RED (**clean-room**).** Verify the RED test artifact exists and the assertion fails (description does not yet match proposed text). **→ SC-4**
- [ ] 5. **RED doublecheck (**clean-room**).** Re-read the current description. Confirm the RED test correctly asserts absence of proposed text. **→ SC-4**
- [ ] 6. **Z3 check — RED doublecheck (**clean-room**).** Confirm doublecheck result matches RED result. **→ SC-4**
- [ ] 7. **Post-RED enforcement (**clean-room**).** Verify no implementation work has begun — only test artifacts exist. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 8. **Z3 check — post-RED (**clean-room**).** Confirm post-RED enforcement passed. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 9. **GREEN phase — edit description field (**sub-agent**).** Replace the `description` field in `.opencode/skills/adversarial-audit/SKILL.md` YAML frontmatter with the proposed text:
  ```
  Use when running adversarial audits of specs, plans, or code. Dispatch to spec-audit, plan-fidelity, concern-separation, coherence-extraction, coherence-maintenance, guideline-audit, drift-detection, spec-summary, closure-verification, test-quality-audit, verification-audit, resolve-models, cross-validate, or completion. Audits are not optional — dispatch is MANDATORY.
  ```
  **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 10. **Z3 check — GREEN (**clean-room**).** Verify the description field now matches the proposed text exactly. **→ SC-4**
- [ ] 11. **Post-GREEN enforcement (**clean-room**).** Verify no other fields in the YAML frontmatter were modified. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 12. **Z3 check — post-GREEN (**clean-room**).** Confirm post-GREEN enforcement passed. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 13. **Checkpoint tag create (**inline**).** Create checkpoint tag: `opencode-config/checkpoint/1456/phase-1-opencode`. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 14. **Checkpoint commit (**inline**).** Commit the description change with message: `fix(adversarial-audit): update description to list all 14 dispatch targets (#1456)`. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 15. **Structural checks (**clean-room**).** Run `uvx pymarkdownlnt scan -r .opencode/skills/adversarial-audit/SKILL.md` and `uvx mdformat --check .opencode/skills/adversarial-audit/SKILL.md`. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 16. **GREEN doublecheck (**clean-room**).** Re-read the description field. Confirm it matches the proposed text exactly. Verify all 14 dispatch targets are present. Verify mandatory language is retained. Verify narrative-only sentence is absent. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 17. **GREEN VbC (**clean-room**).** Run the RED test from step 3 — it must now PASS (description matches proposed text). **→ SC-4**

#### Phase 1 VbC

- [ ] 18. **VbC (**clean-room**).** Verify all 4 SCs:
  - SC-1: grep for all 14 dispatch targets in the description field
  - SC-2: grep for "Audits are not optional" in the description field
  - SC-3: grep confirms "Every unverified deliverable is a defect" is absent
  - SC-4: exact string match against proposed text
  **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Single phase — no transition needed.

- [ ] 19. **Collect behavioral evidence (**inline**).** Copy artifacts from `./tmp/behavioral-evidence-SC-1456/` into `./tmp/1456/artifacts/`. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 20. **Adversarial audit (**sub-agent**).** Dispatch adversarial-audit with spec-audit task. Verify the description change meets all 4 SCs. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 21. **Cross-validate (**sub-agent**).** Dispatch cross-validate to verify evidence type compliance (string evidence for string SCs). **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 22. **Regression check (**clean-room**).** Verify no other files were modified. Run `git diff --stat` to confirm only `.opencode/skills/adversarial-audit/SKILL.md` changed. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 23. **Review prep (**sub-agent**).** Dispatch review-prep: squash to single commit, push, generate compare URL. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 24. **Executive summary (**inline**).** Report: Phase 1 complete — description updated with all 14 dispatch targets. PR ready. **→ SC-1, SC-2, SC-3, SC-4**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Exit Criteria

- C1: Description field updated to list all 14 dispatch targets
- C2: Mandatory language ("Audits are not optional") retained
- C3: Narrative-only sentence ("Every unverified deliverable is a defect") removed
- C4: Description matches proposed text exactly
- C5: Only `.opencode/skills/adversarial-audit/SKILL.md` modified — no other files changed
- C6: All 4 SCs verified PASS
- C7: Adversarial audit and cross-validate completed
- C8: Review-prep completed — PR ready
