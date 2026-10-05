---
title: "Clustered Hierarchical FL"
summary: ""
draft: false
weight: 10311050200
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

{{< callout context="caution" title="Prerequisites" icon="outline/alert-triangle">}}
  - You understood how FLOps performs [classic FL](../../../../concepts/flops/overview)
  - You have carefully read the [base-case FLOps project workflow](../../flops-project-workflow/overview/)
  - You are familiar with [the structure of FLOps compatible ML Git Repositories](../../customizations/ml-git-repo/)
{{< /callout >}}

Different FL architectures exist to support large-scale FL environments.
FLOps wants to benefit from the unique three-tiered Oakestra architecture that can utilize geographical clusters with unique vendors.
Such a scenario has two main challenges.
The first challenge is managing a massive number of connections and aggregations.
The second one is reducing the negative impact of straggling learner updates.
The problem with using a single aggregator is that this single aggregator becomes a communication bottleneck.
Additionally, per-round training latency is limited by the slowest participating learner.
Thus, stragglers turn into another bottleneck.

## Relevant FL Architectures

{{< details "**Clustered FL**" open >}}
  {{< svg "clustered-fl" >}}

  The figure shows the Clustered FL (CFL) architecture that groups similar learners into clusters.
  CFL can form clusters based on local data distribution, training latency, available hardware, or geographical location.
  The singular aggregator remains a bottleneck.
  The main challenge for CFL is choosing a suitable clustering strategy and criteria for the concrete use case.
  If the criteria are biased, updates from preferred clusters might be heavily favored, resulting in a biased global model with bad generalization.
  Another task is to properly profile the nodes to match them to the correct cluster.
  The entire cluster suffers if a slow outlier is present in a cluster.
  Too intrusive profiling can lead to compromised privacy.
  CFL does not really solve existing FL scalability issues on its own.
  Its clustering overhead becomes critical with larger numbers of nodes.

{{< /details >}}


{{< details "**Hierarchical FL**" open >}}
  {{< svg "hierarchical-fl" >}}

  The figure depicts the hierarchical FL (HFL) architecture.
  In HFL, the root aggregator delegates and distributes the aggregation task to intermediate aggregators.
  HFL can have multiple layers of intermediate aggregators.
  Each intermediate aggregator and its connected learners resemble an instance of classic FL.
  After aggregating an intermediate model, the intermediate aggregators send their parameters upstream to the root aggregator.
  The root combines the intermediate parameters into global ones and sends them downstream for further FL rounds.

  The proper assignment of learners to aggregators determines the success of one’s HFL setup.
  For example, if too many learners are attached to a given aggregator, that aggregator becomes a bottleneck.
  The intermediate aggregated model can be biased if too few learners are assigned.
  Thus, the infrastructure resources and management costs become unjustified for the small number of learners.
  A management overhead arises with more components, including handling fault tolerance, monitoring, synchronizing, and balancing.
  Bad synchronization can amplify straggler problems.
  Balancing refers to combining and harmonizing intermediate parameters to get a good global model.

  The benefits of HFL are its dynamic scalability and load balancing.
  One can easily add or remove intermediate aggregators and their connected learners.
  Due to this distribution of load and aggregation, each aggregator, including the root, is less likely to face bottleneck issues.
  The downsides of HFL are communication and management overheads.
  More components lead to more transmitted messages.
  These messages all need to be secured and encrypted.
  With more components and nodes, adversaries can take advantage of more possible backdoors.
  HFL provides a powerful way to improve scalability for FL if done right.

{{< /details >}}

## FLOps' Clustered Hierarchical FL

Besides classic FL, FLOps supports clustered hierarchical FL.
Oakestra’s three-tiered layout supports geographically dispersed clusters.
Each cluster has its own cluster orchestrator and set of worker nodes.
This structure naturally alludes to the use of clustered and hierarchical FL.

FLOps uses two different types of aggregators for HFL.
The root and cluster aggregators are deployed as services on worker nodes to distribute computational load.
Only a single root aggregator exists for a given project.
The root aggregator can reside in any cluster.
Each orchestrated cluster hosts a single cluster aggregator.
A cluster aggregator only works with learners inside the same cluster.
This type of 'geographic' clustering is the reason why FLOps’ HFL is a clustered approach.
Root aggregators treat cluster aggregators as plain learners, precisely as in classic FL.
Cluster aggregators are a combination between learner and aggregator.

{{< svg "chfl-architecture" >}}

The figure shows the detailed architecture of how FLOps realizes clustered HFL.
Every visible element beside the root aggregator is part of a single cluster.
This setup supports multiple clusters.

Because the root aggregator interacts with the cluster aggregators as if they were plain learners, cluster aggregators need to offer the same learner interface.
The cluster aggregator implements the same learner interface and model manager as user ML code repositories.
This approach requires implementing this interface properly and maintaining the state during multiple training cycles.
Therefore, the cluster aggregator needs to be able to modify and access the underlying user ML model.
This ML model is the main reference point for model parameters in a cluster aggregator.

At the start of a new training cycle, the root aggregator calls the cluster aggregator’s `fitModel` method.
It triggers the cluster aggregator’s `handleAggregator` method, which all aggregator types in FLOps have.
The cluster aggregator performs conventional FL training with its learners and fuses new intermediate global parameters *(pink P)*.
Then, it updates its model copy, which is stored in the user’s model manager.
By default, Flower also evaluates the model during training.
The custom FLOps aggregator strategy can store and accumulate evaluation results.
When the root aggregator requests to evaluate the cluster aggregator, it retrieves the stored values from the strategy and context objects.
When the root aggregator calls the cluster aggregator’s `getParameters` method, the cluster aggregator calls its user’s model manager `getParameters` method.
The same applies to setting parameters.

In other words, the cluster aggregator mimics a learner by using the same interface, which works on the same user-provided ML model.
The main differences between a learner and the cluster aggregator are that the fit model method performs classic FL training rounds, the evaluate function retrieves recorded results from the aggregator objects, and the aggregator has no access to data.
This way, FLOps can perform clustered hierarchical FL.

{{< callout context="note" title="Run CHFL yourself" icon="outline/run" >}}
  Feel free to use the `hierarchical_mnist_sklearn_small.json` project SLA for reference and initial testing.
  It is provided by the `oak-cli`.
{{< /callout >}}

{{< callout context="note" title="Create CHFL Project SLAs" icon="outline/file-plus" >}}
  Learn how to turn your classic FL projects into CHFL ones by customizing your SLAs [here](../../customizations/slas/).
{{< /callout >}}
