#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: finalize-task.sh -m "type(scope): message" [-a|--all] [-- path ...]

Commits and pushes the current task branch. By default, explicit paths after -- are required.
Use -a or --all only when intentionally staging all changes.
Explicit paths are force-added so intentionally excluded workflow files can be committed.
USAGE
}

message=""
stage_all=0
paths=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    -m|--message)
      shift
      [ "$#" -gt 0 ] || { echo "Missing commit message." >&2; exit 2; }
      message="$1"
      ;;
    -a|--all)
      stage_all=1
      ;;
    --)
      shift
      while [ "$#" -gt 0 ]; do
        paths+=("$1")
        shift
      done
      break
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

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "Not inside a Git repository checkout." >&2
  exit 1
}

if [ -z "$message" ]; then
  echo "Missing required commit message." >&2
  usage
  exit 2
fi

if [ "$stage_all" -eq 0 ] && [ "${#paths[@]}" -eq 0 ]; then
  echo "Explicit paths after -- are required unless -a or --all is supplied." >&2
  usage
  exit 2
fi

git config user.name >/dev/null || {
  echo "git user.name is not configured." >&2
  exit 1
}
git config user.email >/dev/null || {
  echo "git user.email is not configured." >&2
  exit 1
}

if [ "$stage_all" -eq 1 ]; then
  git add -A
else
  git add -f -- "${paths[@]}"
fi

if git diff --cached --quiet; then
  echo "No staged changes to commit." >&2
  exit 1
fi

git commit -m "$message"

current_branch="$(git symbolic-ref --quiet --short HEAD || true)"
if [ -z "$current_branch" ]; then
  echo "Detached HEAD; commit created, push skipped." >&2
  exit 0
fi

remote=""
if git remote get-url origin >/dev/null 2>&1; then
  remote="origin"
else
  echo "No remote configured; commit created, push skipped."
  exit 0
fi

if ! git ls-remote --exit-code --heads "$remote" main >/dev/null 2>&1; then
  if git show-ref --verify --quiet refs/heads/main; then
    git push "$remote" main:main
  else
    echo "Remote main is missing and no local main exists. Refusing to create main from current branch." >&2
    exit 1
  fi
fi

git push -u "$remote" "$current_branch"
