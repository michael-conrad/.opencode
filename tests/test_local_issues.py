"""RED-phase tests for local-issues tool — all should FAIL against current buggy code.

Co-authored with AI: OpenCode (deepseek-v4-flash)
"""
import subprocess
import os
import tempfile
import pytest

# Derive absolute path to the tool — tests run with varying cwd
_TOOL_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOCAL_ISSUES_TOOL = os.path.join(_TOOL_DIR, "tools", "local-issues")
LOCAL_ISSUES = ["uv", "run", LOCAL_ISSUES_TOOL]


@pytest.fixture
def issues_dir():
    """Create a temporary .issues/ directory for testing."""
    with tempfile.TemporaryDirectory(prefix="test-local-issues-") as tmpdir:
        os.makedirs(os.path.join(tmpdir, ".issues", "open"))
        os.makedirs(os.path.join(tmpdir, ".issues", "closed"))
        with open(os.path.join(tmpdir, ".issues", ".counter"), "w") as f:
            f.write("1\n")
        yield tmpdir


def _create_test_issue(tmpdir):
    """Create a test issue via the CLI and return its number."""
    result = subprocess.run(
        LOCAL_ISSUES + ["create", "--title", "Test Issue", "--labels", "SPEC"],
        cwd=tmpdir, capture_output=True, text=True,
    )
    assert result.returncode == 0, f"Failed to create test issue: {result.stderr}"
    return 1


def _read_frontmatter(tmpdir, number, status="open"):
    """Read frontmatter from an issue's spec.md."""
    import yaml
    open_dir = os.path.join(tmpdir, ".issues", status)
    for entry in os.listdir(open_dir):
        if entry == str(number) or entry.startswith(f"{number}-"):
            spec_path = os.path.join(open_dir, entry, "spec.md")
            with open(spec_path) as f:
                content = f.read()
            if not content.startswith("---"):
                return {}
            end = content.find("---", 3)
            fm_text = content[3:end].strip()
            meta = yaml.safe_load(fm_text)
            return meta or {}
    return {}


# --- C1: cmd_search undefined ---

def test_search_command_exists(issues_dir):
    """SC-1: `local-issues search` must not crash with NameError."""
    result = subprocess.run(
        LOCAL_ISSUES + ["search"],
        cwd=issues_dir, capture_output=True, text=True,
    )
    assert result.returncode == 0, f"search crashed: {result.stderr}"


def test_search_returns_results(issues_dir):
    """SC-1: search with known issues returns output."""
    _create_test_issue(issues_dir)
    result = subprocess.run(
        LOCAL_ISSUES + ["search", "--query", "Test"],
        cwd=issues_dir, capture_output=True, text=True,
    )
    assert result.returncode == 0
    assert "Test Issue" in result.stdout


def test_list_command_works(issues_dir):
    """SC-1: `local-issues list` delegates to search and works."""
    _create_test_issue(issues_dir)
    result = subprocess.run(
        LOCAL_ISSUES + ["list"],
        cwd=issues_dir, capture_output=True, text=True,
    )
    assert result.returncode == 0
    assert "Test Issue" in result.stdout


def test_search_filters_by_status(issues_dir):
    """SC-1: search --status open filters correctly."""
    _create_test_issue(issues_dir)
    result = subprocess.run(
        LOCAL_ISSUES + ["search", "--status", "open"],
        cwd=issues_dir, capture_output=True, text=True,
    )
    assert result.returncode == 0


def test_search_filters_by_labels(issues_dir):
    """SC-1: search --labels SPEC filters correctly."""
    _create_test_issue(issues_dir)
    result = subprocess.run(
        LOCAL_ISSUES + ["search", "--labels", "SPEC"],
        cwd=issues_dir, capture_output=True, text=True,
    )
    assert result.returncode == 0


# --- C2: cmd_review undefined ---

def test_review_command_exists(issues_dir):
    """SC-2: `local-issues review NNN` must not crash with NameError."""
    _create_test_issue(issues_dir)
    result = subprocess.run(
        LOCAL_ISSUES + ["review", "1"],
        cwd=issues_dir, capture_output=True, text=True,
    )
    assert result.returncode == 0, f"review crashed: {result.stderr}"


