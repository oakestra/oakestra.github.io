---
title: "Labels and severity"
summary: "Deployment identity, indexed labels, and normalized log levels"
draft: false
weight: 10204530000
toc: true
---

## Deployment identity

Compose labels each managed container with `oakestra.logging.collector` and `oakestra.cluster.id`. The collector value (`root`, `cluster`, or `one-doc`) selects the Alloy instance that owns its logs. The second value is the emitting plane: `root`, the configured `CLUSTER_NAME`, or `one-doc` for shared 1-DOC infrastructure. The Cluster name is available when Compose creates containers; the database-generated Cluster ID is not. The indexed `cluster_id` is therefore a deployment identity, **not** the database object's ID.

Alloy derives these Loki stream labels:

| Label | Meaning |
| --- | --- |
| `cluster_id` | Root, configured Cluster name, or shared 1-DOC identity. |
| `compose_service` | Stable Docker Compose service key. |
| `container` | Readable Docker container name, which need not equal the service key. |
| `logstream` | Docker `stdout` or `stderr`. |
| `level` | Normalized severity when Alloy recognizes the format. |

Compatibility labels such as `container_name` and `job` remain available. Request IDs, job IDs, worker IDs, message text, logger names, and application context stay inside the record and are parsed at query time. Indexing these high-cardinality values would create many streams.

cAdvisor maps Docker metadata for locally managed containers to Prometheus `cluster_id` and `compose_service` labels. Host series instead use `host_scope=root`, `cluster`, or `one-doc`; one physical machine is not given a fabricated Cluster identity. Container lifecycle rules retain `cluster_id`, `compose_service`, and `compose_project`, so equal service keys in different Compose projects remain distinct. The node_exporter inventory also carries six host-resource thresholds. Host alerts identify `host_scope` and `instance`; filesystem alerts additionally identify `device` and `mountpoint`.

## Severity at ingestion

Python services using `oakestra_logging` emit schema-v1 JSON with an explicit lowercase level. Alloy accepts it from expected Python services only after validating the schema header and service identity. Scoped parsers also recognize supported MongoDB, Redis, Nginx, scheduler, and observability formats. Recognized values become `debug`, `info`, `warning`, `error`, or `critical`.

Unrecognized lines are still stored, but have no indexed `level` and appear as **Unparsed** in dashboards. Docker `stderr` is a stream, not a severity—Gunicorn can emit informational records there. Normalization occurs during ingestion; changing Alloy later does not relabel historical records already in Loki.

Contributors should follow [Writing Python logs](../../../contribution-guide/writing-python-logs/) for the application JSON contract. Operators can use the [Logs dashboard](../../../manuals/observability/logs-dashboard/) to filter the indexed levels.
