---
title: Operations
audience: technical
last_reviewed: 2026-07-26
---

# Operations

## Live instance

Self-hosted at [glpi.agmegypt.com](https://glpi.agmegypt.com).

## Login paths

- **Local GLPI credentials** — the default GLPI login form.
- **Azure AD SSO** — via the [`glpi-singlesignon`](https://github.com/AGM-One-Vision/glpi-singlesignon)
  plugin, configured for AGM's Azure AD tenant. Staff can log in with their
  AGM Microsoft 365 account instead of a separate GLPI password.

## Data access beyond the web UI

The MySQL database backing this instance is read directly (read-only) by
[`glpi-mcp-auth`](https://github.com/AGM-One-Vision/glpi-mcp-auth) to
resolve an authenticated MCP caller to a GLPI user record. All actual
ticket reads/writes from that server still go through the REST API under
a dedicated service account — the DB connection is for identity resolution
only, not a bypass of GLPI's own business logic.

## Related System components

- [`glpi-singlesignon`](https://github.com/AGM-One-Vision/glpi-singlesignon) — plugin, runs inside this app
- [`glpi-mcp-auth`](https://github.com/AGM-One-Vision/glpi-mcp-auth) — separate service, depends on this app's REST API + DB
