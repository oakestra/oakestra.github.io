---
title: "Dashboard Manual Deployment"
description: "Manually deploy the Oakestra Dashboard"
summary: ""
date: 2026-01-21T16:00:00+00:00
lastmod: 2026-01-21T16:00:00+00:00
draft: false
weight: 10306010000
toc: true
seo:
  title: "" # custom title (optional)
  description: "This guide explains how to manually deploy the Oakestra Dashboard for custom setups." # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

<span class="lead">
This guide explains how to manually deploy the Oakestra Dashboard for custom setups.
</span>

{{< callout context="note" title="Automatic Deployment" icon="outline/info-circle">}}
The dashboard is automatically deployed when you start Oakestra using the standard installation scripts. Manual deployment is only necessary for custom configurations or when using override files to exclude the dashboard.
{{< /callout >}}

## Prerequisites

{{< callout context="caution" title="Requirements" icon="outline/alert-triangle">}}
- You have a running Root Orchestrator
- You can access the APIs at `<IP_OF_ROOT_ORCHESTRATOR>:10000`
{{< /callout >}}

## Manual Deployment Steps

### 1. Clone the Dashboard Repository

```bash
git clone https://github.com/oakestra/dashboard.git && cd dashboard
```

### 2. Configure Environment Variables

Create a file containing the environment variables:

```bash
echo "API_ADDRESS=<IP_OF_ROOT_ORCHESTRATOR>:10000" > .env
```

Replace `<IP_OF_ROOT_ORCHESTRATOR>` with the actual IP address of your root orchestrator.

### 3. Run the Dashboard

Start the dashboard using Docker Compose:

```bash
sudo docker compose up
```

## Verification

Once deployed, the dashboard should be accessible at:

```bash
http://<IP_OF_ROOT_ORCHESTRATOR>
```

{{< callout context="danger" icon="outline/alert-octagon">}}
If the Oakestra components (System Manager and MongoDB) are not running or configured correctly, you can reach the login screen but will not be able to log in.
{{< /callout >}}

## Default Credentials

Upon launching the system for the first time, an administrative user is automatically created:

- **Username:** `Admin`
- **Password:** `Admin`

{{< callout context="caution" title="Security Warning" icon="outline/alert-triangle">}}
**After setting up the root, immediately change the password of the admin user!**
{{< /callout >}}

## Troubleshooting

If you experience issues accessing the dashboard:

1. Verify that the Root Orchestrator and all required components are running
2. Check that the `API_ADDRESS` in the `.env` file is correct
3. Ensure that port 80 (or your configured port) is not blocked by a firewall
4. Check the dashboard logs: `docker compose logs`

For more information on dashboard features, see the other pages in this section.
