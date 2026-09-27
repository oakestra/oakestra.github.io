---
title: "Observability overview"
summary: "The responsibilities of Oakestra's log and metrics services"
draft: false
weight: 10204510000
toc: true
---

Oakestra observes its Root and Cluster control planes with host-local logging, metrics, dashboards, and alerts. Each standalone orchestrator stores its own telemetry; the one-host 1-DOC deployment shares one observability pipeline. This section explains the architecture. For installation and day-to-day use, see the [Observability manuals](../../../manuals/observability/overview/).

## What each part does

| Capability | Component | Purpose |
| --- | --- | --- |
| Log collection | Grafana Alloy | Discovers Docker containers and forwards stdout/stderr. |
| Log storage | Loki | Retains log streams and answers LogQL queries. |
| Log browsing and statistics | Grafana | Shows individual records in **Orchestrator Logs** and trends in **Log Statistics**. |
| Log alerting | Grafana-managed rules | Detects recognized error-level records and stacktrace markers in Loki. |
| Metrics collection | node_exporter, cAdvisor, Docker-state exporter, Prometheus | Measures the host, container resources, and Docker lifecycle state. |
| Resource visualization | Grafana | Shows host and container CPU, memory, and disk in **Resources**. |
| Container and resource alerting | Grafana-managed rules | Evaluates Prometheus metrics for missing/restarting containers and resource exhaustion. |

Alloy transports logs; it does not store them or replace Prometheus. Loki stores log lines, while Prometheus stores numeric time series. Grafana dashboards display existing data; alert rules evaluate independently of whether anyone has a dashboard open. Alloy replaces Promtail—running both against the same containers would duplicate ingestion.

The deployment uses Alloy `v1.17.0`, Loki `2.9.2`, Prometheus `v3.13.2-distroless`, node_exporter `v1.12.1`, cAdvisor `v0.60.5`, and Docker-state exporter `0.7.0`. Grafana provides the user interface. The Compose manifests pin the deployed images and are the authority for their exact tags.

Distributed tracing is not part of this stack. Shared-ID links in the Logs dashboard find records containing the same Oakestra identifier, but do not reconstruct a complete request path.

Continue with [Data flows and local ownership](../data-flows/), [Labels and severity](../labels-and-severity/), then [Storage and security](../storage-and-security/).
