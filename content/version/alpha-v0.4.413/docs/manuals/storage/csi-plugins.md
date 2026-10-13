---
title: "CSI-Plugins"
summary: "How to manage container CSI-Plugins in Oakestra Clusters"
draft: false
weight: 10310520000
toc: true
seo:
  title: "Manage Container CSI-Plugins in Oakestra"
  description: "Documentation for the CSI Plugins in Oakestra"
  noindex: false
---

<span class="lead">
CSI Plugins allow for flexible storage management on every orchestration platform.
</span>

### Overview
Oakestra supports [CSI](https://github.com/container-storage-interface/spec) Plugins for storage management.

This wiki details how CSI Plugins compliant to the [official specification](https://github.com/container-storage-interface/spec/blob/master/spec.md) can be installed in Oakestra.

### Install headless plugins

A CSI headless plugin is a CSI installation where a Node-only Plugin component supplies only one worker node at a time.
An example is the [*csi.oakestra.io/hostpath*](../hostpath) plugin used to support Volumes in Oakestra. To install such plugins, perform the following steps.

**Step 1.**
Install your CSI Plugin in each Oakestra worker node independently.

**Step 2.**
Connect the CSI Plugin to the Worker Node using the following command
```bash
oak worker config csi add <CSI Plugin Name> unix:///<PATH TO THE EXPOSED CSI PLUGIN SOCKET>
```
*N.b. `oak worker` is jsut an alias for the `NodeEngine` command line utility.*

**Step 3.**
Restart your worker node.
```bash
oak worker stop
oak worker -d
```

###  Install A CSI Plugin with a separate Controller.

The Oakestra Root and Cluster orchestrators currently don't support the CSI Interface for a CSI Plugin Controller.

You need to develop a custom *CSI Adapter* and deploy it as an Oakestra Plugin along with the CSI Plugin Controller.

Please check the [Extending Oakestra](../../extending-oakestra) wiki.
