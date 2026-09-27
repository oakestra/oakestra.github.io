---
title: "Deployment and upgrades"
summary: "Install the local observability services and migrate from Promtail"
draft: false
weight: 10313100000
toc: true
---

Root, Cluster, and 1-DOC deployments each use the configuration for their own Compose manifest. Start separate installations on the Root host first, then install each Cluster with the Root address. See [Observability concepts](../../../concepts/observability/overview/) for the data flow and why standalone installations keep their telemetry locally.

## Install with the CLI

The CLI downloads the selected version's Compose files, configuration, and images. Use the same version on the Root and Clusters:

```bash
oak install root <VERSION>

oak config set root_orchestrator_address <ROOT_ADDRESS>
oak install cluster <VERSION>
```

For one host running both orchestration levels and a worker, use `oak install full <VERSION>`. The repository's startup scripts (`scripts/StartOakestraRoot.sh`, `scripts/StartOakestraCluster.sh`, and `scripts/StartOakestraFull.sh`) also download configuration for the selected revision. To test unpushed local Compose or configuration changes, use the local files directly as described below. Match configuration, Compose files, overrides, and images to the same Oakestra revision.

The metrics services require rootful Linux Docker Engine 25 or newer on AMD64 or ARM64. If Docker stores data outside `/var/lib/docker`, set `DOCKER_ROOT_DIR`. If Docker uses its containerd snapshotter, cAdvisor needs the socket configured by `CONTAINERD_SOCKET` (default `/run/containerd/containerd.sock`). On a host that cannot meet those requirements, use `override-no-observe.yml` to disable the complete observability stack.

## Run from local Compose files

Manual Compose deployment must produce the expected-container inventory *before* starting services. Run from the Oakestra repository root with Python 3 and Docker Compose available. Set the deployment variables first, including `SYSTEM_MANAGER_URL`, `CLUSTER_ADDRESS`, `CLUSTER_NAME`, and `CLUSTER_LOCATION` where the chosen manifest requires them. For a standalone Root:

```bash
set -o pipefail
compose=(docker compose -p oakestra-root -f root_orchestrator/docker-compose.yml)
"${compose[@]}" config --format json |
  python3 scripts/utils/generateContainerInventory.py \
    --output root_orchestrator/config/container-inventory/containers.prom
"${compose[@]}" up -d --build --remove-orphans
```

For a standalone Cluster, use `cluster_orchestrator/docker-compose.yml`, its `config/container-inventory/containers.prom`, and a distinct Compose project name. For 1-DOC, use `run-a-cluster/1-DOC.yaml` and `run-a-cluster/config/container-inventory/containers.prom`. Add exactly the same `-f` overrides, profiles, environment variables, and project name to both the inventory-rendering and startup commands. Regenerate the inventory after any intended topology or threshold change. The generator fails rather than replacing a valid inventory when the resolved Compose input or resource thresholds are invalid.

## Upgrade from Promtail

Recreate the same Compose project with `--remove-orphans` so Compose removes its obsolete Promtail container and starts Alloy. This flag does not remove named Loki volumes. If you change the Compose project name, the old container belongs to a different project and will not be removed by this command; inspect `docker ps -a` before cleaning it up. Avoid `docker compose down -v` unless deleting locally stored logs, metrics, and Grafana state is intentional.

## Open the interfaces

Root and 1-DOC Grafana use `http://<root-address>:3000`; standalone Cluster Grafana uses `http://<cluster-address>:3001`. Use the credentials configured for that Grafana instance. Recreating Grafana does not reset its persisted password. Alloy, Loki, and cAdvisor diagnostics are host-loopback endpoints listed in [Validation and troubleshooting](../validation-and-troubleshooting/); access a remote host's loopback endpoint with an SSH tunnel.
