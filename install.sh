#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
prefix="${1:-$HOME/.local}"
bindir="$prefix/bin"
hooks_dir="${XDG_CONFIG_HOME:-$HOME/.config}/git/hooks"

mkdir -p "$bindir"
cp "$root_dir/cask" "$bindir/cask"
chmod 755 "$bindir/cask"

mkdir -p "$hooks_dir"
cp "$root_dir/hooks/commit-msg" "$hooks_dir/commit-msg"
chmod 755 "$hooks_dir/commit-msg"

existing_hooks_path="$(git config --global --get core.hooksPath || true)"
if [[ -n "$existing_hooks_path" && "$existing_hooks_path" != "$hooks_dir" ]]; then
  if [[ "${CASK_FORCE:-}" != "1" ]]; then
    echo "cask: core.hooksPath is already set to $existing_hooks_path" >&2
    echo "cask: set CASK_FORCE=1 to override, or install the hook manually." >&2
    exit 1
  fi
fi

git config --global core.hooksPath "$hooks_dir"

echo "cask installed to $bindir/cask"
echo "commit-msg hook installed to $hooks_dir/commit-msg"
echo "core.hooksPath set to $hooks_dir"
