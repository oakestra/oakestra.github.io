---
title: "Logs dashboard"
summary: "Browse, filter, and correlate orchestrator log records"
draft: false
weight: 10313400000
toc: true
---

Open **[Oakestra] Orchestrator Logs** in the Grafana instance for the host you are investigating. It reads that host's local Loki. A standalone Root cannot browse a remote Cluster's records; open the Cluster Grafana to do that. Grafana permits UI edits to the provisioned dashboards, but saves them only in its database. A later update to the version-controlled JSON can overwrite those edits; change the JSON in the Oakestra repository to make a lasting change.

## Select records

| Control | What it does |
| --- | --- |
| **Cluster** | Selects the indexed deployment identity `cluster_id`. One choice is normal on a standalone host. |
| **Source** | Narrows to Oakestra services, observability services, data stores, or all collected containers. |
| **Component** | Selects one or more indexed `compose_service` values within the chosen Cluster and Source. |
| **Level** | Selects normalized `debug`, `info`, `warning`, `error`, `critical`, or **Unparsed**. |
| **Display** | **Compact** formats schema-v1 JSON for reading; **Raw** shows the exact stored line. |
| **Full-line search (regex)** | Runs a case-insensitive regular expression against the original full log line. |
| **Advanced field filter (LogQL)** | Appends LogQL stages for parsing and filtering fields inside matching lines. |
| Time picker | Chooses the time window and lets you scroll back through retained history. |

{{< screenshot src="img/observability stack/Logs dashboard.png" alt="The Logs dashboard showing filters, search controls, and recent orchestrator logs" >}}

Compact display changes presentation after filtering; it does not rewrite Loki records. Search `worker|mqtt` to find either term, or a literal 24-character Oakestra ID to look for the same ID across components. The default `^` pattern matches every line without highlighting the whole line.

For structured Python records, enter this in **Advanced field filter (LogQL)** to select a specific event:

```logql
| json schema="schema_version", event_name="event" | schema="1" | event_name="cluster.registration.completed"
```

For a nested field, use `| json job_id="context.job_id" | job_id="<JOB_ID>"`. The control expects pipeline stages, not a complete selector. Parsing a field at query time does not create a new indexed Loki label. The [LogQL query analyzer](https://grafana.com/docs/loki/latest/query/analyzer/) helps inspect a query.

## Follow a shared ID

Expand a log line containing a 24-character Oakestra ID and use its **Open in...** link. Grafana preserves the time range, switches to the linked component, and places the ID in **Full-line search** so you can see what that component logged about it. A link finds shared text; it does not prove that two events are causally related or reconstruct a distributed trace. If the destination did not log that ID in the selected time range, it shows no lines.


Select a window of at most 30 days. Grafana's generic picker may offer longer ranges, but Loki 2.9 rejects a single query exceeding `30d1h`. Move a shorter absolute window backward to read older retained records.

## Optional: full LogQL queries

The dashboard controls cover routine searches. To write a complete LogQL query instead, open the logs panel menu, choose **Explore**, select `Loki`, and switch the query editor to **Code**. For example:

```logql
{cluster_id="root", compose_service="system_manager"}
{cluster_id="root", compose_service="system_manager", level=~"error|critical"}
{cluster_id="root", compose_service="system_manager"} |~ "(?i)timeout|unreachable"
{cluster_id="root", compose_service="system_manager"} | json | __error__ = "" | schema_version = 1
```

The indexed `level` is more reliable for severity than searching message words. A line without a recognized severity remains available under **Unparsed**.
