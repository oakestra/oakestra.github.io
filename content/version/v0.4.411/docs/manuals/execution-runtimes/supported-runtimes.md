---
title: "Supported Virtualization Runtimes"
summary: ""
draft: false
weight: 10310010000
toc: true
seo:
  title: "Supported Virtualization Runtimes" # custom title (optional)
  description: "Supported Runtimes within Oakestra" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

<span class="lead">
Oakestra aims to streamline how different virtualization technologies are managed and orchestrated. Instead of limiting you to one type of runtime, Oakestra lets you mix and match different virtualizations for different microservices of your application. This gives you the freedom to choose the best environment for each workload.
</span>

{{< callout context="note" title="What is virtualization?" icon="outline/settings-question" >}}
Modern computing environments often combine different types of runtimes. For example, some applications run best in containers for faster startup times, while others need the strong security boundaries of unikernels. Developers package their applications in these runtimes to take advantage of their unique benefits and deploy them on supported hardware.
{{< /callout >}}

{{< callout context="tip" title="How is multi-virtualization support relevant to my application?" icon="outline/rocket" >}}
You are no longer limited to a single runtime for your applications. With Oakestra, you can use fully isolated unikernels for maximizing your Nginx operations and a Docker container for deploying your machine learning models; and have them work together!

This unique functionality allows you to:
- *Optimize Performance*: Pick the runtime that meets your specific speed and resource requirements.
- *Enhance Security and Isolation*: Run sensitive workloads in more secure, isolated environments when needed.
- *Maintain Flexibility*: Easily switch runtimes as your needs evolve.
{{< /callout >}}

### Supported Runtimes

Currently, Oakestra supports the following virtualization runtimes.

| **Technology**        | **Type**                    | **Description**                                                                                 |
|-----------------------|-----------------------------|-------------------------------------------------------------------------------------------------|
| Containerd            | Container Execution Runtime | Ideal for deploying OCI compliant applications that require easy portability and management.                  |
| Unikraft              | Unikernel Execution Runtime | Specialized, lightweight virtual machines that are optimized for high performance and security. |
| crosvm (experimental) | VM Execution Runtime        | Lightweight virtual machines that allow sharing a GPU between multiple workloads.               |

### How to Choose a Runtime

Picking the right runtime depends on your workload’s priorities. Are you looking for the fastest startup times? Then unikernels might be best suited for your service. Do you need to support complex applications with multiple dependencies? Containers like Docker might be a good choice.

With Oakestra, you can easily switch between runtimes to find the best fit for your workload. *Or* you can package different virtualizations for different microservices of your application to truly unlock the **hybrid virtualization of edge computing**. Oakestra makes it easy to manage and orchestrate different runtimes, so you can focus on building and deploying your applications.

{{< link-card
  description="Learn more about deploying container-based applications with Oakestra"
  href="/docs/getting-started/deploy-app"
  target="_blank"
>}}

Or continue reading to deploy your unikernel applications with Oakestra.

### Additional OCI compliant runtimes 

Containerd allows any OCI compliant runtime to be used as plugin. This means that you can use any OCI compliant runtime with Oakestra, including:
- runc
- runsc 
- runu 

and many more.

To do so, simply install any compatible runtime on your containerd distirbution. 

{{< callout context="tip" title="How do I install Containerd?" icon="outline/rocket" >}}
Oakestra installation automatically provides you with a containerd distribution that is compatible with the OCI runtime you choose. 
{{< /callout >}}

**For example, do you with to install gVisor as secure container runtime?**

1. Add the following configuration in your containerd configuration file:
```toml {title="/etc/containerd/config.toml"}
[plugins.cri.containerd.runtimes.runsc]
  runtime_type = "io.containerd.runsc.v1"
[plugins.cri.containerd.runtimes.runsc.options]
  TypeUrl = "io.containerd.runsc.v1.options"
  ConfigPath = "/etc/containerd/runsc.toml"
```

2. Install gVisor on your system as usual following the [gVisor installation instructions](https://gvisor.dev/docs/user_guide/install/).

3. Restart the Oakestra node engine. You will notice how the new runtime is automatically detected and available for your applications. 

{{< callout context="tip" title="How do I check the available virtualizations in my cluster?" icon="outline/rocket" >}}
Using Oakestra root orchestrator APIs you can check the available runtimes in your cluster at the endpoint `http://<root orchestrator address>:10000/api/clusters/`

Check API documentation from our wiki for more details.

{{< /callout >}}

gVisor secure runtime uses the `runsc` runtime type. Therefore, in your application, simply use `runsc` as virtualization type. An Example application configuration is shown below:

```json
{
  "sla_version": "v2.0",
  "customerID": "Admin",
  "applications": [
    {
      "applicationID": "",
      "application_name": "clientsrvr",
      "application_namespace": "test",
      "application_desc": "Simple demo with curl client and Nginx server",
      "microservices": [
        {
          "microserviceID": "",
          "microservice_name": "nginx",
          "microservice_namespace": "test",
          "virtualization": "runsc",
          "cmd": [],
          "memory": 100,
          "vcpus": 1,
          "vgpus": 0,
          "vtpus": 0,
          "bandwidth_in": 0,
          "bandwidth_out": 0,
          "storage": 0,
          "code": "docker.io/library/nginx:latest",
          "state": "",
          "port": "",
          "addresses": {
            "rr_ip": "10.30.55.55",
            "rr_ip_v6": "fdff:2000::55:55"
          },
          "added_files": []
        }
      ]
    }
  ]
}
```