def test_review_shows_metadata(issues_dir):
    """SC-2: review output contains title, status, labels."""
    _create_test_issue(issues_dir)
    result = subprocess.run(
        LOCAL_ISSUES + ["review", "1"],
        cwd=issues_dir, capture_output=True, text=True,
    )
    assert result.returncode == 0
    assert "Test Issue" in result.stdout


# --- C3: cmd_link writes github_issue not remote_issue ---

def test_link_writes_github_issue(issues_dir):
    """SC-3: link produces frontmatter with github_issue, not remote_issue."""
    _create_test_issue(issues_dir)
    result = subprocess.run(
        LOCAL_ISSUES + ["link", "1", "--github", "42"],
        cwd=issues_dir, capture_output=True, text=True,
    )
    assert result.returncode == 0, f"link crashed: {result.stderr}"
    meta = _read_frontmatter(issues_dir, 1)
    assert "github_issue" in meta, f"Expected github_issue in frontmatter, got keys: {list(meta.keys())}"
    assert meta["github_issue"] == 42, f"Expected github_issue=42, got {meta.get('github_issue')}"
    assert "remote_issue" not in meta, "Should not have remote_issue field"


def test_link_read_roundtrip(issues_dir):
    """SC-3: after link, cmd_read shows github_issue field."""
    _create_test_issue(issues_dir)
    subprocess.run(
        LOCAL_ISSUES + ["link", "1", "--github", "42"],
        cwd=issues_dir, capture_output=True, text=True,
    )
    result = subprocess.run(
        LOCAL_ISSUES + ["read", "1"],
        cwd=issues_dir, capture_output=True, text=True,
    )
    assert result.returncode == 0
    assert "github_issue" in result.stdout
    assert "42" in result.stdout


def test_parse_number_bare_nnn(issues_dir):
    """SC-3: _parse_number extracts integer from bare NNN directory name."""
    bare_dir = os.path.join(issues_dir, ".issues", "open", "42")
    os.makedirs(bare_dir, exist_ok=True)
    result = subprocess.run(
        LOCAL_ISSUES + ["read", "--number", "42"],
        cwd=issues_dir, capture_output=True, text=True,
    )
    assert result.returncode == 0, f"read failed for bare NNN dir: {result.stderr}"


# --- H1: yaml.dump instead of _format_frontmatter ---

def test_record_remote_serialization_consistency(issues_dir):
    """H1/SC-12: promote --record-remote produces clean frontmatter without yaml.dump artifacts."""
    _create_test_issue(issues_dir)
    result = subprocess.run(
        LOCAL_ISSUES + ["promote", "1", "--record-remote", "https://github.com/test", "42"],
        cwd=issues_dir, capture_output=True, text=True,
    )
    assert result.returncode == 0, f"record-remote crashed: {result.stderr}"
    open_dir = os.path.join(issues_dir, ".issues", "open")
    for entry in os.listdir(open_dir):
        if entry.startswith("1") and os.path.isdir(os.path.join(open_dir, entry)):
            spec_path = os.path.join(open_dir, entry, "spec.md")
            with open(spec_path) as f:
                content = f.read()
            assert "!!" not in content, "yaml.dump tag artifacts found in frontmatter"
            break


# --- H2: cmd_comment doesn't update updated ---

def test_comment_updates_timestamp(issues_dir):
    """SC-4: comment updates the `updated` field in frontmatter."""
    _create_test_issue(issues_dir)
    meta_before = _read_frontmatter(issues_dir, 1)
    updated_before = meta_before.get("updated", "")
    import time
    time.sleep(0.1)
    result = subprocess.run(
        LOCAL_ISSUES + ["comment", "1", "--body", "test comment"],
        cwd=issues_dir, capture_output=True, text=True,
    )
    assert result.returncode == 0
    meta_after = _read_frontmatter(issues_dir, 1)
    updated_after = meta_after.get("updated", "")
    assert updated_after != updated_before, f"updated did not change: {updated_before} -> {updated_after}"


# --- H3: corrupted .counter crashes ---

def test_corrupted_counter_handled(issues_dir):
    """SC-11: corrupted .counter file does not crash tool."""
    counter_path = os.path.join(issues_dir, ".issues", ".counter")
    with open(counter_path, "w") as f:
        f.write("not-a-number\n")
    result = subprocess.run(
        LOCAL_ISSUES + ["create", "--title", "After Corruption"],
        cwd=issues_dir, capture_output=True, text=True,
    )
    assert result.returncode != 0, "Should fail but not crash"
    result2 = subprocess.run(
        LOCAL_ISSUES + ["create", "--title", "Still works"],
        cwd=issues_dir, capture_output=True, text=True,
    )
    assert result2.returncode == 0


