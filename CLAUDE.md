# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

gitfs-builder is a Debian package builder for gitfs, a FUSE filesystem that integrates with Git. This project creates distributable Debian packages for gitfs and its dependencies across multiple Ubuntu distributions. Built for Python 3.11+.

## Build Commands

**Primary build process:**
```bash
make build           # Full build - downloads deps, builds packages
make clean          # Clean build artifacts
make prepare        # Prepare dependencies without building gitfs
```

**Build targets:**
- Default target directory: `/target/build` (local), `/drone/gitfs/build` (CI)
- Built packages are placed in the build directory

## Architecture

This is a **packaging project**, not a traditional software development codebase. Key components:

- **VERSIONS file**: Centralized version management for all dependencies
- **Makefile**: Complex build orchestration with CI/CD integration
- **debian-*/ directories**: Debian packaging configurations for each component
- **Patches**: Applied during build (0001-fix-install-path.diff, 0002-pex-local-archive.diff)

## Dependencies Built

1. **libgit2** (v1.6.0) - Git library with C bindings
2. **python3-pex** (v1.6.12) - Python 3.11+ executable packaging
3. **Python packages**: atomiclong (v0.1.1), cffi (v1.15.1+), fusepy (v3.0.1), pycparser (v2.21+), pygit2 (v1.12.2+), sentry-sdk (v1.32.0+)
4. **gitfs** (v0.5.2) - Main FUSE filesystem package (Python 3.11+)

## CI/CD Integration

- Uses GitHub Actions for CI/CD
- Builds across Ubuntu 18.04-20.04 distributions
- Automatic version stamping based on git tags/branches
- PGP signing for package integrity
- Publishes to ppa:vladtemian/gitfs PPA repository

## Version Management

All versions are centrally managed in the `VERSIONS` file. When updating dependencies:
1. Update version numbers in VERSIONS
2. Update corresponding URLs if needed
3. Test build across target distributions

## Build Environment Detection

The Makefile automatically detects CI environments and adjusts:
- Build paths (GitHub Actions vs local)
- Version numbering schemes
- Distribution targeting

## Git Workflow

**Branch Strategy:**
- Create feature branches for all changes: `git checkout -b feature/description`
- Never work directly on master branch

**Commit Guidelines:**
- Commit and push frequently to avoid losing work
- Use conventional commits format:
  - `feat: add new dependency version`
  - `fix: correct build path detection`
  - `chore: update package versions`
  - `ci: modify drone configuration`
  - `docs: update build instructions`

**Example workflow:**
```bash
git checkout -b feat/update-libgit2-version
# Make changes
git add .
git commit -m "feat: update libgit2 to v0.28.4"
git push -u origin feat/update-libgit2-version
# Continue with frequent commits
git commit -m "fix: adjust patch for new libgit2 version"
git push
```