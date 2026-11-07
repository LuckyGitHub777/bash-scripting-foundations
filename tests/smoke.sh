#!/usr/bin/env bash
# Offline, unprivileged smoke checks. All write tests use a throwaway directory.
set -euo pipefail
IFS=$'\n\t'
cd "$(dirname "$0")/.."

for script in file-owner.sh number-sequence-generator.sh rename-to-lowercase.sh; do
  bash -n "$script"
done
sha256sum -c MANIFEST.sha256

temporary="$(mktemp -d)"
trap 'rm -rf -- "$temporary"' EXIT

mkdir -p "$temporary/dryrun" "$temporary/collision" "$temporary/aliases"
printf 'safe\n' > "$temporary/dryrun/MiXeD.TXT"

dry_output="$(bash rename-to-lowercase.sh "$temporary/dryrun")"
[[ "$dry_output" == *"Would rename:"* ]]
[[ -f "$temporary/dryrun/MiXeD.TXT" ]]
[[ ! -e "$temporary/dryrun/mixed.txt" ]]

bash rename-to-lowercase.sh "$temporary/dryrun" --apply > /dev/null
[[ -f "$temporary/dryrun/mixed.txt" ]]
[[ ! -e "$temporary/dryrun/MiXeD.TXT" ]]

printf 'a\n' > "$temporary/collision/EXIST.txt"
printf 'b\n' > "$temporary/collision/exist.txt"
bash rename-to-lowercase.sh "$temporary/collision" --apply >/dev/null 2>&1
[[ -f "$temporary/collision/EXIST.txt" && -f "$temporary/collision/exist.txt" ]]

printf 'not in test scope\n' > "$temporary/outside.txt"
ln -s "$temporary/outside.txt" "$temporary/aliases/Linked.TXT"
alias_output="$(bash rename-to-lowercase.sh "$temporary/aliases" --apply 2>&1)"
[[ "$alias_output" == *"Skipping symlink:"* ]]
[[ -L "$temporary/aliases/Linked.TXT" ]]
[[ ! -e "$temporary/aliases/linked.txt" ]]

ln -s "$temporary/dryrun" "$temporary/linked-root"
if bash rename-to-lowercase.sh "$temporary/linked-root" --apply > /dev/null 2>&1; then
  echo "FAIL: accepted a symlinked directory" >&2
  exit 1
fi
[[ -f "$temporary/dryrun/mixed.txt" ]]

[[ "$(bash number-sequence-generator.sh 1 5 2)" == $'1\n3\n5' ]]
if bash number-sequence-generator.sh 1 5 0 > /dev/null 2>&1; then
  echo "FAIL: accepted a zero step" >&2
  exit 1
fi
if bash number-sequence-generator.sh invalid 5 1 > /dev/null 2>&1; then
  echo "FAIL: accepted invalid integer" >&2
  exit 1
fi

owner_output="$(bash file-owner.sh "$temporary/dryrun/mixed.txt")"
[[ "$owner_output" == *"Result: current user owns this path."* ]]
if bash file-owner.sh "$temporary/does-not-exist" > /dev/null 2>&1; then
  echo "FAIL: missing path accepted" >&2
  exit 1
fi

echo "PASS: all offline Bash safety, integrity and behavior tests"
