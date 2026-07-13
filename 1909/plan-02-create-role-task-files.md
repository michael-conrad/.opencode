# Phase 02 — Create Role-Specific Task Files

**Concern:** Create 36 new role-specific task files (9 audit types × 4 DiMo roles)

**Files:**
- `.opencode/skills/audit/tasks/*-generator.md` — 9 new files
- `.opencode/skills/audit/tasks/*-knowledge-supporter.md` — 9 new files
- `.opencode/skills/audit/tasks/*-evaluator.md` — 9 files (rename existing or create new, strip Step 0a)
- `.opencode/skills/audit/tasks/*-path-provider.md` — 9 new files

**SCs:** SC-3, SC-4, SC-5, SC-6

**Dependencies:** Phase 1 (SKILL.md restructured)

**Entry conditions:** Phase 1 complete, SKILL.md dispatches to DiMo chain

**Exit conditions:** 36 role-specific task files exist, Evaluator files contain no Knowledge Supporter work

## Code Path Coverage

- `audit/tasks/spec-audit-{generator,knowledge-supporter,evaluator,path-provider}.md` — new
- `audit/tasks/verification-audit-{generator,knowledge-supporter,evaluator,path-provider}.md` — new
- `audit/tasks/plan-fidelity-{generator,knowledge-supporter,evaluator,path-provider}.md` — new
- `audit/tasks/concern-separation-{generator,knowledge-supporter,evaluator,path-provider}.md` — new
- `audit/tasks/coherence-maintenance-{generator,knowledge-supporter,evaluator,path-provider}.md` — new
- `audit/tasks/guideline-audit-{generator,knowledge-supporter,evaluator,path-provider}.md` — new
- `audit/tasks/drift-detection-{generator,knowledge-supporter,evaluator,path-provider}.md` — new
- `audit/tasks/content-audit-{generator,knowledge-supporter,evaluator,path-provider}.md` — new
- `audit/tasks/test-quality-audit-{generator,knowledge-supporter,evaluator,path-provider}.md` — new

## Cross-Cutting SCs

- DiMo 4-role chain dispatch (all phases)
- Clean-room sub-agent separation (Phases 2 and 4)
- File deletion safety (Phases 2 and 3)

## Interface Boundaries

- `audit/tasks/*-generator.md` — new, internal only
- `audit/tasks/*-knowledge-supporter.md` — new, internal only
- `audit/tasks/*-evaluator.md` — modified, breaking change (Step 0a removed)
- `audit/tasks/*-path-provider.md` — new, internal only

## State Transitions

- No Generator task files → 9 Generator task files exist
- No Knowledge Supporter task files → 9 Knowledge Supporter task files exist
- Evaluator files contain Knowledge Supporter work → Evaluator files are pure Evaluator
- No Path Provider task files → 9 Path Provider task files exist

## Steps

### Generator Task Files (9 files)

- [ ] 13. **Create spec-audit-generator.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/spec-audit-generator.md. This is the Generator role for spec-audit in the DiMo 4-role chain. It must: 1) Read the spec from the provided spec_local_dir, 2) Collect raw evidence about spec structure, determinism, and live documentation sources, 3) Write evidence.yaml to the artifact directory. Use the DiMo Generator role procedure: collect raw evidence, no analysis, no judgment. Return the artifact path.")` **→ SC-3**

- [ ] 14. **Create verification-audit-generator.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/verification-audit-generator.md. Generator role for verification-audit. Reads artifact_evidence_dir, collects raw evidence about implemented code against spec SCs, writes evidence.yaml.")` **→ SC-3**

- [ ] 15. **Create plan-fidelity-generator.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/plan-fidelity-generator.md. Generator role for plan-fidelity. Reads plan_local_dir, collects raw evidence about plan-spec alignment, writes evidence.yaml.")` **→ SC-3**

- [ ] 16. **Create concern-separation-generator.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/concern-separation-generator.md. Generator role for concern-separation. Reads issue context, collects raw evidence about concern boundaries and scope isolation, writes evidence.yaml.")` **→ SC-3**

- [ ] 17. **Create coherence-maintenance-generator.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/coherence-maintenance-generator.md. Generator role for coherence-maintenance. Reads issue context, collects raw evidence about codebase coherence after changes, writes evidence.yaml.")` **→ SC-3**

