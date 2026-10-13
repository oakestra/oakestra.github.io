---
title: "Stage 3: FL-Actors Image Build"
summary: ""
draft: false
weight: 10311030204
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
asciinema: true
---

In stage 3, the deployed image-builder service builds the requested images for the learner and aggregator services.

{{< callout context="danger" title="Critical" icon="outline/alert-octagon" >}}
  Building (multi-platform) images for ML/FL dynamically based on flexible user-provided repositories is a delicate and error-prone process.

  Building images can take up a significant part of the entire project duration - especially if the training configuration is lightweight *(fast / few rounds)*.

  ---

  The only current way for FLOps to let you know that something went wrong during building is to send an error message to your project observer.

  Watch out for these observer logs - especially when working with new ML repositories for the first time.
{{< /callout >}}

The image-builder service does the following:
- Clones the requested ML Git repository
- Checks the cloned repository if it satisfies the mandatory structural requirements
- Checks for potential dependency issues and tries to resolve them if possible
- Builds the FL-Actor images
- Pushes the build images to the FLOps image registry
- Notifies the project observer and the FLOps manager about its success or possible errors

The FLOps manager undeploys and removes the image builder service.

### Showcase

This demo shows this build process from the perspective of a privileged CLI user.

{{< callout context="note" title="*Time Lapse*" icon="outline/clock" >}}
  Building images can easily take 5-30+ minutes.

  This depends on:
  - Underlying worker node resources
  - Complexity of the provided ML repo dependencies
  - Number and kind of target platforms that should be supported

  This demo cuts out long waiting periods for your viewing pleasure.
{{< /callout >}}


{{< asciinema key="flops_base_case_fl_actors_build" poster="0:08" idleTimeLimit="1.5" >}}

{{< callout context="note" title="Want to know more about FLOps' image building process?" icon="outline/settings-question" >}}
  Explore why and how container images are build in FLOps [here](../../../../../concepts/flops/internals/image-building-process).
{{< /callout >}}
