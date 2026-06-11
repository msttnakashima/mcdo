#!/usr/bin/env bash
set -euo pipefail

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "Not inside a Git repository checkout." >&2
  exit 1
}

git_dir="$(git rev-parse --git-dir)"
repo_root="$(git rev-parse --show-toplevel)"
exclude_file="$git_dir/info/exclude"
hook_file="$git_dir/hooks/pre-commit"
guard_script="$repo_root/.codex/automation/guard-local-workflow-commit.sh"

mkdir -p "$(dirname "$exclude_file")" "$(dirname "$hook_file")"
touch "$exclude_file"

add_exclude() {
  pattern="$1"
  if ! grep -Fxq "$pattern" "$exclude_file"; then
    printf '%s\n' "$pattern" >> "$exclude_file"
  fi
}

add_exclude ".codex/"
add_exclude "specs/"
add_exclude "AGENTS.md"
add_exclude "CODEX.md"

echo "Updated $exclude_file."
echo "These patterns only hide untracked files. Already tracked files remain tracked."

chmod +x "$guard_script"

start="# BEGIN MANAGED CODEX WORKFLOW GUARD"
end="# END MANAGED CODEX WORKFLOW GUARD"
block="$(cat <<HOOK
$start
if [ -x ".codex/automation/guard-local-workflow-commit.sh" ]; then
  .codex/automation/guard-local-workflow-commit.sh
fi
$end
HOOK
)"

if [ -f "$hook_file" ]; then
  if grep -Fq "$start" "$hook_file"; then
    tmp="$(mktemp)"
    awk -v start="$start" -v end="$end" -v block="$block" '
      $0 == start { print block; inside=1; next }
      $0 == end { inside=0; next }
      !inside { print }
    ' "$hook_file" > "$tmp"
    cat "$tmp" > "$hook_file"
    rm -f "$tmp"
    chmod +x "$hook_file"
    echo "Updated managed pre-commit guard in $hook_file."
  elif [ ! -s "$hook_file" ]; then
    {
      printf '%s\n' '#!/usr/bin/env bash'
      printf '%s\n' 'set -euo pipefail'
      printf '%s\n' "$block"
    } > "$hook_file"
    chmod +x "$hook_file"
    echo "Installed managed pre-commit guard in $hook_file."
  else
    echo "Existing unmanaged pre-commit hook found; leaving it unchanged." >&2
    echo "Add this guard manually if desired: .codex/automation/guard-local-workflow-commit.sh" >&2
  fi
else
  {
    printf '%s\n' '#!/usr/bin/env bash'
    printf '%s\n' 'set -euo pipefail'
    printf '%s\n' "$block"
  } > "$hook_file"
  chmod +x "$hook_file"
  echo "Installed managed pre-commit guard in $hook_file."
fi
