# Changelog

All notable changes to this project will be documented in this file.

Please choose versions by [Semantic Versioning](http://semver.org/).

* MAJOR version when you make incompatible API changes,
* MINOR version when you add functionality in a backwards-compatible manner, and
* PATCH version when you make backwards-compatible bug fixes.

## v0.1.0
- Add OpenClaw Docker image with Node.js, Claude Code, Codex CLI, and Gemini CLI
- Add Go 1.26.1 toolchain and security tools (govulncheck, gosec, osv-scanner)
- Add Google Cloud CLI, kubectl, Helm, and Trivy
- Add docker-compose support with auto-restart and auto-build
- Add CI workflow with precommit/test/check Makefile targets
- Add multi-arch support for amd64 and arm64
- Derive VERSION from git tags instead of hardcoded value
