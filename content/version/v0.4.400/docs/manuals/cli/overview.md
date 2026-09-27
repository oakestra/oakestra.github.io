---
title: "CLI Overview"
summary: ""
draft: false
weight: 306010000
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

{{< callout context="caution" title="Prerequisites" icon="outline/alert-triangle">}}

- You have carefully read [the application deployment with the `oak-cli`](../../../getting-started/deploy-app/deploy-cli/).
- You are familiar with the basic setup, configuration, and usage of the CLI.
  {{< /callout >}}

## The Root CLI Commands

These are the root **`oak-cli`** commands shown in the main `--help` output.
{{< include-sphinx-html "/static/automatically_generated_oak_cli_docs/index.html" >}}
Most root commands have their own set of subcommands.

### Setup

{{< card-grid >}}

{{< link-card
title="Installer"
href="../features/installer/"
description="Set up necessary requirements the easy way." >}}

{{< link-card
title="Configuration"
href="../features/configuration/"
description="Configure the CLI to your liking." >}}

{{< /card-grid >}}

### Workload Components

{{< card-grid >}}

{{< link-card
title="Applications"
href="../features/applications/"
description="Interact with apps." >}}

{{< link-card
title="Services"
href="../features/services/"
description="Interact with services." >}}

{{< /card-grid >}}

### Addons

{{< card-grid >}}

{{< link-card
title="FLOps"
href="../features/flops/"
description="Interact with the FLOps addon to perform practical federated machine learning." >}}

{{< /card-grid >}}

### Developing Oakestra

{{< card-grid >}}

{{< link-card
title="Development"
href="../features/development/"
description="Accelerate local docker based Oakestra development." >}}

{{< link-card
title="Worker Node"
href="../features/worker/"
description="Manage your local worker node." >}}

{{< /card-grid >}}

---

{{< link-card
title="The CLI in action"
description="Use the CLI to deploy your first Oakestra app."
href="../../../getting-started/deploy-app/deploy-cli/" >}}
