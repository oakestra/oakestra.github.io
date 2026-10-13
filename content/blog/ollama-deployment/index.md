---
title: "Deploy LLMs and Agents with Oakestra"
description: "Oakestra for LLM and Agents deployment and scaling"
summary: ""
date: 2026-05-30T16:27:22+02:00
lastmod: 2026-05-30T16:27:22+02:00
draft: false
weight: 50
categories: [ai]
tags: [ai, blog]
contributors: ["Oakestra Dev Team"]
pinned: false
homepage: false
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

```
{
    "sla_version": "v2.0",
    "customerID": "Admin",
    "applications": [
        {
            "applicationID": "",
            "application_name": "model",
            "application_namespace": "oakversity",
            "application_desc": "OpenClaw custom deployment",
            "microservices": [
                  {
                    "microserviceID": "",
                    "microservice_name": "qwen3527b",
                    "microservice_namespace": "oakmodel",
                    "virtualization": "container",
                    "environment":[
                            "OLLAMA_CONTEXT_LENGTH=128000",
                            "OLLAMA_FLASH_ATTENTION=1",
                            "OLLAMA_NUM_PARALLEL=4",
                            "OLLAMA_MAX_LOADED_MODELS=1",
                            "OLLAMA_KEEP_ALIVE=-1"
                    ],
                    "cmd": ["/bin/sh","-c","ollama serve & sleep 5; ollama run qwen3.5:27b --verbose; sleep inf"],
                    "memory": 0,
                    "vcpus": 0,
                    "vgpus": 1,
                    "vtpus": 0,
                    "bandwidth_in": 0,
                    "bandwidth_out": 0,
                    "storage": 0,
                    "code": "ghcr.io/giobart/ollama:v2",
                    "state": "",
                    "port": "",
                    "addresses":{
                          "rr_ip": "10.30.55.55"
                    },
                    "added_files": [],
                    "constraints":[],
                    "volumes": [
                          {
                                  "volume_id":   "my-named-volume",
                                  "csi_driver":  "csi.oakestra.io/hostpath",
                                  "mount_path":  "/root/.ollama",
                                  "config": {
                                          "host_path": "ollama"
                                  }
                          }
                    ]
                },
                {
                  "microserviceID": "",
                  "microservice_name": "redis",
                  "microservice_namespace": "dev",
                  "virtualization": "container",
                  "environment":[],
                  "cmd": [],
                  "memory": 200,
                  "vcpus": 2,
                  "vgpus": 0,
                  "vtpus": 0,
                  "bandwidth_in": 0,
                  "bandwidth_out": 0,
                  "storage": 0,
                  "code": "docker.io/library/redis:7-alpine",
                  "state": "",
                  "port": "",
                  "addresses":{
                          "rr_ip": "10.30.56.1"
                    },
                  "added_files": [],
                  "constraints":[]
                },
                {
                  "microserviceID": "",
                  "microservice_name": "litellm",
                  "microservice_namespace": "oakbal",
                  "virtualization": "container",
                  "environment":["LITELLM_DROP_PARAMS=True"],
                  "cmd": ["litellm","--config","/app/config.yaml"],
                  "memory": 200,
                  "vcpus": 2,
                  "vgpus": 0,
                  "vtpus": 0,
                  "bandwidth_in": 0,
                  "bandwidth_out": 0,
                  "storage": 0,
                  "code": "ghcr.io/berriai/litellm:main",
                  "state": "",
                  "port": "4000",
                  "addresses":{},
                  "added_files": [],
                  "constraints":[],
                  "addresses":{
                      "rr_ip": "10.30.200.2"
                  },
                  "volumes": [
                        {
                                "volume_id":   "litellm-volume",
                                "csi_driver":  "csi.oakestra.io/hostpath",
                                "mount_path":  "/app/",
                                "config": {
                                        "host_path": "litellm"
                                }
                        }
                  ],
                  "constraints":[
                    {
                      "type":"direct",
                      "node":"cm",
                      "cluster":"defalut_cluster"
                    }
                  ]
                },
                {
                    "microserviceID": "",
                    "microservice_name": "searxng",
                    "microservice_namespace": "dev",
                    "virtualization": "container",
                    "cmd": [],
                    "memory": 200,
                    "vcpus": 1,
                    "vgpus": 0,
                    "vtpus": 0,
                    "bandwidth_in": 0,
                    "bandwidth_out": 0,
                    "storage": 0,
                    "code": "docker.io/searxng/searxng:latest",
                    "state": "",
                    "addresses":{
                          "rr_ip": "10.30.200.1"
                    },
                    "added_files": []
                }
            ]
        }
    ]
}
```

Add the configuration to the `/mnt/oakestra/hostpath/litellm/config.yaml`

```config.yaml
model_list:
  - model_name: "qwen3.5:27b"
    litellm_params:
      model: "ollama/qwen3.5:27b"
      api_base: "http://10.30.55.55:11434"
      rpm: 10
      tpm: 500000
      timeout: 300
      api_key: "ollama"
      drop_params: True
      additional_drop_params: ["max_retries"]

router_settings:
  routing_strategy: "simple-shuffle" # Vital for balancing high user volume

redis_settings:
  redis_host: "10.30.56.1"
  redis_port: 6379

queue_settings:
  enable_queue: true

cache_settings:
  type: "redis" # Enable global response caching

litellm_settings:
    drop_params: true
```


## Test it

```
curl --location 'http://131.159.24.51:4000/chat/completions' --header 'Content-Type: application/json' --data '{"model": "qwen3.5:27b", "messages": [{"role": "user", "content": "hi"}]}'
```
