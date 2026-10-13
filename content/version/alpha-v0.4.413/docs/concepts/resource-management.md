---
title: "Resource Management"
summary: ""
draft: false
weight: 10202000000
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

Oakestra's resources are managed by the **Resource Abstractor**. An instance of this component is deployed at the root orchestator and at each cluster
orchestrator.

{{< svg-small "resources/arch-resource-abstractor" >}}

The resource abstractor exposes a REST API by which resource availability statistics can be delivered, and available resources queried. The data is stored in a mongo database. The resource abstractor stores information on the available resources reported by the cluster and nodes, and on the statuses of services and their instances.

{{< callout context="tip" title="Did you know?" icon="outline/rocket" >}}

Since the Conga release, Oakestra utilises the resource abstractor at the root **and** cluster.

{{< /callout >}}

## Canonical Resources

Oakestra differentiates between canonical and non-canonical resources.

| Canonical Resources | Non-canonical Resources |
| :--- | :--- |
| Worker and cluster are assumed to have (e.g. vCPUs, Memory) | Supplementary resources (e.g. electricity price, TPUs) |
| Static aggregation scheme | Automated aggregation scheme |
| Always collected by resource abstractor | Always collected by resource abstractor |
| Always served by resource abstractor | Only served when explicitly requested |

## Resource Aggregation

The cluster orchestrator aggregates resources from its worker nodes and abstracts the cluster’s internal composition to the root orchestrator.
Canonical and non-canonical resources are aggregated in the following ways:
1. **Canonical Resources:** A static, hard-coded aggregation scheme is used for each resource type. E.g. vCPUs are summed up, for memory usage the
average is calculated, and the available runtimes are appended to a list.
2. **Non-canonical Resources:** Since the cluster orchestrator has no prior knowledge on the resource types a worker might report, it falls back on the following schema based on the resource value type:
    * **Number:** Summate
    * **String:** Append to list
    * **List:** Flatten to list

{{< callout context="note" icon="outline/info-circle">}}
Aside from scheduling, the resource abstractor enables the Addons system for the root and cluster orchestrator. Read more on [extending Oakestra](../oakestra-extensions/addons) here.

{{< /callout >}}