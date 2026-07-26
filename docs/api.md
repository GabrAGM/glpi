---
title: API
audience: technical
last_reviewed: 2026-07-26
---

# REST API

GLPI ships a built-in REST API (`apirest.php`), documented in full in the
repo's [`apirest.md`](https://github.com/AGM-One-Vision/glpi/blob/11.0/bugfixes/apirest.md).
This page is a quick orientation — treat `apirest.md` as the source of truth.

!!! note "No OpenAPI spec"
    `apirest.md` is a hand-written prose reference, not a machine-readable
    OpenAPI/Swagger document. This Component doesn't register a Backstage
    `API` entity for that reason — an `API` kind entity needs a real
    `spec.definition`, and fabricating one from the prose doc would present
    it as more rigorously validated than it is. If GLPI (or AGM) ever
    publishes a maintained OpenAPI spec, register it then via
    [Guide 02](https://github.com/AGM-One-Vision/devhub-catalog/blob/main/docs/guides/02-register-an-api.md).

## Auth flow

1. `GET apirest.php/initSession` with either a login/password (HTTP Basic)
   or a user token, plus an optional `App-Token`. Returns a `session_token`.
2. Every subsequent call sends that token in a `Session-Token` header.
3. `GET apirest.php/killSession` ends the session.

Sessions are read-only by default; pass `session_write=true` to allow
writes serialized per-session.

## Resource model

Endpoints are generic over **itemtype** — any GLPI class inheriting
`CommonDBTM` (e.g. `Ticket`, `User`, `Group`, `ITILCategory`). Standard CRUD:

| Method | Endpoint | Does |
|---|---|---|
| `GET` | `/<itemtype>/<id>` | Fetch one item |
| `GET` | `/search/<itemtype>` | Query with `criteria[]` filters |
| `POST` | `/<itemtype>` | Create (`{"input": {...}}`) |
| `PUT` | `/<itemtype>/<id>` | Update |
| `DELETE` | `/<itemtype>/<id>` | Delete |

Sub-resources follow the same pattern, e.g. `/Ticket/<id>/ITILFollowup`,
`/Ticket/<id>/TicketTask`.

## Who calls this today

[`glpi-mcp-auth`](https://github.com/AGM-One-Vision/glpi-mcp-auth) is the
only known internal consumer — it drives `apirest.php` under a shared
service account to back its Claude Code MCP tools (ticket list/get/create/
update/close, followups, assignment, user/group search).
