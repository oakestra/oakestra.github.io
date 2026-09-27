---
title: "Network Information API"
summary: "Internal API for retrieving service networking details"
draft: false
weight: 303080000
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
swaggerui: true
---

The Network Information API exposes read-only HTTP endpoints to fetch the current networking configuration of an Oakestra service.
It is intended for internal use by other Oakestra components or for debugging service connectivity.

See below for an inline documentation of the available endpoints.
Each one requires a valid JWT in the `Authorization: Bearer <token>` header.

To inspect the endpoint documentation of the specific Oakestra version you are running,
navigate to `https://<root-orchestrator-ip>:10099/docs`, where `root-orchestrator-ip` is the IP address of your running root orchestrator.

{{< swaggerui "openapi/netinfo.json" >}}
