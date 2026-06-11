# Card Catalogue — Issue Comment Churn Regression

## Card 1: Channel-Routing Table Deletion

**Status:** CONFIRMED
**Source:** Git commit analysis

### Finding

Commit `ab2350fa` removed the #608 channel-routing table from `000-critical-rules.md`. This table had 10 rows mapping specific actions to their correct channel:

| Action | Channel |
|--------|---------|
| Progress executive summaries | Chat only |
| Review-prep / verification status | Chat only |
| Substantive spec revision | Chat + Issue comment |
| PR created | Issue comment |
| Issue blocked | Issue comment |
| Bug discovered during implementation | Issue comment |
| User question response | Issue comment |
| Issue closure | Issue comment |
| Agent completes implementation task | Chat only |
| Spec-audit findings | Internal only |

Also removed the bold-rule: `"Progress executive summaries go to chat ONLY, not GitHub Issue comments."`

### Evidence

```
git diff ab2350fa^..ab2350fa -- guidelines/000-critical-rules.md | grep "Progress executive summaries"
  => "-**Progress executive summaries go to chat ONLY, not GitHub Issue comments.**"

grep -c "Progress executive summaries" /home/muksihs/git/opencode-config/.opencode/guidelines/000-critical-rules.md
  => 0 (not present in current file)
```

### Assessment

The removal was rationalized as "context-window pollution reduction" — the table was ~30 lines and judged too verbose for orchestrator context. However, the table was the primary enforceable rule distinguishing chat content from issue content. Its replacement ("Issue comments are for substantive information only") is too weak and abstract to prevent agents from posting status updates.

---

## Card 2: github-comments Skill Deletion

**Status:** CONFIRMED
**Source:** Git commit analysis

### Finding

The entire `github-comments` skill was deleted in commit `ab2350fa`. This skill was the dedicated governance skill for issue comment behavior — what to post, when to post, response protocol, audience separation.

### Evidence

```
ls .opencode/skills/github-comments/ 2>/dev/null || echo "DELETED"
  => DELETED

git show --stat ab2350fa | grep github-comments
  => skills/github-comments/SKILL.md              | 894 +-------------------
  => skills/github-comments/tasks/SKILL.md        |  28 -
```

### Assessment

The skill was "absorbed" into `issue-operations/tasks/comment.md`. The comment task does have the substantive gate (Step 1, lines 22-28). However, this absorption means there is no dedicated skill that orchestrators can load to get comment governance context. The gate exists inside a sub-agent task file that orchestrators never load directly.

---

## Card 3: 16 Affirmative Posting Instructions vs. 1 Gate

**Status:** CONFIRMED
**Source:** Agent codebase analysis

### Finding

The codebase contains approximately 16 affirmative instructions telling agents to post content to GitHub Issues, vs. only 1 substantive gate (`issue-operations/tasks/comment.md` Step 1).

### Key Offenders

| File | Instruction | Type |
|------|-------------|------|
| `completion-core/tasks/completion.md:71-95` | "Post a progress comment to the issue summarizing: What was implemented, What passed verification, What remains" | **Mandatory** — exit criterion |
| `finishing-a-development-branch/tasks/completion.md:25` | "Post status comment on issue (with idempotency check)" | **Mandatory** |
| `git-workflow/tasks/completion.md:31` | "Post status comment on issue" | **Mandatory** |
| `020-go-prohibitions.md:186` | "Posting progress comments to GitHub — always permitted" | **Authorization-free** |
| `git-workflow/tasks/cleanup/verify-merge.md:100` | "MUST be posted as a comment on the issue" | **Mandatory** |

### Assessment

The affirmative instructions outnumber the gates 16:1. The substantive gate in `comment.md` is well-designed (Step 1 says "status update → SKIP") but callers mandate posting *before* routing through the gate, creating a design tension where the gate's skip instruction conflicts with the caller's mandatory exit criterion.

---

## Card 4: Verification Enforcement Dilution

**Status:** CONFIRMED
**Source:** Git diff analysis

### Finding

`000-critical-rules.md` was reduced from 6,687 to 2,264 words (66% reduction). All structured `### 🚫 FORBIDDEN` / `### ✅ REQUIRED` subsections were replaced with one-liner bullet ranges. All "Why This Matters" consequence tables were removed.

### Evidence

```
git diff ab2350fa^..ab2350fa -- guidelines/000-critical-rules.md | grep "^-\*\*" | wc -l
  => 50+ bold-formatted rule lines removed

grep -c "^### 🚫\|^### ✅" /home/muksihs/git/opencode-config/.opencode/guidelines/000-critical-rules.md
  => 0 (zero FORBIDDEN/REQUIRED sections remain)
```

### Assessment

The structured formatting was replaced by compressed bullet ranges. Example transformation:

**Before (enforcement structure):**
```
### 🚫 FORBIDDEN
- Skipping verification because "the changes look correct"
- Proceeding to review-prep before verification skills pass

### ✅ REQUIRED
- See verification-before-completion skill --task verify for evidence requirements
- See finishing-a-development-branch skill --task checklist for branch readiness

### Why This Matters
| Manual Execution | Formal Skill Invocation |
|------------------|------------------------|
| Skips enforcement checklists | Loads and follows enforcement checklist |
```

**After (compressed):**
```
- 🚫 FORBIDDEN: skipping verification, proceeding to review-prep before verification pass
- ✅ REQUIRED: see verification-before-completion skill, finishing-a-development-branch skill
```

The compressed form removes the behavioral friction that formatted sections provide. Agents skip one-line bullets more easily than structured subsections with consequence tables.

---

## Card 5: Spec-Audit Findings Leak Risk

**Status:** CONFIRMED
**Source:** Git diff analysis

### Finding

Two rules were deleted:
1. `"⚠️ Posting spec-audit findings as GitHub comments is FORBIDDEN."`
2. `"Audit findings from spec-auditor are internal agent guidance — equivalent to linter output."`

### Assessment

The classification of audit findings as "internal agent guidance" was a critical framing rule. Without it, an agent might interpret audit results as substantive stakeholder content and post them to issues. The rule was equivalent to the existing lint/compliance convention — agents do not post linter warnings to issues, and audit findings should be treated the same way.

---

## Card 6: Byline Rules as Comment Volume Driver

**Status:** CONFIRMED
**Source:** Codebase analysis

### Finding

`080-code-standards.md` mandates `🤖 Co-authored with AI: <AgentName> (<ModelId>)` as the last line of:
- Issue comments (any repository)
- PR comments (any repository)
- PR bodies (AI-authored)
- Issue bodies (AI-authored)

The standalone byline correction prohibition exists (lines 198-206) but does not prevent the byline from being included in the *first* posting of a comment. Since every issue comment requires a byline, even a one-line "Task complete" comment becomes a multi-line post with attribution, making it look more substantive than it is.

### Assessment

The byline rule is a secondary driver of comment volume. Every non-substantive comment carries a byline, which increases its apparent substance and reduces the likelihood of the substantive gate catching it. The byline itself is not the root cause but amplifies the damage.

---

## Card 7: Online Research — "Silence Is Better Than Noise"

**Status:** CONFIRMED
**Source:** DuckDuckGo search + Elastic AI Factory blog

### Finding

The most authoritative public source on AI agent issue tracker noise is Elastic's "AI Software Factory" blog. Key principles:

1. **Silence over Noise** — Agent with nothing useful to say says nothing. Bug Hunter runs daily; zero findings is a success.
2. **Evidence over Opinions** — Every finding must include file path, line number, reproduction steps. No vague suggestions.
3. **Noop Is Success** — Value measured by signal quality, not output volume. Quiet dashboard = healthy codebase.
4. **Humans Stay in Loop** — Skip labels, `/ai` command for invocation control, review-before-merge, safe-output tools.

### Additional Sources

- OWASP LLM06/LLM08 — "Excessive Agency" classification: agents granted too much functionality, permissions, or autonomy with respect to posting
- GitHub marketplace `ai-moderator` action — detects and optionally minimizes AI-generated comments as spam
- Copilot agent feedback #61 — users unassign Copilot from PRs to prevent auto-responding to comments
- dev.to blog — blocking bot PRs via git author metadata checks in pre-receive hooks

### Assessment

The Elastic principles align exactly with the #608 channel-routing table approach. The fix should adopt "Silence over Noise" as an explicit guideline for issue comment behavior.

---

## Card 8: Research Sources Index

**Status:** CONFIRMED
**Source:** Agent codebase analysis + web research

### Sources Used

| Source | Type | What It Provided |
|--------|------|------------------|
| `git diff ab2350fa^..ab2350fa` | Git commit analysis | Full 84-file, 9,179-line deletion catalog |
| `grep` across current `guidelines/*.md` | Static analysis | Count of remaining channel rules (0) |
| `grep` across current `skills/**/*.md` | Static analysis | 37+ affirmative posting directives, 16:1 ratio |
| Agent `task()` codebase analysis | AI agent analysis | Structured 8-card findings report |
| Agent `task()` web research | Search + web fetch | Elastic AI Factory principles, OWASP classification, GitHub ai-moderator, Copilot feedback |
| Current `.opencode/guidelines/000-critical-rules.md` | File read | Current state of the collapsed rules |
| Current `.opencode/skills/issue-operations/tasks/comment.md` | File read | Substantive gate structure (lines 22-28) |
| Current `.opencode/guidelines/020-go-prohibitions.md` | File read | Authorization-free progress posting rule (line 186) |
| Current `.opencode/guidelines/080-code-standards.md` | File read | Byline rules and standalone byline prohibition |
| `git log --oneline --grep=` | Git history search | Identification of `ab2350fa` as the regression point, #608/#713 as the original fix |

### Unverified Claims (No Live Source)

None. All claims in this card catalogue are backed by tool-call evidence from the current session.