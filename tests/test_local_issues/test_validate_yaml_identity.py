# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
"""SC-2 (issue 2769): validate-yaml record-identity divergence classes.

Contract:
- On a tracker-host store (origin resolves to `github.com`, or to a
  host-mapped tracker base per `local-issues-host-maps.conf`), the sweep
  flags each record that:
  - (a) lacks a resolvable `remote_url` — absent, empty, or unparseable
    as a tracker issue identity → `missing-remote-identity`
  - (b) carries a `remote_url` naming an issue number other than the
    record's folder number → `remote-number-mismatch`
  - (c) carries a `remote_url` naming an owner/repo slug other than the
    store repo's origin-derived owner/repo → `remote-repo-mismatch`
- Every predicate is a locally stored fact (origin URL, host-maps conf,
  record fields); the run needs no network and contacts no remote API.
- Non-tracker-host stores (git-init sandbox with no origin, unmapped
  non-github host) skip the identity classes entirely.
- Scoped `--number` mode inherits the same checks through the shared scan
  machinery, with the existing scoped exit semantics.
- Findings keep the existing machine-greppable report form
  (`<repo>/<path>: <error-class>`) and exit-code semantics (1 on findings).

Tier: regression (test-discipline card, mark-on-creation; rides the
default gate).

Runs against isolated sandbox copies of the tool so no real `.issues/`
state is touched.

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
"""

import shutil
import subprocess
from pathlib import Path

TOOL_NAME = "local-issues"
REPO_QUALIFIER = "opencode-config"

# Identity-divergence error classes (issue 2769).
MISSING_REMOTE_IDENTITY = "missing-remote-identity"
REMOTE_NUMBER_MISMATCH = "remote-number-mismatch"
REMOTE_REPO_MISMATCH = "remote-repo-mismatch"

GITHUB_ORIGIN = "git@github.com:owner/repo.git"
HOST_MAPPED_ORIGIN = "git@gitbucket.internal:owner/repo.git"
UNMAPPED_ORIGIN = "git@other.example:owner/repo.git"
HOST_MAPS_CONF = "gitbucket.internal:8490 = https://gitbucket.internal:8490\n"

CONSISTENT_REMOTE_URL = "https://github.com/owner/repo/issues/{number}"


def _find_project_root() -> Path:
    path = Path(__file__).resolve()
    while path.name != ".opencode":
        if path.parent == path:
            raise RuntimeError("Could not find .opencode/ directory")
        path = path.parent
    return path.parent


PROJECT_ROOT = _find_project_root()
REAL_TOOL = PROJECT_ROOT / ".opencode" / "tools" / TOOL_NAME
TMP_DIR = PROJECT_ROOT / "tmp" / "issue-2769" / "test-sandboxes"


def _write_record(root: Path, number: int, remote_url: str | None) -> None:
    """Seed one clean-YAML record directory; remote_url None omits the field."""
    record = root / ".issues" / str(number)
    record.mkdir(parents=True)
    body = "title: seeded-record-parses\nstatus: open\nlabels: []\n"
    if remote_url is not None:
        body += f"remote_url: {remote_url}\n"
    (record / "issue.yaml").write_text(body, encoding="utf-8")


def _make_sandbox(
    base_name: str, origin: str | None, with_host_maps: bool = False
) -> Path:
    """Isolated sandbox repo: tool copy, git init, optional origin URL."""
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
    if origin is not None:
        subprocess.run(
            ["git", "-C", str(root), "remote", "add", "origin", origin],
            check=True,
        )
    if with_host_maps:
        (tools_dir / "local-issues-host-maps.conf").write_text(
            HOST_MAPS_CONF, encoding="utf-8"
        )
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


def _has_class(result: subprocess.CompletedProcess, error_class: str) -> bool:
    return error_class in result.stdout + result.stderr


# --- Class (a): missing / unresolvable remote identity ---------------------


