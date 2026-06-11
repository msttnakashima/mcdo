# Codex Enforcement

This repository uses a spec-first Codex workflow for the McDonald's "Hello World" web app.

## Non-Negotiables

- Treat [prd.md](prd.md) as the product source of truth until a newer approved PRD replaces it.
- Do not implement from a draft spec. Implementation requires `status: approved` or `status: implementation-ready`.
- Main task IDs must match `^TASK-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}$`.
- Sub spec IDs must match `^TASK-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}-[A-Z]$`.
- Spec filenames must match `^specs/TASK-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}(-[A-Z])?\.spec\.md$`.
- Invalid task IDs or filenames block routing and implementation. Do not silently rename or normalize them.
- Every main task must list `dependencies`; do not start it until every dependency is `done`.
- Every implementation sub spec must have one concrete specialist owner. Split unclear work before routing.
- Always spawn implementation subagents. If subagent spawning is unavailable, stop and report the blocker.
- Use one branch and one PR per main task. Sub specs do not get their own PRs.
- Open a PR only after all sub specs for the main task are complete and validated.
- After opening a PR, immediately enqueue or perform TL/main-agent review. Pending review is active work, not done work.
- Merge only after local TL/main approval, using `.codex/automation/merge-task-pr.sh --tl-approved`.

## Repo Facts

- Current product target: a minimalist single-page static web app that displays exactly `hello from mcdo`.
- Current stack: not established. Do not invent framework commands until the repo contains a framework.
- Frontend validation is first-class once a browser surface exists: desktop, mobile, and zero console errors.
