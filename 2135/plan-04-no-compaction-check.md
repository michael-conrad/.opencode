# Phase 4 — No mechanical compaction

**Concern:** Verify the rewritten `130-authority-source.md` uses no word/line-count compaction targets and contains no content-free section headers (SC-12).

**Files:**
- `.opencode/guidelines/130-authority-source.md`

**SCs:** SC-12

**Dependencies:** Phase 3

**Entry Conditions:**
- Phase 3 complete: rewrite and relocation done
- Phase 3 VbC passed

**Exit Conditions:**
- No forbidden compaction phrases present in `130-authority-source.md`
- No content-free section headers present

**Cost frame:** Verifying the absence of mechanical-compaction artifacts costs one absence grep plus one sub-agent read. Skipping permits truncated content and content-free headers — content loss discovered by readers weeks later.

---

- [ ] 56. **RED (**sub-agent**).** Dispatch `execute red task from test-driven-development`. Grep for `removed for length`, `truncated`, `compacted to fit`, `shortened for size`, `abbreviated for space` in the final guideline finds a match, or a clean-room sub-agent finds a content-free section header. **→ SC-12**
- [ ] 57. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Remove the compaction artifact and restore the truncated content; ensure no content-free section headers remain. **→ SC-12**
- [ ] 58. **GREEN doublecheck (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Absence grep for the five forbidden phrases plus clean-room sub-agent content-free-header check per SC-12 verification method. **→ SC-12**
- [ ] 59. **Checkpoint commit (**inline**).** Stage and commit `.opencode/guidelines/130-authority-source.md`.

#### Phase 4 VbC

- [ ] 60. **VbC (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Verify no mechanical compaction artifacts exist per SC-12 verification method. **→ SC-12**

**Concern transition:** Leaving compaction check → entering clean-room semantic audit. Phase 5 depends on Phase 4's compaction check passing.
