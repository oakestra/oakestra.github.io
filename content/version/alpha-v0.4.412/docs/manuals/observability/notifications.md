---
title: "Notifications"
summary: "Configure and test Grafana webhook or email alert delivery"
draft: false
weight: 10314000000
toc: true
---

Grafana provisions **Oakestra Alert Webhook** and **Oakestra Alert Email**. `OAKESTRA_ALERT_CONTACT_POINT` chooses the destination for the alert rules; it defaults to the webhook. The webhook's default URL, `http://127.0.0.1:65535/oakestra-alerts`, is intentionally inactive. Alert rules still evaluate, but deliveries fail with connection refused until a real receiver is configured. Oakestra does not run a service at that address.

{{< screenshot src="img/observability stack/Contact points.png" alt="Provisioned webhook and email contact points in Grafana" >}}

## Webhook

Set the destination before creating or recreating Grafana:

```bash
export OAKESTRA_ALERT_CONTACT_POINT="Oakestra Alert Webhook"
export OAKESTRA_ALERT_WEBHOOK_URL="https://alerts.example.com/oakestra"
docker compose -f root_orchestrator/docker-compose.yml up -d --force-recreate grafana
```

## Email

Email requires both a recipient and Grafana SMTP transport:

```bash
export OAKESTRA_ALERT_CONTACT_POINT="Oakestra Alert Email"
export OAKESTRA_ALERT_EMAIL_TO="infra@example.com"
export OAKESTRA_ALERT_SMTP_ENABLED=true
export OAKESTRA_ALERT_SMTP_HOST="smtp.example.com:587"
export OAKESTRA_ALERT_SMTP_USER="infra@example.com"
export OAKESTRA_ALERT_SMTP_PASSWORD="<smtp-password>"
export OAKESTRA_ALERT_SMTP_FROM_ADDRESS="infra@example.com"
export OAKESTRA_ALERT_SMTP_FROM_NAME="Oakestra Alerts"
export OAKESTRA_ALERT_SMTP_SKIP_VERIFY=false
docker compose -f root_orchestrator/docker-compose.yml up -d --force-recreate grafana
```

Use `cluster_orchestrator/docker-compose.yml` and service `cluster_grafana` on a standalone Cluster; use `run-a-cluster/1-DOC.yaml` and `grafana` in 1-DOC. Run the command with the same project and overrides used for the installation. Keep SMTP credentials outside tracked files.

Open **Alerting → Notification configuration → Contact points** to inspect or test the destination, then **Alerting → Alert rules** to inspect evaluation. Grafana's contact-point **Test** checks delivery independently of a rule. A provisioned contact point's structure is maintained in the repository; environment variables provide its destination. Log notifications group by alert name, Cluster, and component, wait 30 seconds to group related instances, and repeat every four hours while the condition persists. Test both evaluation and delivery before relying on an alert.
