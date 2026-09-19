# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
"""SC-1 (issue 2450, phase 1, items 5-6): scoped `validate-yaml --number` mode.

Contract:
- `validate-yaml --number <repo>#N` scans ONLY the target issue directory
  (via the existing exact-match lookup) through the shared scan machinery.
- Scoped exit semantics: exit 0 on a clean target even when unrelated
  issues in the same workspace violate the schema; exit 1 on a violating
  target.
- Fail fast (non-zero exit + error) when the target directory is absent.
- Bare unqualified numbers are rejected (qualified repo#N required).
- No-flag default (full workspace scan) is unchanged — covered by
  test_validate_yaml_exit_codes.py.

Runs against an isolated sandbox copy of the tool so no real
`.issues/` state is touched.

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
"""

import shutil
import subprocess
from pathlib import Path

import pytest

TOOL_NAME = "local-issues"
REPO_QUALIFIER = "opencode-config"

# SC-05 error-class taxonomy tokens.
MALFORMED_FRONTMATTER = "malformed-frontmatter"
INVALID_YAML_SYNTAX = "invalid-yaml"
SCHEMA_VIOLATION = "schema-violation"

# Violating NEIGHBOR issues (not the target) in the fixture workspace.
VIOLATING_NEIGHBORS: dict[Path, str] = {
    Path("4210/spec.md"): MALFORMED_FRONTMATTER,
    Path("4211/issue.yaml"): INVALID_YAML_SYNTAX,
    Path("4212/links.yaml"): SCHEMA_VIOLATION,
}

VALID_ISSUE_YAML = (
    "title: valid-issue-parses\n"
    "status: open\n"
    "labels: []\n"
    "created: '2026-01-01T00:00:00Z'\n"
)

VIOLATING_TARGET_FILES: dict[Path, str] = {
    Path("4299/issue.yaml"): INVALID_YAML_SYNTAX,
    Path("4299/links.yaml"): SCHEMA_VIOLATION,
}

TARGET_NUMBER = 4220
VIOLATING_TARGET_NUMBER = 4299
MISSING_TARGET_NUMBER = 4999


def _find_project_root() -> Path:
    path = Path(__file__).resolve()
    while path.name != ".opencode":
        if path.parent == path:
            raise RuntimeError("Could not find .opencode/ directory")
        path = path.parent
    return path.parent


PROJECT_ROOT = _find_project_root()
REAL_TOOL = PROJECT_ROOT / ".opencode" / "tools" / TOOL_NAME
TMP_DIR = PROJECT_ROOT / "tmp" / "issue-2450" / "test-sandboxes"


def _neighbor_content(rel: Path) -> str:
    error_class = VIOLATING_NEIGHBORS[rel]
    if error_class == MALFORMED_FRONTMATTER:
        return (
            "---\ntitle: 'broken fm'\nstatus: open\n"
            "body text without closing delimiter\n"
        )
    if error_class == INVALID_YAML_SYNTAX:
        return "title: [unclosed\nstatus: open\n"
    return "links: 'not-a-list'\n"


def _target_violation_content(rel: Path) -> str:
    error_class = VIOLATING_TARGET_FILES[rel]
    if error_class == INVALID_YAML_SYNTAX:
        return "title: [unclosed\nstatus: open\n"
    return "links: 'not-a-list'\n"


def _make_sandbox(base_name: str) -> Path:
    """Isolated sandbox repo with a copy of local-issues and fixture tree."""
    base = TMP_DIR / base_name
    if base.exists():
        shutil.rmtree(base)
    root = base / "opencode-config"
    tools_dir = root / ".opencode" / "tools"
    issues_dir = root / ".issues"
    tools_dir.mkdir(parents=True)
    issues_dir.mkdir(parents=True)
    shutil.copy2(REAL_TOOL, tools_dir / TOOL_NAME)
    subprocess.run(["git", "init", "-q", str(root)], check=True)
    return root


@pytest.fixture
def dirty_workspace_clean_target() -> Path:
    """Workspace with violating neighbors and a CLEAN target issue."""
    root = _make_sandbox("run-2450-scoped-clean-target")
    issues_dir = root / ".issues"

    for rel in VIOLATING_NEIGHBORS:
        (issues_dir / rel.parts[0]).mkdir(parents=True)
        (issues_dir / rel).write_text(_neighbor_content(rel), encoding="utf-8")

    target = issues_dir / str(TARGET_NUMBER)
    target.mkdir()
    (target / "issue.yaml").write_text(VALID_ISSUE_YAML, encoding="utf-8")
    return root


@pytest.fixture
def violating_target_workspace() -> Path:
    """Workspace whose TARGET issue itself violates the schema."""
    root = _make_sandbox("run-2450-scoped-violating-target")
    issues_dir = root / ".issues"

    for rel in VIOLATING_TARGET_FILES:
        (issues_dir / rel.parts[0]).mkdir(parents=True, exist_ok=True)
        (issues_dir / rel).write_text(_target_violation_content(rel), encoding="utf-8")
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


