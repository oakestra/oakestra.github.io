---
title: "Observability Architecture"
summary: "How Oakestra collects, stores, and presents control-plane logs and metrics"
draft: false
weight: 10205000000
toc: true
seo:
  title: "Oakestra Observability Architecture"
  description: "Understand how Oakestra collects, stores, isolates, secures, and visualizes control-plane logs and resource metrics"
  canonical: ""
  noindex: false
---

Oakestra includes a host-local observability stack for its Root and Cluster control planes. It collects container logs and resource metrics, stores them locally, and makes them available through provisioned Grafana dashboards and alert rules.

{{< callout context="note" title="Alpha documentation" icon="outline/info-circle" >}}
This page describes the observability architecture being introduced for the `alpha-v0.4.412` documentation line. The stack is still being extended, so later alpha revisions may add dashboards, metrics, and alert rules without changing the data-ownership model described here.
{{< /callout >}}

## Capabilities

Observability is split into separate concerns:

| Capability              | Purpose                                                       | Data source                             |
| ----------------------- | ------------------------------------------------------------- | --------------------------------------- |
| Log collection          | Discover control-plane containers and copy stdout/stderr      | Grafana Alloy                           |
| Log storage and queries | Retain log streams and execute LogQL                          | Loki                                    |
| Log browsing            | Read, filter, search, and correlate individual records        | Grafana **Orchestrator Logs** dashboard |
| Log statistics          | Display volume, severity, and noisy-component trends          | Grafana **Log Statistics** dashboard    |
| Log alerting            | Detect error-level records and stacktrace markers             | Grafana-managed alert rules over Loki   |
| Metrics collection      | Scrape host and container resource measurements               | Prometheus, node_exporter, and cAdvisor |
| Resource visualization  | Display host and per-service CPU, memory, filesystem, and I/O | Grafana **Resources** dashboard         |

These capabilities share Grafana, but they are not interchangeable. Alloy transports logs; it does not store them and does not replace Prometheus. Loki stores log lines, while Prometheus stores numeric time series. Dashboards visualize existing data, and alert rules evaluate queries independently of whether a dashboard is open.

Distributed tracing is not part of this stack. The shared-ID links in the Logs dashboard correlate records containing the same Oakestra identifier, but they are not traces and do not reconstruct a complete request path.

The deployment currently uses the following components:

| Component     | Deployed image                             | Responsibility                                       |
| ------------- | ------------------------------------------ | ---------------------------------------------------- |
| Grafana Alloy | `grafana/alloy:v1.17.0`                    | Docker discovery, log processing, and delivery       |
| Loki          | `grafana/loki:2.9.2`                       | Local log storage and LogQL                          |
| Grafana       | `grafana/grafana`                          | Dashboards, Explore, datasources, and managed alerts |
| Prometheus    | `prom/prometheus:v3.13.2-distroless`       | Local metric scraping, TSDB, and PromQL              |
| node_exporter | `quay.io/prometheus/node-exporter:v1.12.1` | Physical-host metrics                                |
| cAdvisor      | `ghcr.io/google/cadvisor:v0.60.5`          | Docker container resource metrics                    |

Alloy replaces Promtail as the log collector. Do not run both collectors against the same containers because doing so duplicates ingestion.

## Data flows

```text
container stdout/stderr
        │
        ▼
Grafana Alloy ───────► local Loki ───────► Grafana Logs dashboard
     Docker API          LogQL             Grafana Log Statistics dashboard
                                            Grafana log alerts

physical host ───────► node_exporter ─┐
Docker containers ───► cAdvisor ──────┼──► local Prometheus ───► Grafana Resources dashboard
Prometheus itself ─────────────────────┘       PromQL
```

Alloy uses `discovery.docker` and `loki.source.docker` against the local Docker socket. It refreshes discovery every five seconds, processes each record, and pushes it to the Loki instance in the same deployment. Prometheus pulls metrics every 15 seconds with a 10-second timeout. Root Prometheus scrapes itself, node_exporter, and cAdvisor; Cluster and 1-DOC Prometheus also scrape Cluster Manager's application metrics.

## Local ownership and isolation

Oakestra deliberately does not send every Cluster's telemetry to the Root:

| Deployment         | Logs                                                              | Metrics                                                              | Grafana     |
| ------------------ | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ----------- |
| Standalone Root    | Root containers → Root Alloy → Root Loki                          | Root host and labelled Root containers → Root Prometheus             | Port `3000` |
| Standalone Cluster | Cluster containers → Cluster Alloy → Cluster Loki                 | Cluster host and labelled Cluster containers → Cluster Prometheus    | Port `3001` |
| 1-DOC              | Root, local Cluster, and shared containers → one Alloy → one Loki | One physical host and all labelled 1-DOC containers → one Prometheus | Port `3000` |

A standalone Root cannot browse a remote Cluster's logs or metrics. Open that Cluster's Grafana to inspect its local data. Consequently, a standalone dashboard's **Cluster** selector can legitimately contain only one value. In 1-DOC, one Docker host contains both orchestration levels, so the shared Loki and Prometheus retain Root, Cluster, and shared container identities without collecting the physical host twice.

## Container discovery and labels

Compose assigns every managed container two important labels:

- `oakestra.logging.collector` selects which Alloy instance may collect the container. Its value is `root`, `cluster`, or `one-doc`.
- `oakestra.cluster.id` identifies the emitting orchestration plane. Root uses `root`, a Cluster uses its configured `CLUSTER_NAME`, and shared 1-DOC infrastructure uses `one-doc`.

