# Default model for all opencode-cli test runs.
# Override: DEFAULT_TEST_MODEL=custom-model
# Single source of truth — do not embed model strings elsewhere.
DEFAULT_TEST_MODEL="${DEFAULT_TEST_MODEL:-ollama/ornith:35b-256k}"
