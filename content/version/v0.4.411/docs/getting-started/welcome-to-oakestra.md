---
title: "Welcome to the Oakestra Documentation"
summary: ""
draft: false
weight: 10101000000
toc: true
seo:
  title: "welcome to oakestra docs" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---
<span class="lead">
Oakestra is a flexible and lightweight orchestration framework designed for all your edge computing needs. Accelerate your next-generation applications with Oakestra!
</span>

## What is Oakestra?

Oakestra is an open-source orchestration framework designed to optimize the deployment and execution of containerized applications in edge and cloud environments. Under the hood, Oakestra uses several clever techniques for *efficient resource management* and *workload orchestration* to address the challenges of running modern, distributed applications in the constrained and dynamic edge-cloud computing continuum.

{{< callout context="tip" title="Did you know?" icon="outline/rocket" >}}
Oakestra is built from the ground up to support the computational flexibility of edge devices while remaining compatible with the cloud-native ecosystem. You can be confident that your applications will run smoothly on a variety of hardware, from small edge devices to powerful cloud servers.
{{< /callout >}}

## Why should you use Oakestra?

{{< card-grid >}}
{{< card title="Edge-Cloud Native" icon="filled/feather" color="yellow" >}}
Oakestra prioritizes minimal overhead to address the computational, storage, and network limitations of edge nodes to unlock the full potential of the edge-cloud continuum.

- [Set up your first Oakestra environment](../oak-environment/high-level-view/)
{{< /card >}}

{{< card title="Efficient App Management" icon="outline/layout-dashboard" color="blue" >}}
Take full control of your microservices with Oakestra's powerful API and intuitive management tools.

- [Oakestra CLI](../deploy-app/deploy-cli/)
- [Oakestra Dashboard](../deploy-app/deploy-dashboard/)
- [Oakestra API](../../reference/api/deploy-api/)
- [Application Catalog](../../manuals/app-catalog/catalog/)

{{< /card >}}

{{< /card-grid >}}

{{< card-grid >}}
{{< card title="Extensible Design" icon="outline/stack-2" color="purple" >}}
Designed with a plug-and-play approach, Oakestra supports customizable orchestration policies, scheduling algorithms, and integration with third-party tools.

- [Addons](../../concepts/oakestra-extensions/addons/)
- [Hooks](../../concepts/oakestra-extensions/hooks/)
- [Custom Resources](../../concepts/oakestra-extensions/custom_resources/)
{{< /card >}}

{{< card title="Bleeding-Edge Features" icon="outline/adjustments-star" color="red" >}}
Leverage several innovative techniques Oakestra uses to make your applications edge-cloud efficient.

- [Multi-Virtualization Support](../../manuals/execution-runtimes/supported-runtimes/)
- [Semantic Networking](../../concepts/networking/)
- [Federated Machine Learning Support](../../concepts/flops/overview/)

{{< /card >}}

{{< /card-grid >}}

{{< callout context="note" icon="outline/flask" >}}
Oakestra has appeared in world-class scientific conferences and journals. Check out our [publications](/research/) to learn more.
{{< /callout >}}

## Contribute

Oakestra is open source with an `Apache 2.0` license. Contributions are welcome! If you want to open an issue, contribute some code, or simply take a look under the hood, then head over to our [GitHub](https://github.com/oakestra/). We recommend linking up with the Oakestra community over [Discord](https://discord.gg/7F8EhYCJDf).

Whether you're a beginner or an advanced user, joining our community is the best way to connect with like-minded people who build great products.

{{< card-grid >}}
{{< link-card
  title="Contribute to Oakestra"
  description="Read our contribution guide"
  href="/docs/contribution-guide/contributing-guide/"
>}}

{{< link-card
  title="Join us"
  description="Meet our lively Discord community"
  href="https://discord.gg/7F8EhYCJDf"
>}}

{{< link-card
  title="Follow us"
  description="See our updates on X"
  href="https://x.com/oakestra"
>}}

{{< /card-grid >}}
