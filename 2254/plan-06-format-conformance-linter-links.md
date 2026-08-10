# Phase 6 — format conformance + linter + links

**Concern:** Reference-doc format updates (numbered-checkbox Workflows/Procedure), skill-card and task-card numbered-checkbox conformance, split fat task cards, dispatch-contract completeness, extend skildeck linter, verify markdown links, explicit orchestrator workflow steps.

**Files:**
- `.opencode/reference/skill-card-description-standards.md`
- `.opencode/reference/task-card-structure-standards.md`
- `.opencode/skills/spec-creation/SKILL.md`
- `.opencode/skills/audit/SKILL.md`
- `.opencode/skills/spec-creation/tasks/*.md`
- `.opencode/skills/audit/tasks/*.md`
- `.opencode/tools/impl/skildeck/`

**SCs:** SC-23, SC-24, SC-25, SC-26, SC-27, SC-28, SC-29a, SC-29b, SC-29c, SC-31, SC-35, SC-36

**Dependencies:** Phase 1, Phase 2

**Entry Conditions:**
- Phase 1 complete: spec-creation dispatch/task restructure
- Phase 2 complete: audit restructure
- Phase 1 and Phase 2 VbC passed

**Exit Conditions:**
- Both reference docs specify the numbered-checkbox format with execution-mode indicator, clean-room unit mandate, and dispatch-contract completeness requirement
- Both main SKILL.md Workflows sections and all task-card Procedures use numbered-checkbox lists with execution-mode sub-bullets
- No fat task cards; dispatch contracts complete
- skildeck linter enforces all new format rules
- All markdown links resolve to real targets with correct relative paths and `Read [Text](path)` wording
- Workflows explicitly orchestrator step-by-step with explicit inline-vs-dispatch decisions

---

## Code Path Coverage

- Path 1 (spec-creation dispatch surface): `.opencode/skills/spec-creation/SKILL.md` — numbered-checkbox Workflows, explicit orchestrator steps
- Path 2 (spec-creation task cards): `tasks/*.md` — numbered-checkbox Procedures, split fat cards, dispatch-contract completeness
- Path 3 (audit dispatch surface): `.opencode/skills/audit/SKILL.md` — numbered-checkbox Workflows, explicit orchestrator steps
- Path 4 (audit role task cards): `tasks/*.md` — numbered-checkbox Procedures, split fat cards, dispatch-contract completeness
- Path 5 (reference standards and taxonomy): `skill-card-description-standards.md`, `task-card-structure-standards.md` — numbered-checkbox format definitions
- Path 7 (skildeck linter): `.opencode/tools/impl/skildeck/` — new format enforcement rules

## Cross-Cutting SCs

- Numbered-checkbox Workflows format (SC-23, SC-24, SC-31, SC-35) — reference doc defines the format; both SKILL.md conform; linter enforces
- Numbered-checkbox task-card Procedure + clean-room unit (SC-25, SC-26, SC-36) — reference doc defines; all task cards conform; linter enforces
- Dispatch-contract completeness (SC-27) — workflow Context supplies every task-card parameter
- Linter enforcement (SC-28) — enforces all format rules
- Markdown link correctness (SC-29a/29b/29c) — includes issue-operations-core/tasks/creation.md as verified target (SC-37)

## Interface Boundaries

- reference/skill-card-description-standards.md §7 → skill-card authors, linter (⚠️ breaking — format change; cards must conform)
- reference/task-card-structure-standards.md → task-card authors, linter (⚠️ breaking — format change; cards must conform)
- spec-creation/SKILL.md Workflows → orchestrator dispatch (same tasks, numbered-checkbox format)
- audit/SKILL.md Workflows → orchestrator dispatch (same tasks, numbered-checkbox format)
- .opencode/tools/impl/skildeck/ → skill-card/task-card validation (additive checks)

## State Transitions

