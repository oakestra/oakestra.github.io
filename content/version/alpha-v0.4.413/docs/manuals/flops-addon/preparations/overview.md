---
title: "FLOps Preparations Overview"
summary: ""
draft: false
weight: 10311020100
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

{{< callout context="note" title="Machine Compatibility" icon="outline/server" >}}
  FLOps can run on a wide range of Linux-based devices.

  It supports both ARM64 and AMD64 architectures.
{{< /callout >}}

### Preparing the Worker Nodes

Most FLOps services can run on any of the orchestrated worker nodes.
Building multi-platform container images and performing ML/FL model training on aggregated data requires extra considerations.
To allow FLOps to work as intended, you have to ensure that at least one of your worker nodes can build images and collect data for training.
You can use a single node to build images and collect training data or two separate ones, one of which will build images and the other aggregate data.

{{< link-card
  title="Image Building Preparation"
  description="Prepare a worker node to build (multi-platform) container images"
  href="/docs/manuals/flops-addon/preparations/image-builder-workers/"
>}}

{{< link-card
  title="ML Training Data Preparation"
  description="Prepare a worker node to aggregate data for training" 
  href="/docs/manuals/flops-addon/preparations/learner-workers/"
>}}

### Set up FLOps Management

Clone the [FLOps repository](https://github.com/oakestra/addon-FLOps) onto the same machine where you run your Oakestra root orchestrator.
```bash
git clone git@github.com:oakestra/addon-FLOps.git 
```

Set the required environment variables - e.g. by adding them to your `/etc/bash.bashrc` file:
```bash
export SYSTEM_MANAGER_IP=<IP-A>
export FLOPS_MANAGER_IP=<IP-B>
export FLOPS_MQTT_BROKER_IP=<IP-C>
export FLOPS_IMAGE_REGISTRY_IP=<IP-D>
export ARTIFACT_STORE_IP=<IP-E>
export BACKEND_STORE_IP=<IP-F>
```

{{< callout context="note" title="Hosting location for the FLOps management suite" icon="outline/info-circle" >}}
  Currently, FLOps is intended to be co-hosted on the same node as your Oakestra root orchestrator.
control plane.
  This means you should use the same public IP for all variables above.

  We intend to split this up to allow hosting FLOps management components on different machines for better scalability.
{{< /callout >}}


Start the management `docker compose`:
```bash
docker compose -f <path-to-your-pulled-flops-repo>/docker/flops_management.docker_compose.yml up --build -d
```
Or use this `oak-cli` command:
```bash
oak addon flops re
```

{{< link-card
  title="FLOps CLI commands"
  description="Explore the oak-cli commands that help you to work with FLOps." 
  href="/docs/reference/cli/oak_addon_flops/"
>}}

{{< callout context="note" title="Resetting your FLOps Management" icon="outline/info-circle" >}}

  The FLOps management suite contains several different components that store information and data persistently.
  This storage usually helps to avoid duplicate work by reusing, e.g., the stored images instead of building them anew.
  However, for certain experiments or development workflows, a clean, unpopulated management suite is required.

  **When clearing your FLOps management, remove all related running apps and services in your Oakestra deployment.**

  Here are a few different approaches to clearing your FLOps management suite:
  - Restart the docker compose: This will clean everything but the image registry. (`oak addon flops re`)
  - `oak addon flops clear-registry`: Only clears the image registry.
  - `oak addon flops redb`: Only clears the FLOps manager DB. (Removes all information about the current/last FLOps projects from the DB.)

  If you want to make sure that your system is entirely free of any previous stains, ensure to [clear your local containerd images](/docs/manuals/debugging/running-containers/).
{{< /callout >}}
