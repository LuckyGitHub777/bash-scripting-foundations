#!/usr/bin/env bash
# file-owner.sh - Check whether the current user owns a file.

set -euo pipefail
IFS=$'\n\t'

usage() {
  printf 'Usage: %s PATH\n' "$0"
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    return 0
  fi

  local target="${1:-}"
  if [[ -z "$target" ]]; then
    usage >&2
    return 1
  fi

  if [[ ! -e "$target" ]]; then
    printf 'Path not found: %s\n' "$target" >&2
    return 1
  fi

  local current_user owner
  current_user="$(id -un)"

  if owner="$(stat -c '%U' "$target" 2>/dev/null)"; then
    :
  else
    owner="$(stat -f '%Su' "$target" 2>/dev/null)"
  fi

  printf 'Current user: %s\n' "$current_user"
  printf 'File owner:   %s\n' "$owner"

  if [[ "$current_user" == "$owner" ]]; then
    printf 'Result: current user owns this path.\n'
  else
    printf 'Result: current user does not own this path.\n'
  fi
}

main "$@"