- [ ] 18. **Create guideline-audit-generator.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/guideline-audit-generator.md. Generator role for guideline-audit. Reads guideline_paths, collects raw evidence about guideline content and enforcement, writes evidence.yaml.")` **→ SC-3**

- [ ] 19. **Create drift-detection-generator.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/drift-detection-generator.md. Generator role for drift-detection. Reads issue context, collects raw evidence about documentation-code drift, writes evidence.yaml.")` **→ SC-3**

- [ ] 20. **Create content-audit-generator.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/content-audit-generator.md. Generator role for content-audit. Reads document_section and source_data_paths, collects raw evidence about factual claims, writes evidence.yaml.")` **→ SC-3**

- [ ] 21. **Create test-quality-audit-generator.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/test-quality-audit-generator.md. Generator role for test-quality-audit. Reads issue context, collects raw evidence about test coverage and quality, writes evidence.yaml.")` **→ SC-3**

- [ ] 22. **Verify Generator files (**inline**).** `ls .opencode/skills/audit/tasks/*-generator.md | wc -l` — must return 9. **→ SC-3**

### Knowledge Supporter Task Files (9 files)

- [ ] 23. **Create spec-audit-knowledge-supporter.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/spec-audit-knowledge-supporter.md. Knowledge Supporter role for spec-audit. Reads evidence.yaml from artifact directory, validates evidence, writes reasoning.yaml.")` **→ SC-4**

- [ ] 24. **Create verification-audit-knowledge-supporter.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/verification-audit-knowledge-supporter.md. Knowledge Supporter role for verification-audit.")` **→ SC-4**

- [ ] 25. **Create plan-fidelity-knowledge-supporter.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/plan-fidelity-knowledge-supporter.md. Knowledge Supporter role for plan-fidelity.")` **→ SC-4**

- [ ] 26. **Create concern-separation-knowledge-supporter.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/concern-separation-knowledge-supporter.md. Knowledge Supporter role for concern-separation.")` **→ SC-4**

- [ ] 27. **Create coherence-maintenance-knowledge-supporter.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/coherence-maintenance-knowledge-supporter.md. Knowledge Supporter role for coherence-maintenance.")` **→ SC-4**

- [ ] 28. **Create guideline-audit-knowledge-supporter.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/guideline-audit-knowledge-supporter.md. Knowledge Supporter role for guideline-audit.")` **→ SC-4**

- [ ] 29. **Create drift-detection-knowledge-supporter.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/drift-detection-knowledge-supporter.md. Knowledge Supporter role for drift-detection.")` **→ SC-4**

- [ ] 30. **Create content-audit-knowledge-supporter.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/content-audit-knowledge-supporter.md. Knowledge Supporter role for content-audit.")` **→ SC-4**

- [ ] 31. **Create test-quality-audit-knowledge-supporter.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/test-quality-audit-knowledge-supporter.md. Knowledge Supporter role for test-quality-audit.")` **→ SC-4**

- [ ] 32. **Verify Knowledge Supporter files (**inline**).** `ls .opencode/skills/audit/tasks/*-knowledge-supporter.md | wc -l` — must return 9. **→ SC-4**

### Evaluator Task Files (9 files)

- [ ] 33. **Create spec-audit-evaluator.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/spec-audit-evaluator.md. Evaluator role for spec-audit. Reads evidence.yaml and reasoning.yaml, produces binary PASS/FAIL per criterion, writes verdict.yaml. Must NOT contain any Knowledge Supporter work (no Step 0a, no evidence validation). Pure evaluation only.")` **→ SC-5, SC-6**

- [ ] 34. **Create verification-audit-evaluator.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/verification-audit-evaluator.md. Evaluator role for verification-audit. Pure evaluation, no Knowledge Supporter work.")` **→ SC-5, SC-6**

- [ ] 35. **Create plan-fidelity-evaluator.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/plan-fidelity-evaluator.md. Evaluator role for plan-fidelity. Pure evaluation, no Knowledge Supporter work.")` **→ SC-5, SC-6**

- [ ] 36. **Create concern-separation-evaluator.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/concern-separation-evaluator.md. Evaluator role for concern-separation. Pure evaluation, no Knowledge Supporter work.")` **→ SC-5, SC-6**

