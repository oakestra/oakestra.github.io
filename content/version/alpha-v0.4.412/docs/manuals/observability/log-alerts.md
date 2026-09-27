---
title: "Log alerts"
summary: "Understand how Grafana detects errors and stacktraces in local Loki"
draft: false
weight: 10313700000
toc: true
---

Grafana provisions **Orchestrator error or stacktrace detected** and evaluates it against the instance's local Loki every 30 seconds. The rule groups instances by `cluster_id` and `compose_service`, identifying the affected deployment and Compose service.

In **Alerting → Alert rules**, expand **Oakestra log alerts** to inspect the provisioned rule. The [Container alerts](../container-alerts/) page shows where these groups appear in Grafana.

## Detection

The first path trusts Alloy's normalized indexed `level` label for recognized records: `error` and `critical` match. A valid Info line containing the word `ERROR` does not match. The second path inspects records without a normalized level and recognizes strict legacy error headers, Python traceback headers, Go panic/runtime markers, and related stack frames. It excludes schema-v1 lines so a structured record is not counted a second time. A raw record with an unfamiliar error format may be missed; broad searches for the word “error” would cause false positives.

The rule excludes Grafana, Loki, Alloy, Prometheus, node_exporter, cAdvisor, and Docker-state exporter streams to avoid infrastructure feedback loops. Those logs remain available in the Logs dashboard when **Source** includes Observability. One or more matching lines in a two-minute window create an alert instance. The instance must remain pending for one minute before it fires and remains firing for one minute after the matching window clears.

Grafana manages and provisions this rule; Loki's ruler API is not used. The Loki datasource disables its unsupported data source-managed alert controls with `manageAlerts: false`, but Grafana's LogQL alert continues to evaluate. Open **Alerting → Alert rules** for state and query errors and [Notifications](../notifications/) for delivery.

The **Active log alerts** section on [Log Statistics](../log-statistics-dashboard/) displays current Pending and Firing instances. It reads Grafana state independently of that dashboard's time range and component filters.
