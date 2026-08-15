# Phase 3 — Remove Non-Actionable Historical Records and Stale Cross-References

**Concern:** Remove non-actionable historical records and stale cross-references from the rewritten guideline so that every remaining section is actionable for the agent.

**Files:**
- `.opencode/guidelines/117-session-trigger-behavior.md` (rewritten)

**SCs:** SC-6, SC-7, SC-8

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: No-Echo, Trigger Behavior Map, and Suppression Rule sections narrowed
- Phase 2 VbC passed (SC-3, SC-4, SC-5, SC-9)
- The list of files preloaded in agent context is known (opencode.jsonc instructions array, load_when fields in guideline frontmatter) — SC-7 precondition

**Exit Conditions:**
- The guideline contains no non-actionable historical records (SC-6, V-SC-6 all 4 checks PASS)
- The guideline contains no stale cross-references to non-preloaded files (SC-7, V-SC-7 all 3 checks PASS)
- The guideline contains no standalone `000-critical-rules.md` reference (SC-8, V-SC-8 PASS)

---

## Item 6 — SC-6: No non-actionable historical records

- [ ] 33. **RED (**sub-agent**).** Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Run Verification Checklist V-SC-6 against the guideline and expect FAIL (historical records present). **→ SC-6**
- [ ] 34. **GREEN (**sub-agent**).** Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Remove the purged triggers list, the spec #426 reference, the per-turn protected branch edit guard reference, and any other non-actionable content. Ensure every remaining section contains at least one MUST, MUST NOT, or SHOULD instruction. **→ SC-6**
- [ ] 35. **Verify (**clean-room**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Run V-SC-6 — all 4 checks must PASS. **→ SC-6**
- [ ] 36. **Checkpoint commit (**inline**).** Run `git add .opencode/guidelines/117-session-trigger-behavior.md && git commit -m "checkpoint(#2134): item-6 — non-actionable records removed"`. **→ SC-6**

## Item 7 — SC-7: No stale cross-references

- [ ] 37. **RED (**sub-agent**).** Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Run Verification Checklist V-SC-7 against the guideline and expect FAIL (stale cross-references present). **→ SC-7**
- [ ] 38. **GREEN (**sub-agent**).** Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Remove cross-references to `session_context_triggers.py`, `session-enforcement.ts`, and any other non-preloaded file. Ensure any remaining cross-reference targets only files preloaded in agent context. **→ SC-7**
- [ ] 39. **Verify (**clean-room**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Run V-SC-7 — all 3 checks must PASS. **→ SC-7**
- [ ] 40. **Checkpoint commit (**inline**).** Run `git add .opencode/guidelines/117-session-trigger-behavior.md && git commit -m "checkpoint(#2134): item-7 — stale cross-references removed"`. **→ SC-7**

## Item 8 — SC-8: No standalone 000-critical-rules.md reference

- [ ] 41. **RED (**sub-agent**).** Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Run Verification Checklist V-SC-8 against the guideline and expect FAIL (standalone reference present). **→ SC-8**
- [ ] 42. **GREEN (**sub-agent**).** Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Remove the standalone cross-reference to `000-critical-rules.md` (the file is preloaded and does not need explicit mention). **→ SC-8**
- [ ] 43. **Verify (**clean-room**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Run V-SC-8 — the check must PASS. **→ SC-8**
- [ ] 44. **Checkpoint commit (**inline**).** Run `git add .opencode/guidelines/117-session-trigger-behavior.md && git commit -m "checkpoint(#2134): item-8 — standalone reference removed"`. **→ SC-8**

#### Phase 3 VbC

- [ ] 45. **VbC (**clean-room**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Verify the guideline contains no non-actionable historical records, no stale cross-references, and no standalone `000-critical-rules.md` reference. **→ SC-6, SC-7, SC-8**

**Cost frame:** Cost is measured in defect-discovery-latency, not tool calls. Skipping the V-SC-6 clean-room checklist means non-actionable historical records survive undetected in the guideline, confusing agent behavior at runtime. Skipping V-SC-7 means stale cross-references to removed files survive undetected. Skipping V-SC-8 means the standalone `000-critical-rules.md` reference survives undetected.

**Concern transition:** Leaving content removal → entering the verification-only integration gate. Phase 4 depends on Phase 1, Phase 2, and Phase 3 outputs.