- task-card format and clean-room unit: CURRENT (plain numbered-list Procedures, some fat task cards) → NUMBERED-CHECKBOX (numbered-checkbox Procedures, no fat task cards, dispatch-contract complete)
- linter enforcement: CURRENT (does not enforce new format rules) → ENFORCING (enforces numbered-checkbox workflow, execution-mode, clean-room, dispatch-contract, markdown links)
- reference format definitions: CURRENT (plain numbered-list) → NUMBERED-CHECKBOX (with execution-mode indicator, clean-room unit mandate, dispatch-contract completeness requirement)

---

## Step-by-step

- [ ] 121. **RED (**sub-agent**).** Write failing enforcement test asserting reference/skill-card-description-standards.md §7 specifies the Workflows section as numbered-checkbox lists (`- [ ] N.`) with sub-bullets for the prompt string, the passed parameters/context, and an execution-mode indicator (inline vs sub-agent dispatch). **→ SC-35**
- [ ] 122. **GREEN (**sub-agent**).** Update reference/skill-card-description-standards.md §7 to specify the Workflows section as numbered-checkbox lists with sub-bullets for the prompt string, the passed parameters/context, and an execution-mode indicator, replacing the current plain numbered-list format. **→ SC-35**
- [ ] 123. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-35**
- [ ] 124. **verify (**clean-room**).** Verify SC-35: grep reference/skill-card-description-standards.md for the numbered-checkbox Workflows specification and execution-mode sub-bullet. **→ SC-35**
- [ ] 125. **commit-inline (**inline**).** Stage and commit reference/skill-card-description-standards.md with the SC-35 test and change together.