- [ ] 37. **Create coherence-maintenance-evaluator.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/coherence-maintenance-evaluator.md. Evaluator role for coherence-maintenance. Pure evaluation, no Knowledge Supporter work.")` **→ SC-5, SC-6**

- [ ] 38. **Create guideline-audit-evaluator.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/guideline-audit-evaluator.md. Evaluator role for guideline-audit. Pure evaluation, no Knowledge Supporter work.")` **→ SC-5, SC-6**

- [ ] 39. **Create drift-detection-evaluator.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/drift-detection-evaluator.md. Evaluator role for drift-detection. Pure evaluation, no Knowledge Supporter work.")` **→ SC-5, SC-6**

- [ ] 40. **Create content-audit-evaluator.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/content-audit-evaluator.md. Evaluator role for content-audit. Pure evaluation, no Knowledge Supporter work.")` **→ SC-5, SC-6**

- [ ] 41. **Create test-quality-audit-evaluator.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/test-quality-audit-evaluator.md. Evaluator role for test-quality-audit. Pure evaluation, no Knowledge Supporter work.")` **→ SC-5, SC-6**

- [ ] 42. **Verify Evaluator files (**inline**).** `ls .opencode/skills/audit/tasks/*-evaluator.md | wc -l` — must return 9. **→ SC-5**

- [ ] 43. **Verify no Knowledge Supporter work in Evaluator files (**inline**).** `grep -rl 'Knowledge Supporter' .opencode/skills/audit/tasks/*-evaluator.md` — must return empty. **→ SC-6**

### Path Provider Task Files (9 files)

- [ ] 44. **Create spec-audit-path-provider.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/spec-audit-path-provider.md. Path Provider (Judger) role for spec-audit. Reads all upstream artifacts (evidence.yaml, reasoning.yaml, verdict.yaml), synthesizes final judgment, writes judgment.yaml with next_step.")` **→ SC-5**

- [ ] 45. **Create verification-audit-path-provider.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/verification-audit-path-provider.md. Path Provider role for verification-audit.")` **→ SC-5**

- [ ] 46. **Create plan-fidelity-path-provider.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/plan-fidelity-path-provider.md. Path Provider role for plan-fidelity.")` **→ SC-5**

- [ ] 47. **Create concern-separation-path-provider.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/concern-separation-path-provider.md. Path Provider role for concern-separation.")` **→ SC-5**

- [ ] 48. **Create coherence-maintenance-path-provider.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/coherence-maintenance-path-provider.md. Path Provider role for coherence-maintenance.")` **→ SC-5**

- [ ] 49. **Create guideline-audit-path-provider.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/guideline-audit-path-provider.md. Path Provider role for guideline-audit.")` **→ SC-5**

- [ ] 50. **Create drift-detection-path-provider.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/drift-detection-path-provider.md. Path Provider role for drift-detection.")` **→ SC-5**

- [ ] 51. **Create content-audit-path-provider.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/content-audit-path-provider.md. Path Provider role for content-audit.")` **→ SC-5**

- [ ] 52. **Create test-quality-audit-path-provider.md (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/audit/tasks/test-quality-audit-path-provider.md. Path Provider role for test-quality-audit.")` **→ SC-5**

- [ ] 53. **Verify Path Provider files (**inline**).** `ls .opencode/skills/audit/tasks/*-path-provider.md | wc -l` — must return 9. **→ SC-5**

- [ ] 54. **Checkpoint commit (**inline**).** `git add .opencode/skills/audit/tasks/*-generator.md .opencode/skills/audit/tasks/*-knowledge-supporter.md .opencode/skills/audit/tasks/*-evaluator.md .opencode/skills/audit/tasks/*-path-provider.md && git commit -m "Phase 2: Create 36 role-specific audit task files for DiMo 4-role chain"` **→ SC-3, SC-4, SC-5, SC-6**

#### Phase 2 VbC

- [ ] 54. **VbC (**clean-room**).** Verify SC-3 (9 Generator files), SC-4 (9 Knowledge Supporter files), SC-5 (9 Path Provider files + 9 Evaluator files), SC-6 (no Knowledge Supporter work in Evaluator files). **→ SC-3, SC-4, SC-5, SC-6**

**Concern transition:** Leaving role-specific task file creation → entering monolithic task file removal. Phase 3 depends on Phase 2 task files existing.
