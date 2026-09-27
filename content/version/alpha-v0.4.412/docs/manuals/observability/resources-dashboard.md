---
title: "Resources dashboard"
summary: "Read host and Oakestra container CPU, memory, and disk measurements"
draft: false
weight: 10313600000
toc: true
---

**[Oakestra] Resources** is provisioned from JSON and queries the local `Prometheus` datasource. A standalone Root or Cluster shows its own physical host and managed containers; 1-DOC shows one physical host and containers from both orchestration levels.

{{< screenshot src="img/observability stack/Resources dashboard.png" alt="The Resources dashboard showing host CPU, memory, and filesystem panels" >}}

## Host panels

Host panels use node_exporter. They show CPU busy percentage and trend, memory used and available, root-filesystem usage, usage by real mountpoint, and disk read/write throughput by device. These panels describe the physical machine. Selecting a different Cluster or Component does not change them, including in 1-DOC.

## Container panels

Container panels use cAdvisor for CPU and memory working set by `cluster_id` and `compose_service`, plus top-N current consumers. **Cluster**, **Source**, and **Component** filter these panels; **Top N** limits each ranking. Replicas of one Compose service are aggregated.

Container CPU is a percentage of one core: `100%` means one fully occupied CPU core, so a multicore service can exceed `100%`. Memory working set subtracts inactive file cache from cgroup usage. It can still include active cache and is not the same as Python heap, RSS, or the memory limit. One `docker stats` snapshot may differ from a Prometheus rate evaluated over a longer interval.

Links between Resources, Logs, and Log Statistics preserve compatible selections and the time range. Quick ranges stop at seven days, matching Prometheus time retention. The 1-GB size policy can remove older blocks sooner, and the WAL and active head consume additional disk space.

To check the datasource in Grafana **Explore**, select `Prometheus` and run:

```promql
100 * (1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m])))
100 * (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)
sum by (cluster_id, compose_service) (
  rate(container_cpu_usage_seconds_total{compose_service!=""}[5m])
) * 100
```

For another view, import a community dashboard through **Dashboards → New → Import** and map it to the local `Prometheus` datasource. Imported dashboards can assume different job names or labels and are stored in the Grafana volume; they are not provisioned or version-controlled by Oakestra. The [Node Exporter Full dashboard](https://grafana.com/grafana/dashboards/1860-node-exporter-full/) is one possible starting point.
