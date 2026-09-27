---
title: "MLflow MLOps Integration"
summary: ""
draft: false
weight: 205030400
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

## MLflow Basics

[MLflow](https://mlflow.org/) is a broad open-source MLOps platform that enriches and unifies common ML tasks.
It provides automatic solutions for ML challenges.
It supports various popular ML tools and frameworks such as [Keras](https://keras.io/) and [Pytorch](https://pytorch.org/).
MLflow is highly flexible, customizable, and extendable.
It supports ML workflow loops from conception to re-deployment.
MLflow does not explicitly focus on orchestration or FL.

### Selection of critical MLFlow components

MLflow divides its core features into multiple different interconnected components.
These components are rather conceptual groupings of functionalities rather than concrete isolated interfaces.

{{< details "**Tracking**">}}

MLflow can track and log ML experiments to help users record and compare their results.
Tracking details such as frequency, subject, and storage destination are freely configurable.
Users can specify and finetune this tracking or let MLflow handle it automatically.
MLflow offers its tracking via various APIs, including Python and REST.
Tracking only handles lightweight parameters, except for input data.
It does not track or record trained models (weights and biases).

**Key Concepts**

- Experiment: Set of runs
- Run: Specific execution of a piece of code
  - Can record various customizable aspects:
    - Code version, metrics, custom tags, etc.
- Popular elements to track:
  - Hyperparameters
  - Custom meta parameters
  - Utilized code
  - Training data
  - Metrics - e.g., accuracy & loss

The tracking artifacts get recorded in a centralized place.
By default, these artifacts are recorded in a local directory.
These tracked records can also be stored and managed by a dedicated local or remote scalable tracking server, enabling users to easily share their tracked results.
An MLflow tracking server comes with its own sophisticated and feature-rich web-based GUI.
This GUI lets users to inspect, compare, and manage their recorded findings.

FLOps uses MLflow's tracking server and GUI, by deploying it as an Oakestra service to keep the control plane lightweight.
The aggregator communicates with this tracking server to log its training rounds, results, and system metrics.

{{< /details >}}

{{< details "**Models**">}}

MLflow can record and store (trained) ML models in uniform and popular formats.
Popular formats are called "flavors, " including pickle formats, python functions, and ML framework-specific solutions.
Models can be stored with exemplary input data, ML code, metadata, and a list of necessary dependencies for replication.
MLflow differentiates between storing lightweight parameters, meta-information, and models.
Model signatures can also be specified.
These signatures are similar to function signatures in programming.
They include the expected input and output types.
Other tools can utilize such signatures to automatically create a model's correct Python functions or REST APIs.
Due to this standardized representation, many other tools can work with these models.
This uniformity also makes deploying these models more efficient.
MLflow allows users to deploy models to different environments via various ways, such as local inference servers (REST API), docker containers, and Kubernetes.

FLOps utilizes logged MLflow models to allow its users to efficiently work, share, store, export, and deploy its trained FL models.
Furthermore, FLOps combines its own image-building capabilities with MLflow's model API to build matching, easily deployable multi-platform model/inference-server container images.

{{< /details >}}

{{< details "**Registry**">}}

MLflow’s model registry is comparable to an interface or API that works with a subset of logged models.
It is not a dedicated standalone registry, unlike container image registries.
It does not host complete models. This registry enables labeling and versioning for logged models.
Labeling includes specific information that tells users if the model is currently in development, review, or production-ready.
Not all logged models are part of the model registry.
Users can manually or automatically decide if and what models they want to add to the model registry.
This process is called registering a model.
Every registered model is also a logged model.
The benefit of this separation is that models in the registry are carefully selected and managed.

{{< /details >}}

{{< details "**Projects**">}}

Projects allow replicating the exact ML environment for development.
Unlike the code tracked by the tracking or model components, MLflow projects contain the entire codebase used to train a specific model.
Projects aim to uniformly package ML code for reproducibility and distribution.
The heart of an MLflow project is its MLproject file.
It contains all the necessary information regarding dependencies and environments to guarantee identical conditions.
This file can have multiple entry points, similar to a Docker file.
These entry points can be used for different use cases, including training or evaluation.
Other users can quickly start using such projects due to MLflow’s project CLI commands.
MLflow can also invoke a project as part of a dynamically built docker container.
The image gets built automatically via Docker after running the CLI command.
Its CLI allows running projects that are local, remote, or stored in a git repository.

MLflow projects have a lot of potential, but they cannot fully handle robust automatic containerization and dependency management.
They work fine if run directly on a host machine that supports Docker.
Most orchestrators expect images and deploy containers.
It is not yet possible to orchestrate and deploy MLflow projects directly instead of using manually configured images.
Issues arise when wrapping an MLflow project into a generic image and then internally calling its CLI to build and run the corresponding image.
MLflow uses Docker directly, which is, in most cases, not possible inside a containerized environment.
This limitation is represented in the official MLflow examples.
In this example, all necessary dependencies are explicitly mentioned and installed in a custom Dockerfile that needs to be built manually to run the ML experiments.
This emphasizes that MLflow projects cannot be automatically turned into standalone container images yet.
This is a significant reason why FLOps requires a custom image-building approach that can be used in containers to build images.

{{< /details >}}

{{< details "**Storage**">}}

MLflow stores its artifacts in two different data stores.
The default does not use any dedicated local or remote storage components.
Instead, everything gets stored locally.
All lightweight metadata, including metrics, tags, and results, are stored in the backend store.
A backend store can be a database, a file server, or a cloud service.
Heavy artifacts like trained models are kept in the artifact store.
Registered models utilize both stores.
Their metadata, such as versions and hyperparameters, are kept in the backend store.
Their corresponding trained model is located in the artifact store.

{{< /details >}}

These optional components can be arranged in various architectures.
In the simplest case, everything is stored and located on the local machine without a dedicated tracking server or data stores.
More sophisticated structures support shared and distributed workflows and workloads.
The mentioned components can be gradually added or removed, enabling flexible and custom solutions.
For example, the artifact store, backend store, and tracking server can all be deployed on different machines and environments.
This separation of concerns enables improved scalability and reduces singular points of failure.
The tracking server can be a proxy and bridge between machines performing ML experiments and the data stores.
This approach enables centralized security and access control, which simplifies client interactions.

## FLOps' MLOps Architecture

{{<svg "mlops-architecture">}}

The aggregator logs everything besides local elements over the tracking server.
The tracking server works as a proxy for artifacts.
Thus, any access to any logged objects goes through the tracking server.
The tracking server itself does not have any state.
After every training round, the aggregator logs lightweight artifacts like metrics, parameters, tags, or runs.
In addition, the aggregator stores exactly one global model copy locally.
After every round, the aggregator checks if the new model’s performance is better or worse.
The aggregator will update its local model if the new model is better.
At the end of the last training round, the aggregator sends the best-trained global model to the artifact store.

Each run can collect various pieces of information, such as metrics, hyperparameters, or custom tags.
These lightweight elements are represented as **A** in the Figure.
An MLflow experiment gathers multiple runs.
FLOps maps these MLflow terms directly to FL.
An experiment becomes an FLOps project and runs are FL training rounds.

The GUI showcases the stored elements in the backend and artifact stores hosted via the FLOps management.
Note that these stores can be deployed and scaled individually onto different machines.
FLOps currently uses a MySQL database for the backend store and a vsftpd (very secure FTP daemon) server for the artifact store.
No MLOps logging takes place on the learners.
Only the aggregator uses these techniques.
This approach works as expected regarding concrete FL metrics and models.

MLflow also provides a way to track system metrics, which FLOps uses.
These metrics only capture information about the aggregator, not the connected learners.
No information belonging to individual learners gets logged.
Furthermore, FLOps ensures that users can only access their own recorded artifacts.
FLOps explicitly upholds these separations to minimize possible privacy hazards and attack vectors.
