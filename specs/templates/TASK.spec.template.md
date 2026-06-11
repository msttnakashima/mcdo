# TASK-YYYY-MM-DD-###

status: draft
owner: spec-architect
created: YYYY-MM-DD
dependencies: []

## ID Rules

Main task ID must match:

```text
^TASK-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}$
```

Sub spec ID must match:

```text
^TASK-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}-[A-Z]$
```

Spec filename must match:

```text
^specs/TASK-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}(-[A-Z])?\.spec\.md$
```

Invalid IDs or filenames block routing and implementation. Do not silently auto-normalize them.

## Main Task

### Goal

State the one 30-minute outcome this task delivers.

### Scope In

- One concrete deliverable.

### Scope Out

- Explicit exclusions.

### Dependencies

- `TASK-YYYY-MM-DD-###`: reason, or `none`.

### Specialist Routing

Primary specialist: `frontend-domain-specialist | ui-ux-frontend-design-specialist | deployment-infrastructure-domain-specialist`

Reason:

### Sub Specs

- `TASK-YYYY-MM-DD-###-A`: one 10-minute implementation step.

## Acceptance Criteria

- Criterion that can be validated directly.

## Validation

- Command or browser check.
- If no command exists yet, state that no command exists and list the manual verification.

## Review Notes

- Risks:
- High-conflict files:
- Parallel-safe: yes/no and reason.

## Handoff

- Implementation summary:
- Validation evidence:
- Review status:
