---
title: "Oakestra releases v0.4.4 (Bass)"
description: "The second major release of Oakestra"
summary: ""
date: 2025-02-21T16:27:22+02:00
lastmod: 2024-02-21T16:27:22+02:00
draft: false
weight: 50
categories: [releases]
tags: [releases, announcements]
contributors: ["Oakestra Dev Team"]
pinned: false
homepage: false
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
asciinema: true
---

We are proud to announce that **Oakestra v0.4.4 (codename: Bass 🎸)** is here! *This is the second major release for Oakestra and it packs several goodies!*

Here are the new features introduced in this version!

{{< card-grid >}}
{{< link-card description="Overhauled and modernized Documentation" href="#modernized-documentation" >}}
{{< link-card description="OAK-CLI Command Line Interface" href="#developer-friendly-command-line-interface" >}}
{{< link-card description="Comprehensive Federated Learning Support" href="#federated-learning-support" >}}
{{< link-card description="System flexibility with lifecycle hooks" href="#lifecycle-hooks" >}}
{{< /card-grid >}}

{{< card-grid >}}
{{< link-card description="Add Oakestra capabilities with addons" href="#oakestra-addons" >}}
{{< link-card description="Run applications within priviledged containers" href="#priviledged-containers" >}}
{{< link-card description="Bug fixes and improvements" href="#fixes-and-improvements" >}}
{{< link-card description="Community Activities" href="#community-activities" >}}
{{< /card-grid >}}

## Modernized Documentation

![dashboard-screenshot](dashboard.png)

Our completely overhauled documentation website is more than just a new look—it's a reimagined resource designed to guide you effortlessly through every aspect of Oakestra. Built on modern frameworks, the site adapts seamlessly to desktops, tablets, and smartphones. Whether you’re troubleshooting an issue or learning new features, you always have a smooth and intuitive experience. Every article has been refined for clarity and depth, making it the definitive guide for both beginners and seasoned developers.

