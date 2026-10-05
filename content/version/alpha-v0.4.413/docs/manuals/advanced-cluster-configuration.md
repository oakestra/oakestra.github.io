---
title: "Advanced Cluster Configurations"
summary: ""
draft: false
weight: 10303000000
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---


**Root Orchestrator Environment Variables**

In a complex network environment, you might want to reach your Root Orchestrator from a specific IP. You can customize the default IP by exporting the following environment variable before the Root Orchestrator installation command.

```bash
# Example configuration for root orchestrator
export SYSTEM_MANAGER_URL=192.158.18.104
oak install root
```

**Cluster Orchestrator Environment Variables**

You can customize the IP address your cluster orchestrator has to use to reach your Root Orchestrator using the following command before the cluster orchestrator installation:

```bash
# Example configuration for the cluster orchestrator
oak config set root_orchestrator_address <IP OF ROOT ORCHESTRATOR>
oak install cluster
```

{{< callout context="danger" title="Watch out!" icon="outline/alert-octagon" >}}
The Root Orchestrator has to be reachable by the Cluster Orchestrator. When not on the same network, the Root Orchestrator URL has to be a public
address!
{{< /callout >}}


### Choose a Different Installation Version

By default, these scripts will use the latest version of Oakestra from the latest stable release. However, this can be changed by appending a specific Oakestra version for each component.

E.g.
```bash
oak install root alpha-v0.4.411 #this installs the alpha-v0.4.411 of oakestra root
```

{{< callout context="danger" title="Watch out!" icon="outline/alert-octagon" >}}
Please make sure all the components of your Oakestra installation run on the same version!
{{< /callout >}}

{{< callout context="note" title="Note" icon="outline/info-circle" >}}
Oakestra has many features that have not yet been released. You can check out what's in the pipeline by taking a look at some of the active [branches](https://github.com/oakestra/oakestra/branches) here.
{{< /callout >}}

### Compose Overrides

Since Oakestra uses docker-compose to build the components, we can use overrides to fine-tune our build environment.

To use the override files, specify them in a comma-separated list by setting the `OVERRIDE_FILES` env variable <u>before running the installation scripts</u>.
```bash
export OVERRIDE_FILES=override-ipv6-enabled.yml
```

{{< details "*Click to see an overview of Root Orchestrator overrides*" >}}
* `override-no-addons.yml`: Disable the [addons](../extending-oakestra/create_addon/) engine and marketplace.
* `override-no-dashboard.yml`: Do not deploy the dashboard.
* `override-no-network.yml`: Exclude network components.
* `override-ipv6-enabled.yml`: Enable IPv6 for container deployments.
* `override-no-observe.yml`: Disable the [observability stack](https://github.com/oakestra/oakestra/blob/7107115a747cf83268aea592df1478cd20933907/root_orchestrator/config/README.md).
{{< /details >}}

{{< details "*Click to see an overview of Cluster Orchestrator overrides*" >}}
* `override-ipv6-enabled.yml`: Enable IPv6 for container deployments.
* `override-no-observe.yml`: Disable the [observability stack](https://github.com/oakestra/oakestra/blob/7107115a747cf83268aea592df1478cd20933907/root_orchestrator/config/README.md).
* `override-mosquitto-auth.yml`: Enable [MQTT Authentication](../networking-internals/mqtt-authentication/).
* `override-no-network.yml`: Exclude network components.
* `override-no-observe.yml`: Disable the [observability stack](https://github.com/oakestra/oakestra/blob/7107115a747cf83268aea592df1478cd20933907/root_orchestrator/config/README.md).
{{< /details >}}


### Advanced Network Configuration

If you run into a restricted network (e.g., on a cloud VM), you need to configure the firewall rules accordingly.

Root:
  - External APIs: port 10000
  - Cluster APIs: ports 10099, 10000

Cluster:
  - Worker's Broker: port 10003
  - Worker's APIs: port 10100

Worker:
  - P2P tunnel towards other workers: port 50103


Additionally, the NetManager component, responsible for the worker nodes' P2P tunnel, must be configured. Therefore, follow these steps on every **Worker Node**:

1) Shutdown your worker node components using
```bash
sudo worker stop
````

2) Edit the NetManager configuration file `/etc/netmanager/netcfg.json` as follows:

```json
{
  "NodePublicAddress": "<IP ADDRESS OF THIS DEVICE, must be reachable from the other workers>",
  "NodePublicPort": "<TUNNEL PORT, The PORT must be reachable from the other workers, use 50103 as default>",
  "ClusterUrl": "0.0.0.0",
  "ClusterMqttPort": "10003",
  "Debug": False
}
```

N.b. leave ClusterUrl to `0.0.0.0`, this field is populated using the NodeEngine data.

3) If necessary, you can customize the NodeEngine cluster configuration

use `oak worker config cluster` command to configure a custom cluster URL.

```
Usage:
  oak worker config cluster [url] [flags]

Flags:
  -p, --clusterPort int   Custom port of the cluster orchestrator (default 10100)
  -s, --clusterSSL        Perform cluster orchestrator handshake over HTTPS
```

Example:
```bash
oak worker config cluster 192.168.10.1
```

4) Restart the NodeEngine
```bash
oak worker -d
```