The Cluster name is used because the database-generated Cluster ID does not exist when Compose creates the containers. Treat this label as a stable deployment identity, not as the database object's ID.

Alloy derives these indexed Loki labels:

| Label             | Meaning                                                  |
| ----------------- | -------------------------------------------------------- |
| `cluster_id`      | Root, configured Cluster name, or shared 1-DOC identity  |
| `compose_service` | Stable Compose service key                               |
| `container`       | Readable Docker container name                           |
| `logstream`       | Docker `stdout` or `stderr` stream                       |
| `level`           | Normalized severity when the record format is recognized |

Compatibility labels such as `container_name` and `job` remain available. Values with high cardinality—request IDs, job IDs, worker IDs, message text, logger names, and structured context—remain inside the log record and are parsed at query time instead of becoming Loki labels. This keeps the number of streams bounded.

cAdvisor retains only containers assigned to the local Oakestra collector and maps Docker metadata to the Prometheus labels `cluster_id` and `compose_service`. Host metrics use `host_scope=root`, `host_scope=cluster`, or `host_scope=one-doc`; a physical host is not given a fabricated Cluster identity.

## Severity normalization

Python services using `oakestra_logging` emit a versioned JSON record with an explicit lowercase `level`. Alloy accepts that value only from expected Python services when the schema header and service identity are valid. Other service-specific stages recognize MongoDB JSON, observability logfmt, Redis markers, Nginx headers, scheduler output, and strict legacy Oakestra headers.

Recognized values are normalized to `debug`, `info`, `warning`, `error`, or `critical`. A line with an unknown format is still stored, but it has no `level` label and appears as **Unparsed** in dashboards. The Docker stream is not a severity: programs such as Gunicorn can write informational records to stderr.

Normalization happens during ingestion. Updating Alloy does not retroactively add labels to records already stored in Loki.

## Storage and lifecycle

The stack uses separate storage layers:

- Docker's local `json-file` log is capped at one 1-MB file per container. This protects host disk space; it is not the Loki history.
- Alloy stores read positions in a named volume, preventing normal collector restarts from unnecessarily rereading log files.
- Loki stores chunks and indexes in a named volume. The current local configuration has no automatic retention deletion, so operators must monitor disk usage and choose an explicit retention policy for long-running installations.
- Prometheus stores its TSDB in a named volume with `7d` and `1GB` retention limits. Whichever limit is reached first removes the oldest persistent blocks; a busy host can therefore retain less than seven days. The 1-GB policy is not an exact filesystem quota because the WAL, active head, and compaction need additional space.
- Dashboards, datasources, and alert definitions are files mounted into Grafana. Grafana recreates these provisioned resources from version-controlled configuration.

Normal container recreation preserves named volumes. `docker compose down -v`, `oak uninstall cleanup`, or manual volume deletion removes the corresponding local history. The local Loki and Prometheus stores are neither replicated nor backups.

## Security boundaries

The default bridge-mode exposure is intentionally narrow:

| Endpoint                         |            Root / 1-DOC |                 Cluster | Exposure                                                                 |
| -------------------------------- | ----------------------: | ----------------------: | ------------------------------------------------------------------------ |
| Grafana                          |                  `3000` |                  `3001` | Published by the deployment; protect it with firewall and authentication |
| Loki API                         |        `127.0.0.1:3100` |        `127.0.0.1:3101` | Host loopback only                                                       |
| Alloy diagnostics                |       `127.0.0.1:12345` |       `127.0.0.1:12346` | Host loopback only                                                       |
| cAdvisor diagnostics and metrics |        `127.0.0.1:8081` |        `127.0.0.1:8082` | Host loopback only                                                       |
| Prometheus                       |                Internal |                Internal | Reached by Grafana over Docker networking                                |
| node_exporter                    | Private metrics gateway | Private metrics gateway | Not published as a normal host port                                      |

With the host-network overrides, Prometheus is exposed only on loopback at `127.0.0.1:10010` for Root and `127.0.0.1:10009` for Cluster.

Alloy and cAdvisor receive read-only mounts of the Docker socket. A read-only socket mount does not restrict Docker API methods: both containers remain inside the Docker daemon's trust boundary. cAdvisor also receives read-only host filesystem and runtime mounts. The services drop Linux capabilities, use read-only filesystems where supported, and keep diagnostics on loopback, but operators must still trust the pinned images and prevent remote access to those endpoints.

The metrics pipeline requires rootful Linux Docker Engine 25 or newer on AMD64 or ARM64. Deployments that cannot satisfy this requirement can use `override-no-observe.yml`, which disables Grafana, Loki, Alloy, Prometheus, node_exporter, and cAdvisor together.

## Configuration ownership

Each deployment has its own observability configuration:

```text
root_orchestrator/
cluster_orchestrator/
run-a-cluster/
├── config/
│   ├── config.alloy
│   ├── loki.yml
│   ├── grafana-datasources.yml
│   ├── grafana-dashboards.yml
│   ├── alerts/
│   └── dashboards/
└── prometheus/
    └── prometheus*.yml
```

The files are similar but not interchangeable: service names, ports, collector scopes, metric gateways, and datasource URLs vary by deployment. Keep the Compose manifest, overrides, downloaded configuration, and image version from the same Oakestra revision.

Continue with the [Observability Operations](../../manuals/observability/) manual to deploy, query, validate, and troubleshoot the stack. Contributors adding Python log events should also read [Structured Python Logging](../../manuals/observability/structured-logging/).