{{< callout title="Explore the New Documentation" icon="outline/book" >}}
Visit our revamped documentation [website](https://www.oakestra.io/docs/getting-started/welcome-to-oakestra/) and share your feedback by submitting an issue [here](https://github.com/oakestra/documentation/issues/new?template=Blank+issue).
{{< /callout >}}

## Developer-Friendly Command Line Interface

Oakestra now includes its own [public CLI tool](https://github.com/oakestra/oakestra-cli) called `oak-cli`. It is a significant game-changer that makes life easier for Oakestra users and developers. The `oak-cli` includes powerful dynamic and customizable features to automate every aspect of your Oakestra workflows, including installing dependencies, deploying applications and services, inspecting service logs in real time, and much more.

![oak-cli-gif](cli.gif)

The `oak-cli` is just getting started. We envision that the `oak-cli` will become the primary interface for working with Oakestra soon, so we encourage you to start using it straight away.

To download it, simply run

```bash
pip install oak-cli
```

{{< callout context="tip" title="Get started with oak-cli" icon="outline/terminal" >}}
Learn how to use the `oak-cli` to create your first Oakestra application [here](https://www.oakestra.io/docs/getting-started/deploy-app/with-the-cli/) and explore every available command [here](https://www.oakestra.io/docs/manuals/cli/cli-overview/).
{{< /callout >}}

## Federated Learning Support

Embracing the future of machine learning, our new FLOps addon introduces robust federated learning capabilities into Oakestra. Wondering *"What is Federated Learning?"* —check out our [brief explanation](https://www.oakestra.io/docs/concepts/flops/fl-basics/).

{{<svg "flops_overview">}}

This addon automatically augments your standard machine learning code into FL-compatible, multi-platform container images and deploys them onto orchestrated worker nodes for training. Users can monitor training rounds live via a sophisticated GUI, then pull the trained model or let FLOps build and deploy an inference server. FLOps supports both classical and clustered hierarchical federated learning, leveraging tools like [Flower](https://flower.ai/), [mlflow](https://mlflow.org/), and [Buildah](https://buildah.io/).

<div class="image-container">
  <div class="image-item">
    <img src="flower.png">
  </div>
  <div class="image-item">
    <img src="mlflow.png">
  </div>
  <div class="image-item">
    <img src="buildah.png">
  </div>
</div>

<!-- <div style="display: flex; justify-content: center;">
  <img src="flower.png" width="300" />
    <img src="mlflow.png" width="250" />
    <img src="buildah.png" width="350" />
</div> -->

{{< callout context="note" icon="outline/bolt" >}}
Find out more in our dedicated [FLOps documentation](https://www.oakestra.io/docs/concepts/flops/overview/#fl-with-oakestra).
{{< /callout >}}

## Oakestra Addons

Addons in the Bass release let developers extend or customize Oakestra's components. With this release, you can install plugins or extensions in your Root Orchestrator. A **Plugin** replaces an Oakestra component with a custom one (e.g., replacing the root scheduler), while an **Extension** deploys a new custom component alongside the existing control plane.

{{< callout context="tip" icon="outline/packages" >}}
Extend Oakestra functionality by defining your own addons. Learn more in our [detailed guide](https://www.oakestra.io/docs/concepts/oakestra-extensions/addons/).
{{< /callout >}}

## Lifecycle Hooks

With the Bass release, Oakestra introduces lifecycle hooks. Hooks allow developers to register, listen to, and react on lifecycle events of your applications. We now support *Creation*, *Update*, and *Deletion* hooks. Synchronous hooks block operations until a response is received, while asynchronous hooks notify subscribers without delay.

{{<svg "hooks">}}

For example, you can register an asynchronous `post_update` hook to trigger alerts when an application’s state changes, or a synchronous `pre_update` hook to update the service status with your custom logic.

{{< callout context="note" icon="outline/info-circle" >}}
For more details, visit our [wiki](https://www.oakestra.io/docs/concepts/oakestra-extensions/hooks/).
{{< /callout >}}

## Priviledged Containers

For advanced use cases requiring elevated system access, the new privileged containers feature is a game changer. By setting the `"privileged": true` flag in your SLA microservice description, you can deploy containers with full system privileges—ideal for scenarios demanding direct hardware access or specialized kernel operations. This feature remains securely disabled by default and is enabled only when explicitly needed.

{{< callout context="caution" title="Important" icon="outline/alert-triangle" >}}
Privileged containers unlock enhanced functionality but must be used with care due to their elevated permissions. 
{{< /callout >}}

## Fixes and Improvements

- Upgraded MongoDB version
- Improved startup and installation scripts
- Fixed cluster direct mapping constraints issues
- Added systemd compatibility for NodeEngine and NetManager
- Introduced Mosquitto broker authentication options

{{< callout context="note" icon="outline/flag" >}}
Read our [release notes](https://github.com/oakestra/oakestra/releases/tag/v0.4.400) for further details. Or simply [get started](https://www.oakestra.io/docs/getting-started/oak-environment/high-level-setup-overview/) with your new Oakestra setup following our detailed guide!
{{< /callout >}}

## Community Activites

### Celebrate Christmas in Style with Oakestra-Powered Edge Gaming

On Christmas 🎄, we inaugurated the Bass release with an Edge Gaming deployment of Minecraft. We deployed the Minecraft web client, proxy, and server on Oakestra and enjoyed a multiplayer session right in our browsers!

<p float="center">
  <img src="https://github.com/oakestra/app-minecraft-client-server-example/blob/main/img/oak-gif.gif?raw=true" width="450" />
  <img src="https://github.com/oakestra/app-minecraft-client-server-example/blob/main/img/menu.png?raw=true" width="400" />
</p>

{{< callout context="tip" icon="outline/info-circle" >}}
Instructions to replicate this deployment is available [here](https://www.oakestra.io/docs/manuals/app-catalog/example-applications/).
{{< /callout >}}

### Oakestra Becomes Social on X and YouTube

We’re expanding our social media presence—join us on X (formerly Twitter) and subscribe to our YouTube channel for live discussions, tutorials, and behind-the-scenes insights. We kicked off our community talk series with Luca Marchiori from the University of Padua, who shared details of his WebAssembly runtime support contributions to Oakestra.

<div style="display: flex; justify-content: center;">
<iframe style="aspect-ratio: 16 / 9; width: 100% !important;" src="https://www.youtube.com/embed/NN6V2ItLWSI" title="Oakestra Community Talk | WebAssembly meets Oakestra - Luca Marchiori" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
</div>

{{< card-grid >}}
{{< link-card description="Follow Oakestra on X" href="https://twitter.com/oakestra" >}}
{{< link-card description="See Oakestra on YouTube" href="https://youtube.com/oakestra" >}}
{{< /card-grid >}}

### Oakestra Developer and Maintainer Meetups

The Oakestra community continues to grow with in-person meetups, hackathons, and social gatherings.  
  
![office-meetup](oakestra-office-meetup.jpg)

Oakestra was also present at the Oktoberfest in Munich 🍻:

![oktoberfest](oakestra-oktoberfest.jpg)

We are incredibly excited about the opportunities the Bass release unlocks for developers and end users alike. Whether you’re a veteran in edge computing or just starting out, this update is designed to simplify complexity and inspire innovative solutions.

Happy orchestrating! 🌳💻