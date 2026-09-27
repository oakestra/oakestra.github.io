---
title: "Observability overview"
summary: "Choose a task for deploying and operating local telemetry"
draft: false
weight: 10313010000
toc: false
---

Oakestra collects control-plane logs and metrics on each orchestrator host. Read the [Observability concepts](../../../concepts/observability/overview/) for the architecture and the boundary between standalone Root, standalone Cluster, and 1-DOC. Then choose the task you need:

{{< screenshot src="img/observability stack/All dashboards.png" alt="Three provisioned Oakestra dashboards in Grafana" >}}

1. [Deployment and upgrades](../deployment/) — match configuration and images, generate expected-container inventory, and migrate from Promtail.
2. [Log collection and storage](../log-collection/) — inspect Alloy, normalized levels, Loki, and log history.
3. [Metrics collection and storage](../metrics-collection/) — check exporters, Prometheus targets, labels, and retention.
4. [Logs dashboard](../logs-dashboard/) — search, filter, and follow a shared ID across components.
5. [Log Statistics dashboard](../log-statistics-dashboard/) — review log-volume and severity trends.
6. [Resources dashboard](../resources-dashboard/) — inspect host and container resource use.
7. [Log alerts](../log-alerts/) — understand error and stacktrace detection.
8. [Container alerts](../container-alerts/) — diagnose missing and restarting containers.
9. [Resource alerts](../resource-alerts/) — set CPU, memory, and disk thresholds.
10. [Notifications](../notifications/) — configure a webhook or email and test delivery.
11. [Validation and troubleshooting](../validation-and-troubleshooting/) — confirm the pipeline works and diagnose common failures.

For application logging changes, use [Writing Python logs](../../../contribution-guide/writing-python-logs/) in the Contribution Guide.
