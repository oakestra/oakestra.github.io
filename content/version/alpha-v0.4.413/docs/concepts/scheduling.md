---
title: "Scheduling"
summary: ""
draft: false
weight: 10203000000
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

## How does the scheduling work in Oakestra?

Oakestra's architecture consists of a two-tier design where resources are organized into clusters. Each cluster represents an aggregation of all its resources. When a job is submitted, it is first scheduled to a cluster. The cluster's scheduler then determines the target worker node to execute the job.  

{{< svg "scheduling/cluster-worker-selection" >}}

The **scheduler component** is implemented as a lightweight Go component. It receives a job description and returns an allocation target. Scheduling in Oakestra operates at two levels:

1. **Root Scheduler:** Determines a suitable cluster for the job.
2. **Cluster Scheduler:** Selects the appropriate worker node within the chosen cluster.

To abstract the scheduling targets (candidates), Oakestra employs a **Resource Abstractor**. This service transforms clusters and worker nodes into generic candidates with defined capabilities. This abstraction ensures compatibility between cluster and worker selection algorithms.

## Scheduler Architecture

{{< svg "scheduling/scheduler-arch" >}}

The scheduler operates in the following manner:

1. It receives requests in the form of service desriptors from the root or cluster orchestrator via an exposed API endpoint
2. The scheduling jobs are enqueued in a task queue
3. The scheduler queries the [resource abstractor](../resource-management) for a list of available candidates and their resources
4. An implemented scheduling algorithm is called to evaluate the candidates with respect to the service descriptor
5. The resulting candidate is communicated back to the orchestrator

## Scheduling Algorithms

The Scheduler supports linking in different scheduling algorithms through the Go modules system. This allows the scheduler to optimise for different
criteria or consider different resources.

Scheduling algorithms typically evaluate the available candidates in two passes:
* **Filtering Stage:** All candidates are filtered with respect to the minimum service requirements and constraints
* **Evaluation Stage:** The remaining candidates are sorted according to an optimisation criterium. The best candidate is returned


### Interested Resources

Each scheduling algorithm provides information on which resource types it considers. The interested resources are passed to the resource abstractor when
quering the available candidates. The resource abstractor will return the available candiates with all of the canonical resources, and the interested non-canonical resources.

{{< callout context="note" icon="outline/info-circle">}}
The concept of canonical and non-canonical resources is new to Oakestra since Conga. You can read more under [Resource Management](../resource-management/#canonical-resources)
{{< /callout >}}

### Contraints

Constrains are requirements a service may have, that are not resource demands. Currently only direct mapping constraints are implemented.

#### Direct mapping positioning

The **direct mapping** constraint allows developers to explicitly define a list of target clusters and nodes in the deployment description. The scheduling algorithm will then operate only on the active clusters or nodes specified in the list.

For example, the following constraint:

```json
"constraints":[
            {
              "type":"direct",
              "node":"xavier1",
              "cluster":"cluster1"
            }
          ]
```
limits the deployment to the node `xavier1` of the cluster `cluster1`. While the following constraint:

```json
"constraints":[
            {
              "type":"direct",
              "cluster":"gpu"
            }
          ]
```
limits the deployment to all worker nodes within the cluster `gpu`.