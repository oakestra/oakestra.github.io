---
title: "Stage 2: Image-Builder Deployment"
summary: ""
draft: false
weight: 10311030203
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
asciinema: true
---

The FLOps manager tries to look up matching container images for learners and aggregators.
The manager checks for images in the FLOps image registry (*part of the management suite*) that match the ML repository that was part of the requested project SLA.

If a match is found, there is no need to build redundant images, and the project goes straight to [stage 4](../stage-4-fl-actor-deployment/).

If images for **FL Actors** *(learners & aggregators)* using the requested ML repository are missing, the manager will create and deploy a single image-builder service.
This builder service is exclusive to its originating project.

```bash
  ╭─────────────────────┬──────────────────────────┬────────────────┬──────────────────┬──────────────────────────╮
  │ Service Name        │ Service ID               │ Instances      │ App Name         │ App ID                   │
  ├─────────────────────┼──────────────────────────┼────────────────┼──────────────────┼──────────────────────────┤
  │                     │                          │                │                  │                          │
  │ builder8266202cd6db │ 6761bf5e59461659a24b1199 │  0 RUNNING     │ projc3fd78f56b75 │ 6761bf5d59461659a24b1197 │
  │                     │                          │                │                  │                          │
  ╰─────────────────────┴──────────────────────────┴────────────────┴──────────────────┴──────────────────────────╯
```

{{< callout context="tip" title="*To build or not to build?*" icon="outline/hammer" >}}
  Stage 2 is distinct because:
  - Deciding if new images need to be built requires querying the remote ML Git repository and the FLOps image registry.
  - The image-builder service can only run on worker nodes with the `image-builder` addon enabled.
  - Deploying the large image builder service *(pulled size ~3GB)* can take time.
{{< /callout >}}
