---
title: "FLOps API Endpoints"
summary: ""
draft: false
weight: 10311050100
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

{{< callout context="note" title="Who is serving?" icon="outline/tools-kitchen-2" >}}
  The FLOps Manager serves this API.

  It uses [Waitress](https://github.com/Pylons/waitress) to provide a production-quality WSGI server.
{{< /callout >}}


## GET

### /api/flops/tracking
The tracking endpoint allows users to spawn their personal tracking servers at will independently from an active project.
Usually, a tracking server is created during FL training.
It returns the tracking server / GUI URL.

## POST

### /api/flops/projects
This endpoint triggers a new FLOps project.
It expects a JSON SLA with the required project configurations and a bearer token authorizing the user on the orchestrator.
If no matching images exist, an image builder is created and deployed.
If an adequate image already exists, the request concludes straight away.
It returns a confirmation that the new project has successfully started.

## /api/flops/mocks
This POST endpoint creates mock data providers and deploys them on fitting learner machines.
We discuss these data providers later on in this thesis.
Similar to the project, this endpoint returns a confirmation to the user.

## DELETE

## /api/flops/database
This endpoint only allows admins to reset the FLOps database.
Otherwise, the entire FLOps management suite needs a restart.
It returns a confirmation.


