---
title: "Validation and troubleshooting"
summary: "Verify local logs, metrics, dashboards, and alert rules"
draft: false
weight: 10314100000
toc: true
---

Validate each orchestrator on the host that runs it. Standalone Root and Cluster installations have separate Loki and Prometheus instances. These checks read live state; they do not inject test records, restart containers, or delete volumes.

## Confirm services and data

Run `docker ps --format 'table {{.Names}}\t{{.Status}}'`. Expected observability containers are:

| Deployment | Collector / storage / UI | Metric sources |
| --- | --- | --- |
| Root | `alloy`, `loki`, `grafana`, `root_prometheus` | `root_node_exporter`, `root_cadvisor`, `root_docker_state_exporter` |
| Cluster | `cluster_alloy`, `cluster_loki`, `cluster_grafana`, `cluster_prometheus` | `cluster_node_exporter`, `cluster_cadvisor`, `cluster_docker_state_exporter` |
| 1-DOC | `alloy`, `loki`, `grafana`, `prometheus` | `node_exporter`, `cadvisor`, `docker_state_exporter` |

On a Root or 1-DOC host:

```bash
curl -fsS http://127.0.0.1:3100/ready
curl -fsS http://127.0.0.1:12345/-/ready
curl -fsS http://127.0.0.1:8081/metrics >/dev/null
curl -fsS http://127.0.0.1:3100/loki/api/v1/labels
```

Use ports `3101`, `12346`, and `8082` on a standalone Cluster. Loki's labels endpoint should include `cluster_id`, `compose_service`, and `container` after logs arrive; `level` appears only after a supported format has been ingested. Open the [Alloy graph](../log-collection/) and confirm discovery, source, processing, and writer components are healthy.

In Grafana **Explore**, query `{cluster_id="root"}` with `Loki` on Root, and `up` with `Prometheus`. Use the Cluster's configured name in its local Loki. Prometheus targets should be `up=1`. Check `oakestra:container_monitoring_ready=1`, zero missing replicas, and six `oakestra_resource_alert_threshold_percent` series per node_exporter target. Open **Alerting → Alert rules** and confirm one log rule, four container rules, and seven resource rules have no evaluation errors. Notification delivery requires a real [contact point](../notifications/).

## Check configuration from a source checkout

Use the pinned images and the configuration directory for the deployment you changed:

```bash
docker run --rm -v "$PWD/root_orchestrator/config/config.alloy:/etc/alloy/config.alloy:ro" \
  grafana/alloy:v1.17.0 validate /etc/alloy/config.alloy

docker run --rm --entrypoint=promtool \
  -v "$PWD/root_orchestrator/prometheus:/etc/prometheus:ro" \
  prom/prometheus:v3.13.2-distroless \
  check config /etc/prometheus/prometheus.yml
```

These checks validate file syntax, not reachability or alert delivery. The dashboard and alerting files are provisioned when Grafana starts. Inspect the corresponding Grafana instance to confirm it loaded them.

## Common failures

| Symptom | Check and response |
| --- | --- |
| Promtail remains after an upgrade | Recreate the same Compose project with `--remove-orphans`; preserve named volumes. |
| Alloy is running but Loki has no streams | Inspect `docker logs alloy` or `cluster_alloy`, the Alloy graph, Docker socket, `oakestra.logging.collector`, `oakestra.cluster.id`, and local `LOKI_URL`. |
| A dashboard says **No data** | Try a basic selector in Explore. Check Loki for HTTP 429, shorten the range, restore normal refresh, and clear advanced filters. Verify you opened the correct host's Grafana. |
| A Loki query exceeds its time limit | Query at most 30 days per request and move a shorter absolute window backward. This limit does not delete stored data. |
| Every line is **Unparsed** | Check that Alloy configuration matches deployed services. Raw third-party output may remain unclassified; inspect current Python schema-v1 lines and collector logs. |
| A Loki rule API request returns 404 | The rule is Grafana-managed. Ensure the Loki datasource has `manageAlerts: false`; inspect **Alerting → Alert rules**. |
| Prometheus target is down | Inspect `up`, exporter logs, Docker compatibility, socket and filesystem mounts, and the private metrics gateway. |
| Container monitoring is unavailable | Check `oakestra:container_monitoring_ready`, Docker-state and node_exporter targets, socket permissions, and the inventory textfile. |
| Inventory or threshold configuration is missing | Regenerate inventory from the same resolved Compose configuration; verify exactly six threshold series and `node_textfile_scrape_error=0`. |
| cAdvisor has no filesystem usage series | Check its metrics endpoint, Docker storage driver, and mount permissions; CPU and memory can still work. |
| Alerts fire but delivery fails | Inspect the contact point's last delivery error. The default webhook is deliberately inactive; check URL or SMTP settings, receiver availability, and the **Test** action. |
| History disappeared after cleanup | Check whether named volumes were removed with `down -v`, `oak uninstall cleanup`, or manual deletion. Restore from an external backup if available. |

The stack monitors the local control plane. It does not collect NodeEngine host log files, provide distributed traces, or guarantee that a running application is healthy. A completely failed host needs independent monitoring.
