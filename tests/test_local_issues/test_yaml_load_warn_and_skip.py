# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
"""SC-05 (issue 2432, item 5): yaml_load warn-and-skip hardening.

Fixture tree contains one malformed file per error class (malformed
frontmatter, invalid YAML syntax, schema violation) plus valid files that
must still parse. `list`, `search`, and `read` MUST complete
exception-free (exit 0, no traceback) while emitting stderr warnings
carrying the offending file path plus its error class. Valid files in
the same tree MUST still be parsed.

Runs against an isolated sandbox copy of the tool so no real
`.issues/` state is touched.

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
"""

import shutil
import subprocess
from pathlib import Path

import pytest

TOOL_NAME = "local-issues"

# Error-class tokens asserted in stderr warnings (SC-05 taxonomy).
MALFORMED_FRONTMATTER = "malformed-frontmatter"
INVALID_YAML_SYNTAX = "invalid-yaml"
SCHEMA_VIOLATION = "schema-violation"

# Malformed fixture files, one per error class.
MALFORMED_FILES: dict[Path, str] = {
    Path("4210/spec.md"): MALFORMED_FRONTMATTER,
    Path("4211/issue.yaml"): INVALID_YAML_SYNTAX,
    Path("4212/links.yaml"): SCHEMA_VIOLATION,
}


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
        return "---\ntitle: 'broken fm'\nstatus: open\n" "body text without closing delimiter\n"
    if error_class == INVALID_YAML_SYNTAX:
        # Unclosed flow sequence — yaml.safe_load raises YAMLError.
        return "title: [unclosed\nstatus: open\n"
    # SCHEMA_VIOLATION: valid YAML syntax, wrong schema shape —
    # links must be a list of {number, type}, not a bare string.
    return "links: 'not-a-list'\n"


@pytest.fixture
def sandbox() -> Path:
    """Isolated sandbox repo with a copy of local-issues and a fixture tree.

    Layout mirrors the real repo: <root>/opencode-config/.opencode/tools/
    local-issues plus .issues/{N}/ fixture issues. One issue per error
    class holds a malformed file; two issues hold only valid files.
    """
    base = TMP_DIR / "run-sc05"
    if base.exists():
        shutil.rmtree(base)
    root = base / "opencode-config"
    tools_dir = root / ".opencode" / "tools"
    issues_dir = root / ".issues"
    tools_dir.mkdir(parents=True)
    shutil.copy2(REAL_TOOL, tools_dir / TOOL_NAME)

    for rel, _cls in MALFORMED_FILES.items():
        issue_dir = issues_dir / rel.parts[0]
        issue_dir.mkdir(parents=True)
        (issues_dir / rel).write_text(_fixture_content(rel), encoding="utf-8")

    # Valid issue: must still be parsed and listed/read.
    valid = issues_dir / "4220"
    valid.mkdir()
    (valid / "issue.yaml").write_text(
        "title: valid-issue-parses\n"
        "status: open\n"
        "labels: []\n"
        "created: '2026-01-01T00:00:00Z'\n",
        encoding="utf-8",
    )
    # Valid issue with a plain spec.md (markdown fallback path).
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
    )


def _assert_no_crash(result: subprocess.CompletedProcess, command: str) -> None:
    """SC-05: command completes exception-free."""
    assert result.returncode == 0, (
        f"{command} crashed on malformed fixture tree "
        f"(exit {result.returncode}); stderr: {result.stderr!r}"
    )
    assert "Traceback" not in result.stderr, (
        f"{command} raised an uncaught exception on malformed tree; "
        f"stderr: {result.stderr!r}"
    )


def _assert_warning_for(result: subprocess.CompletedProcess, command: str) -> None:
    """Each malformed file gets a stderr warning with path + error class."""
    for rel, error_class in MALFORMED_FILES.items():
        path_str = str(rel)
        assert path_str in result.stderr, (
            f"{command} stderr missing malformed path {path_str!r}: "
            f"{result.stderr!r}"
        )
        assert error_class in result.stderr, (
            f"{command} stderr missing error class {error_class!r} for "
            f"{path_str!r}: {result.stderr!r}"
        )


def test_list_warn_and_skip(sandbox: Path) -> None:
    # SC-05: list completes exception-free with warnings, valid issue still listed
    result = _run_tool(sandbox, "list")
    _assert_no_crash(result, "list")
    _assert_warning_for(result, "list")
    assert "valid-issue-parses" in result.stdout, (
        f"list dropped valid issue from output: {result.stdout!r}"
    )


def test_search_warn_and_skip(sandbox: Path) -> None:
    # SC-05: search completes exception-free with warnings, valid issue still found
    result = _run_tool(sandbox, "search", "--query", "valid-issue-parses")
    _assert_no_crash(result, "search")
    _assert_warning_for(result, "search")
    assert "valid-issue-parses" in result.stdout, (
        f"search dropped valid issue from results: {result.stdout!r}"
    )


def test_read_malformed_and_valid(sandbox: Path) -> None:
    # SC-05: read of malformed issue warns + returns skip/empty result
    result = _run_tool(sandbox, "read", "--number", "opencode-config#4211")
    _assert_no_crash(result, "read")
    assert INVALID_YAML_SYNTAX in result.stderr, (
        f"read stderr missing error class for malformed issue: "
        f"{result.stderr!r}"
    )

    # SC-05: read of a valid issue in the same tree still parses
    result = _run_tool(sandbox, "read", "--number", "opencode-config#4220")
    _assert_no_crash(result, "read")
    assert "valid-issue-parses" in result.stdout, (
        f"read failed to parse valid issue in same tree: {result.stdout!r}"
    )


def test_valid_markdown_fallback_still_parses(sandbox: Path) -> None:
    # SC-05: valid frontmatter-less spec.md fallback still works alongside malformed files
    result = _run_tool(sandbox, "read", "--number", "opencode-config#4221")
    _assert_no_crash(result, "read")
    assert "Plain markdown body" in result.stdout, (
        f"read failed on valid markdown fallback issue: {result.stdout!r}"
    )


@pytest.mark.parametrize(
    "rel", [str(rel) for rel in MALFORMED_FILES]
)
def test_each_malformed_file_warns_on_list(sandbox: Path, rel: str) -> None:
    # SC-05: one warning per malformed file, each with its error class
    result = _run_tool(sandbox, "list")
    _assert_no_crash(result, "list")
    assert rel in result.stderr, (
        f"list stderr missing warning for {rel!r}: {result.stderr!r}"
    )
    assert MALFORMED_FILES[Path(rel)] in result.stderr, (
        f"list stderr missing error class for {rel!r}: {result.stderr!r}"
    )
