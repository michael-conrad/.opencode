# Phase 1 — Rule substance

**Concern:** Author the Tier 2 root-repo-only tooling rule in the canonical `.opencode/AGENTS.md` `## Boundaries (Critical)` section, covering root build tool, root project-local tools, submodule toolchain prohibition, framework-agnostic phrasing, no hardcoded commands, and canonical placement.

**Files:**
- `.opencode/AGENTS.md` (`## Boundaries (Critical)` section)
- `.opencode/tests-v2/behaviors/` (behavioral test scenarios for SC-1, SC-2, SC-3)

**SCs:** SC-1, SC-2, SC-3, SC-6, SC-7, SC-8

**Dependencies:** None

**Entry Conditions:**
- Spec #2318 approved
- Feature branch exists (per git-workflow pre-work)
- `.opencode/AGENTS.md` `## Boundaries (Critical)` section currently contains no root-repo-only tooling rule

**Exit Conditions:**
- SC-1, SC-2, SC-3, SC-6, SC-7, SC-8 verified PASS and committed
- Rule text authored in canonical `.opencode/AGENTS.md` requiring root-repo-only build tooling and project-local tools, prohibiting submodule toolchain invention/alteration, framework-agnostic, command-free

---

### Pre-implementation (one-time, before any phase)

- [ ] 1. **Coherence gate (**clean-room**).** Verify the plan faithfully derives from the approved spec #2318: every SC-1..SC-9 maps to exactly one plan item, evidence types are preserved (SC-1..SC-5 behavioral, SC-6/SC-7 structural, SC-8/SC-9 string), and the phase DAG (phase 1 → phase 2, phase 1 → phase 3) is acyclic and matches the structure artifact. **→ coherence**
- [ ] 2. **Baseline check (**clean-room**).** Confirm the feature branch is at trunk-tip, submodules are clean, and `.opencode/AGENTS.md` `## Boundaries (Critical)` currently contains no root-repo-only tooling rule and no submodule toolchain prohibition. Record baseline state as the pre-change truth. **→ baseline**

### Item 1 (SC-1): Root build tool only

- [ ] 3. **Pre-clean (**inline**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-2318}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-1**
- [ ] 4. **RED (**sub-agent**).** Write a failing behavioral enforcement test asserting via `session.yaml` clean-room sub-agent inspection the absence of submodule-local build-tool usage and the presence of exclusive root build-tool selection in recorded agent actions (the test fails because the rule is absent). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-1**
- [ ] 5. **GREEN (**sub-agent**).** Author the rule in `.opencode/AGENTS.md` requiring root-repo-only build tooling in multi-module checkouts. No scope creep. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-1**
- [ ] 6. **Post-regression (**sub-agent**).** Run regression test patterns to confirm the rule change introduces no regression. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-1**
- [ ] 7. **Verify (**clean-room**).** Verify SC-1 against the deliverable: the behavioral test passes via `session.yaml` clean-room sub-agent inspection, asserting root build-tool selection. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-1**
- [ ] 8. **Commit (**inline**).** Commit the rule text and behavioral test scenario together as one atomic slice. `git add .opencode/AGENTS.md .opencode/tests-v2/behaviors/ && git commit -m "<root build tool rule + test>"`. **→ SC-1**

### Item 2 (SC-2): Root project-local tools only

- [ ] 9. **Pre-clean (**inline**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-2318}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-2**
- [ ] 10. **RED (**sub-agent**).** Write a failing behavioral enforcement test asserting via `session.yaml` clean-room sub-agent inspection the presence of root project-local-tool selection in recorded agent actions (the test fails because the rule is absent). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-2**
- [ ] 11. **GREEN (**sub-agent**).** Ensure the rule text covers root project-local tools per `085-project-local-tools.md`. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-2**
- [ ] 12. **Post-regression (**sub-agent**).** Run regression test patterns. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-2**
- [ ] 13. **Verify (**clean-room**).** Verify SC-2: the behavioral test passes via `session.yaml` clean-room sub-agent inspection, asserting root project-local-tool selection. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-2**
- [ ] 14. **Commit (**inline**).** Commit the project-local-tools coverage in the rule text and behavioral test scenario as one atomic slice. **→ SC-2**

