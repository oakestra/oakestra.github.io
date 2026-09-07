---
title: "Observability Operations"
description: "Deploy, query, validate, secure, and troubleshoot the Oakestra observability stack across every orchestrator mode"
summary: "Operate the Oakestra observability stack"
draft: false
weight: 10313000000
toc: true
sidebar:
  collapsed: true
seo:
  title: "Oakestra Observability Operations"
  description: "Operate Oakestra logs, metrics, dashboards, and alerts across standalone Root, standalone Cluster, and 1-DOC deployments"
  canonical: ""
  noindex: false
---

This manual explains how to operate the observability stack described in [Observability Architecture](../../concepts/observability/). It covers Root, Cluster, and 1-DOC deployments, but every standalone orchestrator reads only its own local Loki and Prometheus.

{{< callout context="note" title="Alpha documentation" icon="outline/info-circle" >}}
This guide applies to the observability stack included in Oakestra `alpha-v0.4.412`. The wider observability roadmap is still being developed, so later versions may extend the documented dashboards, metrics, and alert rules.
{{< /callout >}}

## Install or upgrade

The startup scripts and `oak install` commands download configuration for the selected Oakestra version. Keep the Compose manifests, overrides, images, and configuration files on the same revision.

For a 1-DOC installation:

```bash
oak install full alpha-v0.4.412
```

For separate hosts, install the Root first, configure the Cluster's Root address, and then install the Cluster using the same version:

```bash
oak install root alpha-v0.4.412

oak config set root_orchestrator_address <ROOT_ADDRESS>
oak install cluster alpha-v0.4.412
```

The observability changes are also testable from a source checkout. Set the requested Oakestra revision and run the corresponding startup script, or render and start the Compose file directly. Use `--remove-orphans` when upgrading from Promtail so Compose removes the retired collector after Alloy is created:

```bash
docker compose -f root_orchestrator/docker-compose.yml \
  up -d --build --remove-orphans
```

Use `cluster_orchestrator/docker-compose.yml` for a standalone Cluster or `run-a-cluster/1-DOC.yaml` for 1-DOC. Include exactly the same override files used by the installation. Do not add `-v` when stopping or recreating the deployment unless deleting all local log, metric, and collector state is intentional.

To run Oakestra without the complete observability stack:

```bash
export OVERRIDE_FILES=override-no-observe.yml
oak install full alpha-v0.4.412
```

The metrics stack requires rootful Linux Docker Engine 25 or newer on AMD64 or ARM64. If Docker stores data outside `/var/lib/docker`, set `DOCKER_ROOT_DIR` before installation. The core orchestrator can still run on an unsupported metrics host with `override-no-observe.yml`.

## Expected services

Run the following on the orchestrator host:

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}'
```

The observability containers are:

| Deployment | Expected containers                                                                                                   |
| ---------- | --------------------------------------------------------------------------------------------------------------------- |
| Root       | `alloy`, `loki`, `grafana`, `root_prometheus`, `root_node_exporter`, `root_cadvisor`                                  |
| Cluster    | `cluster_alloy`, `cluster_loki`, `cluster_grafana`, `cluster_prometheus`, `cluster_node_exporter`, `cluster_cadvisor` |
| 1-DOC      | `alloy`, `loki`, `grafana`, `prometheus`, `node_exporter`, `cadvisor`                                                 |

1-DOC intentionally runs one observability pipeline for its one physical host. It does not need duplicate Root and Cluster exporters.

## Open Grafana and diagnostics

Open Grafana at:

- Root or 1-DOC: `http://<orchestrator-address>:3000`
- standalone Cluster: `http://<cluster-address>:3001`

Use the credentials configured for that Grafana instance. Changing branches or Compose files does not reset an existing Grafana password. Grafana may ask for a password change on a fresh first login.

Diagnostic APIs are bound to loopback and should remain private:

| Endpoint                                | Root / 1-DOC                    | Cluster                         |
| --------------------------------------- | ------------------------------- | ------------------------------- |
| Alloy component graph and target health | `http://127.0.0.1:12345`        | `http://127.0.0.1:12346`        |
| Loki readiness and API                  | `http://127.0.0.1:3100/ready`   | `http://127.0.0.1:3101/ready`   |
| cAdvisor UI                             | `http://127.0.0.1:8081`         | `http://127.0.0.1:8082`         |
| cAdvisor metrics                        | `http://127.0.0.1:8081/metrics` | `http://127.0.0.1:8082/metrics` |

When the service runs on a remote Linux machine, `127.0.0.1` refers to that machine. Use an SSH tunnel instead of rebinding diagnostics to a LAN or Tailscale address:

