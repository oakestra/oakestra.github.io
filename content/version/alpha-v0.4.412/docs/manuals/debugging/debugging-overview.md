---
title: "How to start debugging?"
summary: "Debugging in Oakestra"
draft: false
weight: 10312010000
toc: true
seo:
  title: "Debugging in Oakestra" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

{{< callout context="tip" title="Suffering from a bug?" icon="outline/settings-question" >}}
Oakestra offers built-in tools and clear workflows to help you identify, diagnose, and resolve issues quickly. Whether you’re facing unexpected application behavior, slow performance, or deployment failures, Oakestra provides a streamlined process for gathering diagnostic information and guiding you toward solutions.
{{< /callout >}}

At this stage, you should be familiar with the steps of configuring and running any application within Oakestra and know the main parts of the operations. If not, please refer to the [Getting Started](/docs/getting-started) section and other relevant sections of this documentation.

## Check orchestration logs

The first debugging step is to identify where the issue is coming from. The Root and Cluster orchestrators are the main components of the Oakestra system. They are responsible for managing the applications and the workers in the cluster.
You have two ways to access operational logs from the components 

### Using Grafana

Standalone Root and Cluster deployments expose Grafana at `http://<root-orchestrator-ip>:3000` and `http://<cluster-orchestrator-ip>:3001`, respectively. Each instance reads its own local Loki and Prometheus.

{{< callout context="note" title="1-DOC deployments" icon="outline/info-circle" >}}
1-DOC runs Root and Cluster on one host and uses one Grafana instance at `http://<host-ip>:3000`. Its separate Logs, Log Statistics, and Resources dashboards read the shared local Loki and Prometheus; there is no second Grafana on port `3001`.
{{< /callout >}}

The provisioned Logs dashboard supports component and severity selection, full-line search, structured-field filters, time navigation, and shared-ID correlation links. The Log Statistics and Resources dashboards cover trends and resource usage separately. See the [Observability manuals](../../observability/overview/) for queries, local-data boundaries, and troubleshooting steps.

{{< screenshot src="img/observability stack/Logs dashboard.png" alt="The current Oakestra Logs dashboard with filters and recent records" >}}

### Using Docker logs 

Run `docker ps -a` on the orchestrator machine to check all running containers. 

![](control-plane-docker-logs-1.png)

Then simply run `docker logs <container name>` to check its logs. 

![](control-plane-docker-logs-2.png)

The logs are your best friend in identifying the root cause of the issue. Specially check for runtime errors, warnings, and exceptions.

## Run diagnostics commands

You can also run live diagnostics commands to check the status of the components using `oak-cli`. 

{{< link-card
  description="See CLI command descriptions for details"
  href="/docs/reference/cli/"
  target="_blank"
>}}

Continue reading to learn more about the debugging specific aspects of the Oakestra ecosystem.
