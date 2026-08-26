# Phase 2 — Cross-referencing

**Concern:** Add Read-Link cross-references from the rule to `060-tool-usage.md` and `085-project-local-tools.md` using the Read-Link Cross-Reference Rule (`Read [Text](path)`).

**Files:**
- `.opencode/AGENTS.md` (rule cross-references)

**SCs:** SC-9

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: the root-repo-only tooling rule exists in `.opencode/AGENTS.md`
- Phase 1 VbC passed (SC-1, SC-2, SC-3, SC-6, SC-7, SC-8 PASS)

**Exit Conditions:**
- SC-9 verified PASS and committed
- Every cross-reference from the rule to other guidance uses the Read-Link Cross-Reference Rule (`Read [Text](path)`)

---

### Item 9 (SC-9): Read-Link cross-references

- [ ] 40. **Pre-clean (**inline**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-2318}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-9**
- [ ] 41. **RED (**sub-agent**).** Write a failing structural check asserting the rule's cross-references lack `Read [Text](path)` format. Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-9**
- [ ] 42. **GREEN (**sub-agent**).** Add Read-Link cross-references from the rule to `060-tool-usage.md` and `085-project-local-tools.md` using the `Read [Text](path)` pattern. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-9**
- [ ] 43. **Post-regression (**sub-agent**).** Run regression test patterns. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-9**
- [ ] 44. **Verify (**clean-room**).** Verify SC-9: cross-reference-format verification that every cross-reference from the rule uses the `Read [Text](path)` pattern. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-9**
- [ ] 45. **Commit (**inline**).** Commit the Read-Link references as one atomic slice. `git add .opencode/AGENTS.md && git commit -m "<Read-Link cross-references>"`. **→ SC-9**

#### Phase 2 VbC

- [ ] 46. **VbC (**clean-room**).** Verify SC-9 verdict is clean PASS (evidence is `string`; any `DONE_WITH_CONCERNS` is coerced to FAIL per the implementation-workflow coercion rules). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-9**

**Concern transition:** Leaving cross-referencing → entering behavioral enforcement test. Phase 3 depends on the rule text existing in `.opencode/AGENTS.md` from Phase 1.
