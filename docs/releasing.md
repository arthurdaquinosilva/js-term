# Releasing

cinder is published only on GitHub — it isn't on npm. People install it with `install.sh`, which downloads the source archive of a branch or tag from GitHub and runs `npm ci --omit=dev` in it.

## Each release

1. Update `version` in `package.json` and add a section to `CHANGELOG.md`.
2. Run the checks:
   ```sh
   npm test
   npm run docs:check
   ```
3. Commit, tag and push: `git tag v0.1.0 && git push --tags`.
4. Create a GitHub release from the tag.

The tag is what `install.sh` installs when asked for it:

```sh
curl -fsSL https://raw.githubusercontent.com/arthurdaquinosilva/cinder/main/install.sh | CINDER_VERSION=v0.1.0 sh
```

`install.sh` is served straight from `main` and installs `main` unless `CINDER_VERSION` is set, so it needs no change per release.
