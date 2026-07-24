"""Shared fixtures for .opencode/tools/ unit tests."""
from unittest.mock import patch

import pytest


@pytest.fixture
def mock_subprocess_run():
    with patch("session_init.auth.subprocess.run") as mock:
        yield mock


@pytest.fixture
def mock_shutil_which():
    with patch("session_init.auth.shutil.which") as mock:
        yield mock