- [ ] 126. **RED (**sub-agent**).** Write failing enforcement test asserting reference/task-card-structure-standards.md specifies the task-card Procedure as numbered-checkbox lists and states the clean-room unit mandate and the dispatch-contract completeness requirement. **→ SC-36**
- [ ] 127. **GREEN (**sub-agent**).** Update reference/task-card-structure-standards.md to specify the task-card Procedure as numbered-checkbox lists and state the clean-room unit mandate (task cards are for non-task-capable sub-agents; a procedure requiring internal sub-agent dispatch MUST be split) and the dispatch-contract completeness requirement (the workflow Context must supply every parameter in the task card's Dispatch Contract and Entry Criteria). **→ SC-36**
- [ ] 128. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-36**
- [ ] 129. **verify (**clean-room**).** Verify SC-36: grep reference/task-card-structure-standards.md for the numbered-checkbox Procedure format, the clean-room unit mandate, and the dispatch-contract completeness requirement. **→ SC-36**
- [ ] 130. **commit-inline (**inline**).** Stage and commit reference/task-card-structure-standards.md with the SC-36 test and change together.

- [ ] 131. **RED (**sub-agent**).** Write failing enforcement test asserting spec-creation/SKILL.md Workflows section uses numbered checkbox lists (`- [ ] N.`) with sub-bullets for the prompt string, the passed parameters/context, and an execution-mode indicator. **→ SC-23**
- [ ] 132. **GREEN (**sub-agent**).** Convert the spec-creation Workflows section to numbered checkbox lists with sub-bullets for prompt string, parameters/context, and execution-mode indicator. **→ SC-23**
- [ ] 133. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-23**
- [ ] 134. **verify (**clean-room**).** Verify SC-23: grep spec-creation/SKILL.md for numbered checkbox workflow steps and execution-mode sub-bullets. **→ SC-23**
- [ ] 135. **commit-inline (**inline**).** Stage and commit spec-creation/SKILL.md with the SC-23 test and change together.

- [ ] 136. **RED (**sub-agent**).** Write failing enforcement test asserting audit/SKILL.md Workflows section uses numbered checkbox lists (`- [ ] N.`) with sub-bullets for the prompt string, the passed parameters/context, and an execution-mode indicator. **→ SC-24**
- [ ] 137. **GREEN (**sub-agent**).** Convert the audit Workflows section to numbered checkbox lists with sub-bullets for prompt string, parameters/context, and execution-mode indicator. **→ SC-24**
- [ ] 138. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-24**
- [ ] 139. **verify (**clean-room**).** Verify SC-24: grep audit/SKILL.md for numbered checkbox workflow steps and execution-mode sub-bullets. **→ SC-24**
- [ ] 140. **commit-inline (**inline**).** Stage and commit audit/SKILL.md with the SC-24 test and change together.

- [ ] 141. **RED (**sub-agent**).** Write failing enforcement test asserting every task card Procedure section in spec-creation and audit uses numbered checkbox lists (`- [ ] N.`). **→ SC-25**
- [ ] 142. **GREEN (**sub-agent**).** Convert every task card Procedure section in spec-creation and audit to numbered checkbox lists. **→ SC-25**
- [ ] 143. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-25**
- [ ] 144. **verify (**clean-room**).** Verify SC-25: grep all task cards in spec-creation and audit for numbered checkbox procedure steps. **→ SC-25**
- [ ] 145. **commit-inline (**inline**).** Stage and commit spec-creation/tasks and audit/tasks with the SC-25 test and change together.

- [ ] 146. **RED (**sub-agent**).** Write failing semantic test: clean-room sub-agent reads all task cards in spec-creation and audit and asserts no procedure requires internal sub-agent dispatch. **→ SC-26**
- [ ] 147. **GREEN (**sub-agent**).** Split any task card whose procedure would require internal sub-agent dispatch into multiple task cards; adjust the SKILL.md workflow to dispatch each split task card as a separate step. **→ SC-26**
- [ ] 148. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-26**
- [ ] 149. **verify (**clean-room**).** Verify SC-26: sub-agent reads all task cards in spec-creation and audit and verifies no procedure requires internal dispatch via analytical judgment. **→ SC-26**
- [ ] 150. **commit-inline (**inline**).** Stage and commit spec-creation/tasks, audit/tasks, spec-creation/SKILL.md, and audit/SKILL.md with the SC-26 test and change together.

- [ ] 151. **RED (**sub-agent**).** Write failing semantic test: clean-room sub-agent cross-references each task card's Dispatch Contract/Entry Criteria against the SKILL.md workflow Context sub-bullet and asserts completeness. **→ SC-27**
- [ ] 152. **GREEN (**sub-agent**).** Ensure every workflow Context sub-bullet supplies every parameter in the task card's Dispatch Contract and Entry Criteria. **→ SC-27**
- [ ] 153. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-27**
- [ ] 154. **verify (**clean-room**).** Verify SC-27: sub-agent cross-references each task card's Dispatch Contract/Entry Criteria against the SKILL.md workflow Context sub-bullet via analytical judgment. **→ SC-27**
- [ ] 155. **commit-inline (**inline**).** Stage and commit spec-creation/SKILL.md, audit/SKILL.md, spec-creation/tasks, and audit/tasks with the SC-27 test and change together.

- [ ] 156. **RED (**sub-agent**).** Write failing behavioral test running skildeck lint against a fixture violating each new rule and asserting the linter flags it. **→ SC-28**
- [ ] 157. **GREEN (**sub-agent**).** Extend the skildeck linter to enforce numbered-checkbox workflow format, execution-mode sub-bullet, task-card clean-room unit, dispatch-contract completeness, and markdown link correctness. **→ SC-28**
- [ ] 158. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-28**
- [ ] 159. **verify (**clean-room**).** Verify SC-28: opencode run (with-test-home) runs skildeck lint against a fixture violating each new rule and asserts the linter flags it. **→ SC-28**
- [ ] 160. **commit-inline (**inline**).** Stage and commit .opencode/tools/impl/skildeck/ with the SC-28 test and change together.

- [ ] 161. **RED (**sub-agent**).** Write failing enforcement test asserting all markdown links in the two skills, reference docs, and issue-operations-core/tasks/creation.md resolve to real targets. **→ SC-29a**
- [ ] 162. **GREEN (**sub-agent**).** Fix all markdown links in the two skills, reference docs, and issue-operations-core/tasks/creation.md to resolve to real targets. **→ SC-29a**
- [ ] 163. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-29a**
- [ ] 164. **verify (**clean-room**).** Verify SC-29a: verify all markdown links in the two skills, reference docs, and issue-operations-core/tasks/creation.md resolve to existing files. **→ SC-29a**
- [ ] 165. **commit-inline (**inline**).** Stage and commit spec-creation/SKILL.md, audit/SKILL.md, reference/, and issue-operations-core/tasks/creation.md with the SC-29a test and change together.

- [ ] 166. **RED (**sub-agent**).** Write failing enforcement test asserting all markdown links in the two skills, reference docs, and issue-operations-core/tasks/creation.md use correct relative paths from their containing file. **→ SC-29b**
- [ ] 167. **GREEN (**sub-agent**).** Fix all markdown links to use correct relative paths from their containing file. **→ SC-29b**
- [ ] 168. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-29b**
- [ ] 169. **verify (**clean-room**).** Verify SC-29b: verify all markdown links use correct relative paths from their containing file. **→ SC-29b**
- [ ] 170. **commit-inline (**inline**).** Stage and commit spec-creation/SKILL.md, audit/SKILL.md, reference/, and issue-operations-core/tasks/creation.md with the SC-29b test and change together.

- [ ] 171. **RED (**sub-agent**).** Write failing enforcement test asserting all markdown links in the two skills, reference docs, and issue-operations-core/tasks/creation.md are worded per the `Read [Text](path)` cross-reference pattern. **→ SC-29c**
- [ ] 172. **GREEN (**sub-agent**).** Fix all markdown links to follow the `Read [Text](path)` wording. **→ SC-29c**
- [ ] 173. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-29c**
- [ ] 174. **verify (**clean-room**).** Verify SC-29c: verify all markdown links follow the `Read [Text](path)` wording. **→ SC-29c**
- [ ] 175. **commit-inline (**inline**).** Stage and commit spec-creation/SKILL.md, audit/SKILL.md, reference/, and issue-operations-core/tasks/creation.md with the SC-29c test and change together.

- [ ] 176. **RED (**sub-agent**).** Write failing enforcement test asserting the workflows in spec-creation/SKILL.md and audit/SKILL.md clearly indicate they are for the orchestrator to follow step-by-step, with the execution-mode sub-bullet making the inline-vs-dispatch decision explicit. **→ SC-31**
- [ ] 177. **GREEN (**sub-agent**).** Make the workflows in both SKILL.md files clearly indicate they are for the orchestrator to follow step-by-step, with the execution-mode sub-bullet making the inline-vs-dispatch decision explicit. **→ SC-31**
- [ ] 178. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-31**
- [ ] 179. **verify (**clean-room**).** Verify SC-31: grep the two SKILL.md files for orchestrator-step framing and execution-mode sub-bullets. **→ SC-31**
- [ ] 180. **commit-inline (**inline**).** Stage and commit spec-creation/SKILL.md and audit/SKILL.md with the SC-31 test and change together.

#### Phase 6 VbC

- [ ] 181. **VbC (**clean-room**).** Verify all Phase 6 SCs (SC-23, SC-24, SC-25, SC-26, SC-27, SC-28, SC-29a, SC-29b, SC-29c, SC-31, SC-35, SC-36) pass their verification methods. **→ SC-23, SC-24, SC-25, SC-26, SC-27, SC-28, SC-29a, SC-29b, SC-29c, SC-31, SC-35, SC-36**

**Cost frame:** Verifying each format-conformance, clean-room, dispatch-contract, linter, link, and workflow-clarity fix costs one grep search, one semantic sub-agent read, or one behavioral test run. Skipping means the orchestrator cannot tell whether a workflow step is inline or dispatched, fat task cards remain unexecutable by sub-agents, dispatched sub-agents fabricate missing parameters, format defects recur silently, and dangling links persist — the reference docs keep defining a format the cards and linter cannot conform to or enforce.

**Concern transition:** Leaving format conformance + linter + links → entering functional end-to-end verification. Phase 7 depends on Phase 6's format conformance, linter, and link corrections.

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
