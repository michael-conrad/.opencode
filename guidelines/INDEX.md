# Guidelines Index

Progressive disclosure routing index for all guideline files. Contains name + trigger-pattern pairs only.
Full guideline content for Tier 2+ is loaded on-demand by sub-agents. Tier 1 files are loaded upfront via the opencode.jsonc instructions array.

## Index

| Guideline | Tier | Trigger Pattern | Load When |
|-----------|------|-----------------|-----------|
| `000-critical-rules.md` | 1 | critical, zero tolerance, violation, mandate, Tier 1 | Instructions array (all Tier 1 files) |
| `010-approval-gate.md` | 1 | approved, go, authorization, approve, approval-gate, spec-before-code | Implementation authorization |
| `015-pre-spec-inspection.md` | 2 | code inspection, pre-spec, investigate codebase | Pre-spec creation |
| `016-srclight-preference.md` | 2 | srclight, code search, symbol lookup | Code analysis |
| `020-go-prohibitions.md` | 1 | GO, prohibited, forbidden, never do, soliciting, solicitation | Authorization handling |
| `020-go-prohibitions.md §1.6` | 1 | research, research card, card catalogue, cached findings | Research dispatch |
| `045-open-questions.md` | 2 | open questions, unresolved, Q&A, clarify | Spec review |
| `050-scope-autonomy.md` | 2 | scope, autonomy, agent discretion, agent decision | Agent classification |
| `060-tool-usage.md` | 1 | tool, path rule, temp file, command restriction | File operations |
| `065-verification-honesty.md` | 1 | verify, verification, memory, stale, training data, evidence | Any verification claim |
| `067-context-completeness.md` | 1 | comment, context completeness, read all, all comments | Issue/PR review |
| `070-environment.md` | 2 | environment, testing, temp, pytest, uv run | Test execution |
| `075-docs-verification.md` | 1 | documentation, docs, live doc, API doc, verify doc | Documentation claims |
| `080-code-standards.md` | 1 | code standard, attribution, co-authored, byline, enforcement test, behavioral test, hardcoded identity | Code writing |
| `085-project-local-tools.md` | 2 | tool, local tool, isolated, project-local, .tools, .node | Tool installation |
| `086-http-requests.md` | 2 | HTTP, request, header, User-Agent | HTTP client code |
| `087-no-backward-compat.md` | 2 | backward compat, refactor, deprecate, breaking change | Refactoring |
| `090-data-integrity.md` | 1 | data integrity, mutable, mutation, database, production data | Data operations |
| `091-incremental-build.md` | 1 | incremental, decompose, monolithic, item, TDD, RED, GREEN | Implementation planning |
| `100-persistence.md` | 2 | PostgreSQL, SQLAlchemy, persistence, database, ORM, session | Database code |
| `115-branch-naming.md` | 2 | branch naming, branch name, naming convention | Branch creation |
| `116-pair-mode.md` | 2 | pair mode, pair branch, pair-, dev-pair | Pair mode operations |
| `117-session-trigger-behavior.md` | 1 | session trigger, trigger, trigger warning, SESSION_TRIGGER | Session start |
| `130-authority-source.md` | 1 | authority, authoritative, source of truth, code over doc | Documentation drift |
| `140-planning-spec-creation.md` | 2 | planning, spec creation, spec workflow, spec-driven | Spec creation |
| `141-planning-status-tracking.md` | 2 | status tracking, STATUS, marker, revision, label state | Status updates |
| `142-planning-archive-workflow.md` | 2 | archive, spec structure, spec format, requirements | Spec structure |
| `143-planning-spec-templates.md` | 2 | template, spec template, template format | Spec templating |
| `144-planning-spec-examples.md` | 2 | example, spec example, example structure | Spec examples |
| `200-errors.md` | 2 | exception, error handling, missing data, null, logging, raise, domain exception | Error handling |
| `210-scripting.md` | 2 | script, scripting, script header, shebang | Script creation |
| `250-dark-prose-reference.md` | 2 | dark prose, prose pattern, confirmshaming, goal hijacking, agency-respecting, identity frame, dark pattern | Dark prose content creation |
| `255-distribution-shifting-reference.md` | 2 | distribution shift, dist-shift, mean response, expert tail, RLHF diversity, contrastive decoding, anti-mean, anti-consensus, external-signal verification, corrupt-success contrast | Distribution shifting content |
| `257-procedural-discipline-reference.md` | 2 | procedural discipline, p-dis, dependency order, re-priming, controlled vocabulary, continue drift, verification signal, positional enforcement, dependency-order gate | Procedural discipline content |
