## Summary

The orchestrator dispatches entire skill cards (SKILL.md) to sub-agents via `task()` instead of reading the SKILL.md itself and following its routing instructions. This is a category error: SKILL.md files contain orchestrator-level routing instructions (Trigger Dispatch Tables, DISPATCH_GATE protocols, Invocation sections, Orchestrator Entry Criteria) that sub-agents cannot execute. Sub-agents cannot call `task()`, cannot follow Trigger Dispatch Tables, and cannot satisfy Orchestrator Entry Criteria.

The root cause is not a one-off mistake — it is a **structural conflict in the guidelines themselves**. Three separate directives combine to force the orchestrator into this incorrect behavior, and no directive explicitly authorizes the orchestrator to read SKILL.md routing metadata in its own context.

## Artifact Type Distinction (MANDATORY)

The orchestrator MUST distinguish between two fundamentally different artifact types. This distinction is the core of the fix:

| Artifact | File | Consumer | Content | Action |
|----------|------|----------|---------|--------|
| **Skill Card** | `SKILL.md` | **Orchestrator** | Routing metadata: Trigger Dispatch Table, Invocation section, DISPATCH_GATE protocol, Persona, Sub-Agent Routing, Mandatory Task Discipline | Orchestrator loads via `skill()`, reads routing metadata in own context, does NOT dispatch to sub-agent |
| **Task Card** | `tasks/<name>.md` | **Sub-agent** | Execution procedure: Purpose, Entry Criteria, step-by-step instructions, Exit Criteria, Return contract format | Orchestrator dispatches via `task()` using canonical string from Invocation section; sub-agent reads and executes |

**The skill card tells the orchestrator WHAT to dispatch. The task card tells the sub-agent HOW to execute. Dispatching the skill card to a sub-agent means the sub-agent receives instructions about dispatching — which it cannot do.**

## Root Cause: Structural Conflict in Guidelines

### Directive Chain (the trap)

Three directives in the system prompt and guidelines combine to produce the category error:

| # | Directive | Source | Line | What It Says |
|---|-----------|--------|------|-------------|
| D1 | **Sub-Agent Routing Boundary** | `prompts/default.txt` | 44 | "If you are about to read a file, analyze content, compose prose, or make a decision: dispatch to a sub-agent via `task()`. The orchestrator routes. It does not do." |
| D2 | **Loading a skill ≠ reading it** | `prompts/default.txt` | 181 | "Loading a skill means calling `skill({name: '...'})`, NOT reading the SKILL.md and executing inline." |
| D3 | **Orchestrator NEVER inline work** | `020-go-prohibitions.md` | 212 | "The orchestrator NEVER performs inline work. ALL file reads, file edits, file writes, analysis, verification, and decision-making MUST be delegated to clean-room sub-agents." |

### How the trap fires

1. Orchestrator receives a task → matches a skill → calls `skill({name: "..."})` → SKILL.md content loads into orchestrator context
2. Orchestrator sees the Trigger Dispatch Table, which references task files like `tasks/verify-authorization.md`
3. D1 fires: "If you are about to read a file... dispatch to a sub-agent" → orchestrator interprets "reading the task file" as a file-read that must be dispatched
4. D2 reinforces: "NOT reading the SKILL.md and executing inline" → orchestrator concludes it must NOT read or execute anything from the skill
5. D3 reinforces: "NEVER performs inline work" → orchestrator concludes it must dispatch everything
6. Orchestrator forwards the **entire SKILL.md content** to a sub-agent via `task()` — the sub-agent receives orchestrator-level routing instructions it cannot execute

### The missing carve-out

**No directive anywhere tells the orchestrator:** "After loading a skill via `skill()`, you MUST read its Trigger Dispatch Table and Invocation section in your own context. This is routing metadata consumption, not 'reading a file' or 'inline work.' Only after identifying the canonical dispatch string should you dispatch a task card to a sub-agent."

The DISPATCH_GATE sections inside SKILL.md files do say this — but the orchestrator never reads them because D1/D2/D3 have already told it to dispatch the content before reading it.

