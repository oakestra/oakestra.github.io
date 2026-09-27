---
title: "Writing Python logs"
summary: "Write safe, queryable schema-v1 logs for Oakestra Python services"
draft: false
weight: 10402500000
toc: true
seo:
  title: "Writing Python logs in Oakestra"
  description: "Write safe, structured Oakestra Python logs with schema-v1 JSON, contextual fields, redaction, and queryable severity"
  canonical: ""
  noindex: false
---

Oakestra Python control-plane services use the shared `oakestra_logging` package to emit one JSON object per application event to stdout. Docker captures the line, Alloy forwards it, and Loki stores it without requiring a service-specific text parser.

The package wraps [Structlog](https://www.structlog.org/) and bridges Python's standard `logging` module through `ProcessorFormatter`. Application modules choose a level, a short static message, an optional stable event name, and bounded context. They must not configure a separate renderer or handler.

This contract currently standardizes Oakestra-owned Python application records, standard-library records routed through the shared handler, and Gunicorn records. Go services, subprocesses, development-server banners, and third-party code that writes directly to stdout/stderr can still be unstructured. Alloy retains those lines and applies narrowly scoped compatibility parsers where possible.

## Configure a service

Call `configure_logging()` once in the service entry point before serving work. `OAKESTRA_SERVICE_NAME` distinguishes runtime roles that share an image. The library's `LOG_LEVEL` fallback is `INFO`; deployment configuration sets Resource Abstractors to `WARNING` by default. An explicit `LOG_LEVEL` overrides the deployment default.

```python
import os

from oakestra_logging import configure_logging, get_logger

configure_logging(os.getenv("OAKESTRA_SERVICE_NAME", "system_manager"))
logger = get_logger(__name__)
```

Other modules obtain a logger named after their Python module:

```python
from oakestra_logging import get_logger

logger = get_logger(__name__)
```

`__name__` records the module that emitted the event, such as `services.service_management`. This makes the `logger` field useful without hard-coding names that become stale when modules move.

Supported `LOG_LEVEL` values are `DEBUG`, `INFO`, `WARN`, `WARNING`, `ERROR`, `FATAL`, and `CRITICAL`. Output always normalizes them to lowercase `debug`, `info`, `warning`, `error`, or `critical`. An invalid setting produces a structured warning and falls back to `INFO`.

## Schema v1

Every standardized record contains:

| Field            |    Required | Meaning                                                         |
| ---------------- | ----------: | --------------------------------------------------------------- |
| `schema_version` |         yes | Contract version, currently `1`                                 |
| `timestamp`      |         yes | UTC ISO/RFC 3339 timestamp                                      |
| `level`          |         yes | Normalized severity                                             |
| `service`        |         yes | Runtime role configured for this process                        |
| `logger`         |         yes | Python module or standard-library logger name                   |
| `message`        |         yes | Short human-readable description                                |
| `event`          |          no | Stable dotted event identifier supplied as `event_name`         |
| `context`        |          no | Structured application values and bound fields                  |
| `source`         | conditional | File, function, and line for warning/error/critical records     |
| `exception`      |          no | Exception type, message, and stacktrace in the same JSON record |

An example record is:

```json
{
  "context": {
    "cluster_id": "abc123",
    "job_count": 2
  },
  "event": "cluster.registration.completed",
  "level": "info",
  "logger": "services.cluster_management",
  "message": "Cluster registration completed",
  "schema_version": 1,
  "service": "system_manager",
  "timestamp": "2026-07-22T10:00:00Z"
}
```

The application `service` field describes the process role. Alloy's indexed `compose_service` label describes the container source. A contextual `cluster_id` may identify a business object involved in an operation, while Alloy's `cluster_id` label identifies the orchestration plane that emitted the line. Do not duplicate Docker labels manually in every logging call.

## Write useful records

Use a static message and pass changing values as keyword arguments:

```python
logger.info(
    "Cluster registration completed",
    event_name="cluster.registration.completed",
    cluster_id=cluster_id,
    worker_count=worker_count,
)
```

Avoid interpolating complete objects into the message:

```python
# Avoid: dynamic data is difficult to query and may expose the payload.
logger.info(f"Registered cluster {cluster_id}: {cluster_payload}")
```

Use lowercase dotted event names for operational events that may be queried, counted, linked, or alerted on. Keep the event name stable when wording changes; never include an ID inside it.

Good context is small and bounded: identifiers, counts, enum-like states, durations, retry numbers, field names, and target components. Do not log complete requests, users, SLAs, MQTT messages, database documents, HTTP responses, environment dictionaries, or resource snapshots. Prefer `payload_size`, `field_count`, or a necessary identifier.

### Bind operation context

When several records belong to one operation, bind shared fields to a local logger:

```python
operation_logger = logger.bind(
    operation="deployment",
    job_id=job_id,
    cluster_id=cluster_id,
)

operation_logger.info(
    "Deployment started",
    event_name="deployment.started",
)

operation_logger.info(
    "Deployment completed",
    event_name="deployment.completed",
)
```

`bind()` returns a new logger that automatically includes those fields; it does not mutate the original module logger. Keep operation-specific bound loggers inside the request, job, or function scope. Do not attach changing request data to a global logger.

### Choose the level

| Level      | Use it for                                                           |
| ---------- | -------------------------------------------------------------------- |
| `debug`    | Detailed or high-frequency diagnostics normally hidden in production |
| `info`     | Expected lifecycle events and successful state changes               |
| `warning`  | Unexpected but recoverable conditions requiring attention            |
| `error`    | An operation failed, but the process can continue serving other work |
| `critical` | The service cannot initialize or safely continue                     |

Do not report a normal client 4xx response as an internal error merely because a request was rejected. Do not fill tight loops and periodic health checks with Info records. Warning and higher records include source location automatically; lower levels omit it to reduce volume.

### Record an exception once

Use `logger.exception()` at the boundary that handles, translates, retries, or terminates because of a failure:

```python
try:
    deploy_service(service_id)
except DeploymentError:
    logger.exception(
        "Service deployment failed",
        event_name="service.deploy.failed",
        service_id=service_id,
        operation="deploy_service",
    )
    raise
```

The package stores the exception type, message, and escaped traceback in one `exception` object and emits one line. Do not also call `traceback.print_exc()` or log the same failure at every layer. Use `warning` or `error` with a safe `error_type` when a traceback adds no diagnostic value.

## Redaction and sensitive data

The logging processor recursively redacts values stored under keys representing passwords, secrets, tokens, authorization headers, cookies, API keys, private keys, and credentials. Redaction is case-insensitive and applies to nested mappings.

It is a final safeguard, not permission to log secrets. It cannot discover a token embedded in a message, exception text, opaque string, or innocent-looking field. Exclude sensitive and personal data at the call site and do not construct exceptions that contain credentials or complete payloads.

## Standard-library and Gunicorn integration

Existing modules and dependencies may continue to use Python's standard logging API. Records that reach the configured root handler pass through the same JSON contract:

```python
import logging

legacy_logger = logging.getLogger(__name__)
legacy_logger.info(
    "Lookup completed",
    extra={"operation": "lookup", "result_count": result_count},
)
```

Safe `extra` values move under `context`. Do not install another `basicConfig()`, rotating file handler, or JSON formatter in an Oakestra service because it can duplicate records or bypass the shared redaction and schema.

The shared Gunicorn logger routes `gunicorn.error` and `gunicorn.access` through the root handler. Logger names identify the origin but do not define severity: a logger named `gunicorn.error` can still emit an Info record. Use the normalized `level` field or Alloy label.

## Query structured records

Docker output can be filtered locally with `jq`:

```bash
docker logs --tail 200 system_manager 2>&1 |
  jq -R 'fromjson? | select(.schema_version == 1)'
```

In Loki, select the trusted container labels and parse application fields at query time:

```logql
{cluster_id="root", compose_service="system_manager"}
| json
| __error__ = ""
| schema_version = 1
| level = "error"
```

The indexed Alloy `level` label is more efficient for broad severity selection:

```logql
{cluster_id="root", compose_service="system_manager", level=~"error|critical"}
| json
| __error__ = ""
| schema_version = 1
```

Application fields such as `event`, `logger`, and `context.job_id` stay queryable without becoming permanent labels:

```logql
{cluster_id="root", compose_service="system_manager"}
| json event_name="event", job_id="context.job_id"
| event_name = "deployment.started"
| job_id = "<JOB_ID>"
```

## Relationship to alerts

Grafana treats Alloy's normalized `level=error|critical` label as authoritative. For schema-v1 Python and Gunicorn records, that label comes from the validated structured level. An Info message containing the text `ERROR` must not trigger an alert. A separate compatibility path handles known records without a normalized level and explicitly excludes schema-v1 lines to avoid double counting.

As more components adopt structured output, compatibility matching can become narrower. Do not weaken the schema path by guessing severity from arbitrary message text.

## Validate logging changes

Run the shared package tests from an Oakestra source checkout:

```bash
python -m venv .venv
. .venv/bin/activate
pip install -e 'libraries/oakestra_logging[test]'
pytest libraries/oakestra_logging/tests
```

For a service change, also run its tests, Ruff, Python compilation, and a container smoke test. Confirm that:

- one application event produces one JSON line;
- all required schema fields exist;
- warning/error/critical records contain `source`;
- exceptions remain one record rather than a multiline duplicate;
- nested sensitive keys are redacted;
- `LOG_LEVEL` suppresses lower-severity records;
- standard-library and Gunicorn records pass through the same handler;
- Alloy attaches the expected `cluster_id`, `compose_service`, and normalized `level` labels.

Read the [Observability manuals](../../manuals/observability/overview/) for dashboards, queries, alert destinations, and troubleshooting. The [shared package README](https://github.com/oakestra/oakestra/blob/feat/566-standardize-python-orchestrator-logging-as-structured-json/libraries/oakestra_logging/README.md) and [schema](https://github.com/oakestra/oakestra/blob/feat/566-standardize-python-orchestrator-logging-as-structured-json/libraries/oakestra_logging/oakestra_logging/schema/log-event-v1.schema.json) are the authoritative implementation references.

<!-- TODO(release): Point the package links to the released Oakestra tag after the structured-logging branch merges. -->
