# Phase 1 — Configuration and registration work

**Concern:** Register RAGSync as a default MCP service and configure it with local embeddings, per-source isolation, auto-sync, a bounded corpus scope, and a per-source isolation review checklist.

**Files:**
- `.opencode/opencode.jsonc` (mcp block)
- `.opencode/` RAG-Sync config file (new)
- `.opencode/` review checklist (new)

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-7

**Dependencies:** None

**Entry Conditions:**
- Spec #2315 approved
- Feature branch exists (per git-workflow pre-work)
- RAGSync adopted as-is per CON-1; corpus stays non-tracked per CON-2
- Corpus scope bounded per CON-8 (main repo + registered submodule list; non-registered git sub-repos excluded absent a declared carveout)

**Exit Conditions:**
- SC-1..SC-5, SC-7 verified PASS and committed
- RAGSync registered, configured with local embeddings, per-source isolation, auto-sync, and bounded corpus scope
- Review checklist enforcing per-source isolation exists

---

### Pre-implementation (one-time, before any phase)

- [ ] 1. **Coherence gate (**clean-room**).** Verify the plan faithfully derives from the approved spec #2315: every SC-1..SC-7 maps to exactly one plan item, evidence types match the spec (behavioral for SC-1/2/3/5/7, structural for SC-4/6), and the phase DAG (phase 1 → phase 2) is acyclic and matches the structure artifact. **→ coherence**
- [ ] 2. **Baseline check (**clean-room**).** Confirm the feature branch is at trunk-tip, submodules are clean, and `.opencode/opencode.jsonc` currently declares no `ragsync` service and no RAG-Sync config file exists. Record baseline state as the pre-change truth. **→ baseline**

### Item 1 (SC-1): Register RAGSync as a default MCP service

- [ ] 3. **Pre-clean (**inline**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-2315}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-1**
- [ ] 4. **RED (**sub-agent**).** Write a failing check asserting the `ragsync` service entry is absent from the `.opencode/opencode.jsonc` mcp block (the check fails because the entry does not yet exist). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-1**
- [ ] 5. **GREEN (**sub-agent**).** Add the `ragsync` service entry to `.opencode/opencode.jsonc` with `type: local`, `stdio` transport, and `enabled: true`, following the existing `uvx` runner pattern (R-2). No scope creep. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-1**
- [ ] 6. **Post-regression (**sub-agent**).** Run regression test patterns to confirm the registration change introduces no regression. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-1**
- [ ] 7. **Verify (**clean-room**).** Verify SC-1 against the deliverable (behavioral): launch opencode and confirm the `ragsync` service spawns and lists its tools; the `.opencode/opencode.jsonc` mcp block contains the `ragsync` service entry, parses as valid JSONC, and lists the service as enabled. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-1**
- [ ] 8. **Commit (**inline**).** Commit the registration change (test + change together as one atomic slice). `git add .opencode/opencode.jsonc && git commit -m "<registration message>"`. **→ SC-1**

### Item 2 (SC-2)

- [ ] 9. **Pre-clean (**inline**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-2315}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-2**
- [ ] 10. **RED (**sub-agent**).** Write a failing check asserting RAG-Sync is not yet configured with a pinned local fastembed model (no such configuration exists). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-2**
- [ ] 11. **GREEN (**sub-agent**).** Configure RAG-Sync to use fastembed with a pinned default local embedding model and no external embedding API dependency. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-2**
- [ ] 12. **Post-regression (**sub-agent**).** Run regression test patterns. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-2**
- [ ] 13. **Verify (**clean-room**).** Verify SC-2 (behavioral): run a network-monitored retrieval query through the fastembed local path and confirm no external embedding API call is made; the RAG-Sync embedding configuration references fastembed and a pinned default local model. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-2**
- [ ] 14. **Commit (**inline**).** Commit the embedding configuration change as one atomic slice. **→ SC-2**

### Item 3 (SC-3)

