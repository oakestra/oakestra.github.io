---
title: "Volumes"
summary: "How to manage container volumes in Oakestra Clusters"
draft: false
weight: 10310510000
toc: true
seo:
  title: "Manage Container Volumes in Oakestra"
  description: "Documentation for the Volumes CSI Plugin in Oakestra"
  noindex: false
---

<span class="lead">
Managing volumes at the Edge is not an easy job. Where do we maintain the storage? Where is the data? What nodes can support them?
</span>

### Overview
Oakestra assumes that by default, no edge nodes support volumes. Every worker must explicitly declare the availability for storage that can support volumes. That's because edge devices might have different sizes, and can support different storage.

Oakestra supports Volumes in the form of [CSI](https://github.com/container-storage-interface/spec) Plugins. Meaning that, a volume plugin must be **installed** and **enabled** on each worker node that is planning on accepting volumes mounts.

### Install the Volumes support on your worker nodes.

On each worker node of your infrastructure that would like to support local volume mounts in a *path* of the *host*, you need to install and enable the *csi.oakestra.io/hostpath* CSI Plugin.

**Step 1.**
Startup the **hostpath** CSI Plugin.
```bash
docker run -d \
  --name oakestra-hostpath-csi \
  --privileged \
  --pid host \
  -v /var/lib/oakestra/csi:/var/lib/oakestra/csi:rshared \
  -v /mnt/oakestra/hostpath:/mnt/oakestra/hostpath:rshared \
  ghcr.io/oakestra/oakestra/csi-hostpath-plugin:latest \
  -endpoint unix:///var/lib/oakestra/csi/hostpath.sock
```

**Step 2.**
Enable the CSI Plugin in your worker node.
```bash
oak worker config csi add csi.oakestra.io/hostpath unix:///var/lib/oakestra/csi/hostpath.sock
```
*N.b. `oak worker` is jsut an alias for the `NodeEngine` command line utility.*

**Step 3.**
Restart your worker node.
```bash
oak worker stop
oak worker -d
```

### Check if any node in your infrastructure supports Volumes via the csi.oakestra.io/hostpath plugin.

Use the cluster info functionality to inspect if your cluster supports the `csi.oakestra.io/hostpath` plugin.

```bash
oak cluster info <cluster_name>
```

{{< asciinema key="csi" poster="0:15" idleTimeLimit="3">}}

If your cluster supports the `csi.oakestra.io/hostpath` plugin your should see it listed in the **CSI drivers** list.


### Usage Examples

In your application descriptor (`SLA`), you can define a volume using the following syntax:

```
"volumes": [
      {
          "volume_id":   "my-named-volume",
          "csi_driver":  "csi.oakestra.io/hostpath",
          "mount_path":  "/root/.ollama",
          "config": {
                  "host_path": "ollama"
          }
      }
]
```

{{< callout context="tip" title="Check the SLA Specification" icon="outline/alert-triangle" >}}
You can find [here](../../../reference/app-sla) the full specification for the Oakestra deployment descriptor.
{{< /callout >}}

- `volume_id`: The unique identifier for your volume. If `config.host_path` is not set, this will be used as the folder name for your mount in the system.
- `volume_id`: any compatible CSI driver installed in the platform. In this example, we used `csi.oakestra.io/hostpath`
- `mount_path`: the path inside your container that you want to mount as a volume
- `config.host_path`: custom name for the folder to mount in the host.

This container will mount the internal `/root/.ollama` folder to `/mnt/oakestra/hostpath/ollama`

{{< callout context="warning" title="Be carefull with the mount folder" icon="outline/alert-octagon" >}}
The default path for the mount folder is: `/mnt/oakestra/hostpath`. Your `host_path` or `volume_id` will always be appended from there. This is an intended behaviour to avoid exposing or manipulating internal host directories from a container at the edge.
{{< /callout >}}

{{< callout context="caution" title="Security Concerns" icon="outline/alert-triangle" >}}
The current `csi.oakestra.io/hostpath` does not prevent applications from re-declaring volumes with the same `host_path` and accessing the same folder. This is intended to enable data sharing across applications, but it may introduce security risks. Future implementation will allow data sharing only between apps in the same namespace.
{{< /callout >}}
