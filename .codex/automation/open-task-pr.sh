#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: open-task-pr.sh [-b base] [-t title] [-F body-file]

Creates a GitHub PR for the current branch. Falls back to gh pr create --fill when no body file is supplied.
Skips cleanly when gh, authentication, or a GitHub remote is unavailable.
USAGE
}

base="main"
title=""
body_file=""

while getopts ":b:t:F:h" opt; do
  case "$opt" in
    b) base="$OPTARG" ;;
    t) title="$OPTARG" ;;
    F) body_file="$OPTARG" ;;
    h) usage; exit 0 ;;
    :) echo "Missing value for -$OPTARG" >&2; usage; exit 2 ;;
    \?) echo "Unknown option: -$OPTARG" >&2; usage; exit 2 ;;
  esac
done

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "Not inside a Git repository checkout." >&2
  exit 1
}

if ! command -v gh >/dev/null 2>&1; then
  echo "gh is not installed; PR creation skipped."
  exit 0
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "gh is not authenticated; PR creation skipped."
  exit 0
fi

current_branch="$(git symbolic-ref --quiet --short HEAD || true)"
if [ -z "$current_branch" ]; then
  echo "Detached HEAD; PR creation skipped." >&2
  exit 0
fi

if [ "$current_branch" = "$base" ]; then
  echo "Current branch is '$base'; refusing to create a PR from the base branch." >&2
  exit 1
fi

if [ -n "$body_file" ] && [ ! -f "$body_file" ]; then
  echo "PR body file not found: $body_file" >&2
  exit 1
fi

remote="origin"
remote_url="$(git remote get-url "$remote" 2>/dev/null || true)"
if ! printf '%s\n' "$remote_url" | grep -Eq 'github.com[:/]'; then
  echo "No GitHub-hosted origin remote; PR creation skipped."
  exit 0
fi

repo="$(printf '%s\n' "$remote_url" | sed -E 's#^git@github.com:##; s#^https://github.com/##; s#\\.git$##')"

if ! git ls-remote --exit-code --heads "$remote" "$base" >/dev/null 2>&1; then
  if git show-ref --verify --quiet "refs/heads/$base"; then
    git push "$remote" "$base:$base"
  else
    echo "Remote base '$base' is missing and no local '$base' exists. Refusing to create it from current branch." >&2
    exit 1
  fi
fi

if ! git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
  git push -u "$remote" "$current_branch"
fi

existing_pr="$(gh pr list --repo "$repo" --head "$current_branch" --json number --jq '.[0].number // empty')"
if [ -n "$existing_pr" ]; then
  echo "PR #$existing_pr already exists for $current_branch."
  exit 0
fi

derive_title() {
  branch="$1"
  IFS='/' read -r part1 part2 part3 extra <<EOF_TITLE
$branch
EOF_TITLE
  if [ -n "${extra:-}" ]; then
    msg="$(printf '%s %s' "$part3" "$extra" | tr '-' ' ')"
    printf '%s(%s): %s' "$part1" "$part2" "$msg"
  elif [ -n "${part3:-}" ]; then
    msg="$(printf '%s' "$part3" | tr '-' ' ')"
    printf '%s(%s): %s' "$part1" "$part2" "$msg"
  elif [ -n "${part2:-}" ]; then
    msg="$(printf '%s' "$part2" | tr '-' ' ')"
    printf '%s: %s' "$part1" "$msg"
  else
    printf '%s' "$branch"
  fi
}

if [ -z "$title" ]; then
  title="$(derive_title "$current_branch")"
fi

if [ -n "$body_file" ]; then
  gh pr create --repo "$repo" --base "$base" --head "$current_branch" --title "$title" --body-file "$body_file"
else
  gh pr create --repo "$repo" --base "$base" --head "$current_branch" --title "$title" --fill
fi
