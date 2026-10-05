---
title: "Crosvm VM Deployment"
summary: ""
draft: false
weight: 10310030000
toc: true
seo:
  title: "Crosvm VM Deployment"
  description: "Deployment of virtual machine workloads using the
    crosvm runtime in Oakestra"
  canonical: ""
  noindex: false
---

<span class="lead">
Oakestra supports running workloads inside virtual machines via its
crosvm-based runtime, enabling secure multi-tenant GPU sharing through
virtio-GPU.
</span>

{{< callout context="caution" title="Experimental Runtime" icon="outline/alert-triangle" >}}
The crosvm runtime is currently experimental. It requires manual
installation of third-party dependencies (`crosvm`, `virglrenderer`,
`minigbm`) on each worker node before use. See
[Installing Dependencies](#installing-dependencies) below.
{{< /callout >}}

{{< callout context="tip" title="What do you need?" icon="outline/rocket" >}}
To deploy a workload using the crosvm runtime you need:

1. A compatible OCI container image hosted in a registry accessible to
   your Oakestra worker nodes
2. A service deployment descriptor
3. A worker node with the crosvm runtime enabled (use `oak worker config virtualization crosvm on`), KVM support, and the
   required third-party dependencies installed
   {{< /callout >}}

### Building a Compatible Image

The crosvm runtime launches virtual machines directly from OCI container
images. For an image to be compatible, it must:

- Contain a Linux **kernel** at a standard path (e.g., `/boot/vmlinuz`)
- Have **cloud-init** installed (used for network and environment
  variable configuration at boot)

The simplest starting point is an Ubuntu cloud image, which ships with
both cloud-init and a kernel included. Your `Dockerfile` then only needs
to add your application and register it as a systemd service.

```dockerfile
FROM <your-base-image>

# Install your application and register it as a systemd service
RUN apt-get install -y my-app
COPY my-app.service /etc/systemd/system/
RUN systemctl enable my-app
```

{{< link-card
title="Looking for a real-world example?"
description="See the Wolf cloud gaming image for a complete example of a crosvm-compatible image, including the base image Dockerfile."
href="https://github.com/axiphi/oakestra-wolf"
target="_blank"
>}}

### Creating a Service Deployment Descriptor

The crosvm runtime integrates with the standard Oakestra SLA format.

{{< details "Example SLA for a VM-based service" open >}}
```json {title="crosvm-service.json"}
{
  "sla_version": "v2.0",
  "customerID": "Admin",
  "applications": [
    {
      "applicationID": "",
      "application_name": "my-vm-app",
      "application_namespace": "default",
      "application_desc": "A VM-based service using the crosvm runtime",
      "microservices": [
        {
          "microserviceID": "",
          "microservice_name": "my-vm-app",
          "microservice_namespace": "default",
          "virtualization": "crosvm",
          "memory": 4096,
          "vcpus": 4,
          "vgpus": 1,
          "vtpus": 0,
          "bandwidth_in": 0,
          "bandwidth_out": 0,
          "storage": 16384,
          "image": "containers-docker://registry.example.com/my-app:latest",
          "port": "8080:8080",
          "arch": ["amd64"],
          "env": [
            "MY_CONFIG_VALUE=hello"
          ],
          "state": "",
          "added_files": []
        }
      ]
    }
  ]
}
```
{{< /details >}}

**Key fields to note:**

- `virtualization` must be set to `"crosvm"`
- `image` must use the `containers-docker://` prefix followed by a
  standard Docker registry image reference
- `memory` specifies RAM allocated to the VM in MiB
- `vcpus` sets the number of virtual CPU cores
- `storage` sets the writable root filesystem size in MiB
- `vgpus` enables virtio-GPU when set to `1`, allowing the VM to share
  the host GPU — set to `0` to disable GPU access
- `env` passes key-value pairs into the VM via `/etc/environment`,
  making them available to all processes at boot

{{< callout context="caution" title="GPU Support" icon="outline/alert-triangle" >}}
virtio-GPU requires a compatible GPU driver on both the host and the
guest OS. Support is under active development and certain hardware
configurations may not work as expected. See
[Limitations](#limitations) below.
{{< /callout >}}

### Installing Dependencies

The crosvm runtime depends on third-party software (`crosvm`,
`virglrenderer`, and `minigbm`) which must be installed manually on
each worker node.

The Oakestra repository provides a
[build script](https://github.com/oakestra/oakestra/blob/develop/go_node_engine/third_party/build.sh)
that compiles and packages them for you.

**1: Run the build script**

From the directory containing `build.sh`, run it with no arguments:
```bash
./build.sh
```

**2: Copy the archive to your worker node**

Once the build completes, copy the appropriate archive from the `dist/` folder to your worker node (e.g. using `scp`):

```bash
# For amd64 worker nodes
scp dist/prod-amd64.tar.gz <user>@<worker-node>:~

# For arm64 worker nodes
scp dist/prod-arm64.tar.gz <user>@<worker-node>:~
```

**3: Unpack the archive on the worker node**

On the worker node, unpack the archive to its root directory:

```bash
sudo tar -xzf prod-amd64.tar.gz -C /
```

### Limitations

- **virtio-GPU maturity**: virtio-GPU is still under active development.
  Vulkan support and certain GPU driver combinations may not work
  correctly. OpenGL workloads are generally more stable.
- **Performance overhead**: Virtualized graphics performance is significantly lower than native.
  This is expected to improve as virtio-GPU matures.
- **Memory overhead**: The VM hypervisor itself consumes memory beyond
  the configured `memory` limit. Account for additional overhead per
  instance when planning worker node capacity.
- **Host requirements**: The crosvm runtime requires a recent Linux
  kernel (6.x) and up-to-date GPU drivers on the host. Some LTS
  distributions may ship kernels that are too old.
- **Dependency installation**: There is currently no packaged
  distribution of the required third-party binaries. They must be
  compiled and installed manually using the provided build script.
