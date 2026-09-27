---
title: "Oakestra releases v0.4.410 (Conga)"
description: "Another big step for Edge-Cloud service orchestration"
summary: ""
date: 2026-04-20T12:27:22+02:00
lastmod: 2026-04-13T12:27:22+02:00
draft: false
weight: 50
categories: [releases]
tags: [releases, announcements]
contributors: ["Oakestra Dev Team"]
pinned: false
homepage: false
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

We are proud to announce that Oakestra Conga 🪘 (v0.4.410) is here! _This is the third major release of Oakestra and the rhythm of the new features will have you dancing!_

{{< card-grid >}}
{{< link-card description="A new CLI" href="#new-cli" >}}
{{< link-card description="New Installation Procedure" href="#new-installation-procedure" >}}
{{< link-card description="Storage Drivers" href="#storage-drivers" >}}
{{< link-card description="Revamped Schedulers" href="#service-scheduling-redefined" >}}
{{< /card-grid >}}

{{< card-grid >}}
{{< link-card description="Marketplace and Addons Dashboard" href="#a-new-look-for-your-addons" >}}
{{< link-card description="CrossVM Compatibility" href="#cross-vm-compatibility" >}}
{{< link-card description="Dashboard SLA Editor" href="#dashboard-deployment-descriptor" >}}
{{< link-card description="A Step Closer to a Production Release" href="#a-step-closer-to-a-production-release" >}}
{{< /card-grid >}}

# New CLI

![oakestra-cli](oakestra-cli.png)

The CLI is now the default way to install and interact with your Oakestra installation. The new CLI is a simple binary that gets installed with a single command: `curl -sfL oakestra.io/oak.sh | bash`

From here you can:

- 📀 Manage your Oakestra components installation
- 📡 Check your cluster status
- 📲 Create and remove applications
- 📈 Create, scale, remove services
- 📊 Monitor deployment status and service information (such as deployment failures, logs, resource usage, and more!)
- 🤖 You can even use Claude AI to solve your Oakestra setup problems

### Check how `oak doctor` can verify your installation

<div style="max-width:50em;margin-right:auto;margin-left:auto">
{{< asciinema key="doctor" theme="dracula" poster="0:10" autoPlay="false" loop="false" startAt="0:5" idleTimeLimit="2" >}}
</div>

{{< callout context="note" title="Did you know?" icon="outline/rocket">}}

You can use Claude AI 🤖 to help you troubleshooting your infrastructure!

- Configure the Claude Oakestra Doctor skill using `oak config claude`
- Then use `oak doctor <component>` command with the `--ai-troubleshoot` flag and let Claude handle the rest.

Check out the troubleshooting [wiki](/docs/manuals/troubleshooting/).

{{< /callout >}}

# New Installation Procedure

Thanks to the new CLI, installing Oakestra has never been easier! Check this out ⬇︎

<div style="max-width:50em;margin-right:auto;margin-left:auto">
{{< asciinema key="install" theme="dracula" poster="0:10" autoPlay="true" loop="true" startAt="0:5" idleTimeLimit="2" >}}
</div>

Check out the [installation wiki](/docs/getting-started/oak-environment/your-first-orchestrator/) for a quick installation and the [advanced setup guide](/docs/getting-started/oak-environment/advanced-cluster-setup/) to unleash the full potential of Oakestra.

# Storage Drivers

![csi](csi.png)

