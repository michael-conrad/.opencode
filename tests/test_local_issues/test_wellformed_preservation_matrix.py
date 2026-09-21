# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
"""SC-4 (issue 2449, phase 4): well-formed ticket preservation matrix.

Fixture matrix exercises five issue-directory shapes:

- well-formed control (issue.yaml + spec.md, real status)
- artifact-only variant (spec.md only, no issue.yaml)
- comments.yaml-only variant (no issue.yaml, no spec.md)
- links.yaml-only variant (no issue.yaml, no spec.md)
- empty directory variant (no files at all)

Assertions:

- Control keeps its real status in list/search with NO
  `[artifact-only]` marker, and read reports the real status
  (non-regression pin — may already pass from phases 1-3).
- Variants are marked `[artifact-only]` in list/search and read omits
  any status line (the SC-4 gate).
- The empty dir is excluded from list and search output entirely.

Runs against an isolated sandbox copy of the tool so no real
`.issues/` state is touched.

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
"""

import shutil
import subprocess
from pathlib import Path

import pytest

TOOL_NAME = "local-issues"

# SC-4 matrix fixture issue numbers (unique namespace per phase).
CONTROL_NUM = 9968          # well-formed: issue.yaml + spec.md
ARTIFACT_ONLY_NUM = 9969    # spec.md only
COMMENTS_ONLY_NUM = 9967    # comments.yaml only
LINKS_ONLY_NUM = 9966       # links.yaml only
EMPTY_NUM = 9965            # empty directory

CONTROL_STATUS = "in-progress"
STATUS_LINE_PREFIX = "  status:"
SEARCH_MARKER = "matrixmarker"


def _find_project_root() -> Path:
    path = Path(__file__).resolve()
    while path.name != ".opencode":
        if path.parent == path:
            raise RuntimeError("Could not find .opencode/ directory")
        path = path.parent
    return path.parent


PROJECT_ROOT = _find_project_root()
REAL_TOOL = PROJECT_ROOT / ".opencode" / "tools" / TOOL_NAME
TMP_DIR = PROJECT_ROOT / "tmp" / "2449" / "test-sandboxes"


@pytest.fixture
def sandbox() -> Path:
    """Isolated sandbox repo with a copy of local-issues and the matrix.

    Layout mirrors the real repo: <root>/opencode-config/.opencode/tools/
    local-issues plus .issues/{N}/ fixture directories, one per matrix
    shape.
    """
    base = TMP_DIR / "run-sc4"
    if base.exists():
        shutil.rmtree(base)
    root = base / "opencode-config"
    tools_dir = root / ".opencode" / "tools"
    issues_dir = root / ".issues"
    tools_dir.mkdir(parents=True)
    shutil.copy2(REAL_TOOL, tools_dir / TOOL_NAME)

    # Well-formed control: issue.yaml with a real (non-open) status plus
    # spec.md. Must keep its real status everywhere.
    control = issues_dir / str(CONTROL_NUM)
    control.mkdir(parents=True)
    (control / "issue.yaml").write_text(
        "title: well-formed-control-with-matrixmarker-token\n"
        f"status: {CONTROL_STATUS}\n"
        "labels: []\n"
        "created: '2026-01-01T00:00:00Z'\n",
        encoding="utf-8",
    )
    (control / "spec.md").write_text(
        f"Well-formed control body with {SEARCH_MARKER} token.\n",
        encoding="utf-8",
    )

    # Artifact-only variant: spec.md only, no issue.yaml.
    artifact_only = issues_dir / str(ARTIFACT_ONLY_NUM)
    artifact_only.mkdir()
    (artifact_only / "spec.md").write_text(
        f"Artifact-only body with {SEARCH_MARKER} token.\n",
        encoding="utf-8",
    )

    # comments.yaml-only variant: no issue.yaml, no spec.md.
    comments_only = issues_dir / str(COMMENTS_ONLY_NUM)
    comments_only.mkdir()
    (comments_only / "comments.yaml").write_text(
        "comments:\n"
        f"- body: comment body with {SEARCH_MARKER} token\n"
        "  author: tester\n"
        "  created: '2026-01-01T00:00:00Z'\n",
        encoding="utf-8",
    )

    # links.yaml-only variant: no issue.yaml, no spec.md.
    links_only = issues_dir / str(LINKS_ONLY_NUM)
    links_only.mkdir()
    (links_only / "links.yaml").write_text(
        f"links:\n- url: https://example.com/{SEARCH_MARKER}\n",
        encoding="utf-8",
    )

    # Empty-directory variant: no files at all.
    (issues_dir / str(EMPTY_NUM)).mkdir()

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


