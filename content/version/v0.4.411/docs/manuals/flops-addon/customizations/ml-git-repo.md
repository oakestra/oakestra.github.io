---
title: "ML Git Repositories"
summary: ""
draft: false
weight: 10311040300
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

Each FLOps project is associated with precisely one public ML code repository.
Multiple users can reuse the same repository, and each user can create various FLOps projects per repository.
To use your own ML code in FLOps, you must create a properly structured public Git repository and include a link to it in your project SLA.
The repository must fulfill the following structural requirements for this to be possible and straightforward.

{{< svg "ml-code-repository-uml" >}}

The diagram shows additional details of the ML code repositories from the core model.
The repository needs a dedicated file that lists all necessary dependencies to train its model.

{{< callout context="danger" title="Why the explicit Dependencies?" icon="outline/alert-octagon" >}}
  Having proper, minimal, and compatible dependencies is crucial for ML and FLOps.
  Dependencies significantly impact all aspects, from image-building speeds, sizes, deployment times, and more.
  Minor errors in the provided/used dependencies can break your FLOps project.

  Theoretically, it should be possible to extract these requirements dynamically by inspecting the code.
  However, this is a complex and error-prone endeavor.
  To avoid issues, you must provide and check these dependencies as part of your ML repository.

  We recommend using [mlflow's auto-logging feature](https://mlflow.org/docs/latest/tracking/autolog.html?highlight=autologging%20dependencies) to extract those dependencies.
  For this you can temporarily and effortlessly wrap your code with mlflow and use examplary data to run a single training and evaluation cycle for your ML model.

  Always verify if your provided dependency list is correct and in itself compatible. (Even mlflow's extracted dependencies can be erroneous!)
{{< /callout >}}

To help your code to fulfill this necessary structure, please follow these templates:

{{< details "**DataManager Template**">}}
```python
from abc import ABC, abstractmethod
from typing import Any, Tuple


class DataManagerTemplate(ABC):
    @abstractmethod
    def _prepare_data(self) -> Any:
        """Calls the load_ml_data function and does data preprocessing, etc. (optional)

        The Learner does not yet have the data from the worker node.
        To get this data please use the 'load_ml_data' function which can be imported like this:
        ```
        from flops_utils.flops_learner_files_wrapper import load_ml_data
        ```
        Once the data has been fetched, custom data preprocessing and augmentations can be applied.
        """

    @abstractmethod
    def get_data(self) -> Tuple[Any, Any]:
        """Get the necessary data for training and evaluation.

        This data has to be already prepared/preprocessed.

        This method is intended to be called by the ModelManager.

        Examples:
        - self.training_data, self.testing_data
        """
```
{{< /details >}}

{{< details "**ModelManager Template**">}}
```python
class ModelManagerTemplate(ABC):
    @abstractmethod
    def set_model_data(self) -> None:
        """Gets the data from the DataManager and makes it available to the model.

        Do not include this method call in the ModelManager init function.
        The aggregator also needs the model but does not have access to the data.

        This function will be called by the FLOps Learner only.

        It heavily depends on the underlying model and ML library.

        Examples: ()
        - self.trainloader, self.testloader = DataManager().get_data()
        - (self.x_train, self.y_train), (self.x_test, self.y_test) = (
            DataManager().get_data())
        """
        pass

    @abstractmethod
    def get_model(self) -> Any:
        """Gets the managed model.

        Examples:
        - self.model
        - tf.keras.applications.MobileNetV2(
            (32, 32, 3), classes=10, weights=None
        )"""
        pass

    @abstractmethod
    def get_model_parameters(self) -> Any:
        """Gets the model parameters.

        Examples:
        - self.model.get_weights()
        - [val.cpu().numpy() for _, val in self.model.state_dict().items()]
        """
        pass

    @abstractmethod
    def set_model_parameters(self, parameters) -> None:
        """Set the model parameters.

        Examples:
        - self.model.set_weights(parameters)

        - params_dict = zip(self.model.state_dict().keys(), parameters)
        - state_dict = OrderedDict({k: torch.tensor(v) for k, v in params_dict})
        - self.model.load_state_dict(state_dict, strict=True)
        """
        pass

    @abstractmethod
    def fit_model(self) -> int:
        """Fits the model and returns the number of training samples.

        Examples of return values:
        - len(self.x_train)
        - len(self.trainloader.dataset)
        """
        pass

    @abstractmethod
    def evaluate_model(self) -> Tuple[Any, Any, int]:
        """Evaluates the model.

        Returns:
        - loss
        - accuracy
        - number of test/evaluation samples

        Examples of return values:
        - loss, accuracy, len(self.testloader.dataset)
        - loss, accuracy, len(self.x_test)
        """
        pass

```
{{< /details >}}

{{< callout context="note" title="flops-utils is here to help!" icon="outline/first-aid-kit" >}}
  [flops-utils](https://github.com/oakestra/addon-FLOps/tree/main/utils_library) is a [pip package](https://pypi.org/project/flops-utils/) that helps you work with FLOps - including creating your ML repositories. 

  You can import the templates from above into your code to inherit from them:
  ```python
  from flops_utils.ml_repo_templates import DataManagerTemplate
  ```

  `flops-utils` is necessary to build a proper `DataManager`.
  It offers the auxiliary method to be augmented during image building to load the local data for learning.
  Your `DataManager` implementation has to call it.
  ```python
  from flops_utils.ml_repo_building_blocks import load_dataset 
  ```

  Install flops-utils now: `pip install flops-utils`

  *FLOps is using flops-utils throughout its code base.*
{{< /callout >}}

The following are exemplary implementations of the required files:

{{< details "**conda.yml**">}}
```yaml
channels:
  - conda-forge
dependencies:
  - python=3.10.14
  - pip<=24.0
- pip:
  - cloudpickle==3.0.0
  - numpy==1.26.4
  - packaging==24.0
  - psutil==5.9.8
  - pyyaml==6.0.1
  - scikit-learn==1.4.2
  - scipy==1.13.0

name: mlflow-env
```
{{< /details >}}

{{< details "**data_manager.py**">}}
```python
from typing import Any, Tuple

from flops_utils.ml_repo_building_blocks import load_dataset
from flops_utils.ml_repo_templates import DataManagerTemplate


class DataManager(DataManagerTemplate):
    def __init__(self):
        (self.x_train, self.x_test), (self.y_train, self.y_test) = self._prepare_data()

    def _prepare_data(self, partition_id=1) -> Any:
        """Reference: https://github.com/adap/flower/blob/main/examples/sklearn-logreg-mnist/client.py"""
        dataset = load_dataset()
        dataset.set_format("numpy")

        x, y = dataset["image"].reshape((len(dataset), -1)), dataset["label"]
        # Split the on edge data: 80% train, 20% test
        train_split = int(0.8 * len(x))
        x_train, x_test = x[:train_split], x[train_split:]
        eval_split = int(0.8 * len(y))
        y_train, y_test = y[:eval_split], y[eval_split:]
        return (x_train, x_test), (y_train, y_test)

    def get_data(self) -> Tuple[Any, Any]:
        return (self.x_train, self.x_test), (self.y_train, self.y_test)
  ```
{{< /details >}}

{{< details "**model_manager.py**">}}
```python
import warnings
from typing import Any, Tuple

import numpy as np
from data_manager import DataManager
from flops_utils.ml_repo_templates import ModelManagerTemplate
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import log_loss


class ModelManager(ModelManagerTemplate):
    def __init__(self):
        self.model = LogisticRegression(
            penalty="l2",
            max_iter=1,  # local epoch
            warm_start=True,  
        )
        self._set_init_params()

    def _set_init_params(self) -> None:
        """Sets initial parameters as zeros Required since model params are uninitialized
        until model.fit is called.

        But server asks for initial parameters from clients at launch. Refer to
        sklearn.linear_model.LogisticRegression documentation for more information.

        Reference: https://github.com/adap/flower/blob/main/examples/sklearn-logreg-mnist/utils.py
        """
        n_classes = 10  # MNIST has 10 classes
        n_features = 784  # Number of features in dataset
        self.model.classes_ = np.array([i for i in range(10)])
        self.model.coef_ = np.zeros((n_classes, n_features))
        if self.model.fit_intercept:
            self.model.intercept_ = np.zeros((n_classes,))

    def set_model_data(self) -> None:
        (self.x_train, self.x_test), (self.y_train, self.y_test) = (
            DataManager().get_data()
        )

    def get_model(self) -> Any:
        return self.model

    def get_model_parameters(self) -> Any:
        if self.model.fit_intercept:
            params = [
                self.model.coef_,
                self.model.intercept_,
            ]
        else:
            params = [
                self.model.coef_,
            ]
        return params

    def set_model_parameters(self, parameters) -> None:
        self.model.coef_ = parameters[0]
        if self.model.fit_intercept:
            self.model.intercept_ = parameters[1]

    def fit_model(self) -> int:
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            self.model.fit(self.x_train, self.y_train)
        return len(self.x_train)

    def evaluate_model(self) -> Tuple[Any, Any, int]:
        loss = log_loss(self.y_test, self.model.predict_proba(self.x_test))
        accuracy = self.model.score(self.x_test, self.y_test)
        return loss, accuracy, len(self.x_test)
```
{{< /details >}}


### How is FLOps using your ML code?

The image-builder, aggregator, and learners utilize the code provided in the ML code repository.
They have direct access to the model and data managers.
The image builder requires the dependency file to build the actor images properly.
The learner uses the code found in the model and data managers and wraps itself around their implemented interface methods.
As a result, you do not need to implement the FL (boilerplate) code yourself.
Therefore, a learner’s `getParameters` method uses the `getParameters` method described in the user’s ML repository with additional logic.

{{< card-grid >}}
    {{< link-card
    title="Image Building Process"
    description="Learn how FLOps uses your ML code to build fitting FL actor images" 
    href="/docs/concepts/flops/internals/image-building-process"
    >}}
    {{< link-card
    title="Local ML Data Management"
    description="Explore how FLOps synergizes local data with your augmented ML components for training" 
    href="/docs/concepts/flops/internals/ml-data-management/"
    >}}
{{< /card-grid >}}

<br>

Continue reading to learn about advanced FLOps features such as clustered hierarchical FL.