### Affected files (the full chain)

| File | Role | What Must Change |
|------|------|------------------|
| `prompts/default.txt` line 44 | **Primary trigger** — Sub-Agent Routing Boundary | Add EXCEPTION with artifact type distinction table |
| `prompts/default.txt` line 181 | **Reinforcing trigger** — "NOT reading the SKILL.md" | Clarify: "NOT reading the SKILL.md and executing inline" means don't inline-execute the task steps — it does NOT mean don't read the routing table |
| `020-go-prohibitions.md` line 212 | **Reinforcing trigger** — "NEVER performs inline work" | Add exception: reading SKILL.md routing metadata is NOT inline work. Inline the artifact type distinction table. |
| `000-critical-rules.md` | Enforcement | Add critical-rules-XXX: "Dispatching SKILL.md to sub-agents — category error". Inline the artifact type distinction table. |
| `dispatch-gate-protocol.md` (or equivalent per #1199) | Protocol | Add SKILL.md Consumption Rule. Inline the artifact type distinction table. |
| All 37+ SKILL.md files | Protocol | Add orchestrator-reads-routing-metadata as first checklist item. Inline the artifact type distinction table. |
| `AGENTS.md` | **Defective cross-reference directive** | Replace the Cross-Reference Load Directive with a mandatory Read-Link Cross-Reference Rule |

## The Correct Pattern

```
1. Orchestrator: skill({name: "approval-gate"})
   → SKILL.md content loads into orchestrator context
2. Orchestrator: reads Trigger Dispatch Table in own context
   → Identifies correct task: "verify-authorization"
3. Orchestrator: reads Invocation section in own context
   → Gets canonical dispatch string: "execute verify-authorization from approval-gate. Read `approval-gate/tasks/verify-authorization.md` first"
4. Orchestrator: task(subagent_type="general", prompt: "execute verify-authorization from approval-gate. Read `approval-gate/tasks/verify-authorization.md` first")
   → Dispatches TASK CARD to sub-agent, NOT the skill card
5. Sub-agent: receives prompt → reads approval-gate/tasks/verify-authorization.md → executes procedure → returns result contract
```

## Fix

### Phase 1: Fix `prompts/default.txt` — Add EXCEPTION to Sub-Agent Routing Boundary

**Current** (line 44):
```
If you are about to read a file, analyze content, compose prose, or make a decision: dispatch to a sub-agent via `task()`. The orchestrator routes. It does not do.
```

**Replace with**:
```
If you are about to read a file, analyze content, compose prose, or make a decision: dispatch to a sub-agent via `task()`. The orchestrator routes. It does not do.

EXCEPTION — Skill routing metadata: After calling `skill({name: "..."})`,
the orchestrator MUST read the loaded SKILL.md's Trigger Dispatch Table
and Invocation section in its own context. This is NOT "reading a file"
— it is reading routing metadata that the orchestrator needs to dispatch
correctly.

| Artifact | File | Consumer | Content | Action |
|----------|------|----------|---------|--------|
| Skill Card | SKILL.md | Orchestrator | Routing metadata (Trigger Dispatch Table, Invocation, DISPATCH_GATE) | Load via skill(), read in own context, do NOT dispatch |
| Task Card | tasks/<name>.md | Sub-agent | Execution procedure (entry criteria, steps, exit criteria) | Dispatch via task() using canonical string from Invocation |

The skill card tells the orchestrator WHAT to dispatch. The task card tells
the sub-agent HOW to execute. Only the task card goes to a sub-agent.
```

### Phase 2: Fix `prompts/default.txt` — Clarify "NOT reading the SKILL.md"

**Current** (line 181):
```
"Loading a skill" means calling `skill({name: "..."})` (the tool), NOT reading the SKILL.md and executing inline. Pre-reading a skill card and performing its steps manually means you are bypassing your own quality system. Professional agents load skills. Amateurs inline.
```

**Replace with**:
```
"Loading a skill" means calling `skill({name: "..."})` (the tool). The orchestrator then reads the SKILL.md's Trigger Dispatch Table and Invocation section in its own context to determine the correct dispatch. The orchestrator does NOT execute the task steps inline — those go to a sub-agent via `task()`. Pre-reading a skill card's task files and performing their steps manually means you are bypassing your own quality system. Professional agents load skills, read routing metadata, and dispatch task cards. Amateurs inline.
```

### Phase 3: Fix `020-go-prohibitions.md` — Add Exception for Routing Metadata

**Current** (line 212):
```
- **The orchestrator NEVER performs inline work.** ALL file reads, file edits, file writes, analysis, verification, and decision-making MUST be delegated to clean-room sub-agents. The orchestrator ONLY tasks sub-agents via task(), receives result contracts, and routes to the next pipeline step. Zero inline file operations are permitted in the main agent context.
```

**Replace with**:
```
- **The orchestrator NEVER performs inline work.** ALL file reads, file edits, file writes, analysis, verification, and decision-making MUST be delegated to clean-room sub-agents. The orchestrator ONLY tasks sub-agents via task(), receives result contracts, and routes to the next pipeline step. Zero inline file operations are permitted in the main agent context.

EXCEPTION — Skill routing metadata: Reading a loaded SKILL.md's Trigger Dispatch Table and Invocation section in the orchestrator's own context is NOT "inline work" or "reading a file." It is routing metadata consumption — the orchestrator must read these sections to determine which task card to dispatch and what canonical dispatch string to use. The orchestrator dispatches the task card (`tasks/<name>.md`), not the skill card (SKILL.md), to the sub-agent.

| Artifact | File | Consumer | Content | Action |
|----------|------|----------|---------|--------|
| Skill Card | SKILL.md | Orchestrator | Routing metadata (Trigger Dispatch Table, Invocation, DISPATCH_GATE) | Load via skill(), read in own context, do NOT dispatch |
| Task Card | tasks/<name>.md | Sub-agent | Execution procedure (entry criteria, steps, exit criteria) | Dispatch via task() using canonical string from Invocation |
```

### Phase 4: Add Critical Violation to `000-critical-rules.md`

Add a new section:

```
### [critical-rules-XXX] Dispatching SKILL.md to sub-agents — category error

**CRITICAL VIOLATION:** Dispatching SKILL.md content (the skill card) to a sub-agent via `task()` is a category error. The skill card contains orchestrator-level routing instructions (Trigger Dispatch Table, DISPATCH_GATE protocol, Invocation section, Orchestrator Entry Criteria) that a sub-agent cannot execute. Sub-agents cannot call `task()`, cannot follow Trigger Dispatch Tables, and cannot satisfy Orchestrator Entry Criteria.

The skill card (SKILL.md) tells the orchestrator WHAT to dispatch. The task card (tasks/<name>.md) tells the sub-agent HOW to execute. Dispatching the skill card to a sub-agent means the sub-agent receives instructions about dispatching — which it cannot do.

| Artifact | File | Consumer | Content | Action |
|----------|------|----------|---------|--------|
| Skill Card | SKILL.md | Orchestrator | Routing metadata (Trigger Dispatch Table, Invocation, DISPATCH_GATE) | Load via skill(), read in own context, do NOT dispatch |
| Task Card | tasks/<name>.md | Sub-agent | Execution procedure (entry criteria, steps, exit criteria) | Dispatch via task() using canonical string from Invocation |

The correct pattern:
1. Orchestrator calls `skill({name: "..."})` → skill card loads into orchestrator context
2. Orchestrator reads Trigger Dispatch Table and Invocation section in own context
3. Orchestrator dispatches the **task card** (`tasks/<name>.md`) to a sub-agent via `task()`
4. Sub-agent reads the task card, executes the procedure, returns a result contract

#### 🚫 FORBIDDEN
- Forwarding skill card content (Trigger Dispatch Table, DISPATCH_GATE, Invocation, Orchestrator Entry Criteria) to a sub-agent via `task()`
- Treating the `skill()` tool as a "dispatch to sub-agent" mechanism — it loads routing metadata into the orchestrator's context
- Including skill card routing sections in `task()` prompts
- Sending SKILL.md content to a sub-agent and expecting the sub-agent to "follow its instructions" — the instructions say "dispatch to sub-agents via task()" which the sub-agent cannot do

#### ✅ REQUIRED
- Call `skill({name: "..."})` to load the skill card into orchestrator context
- Read the Trigger Dispatch Table and Invocation section in the orchestrator's own context
- Dispatch the **task card** (`tasks/<name>.md`) to a sub-agent via `task()` using the canonical dispatch string
- The sub-agent receives only the task card path and routing context — never the skill card content

#### 4-Way Violation Distinction

| Violation | ID | What Happens |
|-----------|-----|-------------|
| Pre-read skill + inline execute | critical-rules-048 | Agent reads task card `.md` file, executes steps manually without calling `skill()` |
| Orchestrator inline work | critical-rules-034 | Agent performs file modifications or analysis inline without sub-agent task() |
| Tool-recipe dispatch | #329 (spec-fix) | Agent tasks sub-agent with raw API calls instead of task objectives |
| **Skill card dispatched to sub-agent** | **critical-rules-XXX** | **Agent dispatches SKILL.md content (skill card) to sub-agent via task(); sub-agent receives orchestrator-level routing instructions it cannot execute** |
```

### Phase 5: Add SKILL.md Consumption Rule to DISPATCH_GATE Protocol

Add to the DISPATCH_GATE protocol (in `dispatch-gate-protocol.md` per #1199, or in each SKILL.md if not yet extracted):

```
### SKILL.md Consumption Rule — Skill Card vs. Task Card Distinction

The `skill()` tool loads the **skill card** (SKILL.md) into the **calling agent's context**. The calling agent (orchestrator) MUST:

1. Read the Trigger Dispatch Table to identify the correct task
2. Read the Invocation section to get the canonical dispatch string
3. Dispatch the **task card** (`tasks/<name>.md`) to a sub-agent via `task()`
4. NOT dispatch the skill card (SKILL.md) itself to any sub-agent

| Artifact | File | Consumer | Content | Action |
|----------|------|----------|---------|--------|
| Skill Card | SKILL.md | Orchestrator | Routing metadata (Trigger Dispatch Table, Invocation, DISPATCH_GATE) | Load via skill(), read in own context, do NOT dispatch |
| Task Card | tasks/<name>.md | Sub-agent | Execution procedure (entry criteria, steps, exit criteria) | Dispatch via task() using canonical string from Invocation |

The skill card is a routing table for the orchestrator. The task card is an execution procedure for the sub-agent. Dispatching the skill card to a sub-agent is like giving a bus driver a map and telling them to drive to the map itself, rather than to the destination the map describes.
```

### Phase 6: Update All SKILL.md Mandatory Task Discipline Checklist Item 1

In all 37+ SKILL.md files, update checklist item 1 to explicitly include reading the routing metadata:

**Current** (representative):
```
- [ ] 1. Every task and sub-task in this skill is mandatory
```

**Replace with**:
```
- [ ] 1. The orchestrator loads this skill card via `skill({name: "..."})`, then reads the Trigger Dispatch Table and Invocation section in its own context. The orchestrator does NOT dispatch this SKILL.md to a sub-agent — it reads the routing metadata itself, then dispatches the named task card to a sub-agent.

| Artifact | File | Consumer | Content | Action |
|----------|------|----------|---------|--------|
| Skill Card | SKILL.md | Orchestrator | Routing metadata (Trigger Dispatch Table, Invocation, DISPATCH_GATE) | Load via skill(), read in own context, do NOT dispatch |
| Task Card | tasks/<name>.md | Sub-agent | Execution procedure (entry criteria, steps, exit criteria) | Dispatch via task() using canonical string from Invocation |
```

### Phase 7: Fix `AGENTS.md` — Replace Defective Cross-Reference Directive with Read-Link Rule

**Current** (lines 294-300):
```
## Cross-Reference Load Directive — MANDATORY

When a guideline or skill file references another file or skill, the reference is a load directive, not a citation:

1. "See `FILENAME.md` §SECTION" or "See `SKILLNAME` skill" — This is a load directive. The text before "see" is a summary. The complete rule lives at the referenced location. Search your context for the referenced section before acting on the rule. Do not treat the summary as the complete rule.

2. "Read [Text](path)" — This is an instruction to call `read` on that path. The referenced content is not pre-loaded in your context. Follow the link to get the complete rule.
```

**Replace with**:
```
## Read-Link Cross-Reference Rule — MANDATORY

When agent-facing text (guidelines, skill cards, task cards, prompts) references content in another file, the agent MUST use the `Read [Text](path)` pattern. This is an instruction to call the `read` tool on that path — the agent reads the referenced content into its context before proceeding.

### 🚫 FORBIDDEN

- "See `FILENAME.md` §SECTION" — Agents treat this as a citation (informational text to be ignored), not an instruction to read. The pattern is defective and MUST NOT appear in new or updated agent-facing text.
- "See `SKILLNAME` skill" — Same defect. The agent does not load the skill from a "see" reference.
- Any cross-reference that relies on the agent inferring it should read the referenced file.

### ✅ REQUIRED

- `Read [Text](path)` — The agent MUST call the `read` tool on the path and load the referenced content into context. Example: `Read [the DISPATCH_GATE protocol](.opencode/.guidelines/dispatch-gate-protocol.md)`
- When the referenced content is too large to inline (e.g., full task file procedures), use `Read [Text](path)` to direct the agent to load it.
- When a rule, distinction, or definition must be visible at multiple decision points, inline the full content at each location. Do not rely on the agent following a pointer to another file.

### Why This Matters

| Pattern | Agent Behavior | Result |
|---------|---------------|--------|
| "See `file` §section" | Treated as citation, ignored | Agent never reads the referenced content |
| `Read [Text](path)` | Treated as instruction to call `read` tool | Agent loads referenced content into context |

The `Read [Text](path)` pattern is the only cross-reference form that produces reliable agent behavior. All other forms are defective and must not be used.
```

### Phase 8: Behavioral Enforcement Test

Create a behavioral test that:
1. Sends a prompt that triggers the orchestrator to load a skill and dispatch work
2. Verifies the orchestrator reads the Trigger Dispatch Table and Invocation section in its own context (stderr shows skill() call followed by task() dispatch with task card path)
3. Verifies the orchestrator does NOT forward skill card content (Trigger Dispatch Table, DISPATCH_GATE, Invocation, Orchestrator Entry Criteria) to the sub-agent
4. Fails if the sub-agent receives orchestrator-level routing instructions

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `prompts/default.txt` line 44 includes EXCEPTION with artifact type distinction table (Skill Card vs Task Card) | `string` | grep for "| Skill Card | SKILL.md | Orchestrator" in prompts/default.txt |
| SC-2 | `prompts/default.txt` line 181 clarified — "NOT reading the SKILL.md" means don't inline-execute task steps, not don't read routing table | `string` | grep for "reads the SKILL.md's Trigger Dispatch Table" in prompts/default.txt |
| SC-3 | `020-go-prohibitions.md` line 212 includes EXCEPTION for skill routing metadata consumption with inlined artifact type distinction table | `string` | grep for "| Skill Card | SKILL.md | Orchestrator" in 020-go-prohibitions.md |
| SC-4 | `000-critical-rules.md` contains critical-rules-XXX: "Dispatching SKILL.md to sub-agents — category error" with 4-way violation distinction table and inlined artifact type distinction table | `string` | grep for "critical-rules-XXX" in 000-critical-rules.md |
| SC-5 | DISPATCH_GATE protocol includes SKILL.md Consumption Rule with "Skill Card vs. Task Card Distinction" heading and inlined artifact type distinction table | `string` | grep for "Skill Card vs. Task Card Distinction" in dispatch-gate-protocol.md or equivalent |
| SC-6 | All 37+ SKILL.md files have updated checklist item 1: orchestrator reads routing metadata in own context, does not dispatch SKILL.md to sub-agent, with inlined artifact type distinction table | `string` | grep for "reads the Trigger Dispatch Table and Invocation section in its own context" in each SKILL.md |
| SC-7 | `AGENTS.md` Cross-Reference Load Directive replaced with Read-Link Cross-Reference Rule — prohibits "See `file`" patterns, mandates `Read [Text](path)` as the only valid cross-reference form | `string` | grep for "Read-Link Cross-Reference Rule" in AGENTS.md |
| SC-8 | Behavioral test: orchestrator dispatches task card, not skill card content, to sub-agent | `behavioral` | `opencode-cli run` → stderr shows skill() call → task() dispatch with task card path, no SKILL.md content in prompt |
| SC-9 | Behavioral test: sub-agent does NOT receive orchestrator-level routing instructions (Trigger Dispatch Table, DISPATCH_GATE, Invocation, Orchestrator Entry Criteria) | `behavioral` | `opencode-cli run` → stderr of sub-agent shows task card content, not SKILL.md routing sections |

## Implementation Order

| Step | Phase | Files Changed | Dependency |
|------|-------|-------------|------------|
| 1 | Phase 1 | `prompts/default.txt` | None — fixes the primary trigger |
| 2 | Phase 2 | `prompts/default.txt` | None — fixes the reinforcing trigger |
| 3 | Phase 3 | `020-go-prohibitions.md` | None — fixes the reinforcing trigger |
| 4 | Phase 4 | `000-critical-rules.md` | None — adds enforcement |
| 5 | Phase 5 | `dispatch-gate-protocol.md` or 37 SKILL.md files | #1199 (extract protocol) or independent |
| 6 | Phase 6 | 37 SKILL.md files | Phase 5 (protocol rule exists) |
| 7 | Phase 7 | `AGENTS.md` | None — fixes defective cross-reference directive |
| 8 | Phase 8 | `tests/behaviors/` | Phases 1-7 (rules exist to test against) |

Steps 1-4 and 7 are independent and can be done in parallel. Steps 5-6 depend on the protocol rule existing. Step 8 depends on all prior phases.

## Inline-Only Cross-Reference Policy

No "See `file` §section" cross-references are used in this spec. Every file that needs the artifact type distinction inlines the full table. This ensures:

- The agent sees the distinction at every decision point, not a pointer to another location
- No file depends on the agent following a cross-reference directive to understand the rule
- Each file is self-contained for its purpose (system prompt, guideline, protocol, skill card)
- Updates to the table must be applied to all locations — but the tradeoff is acceptable because the table is small and stable

The `AGENTS.md` Cross-Reference Load Directive is replaced with the Read-Link Cross-Reference Rule as the canonical source for future edits. The Read-Link pattern (`Read [Text](path)`) is the only valid cross-reference form because it instructs the agent to call the `read` tool — the agent loads the content rather than ignoring a citation.

## Non-Goals

- This spec does NOT change the `skill()` tool behavior — it changes how the orchestrator uses the loaded content
- This spec does NOT change task card structure — task cards remain self-contained execution procedures for sub-agents
- This spec does NOT change the canonical dispatch string format — it clarifies that the dispatch string targets task cards, not skill cards
- This spec does NOT change the existing DISPATCH_GATE protocol — it adds a new rule to it

## Related Issues

- #516 — Skill Dispatch Mandate (prohibit pre-reading skill cards and inline execution)
- #909 — Orchestrator-Serial Pipeline (14-step dispatch routing table)
- #1199 — Extract DISPATCH_GATE protocol to single reference
- #1406 — Orchestrator dispatch-gate bypass prevention
- #1407 — Routing-only SKILL.md restructure
- #1560 — Restructure spec-creation skill
- #1558 — Restructure writing-plans skill
- #1559 — Restructure implementation-pipeline skill
- #1561 — Remove dead "unless explicitly marked as inline" clause

## References

- opencode docs: https://opencode.ai/docs/skills/ — "Skills are loaded on-demand via the native skill tool — agents see available skills and can load the full content when needed"
- The `skill()` tool loads content into the **calling agent's context** — the orchestrator reads it, the orchestrator routes from it. It is NOT a dispatch mechanism to sub-agents.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
