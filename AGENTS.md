# Repository Guidelines

## Project Structure & Modules
- `Makefile`: Orchestrates fetching sources, preparing Debian dirs, and building source packages.
- `VERSIONS`: Central place for upstream versions and download URLs.
- `debian-gitfs/`, `debian-libgit2/`, `debian-python-pex/`: Debian packaging for each component (rules, control, patches).
- `.github/workflows/build.yml`: CI to build for Ubuntu series and upload artifacts/PPAs.
- Output: `build/` in CI (`/github/workspace/build`), `/target/build` locally unless `TARGET` is overridden.

## Build, Test, and Develop
- `make build`: Fetches sources, stages Debian packaging, and creates source packages via `debuild`.
- `make clean`: Removes the build directory.
- Local example: `DEBEMAIL="you@example.com" DEBFULLNAME="Your Name" TARGET=$PWD/build make build` then check `build/`.
- Requirements (locally): `devscripts build-essential lintian dput-ng lsb-release wget` and, for pex, Python headers (e.g., `python3-dev`).
- Full binary/test build per package (optional): inside `build/<pkg>-<ver>/` run `debuild -b` to execute `dh_auto_test` rules (e.g., libgit2).

## Coding Style & Naming
- Makefiles: tabs for recipes; variables in `UPPER_SNAKE_CASE`; keep targets small and composable.
- Debian packaging: follow dh conventions; keep `debian/rules` minimal; name folders `debian-<package>`.
- YAML: 2-space indents in GitHub Actions; keep job steps explicit and reproducible.
- Version bumps: update `VERSIONS`; avoid inlining versions in rules.

## Testing Guidelines
- Tests primarily run via `dh_auto_test` in package rules (enabled for libgit2, disabled for gitfs).
- To run locally: `debuild -b` in a prepared package dir or trigger CI with a PR to run the matrix builds.
- Keep changes lintian-clean; review `*.build`/`*.changes` logs in `build/`.

## Commit & PR Guidelines
- Commits: short, imperative, and scoped (e.g., "Bump gitfs to 0.5.2", "Use python3-sphinx to build the pex"). Link PR numbers when relevant.
- PRs: describe intent and affected packages, include rationale for version or rules changes, and update `VERSIONS` as needed. CI must pass; attach build artifacts or logs if reproducing locally.

## Security & Publishing
- Never commit secrets. Import PGP keys via GitHub Secrets (`PGP_KEY`) for CI signing.
- PPA deploys on `master` push per workflow; verify changelogs and signatures before merging.