def test_scoped_exit_0_clean_target_amid_violating_neighbors(
    dirty_workspace_clean_target: Path,
) -> None:
    result = _run_tool(
        dirty_workspace_clean_target,
        "validate-yaml",
        "--number",
        f"{REPO_QUALIFIER}#{TARGET_NUMBER}",
    )
    assert result.returncode == 0, (
        f"scoped validate-yaml expected exit 0 on clean target amid "
        f"violating neighbors, got {result.returncode}; "
        f"stdout: {result.stdout!r} stderr: {result.stderr!r}"
    )


def test_scoped_exit_1_on_violating_target(violating_target_workspace: Path) -> None:
    result = _run_tool(
        violating_target_workspace,
        "validate-yaml",
        "--number",
        f"{REPO_QUALIFIER}#{VIOLATING_TARGET_NUMBER}",
    )
    assert result.returncode == 1, (
        f"scoped validate-yaml expected exit 1 on violating target, got "
        f"{result.returncode}; stdout: {result.stdout!r} stderr: {result.stderr!r}"
    )


def test_scoped_report_lines_target_only(violating_target_workspace: Path) -> None:
    result = _run_tool(
        violating_target_workspace,
        "validate-yaml",
        "--number",
        f"{REPO_QUALIFIER}#{VIOLATING_TARGET_NUMBER}",
    )
    output = result.stdout + result.stderr
    for rel, error_class in VIOLATING_TARGET_FILES.items():
        path_str = str(rel)
        assert f"{path_str}: {error_class}" in output, (
            f"scoped validate-yaml missing report line {path_str!r}: "
            f"{error_class!r}; stdout: {result.stdout!r} stderr: {result.stderr!r}"
        )


def test_scoped_fail_fast_on_absent_target(
    dirty_workspace_clean_target: Path,
) -> None:
    result = _run_tool(
        dirty_workspace_clean_target,
        "validate-yaml",
        "--number",
        f"{REPO_QUALIFIER}#{MISSING_TARGET_NUMBER}",
    )
    assert result.returncode != 0, (
        f"scoped validate-yaml expected fail-fast (non-zero exit) on absent "
        f"target directory, got exit 0; stdout: {result.stdout!r} "
        f"stderr: {result.stderr!r}"
    )


def test_scoped_report_lines_match_format(violating_target_workspace: Path) -> None:
    """SC-2: every scoped report line matches `<path>: <error-class>`."""
    result = _run_tool(
        violating_target_workspace,
        "validate-yaml",
        "--number",
        f"{REPO_QUALIFIER}#{VIOLATING_TARGET_NUMBER}",
    )
    report_lines = [
        line for line in result.stdout.splitlines() if line.strip()
    ]
    assert report_lines, (
        f"scoped validate-yaml emitted no report lines; stdout: "
        f"{result.stdout!r} stderr: {result.stderr!r}"
    )
    for line in report_lines:
        assert ": " in line, f"report line missing '<path>: <class>' shape: {line!r}"
        path_str, _, error_class = line.partition(": ")
        assert path_str == f"{VIOLATING_TARGET_NUMBER}/{Path(path_str).name}", (
            f"report path not in '<issue>/<file>' form: {line!r}"
        )
        assert error_class in {
            MALFORMED_FRONTMATTER,
            INVALID_YAML_SYNTAX,
            SCHEMA_VIOLATION,
        }, f"unknown error class in report line: {line!r}"


def test_scoped_output_equals_filtered_workspace(
    violating_target_workspace: Path,
) -> None:
    """SC-2: scoped output == workspace output filtered to target paths."""
    scoped = _run_tool(
        violating_target_workspace,
        "validate-yaml",
        "--number",
        f"{REPO_QUALIFIER}#{VIOLATING_TARGET_NUMBER}",
    )
    workspace = _run_tool(violating_target_workspace, "validate-yaml")

    target_prefix = f"{VIOLATING_TARGET_NUMBER}/"
    expected = sorted(
        line
        for line in workspace.stdout.splitlines()
        if line.startswith(target_prefix)
    )
    actual = sorted(line for line in scoped.stdout.splitlines() if line.strip())
    assert actual == expected, (
        f"scoped output {actual!r} != workspace output filtered to "
        f"{target_prefix!r} ({expected!r}); workspace stdout: "
        f"{workspace.stdout!r} scoped stdout: {scoped.stdout!r}"
    )
    assert expected, "fixture produced no workspace findings for the target"


def test_scoped_rejects_bare_number(dirty_workspace_clean_target: Path) -> None:
    result = _run_tool(
        dirty_workspace_clean_target,
        "validate-yaml",
        "--number",
        str(TARGET_NUMBER),
    )
    assert result.returncode != 0, (
        f"scoped validate-yaml expected rejection of bare unqualified "
        f"number, got exit 0; stdout: {result.stdout!r} stderr: {result.stderr!r}"
    )
    assert "qualifier" in (result.stdout + result.stderr).lower(), (
        f"bare-number rejection must name the qualifier requirement; "
        f"stdout: {result.stdout!r} stderr: {result.stderr!r}"
    )