```bash
ssh -N \
  -L 13000:127.0.0.1:3000 \
  -L 12345:127.0.0.1:12345 \
  -L 18081:127.0.0.1:8081 \
  user@orchestrator-host
```

Then open ports `13000`, `12345`, and `18081` on your workstation's loopback interface. Change the remote ports to `3001`, `12346`, and `8082` for a standalone Cluster.

## Dashboards

Grafana loads dashboards from version-controlled JSON files mounted under `/var/lib/grafana/dashboards`. They appear automatically after startup and are updated from the files. Editing a provisioned dashboard in the UI is useful for experiments, but durable changes belong in its JSON source.

### Orchestrator Logs

Use **[Oakestra] Orchestrator Logs** to read individual records. Its controls are:

| Control                           | Effect                                                                              |
| --------------------------------- | ----------------------------------------------------------------------------------- |
| **Cluster**                       | Selects the `cluster_id` stored in the local Loki                                   |
| **Source**                        | Selects Oakestra services, observability, data stores, or all collected containers  |
| **Component**                     | Selects one or more `compose_service` values within Cluster and Source              |
| **Level**                         | Selects normalized `debug`, `info`, `warning`, `error`, `critical`, or **Unparsed** |
| **Display**                       | **Compact** formats schema-v1 JSON for reading; **Raw** shows the exact stored line |
| **Full-line search (regex)**      | Applies a case-insensitive regular expression to the original line                  |
| **Advanced field filter (LogQL)** | Appends query-time parsers and field filters                                        |
| Time picker                       | Selects the period queried from local Loki                                          |

Compact display changes only the query result presentation. Searches and advanced filters still inspect the original stored record.

Expand a line containing a 24-character Oakestra ID to use **Open in...** links. A link keeps the time range, changes the target component, and places the exact ID in the Search field. It shows only records where that other component logged the same ID; it does not infer causality or provide distributed tracing.

Loki 2.9 rejects a single query longer than its `30d1h` limit even though Grafana's generic time picker offers longer periods. Query a window of 30 days or less and move an absolute window backward to inspect older retained data.

### Log Statistics

Use **[Oakestra] Log Statistics** for trends rather than individual lines. It provides:

- total lines and average lines per second over the selected range;
- warning and error/critical totals;
- throughput over time per component;
- warning and error/critical rates per component and per Cluster;
- top-N noisy components;
- distribution across normalized levels and **Unparsed** records.

The dashboard shares Cluster, Source, and Component filters with the Logs dashboard. Error panels combine `error` and `critical`; the distribution keeps them separate. **Unparsed** means Alloy did not recognize a supported severity format—it does not mean that the record is harmless.

The default refresh is one minute. Trend panels limit resolution and use a minimum interval to avoid overwhelming Loki with concurrent queries. A rejected query can appear as **No data**, so check Loki logs for HTTP 429 responses before concluding that history is missing.

### Resources

Use **[Oakestra] Resources** for Prometheus-backed resource measurements. Host panels show:

- CPU busy percentage and CPU usage over time;
- memory used and available;
- root filesystem and real-mountpoint usage;
- disk read/write throughput by device.

Container panels show CPU and memory working set per Cluster and Compose service, plus top-N consumers. Container CPU is expressed as a percentage of one core: `100%` is one fully occupied core, and a multicore service can exceed `100%`. Working set is cgroup memory usage minus inactive file cache; it is not the same as application heap or RSS.

Cluster, Source, Component, and Top-N affect container panels only. Host panels always describe the single physical host monitored by local node_exporter. This is especially important in 1-DOC: selecting Root or Cluster changes container panels but cannot change the physical host.

Prometheus keeps at most seven days or approximately 1 GB of persistent blocks, whichever policy is reached first. Therefore the size policy can shorten the available history. Restarting the container preserves the named volume; removing the volume deletes the history.

## Query logs with LogQL

Use Grafana **Explore**, select the `Loki` datasource, and start with an indexed stream selector:

```logql
{cluster_id="root", compose_service="system_manager"}
```

Select errors and critical records without scanning message text:

```logql
{cluster_id="root", compose_service="system_manager", level=~"error|critical"}
```

Search the complete line with a literal or regular expression:

```logql
{cluster_id="root", compose_service="system_manager"} |= "registration"

{cluster_id="root", compose_service="system_manager"} |~ "(?i)timeout|unreachable"
```

Parse schema-v1 JSON fields at query time:

```logql
{cluster_id="root", compose_service="system_manager"}
| json
| __error__ = ""
| schema_version = 1
| event = "cluster.registration.completed"
```

Extract a nested context field explicitly when needed:

```logql
{cluster_id="root", compose_service="system_manager"}
| json job_id="context.job_id"
| job_id = "<JOB_ID>"
```

