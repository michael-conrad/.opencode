# Default model for all opencode test runs.
# Override: DEFAULT_TEST_MODEL=custom-model
# Single source of truth — do not embed model strings elsewhere.
DEFAULT_TEST_MODEL="${DEFAULT_TEST_MODEL:-ollama/qwen3.8:27b-256k-gguf4}"
