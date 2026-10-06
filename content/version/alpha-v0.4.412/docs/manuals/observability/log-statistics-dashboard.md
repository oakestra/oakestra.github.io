---
title: "Log Statistics dashboard"
summary: "Track log volume, severity, and noisy components over time"
draft: false
weight: 10313500000
toc: true
---

**[Oakestra] Log Statistics** summarizes the local Loki's records without mixing individual lines and trend panels. It is provisioned separately from [Orchestrator Logs](../logs-dashboard/) and links back to it while preserving compatible filters and the time range.

The dashboard shows total lines and average lines per second across the selected range, warning and error/critical counts, throughput trends by component, separate warning and error/critical rates by component and Cluster, and top-N components ranked by average severity rate. Its distribution keeps `critical` separate from `error` and displays records without a normalized `level` as **Unparsed**. Unparsed does not mean harmless: Alloy simply could not classify the line's format.

{{< screenshot src="img/observability stack/Log statistics dashboard.png" alt="The Log Statistics selected-range overview and throughput trend" >}}

**Cluster**, **Source**, and **Component** filter the log queries. **Top N** changes the ranking size (5, 10, or 20). A standalone Grafana queries only its local Loki, so a Cluster selector with one value is expected. In 1-DOC, the shared Loki can contain Root, local Cluster, and shared infrastructure identities.

The collapsed **Active log alerts** section reads Grafana's current Pending and Firing instances of the provisioned log rule. It does not use the dashboard time range or the Cluster, Source, and Component filters. For historical alert state, inspect Grafana Alerting rather than treating this panel as a time-series count.

The default refresh is one minute. If many panels suddenly say **No data**, inspect Loki for HTTP 429 or “too many outstanding requests”; rejected queries do not prove that the stored logs disappeared. Reduce the selected window or refresh pressure. Keep each Loki query window at 30 days or less.
