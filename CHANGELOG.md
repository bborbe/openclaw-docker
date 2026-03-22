# Changelog

All notable changes to this project will be documented in this file.

Please choose versions by [Semantic Versioning](http://semver.org/).

* MAJOR version when you make incompatible API changes,
* MINOR version when you add functionality in a backwards-compatible manner, and
* PATCH version when you make backwards-compatible bug fixes.

## v0.3.0
- Separate entrypoint (prepare) from CMD (supervisord start)
- Move entrypoint.sh and supervisord.conf to files/ directory
- Make openclaw gateway args configurable via OPENCLAW_ARGS env var
- Add docker-compose profiles: secure (default) and lan (--allow-unconfigured --bind lan)
- Fix shellcheck path in Makefile after files/ move

## v0.2.0
- Add optional supervisord drop-in helper config pattern for sidecar processes
- Add procps package for ps and pgrep utilities
- Add supervisord examples (git-ai-sync, task-watcher)

## v0.1.1
- Separate OPENCLAW_VERSION from VERSION to fix Docker build with git tags

## v0.1.0
- Add OpenClaw Docker image with Node.js, Claude Code, Codex CLI, and Gemini CLI
- Add Go 1.26.1 toolchain and security tools (govulncheck, gosec, osv-scanner)
- Add Google Cloud CLI, kubectl, Helm, and Trivy
- Add docker-compose support with auto-restart and auto-build
- Add CI workflow with precommit/test/check Makefile targets
- Add multi-arch support for amd64 and arm64
- Derive VERSION from git tags instead of hardcoded value
