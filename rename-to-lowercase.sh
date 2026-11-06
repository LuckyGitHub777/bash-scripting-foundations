#!/usr/bin/env bash
# rename-to-lowercase.sh - Rename files in a directory to lowercase, safely.

set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<'EOF'
Usage: ./rename-to-lowercase.sh [DIRECTORY] [--apply]

Default is dry-run. Use --apply to rename files.
EOF
}

main() {
  local directory="."
  local apply=0

  for arg in "$@"; do
    case "$arg" in
      -h|--help)
        usage
        return 0
        ;;
      --apply)
        apply=1
        ;;
      *)
        directory="$arg"
        ;;
    esac
  done

  if [[ ! -d "$directory" ]]; then
    printf 'Directory not found: %s\n' "$directory" >&2
    return 1
  fi

  shopt -s nullglob

  local file base lower target
  for file in "$directory"/*; do
    [[ -f "$file" ]] || continue

    base="$(basename "$file")"
    lower="$(printf '%s' "$base" | tr '[:upper:]' '[:lower:]')"
    target="$(dirname "$file")/$lower"

    if [[ "$file" == "$target" ]]; then
      continue
    fi

    if [[ -e "$target" || -L "$target" ]]; then
      printf 'Skipping collision: %s -> %s\n' "$file" "$target" >&2
      continue
    fi

    if [[ "$apply" -eq 1 ]]; then
      mv -- "$file" "$target"
      printf 'Renamed: %s -> %s\n' "$file" "$target"
    else
      printf 'Would rename: %s -> %s\n' "$file" "$target"
    fi
  done

  if [[ "$apply" -eq 0 ]]; then
    printf 'Dry run complete. Re-run with --apply to rename files.\n'
  fi
}

main "$@"
