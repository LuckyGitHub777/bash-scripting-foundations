#!/usr/bin/env bash
# number-sequence-generator.sh - Print a simple number sequence.

set -euo pipefail
IFS=$'\n\t'

usage() {
  printf 'Usage: %s START END [STEP]\n' "$0"
  printf 'Example: %s 1 10 2\n' "$0"
}

is_integer() {
  [[ "$1" =~ ^-?[0-9]+$ ]]
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    return 0
  fi

  local start="${1:-1}"
  local end="${2:-10}"
  local step="${3:-1}"

  if ! is_integer "$start" || ! is_integer "$end" || ! is_integer "$step"; then
    printf 'START, END, and STEP must be integers.\n' >&2
    return 1
  fi

  if [[ "$step" -eq 0 ]]; then
    printf 'STEP cannot be zero.\n' >&2
    return 1
  fi

  seq "$start" "$step" "$end"
}

main "$@"