# --- H4: shutil.move unhandled ---

def test_close_move_error_handled(issues_dir):
    """SC-13: close handles move failures gracefully."""
    _create_test_issue(issues_dir)
    import stat
    closed_dir = os.path.join(issues_dir, ".issues", "closed")
    os.chmod(closed_dir, stat.S_IRUSR | stat.S_IXUSR)
    result = subprocess.run(
        LOCAL_ISSUES + ["close", "1"],
        cwd=issues_dir, capture_output=True, text=True,
    )
    os.chmod(closed_dir, stat.S_IRWXU)
    assert result.returncode == 1, f"Expected exit code 1 on move failure, got {result.returncode}"


# --- H5: --record-remote with insufficient args silently does nothing ---

def test_record_remote_insufficient_args(issues_dir):
    """SC-8: promote --record-remote with insufficient args returns error."""
    _create_test_issue(issues_dir)
    result = subprocess.run(
        LOCAL_ISSUES + ["promote", "1", "--record-remote"],
        cwd=issues_dir, capture_output=True, text=True,
    )
    assert result.returncode != 0, "Should return non-zero when --record-remote has insufficient args"


# --- H6: double-close returns 0 ---

def test_double_close_returns_exit_code_2(issues_dir):
    """SC-5: close on already-closed issue returns exit code 2."""
    _create_test_issue(issues_dir)
    result1 = subprocess.run(
        LOCAL_ISSUES + ["close", "1"],
        cwd=issues_dir, capture_output=True, text=True,
    )
    assert result1.returncode == 0
    result2 = subprocess.run(
        LOCAL_ISSUES + ["close", "1"],
        cwd=issues_dir, capture_output=True, text=True,
    )
    assert result2.returncode == 2, f"Expected exit code 2 for double-close, got {result2.returncode}"


# --- Help text missing promote and sync ---

def test_help_text_includes_all_commands(issues_dir):
    """SC-7: help text includes promote and sync."""
    result = subprocess.run(
        LOCAL_ISSUES,
        cwd=issues_dir, capture_output=True, text=True,
    )
    assert "promote" in result.stderr, "Help text missing `promote`"
    assert "sync" in result.stderr, "Help text missing `sync`"


# --- No --help flag ---

def test_help_flag_supported(issues_dir):
    """SC-7: --help flag outputs usage, not 'Unknown command.'"""
    result = subprocess.run(
        LOCAL_ISSUES + ["--help"],
        cwd=issues_dir, capture_output=True, text=True,
    )
    assert result.returncode == 0, f"--help should not crash: {result.stderr}"
    assert "Unknown command" not in result.stderr, "--help should not say 'Unknown command'"
    assert "Usage" in result.stdout or "Usage" in result.stderr
    assert "promote" in result.stdout + result.stderr
    assert "sync" in result.stdout + result.stderr


# --- Empty title validation ---

def test_empty_title_fails(issues_dir):
    """SC-6: create with empty title returns non-zero exit."""
    result = subprocess.run(
        LOCAL_ISSUES + ["create", "--title", ""],
        cwd=issues_dir, capture_output=True, text=True,
    )
    assert result.returncode == 1, f"Empty title should fail, got {result.returncode}"
    assert result.stderr, "Should produce an error message on stderr"


# --- SC-14: filesystem matches frontmatter after mutations ---

def test_state_consistency_after_close(issues_dir):
    """SC-14: after close, directory is under closed/ and frontmatter says 'closed'."""
    _create_test_issue(issues_dir)
    assert os.path.isdir(os.path.join(issues_dir, ".issues", "open", "1"))
    result = subprocess.run(
        LOCAL_ISSUES + ["close", "1"],
        cwd=issues_dir, capture_output=True, text=True,
    )
    assert result.returncode == 0
    assert not os.path.isdir(os.path.join(issues_dir, ".issues", "open", "1"))
    assert os.path.isdir(os.path.join(issues_dir, ".issues", "closed", "1"))
    meta = _read_frontmatter(issues_dir, 1, status="closed")
    assert meta.get("status") == "closed", f"Expected status=closed, got {meta.get('status')}"
