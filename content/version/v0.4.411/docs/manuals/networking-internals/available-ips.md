---
title: "Retrieve Available Service IPs"
summary: "API Endpoint to query for available Service IPs without reservation."
draft: false
weight: 10305070000
toc: true
seo:
  title: "Retrieve Available Service IPs"
  description: "Documentation for the Service IP retrieval API in Oakestra"
  noindex: false
---

<span class="lead">
Oakestra provides a mechanism to query the System Manager for available Service IPs (IPv4 and IPv6) to avoid address collisions during manual service deployments or addon creation.
</span>

### Overview

When developing addons (e.g., FLOps) or deploying custom services, assigning a static Service IP usually involves guessing an available address or performing calculations on hashes. This approach is error-prone and can lead to IP collisions within the cluster.

The **Network Information API** exposes an endpoint to "ask" Oakestra for valid, currently unoccupied Service IPs.

{{< callout context="note" title="Single Source of Truth" icon="outline/info-circle" >}}
Using this endpoint is the recommended way to acquire Service IPs. It minimizes collisions by checking the centralized database of occupied addresses instead of relying on client-side randomization.
{{< /callout >}}

### Endpoint Definition

The endpoint is part of the `pubnet` API blueprint.

**Method:** `GET`
**Path:** `http://<root-orchestrator-ip>:10099/api/pubnet/service/netinfo/available-ip/{x}`

#### Parameters

| Parameter | Type | In | Description | Default |
| :--- | :--- | :--- | :--- | :--- |
| `x` | `integer` | **Path** | The number of IP addresses to retrieve. | `1` |
| `v` | `string` | **Query** | IP version filter. Values: `"4"` (IPv4), `"6"` (IPv6). If omitted, both are returned. | `None` (Both) |

{{< callout context="caution" title="Important: No Reservation" icon="outline/alert-triangle" >}}
This endpoint returns the **next available** IP addresses but **does not reserve** them in the system.
It is a read-only operation intended to suggest valid IPs for immediate use. If multiple clients query this endpoint simultaneously without using the IPs, they might receive the same addresses.
{{< /callout >}}

### Usage Examples

You can retrieve a single IP, multiple IPs, or filter by version using the query parameters.

#### 1. Retrieve a single available IP (IPv4 & IPv6)

Call the endpoint without specifying `x` to get one available address for both versions (if available).

{{< details "Request & Response" open >}}
**Request:**
```bash
GET http://<root-orchestrator-ip>:10099/api/pubnet/service/netinfo/available-ip
Authorization: Bearer <your-jwt-token>
```

**Response:**
```json
{
  "available_service_ips": [
    "10.30.0.5",
    "fdff:0:0:0:0:0:0:5"
  ]
}
```

{{< /details >}}
#### 2. Retrieve multiple IPv4 addresses
Specify the number of IPs in the path and filter by version `v=4`.

{{< details "Request & Response" >}} 
**Request:**
```bash
GET http://<root-orchestrator-ip>:10099/api/pubnet/service/netinfo/available-ip/3?v=4
Authorization: Bearer <your-jwt-token>
```
**Response:**
```json
{
  "available_service_ips": [
    "10.30.0.12",
    "10.30.0.13",
    "10.30.0.14"
  ]
}
```
{{< /details >}}

#### 3. Retrieve multiple IPv6 addresses
Filter by version `v=6`.
{{< details "Request & Response" >}}
**Request:**
```bash
GET http://<root-orchestrator-ip>:10099/api/pubnet/service/netinfo/available-ip/2?v=6
Authorization: Bearer <your-jwt-token>
```
**Response:**
```json
{
  "available_service_ips": [
    "fdff:0:0:0:0:0:0:a1",
    "fdff:0:0:0:0:0:0:a2"
  ]
}
```
{{< /details >}}