# :js — notes for later

Snapshot from 2026-11-18 (v0.2.0). This is a working list toward a "production grade" 1.0, most important first.

## State

- :py's JavaScript/TypeScript sibling for Node ≥ 20.12. Plain ES modules with no build step. About 7,800 lines in `src/`, about 1,600 lines of tests (`node --test`). CI runs Ubuntu and macOS on Node 20, 22 and 24 with tmux for terminal tests, `node --check` and a docs-are-current check.
- Only 2 runtime dependencies (acorn, acorn-walk). Excellent.
- Docs: features, configuration, magics (generated), releasing.
- Tests weren't run in this review (no `node_modules` locally). Run `npm ci && npm test` to get a baseline.
- `Dockerfile` and `.dockerignore` exist. Document what they're for (a test runner or a distribution image).

## 1. Code quality

- [ ] **No linter or type checking.** CI only runs `node --check` (syntax). Add ESLint and Prettier, and type-check the JS with `tsc --checkJs` plus JSDoc types (no build step needed), or move to TypeScript.
- [ ] 54 `catch {` blocks in `src/`. Review which ones swallow errors silently, and log them in debug mode.
- [ ] Add coverage (`node --test --experimental-test-coverage` or c8) with a threshold.
- [ ] Node 20 reached end of life in April 2026. Decide whether to drop it (raise `engines` to ≥ 22) or keep testing it. Add Node 25 or the current release as a non-blocking job.

## 2. Diagnosability

- [ ] Add `--debug` / `JS_TERM_LOG`, a crash report file and `:js --doctor` (Node version, TypeScript support available, terminal capabilities).
- [ ] Make sure a crash inside :js's own UI never loses the user's session state or history.

## 3. Product

- [ ] TypeScript: document what is supported (type stripping vs a full type check), and which Node version is needed for native type stripping.
- [ ] ESM and CommonJS `require` interop at the prompt, top-level `await` and `import()` of local files: check edge cases and document them.
- [ ] A "Known limits" section in the README, as in :py.

## 4. Releases and distribution

- [ ] Tag-triggered release workflow (test, `npm pack` tarball attached to the release, notes from CHANGELOG).
- [ ] `install.sh` should default to the latest tag, not `main`. Publish checksums.
- [ ] Add Dependabot for npm and Actions.

## 5. Project hygiene

- [ ] Add CONTRIBUTING.md, SECURITY.md, issue and PR templates.
- [ ] Write a stability policy for magics, config keys and CLI flags before 1.0.

## Shared with the family

The pitch palette is copied into each repo, and the release, installer, logging and `--doctor` work is the same across all of them. Solve it once in :py and port it here.
