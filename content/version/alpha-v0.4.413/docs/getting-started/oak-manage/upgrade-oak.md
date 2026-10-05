---
title: "Update or Uninstall your Oakestra Components"
summary: "A quick guide on how to update your Oakestra Components"
draft: false
weight: 10103020000
toc: true
seo:
  title: "Update your Oakestra Components" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

In this wiki you'll learn how to Uninstall or Update your Oakestra installation.

## Uninstall Oakestra Components

{{< tabs "Uninstall" >}}
{{< tab "Single Machine" >}}
If you have a single machine setup where all your components (Root, Cluster and Worker node) are installed in the same machine, then you can run:

```bash
oak worker stop
oak uninstall worker && oak uninstall cluster && oak uninstall root
```

{{< /tab >}}
{{< tab "Worker Node" >}}


In each worker node machine run:
```bash
oak worker stop
oak uninstall worker
```


{{< /tab >}}
{{< tab "Cluster Orchestrator" >}}

In each cluster orchestrator machine run:
```bash
oak uninstall cluster
```

{{< /tab >}}
{{< tab "Root Orchestrator" >}}

In your root orchestrator machine run:
```bash
oak uninstall root
```
{{< /tab >}}
{{< tab "Cleanup" >}}

Bruteforce removal of all Oakestra containers, volumes, images, and worker binaries.
In each machine, run:
```bash
oak uninstall cleanup
```
{{< /tab >}}
{{< /tabs >}}

## Update Oakestra Components

First, find out what version you're currently running.
In your root orchestrator machine, run:

```bash
docker ps | grep root-system-manager: | awk '{print $2}' | cut -d':' -f2
```

Then, how can you update your Oakestra to the latest version?
{{< tabs "Update" >}}
{{< tab "current version <0.4.410" >}}

First you need to uninstall the old Oakestra components
On each worker node run:
```bash
sudo NodeEngine stop
curl -sfL oakestra.io/oak.sh | bash
oak uninstall worker
```
And follow the on-screen instructions

On each **cluster** orchestrator and **root** orchestrator node run:
```bash
curl -sfL oakestra.io/oak.sh | bash
oak uninstall cleanup #this command will cleanup the previous oakestra installation
```

Then, follow the installation instructions from scratch.

{{< /tab >}}
{{< tab "current version >=0.4.410" >}}

You're currently on the latest version!
Future version will include a `oak update` command. Stay tuned.

{{< /tab >}}
{{< /tabs >}}
