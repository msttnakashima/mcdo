#!/usr/bin/env bash
set -euo pipefail

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

if [ "${ALLOW_CODEX_WORKFLOW_COMMIT:-}" = "1" ]; then
  exit 0
fi

blocked=()
while IFS=$'\t' read -r status path rest; do
  [ -n "${path:-}" ] || continue
  case "$status" in
    D|D*) continue ;;
  esac
  blocked+=("$status $path")
done < <(git diff --cached --name-status -- .codex specs AGENTS.md CODEX.md)

if [ "${#blocked[@]}" -gt 0 ]; then
  cat >&2 <<'MSG'
Refusing to commit local Codex workflow/spec files.

Set ALLOW_CODEX_WORKFLOW_COMMIT=1 to commit them intentionally.
Deletions are allowed so tracked workflow/spec files can be cleaned up.
MSG
  printf '%s\n' "${blocked[@]}" >&2
  exit 1
fi