def _entry_for(stdout: str, display: str) -> str | None:
    return next(
        (line for line in stdout.splitlines() if display in line),
        None,
    )


def _read_status_lines(stdout: str) -> list[str]:
    # read renders yaml-less dirs as inline `issue: {}`, so scan the
    # whole output for status lines rather than a multi-line block.
    return [
        ln for ln in stdout.splitlines() if ln.startswith(STATUS_LINE_PREFIX)
    ]


# --- Control: keeps real status, no [artifact-only] marker ------------


def test_list_control_keeps_real_status_no_marker(sandbox: Path) -> None:
    # SC-4 non-regression pin: control keeps real status, no marker.
    result = _run_tool(sandbox, "list")
    assert result.returncode == 0, (
        f"list crashed (exit {result.returncode}); stderr: {result.stderr!r}"
    )
    entry = _entry_for(result.stdout, f"opencode-config#{CONTROL_NUM}")
    assert entry is not None, (
        f"list output missing control entry: {result.stdout!r}"
    )
    assert f"[{CONTROL_STATUS}]" in entry, (
        f"control lost real status in list: {entry!r}"
    )
    assert "[artifact-only]" not in entry, (
        f"control wrongly marked [artifact-only] in list: {entry!r}"
    )


def test_search_control_keeps_real_status_no_marker(sandbox: Path) -> None:
    result = _run_tool(sandbox, "search", "--query", SEARCH_MARKER)
    assert result.returncode == 0, (
        f"search crashed (exit {result.returncode}); stderr: {result.stderr!r}"
    )
    entry = _entry_for(result.stdout, f"opencode-config#{CONTROL_NUM}")
    assert entry is not None, (
        f"search output missing control entry: {result.stdout!r}"
    )
    assert f"[{CONTROL_STATUS}]" in entry, (
        f"control lost real status in search: {entry!r}"
    )
    assert "[artifact-only]" not in entry, (
        f"control wrongly marked [artifact-only] in search: {entry!r}"
    )


def test_read_control_keeps_real_status(sandbox: Path) -> None:
    result = _run_tool(
        sandbox, "read", "--number", f"opencode-config#{CONTROL_NUM}"
    )
    assert result.returncode == 0, (
        f"read crashed (exit {result.returncode}); stderr: {result.stderr!r}"
    )
    block = result.stdout
    assert f"status: {CONTROL_STATUS}" in block, (
        f"control lost real status in read: {result.stdout!r}"
    )
    assert "status: artifact-only" not in block, (
        f"control read carries artifact-only sentinel: {result.stdout!r}"
    )


# --- Variants: marked [artifact-only] in list/search, read omits status