This release brings support for [CSI](https://github.com/container-storage-interface/spec/tree/master) Storage plugins! Volumes management at the edge is not an easy task, and with CSI plugins you can now attach storage drivers customized for your needs. Check out the [CSI Plugin Wiki](/docs/manuals/storage/csi-plugins/).

# Service Scheduling Redefined

Oakestra Conga introduces a redefined concept for task scheduling. Resources and aggregation strategies are now fully generalized, making schedulers swappable across root and cluster components.

![scheduling](scheduling.png)

If you're doing research on task scheduling, you can now customize, implement and replace scheduling strategies at the root and cluster level with minimal effort!

Check out the new [Resource Management wiki](/docs/concepts/resource-management/#canonical-resources) to find out how scheduling and resource management have changed. If you want to implement a new scheduler for Oakestra, check out the [scheduler component README](https://github.com/oakestra/oakestra/tree/develop/scheduler).

# A New Look for Your Addons

![addons](addons.png)

The new addons dashboard allows you to easily manage:

- [Addons](/docs/manuals/extending-oakestra/install_addon/) by connecting to your local marketplace instance and installing your preferred ones.
- [Hooks](/docs/manuals/extending-oakestra/hooks/) via a dedicated UI interface.
- [Custom Resources](/docs/manuals/extending-oakestra/custom_resources/) for both creation and management operations.

![marketplace](marketplace.png)

If the marketplace dashboard is reachable from your network, a link will appear in your Oakestra Dashboard!

# Cross VM Compatibility

Oakestra Conga supports a new experimental runtime: `crossvm`. This runtime enables seamless workloads across different virtual machine environments, providing greater flexibility for edge deployments.

![crossvm](./crossvm.png)

The crosvm runtime launches virtual machines directly from OCI container images. Additionally it provides support for **virtio-GPUs**. This makes it the ideal runtime for isolated edge-cloud gaming instances and AI inference. Check out the [Crosvm VM Deployment](/docs/manuals/execution-runtimes/crosvm-deployment/) page for further details.

# Dashboard Deployment Descriptor

The SLA uploader in the dashboard now supports in-line editing.

![dashboard](sla-upload.png)

Additionally, you can provide the same SLAs as your CLI and APIs, provided that the application name and namespace match the application you're providing the SLA for.

# A Step Closer to a Production Release

This release introduces plenty of under-the-hood improvements for system stability, bringing the platform one step closer to production readiness. You can check the full changelog [here](https://github.com/oakestra/oakestra/releases/tag/v0.4.410).

Get in touch with us and help us grow stronger. We've got plenty of open issues and exciting problems to work on.

{{< rawhtml >}}

<style>
  @keyframes conga-shake {
    0%   { transform: rotate(0deg) scale(1); }
    10%  { transform: rotate(-12deg) scale(1.05); }
    25%  { transform: rotate(12deg) scale(1.08); }
    40%  { transform: rotate(-10deg) scale(1.05); }
    55%  { transform: rotate(10deg) scale(1.08); }
    70%  { transform: rotate(-6deg) scale(1.03); }
    85%  { transform: rotate(6deg) scale(1.03); }
    100% { transform: rotate(0deg) scale(1); }
  }
  #conga-egg-wrap {
    display: flex;
    flex-direction: column;
    align-items: center;
    margin: 1.5rem 0 2rem 0;
    user-select: none;
  }
  #conga-egg {
    height: 110px;
    cursor: pointer;
    transform-origin: bottom center;
    transition: filter 0.2s;
    filter: drop-shadow(0 4px 12px rgba(0,0,0,0.18));
  }
  #conga-egg:hover {
    filter: drop-shadow(0 6px 18px rgba(200,120,0,0.35));
  }
  #conga-egg.shaking {
    animation: conga-shake 0.45s ease-in-out;
  }
  #conga-hint {
    margin-top: 0.55rem;
    font-size: 0.82rem;
    color: #a07030;
    letter-spacing: 0.03em;
    opacity: 0;
    transition: opacity 0.3s;
    min-height: 1.2em;
  }
</style>
<div id="conga-egg-wrap">
  <img id="conga-egg" src="conga-icon.svg" alt="Conga drum – click me!" title="Click me..." />
  <span id="conga-hint"></span>
</div>
<script>
(function () {
  var egg = document.getElementById('conga-egg');
  var hint = document.getElementById('conga-hint');
  var clicks = 0;
  var hints = ['🥁 Again…', '🥁 One more!', '🎵 Here we go!'];

var audio = new Audio('/audio/conga.mp3');

egg.addEventListener('click', function () {
audio.currentTime = 0;
audio.play().catch(error => {
console.error("Audio failed to play:", error);
hint.textContent = "Audio Error: " + error.message;
});

    egg.classList.remove('shaking');
    void egg.offsetWidth; // force reflow to restart animation
    egg.classList.add('shaking');
    clicks++;

    if (clicks <= 3) {
      hint.style.opacity = '1';
      hint.textContent = hints[clicks - 1] || '';
    }

    if (clicks >= 3) {
      setTimeout(function () {
        window.location.href = '/oakestra-instruments/';
      }, 520);
    }

});

egg.addEventListener('animationend', function () {
egg.classList.remove('shaking');
});
})();
</script>
{{< /rawhtml >}}

#### Acknowledgments:

Many thanks to the contributors for this release:

- [@Mjaethers](https://github.com/Mjaethers)
- [@axiphi](https://github.com/axiphi)
- [@HMF2475](https://github.com/HMF2475)
- [@melkodary](https://github.com/melkodary)
- [@smnzlnsk](https://github.com/smnzlnsk)
- [@giobart](https://github.com/giobart)
- [@nitindermohan](https://github.com/nitindermohan)
