# Codex Project Guide

## Project Summary

Product: McDonald's "Hello World" Web App.

Purpose: validate deployment pipeline, hosting infrastructure, SSL/domain routing, and basic frontend architecture with a minimalist static page.

Primary product requirement: the app displays exactly:

```text
hello from mcdo
```

The PRD requires a single static page, no navigation, no external links, desktop/mobile loading, and zero console errors.

## Evidence

- [prd.md](prd.md): product scope, exact display text, single-page constraint, performance target, and success metrics.
- Repository scan on 2026-06-11: no app source, package manifest, test config, lint config, build config, `.codex` assets, or existing guidance files.
- Git scan on 2026-06-11: repository is on unborn `main`, has no commits yet, and has `origin` set to `git@github.com:msttnakashima/mcdo.git`.

## Current Commands

No install, dev, lint, test, or build commands are established yet.

Do not invent commands in task specs. When a stack is added, update this section with the exact commands from committed repo files.

Expected validation once the app exists:

- Load the page in a desktop browser.
- Load the page in a mobile viewport.
- Confirm visible text is exactly `hello from mcdo`.
- Confirm there are no console errors on page load.
- Confirm no navigation or external links exist.

For frontend verification, prefer Playwright MCP for deterministic flows and Chrome DevTools MCP for DOM, console, network, and performance debugging.

## Domain Routing

Use `.codex/agents/agent-router.toml` for routing.

Primary domains:

- `frontend-domain-specialist`: owns static page structure, browser behavior, exact display text, frontend validation, and eventual app framework files.
- `ui-ux-frontend-design-specialist`: owns layout, typography, visual alignment, responsive viewport checks, and UI polish for the minimalist page.
- `deployment-infrastructure-domain-specialist`: owns deployment readiness docs/config only when a hosting provider, domain, SSL workflow, CI/CD surface, or infrastructure file exists in the repo.

No catch-all implementation specialist is allowed. If a spec cannot name one of the concrete specialists above, split it or create a justified specialist first.

## Spec And Task Standards

Main task IDs:

```text
^TASK-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}$
```

Sub spec IDs:

```text
^TASK-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}-[A-Z]$
```

Spec filenames:

```text
^specs/TASK-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}(-[A-Z])?\.spec\.md$
```

Rules:

- Main task filenames are exactly `specs/TASK-YYYY-MM-DD-###.spec.md`.
- Sub spec filenames are exactly `specs/TASK-YYYY-MM-DD-###-A.spec.md`.
- Suffixes are allocated from `A` through `Z` under the parent task.
- If a main task needs more than 26 sub specs, split the main task.
- Slug suffixes and descriptive filename tails are invalid.
- Invalid IDs or filenames block routing and implementation until the spec architect or TL corrects them.
- A main task should fit one developer in about 30 minutes and be reviewable as one PR.
- A sub spec should fit one developer in about 10 minutes and contain one concrete developer step.
- Main tasks must include `dependencies`.
- Implementation must not start until dependencies are `done`.

## Workflow Policy

Session defaults:

- Same repo, same main task, still implementing: keep the same session.
- Next sub spec under the same active main task: keep the same session when context remains useful.
- New main task: start a fresh session.
- New bootstrap job for another repo: start a fresh session.
- Continue an old session only when the same main task depends on context that would be expensive to rebuild.

Implementation policy:

- The main agent coordinates, integrates, validates, reviews, and closes out.
- Implementation work must be performed by spawned subagents.
- If subagent spawning is unavailable, stop and report the blocker instead of implementing directly.
- Spawn `frontend-domain-specialist` for frontend-owned specs.
- Spawn `ui-ux-frontend-design-specialist` for UI/UX-owned specs.
- Spawn `deployment-infrastructure-domain-specialist` only for evidenced deployment/infrastructure surfaces.
- Use parallel implementation only when main tasks are dependency-free, non-conflicting, and isolated by branch plus worktree.
- Treat root config, shared schemas, migrations, and global workflow files as high-conflict surfaces that should usually serialize.

Git policy:

- Use `.codex/automation/task-branch.sh` for serial main task work.
- Use `.codex/automation/task-worktree.sh` for parallel main task work.
- Use `.codex/automation/finalize-task.sh` for commit and push.
- Use `.codex/automation/open-task-pr.sh` for PR creation.
- Use `.codex/automation/merge-task-pr.sh --tl-approved` for merge commits after TL/main approval.
- Branch names follow `type/scope/short-message`, with `scope` optional as `type/short-message`.
- PR titles follow `type(scope): short message` or `type: short message`.

Local workflow files may be hidden from normal `git status` by `.codex/automation/exclude-codex-local.sh`. If these files should be versioned, stage them explicitly with `git add -f`.

## Convention Overrides

- Keep the app minimal. Do not add navigation, external links, analytics, images, or brand assets unless a later PRD explicitly requires them.
- The visible product text must remain exactly `hello from mcdo` unless a newer approved PRD changes it.
- Do not choose a frontend framework until a task spec explicitly owns that decision.
- Preserve current repo patterns once a stack exists, even if they differ from generic defaults.
