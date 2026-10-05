---
title: "High-Level Setup Overview"
summary: ""
draft: false
weight: 10102010000
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

{{< svg "architecture" >}}

Oakestra lets you deploy your workload on devices of any size, from a small Raspberry Pi to a cloud instance on GCP or AWS. The tree structure enables you to create multiple clusters of resources.

* The **Root Orchestrator** manages different clusters of resources. The root only sees aggregated cluster resources.
* The **Cluster Orchestrator** manages your worker nodes. This component collects real-time resource information and schedules your workloads to the best-matching device.
* A **Worker** is where your workloads are executed (e.g., your containers).

{{< callout context="note" title="Did you know?" icon="outline/rocket">}} Since the stable Accordion release, Oakestra supports both container and unikernel virtualization targets. {{< /callout >}}


{{< callout context="caution" title="Minimum System Requirements" icon="outline/alert-triangle">}}
Oakestra CLI:
- 10MB of Disk
- Windows, Linux, or macOS
- AMD64 or ARM64 architecture
- 50MB of RAM

Root and Cluster Orchestrator (combined):
- Docker + Docker Compose v2
- 5GB of Disk
- 500MB of RAM
- ARM64 or AMD64 architecture
- Linux-based OS

Worker Node:
- Linux-based OS with `iptables` compatibility
- 50MB of space
- 100MB RAM
- ARM64 or AMD64 architecture
{{< /callout >}}
