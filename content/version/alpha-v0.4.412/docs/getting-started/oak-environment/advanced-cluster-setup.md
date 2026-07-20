---
title: "Advanced Cluster Setup"
summary: ""
draft: false
weight: 10102030000
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

Having one root orchestrator and one cluster orchestrator on one device is a great way to start using Oakestra, but the true power of the system lies in its federated architecture.

## Install Root, Cluster and Worker Components

This guide will walk you through deploying the stand-alone Oakestra components so you can mix and match them to compose the infrastructure you need. Remember, for a valid Oakestra installation, you need at least: 1x Root Orchestrator 🌳, 1x Cluster Orchestrator 🪾 , and 1x Worker Node 🦾.

Then, you can add additional Cluster Orchestrators and Worker Nodes to extend the infrastructure as much as you need.

For example:

- Your Root 🌳 and Cluster 🪾 Orchestrator can run in a single node, and then you connect 10 more servers, installing a Worker Node 🦾 in each one of them.
- Your Root Orchestrator 🌳 runs in a standalone device, and then you deploy three Cluster Orchestrators 🌳 + Worker Node 🦾 on 3 separate servers. This way, you have one root and 3 clusters of 1 node each.
- Your Root Orchestrator 🌳 runs in a standalone device; you connect and install a Cluster Orchestrator 🪾 on 3 separate machines (respectively 𝞨, 𝞫, and 𝞱). Finally, you install the Worker Node 🦾 on 30 other Linux machines, and you connect 20 of them to 𝞨, 5 of them to 𝞫, and an additional 5 to 𝞱.

You probably got the point by now! Let’s learn how you can compose the infrastructure according to your needs.

Here, the instructions on how to install the standalone components and where to install them are up to you.

{{< tabs "Requests" >}}
{{< tab "🌳 Root Orchestrator" >}}

{{<svg "architecture/Arch-Root">}}

### Create a Root Orchestrator

The Root Orchestrator component will manage your clusters. You will interact with the root orchestrator to deploy and manage your applications via the [oak](../../deploy-app/deploy-cli/) terminal command, the [dashboard](../../deploy-app/deploy-dashboard/) or the [APIs](../../../reference/api/deploy-api/).

#### Installation

1. Install the `oak` cli in your root orchestrator machine:

```bash
curl -sfL oakestra.io/oak.sh | bash
```

2. Install the Root orchestrator using:

```bash
oak install root alpha-v0.4.412
```

_What is this doing?_ This script downloads the required files to the directory `~/.oakestra/root_orchestrator`. From there it executes the root orchestrator using docker compose.

{{< /tab >}}

{{< tab "🪾 Cluster Orchestrator" >}}

{{<svg "architecture/Arch-Cluster">}}

### Create a Cluster Orchestrator

You can deploy a cluster orchestrator in the same machine as your root or in a separate machine. You can create as many clusters as you need by deploying multiple cluster orchestrators (**each one on a different machine**). This component will manage the worker nodes and reports to the root orchestrator aggregated information about the cluster status.

#### Installation

1. Install the `oak` cli in your root orchestrator machine:

```bash
curl -sfL oakestra.io/oak.sh | bash
```

2. Configure your Cluster Orchestrator name and the address of the root machine.

```bash
oak config set root_orchestrator_address <IP OF ROOT ORCHESTRATOR> #Only if different than current machine
oak config set cluster_name <UNIQUE NAME FOR YOUR CLUSTER>
```

3. Install and startup your cluster

```bash
oak install cluster alpha-v0.4.412
```

**Be carefull:** this install script asks you to confirm the address, name and position of your cluster.

- The `cluster address` MUST be an address reachable from the root (by default the installation script uses the IP of the default network interface of the cluster machine).
- The position is expressed with geographical coordinates in the format `latitude,longitude,radius`. The radius is in meters. By default it guesses your location but you can change it during installation.
- **If you agree with the defaults, just press ENTER**

_What is this doing?_ This script downloads the required files to the directory `~/.oakestra/cluster_orchestrator`. From there it executes the root orchestrator using docker compose.

You can register as many cluster orchestrators with the root orchestrator as you would like. Repeat the above command on a new device and with a unique `Cluster Name` and `Cluster Location`.

{{< /tab >}}
{{< tab "🦾 Worker Node" >}}

{{< svg "deploy-worker" >}}

### Create a Worker Node

If you have at least a running **Root Orchestrator** and at least one **Cluster Orchestrator** you can add as many new worker nodes to each cluster as you need.

#### Installation

For each worker node you want to install, repeat the following procedure:

1. Install the `oak` cli in your worker node machine:

```bash
curl -sfL oakestra.io/oak.sh | bash
```

2. (Optional) Set the root orchestrator address **if that's running on a different machine**

```bash
oak config set root_orchestrator_address <IP OF ROOT ORCHESTRATOR> #Only if different than current
```

3. Install and run your worker node:

```bash
oak install worker alpha-v0.4.412
```

At the end of the installation, it will ask you the following:

- To select the cluster orchestrator where you want to attach this worker node
- If you want to start up the worker node right away (y/N)

If you decide to not start your worker node right away, you can run it in background later on running:

```bash
oak worker -d
```

N.b. The cluster selector during the installation shows you the default IP address of the cluster detected by the root orchestrator.
If within your cluster network, you prefer an internal address where the cluster orchestrator is still reachable, check [Advanced Installation Options](../../../manuals/advanced-cluster-configuration)

{{< /tab >}}
{{< /tabs >}}

<hr>

---

{{< callout context="caution" title="Network Configuration" icon="outline/alert-triangle">}}
If you run into a restricted network (e.g., on a cloud VM) you need to configure the firewall rules and the NetManager component accordingly. Please refer to: [Firewall Setup](../../../manuals/firewall)
{{< /callout >}}
