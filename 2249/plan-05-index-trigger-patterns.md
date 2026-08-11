# Phase 5 — INDEX.md DI trigger patterns

**Concern:** Update the `080-code-standards.md` row in `INDEX.md` to add DI-related trigger patterns (`dependency injection`, `di`, `inject`, `container`), preserving existing trigger patterns.

**Files:**
- `.opencode/guidelines/INDEX.md` (modify — add DI trigger patterns to the `080-code-standards.md` row)

**SCs:** SC-5

**Dependencies:** Phase 4

**Entry Conditions:**
- Phase 4 complete: generic DI section fully documented (principle + table + guidance + exclusion)
- Phase 4 VbC passed

**Exit Conditions:**
- The `080-code-standards.md` row in `INDEX.md` contains the DI trigger patterns
- Existing trigger patterns preserved
- SC-5 structural evidence produced via `grep`

---

### Item 5 — SC-5 (structural): INDEX.md trigger patterns

- [ ] 28. **RED** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Write a failing structural test asserting `.opencode/guidelines/INDEX.md` contains DI-related trigger patterns (`dependency injection`, `di`, `inject`, `container`) in the `080-code-standards.md` row. Fails because the trigger patterns are not yet present.
- [ ] 29. **GREEN** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Make the RED test PASS by appending the DI-related trigger patterns (`dependency injection`, `di`, `inject`, `container`) to the `080-code-standards.md` row in `.opencode/guidelines/INDEX.md`, preserving existing trigger patterns. No scope creep.
- [ ] 30. **post-regression** (**sub-agent**). Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after the GREEN change.
- [ ] 31. **verify** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Verify SC-5: assert the `080-code-standards.md` row in `INDEX.md` contains the DI trigger patterns and existing trigger patterns are preserved. Structural evidence suffices.
- [ ] 32. **commit-inline** (**inline**). Orchestrator runs `git add .opencode/guidelines/INDEX.md <test files> && git commit -m "<message>"`. Test and implementation committed as one atomic slice. No co-author trailer during implementation commits.

#### Phase 5 VbC

- [ ] 33. **VbC verification assertions** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert SC-5 (structural) PASS. Any FAIL halts the phase.

**Concern transition:** Leaving INDEX.md trigger patterns → entering behavioral test artifact generation. Phase 6 depends on Phase 5's routing.
