# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
"""SC-06 (issue 2432, item 6): `validate-yaml` subcommand exit-code contract.

Contract (fixed before Phases 4-5 consumers):
- exit 0 when the fixture tree is clean
- exit 1 when malformed files are found
- never mutates files
- report lines on stdout/stderr of the form `<path>: <error-class>`
  reusing the SC-05 error-class taxonomy (malformed-frontmatter,
  invalid-yaml, schema-violation).

Runs against an isolated sandbox copy of the tool so no real
`.issues/` state is touched.

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
"""

import shutil
import subprocess
from pathlib import Path

import pytest

TOOL_NAME = "local-issues"

# SC-05 error-class taxonomy tokens.
MALFORMED_FRONTMATTER = "malformed-frontmatter"
INVALID_YAML_SYNTAX = "invalid-yaml"
SCHEMA_VIOLATION = "schema-violation"

# Malformed fixture files, one per error class.
MALFORMED_FILES: dict[Path, str] = {
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


def _fixture_content(rel: Path) -> str:
    """Return the fixture content for a malformed file by error class."""
    error_class = MALFORMED_FILES[rel]
    if error_class == MALFORMED_FRONTMATTER:
        # Frontmatter opens with --- but never closes it.
        return (
            "---\ntitle: 'broken fm'\nstatus: open\n"
            "body text without closing delimiter\n"
        )
    if error_class == INVALID_YAML_SYNTAX:
        # Unclosed flow sequence — yaml.safe_load raises YAMLError.
        return "title: [unclosed\nstatus: open\n"
    # SCHEMA_VIOLATION: valid YAML syntax, wrong schema shape —
    # links must be a list of {number, type}, not a bare string.
    return "links: 'not-a-list'\n"


def _make_sandbox(request: pytest.FixtureRequest, base_name: str) -> Path:
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
    return root, tools_dir, issues_dir


@pytest.fixture
def dirty_sandbox() -> Path:
    """Sandbox with one malformed file per error class plus a valid issue."""
    root, _tools_dir, issues_dir = _make_sandbox(None, "run-sc06-dirty")

    for rel in MALFORMED_FILES:
        issue_dir = issues_dir / rel.parts[0]
        issue_dir.mkdir(parents=True)
        (issues_dir / rel).write_text(_fixture_content(rel), encoding="utf-8")

    valid = issues_dir / "4220"
    valid.mkdir()
    (valid / "issue.yaml").write_text(VALID_ISSUE_YAML, encoding="utf-8")

    subprocess.run(["git", "init", "-q", str(root)], check=True)
    return root


@pytest.fixture
def clean_sandbox() -> Path:
    """Sandbox containing only valid files."""
    root, _tools_dir, issues_dir = _make_sandbox(None, "run-sc06-clean")

    valid = issues_dir / "4220"
    valid.mkdir()
    (valid / "issue.yaml").write_text(VALID_ISSUE_YAML, encoding="utf-8")
    valid_md = issues_dir / "4221"
    valid_md.mkdir()
    (valid_md / "spec.md").write_text(
        "Plain markdown body with no frontmatter.\n", encoding="utf-8"
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


def _snapshot_tree(sandbox: Path) -> dict[Path, bytes]:
    """Snapshot all files under .issues/ for mutation detection."""
    issues = sandbox / ".issues"
    return {
        p.relative_to(sandbox): p.read_bytes() for p in issues.rglob("*") if p.is_file()
    }


def test_validate_yaml_exit_1_on_malformed(dirty_sandbox: Path) -> None:
    # SC-06: exit 1 when malformed files found
    result = _run_tool(dirty_sandbox, "validate-yaml")
    assert result.returncode == 1, (
        f"validate-yaml expected exit 1 on malformed tree, got "
        f"{result.returncode}; stdout: {result.stdout!r} "
        f"stderr: {result.stderr!r}"
    )


def test_validate_yaml_report_lines(dirty_sandbox: Path) -> None:
    # SC-06: one `<path>: <error-class>` report line per malformed file
    result = _run_tool(dirty_sandbox, "validate-yaml")
    output = result.stdout + result.stderr
    for rel, error_class in MALFORMED_FILES.items():
        path_str = str(rel)
        assert f"{path_str}: {error_class}" in output, (
            f"validate-yaml missing report line {path_str!r}: "
            f"{error_class!r}; stdout: {result.stdout!r} "
            f"stderr: {result.stderr!r}"
        )


def test_validate_yaml_exit_0_on_clean(clean_sandbox: Path) -> None:
    # SC-06: exit 0 when tree is clean
    result = _run_tool(clean_sandbox, "validate-yaml")
    assert result.returncode == 0, (
        f"validate-yaml expected exit 0 on clean tree, got "
        f"{result.returncode}; stdout: {result.stdout!r} "
        f"stderr: {result.stderr!r}"
    )


@pytest.mark.parametrize("sandbox_name", ["dirty_sandbox", "clean_sandbox"])
def test_validate_yaml_never_mutates(
    sandbox_name: str, request: pytest.FixtureRequest
) -> None:
    # SC-06: validate-yaml never mutates files
    sandbox = request.getfixturevalue(sandbox_name)
    before = _snapshot_tree(sandbox)
    result = _run_tool(sandbox, "validate-yaml")
    after = _snapshot_tree(sandbox)
    assert before == after, (
        f"validate-yaml mutated files under .issues/ (exit "
        f"{result.returncode}); changed: "
        f"{[k for k in set(before) | set(after) if before.get(k) != after.get(k)]}"
    )