Keep IDs and application fields in the log body rather than turning them into indexed labels. For help constructing a pipeline, use Grafana's [LogQL query analyzer](https://grafana.com/docs/loki/latest/query/analyzer/).

## Query metrics with PromQL

Prometheus is internal in normal bridge deployments, so query it through Grafana Explore or execute `promtool` inside its container:

```bash
docker exec root_prometheus \
  promtool query instant http://127.0.0.1:9090 up

docker exec root_prometheus \
  promtool query instant http://127.0.0.1:9090 prometheus_tsdb_head_series
```

Use `cluster_prometheus` on a standalone Cluster and `prometheus` in 1-DOC. The `up` result should be `1` for each configured target. Representative Explore queries include:

```promql
100 * (1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m])))

100 * (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)

sum by (cluster_id, compose_service) (
  rate(container_cpu_usage_seconds_total{compose_service!=""}[5m])
) * 100
```

Sampling windows mean container CPU and memory values will not exactly match a single `docker stats` snapshot.

## Log alerts

Grafana provisions **Orchestrator error or stacktrace detected** and evaluates it against local Loki every 30 seconds. It has two detection paths:

1. For schema-v1 Python and Gunicorn records, `level=error|critical` plus `schema_version=1` is authoritative. An Info record containing the word `ERROR` does not fire.
2. For records outside schema v1, a compatibility path recognizes strict uppercase error markers, Oakestra compact errors, Python traceback markers, and Go panic/runtime stack markers.

The compatibility path excludes schema-v1 lines to avoid double counting. Observability services are excluded from this log alert to avoid self-generated recursive noise. An alert instance is grouped by `cluster_id` and `compose_service`, remains pending for one minute, and keeps firing for one minute after its two-minute query window clears. Notifications wait 30 seconds for grouping and repeat every four hours while the condition persists.

Open **Alerting → Alert rules** to inspect rule evaluation and **Alerting → Notification configuration → Contact points** to inspect delivery.

## Configure notifications

Both **Oakestra Alert Webhook** and **Oakestra Alert Email** are provisioned. The default webhook points to an intentionally inactive local address: alert evaluation works, but delivery fails until you configure a real destination.

Configure a webhook before creating or recreating Grafana:

```bash
export OAKESTRA_ALERT_CONTACT_POINT="Oakestra Alert Webhook"
export OAKESTRA_ALERT_WEBHOOK_URL="https://alerts.example.com/oakestra"
```

For email, configure both the recipient and Grafana SMTP transport:

```bash
export OAKESTRA_ALERT_CONTACT_POINT="Oakestra Alert Email"
export OAKESTRA_ALERT_EMAIL_TO="infra@example.com"
export OAKESTRA_ALERT_SMTP_ENABLED=true
export OAKESTRA_ALERT_SMTP_HOST="smtp.example.com:587"
export OAKESTRA_ALERT_SMTP_USER="infra@example.com"
export OAKESTRA_ALERT_SMTP_PASSWORD="<smtp-password>"
export OAKESTRA_ALERT_SMTP_FROM_ADDRESS="infra@example.com"
export OAKESTRA_ALERT_SMTP_FROM_NAME="Oakestra Alerts"
export OAKESTRA_ALERT_SMTP_SKIP_VERIFY=false
```

Then recreate the correct Grafana service so it reads the environment:

```bash
docker compose -f root_orchestrator/docker-compose.yml \
  up -d --force-recreate grafana
```

Use `cluster_orchestrator/docker-compose.yml` and `cluster_grafana` for a standalone Cluster. Keep credentials out of tracked Compose and documentation files. The Grafana **Test** action verifies the contact point independently of the LogQL rule; verify both rule evaluation and delivery before relying on notifications.

## Validate the stack

### Service and readiness checks

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}'

curl -fsS http://127.0.0.1:3100/ready
curl -fsS http://127.0.0.1:12345/-/ready
curl -fsS http://127.0.0.1:8081/metrics >/dev/null
```

Use ports `3101`, `12346`, and `8082` on a standalone Cluster. In the Alloy UI, verify that Docker discovery, the Docker log source, the processing pipeline, and the local Loki writer are healthy.

### Loki labels and data

```bash
curl -fsS http://127.0.0.1:3100/loki/api/v1/labels | jq .

curl -fsSG http://127.0.0.1:3100/loki/api/v1/query_range \
  --data-urlencode 'query={cluster_id="root"}' \
  --data-urlencode 'limit=5' | jq '.data.result'
```

Expect `cluster_id`, `compose_service`, `container`, `logstream`, and—for recognized records—`level`. A label can be absent from the global list until at least one retained stream contains it.

### Prometheus targets and Grafana datasources

```bash
docker exec root_prometheus \
  promtool query instant http://127.0.0.1:9090 up

