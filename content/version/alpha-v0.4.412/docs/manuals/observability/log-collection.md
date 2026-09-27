---
title: "Log collection and storage"
summary: "Follow container output through Alloy into local Loki"
draft: false
weight: 10313200000
toc: true
---

Each orchestrator's Alloy discovers Docker containers through `discovery.docker`, tails stdout and stderr with `loki.source.docker`, and sends records to its local Loki. It replaces Promtail. Standalone Root and Cluster instances do not ship logs to one another; 1-DOC has one collector and Loki for its shared Docker host.

## Selection and labels

Compose labels determine which collector owns a container. `oakestra.logging.collector` has the value `root`, `cluster`, or `one-doc`. `oakestra.cluster.id` is `root`, the configured Cluster name, or `one-doc` for shared 1-DOC infrastructure. A Cluster's database-generated ID is not available when Docker creates its containers, so the log label `cluster_id` is a deployment name rather than the database ID.

Alloy adds indexed Loki labels including `cluster_id`, `compose_service`, `container`, `logstream`, and, when recognized, `level`. `compose_service` is the Compose service key; `container` is the readable Docker container name. A Python record's JSON `service` field identifies the emitting application role and remains in the log body. Request and job IDs also stay in the body so they do not multiply indexed streams.

## Severity and raw lines

Alloy validates schema-v1 Python records before accepting their lowercase `level` and applies service-specific parsers to supported MongoDB, Redis, Nginx, scheduler, and observability formats. It normalizes recognized values to `debug`, `info`, `warning`, `error`, or `critical`. Unknown formats remain searchable with no `level` label and appear as **Unparsed** in Grafana. Docker's `stderr` stream alone does not imply an error. Changes to Alloy parsing affect newly ingested lines, not old records already stored in Loki.

## Persistence and query limits

Docker retains a capped local `json-file` log; Alloy persists read positions in a named volume; Loki persists chunks and indexes in another named volume. Loki has no automatic retention deletion in this configuration. Monitor its volume's disk use for long-running deployments. Removing volumes destroys their local history.

Loki 2.9 rejects a single query longer than its `30d1h` limit. This is a query-window limit, not data retention: choose an absolute window of at most 30 days and move it backward to inspect older history. Dashboard queries also limit parallelism to protect Loki from refresh bursts.

## Inspect the collector

On the Root or 1-DOC host, open `http://127.0.0.1:12345/graph`; on a standalone Cluster, use port `12346`. Check that Docker discovery, the Docker source, processing stages, and the local Loki writer are healthy. Inspect `docker logs alloy` (or `cluster_alloy`) if no targets appear. A Root Loki readiness check is `curl -fsS http://127.0.0.1:3100/ready`; Cluster Loki uses port `3101`. The diagnostic ports are bound to host loopback.
