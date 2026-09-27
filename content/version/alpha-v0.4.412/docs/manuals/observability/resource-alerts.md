---
title: "Resource alerts"
summary: "Configure warning and critical host CPU, memory, and disk alerts"
draft: false
weight: 10313900000
toc: true
---

Grafana provisions six Prometheus rules for host resources and one rule for missing threshold configuration:

| Resource | Warning | Critical | Pending time, warning / critical |
| --- | --- | --- | --- |
| CPU used | At least 80% | At least 90% | 5 minutes / 2 minutes |
| Memory available | At most 15% | At most 10% | 5 minutes / 2 minutes |
| Disk free | At most 15% | At most 10% | 5 minutes / 2 minutes |

Warning ranges stop where critical begins, preventing simultaneous warning and critical instances for one resource. CPU uses a five-minute non-idle rate. Disk rules evaluate real, writable, non-zero filesystems and retain `device` and `mountpoint`. A seventh rule reports missing or duplicate threshold series after one minute.

In **Alerting → Alert rules**, expand **Oakestra host resource alerts** to inspect the provisioned rules. The [Container alerts](../container-alerts/) page shows where these groups appear in Grafana.

Configure deployment-specific thresholds before running the startup script or [inventory generator](../deployment/):

```bash
export OAKESTRA_RESOURCE_CPU_WARNING_PERCENT=80
export OAKESTRA_RESOURCE_CPU_CRITICAL_PERCENT=90
export OAKESTRA_RESOURCE_MEMORY_WARNING_AVAILABLE_PERCENT=15
export OAKESTRA_RESOURCE_MEMORY_CRITICAL_AVAILABLE_PERCENT=10
export OAKESTRA_RESOURCE_DISK_WARNING_FREE_PERCENT=15
export OAKESTRA_RESOURCE_DISK_CRITICAL_FREE_PERCENT=10
```

All values must be finite percentages between 0 and 100. CPU warning must be lower than CPU critical; available-memory and free-disk warning must be higher than their critical values. The generator rejects invalid or misordered values without replacing an existing valid inventory file. For manual Compose deployment, regenerate that file after changing a threshold and wait for node_exporter's next scrape.

Dashboard variables cannot configure server-side Grafana alerts. The generator publishes six `oakestra_resource_alert_threshold_percent` series through node_exporter, which the provisioned rules read. Check their count with:

```promql
count by (host_scope, instance) (oakestra_resource_alert_threshold_percent{job="node-exporter"})
```

Each local host should report six series. Host alerts carry `host_scope` and `instance`, not an invented `cluster_id`. In 1-DOC, Root and Cluster share one physical host; the alert points to the corresponding panel in **[Oakestra] Resources**. Resource alerts reuse the selected [contact point](../notifications/) and keep firing briefly after recovery to reduce notification flapping.
