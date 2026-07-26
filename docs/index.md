---
title: Overview
audience: technical
last_reviewed: 2026-07-26
---

# GLPI

**GLPI** (Gestionnaire Libre de Parc Informatique) is a free, open-source
IT Asset and Service Management platform. AGM self-hosts a fork of it at
[glpi.agmegypt.com](https://glpi.agmegypt.com), tracking the upstream
[`glpi-project/glpi`](https://github.com/glpi-project/glpi) `11.0/bugfixes`
branch.

## What it covers

- **Service desk (ITIL)** — tickets, incidents, problems, changes, with
  SLAs and a knowledge base
- **Asset & configuration management** — computers, peripherals, network
  devices, software licenses, contracts
- **Entity separation** — multi-org / multi-department scoping within one
  instance

## The AGM GLPI stack

This System is made up of three repos:

| Repo | Role |
|---|---|
| [`glpi`](https://github.com/AGM-One-Vision/glpi) *(this repo)* | The GLPI application itself |
| [`glpi-singlesignon`](https://github.com/AGM-One-Vision/glpi-singlesignon) | Plugin adding Azure AD login to the GLPI web UI |
| [`glpi-mcp-auth`](https://github.com/AGM-One-Vision/glpi-mcp-auth) | MCP server exposing helpdesk tickets to Claude Code, authenticated via the same Azure AD tenant |

See [API](api.md) for the built-in REST API and [Operations](operations.md)
for how the pieces run together.

## Docs that ship with the app

Beyond this TechDocs site, the repo itself carries GLPI's own docs, still
worth reading directly:

- [`apirest.md`](https://github.com/AGM-One-Vision/glpi/blob/11.0/bugfixes/apirest.md) — REST API reference
- [`INSTALL.md`](https://github.com/AGM-One-Vision/glpi/blob/11.0/bugfixes/INSTALL.md) — install/upgrade guide
- [`SECURITY.md`](https://github.com/AGM-One-Vision/glpi/blob/11.0/bugfixes/SECURITY.md) — security policy
