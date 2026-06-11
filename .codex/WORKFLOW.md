# Codex Workflow

## 1. Create Or Update Specs

All implementation starts with a main task spec and one or more sub specs.

Valid main task ID:

```text
^TASK-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}$
```

Valid sub spec ID:

```text
^TASK-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}-[A-Z]$
```

Valid spec filename:

```text
^specs/TASK-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}(-[A-Z])?\.spec\.md$
```

Invalid IDs or filenames block routing and implementation. Do not silently auto-normalize them.

Main task rules:

- Filename is exactly `specs/TASK-YYYY-MM-DD-###.spec.md`.
- ID uses the task creation date and a three-digit daily sequence.
- Scope should fit about 30 minutes for one developer.
- Scope should be reviewable as one PR.
- Include `dependencies`.
- Do not start until all dependencies are `done`.

Sub spec rules:

- Filename is exactly `specs/TASK-YYYY-MM-DD-###-A.spec.md`.
- ID is the parent task ID plus one uppercase suffix from `A` to `Z`.
- Allocate suffixes in order.
- Scope should fit about 10 minutes for one developer.
- Shape sub specs as one endpoint change, one UI component change, one schema adjustment, one migration, one validation rule, or one docs update.
- If a sub spec has multiple concrete developer steps, split it.
- If a main task needs more than 26 sub specs, split the main task.

Use `specs/templates/TASK.spec.template.md`.

## 2. Approve Before Implementation

Implementation must not start while a spec is `draft`.

Allowed implementation statuses:

- `approved`
- `implementation-ready`

Blocked statuses:

- `draft`
- `blocked`
- `done`

The spec architect owns decomposition and ID validation before routing.

## 3. Route To Specialists

Use `.codex/agents/agent-router.toml`.

Routes:

- Frontend-owned specs route to `frontend-domain-specialist`.
- UI/UX-owned specs route to `ui-ux-frontend-design-specialist`.
- Deployment/infrastructure specs route to `deployment-infrastructure-domain-specialist` only when concrete provider, config, CI/CD, domain, SSL, or hosting files exist.

Do not route to a catch-all implementation specialist. If no concrete specialist owner exists, split the work or add a justified specialist before implementation.

## 4. Branch And Isolation

Serial work:

```sh
.codex/automation/task-branch.sh -p feat -s frontend -t hello-page
```

Parallel work:

```sh
.codex/automation/task-worktree.sh -p feat -s frontend -t hello-page
```

Use one branch and one PR per main task. Sub specs are completed on the parent main task branch.

Parallel main task execution is allowed only when:

- all dependencies are done,
- `scope_in` does not materially conflict,
- each task has a separate branch,
- each task has an isolated worktree,
- required specialists are available,
- no high-conflict shared files overlap.

High-conflict surfaces should serialize unless explicitly proven safe:

- root config,
- workflow files,
- package manager manifests,
- shared schemas,
- migrations,
- deployment config,
- lockfiles.

## 5. Spawn Implementation Subagents

Implementation work must be done by spawned subagents. This repository grants standing authorization to spawn implementation subagents by default.

If subagent spawning is unavailable, stop and report the blocker instead of implementing directly.

The main agent coordinates:

- spec readiness,
- routing,
- integration,
- validation,
- PR creation,
- TL/main-agent review,
- merge closeout.

Implementation agents stop after implementation, validation, and handoff metadata.

Session policy:

- Same repo, same main task, still implementing: keep the same session.
- Next sub spec under the same active main task: keep the same session when context remains useful.
- New main task: start a fresh session.
- New bootstrap job for another repo: start a fresh session.
- Continue an old session only when the same main task depends on context that would be expensive to rebuild.

## 6. Validate

No repo commands are established yet.

When the static app exists, validation should include:

- exact visible text: `hello from mcdo`,
- desktop viewport check,
- mobile viewport check,
- zero browser console errors,
- no navigation or external links,
- app-specific lint/test/build commands once committed.

For frontend validation:

- Use Playwright MCP first for repeatable browser flows.
- Use Chrome DevTools MCP for DOM inspection, console/network debugging, and performance investigation.

## 7. Finalize, PR, Review, Merge

Commit and push after every sub spec under the main task is complete and validated:

```sh
.codex/automation/finalize-task.sh -m "feat(frontend): add hello page" -- path/to/file
```

Use `-a` or `--all` only when intentionally staging all changes.

Open a PR:

```sh
.codex/automation/open-task-pr.sh
```

PR creation happens only after all sub specs under the parent main task are complete and validated.

Immediately after opening a PR, enqueue or perform TL/main-agent review. Pending PR review is active work, not done work. If review capacity is unavailable, stop and report the review backlog.

Merge after local TL/main approval:

```sh
.codex/automation/merge-task-pr.sh --tl-approved
```

Merges use GitHub merge commits via `gh pr merge --merge --delete-branch`. Squash and rebase are not the normal merge path.

## 8. Local Workflow Guardrails

To hide local workflow scaffolding from normal `git status` and install the local pre-commit guard:

```sh
.codex/automation/exclude-codex-local.sh
```

This only hides untracked files. It does not untrack files that are already committed.

If workflow files should be versioned, stage them explicitly:

```sh
git add -f AGENTS.md CODEX.md .codex specs
```
