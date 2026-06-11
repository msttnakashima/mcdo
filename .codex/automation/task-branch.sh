#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: task-branch.sh [-p type] [-s scope] -t short-message [-b base]

Creates or switches to one branch for a main task.
Branch format: type/scope/short-message, or type/short-message when scope is omitted.
USAGE
}

type="chore"
scope=""
short=""
base="main"

while getopts ":p:s:t:b:h" opt; do
  case "$opt" in
    p) type="$OPTARG" ;;
    s) scope="$OPTARG" ;;
    t) short="$OPTARG" ;;
    b) base="$OPTARG" ;;
    h) usage; exit 0 ;;
    :) echo "Missing value for -$OPTARG" >&2; usage; exit 2 ;;
    \?) echo "Unknown option: -$OPTARG" >&2; usage; exit 2 ;;
  esac
done

if [ -z "$short" ]; then
  echo "Missing required -t short-message" >&2
  usage
  exit 2
fi

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "Not inside a Git repository checkout." >&2
  exit 1
}

slugify() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

type_slug="$(slugify "$type")"
scope_slug="$(slugify "$scope")"
short_slug="$(slugify "$short")"

if [ -z "$type_slug" ] || [ -z "$short_slug" ]; then
  echo "Type and short message must contain at least one alphanumeric character." >&2
  exit 2
fi

if [ -n "$scope_slug" ]; then
  branch="${type_slug}/${scope_slug}/${short_slug}"
else
  branch="${type_slug}/${short_slug}"
fi

if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  current="$(git symbolic-ref --quiet --short HEAD || true)"
  if [ "$current" != "$base" ]; then
    git symbolic-ref HEAD "refs/heads/$base"
  fi
  echo "Repository has no commits. Create the first commit on '$base' before creating task branch '$branch'." >&2
  exit 1
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Refusing to switch branches with uncommitted changes." >&2
  exit 1
fi

remote=""
if git remote get-url origin >/dev/null 2>&1; then
  remote="origin"
fi

base_ref=""
if git show-ref --verify --quiet "refs/heads/$base"; then
  base_ref="$base"
elif [ -n "$remote" ] && git ls-remote --exit-code --heads "$remote" "$base" >/dev/null 2>&1; then
  git fetch "$remote" "$base"
  base_ref="$remote/$base"
else
  echo "Base branch '$base' does not exist locally or on origin. Refusing to create it from a task branch." >&2
  exit 1
fi

if git show-ref --verify --quiet "refs/heads/$branch"; then
  git switch "$branch"
elif [ -n "$remote" ] && git ls-remote --exit-code --heads "$remote" "$branch" >/dev/null 2>&1; then
  git fetch "$remote" "$branch"
  git switch --track -c "$branch" "$remote/$branch"
else
  git switch -c "$branch" "$base_ref"
fi

echo "$branch"
