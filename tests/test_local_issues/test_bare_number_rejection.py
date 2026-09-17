# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
"""SC-01 (issue 2432, item 1): local-issues read family + create reject bare numbers.

Each read-family command (`read`, `read-comments`, `read-labels`,
`read-sub-issues`) and `create` invoked with a bare issue number
(`--number 2432`, no `#` qualifier) MUST exit non-zero and print a
qualifier listing to stderr. Runs against an isolated sandbox copy of the
tool so no real `.issues/` state is touched.

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
"""

import shutil
import subprocess
from pathlib import Path

import pytest

TOOL_NAME = "local-issues"
BARE_NUMBER = "2432"
PROJECT_ROOT = Path(__file__).resolve().parents[3]  # .../opencode-config
REAL_TOOL = PROJECT_ROOT / ".opencode" / "tools" / TOOL_NAME

READ_FAMILY = ("read", "read-comments", "read-labels", "read-sub-issues")


def _find_project_root() -> Path:
    path = Path(__file__).resolve()
    while path.name != ".opencode":
        if path.parent == path:
            raise RuntimeError("Could not find .opencode/ directory")
        path = path.parent
    return path.parent


PROJECT_ROOT = _find_project_root()
REAL_TOOL = PROJECT_ROOT / ".opencode" / "tools" / TOOL_NAME
TMP_DIR = PROJECT_ROOT / "tmp" / "issue-2432" / "test-sandboxes"


@pytest.fixture
def sandbox() -> Path:
    """Isolated sandbox repo with a copy of local-issues and a fixture issue.

    Sandbox layout mirrors the real repo: <root>/opencode-config/.opencode/
    tools/local-issues plus .opencode/.issues/2432/issue.yaml so reads
    succeed today (exit 0) and the bare-number rejection is the only
    behavior under test.
    """
    base = TMP_DIR / "run-2432"
    if base.exists():
        shutil.rmtree(base)
    root = base / "opencode-config"
    tools_dir = root / ".opencode" / "tools"
    issues_dir = root / ".issues" / BARE_NUMBER
    tools_dir.mkdir(parents=True)
    issues_dir.mkdir(parents=True)
    shutil.copy2(REAL_TOOL, tools_dir / TOOL_NAME)
    (issues_dir / "issue.yaml").write_text(
        "title: fixture\nlabels: []\ncreated: '2026-01-01T00:00:00Z'\n",
        encoding="utf-8",
    )
    subprocess.run(["git", "init", "-q", str(root)], check=True)
    return root


def _run_tool(sandbox: Path, *cli_args: str) -> subprocess.CompletedProcess:
    tool = sandbox / ".opencode" / "tools" / TOOL_NAME
    return subprocess.run(
        ["uv", "run", "--script", str(tool), *cli_args],
        cwd=sandbox,
        capture_output=True,
        text=True,
        timeout=120,
        check=False,
    )


def _assert_bare_number_rejected(
    result: subprocess.CompletedProcess, command: str
) -> None:
    """SC-01: non-zero exit plus stderr qualifier listing."""
    assert result.returncode != 0, (
        f"{command} with bare number --number {BARE_NUMBER} exited 0 "
        f"(bare numbers still accepted); stderr: {result.stderr!r}"
    )
    stderr_lower = result.stderr.lower()
    assert "qualifier" in stderr_lower, (
        f"{command} stderr missing qualifier listing: {result.stderr!r}"
    )


@pytest.mark.parametrize("command", READ_FAMILY)
def test_read_family_rejects_bare_number(sandbox: Path, command: str) -> None:
    # SC-01: read family must reject bare numbers with non-zero exit + qualifier listing
    result = _run_tool(sandbox, command, "--number", BARE_NUMBER)
    _assert_bare_number_rejected(result, command)


def test_create_rejects_bare_number(sandbox: Path) -> None:
    # SC-01: create must reject bare numbers with non-zero exit + qualifier listing
    result = _run_tool(
        sandbox, "create", "--number", BARE_NUMBER, "--title", "sandbox probe"
    )
    _assert_bare_number_rejected(result, "create")