@pytest.mark.parametrize(
    "num,display",
    [
        (ARTIFACT_ONLY_NUM, "artifact-only"),
        (COMMENTS_ONLY_NUM, "comments.yaml-only"),
        (LINKS_ONLY_NUM, "links.yaml-only"),
    ],
    ids=["artifact-only", "comments-only", "links-only"],
)
def test_list_variant_marked_artifact_only(
    sandbox: Path, num: int, display: str
) -> None:
    # SC-4 gate: yaml-less variant dirs render [artifact-only], never a
    # fabricated [open].
    result = _run_tool(sandbox, "list")
    assert result.returncode == 0, (
        f"list crashed (exit {result.returncode}); stderr: {result.stderr!r}"
    )
    entry = _entry_for(result.stdout, f"opencode-config#{num}")
    assert entry is not None, (
        f"list output missing {display} variant entry: {result.stdout!r}"
    )
    assert "[artifact-only]" in entry, (
        f"SC-4 RED: {display} variant not marked [artifact-only] in list; "
        f"entry: {entry!r}"
    )
    assert "[open]" not in entry, (
        f"SC-4 RED: {display} variant fabricated [open] in list; "
        f"entry: {entry!r}"
    )


@pytest.mark.parametrize(
    "num,marker,display",
    [
        (ARTIFACT_ONLY_NUM, SEARCH_MARKER, "artifact-only"),
        (COMMENTS_ONLY_NUM, SEARCH_MARKER, "comments.yaml-only"),
        (LINKS_ONLY_NUM, SEARCH_MARKER, "links.yaml-only"),
    ],
    ids=["artifact-only", "comments-only", "links-only"],
)
def test_search_variant_marked_artifact_only(
    sandbox: Path, num: int, marker: str, display: str
) -> None:
    result = _run_tool(sandbox, "search", "--query", marker)
    assert result.returncode == 0, (
        f"search crashed (exit {result.returncode}); stderr: {result.stderr!r}"
    )
    entry = _entry_for(result.stdout, f"opencode-config#{num}")
    assert entry is not None, (
        f"search output missing {display} variant entry: {result.stdout!r}"
    )
    assert "[artifact-only]" in entry, (
        f"SC-4 RED: {display} variant not marked [artifact-only] in search; "
        f"entry: {entry!r}"
    )
    assert "[open]" not in entry, (
        f"SC-4 RED: {display} variant fabricated [open] in search; "
        f"entry: {entry!r}"
    )


@pytest.mark.parametrize(
    "num,display",
    [
        (ARTIFACT_ONLY_NUM, "artifact-only"),
        (COMMENTS_ONLY_NUM, "comments.yaml-only"),
        (LINKS_ONLY_NUM, "links.yaml-only"),
    ],
    ids=["artifact-only", "comments-only", "links-only"],
)
def test_read_variant_omits_status(
    sandbox: Path, num: int, display: str
) -> None:
    result = _run_tool(
        sandbox, "read", "--number", f"opencode-config#{num}"
    )
    assert result.returncode == 0, (
        f"read on {display} variant crashed (exit {result.returncode}); "
        f"stderr: {result.stderr!r}"
    )
    status_lines = _read_status_lines(result.stdout)
    assert status_lines == [], (
        f"SC-4 RED: read fabricates status line for {display} variant; "
        f"status line(s): {status_lines!r}; output: {result.stdout!r}"
    )


# --- Empty dir: excluded from list and search -------------------------


def test_list_excludes_empty_dir(sandbox: Path) -> None:
    result = _run_tool(sandbox, "list")
    assert result.returncode == 0, (
        f"list crashed (exit {result.returncode}); stderr: {result.stderr!r}"
    )
    entry = _entry_for(result.stdout, f"opencode-config#{EMPTY_NUM}")
    assert entry is None, (
        f"SC-4 RED: empty dir rendered in list instead of excluded; "
        f"entry: {entry!r}"
    )


def test_search_excludes_empty_dir(sandbox: Path) -> None:
    result = _run_tool(sandbox, "search", "--query", "opencode-config")
    assert result.returncode == 0, (
        f"search crashed (exit {result.returncode}); stderr: {result.stderr!r}"
    )
    entry = _entry_for(result.stdout, f"opencode-config#{EMPTY_NUM}")
    assert entry is None, (
        f"SC-4 RED: empty dir rendered in search instead of excluded; "
        f"entry: {entry!r}"
    )
