---
title: "Check your Installation"
summary: "Check if your oakestra installation is working"
draft: false
weight: 10103010000
toc: true
seo:
  title: "Check your Oakestra Environment" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

In this wiki we'll help you check if your Oakestra installation is up and running as you expected.

## Check your clusters status
This is how you can check your clusters' status.

{{< tabs "Check_Clusters" >}}
{{< tab "Use the Terminal" >}}
Simply run:
```bash
oak cluster ls
```



Did you know? You can install the Oakestra CLI on any machine and manage your Oakestra cluster remotely. Check [our CLI wiki](../../deploy-app/deploy-cli/).
{{< /tab >}}
{{< tab "Use the Dashboard" >}}

Reach your Oakestra Dashboard at `http://<ROOT_ORCHESTRATOR_IP>`, log in and click the *Available Clusters* section.

![](dashboard.png)

{{< /tab >}}
{{< tab "Use the APIs" >}}

Either directly perform a `GET` request to: `http://<ROOT_ORCHESTRATOR_IP>:10000/api/clusters`

Or use the Swagger API documentation available at `http://<ROOT_ORCHESTRATOR_IP>:10000/api/docs`

{{< /tab >}}
{{< /tabs >}}


{{< callout context="tip" title="Oakestra Addons" icon="outline/rocket" >}}

Check out [addons](../../../concepts/oakestra-extensions/addons) for the Oakestra customization options!

{{< /callout >}}


## Check the installed components

You can check the status of your Oakestra components as follows:

{{< tabs "Check_Status" >}}
{{< tab "🌳 Check your Root Orchestrator" >}}
In the root orchestrator machine, run:

```bash
oak doctor root
```

This will show you if all components are running correctly.
{{< /tab >}}
{{< tab "🪾 Check your Cluster Orchestrator" >}}
In each cluster, the orchestrator machine runs

```bash
oak doctor cluster
```

This will show you if all components are running correctly.
{{< /tab >}}
{{< tab "🦾 Check your Worker Node" >}}
In each worker node machine, run

```bash
oak doctor worker
```

This will show you if the NodeEngine and NetManager components, the living soul of your worker node, are up and running as expected.
{{< /tab >}}
{{< /tabs >}}


{{< callout context="caution" title="Something is not working?" icon="outline/alert-triangle">}}
If something is not working, please check out our [Troubleshooting Guide](../../../manuals/troubleshooting).
{{< /callout >}}
