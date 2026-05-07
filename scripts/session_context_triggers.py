#!/usr/bin/env -S uv run --script
# /// script
# requires-python = "~=3.12"
# dependencies = []
# ///
"""Trigger section emitter for AI agent session context.

Purged per spec #426: all branch-status-based triggers that caused
AI agent malfunctions have been removed. Only pair_mode_resume
and nested_opencode_fatal remain.

Exit codes:
    0: Success
    1: No git root directory resolution failure
"""

import re
import subprocess
import sys
from pathlib import Path

GIT_TIMEOUT = 10


def run_git(args: list[str]) -> str | None:
    try:
        result = subprocess.run(
            ["git"] + args,
            capture_output=True,
            text=True,
            check=False,
            stdin=subprocess.DEVNULL,
            timeout=GIT_TIMEOUT,
        )
        if result.returncode == 0:
            return result.stdout.strip()
    except subprocess.TimeoutExpired:
        print(f"git {' '.join(args)} timed out after {GIT_TIMEOUT}s", file=sys.stderr)
    except (subprocess.SubprocessError, OSError):
        pass
    return None


def get_current_branch() -> str | None:
    return run_git(["branch", "--show-current"])


def get_root_dir() -> str:
    _path = Path(__file__).resolve().parent
    while _path.name != ".opencode":
        _path = _path.parent
    return str(_path.parent)


def is_pair_mode_branch() -> tuple[bool, str | None]:
    branch = get_current_branch()
    if branch and branch.startswith("pair-"):
        return True, branch
    return False, None


def build_pair_mode_resume(branch: str) -> str:
    issue_match = re.search(r"/(\d+)[-/]", branch)
    issue_hint = f"\n- Related issue: #{issue_match.group(1)}" if issue_match else ""

    diff_stat = run_git(["diff", "--stat", "origin/dev..HEAD"])
    summary = ""
    if diff_stat:
        lines = diff_stat.strip().splitlines()
        if lines:
            summary = f"\n- Changes: {lines[-1].strip()}"

    return "\n".join(
        [
            "## Pair Mode Resumed",
            f"- Branch: `{branch}`",
            f"- Resuming pair-mode collaboration{issue_hint}{summary}",
        ]
    )


NESTED_OPENCODE_DIR = ".opencode/.opencode"


def has_nested_opencode() -> bool:
    root_dir = get_root_dir()
    nested_path = Path(root_dir) / NESTED_OPENCODE_DIR
    return nested_path.is_dir()


def build_nested_opencode_warning() -> str:
    return (
        "\n"
        "### NESTED_OPENCODE_FATAL\n\n"
        "FATAL ERROR: AI agent configuration is broken. "
        "A `.opencode/.opencode/` directory exists at the project root. "
        "This nested folder breaks skill discovery — the AI agent's skill scanner "
        "picks up the inner `.opencode/skills/` path (which is empty or incomplete) "
        "instead of the top-level `.opencode/skills/` directory.\n\n"
        "**Impact:** Top-level skills (approval-gate, divide-and-conquer, git-workflow, "
        "etc.) are invisible to the agent. Only deeply nested platform sub-skills "
        "(local, github-mcp, gitbucket-api) may appear.\n\n"
        "**Fix Required:** Delete the nested `.opencode/.opencode/` directory immediately. "
        "Then verify `.opencode/.gitignore` contains `.opencode/` to prevent recurrence.\n\n"
        "HALT all operations. Do NOT continue working. Report this to the developer immediately.\n"
    )


def is_local_only_repo() -> bool:
    remote_output = run_git(["remote", "-v"])
    if not remote_output or not remote_output.strip():
        return True
    return False


def main() -> int:
    root_dir = get_root_dir()

    sections: list[str] = []

    is_pair, pair_branch = is_pair_mode_branch()
    if is_pair and pair_branch:
        sections.append(build_pair_mode_resume(pair_branch))

    if has_nested_opencode():
        sections.append(build_nested_opencode_warning())

    if len(sections) > 0:
        print("\n\n".join(sections))

    return 0


if __name__ == "__main__":
    sys.exit(main())