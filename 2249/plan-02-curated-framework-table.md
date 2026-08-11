# Phase 2 — Curated three-tier framework table

**Concern:** Add the curated per-language framework table to the generic DI section, organized into three advisory tiers.

**Files:**
- `.opencode/guidelines/080-code-standards.md` (modify — add framework table within the generic DI section)

**SCs:** SC-2

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: generic DI principle section exists
- Phase 1 VbC passed

**Exit Conditions:**
- The curated three-tier framework table exists within the generic DI section
- The table is explicitly advisory and organized into Clear standard / Contested / Non-idiomatic and guidance-only tiers
- SC-2 behavioral evidence produced via `opencode run` + clean-room `session.yaml` evaluation

---

### Item 2 — SC-2 (behavioral): curated three-tier framework table

- [ ] 10. **RED** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Write a behavioral enforcement test that FAILS because the curated framework table does not yet exist. The test sends a real-domain prompt via `opencode run` and asserts, via `session.yaml`, that an agent writing code in a given language applies no tiered per-language guidance (defect present). RED must fail before GREEN begins.
- [ ] 11. **GREEN** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Make the RED test PASS by adding the curated per-language framework table to the generic DI section in `.opencode/guidelines/080-code-standards.md`. The table is explicitly advisory and organized into three tiers: (1) Clear standard — Python (`dependency-injector`), C#/.NET (built-in `Microsoft.Extensions.DependencyInjection`), Java (Spring; Dagger for GWT-style), Angular/Vue/Svelte (built-in); (2) Contested — Kotlin (Koin/Hilt), Scala (MacWire/Guice/ZIO), Dart/Flutter (get_it/provider/Riverpod), TypeScript (tsyringe/InversifyJS); (3) Non-idiomatic and guidance-only — Go, Rust, C++, Swift, Ruby, React (Context/hooks), Web Components. No scope creep — only the minimum change needed for SC-2.
- [ ] 12. **post-regression** (**sub-agent**). Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after the GREEN change.
- [ ] 13. **verify** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Verify SC-2 against its success criterion. Behavioral evidence: `opencode run` `session.yaml` shows the agent applying the tiered guidance appropriately for a given language. PASS requires clean behavioral evidence — a non-clean pass (DONE_WITH_CONCERNS) is coerced to FAIL.
- [ ] 14. **commit-inline** (**inline**). Orchestrator runs `git add .opencode/guidelines/080-code-standards.md <test files> && git commit -m "<message>"`. Test and implementation committed as one atomic slice. No co-author trailer during implementation commits.

#### Phase 2 VbC

- [ ] 15. **VbC verification assertions** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert SC-2 (behavioral, clean) PASS. Any FAIL (including EVIDENCE_TYPE_MISMATCH for SC-2's behavioral requirement) halts the phase.

**Concern transition:** Leaving curated framework table → entering selection guidance. Phase 3 depends on Phase 2's framework table.