def test_missing_remote_identity_flagged() -> None:
    sandbox = _make_sandbox(
        "identity-missing-remote", origin=GITHUB_ORIGIN
    )
    _write_record(sandbox, 1001, remote_url=None)
    result = _run_tool(sandbox, "validate-yaml")
    assert result.returncode == 1, (
        f"tracker-host record lacking remote_url must exit 1, got "
        f"{result.returncode}; stdout: {result.stdout!r} "
        f"stderr: {result.stderr!r}"
    )
    line = f"{REPO_QUALIFIER}/1001/issue.yaml: {MISSING_REMOTE_IDENTITY}"
    assert line in result.stdout, (
        f"missing line {line!r}; stdout: {result.stdout!r} "
        f"stderr: {result.stderr!r}"
    )


def test_unresolvable_remote_url_flagged_as_missing() -> None:
    sandbox = _make_sandbox(
        "identity-unresolvable", origin=GITHUB_ORIGIN
    )
    _write_record(sandbox, 1008, remote_url=GITHUB_ORIGIN)
    result = _run_tool(sandbox, "validate-yaml")
    assert result.returncode == 1, (
        f"unparseable remote_url must exit 1, got {result.returncode}; "
        f"stdout: {result.stdout!r} stderr: {result.stderr!r}"
    )
    line = f"{REPO_QUALIFIER}/1008/issue.yaml: {MISSING_REMOTE_IDENTITY}"
    assert line in result.stdout, (
        f"missing line {line!r}; stdout: {result.stdout!r} "
        f"stderr: {result.stderr!r}"
    )


# --- Class (b): issue-number mismatch --------------------------------------


def test_remote_number_mismatch_flagged() -> None:
    sandbox = _make_sandbox(
        "identity-number-mismatch", origin=GITHUB_ORIGIN
    )
    _write_record(sandbox, 1002, remote_url=f"{CONSISTENT_REMOTE_URL.format(number=999)}")
    result = _run_tool(sandbox, "validate-yaml")
    assert result.returncode == 1, (
        f"remote_url naming issue 999 in folder 1002 must exit 1, got "
        f"{result.returncode}; stdout: {result.stdout!r} "
        f"stderr: {result.stderr!r}"
    )
    line = f"{REPO_QUALIFIER}/1002/issue.yaml: {REMOTE_NUMBER_MISMATCH}"
    assert line in result.stdout, (
        f"missing line {line!r}; stdout: {result.stdout!r} "
        f"stderr: {result.stderr!r}"
    )


# --- Class (c): repo-slug mismatch ------------------------------------------


def test_remote_repo_mismatch_flagged() -> None:
    sandbox = _make_sandbox(
        "identity-repo-mismatch", origin=GITHUB_ORIGIN
    )
    _write_record(
        sandbox, 1003, remote_url="https://github.com/owner/other/issues/1003"
    )
    result = _run_tool(sandbox, "validate-yaml")
    assert result.returncode == 1, (
        f"remote_url naming owner/other in store owner/repo must exit 1, "
        f"got {result.returncode}; stdout: {result.stdout!r} "
        f"stderr: {result.stderr!r}"
    )
    line = f"{REPO_QUALIFIER}/1003/issue.yaml: {REMOTE_REPO_MISMATCH}"
    assert line in result.stdout, (
        f"missing line {line!r}; stdout: {result.stdout!r} "
        f"stderr: {result.stderr!r}"
    )


# --- Consistent records are silent ------------------------------------------


def test_consistent_records_silent() -> None:
    sandbox = _make_sandbox("identity-consistent-silent", origin=GITHUB_ORIGIN)
    _write_record(sandbox, 1004, remote_url=f"{CONSISTENT_REMOTE_URL.format(number=1004)}")
    _write_record(
        sandbox, 1005, remote_url=f"{CONSISTENT_REMOTE_URL.format(number=1005)}"
    )
    result = _run_tool(sandbox, "validate-yaml")
    assert result.returncode == 0, (
        f"consistent records must exit 0, got {result.returncode}; "
        f"stdout: {result.stdout!r} stderr: {result.stderr!r}"
    )
    for wrong in (MISSING_REMOTE_IDENTITY, REMOTE_NUMBER_MISMATCH, REMOTE_REPO_MISMATCH):
        assert not _has_class(result, wrong), (
            f"consistent store must not emit {wrong!r}; stdout: "
            f"{result.stdout!r} stderr: {result.stderr!r}"
        )