curl -fsS http://127.0.0.1:3000/api/health | jq .
```

In Grafana, open **Connections → Data sources** and test both `Loki` and `Prometheus`. Confirm exactly one Logs, Log Statistics, and Resources dashboard is provisioned.

### Configuration checks from a source checkout

```bash
docker compose -f root_orchestrator/docker-compose.yml config >/dev/null

docker run --rm --entrypoint=/bin/loki \
  -v "$PWD/root_orchestrator/config/loki.yml:/etc/loki/config.yml:ro" \
  grafana/loki:2.9.2 \
  -config.file=/etc/loki/config.yml -verify-config

docker run --rm --entrypoint=alloy \
  -v "$PWD/root_orchestrator/config/config.alloy:/etc/alloy/config.alloy:ro" \
  grafana/alloy:v1.17.0 \
  validate /etc/alloy/config.alloy

docker run --rm --entrypoint=promtool \
  -v "$PWD/root_orchestrator/prometheus:/etc/prometheus:ro" \
  prom/prometheus:v3.13.2-distroless \
  check config /etc/prometheus/prometheus.yml
```

Repeat with the configuration directory for the deployment mode you are changing.

## Common failures

### Promtail is still present

The old container is an orphan after Compose replaces the service with Alloy. Recreate from the current Compose project with `--remove-orphans`. This removes the obsolete container; it does not migrate or delete Loki's named volume.

### Alloy runs but Loki has no streams

Check the Alloy graph, then inspect:

```bash
docker logs alloy --tail 200
docker inspect system_manager \
  --format '{{json .Config.Labels}}' | jq .
```

For Cluster, use `cluster_alloy` and a Cluster service. Confirm `oakestra.logging.collector` matches `ALLOY_COLLECTOR_ID`, the container has `oakestra.cluster.id`, the Docker socket is mounted, and `LOKI_URL` points to the local Loki.

### Grafana shows No data

First determine whether the datasource returned no series or rejected the query:

```bash
docker logs loki --since 10m 2>&1 | grep -E '429|too many outstanding|error'
docker logs root_prometheus --since 10m 2>&1 | grep -i error
```

Then reduce the time range, restore the dashboard's one-minute refresh, clear advanced filters, and test a basic selector in Explore. Standalone Root and Cluster instances do not contain each other's data. A Cluster filter with one value can therefore be correct.

### Query exceeds the Loki time limit

Use a range no longer than 30 days. To inspect older logs, choose an absolute start and end whose difference is still at most 30 days. This query limit is independent of whether the named volume contains older chunks.

### Every line is Unparsed

Verify the deployed Alloy configuration matches the service images. New Python application records should contain `schema_version`, `timestamp`, `level`, `service`, `logger`, and `message`. Legacy, direct stdout/stderr, and unknown third-party formats remain searchable even when severity cannot be classified.

### Alerts evaluate but notifications fail

Open the contact point and inspect its last delivery error. The default webhook and email addresses are placeholders. Confirm the selected `OAKESTRA_ALERT_CONTACT_POINT`, destination variables, SMTP settings, DNS, certificates, firewall, and receiver availability, then use Grafana's contact-point test.

### Prometheus target is down

Query `up`, inspect **Explore** with the Prometheus datasource, and check the target container logs. Verify Docker Engine compatibility, `DOCKER_ROOT_DIR`, the private metrics gateway, and the read-only host mounts. In host-network mode, Root Grafana uses loopback Prometheus port `10010` and Cluster Grafana uses `10009`.

### cAdvisor does not show container filesystem usage

Storage-driver and protected-layer behavior can make `container_fs_usage_bytes` unavailable even when CPU, memory, network, and disk-I/O metrics work. Check cAdvisor's `/metrics`, Docker's storage driver, and host mount permissions before treating the entire pipeline as unavailable.

### History disappeared after cleanup

Check whether the deployment was stopped with `docker compose down -v`, `oak uninstall cleanup`, or an equivalent volume-removal command. Named-volume deletion is destructive and cannot be recovered unless the data was backed up externally.

## Scope of this alpha stack

The documented stack collects Docker control-plane logs, host metrics, container resource metrics, and Cluster Manager metrics. It provides three dashboards and error/stacktrace log alerting. It does not centralize telemetry from standalone Clusters into the Root, ingest NodeEngine's host log files, provide distributed traces, prove application health from container state, or provide durable remote storage. Later observability work can add capabilities without changing these boundaries.

For log-authoring rules and the Python JSON contract, continue with [Structured Python Logging](structured-logging/).
