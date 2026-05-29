# opencode-config

Configuration, guidelines, and skills for OpenCode AI assistant.

## Install as a Git Submodule

```bash
git submodule add git@github.com:michael-conrad/opencode-config.git .opencode
```

## Overview

This repository provides a comprehensive framework for configuring and extending OpenCode with:

- **Guidelines** - Core rules and protocols for AI agent behavior
- **Skills** - Self-contained task-specific workflows
- **Tools** - Utility scripts for session management
- **Tests** - Enforcement test framework

## Features

- **Spec-Driven Development** - All code changes require approved specs
- **Authorization Gates** - Explicit approval required before implementation
- **Pair Mode** - Collaborative development on `pair-*` branches
- **Session Enforcement** - TypeScript plugin validates agent identity and triggers
- **Git Workflow** - Three-branch model: `feature` → `dev` → `main`
- **Verification Gates** - Evidence-based completion verification
- **Fragment Registry** - Synchronized content blocks across skills

## Directory Structure

```
.
├── AGENTS.md              # Main guidelines for AI agents
├── opencode.jsonc         # OpenCode configuration
├── dispatch-table.yaml   # DEPRECATED skill dispatch (historical)
├── guidelines/            # Core rule definitions
├── skills/                # Self-contained skill modules
├── tools/                 # Utility scripts
├── scripts/               # Session context scripts
├── plugins/               # TypeScript plugins
├── hooks/                 # Git hooks
├── tests/                 # Enforcement test suite
├── docs/                  # Documentation
└── .guidelines/           # Fragment registry
```

### Guidelines (`guidelines/`)

Core rules organized by series:

| Series | Category | Files |
|--------|----------|-------|
| 000-099 | Core Rules | critical-rules, approval-gate, go-prohibitions, scope-autonomy, tool-usage, environment, incremental-build |
| 100-199 | Planning | planning-spec-creation, planning-status-tracking, planning-archive-workflow, planning-spec-templates, planning-spec-examples |
| 200-299 | Error Handling | exception-handling, missing-data, logging-vs-raising, domain-exceptions |

### Skills (`skills/`)

Self-contained modules with YAML frontmatter for self-discovery:

| Category | Skills |
|----------|--------|
| Workflow | `approval-gate`, `git-workflow`, `executing-plans`, `writing-plans`, `finishing-a-development-branch` |
| Planning | `brainstorming`, `spec-creation`, `divide-and-conquer` |
| Quality | `spec-auditor`, `guideline-auditor`, `coherence-auditor`, `code-size-enforcement`, `plan-fidelity-auditor` |
| Review | `requesting-code-review`, `receiving-code-review`, `issue-review` |
| Debug | `systematic-debugging`, `conflict-resolution` |
| Development | `test-driven-development`, `programming-principles`, `engineering-approach` |
| Operations | `mcp-tool-usage`, `issue-operations`, `pr-creation-workflow` |
| Maintenance | `skill-creator`, `fragment-manager`, `sync-guidelines`, `changelog-generator` |
| Audit | `verification`, `verification-before-completion`, `verification-enforcement` |
| Other | `correspondence`, `multimodal-dispatch`, `sre-runbook`, `ui-design`, `ui-engineer`, `research` |

### Tools (`tools/`)

| Tool | Purpose |
|------|---------|
| `session-init` | Emit session context (owner, repo, platform). **Canonical source for identity data including Sub-folder Repo Mappings.** |
| `guidelines` | Guideline management |
| `md` | Markdown utilities |
| `py` | Python utilities |
| `jupyter`, `jupyter-start`, `jupyter-stop` | Jupyter notebook management |
| `memory` | Memory/state persistence |
| `help` | Help documentation |

### Plugins (`plugins/`)

| Plugin | Purpose |
|--------|---------|
| `session-enforcement.ts` | Identity validation, trigger injection, hook installation |
| `env-loader.ts` | Environment variable loading |

### Scripts (`scripts/`)

| Script | Purpose |
|--------|---------|
| `session_context_triggers.py` | Trigger warning generation |
| `validate-release-tags.sh` | Release tag validation |
| `validate-submodule-refs.sh` | Submodule reference validation |

