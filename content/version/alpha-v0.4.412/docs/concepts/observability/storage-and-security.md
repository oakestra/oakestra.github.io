---
title: "Storage and security"
summary: "Local retention, exposure, and trust boundaries"
draft: false
weight: 10204540000
toc: true
---

## Storage lifecycle

The pipeline has separate stores with different lifetimes:

- Docker's local `json-file` log is capped at one 1-MB file per container; it is not the Loki history.
- Alloy persists read positions in a named volume so a normal collector restart does not unnecessarily reread existing log files.
- Loki stores chunks and indexes in a named volume. This configuration has no automatic retention deletion; operators must monitor its disk usage and choose a retention policy for long-running deployments.
- Prometheus stores its TSDB in a named volume with `7d` and `1GB` retention limits. The oldest persistent blocks are removed as either limit is reached. The size limit is not an exact filesystem quota because the WAL, active head, and compaction require additional space.
- Expected-container inventory persists on the host, so removal of a container does not remove its desired-state record. Provisioned dashboards, datasources, and alert definitions are files mounted into Grafana.

Recreating containers normally preserves named volumes. `docker compose down -v`, `oak uninstall cleanup`, or manual volume deletion removes the corresponding local history. Local Loki and Prometheus storage is neither replicated nor a backup. Loki's separate 30-day *query-window* limit does not delete stored logs; see [Log collection and storage](../../../manuals/observability/log-collection/).

## Network exposure and trust

| Endpoint | Root / 1-DOC | Standalone Cluster | Default exposure |
| --- | --- | --- | --- |
| Grafana | `3000` | `3001` | Published; protect with authentication and firewall rules. |
| Loki API | `127.0.0.1:3100` | `127.0.0.1:3101` | Host loopback. |
| Alloy diagnostics | `127.0.0.1:12345` | `127.0.0.1:12346` | Host loopback. |
| cAdvisor diagnostics | `127.0.0.1:8081` | `127.0.0.1:8082` | Host loopback. |
| Prometheus | Internal | Internal | Reached by Grafana over Docker networking. |
| node_exporter | Private metrics gateway | Private metrics gateway | Not published as a normal host port. |
| Docker-state exporter | Internal | Internal | Scraped by local Prometheus. |

With host-network overrides, Prometheus is exposed only on loopback: `127.0.0.1:10010` on Root and `127.0.0.1:10009` on Cluster.

Alloy, cAdvisor, and the Docker-state exporter receive Docker socket mounts. Mounting the socket read-only does **not** restrict Docker API methods; those containers remain inside the Docker daemon's trust boundary. cAdvisor also reads host filesystem and container-runtime mounts. The services drop Linux capabilities and use read-only filesystems where supported, but operators must still trust the pinned images and prevent remote access to diagnostics.

The metrics pipeline requires rootful Linux Docker Engine 25 or newer on AMD64 or ARM64. `override-no-observe.yml` disables the entire stack where this requirement cannot be met.

## Configuration ownership

Root, Cluster, and 1-DOC observability configuration lives under `root_orchestrator/`, `cluster_orchestrator/`, and `run-a-cluster/`, respectively. Each has a `config/` directory for Alloy, Loki, Grafana provisioning, dashboards, and inventory, plus a `prometheus/` directory for scraping and recording rules. These files are similar but not interchangeable: service names, ports, collector scopes, gateway addresses, and datasource URLs vary by deployment. Keep Compose, overrides, configuration, and images from the same Oakestra revision. The [Deployment and upgrades manual](../../../manuals/observability/deployment/) gives the operational steps.
