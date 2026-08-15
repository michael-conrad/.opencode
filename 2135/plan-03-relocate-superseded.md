# Phase 3 — Relocate superseded sections

**Concern:** Remove the three superseded sections from `130-authority-source.md` and relocate their content to the target files (spec-creation SKILL.md, 065-verification-honesty.md) without content loss.

**Files:**
- `.opencode/guidelines/130-authority-source.md`
- `.opencode/skills/spec-creation/SKILL.md`
- `.opencode/guidelines/065-verification-honesty.md`

**SCs:** SC-8a, SC-8b, SC-9a, SC-9b, SC-10a, SC-10b

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: all six rules present
- Phase 2 VbC passed
- Target files exist (spec-creation SKILL.md, 065-verification-honesty.md)

**Exit Conditions:**
- The three superseded sections are absent from `130-authority-source.md`
- Their content is present in the target files
- No overlapping duplicate content in target files

**Cost frame:** Verifying each section's absence from the original location and presence in the target costs one clean-room sub-agent read. Skipping leaves duplicate conflicting guidance in two files or loses the relocation silently — a drift or content-loss defect discovered at review.

---

- [ ] 31. **RED (**sub-agent**).** Dispatch `execute red task from test-driven-development`. Clean-room sub-agent reads `130-authority-source.md` and finds the Superseding Issues + Overlap Detection Checklist section still present. **→ SC-8a**
- [ ] 32. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Remove the Superseding Issues + Overlap Detection Checklist section from `130-authority-source.md`. **→ SC-8a**
- [ ] 33. **GREEN doublecheck (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Confirm the section is absent from the original location per SC-8a verification method. **→ SC-8a**
- [ ] 34. **Checkpoint commit (**inline**).** Stage and commit `.opencode/guidelines/130-authority-source.md`.

- [ ] 35. **RED (**sub-agent**).** Dispatch `execute red task from test-driven-development`. Clean-room sub-agent reads `spec-creation/SKILL.md` and finds the Superseding Issues + Overlap Detection Checklist content absent. **→ SC-8b**
- [ ] 36. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Relocate the Superseding Issues + Overlap Detection Checklist content to `spec-creation/SKILL.md`. **→ SC-8b**
- [ ] 37. **GREEN doublecheck (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Verify the content is present in the target location per SC-8b verification method. **→ SC-8b**
- [ ] 38. **Checkpoint commit (**inline**).** Stage and commit `.opencode/skills/spec-creation/SKILL.md`.

- [ ] 39. **RED (**sub-agent**).** Dispatch `execute red task from test-driven-development`. Clean-room sub-agent reads `130-authority-source.md` and finds the Verification First section still present. **→ SC-9a**
- [ ] 40. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Remove the Verification First section from `130-authority-source.md`. **→ SC-9a**
- [ ] 41. **GREEN doublecheck (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Confirm the section is absent from the original location per SC-9a verification method. **→ SC-9a**
- [ ] 42. **Checkpoint commit (**inline**).** Stage and commit `.opencode/guidelines/130-authority-source.md`.

- [ ] 43. **RED (**sub-agent**).** Dispatch `execute red task from test-driven-development`. Clean-room sub-agent reads `065-verification-honesty.md` and finds the Verification First content absent. **→ SC-9b**
- [ ] 44. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Relocate the Verification First content to `065-verification-honesty.md`. **→ SC-9b**
- [ ] 45. **GREEN doublecheck (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Verify the content is present in the target location per SC-9b verification method. **→ SC-9b**
- [ ] 46. **Checkpoint commit (**inline**).** Stage and commit `.opencode/guidelines/065-verification-honesty.md`.

- [ ] 47. **RED (**sub-agent**).** Dispatch `execute red task from test-driven-development`. Clean-room sub-agent reads `130-authority-source.md` and finds the Plan Audit Code Deep Dive section still present. **→ SC-10a**
- [ ] 48. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Remove the Plan Audit Code Deep Dive section from `130-authority-source.md`. **→ SC-10a**
- [ ] 49. **GREEN doublecheck (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Confirm the section is absent from the original location per SC-10a verification method. **→ SC-10a**
- [ ] 50. **Checkpoint commit (**inline**).** Stage and commit `.opencode/guidelines/130-authority-source.md`.

- [ ] 51. **RED (**sub-agent**).** Dispatch `execute red task from test-driven-development`. Clean-room sub-agent reads `spec-creation/SKILL.md` and finds the Plan Audit Code Deep Dive content absent. **→ SC-10b**
- [ ] 52. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Relocate the Plan Audit Code Deep Dive content to `spec-creation/SKILL.md`. **→ SC-10b**
- [ ] 53. **GREEN doublecheck (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Verify the Plan Audit Code Deep Dive content is present per SC-10b verification method. **→ SC-10b**
- [ ] 54. **Checkpoint commit (**inline**).** Stage and commit `.opencode/skills/spec-creation/SKILL.md`.

#### Phase 3 VbC

- [ ] 55. **VbC (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Verify all six SCs (SC-8a, SC-8b, SC-9a, SC-9b, SC-10a, SC-10b) per their verification methods — sections absent from original, content present in targets. **→ SC-8a, SC-8b, SC-9a, SC-9b, SC-10a, SC-10b**

**Concern transition:** Leaving relocation → entering no-mechanical-compaction check. Phase 4 depends on Phase 3's rewrite and relocation being complete.
