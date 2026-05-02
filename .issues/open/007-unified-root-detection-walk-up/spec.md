---
number: 7
title: "Unified canonical root detection — walk-up-to-.opencode pattern"
status: "implementing"
labels: [SPEC-FIX, approved]
created: "2026-04-30T14:15:53Z"
updated: "2026-04-30T14:40:00Z"
github_issue: 249
github_plan: 251
sub_issues: [252, 253, 254, 255, 256, 257]
supersedes: [150, 234, 239]
author: "michael-conrad"
authorization: "for_pr"
branch: "feature/249-unified-root-detection-walk-up"
carve_outs:
  - "#318 — Hook root detection: hooks execute from .git/hooks/ outside .opencode/ tree; git rev-parse --show-toplevel permitted for hooks only per 210-scripting.md Hooks Exception"
  - "#317 — Root-guard addition: canonical walk-up pattern updated to include filesystem-root guard preventing infinite loops"
---

## Phase Progress

| Phase | Issue | Status | Started | Completed |
|-------|-------|--------|---------|-----------|
| RED — Guideline + Enforcement Test | #252 | in_progress | 2026-04-30T14:40:00Z | — |
| GREEN — Shell Standard (25 files) | #254 | pending | — | — |
| GREEN — Shell Edge Cases (6 files) | #257 | pending | — | — |
| GREEN — Python Scripts (6 files) | #255 | pending | — | — |
| VERIFY — Enforcement Suite | #253 | pending | — | — |
| REFACTOR — Tracking Update | #256 | pending | — | — |

## Canonical Pattern

**Shell:**
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"
```

**Python:**
```python
from pathlib import Path
_path = Path(__file__).resolve().parent
while _path.name != ".opencode":
    _path = _path.parent
PROJECT_DIR = _path.parent
```

## Prohibited Patterns

- `git rev-parse --show-cdup`
- `git rev-parse --show-toplevel`
- `../..` or deeper relative traversals
- `.parent.parent` (or deeper) chains
- `sys.path.insert / append` for root detection
- Shared/imported root detection functions
- `.git` directory walking for root detection

Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)
