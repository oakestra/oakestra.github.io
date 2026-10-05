---
title: "Project SLAs"
summary: ""
draft: false
weight: 10311040200
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

<span class="lead">
  The FLOps manager can only instantiate a new project via a Service Layer Agreement JSON file.
  This guide showcases the structure and all available properties and keys of such SLAs with examples.
</span>

{{< callout context="note" icon="outline/info-circle">}}
  To see project SLAs in action have a look at [Stage 1: Project Start](/docs/manuals/flops-addon/flops-project-workflow/stages/stage-1-project-start/).
{{< /callout >}}


```json
{
  % This key enables more verbose logging in the manager and project observer.
  "verbose": true, % default=false, optional
  % This ID should be the same as for the orchestrator.
  "customerID": "Admin", 
  % FLOps has only been tested for GitHub so far.
  "ml_repo_url": "https://github.com/Malyuk-A/flops_ml_repo_mnist_sklearn",
  % Supported flavors include: sklearn, pytorch, tensorflow, keras.
  "ml_model_flavor": "sklearn",
  % This key only works for special repositories intended for development.
  % It tells the builder to use prebuilt base images to significantly speed up image builds and development.
  "use_devel_base_images": false, % default=false, optional
  % This key expects a list of target platforms on which the built images should run.
  % It supports linux/amd64 and linux/arm64.
  "supported_platforms": ["linux/amd64"], % default=["linux/amd64"], optional
  "training_configuration": {
      % This key specifies the FL type.
      % FLOps supports classic and hierarchical modes.
      "mode": "classic", % default="classic", optional
      % Requested data tags should match available data on learner nodes.
      % Multiple different tags can be requested.
      % The ML data server will use local data fragments that match any of the provided tags.
      % If no data tags are provided the learner will notify watchers that it cannot find any data.
      "data_tags": ["mnist"],
      % Training cycles only apply to the hierarchical mode.
      "training_cycles: 1, % default=1, optional
      % This key tells learners the number of training and evaluation rounds to perform.
      "training_rounds": 3, % default=3, optional
      % Clients mean learners in this context.
      "min_available_clients": 2, % default=1, optional
      "min_fit_clients": 2, % default=1, optional
      "min_evaluate_clients": 2 % default=1, optional
  },
  % FLOps supports these two post-training steps.
  "post_training_steps": ["build_image_for_trained_model", "deploy_trained_model_image"], % default=[], optional
  % These are optional values that require fine-tuning.
  % Note that these values are not recommendations but placeholder values.
  "resource_constraints": {
      "memory": 250, % in MB
      "vcpus": 1,
      "storage": 25 % in MB
  }
}
```

The following SLA shows a simple classic FL project configuration with both post-training steps enabled.
It requires two learners for training.


```json
{
  "verbose": true,
  "customerID": "Admin",
  "ml_repo_url": "https://github.com/Malyuk-A/flops_ml_repo_mnist_sklearn",
  "ml_model_flavor": "sklearn",
  "training_configuration": {
      "data_tags": ["mnist"],
      "min_available_clients": 2,
      "min_fit_clients": 2,
      "min_evaluate_clients": 2
  },
  "post_training_steps": ["build_image_for_trained_model", "deploy_trained_model_image"],
}
```

The next SLA displays a more advanced configuration with HFL, multi-platform support, and more FL actors.

```json
{
  "customerID": "Admin",
  "ml_repo_url": "https://github.com/Malyuk-A/flops_ml_repo_cifar10_pytorch",
  "ml_model_flavor": "pytorch",
  "supported_platforms": ["linux/amd64", "linux/arm64"],
  "training_configuration": {
      "mode": "hierarchical",
      "data_tags": ["cifar10"],
      "training_cycles": 10,
      "training_rounds": 5,
      "min_available_clients":3,
      "min_fit_clients": 3,
      "min_evaluate_clients": 3
  },
  "post_training_steps": ["build_image_for_trained_model", "deploy_trained_model_image"],
}
```

We encourage you to take existing SLAs and play around with different values.
