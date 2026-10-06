---
title: "Metrics collection and storage"
summary: "Understand Prometheus, host exporters, container metrics, and retention"
draft: false
weight: 10313300000
toc: true
---

Prometheus scrapes local targets every 15 seconds with a 10-second timeout. `node_exporter` measures the physical host's CPU, memory, filesystems, disks, and network; cAdvisor measures Docker container resources; the Docker-state exporter supplies running state and automatic restart counters. Cluster and 1-DOC Prometheus also scrape Cluster Manager application metrics. The Root's Prometheus does not contain remote Cluster metrics.

## Identity and ownership

cAdvisor keeps Oakestra-managed containers and maps Docker metadata to `cluster_id` and `compose_service`. Host metrics use `host_scope=root`, `cluster`, or `one-doc` and an `instance` label. A physical 1-DOC host is measured once even though it runs both Root and Cluster services; its host metrics do not receive a fabricated `cluster_id`.

The inventory generator writes expected service replica counts and six resource alert thresholds into a node_exporter textfile. This lets alerts detect containers that never started or disappeared, as well as a missing inventory. Generate it from the same resolved Compose configuration used for deployment, as shown in [Deployment and upgrades](../deployment/). cAdvisor alone cannot provide a reliable Docker restart-policy counter; the Docker-state exporter supplies that signal.

## Retention and security

Prometheus stores data in a named volume, keeping at most seven days or approximately 1 GB of persistent blocks, whichever policy removes old blocks first. The 1-GB limit is not an exact disk quota because the active head, WAL, and compaction use extra space. Deleting the volume removes its history. This policy is independent of Loki's query-window limit and Loki's separate storage behavior.

The metrics exporters and Prometheus are internal to the deployment in normal bridge mode. cAdvisor's diagnostic UI is available only from the host at `http://127.0.0.1:8081` (Root or 1-DOC) or `http://127.0.0.1:8082` (Cluster). In host-network overrides, Prometheus is exposed only on loopback at `10010` for Root and `10009` for Cluster. Docker and containerd socket mounts remain security-sensitive even when mounted read-only.

## Check targets

Open Grafana **Explore** and select the `Prometheus` datasource. In **Builder**, choose the `up` metric and leave Label and Value filters empty; alternatively, switch to **Code** and type `up`. Click **Run query**. Each configured target should return `1` when its scrape succeeds (`0` means the scrape failed). On a standalone Root host you can also query Prometheus from its container:

```bash
docker exec root_prometheus \
  promtool query instant http://127.0.0.1:9090 up
```

Use `cluster_prometheus` on a standalone Cluster or `prometheus` in 1-DOC. For host and container examples and units, continue to the [Resources dashboard](../resources-dashboard/).
