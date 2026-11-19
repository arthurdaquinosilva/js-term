#!/bin/sh
# Installs :js straight from GitHub — no npm registry involved:
#
#   curl -fsSL https://raw.githubusercontent.com/arthurdaquinosilva/js-term/main/install.sh | sh
#
# Environment overrides:
#   JS_TERM_VERSION   branch or tag to install (default: main), e.g. JS_TERM_VERSION=v0.2.0
#   JS_TERM_HOME      where the source lives   (default: ~/.local/lib/js-term)
#   JS_TERM_BIN_DIR   where the command goes   (default: ~/.local/bin)
#
# Pass --uninstall to remove it:  curl -fsSL .../install.sh | sh -s -- --uninstall
#
# The launcher uses `#!/usr/bin/env node`, so it runs on whichever Node is on PATH — switching nvm
# versions keeps the command available (as long as that Node is 20.12+).

set -eu

REPO="arthurdaquinosilva/js-term"
VERSION="${JS_TERM_VERSION:-main}"
# Not ~/.local/share/js-term: that is :js's own data dir (history), which updates must never touch.
HOME_DIR="${JS_TERM_HOME:-$HOME/.local/lib/js-term}"
COMMANDS=":js js-term"
BIN_DIR="${JS_TERM_BIN_DIR:-$HOME/.local/bin}"
MIN_NODE="20.12"

say() { printf '%s\n' "$*"; }
err() { printf ':js install: %s\n' "$*" >&2; exit 1; }
has() { command -v "$1" >/dev/null 2>&1; }

# Succeeds when version $1 >= version $2 (major.minor only).
version_ge() {
  a_major=${1%%.*}; a_rest=${1#*.}; a_minor=${a_rest%%.*}
  b_major=${2%%.*}; b_minor=${2#*.}
  [ "$a_major" -gt "$b_major" ] || { [ "$a_major" -eq "$b_major" ] && [ "$a_minor" -ge "$b_minor" ]; }
}

uninstall() {
  for cmd in $COMMANDS; do rm -f "$BIN_DIR/$cmd"; done
  rm -rf "$HOME_DIR"
  say "Removed :js ($HOME_DIR and its commands in $BIN_DIR)."
  say "Your history and config (~/.local/share/js-term, ~/.config/js-term) were left in place."
}

# :js used to be called cinder: remove that installation, keep its history (:js copies it over).
remove_old_install() {
  old_home="$HOME/.local/lib/cinder"
  if [ -L "$BIN_DIR/cinder" ] && [ "$(readlink "$BIN_DIR/cinder")" = "$old_home/bin/cinder.js" ]; then
    rm -f "$BIN_DIR/cinder"
  fi
  if [ -d "$old_home" ]; then
    rm -rf "$old_home"
    say "Removed the old cinder installation ($old_home)."
  fi
}

download() {
  if has curl; then curl -fsSL "$1"
  elif has wget; then wget -qO- "$1"
  else err "needs curl or wget to download :js"
  fi
}

main() {
  if [ "${1:-}" = "--uninstall" ]; then uninstall; return; fi

  has node || err "Node.js $MIN_NODE or newer is required (https://nodejs.org or nvm)"
  has npm || err "npm is required to install :js's dependencies"
  has tar || err "tar is required"
  node_version=$(node -p 'process.versions.node')
  version_ge "$node_version" "$MIN_NODE" || err "Node $node_version is too old; :js needs $MIN_NODE or newer"

  case "$VERSION" in
    v[0-9]*) ref="refs/tags/$VERSION" ;;
    *) ref="refs/heads/$VERSION" ;;
  esac
  url="https://github.com/$REPO/archive/$ref.tar.gz"

  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT INT TERM

  say "Downloading :js ($VERSION)..."
  download "$url" | tar -xz -C "$tmp" --strip-components=1 || err "could not download $url"
  [ -f "$tmp/bin/js-term.js" ] || err "the download does not look like :js ($url)"

  say "Installing dependencies..."
  (cd "$tmp" && npm ci --omit=dev --no-audit --no-fund --loglevel=error >/dev/null) ||
    err "npm could not install :js's dependencies"

  # Swap the new copy in only once it is complete, so a failed update leaves the old one working.
  mkdir -p "$(dirname "$HOME_DIR")" "$BIN_DIR"
  rm -rf "$HOME_DIR.old"
  [ -d "$HOME_DIR" ] && mv "$HOME_DIR" "$HOME_DIR.old"
  mv "$tmp" "$HOME_DIR"
  rm -rf "$HOME_DIR.old"
  trap - EXIT INT TERM
  chmod +x "$HOME_DIR/bin/js-term.js"
  for cmd in $COMMANDS; do ln -sf "$HOME_DIR/bin/js-term.js" "$BIN_DIR/$cmd"; done
  remove_old_install

  say "Installed $("$BIN_DIR/:js" --version) to $BIN_DIR/:js"

  case ":$PATH:" in
    *":$BIN_DIR:"*)
      found=$(command -v :js)
      [ "$found" = "$BIN_DIR/:js" ] ||
        say "Note: another :js comes first on PATH ($found); remove it with 'npm uninstall -g js-term' or 'npm unlink -g js-term'."
      ;;
    *)
      say ""
      say "$BIN_DIR is not on your PATH. Add it to your shell profile (~/.zshrc or ~/.bashrc):"
      say "  export PATH=\"$BIN_DIR:\$PATH\""
      ;;
  esac
  say "Run ':js' to start, ':js --vi' for vi keys. Re-run this installer to update."
}

main "$@"
