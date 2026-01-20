#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
prefix="${1:-$HOME/.local}"
bindir="$prefix/bin"
hooks_dir="${XDG_CONFIG_HOME:-$HOME/.config}/git/hooks"
hook_path="$hooks_dir/commit-msg"
binary_path="$bindir/kamkanam"
force_override="${KAMKANAM_FORCE:-}"

if [[ -f "$binary_path" ]]; then
  rm -f "$binary_path"
  echo "removed $binary_path"
else
  echo "kamkanam binary not found at $binary_path"
fi

if [[ -f "$hook_path" ]]; then
  if [[ -f "$root_dir/hooks/commit-msg" ]] && cmp -s "$hook_path" "$root_dir/hooks/commit-msg"; then
    rm -f "$hook_path"
    echo "removed $hook_path"
  elif [[ "$force_override" == "1" ]]; then
    rm -f "$hook_path"
    echo "removed $hook_path (forced)"
  else
    echo "kamkanam: commit-msg hook at $hook_path does not match; leaving it in place." >&2
    echo "kamkanam: set KAMKANAM_FORCE=1 to remove it anyway." >&2
  fi
else
  echo "commit-msg hook not found at $hook_path"
fi

current_hooks_path="$(git config --global --get core.hooksPath || true)"
if [[ "$current_hooks_path" == "$hooks_dir" ]]; then
  if [[ "$force_override" == "1" ]]; then
    git config --global --unset core.hooksPath || true
    echo "core.hooksPath unset (forced)"
  else
    hook_present=0
    if [[ -f "$hook_path" ]]; then
      hook_present=1
    fi
    other_hooks=""
    if [[ -d "$hooks_dir" ]]; then
      other_hooks="$(find "$hooks_dir" -maxdepth 1 -type f ! -name 'commit-msg' -print -quit 2>/dev/null || true)"
    fi
    if [[ "$hook_present" -eq 1 ]]; then
      echo "core.hooksPath left as $hooks_dir (commit-msg hook still present)"
    elif [[ -n "$other_hooks" ]]; then
      echo "core.hooksPath left as $hooks_dir (other hooks present)"
    else
      git config --global --unset core.hooksPath || true
      echo "core.hooksPath unset"
    fi
  fi
elif [[ -n "$current_hooks_path" ]]; then
  echo "core.hooksPath left as $current_hooks_path"
fi

if [[ -d "$hooks_dir" ]]; then
  if [[ -z "$(ls -A "$hooks_dir" 2>/dev/null)" ]]; then
    rmdir "$hooks_dir" || true
  fi
fi
