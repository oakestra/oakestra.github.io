---
title: "Observability"
description: "Operate Oakestra logs, metrics, dashboards, and alerts"
summary: "Choose an observability task"
draft: false
weight: 10313000000
toc: false
sidebar:
  collapsed: true
seo:
  title: "Oakestra observability manuals"
  description: "Deploy and operate local observability services for Root, Cluster, and 1-DOC"
  canonical: ""
  noindex: false
---

Oakestra collects control-plane logs and metrics on each orchestrator host. Start with [Observability Stack](../../concepts/observability/) if you want to understand the architecture and why standalone Root and Cluster installations keep their data locally. These manuals explain what to do with that stack:

1. [Deployment and upgrades](./deployment/) — install a matching configuration, generate expected-container inventory, and migrate from Promtail.
2. [Log collection and storage](./log-collection/) — inspect Alloy, normalized levels, Loki, and log history.
3. [Metrics collection and storage](./metrics-collection/) — check exporters, Prometheus targets, labels, and retention.
4. [Logs dashboard](./logs-dashboard/) — search, filter, and follow a shared ID across components.
5. [Log Statistics dashboard](./log-statistics-dashboard/) — review log-volume and severity trends.
6. [Resources dashboard](./resources-dashboard/) — inspect host and container resource use.
7. [Log alerts](./log-alerts/) — understand error and stacktrace detection.
8. [Container alerts](./container-alerts/) — diagnose missing and restarting containers.
9. [Resource alerts](./resource-alerts/) — set CPU, memory, and disk thresholds.
10. [Notifications](./notifications/) — configure a webhook or email and test delivery.
11. [Validation and troubleshooting](./validation-and-troubleshooting/) — confirm that the pipeline works and diagnose common failures.

If you are adding log events to a Python service, use [Writing Python logs](../../contribution-guide/writing-python-logs/). It covers the shared JSON contract and safe logging patterns.