### Item 3 (SC-3): No submodule toolchain invention/alteration

- [ ] 15. **Pre-clean (**inline**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-2318}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-3**
- [ ] 16. **RED (**sub-agent**).** Write a failing behavioral enforcement test asserting via `session.yaml` clean-room sub-agent inspection the absence of submodule toolchain creation/alteration in recorded agent actions (the test fails because the rule is absent). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-3**
- [ ] 17. **GREEN (**sub-agent**).** Author the rule text prohibiting submodule toolchain invention/alteration. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-3**
- [ ] 18. **Post-regression (**sub-agent**).** Run regression test patterns. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-3**
- [ ] 19. **Verify (**clean-room**).** Verify SC-3: the behavioral test passes via `session.yaml` clean-room sub-agent inspection, asserting absence of submodule toolchain creation/alteration. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-3**
- [ ] 20. **Commit (**inline**).** Commit the prohibition text and behavioral test scenario as one atomic slice. **→ SC-3**

### Item 6 (SC-6): Framework-agnostic phrasing

- [ ] 21. **Pre-clean (**inline**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-2318}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-6**
- [ ] 22. **RED (**sub-agent**).** Write a failing structural check asserting the rule does not yet cover both git submodules AND toolchain-native multi-module arrangements. Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-6**
- [ ] 23. **GREEN (**sub-agent**).** Ensure the authored text uses framework-agnostic phrasing covering both arrangements, with only generic `e.g.` illustration. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-6**
- [ ] 24. **Post-regression (**sub-agent**).** Run regression test patterns. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-6**
- [ ] 25. **Verify (**clean-room**).** Verify SC-6: structural inspection of the authored text confirms framework-agnostic coverage of both git submodules and toolchain-native multi-module arrangements. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-6**
- [ ] 26. **Commit (**inline**).** Commit the framework-agnostic phrasing as one atomic slice. **→ SC-6**

### Item 7 (SC-7): No hardcoded repo-specific commands

- [ ] 27. **Pre-clean (**inline**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-2318}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-7**
- [ ] 28. **RED (**sub-agent**).** Write a failing structural check asserting hardcoded repo-specific build commands are present. Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-7**
- [ ] 29. **GREEN (**sub-agent**).** Keep the rule text free of repo-specific build commands or tool names. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-7**
- [ ] 30. **Post-regression (**sub-agent**).** Run regression test patterns. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-7**
- [ ] 31. **Verify (**clean-room**).** Verify SC-7: structural inspection of the authored text confirms absence of hardcoded repo-specific command names. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-7**
- [ ] 32. **Commit (**inline**).** Commit the command-free wording as one atomic slice. **→ SC-7**

### Item 8 (SC-8): Canonical placement

- [ ] 33. **Pre-clean (**inline**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-2318}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-8**
- [ ] 34. **RED (**sub-agent**).** Write a failing structural check asserting the rule is absent from canonical `.opencode/AGENTS.md`. Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-8**
- [ ] 35. **GREEN (**sub-agent**).** Place the rule in canonical `.opencode/AGENTS.md`. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-8**
- [ ] 36. **Post-regression (**sub-agent**).** Run regression test patterns. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-8**
- [ ] 37. **Verify (**clean-room**).** Verify SC-8: file-location verification that the rule exists in `.opencode/AGENTS.md`. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-8**
- [ ] 38. **Commit (**inline**).** Commit the canonical placement as one atomic slice. **→ SC-8**

#### Phase 1 VbC

- [ ] 39. **VbC (**clean-room**).** Verify all SC-1, SC-2, SC-3, SC-6, SC-7, SC-8 verdicts are clean PASS (SC-1..SC-3 evidence is `behavioral` via `session.yaml` clean-room inspection; SC-6/SC-7 evidence is `structural`; SC-8 evidence is `string`; any `DONE_WITH_CONCERNS` is coerced to FAIL per the implementation-workflow coercion rules). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-1, SC-2, SC-3, SC-6, SC-7, SC-8**

**Concern transition:** Leaving rule substance → entering cross-referencing. Phase 2 depends on the rule text existing in `.opencode/AGENTS.md` from Phase 1.
