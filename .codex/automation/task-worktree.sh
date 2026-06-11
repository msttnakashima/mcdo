#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: task-worktree.sh [-p type] [-s scope] -t short-message [-b base] [-d worktree-root]

Creates or reuses an isolated worktree for one main task branch.
Branch format: type/scope/short-message, or type/short-message when scope is omitted.
Default worktree path: ../<repo>-worktrees/<type-scope-short-message>
USAGE
}

type="chore"
scope=""
short=""
base="main"
root=""

while getopts ":p:s:t:b:d:h" opt; do
  case "$opt" in
    p) type="$OPTARG" ;;
    s) scope="$OPTARG" ;;
    t) short="$OPTARG" ;;
    b) base="$OPTARG" ;;
    d) root="$OPTARG" ;;
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

if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  current="$(git symbolic-ref --quiet --short HEAD || true)"
  if [ "$current" != "$base" ]; then
    git symbolic-ref HEAD "refs/heads/$base"
  fi
  echo "Repository has no commits. Create the first commit on '$base' before creating task worktrees." >&2
  exit 1
fi

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
  path_slug="${type_slug}-${scope_slug}-${short_slug}"
else
  branch="${type_slug}/${short_slug}"
  path_slug="${type_slug}-${short_slug}"
fi

existing_path="$(git worktree list --porcelain | awk -v b="refs/heads/$branch" '
  $1 == "worktree" { path=$2 }
  $1 == "branch" && $2 == b { print path; exit }
')"

if [ -n "$existing_path" ]; then
  echo "$existing_path"
  exit 0
fi

repo_name="$(basename "$(git rev-parse --show-toplevel)")"
if [ -z "$root" ]; then
  root="../${repo_name}-worktrees"
fi
mkdir -p "$root"
worktree_path="${root%/}/$path_slug"

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
  git worktree add "$worktree_path" "$branch"
elif [ -n "$remote" ] && git ls-remote --exit-code --heads "$remote" "$branch" >/dev/null 2>&1; then
  git fetch "$remote" "$branch"
  git worktree add --track -b "$branch" "$worktree_path" "$remote/$branch"
else
  git worktree add -b "$branch" "$worktree_path" "$base_ref"
fi

echo "$worktree_path"
