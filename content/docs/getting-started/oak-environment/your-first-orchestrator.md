---
title: "Create a Single-Node Cluster"
summary: ""
draft: false
weight: 10102020000
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

Let's get you up to speed with the easiest possible setup. You'll be able to run your first Oakestra orchestrator in a few seconds, all on a single device!

### Start the Orchestrators on a Single Machine

{{< callout context="caution" title="System Requirements" icon="outline/alert-triangle">}}
Make sure you first check the system requirements [here](../high-level-view).
{{< /callout >}}

In this guide, we'll perform a single-machine setup. This setup is the easiest way to get started with Oakestra, with a single cluster managed by a single machine. To do so, we'll install the **Root Orchestrator**, the **Cluster Orchestrator**, and the **Worker Node** together, as shown in the following figure.

After the orchestrators are up and running, you can add edge devices as workers to your cluster.

{{< svg-small "deploy-orchestrators" >}}

You can install the **Root** and **Cluster Orchestrator** on a single machine using the following commands:

1. Install the `oak` CLI on your machine:

```bash
curl -sfL oakestra.io/oak.sh | bash
```

2. Perform a full Root + Cluster + Worker installation using:

```bash
oak install full
```

That's it! You should be good to go now.
**Take a look at the example below.**
{{< asciinema key="install" poster="0:15" idleTimeLimit="1">}}

> The installer asks whether to start your worker right away.
> **If you choose not to start it immediately**, you can do so later using:
>
> ```
> oak worker -d
> ```

{{< callout context="note" title="Did you know?" icon="outline/info-circle" >}}
You can set up a multi-cluster infrastructure by installing each **Cluster Orchestrator** and **Worker Node** on a different machine.
Check out the [Advanced Oakestra Clusters Setup](../advanced-cluster-setup) section for more details.
{{< /callout >}}

{{< callout context="caution" title="Network Configuration" icon="outline/alert-triangle">}}
If you run into a restricted network (e.g., on a cloud VM), you need to configure the firewall rules and the NetManager component accordingly. Please refer to: [Firewall Setup](../../../manuals/firewall)
{{< /callout >}}

If the installation command succeeded, you can now check if your cluster is showing up correctly using the command:

```bash
oak cluster ls
```

If your cluster is showing up with one active node, **congratulations! 🎉🎉**

If not, wait a few minutes; the cluster startup might take a while. If still nothing happens, you can refer to the [Troubleshooting Guide](../../../manuals/troubleshooting).

### Shutdown the Components

To stop your **Worker node**, run:

```bash
oak worker stop
```

{{< callout context="note" title="Restart your worker" icon="outline/info-circle" >}}
If you stop your worker without uninstalling it, you can use the following command to restart it in the background:

```bash
oak worker -d
```

{{< /callout >}}

To uninstall your **Worker node**, run:

```bash
oak uninstall worker
```

To stop your **Root and cluster**, run:

```bash
oak uninstall cluster && oak uninstall root
```
