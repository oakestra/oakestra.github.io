---
title: "Container alerts"
summary: "Detect missing, automatically restarting, and unmonitored containers"
draft: false
weight: 10313800000
toc: true
---

Grafana provisions four Prometheus-backed container lifecycle alerts:

| Rule | What it detects |
| --- | --- |
| **Expected container is not running** | Fewer running replicas than the resolved Compose inventory expects for one minute. |
| **Container restarted automatically** | An increase in Docker's restart-policy counter over the last five minutes. |
| **Container monitoring unavailable** | Docker-state or node_exporter collection is unavailable or reports an error for one minute. |
| **Expected container inventory is missing** | Monitoring works, but the inventory is absent or empty for one minute. |

{{< screenshot src="img/observability stack/Alert rules.png" alt="Provisioned container alert rules in Grafana, with the log and host-resource groups listed below" >}}

cAdvisor reports resource usage but lacks the Docker restart-policy counter. The Docker-state exporter supplies running state and restart data. The startup scripts generate `oakestra_expected_container_replicas` from resolved Compose JSON into a node_exporter textfile. This makes a service that never started detectable; merely watching cAdvisor's previously seen series could not do that.

For manual Compose deployment, generate inventory before startup as shown in [Deployment and upgrades](../deployment/). Regenerate it after an intended change in Compose services, profiles, overrides, project name, or scale. Use exactly the same resolved configuration for inventory and deployment. Do not remove an expectation to hide an unplanned failure.

Per-service alert labels include `cluster_id`, `compose_service`, and `compose_project`, so identically named services in separate Compose projects remain distinct. Shared input-health alerts do not fabricate a Cluster label. Missing-service alerts are suppressed while monitoring inputs are unavailable; a recovered per-service alert during such an outage is not proof that the container recovered. Check `oakestra:container_monitoring_ready` (`1` when ready), `oakestra:container_missing_replicas`, and `oakestra:container_restarts_5m` in Grafana Explore.

A manual restart or container recreation is not necessarily an automatic restart-policy event. These rules detect Docker state, not whether a running application responds correctly. They also cannot report a completely failed host without external monitoring.
