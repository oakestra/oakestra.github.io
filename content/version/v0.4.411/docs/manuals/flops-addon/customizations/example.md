---
title: "Example Projects"
summary: ""
draft: false
weight: 10311040400
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

<span class="lead">
Check out these examples from the community!
</span>

Here a collection of examples that you can already use to experiment with FLOps.

# Handwritten Digits

For the handwritten digits recognition task, we provide 4 different examples based on the `mnist` training dataset.
For the training, you can use the default mock data provider.

```bash
  curl -sSl https://oakestra.io/FLOps_SLAs/mocks/mnist_multi.json > mnist_multi.json
  oak addon flops mock-data mnist_multi.json
```

{{< callout context="note" title="Do you want to injest your own data?" icon="outline/settings-question" >}}
  FLOps uses Arrow Flight for data ingestion. Each Learner Node uses a Arrow Flight server and client combination. Check out [here](/docs/concepts/flops/internals/ml-data-management/) how this works.
{{< /callout >}}


{{< tabs "mnist" >}}
{{< tab "Small" >}}

This is a small example also used as the example in the [../../flops-project-workflow/overview] section.

You can download the SLA for this example using

```bash
  curl -sSl https://oakestra.io/FLOps_SLAs/projects/mnist_sklearn_small.json > mnist_sklearn_small.json
```

and then you can run the project using

```bash
  oak addon flops p mnist_sklearn_small.json
```

{{< /tab >}}
{{< tab "Large" >}}

You can download the SLA for this example using

```bash
  curl -sSl https://oakestra.io/FLOps_SLAs/projects/mnist_sklearn_large.json > mnist_sklearn_large.json
```

and then you can run the project using

```bash
  oak addon flops p mnist_sklearn_large.json
```

{{< /tab >}}
{{< tab "Hierarchical S" >}}

You can download the SLA for this example using

```bash
  curl -sSl https://oakestra.io/FLOps_SLAs/projects/hierarchical_mnist_sklearn_small.json> hierarchical_mnist_sklearn_small.json
```

and then you can run the project using

```bash
  oak addon flops p hierarchical_mnist_sklearn_small.json
```

{{< /tab >}}
{{< tab "Hierarchical L" >}}

You can download the SLA for this example using

```bash
  curl -sSl https://oakestra.io/FLOps_SLAs/projects/hierarchical_mnist_sklearn_large.json > hierarchical_mnist_sklearn_large.json
```

and then you can run the project using

```bash
  oak addon flops p hierarchical_mnist_sklearn_small.json
```

{{< /tab >}}
{{< /tabs >}}

#### Core differences between these examples
| Name    | `mode` | `rounds` | `clients` | `cycles` | `post_training` | `arch`
| --------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
| Small    | classic | 3 | 2 | N/A | build & deploy trained model | amd64 |
| Large | classic | 10 | 4 | N/A | build & deploy trained model  | amd64 |
| Hierarchical S | hierarchical | 3 | 2 | 2 | build & deploy trained model | amd64 |
| Hierarchical L | hierarchical | 5 | 3 | 10 | build & deploy trained model | amd64 |

{{< callout context="note" icon="outline/info-circle">}}
  Check out [FLOps SLA configuration](../slas) page to learn how to customize your project.
{{< /callout >}}


# Object Recognition

For a simple FL object recognition example, here you can find an example based on the cifar10 dataset.

For the training, you can use the default mock data provider for this example.

```bash
  curl -sSl https://oakestra.io/FLOps_SLAs/mocks/cifar10_simple.json > cifar10_simple.json
  oak addon flops mock-data cifar10_simple.json
```

{{< callout context="note" title="Do you want to injest your own data?" icon="outline/settings-question" >}}
  FLOps uses Arrow Flight for data ingestion. Each Learner Node uses a Arrow Flight server and client combination. Check out [here](/docs/concepts/flops/internals/ml-data-management/) how this works.
{{< /callout >}}


Then, you can download the SLA for this example running

```bash
  curl -sSl https://oakestra.io/FLOps_SLAs/projects/cifar10_pytorch.json > cifar10_pytorch.json
```

and finally you can run the project using

```bash
  oak addon flops p cifar10_pytorch.json
```

Here a summary of the settings for this default SLA

#### Standard Example Configuration
| Name    | `mode` | `flavor` | `rounds` | `clients` | `post_training` | `arch` |
| --------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
| cifar10_pytorch    | classic | pyTorch | 3 | 2 | build & deploy trained model | amd64 |

{{< callout context="note" icon="outline/info-circle">}}
  Check out [FLOps SLA configuration](../slas) page to learn how to customize your project.
{{< /callout >}}
