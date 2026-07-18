# DeploymentSteps

Deployment procedure for releasing a new version.

1. Run all tests: `uv run pytest test/`
2. Build the package: `uv build`
3. Publish to registry: `uv publish`
4. Tag the release: `git tag v$(uv run python -m setuptools_scm)`
5. Push tags: `git push --tags`
6. Verify deployment: check package page for new version
