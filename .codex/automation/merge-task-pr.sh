#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: merge-task-pr.sh --tl-approved [-b base]

Merges the current branch PR after local TL/main approval.
Uses GitHub merge commits and deletes the remote task branch.
Skips cleanly when gh, authentication, GitHub remote, or a current-branch PR is unavailable.
USAGE
}

base="main"
approved=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --tl-approved)
      approved=1
      ;;
    -b|--base)
      shift
      [ "$#" -gt 0 ] || { echo "Missing base branch." >&2; exit 2; }
      base="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
  shift
done

if [ "$approved" -ne 1 ]; then
  echo "Missing required --tl-approved flag." >&2
  exit 2
fi

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "Not inside a Git repository checkout." >&2
  exit 1
}

if ! command -v gh >/dev/null 2>&1; then
  echo "gh is not installed; PR merge skipped."
  exit 0
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "gh is not authenticated; PR merge skipped."
  exit 0
fi

branch="$(git symbolic-ref --quiet --short HEAD || true)"
if [ -z "$branch" ]; then
  echo "Detached HEAD; PR merge skipped." >&2
  exit 0
fi

remote="origin"
remote_url="$(git remote get-url "$remote" 2>/dev/null || true)"
if ! printf '%s\n' "$remote_url" | grep -Eq 'github.com[:/]'; then
  echo "No GitHub-hosted origin remote; PR merge skipped."
  exit 0
fi

repo="$(printf '%s\n' "$remote_url" | sed -E 's#^git@github.com:##; s#^https://github.com/##; s#\\.git$##')"
pr_number="$(gh pr list --repo "$repo" --head "$branch" --json number --jq '.[0].number // empty')"

if [ -z "$pr_number" ]; then
  echo "No PR exists for $branch; PR merge skipped."
  exit 0
fi

gh pr merge "$pr_number" --repo "$repo" --merge --delete-branch

git fetch "$remote" "$base" || true
if git show-ref --verify --quiet "refs/remotes/$remote/$base"; then
  git switch -C "$base" "$remote/$base"
elif git show-ref --verify --quiet "refs/heads/$base"; then
  git switch "$base"
fi

if git show-ref --verify --quiet "refs/heads/$branch"; then
  git branch -d "$branch" || true
fi
