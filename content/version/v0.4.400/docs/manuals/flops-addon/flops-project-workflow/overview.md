---
title: "FLOps Projects Overview"
summary: ""
draft: false
weight: 309030100
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
asciinema: true
---

{{< callout context="note" title="This Guide's Goals" icon="outline/target-arrow" >}}

- Get you doing FL as quickly as possible
- Help you understand the basic FLOps project workflow

This guide uses predefined SLAs and ML Git repositories provided by the [oak-cli](../../../../getting-started/deploy-app/deploy-cli/) to streamline the necessary steps.
This base case is intended to run on a single machine to make it as easy as possible to follow along.

To create and use custom SLAs and ML Git repositories, please familiarize yourself with this base case and read the dedicated [FLOps customization documentation](../../customizations/overview/).

{{< /callout >}}

## What is a FLOps Project?

A FLOps **project** links all necessary FL and ML/DevOps components to power one FL user request.

A project contains information about:

- The user who requested it
- The target platforms that should be supported (e.g., ARM/AMD)
- What steps FLOps should perform after training.
- etc.

Projects are based on the SLA you use - they can vary in:

- ML Training Code (Git Repository)
- Requested Data (data-tags)
- FL Training Configuration
  - Number of training rounds
  - Number of Learners
  - etc.
- FL Strategy (classic or clustered hierarchical)
- etc.

## Running a basic FLOps Project

{{< callout context="caution" title="Requirements" icon="outline/alert-triangle">}}

- You have a running Oakestra deployment with at least one Worker Node with a registered NetManager.
- You have [prepared your system to use FLOps](../../preparations/overview/).
  {{< /callout >}}

{{< link-card
title="Stage 0: Preparations"
href="../stages/stage-0-preparation/" >}}

{{< link-card
title="Stage 1: Project Start"
href="../stages/stage-1-project-start/" >}}

{{< link-card
title="Stage 2: Image-Builder Deployment"
href="../stages/stage-2-image-builder-deployment/" >}}

{{< link-card
title="Stage 3: FL-Actors Image Build"
href="../stages/stage-3-FL-actor-image-build/" >}}

{{< link-card
title="Stage 4: FL-Actors Deployment"
href="../stages/stage-4-FL-actor-deployment/" >}}

{{< link-card
title="Stage 5: FL Training"
href="../stages/stage-5-FL-training/" >}}

{{< link-card
title="Post-training Steps"
href="../stages/post-training-steps/" >}}