## Configuration

### `opencode.jsonc`

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    ".opencode/AGENTS.md",
    ".opencode/guidelines/000-critical-rules.md",
    ".opencode/guidelines/010-approval-gate.md",
    ".opencode/guidelines/020-go-prohibitions.md",
    ".opencode/guidelines/060-tool-usage.md"
  ],
  "mcp": {
    "the-notebook-mcp": { ... },
    "srclight": { ... }
  }
}
```

## Session Context

At session start:

1. **Identity section** - `github.owner`, `github.repo`, `github.platform`, credential status
2. **Identity-echo directive** - Mandatory identity echo
3. **Trigger alerts** - Warnings for special states (main branch, uncommitted work, merge conflicts, etc.)

## Pair Mode

When branch starts with `pair-`, agent operates in collaborative mode:

| Branch Pattern | Mode | Working Directory |
|---|---|---|
| `pair-feature/123-xyz` | Dev-pair | Main project dir |
| `feature/789-xyz` | Autonomous | `.worktrees/` |

## Testing

### Skill Enforcement Tests

```bash
# Run all enforcement tests
bash tests/test-enforcement.sh

# Run by scenario
bash tests/test-enforcement.sh --scenario NAME

# Run by tag
bash tests/test-enforcement.sh --tag TAG

# Run for changed files
bash tests/test-enforcement.sh --changed [--base BRANCH]

# List scenarios
bash tests/test-enforcement.sh --list
```

### Behavioral Tests

Behavioral tests generate model-run artifacts. Run individual scenario scripts:

```bash
bash tests/behaviors/<scenario>.sh
```

### Isolated Testing

```bash
# Run opencode-cli in isolated environment
bash tests/with-test-home opencode-cli run '<message>'

# Clean test artifacts
bash tests/with-test-home --clean
```

## Critical Rules

### Authorization Workflow

1. **Branch Before Edit** - Create feature branch BEFORE any filesystem change
2. **Explicit Authorization** - Wait for "approved" or "go" before implementing
3. **Spec Required** - No implementation without approved spec
4. **HALT After Tasks** - Silently halt after completing a task

### Multi-Task Spec Workflow

When parent issue has sub-issues, authorization cascades to ALL sub-issues:

- User authorizes parent issue
- Verify parent has sub-issues
- Authorization cascades to ALL sub-issues
- Complete ALL phases in sequence (NO HALT between phases)
- Report ONCE after ALL phases complete
- HALT ONCE at the end

### Verification Gates

Before completion claims:

1. `verification-before-completion` - Evidence verification
2. `finishing-a-development-branch` - Branch readiness check
3. `git-workflow review-prep` - Push and prepare for review

## Fragment Registry

Duplicate content blocks synchronized across skills via `.guidelines/registry.yaml`.

Use `fragment-manager` skill for CRUD operations:

```bash
# Create fragment from duplicate content
/skill fragment-manager --task create-fragment

# Sync fragment to destinations
/skill fragment-manager --task sync-fragment --fragment-id <id>

# Check for drift
/skill fragment-manager --task check-drift
```

## Submodule Tracking

When this repository is consumed as a submodule (e.g., `.opencode/`), it **must track the `dev` branch** — never detached HEAD and never `main`.

### Why

- `dev` is the active development branch with the latest guidelines, skills, and tools
- `main` is reserved for stable releases and will lag behind ongoing work
- Detached HEAD prevents `git pull` from receiving updates and makes local changes fragile

### Verification

```bash
git submodule status          # Should show branch name, not a bare SHA
cat .gitmodules               # branch = dev
cd .opencode && git branch --show-current  # Must print "dev"
```

### Recovery

If a submodule is detached or tracking `main`:

```bash
cd .opencode
git checkout dev
git pull
cd ..
git add .opencode
git commit -m "chore: fix submodule tracking to dev"
```

## License

MIT

## See Also

- [AGENTS.md](AGENTS.md) - Main guidelines
- [tests/README.md](tests/README.md) - Test documentation
- [.guidelines/README.md](.guidelines/README.md) - Fragment registry docs