# --- Tracker-host scoping (local facts only, no noise elsewhere) ------------


def test_no_origin_store_skips_identity() -> None:
    sandbox = _make_sandbox("identity-no-origin-skip", origin=None)
    _write_record(sandbox, 1006, remote_url=None)
    result = _run_tool(sandbox, "validate-yaml")
    assert result.returncode == 0, (
        f"store without origin must skip identity classes, got exit "
        f"{result.returncode}; stdout: {result.stdout!r} "
        f"stderr: {result.stderr!r}"
    )
    assert not _has_class(result, MISSING_REMOTE_IDENTITY), (
        f"identity class leaked on non-tracker-host store; stdout: "
        f"{result.stdout!r} stderr: {result.stderr!r}"
    )


def test_unmapped_host_skips_identity() -> None:
    sandbox = _make_sandbox("identity-unmapped-host-skip", origin=UNMAPPED_ORIGIN)
    _write_record(sandbox, 1007, remote_url=None)
    result = _run_tool(sandbox, "validate-yaml")
    assert result.returncode == 0, (
        f"unmapped non-github host must skip identity classes, got exit "
        f"{result.returncode}; stdout: {result.stdout!r} "
        f"stderr: {result.stderr!r}"
    )
    assert not _has_class(result, MISSING_REMOTE_IDENTITY), (
        f"identity class leaked on unmapped host; stdout: "
        f"{result.stdout!r} stderr: {result.stderr!r}"
    )


def test_host_mapped_store_flags_missing_identity() -> None:
    sandbox = _make_sandbox(
        "identity-host-mapped",
        origin=HOST_MAPPED_ORIGIN,
        with_host_maps=True,
    )
    _write_record(sandbox, 1009, remote_url=None)
    result = _run_tool(sandbox, "validate-yaml")
    assert result.returncode == 1, (
        f"host-mapped tracker store must flag missing identity, got exit "
        f"{result.returncode}; stdout: {result.stdout!r} "
        f"stderr: {result.stderr!r}"
    )
    line = f"{REPO_QUALIFIER}/1009/issue.yaml: {MISSING_REMOTE_IDENTITY}"
    assert line in result.stdout, (
        f"missing line {line!r}; stdout: {result.stdout!r} "
        f"stderr: {result.stderr!r}"
    )


# --- Scoped mode inherits the identity checks -------------------------------


def test_scoped_mode_inherits_identity_checks() -> None:
    sandbox = _make_sandbox("identity-scoped-inherit", origin=GITHUB_ORIGIN)
    _write_record(sandbox, 1002, remote_url=f"{CONSISTENT_REMOTE_URL.format(number=999)}")
    _write_record(sandbox, 1004, remote_url=f"{CONSISTENT_REMOTE_URL.format(number=1004)}")
    flagged = _run_tool(
        sandbox, "validate-yaml", "--number", f"{REPO_QUALIFIER}#1002"
    )
    assert flagged.returncode == 1, (
        f"scoped mode must flag a divergent target, got {flagged.returncode}; "
        f"stdout: {flagged.stdout!r} stderr: {flagged.stderr!r}"
    )
    line = f"{REPO_QUALIFIER}/1002/issue.yaml: {REMOTE_NUMBER_MISMATCH}"
    assert line in flagged.stdout, (
        f"missing line {line!r}; stdout: {flagged.stdout!r} "
        f"stderr: {flagged.stderr!r}"
    )
    clean = _run_tool(
        sandbox, "validate-yaml", "--number", f"{REPO_QUALIFIER}#1004"
    )
    assert clean.returncode == 0, (
        f"scoped mode on a consistent target must exit 0, got "
        f"{clean.returncode}; stdout: {clean.stdout!r} "
        f"stderr: {clean.stderr!r}"
    )
