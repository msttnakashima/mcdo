# Bootstrap Strategy

## Evidence Map

| Value | Evidence | Confidence |
| --- | --- | --- |
| Product is McDonald's "Hello World" Web App | `prd.md` title and executive summary | high |
| Primary requirement is exact text `hello from mcdo` | `prd.md` FR-01 | high |
| App is one static page with no navigation or external links | `prd.md` FR-02 | high |
| Desktop and mobile browser validation matters | `prd.md` success metrics | high |
| Zero console errors are required | `prd.md` success metrics | high |
| Performance target is under 500ms | `prd.md` non-functional requirements | medium |
| Deployment/hosting/SSL/domain routing are project goals | `prd.md` executive summary and objectives | medium |
| No concrete app stack exists yet | repo scan found only `prd.md` | high |
| No install/test/lint/build commands exist yet | repo scan found no manifests or configs | high |
| No existing Codex assets exist | repo scan found no `AGENTS.md`, `CODEX.md`, or `.codex` | high |
| GitHub remote exists | `git remote -v` reports `origin git@github.com:msttnakashima/mcdo.git` | high |
| Repository has no commits yet | `git rev-parse --verify HEAD` fails on unborn `main` | high |

## Inferred Product Shape

Product: McDonald's "Hello World" Web App.

Summary: a static one-page browser surface used as a deployment and hosting smoke test.

Primary users:

- Browser visitors who should see the placeholder page.
- Engineers validating deployment, SSL, domain routing, and console health.

Platform targets:

- Desktop browser.
- Mobile browser.
- Static hosting target, provider not yet specified.

Likely domains:

- Static frontend.
- Minimal UI/UX.
- Deployment/infrastructure readiness once provider evidence exists.

Likely data model areas:

- None. The PRD does not require persistence, APIs, authentication, or user data.

Integrations:

- GitHub remote exists.
- Hosting, SSL, domain, CI/CD, analytics, and monitoring are not specified.

Auth/access needs:

- None for the app based on the PRD.
- GitHub access is needed only for PR automation.

Testing/lint/build commands:

- Not established.
- Browser validation is required once a page exists.

Design/system clues:

- Clean centered layout.
- Standard typography.
- Exact visible text.
- No navigation or external links.

Docs to preserve:

- `prd.md`.

## Bootstrap Decisions

- Generate a small operating setup instead of a broad framework.
- Do not add app implementation files during bootstrap.
- Do not invent npm, Vite, React, Next.js, hosting, or CI commands.
- Generate concrete specialists only for evidenced primary domains.
- Include frontend browser verification guidance because the product has a browser surface.
- Include deployment/infrastructure specialist guidance but restrict it to evidenced repo surfaces.
