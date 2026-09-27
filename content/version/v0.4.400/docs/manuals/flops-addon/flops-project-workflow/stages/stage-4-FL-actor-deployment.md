---
title: "Stage 4: FL-Actors Deployment"
summary: ""
draft: false
weight: 309030205
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
asciinema: true
---

The FL actor images stored in the FLOps image registry now get deployed on matching worker nodes.
Thanks to its rather lightweight computations, the aggregator service can be deployed on an arbitrary worker node, whereas learner services can only be deployed on dedicated notes that have the `FLOps-learner` add-on enabled.
The aggregator image has a superset of the learner image dependencies, so pulling and deploying both actors takes about the same amount of time.

{{< callout context="tip" title="*Aggregator Size*" icon="outline/weight" >}}

The aggregator is the prime target for tracking results and performing other MLOps tasks, including logging the trained model with its dependencies.
To do so, the aggregator keeps a copy of the model that it updates to create the global FL model.
It needs to be capable of setting and extracting this model's parameters.
For this, the aggregator is calling the user-defined get/set model parameter methods, which rely on the model ML dependencies.
That is why the aggregator requires the same dependencies as the learners even though it is not training itself.
In addition, the aggregator needs mlflow and related dependencies to perform MLOps tasks.

{{< /callout >}}

Each actor service needs some time to spin up properly and connect to one another.
The learner services need to fetch and process their local training data before establishing a connection with their aggregator.

```bash
╭──────────────────────┬──────────────────────────┬────────────────┬──────────────────┬──────────────────────────╮
│ Service Name         │ Service ID               │ Instances      │ App Name         │ App ID                   │
├──────────────────────┼──────────────────────────┼────────────────┼──────────────────┼──────────────────────────┤
│                      │                          │                │                  │                          │
│ observ11e3c5ca7c4c   │ 679cbbaeaf4c1923eb5df1b4 │  0 RUNNING     │ observatory      │ 679cbbadaf4c1923eb5df1b2 │
│                      │                          │                │                  │                          │
├──────────────────────┼──────────────────────────┼────────────────┼──────────────────┼──────────────────────────┤
│                      │                          │                │                  │                          │
│ trackinge3afed0047b0 │ 679cbbaeaf4c1923eb5df1b5 │  0 RUNNING     │ observatory      │ 679cbbadaf4c1923eb5df1b2 │
│                      │                          │                │                  │                          │
├──────────────────────┼──────────────────────────┼────────────────┼──────────────────┼──────────────────────────┤
│                      │                          │                │                  │                          │
│ aggr11e3c5ca7c4c     │ 679cbbaeaf4c1923eb5df1b6 │  0 RUNNING     │ projc911185f81c4 │ 679cbbaeaf4c1923eb5df1b3 │
│                      │                          │                │                  │                          │
├──────────────────────┼──────────────────────────┼────────────────┼──────────────────┼──────────────────────────┤
│                      │                          │                │                  │                          │
│                      │                          │  0 RUNNING     │                  │                          │
│ flearner11e3c5ca7c4c │ 679cbbafaf4c1923eb5df1b7 │                │ projc911185f81c4 │ 679cbbaeaf4c1923eb5df1b3 │
│                      │                          │  1 RUNNING     │                  │                          │
│                      │                          │                │                  │                          │
╰──────────────────────┴──────────────────────────┴────────────────┴──────────────────┴──────────────────────────╯
```