- [ ] 15. **Pre-clean (**inline**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-2315}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-3**
- [ ] 16. **RED (**sub-agent**).** Write a failing check asserting no per-source config sections exist (no isolation is declared). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-3**
- [ ] 17. **GREEN (**sub-agent**).** Declare one RAG-Sync config section per reference source corpus with isolated index namespaces. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-3**
- [ ] 18. **Post-regression (**sub-agent**).** Run regression test patterns. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-3**
- [ ] 19. **Verify (**clean-room**).** Verify SC-3 (behavioral): run a cross-source search asserting no retrieval leakage between corpus namespaces; the config declares one section per source with isolated index namespaces. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-3**
- [ ] 20. **Commit (**inline**).** Commit the per-source isolation configuration as one atomic slice. **→ SC-3**

### Item 4 (SC-4)

- [ ] 21. **Pre-clean (**inline**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-2315}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-4**
- [ ] 22. **RED (**sub-agent**).** Write a failing check asserting the per-source isolation review checklist does not yet exist. Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-4**
- [ ] 23. **GREEN (**sub-agent**).** Document a review checklist in the `.opencode` tree that enforces per-source isolation (one config section per source, isolated index namespaces, empty-source handling). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-4**
- [ ] 24. **Post-regression (**sub-agent**).** Run regression test patterns. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-4**
- [ ] 25. **Verify (**clean-room**).** Verify the review checklist exists and covers per-source isolation enforcement. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-4**
- [ ] 26. **Commit (**inline**).** Commit the review checklist as one atomic slice. **→ SC-4**

### Item 5 (SC-5)

- [ ] 27. **Pre-clean (**inline**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-2315}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-5**
- [ ] 28. **RED (**sub-agent**).** Write a failing check asserting auto-sync is not yet enabled for declared sources. Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-5**
- [ ] 29. **GREEN (**sub-agent**).** Enable auto-sync for each declared source in the RAG-Sync config so the index updates on source file changes. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-5**
- [ ] 30. **Post-regression (**sub-agent**).** Run regression test patterns. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-5**
- [ ] 31. **Verify (**clean-room**).** Verify SC-5 (behavioral): modify a source file, observe index freshness without manual re-indexing, and confirm auto-sync is enabled in the RAG-Sync config for each declared source. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-5**
- [ ] 32. **Commit (**inline**).** Commit the auto-sync configuration as one atomic slice. **→ SC-5**

### Item 7 (SC-7): Configure and verify the bounded corpus scope

- [ ] 33. **Pre-clean (**inline**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-2315}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-7**
- [ ] 34. **RED (**sub-agent**).** Write a failing check asserting the RAG-Sync config declares no bounded corpus scope (a naive file walk would silently index non-registered git sub-repos — the `.issues/` orphan-branch worktrees at root and under `.opencode/`). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-7**
- [ ] 35. **GREEN (**sub-agent**).** Configure the RAG-Sync corpus scope to cover all files in the main repo plus every git submodule in the main repo's registered submodule list (per `.gitmodules`), excluding non-registered git sub-repos unless a special carveout is declared in the RAGSync config (CON-8, R-12). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-7**
- [ ] 36. **Post-regression (**sub-agent**).** Run regression test patterns. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-7**
- [ ] 37. **Verify (**clean-room**).** Verify SC-7 (behavioral): enumerate indexed sources at runtime and assert main-repo and registered-submodule coverage with non-registered sub-repos excluded absent a carveout. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-7**
- [ ] 38. **Commit (**inline**).** Commit the corpus-scope configuration as one atomic slice. **→ SC-7**

#### Phase 1 VbC

- [ ] 39. **VbC (**clean-room**).** Verify all SC-1..SC-5 and SC-7 verdicts are clean PASS (SC-4 evidence is `structural`; SC-1/2/3/5/7 evidence is `behavioral`; any `DONE_WITH_CONCERNS` is coerced to FAIL per the implementation-workflow coercion rules). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-7**

**Concern transition:** Leaving configuration and registration work → entering documentation work. Phase 2 depends on the service configuration and registration being in place from Phase 1.