"""Unit tests for session-init collect_issue_artifact_paths (issue 2447, SC-1)."""

import importlib.util
import os
from pathlib import Path
from importlib.machinery import SourceFileLoader

SESSION_INIT_PATH = Path(__file__).resolve().parents[2] / "tools" / "session-init"

_loader = SourceFileLoader("session_init_script", str(SESSION_INIT_PATH))
_spec = importlib.util.spec_from_loader("session_init_script", _loader)
assert _spec is not None
session_init_script = importlib.util.module_from_spec(_spec)
_loader.exec_module(session_init_script)

collect_issue_artifact_paths = session_init_script.collect_issue_artifact_paths


class TestCollectIssueArtifactPathsNoWorktreeHint:
    def test_no_worktree_setup_hint_when_issues_dir_absent(self, tmp_path, monkeypatch):
        monkeypatch.chdir(tmp_path)
        repo_info = [
            {
                "path": ".opencode",
                "owner": "o",
                "repo": "sub",
                "platform": "github.com",
                "url": "https://example.com/o/sub",
                "issues": ".opencode/.issues/",
            },
        ]
        assert not os.path.isdir(os.path.join(tmp_path, ".opencode", ".issues"))

        entries = collect_issue_artifact_paths(repo_info)
        emitted = "\n".join(entries)

        assert "create worktree from orphaned branch issues-data" not in emitted, (
            f"worktree-creation setup hint must not be emitted; got: {entries}"
        )
        assert "create worktree" not in emitted, f"setup hint leaked: {entries}"
