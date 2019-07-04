# OctoPerf Enterprise-Edition Helm Chart

This functionality is in beta status and may be changed or removed completely in a future release. OctoPerf will take a best effort approach to fix any issues, but beta features are not subject to the support SLA of official GA features.

## Overview

This chart launches the whole **OctoPerf Enterprise-Edition** stack inside your Kubernetes Cluster. It includes the following components:

- **Elasticsearch**: the main database used to store most of the data,
- **Backend**: the backend server which serves OctoPerf REST API,
- **Frontend**: the Web UI which consumes the REST API exposed by the backend. It's made of static web html/js/css files served by a NGinx server,
- **Documentation**: static web documentation served by a NGinx server.

For a more comprehensive understanding, see [How the Enterprise-Edition works](https://doc.octoperf.com/enterprise-edition/).

## Dependencies

OctoPerf Enterprise-Edition helm chart depends on [Elasticsearch](https://github.com/elastic/helm-charts/tree/master/elasticsearch) helm chart. To configure Elasticsearch through your own `values.yaml`, prefix elasticsearch configuration with `elasticsearch.`.

## Installation

* Add the octoperf helm charts repo:

  ```
  helm repo add octoperf https://helm.octoperf.com
  ```
 
* Install it:

  ```
  helm install --name octoperf-ee octoperf/enterprise-edition --version 11.0.0
  ```

## Compatibility

This chart is tested with the latest supported versions. The currently tested versions are:

| 11.x.x|
| ----- |
| 11.0.0|

Examples of installing older major versions can be found in the [examples](./examples) directory.

## Getting Started

* This repo includes a number of [example](./examples) configurations which can be used as a reference,
* The default storage class for GKE is `standard` which by default will give you `pd-ssd` type persistent volumes. This is network attached storage and will not perform as well as local storage. If you are using Kubernetes version 1.10 or greater you can use [Local PersistentVolumes](https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/local-ssd) for increased performance.
* It is important to verify that the JVM heap size in `elasticsearch.esJavaOpts` and `backend.config.JAVA_OPTS` and to set the CPU/Memory `resources` to something suitable for your cluster.

## Configuration

The configuration is splitted in `4` big sections defined by the prefix being used:

- **No prefix**: global configuration settings such as Docker registry,
- **ingress.** prefix: ingress configuration settings,
- **backend.** prefix: backend configuration settings,
- **frontend.** prefix: frontend configuration settings,
- **doc.** prefix: documentation configuration settings.

| Parameter | Description | Default |
| ----------|-------------|---------|
| `registry` | Docker images registry to use | `registry.hub.docker.com` |
| `imagePullPolicy` | Kubernetes [Image Pull Policy](https://kubernetes.io/docs/concepts/containers/images/#updating-images) | `IfNotPresent` |
| `imagePullSecrets`         | Configuration for [imagePullSecrets](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-pod-that-uses-your-secret) so that you can use a private registry for your image | `[]` |
| `ingress.enabled`         | Enable / Disable Ingress Controller | `true` |
| `ingress.annotations`         | Configurable [annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) applied to all ingress pods  | `{}` |
| `ingress.path`         | ingress path  | `/` |
| `ingress.hosts`         | ingress hosts  | `[enterprise-edition.local]` |
| `ingress.tls`         | ingress tls secrets to use  | `[]` |
| `elasticsearch.clusterHealthCheckParams`         | The [Elasticsearch cluster health status params](https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-health.html#request-params) that will be used by readinessProbe command  | `wait_for_status=yellow&timeout=1s` |
| `doc.enabled`         | Enable / Disable service exposing static documentation using an NGinx deployment | `true` |
| `doc.image`         | The documentation docker image | `enterprise-documentation` |
| `doc.annotations`         | Configurable [annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) applied to all documentation pods  | `{}` |
| `doc.readinessProbe`         | Documentation pods [readinessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)  | `httpGet /doc`<br>`failureThreshold: 3`<br>`initialDelaySeconds: 5`<br>`periodSeconds: 5`<br>`timeoutSeconds: 5` |
| `doc.livenessProbe`         | Documentation pods [livenessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)  | `httpGet /doc`<br>`failureThreshold: 3`<br>`initialDelaySeconds: 5`<br>`periodSeconds: 5`<br>`timeoutSeconds: 5` |
| `doc.nodeSelector`         | Documentation [node selectors](https://kubernetes.io/docs/user-guide/node-selection/)  | `{}`|
| `doc.affinity`         | Documentation pod affinity | `{}`|
| `frontend.enabled`         | Enable / Disable frontend DaemonSet | `true`|
| `frontend.image`         | Enable / Disable frontend DaemonSet | `true`|
| `frontend.annotations`         | Configurable [annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) applied to all frontend pods  | `{}` |
| `frontend.readinessProbe`         | Frontend pods [readinessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)  | `httpGet /doc`<br>`failureThreshold: 3`<br>`initialDelaySeconds: 5`<br>`periodSeconds: 5` |
| `frontend.livenessProbe`         | Frontend pods [livenessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)  | `httpGet /doc`<br>`failureThreshold: 3`<br>`initialDelaySeconds: 5`<br>`periodSeconds: 5` |
| `frontend.config.config-ee.json`         | Frontend [configuration file](https://doc.octoperf.com/enterprise-edition/configuration/#gui-frontend-configuration) content. This file is mounted as a volume on frontend pods. | `Json` |
| `frontend.nodeSelector`         | Frontend [node selectors](https://kubernetes.io/docs/user-guide/node-selection/)  | `{}`|
| `frontend.affinity`         | Frontend pod affinity | `{}`|
| `backend.enabled`         | Enable / Disable Backend StatefulSet | `true`|
| `backend.maxUnavailable`         | The [maxUnavailable](https://kubernetes.io/docs/tasks/run-application/configure-pdb/#specifying-a-poddisruptionbudget) value for the pod disruption budget. By default this will prevent Kubernetes from having more than 1 unhealthy pod in the node group | `1` |
| `backend.annotations`      | Annotations that Kubernetes will use for the service | `{}` |
| `backend.env`      | Backend [Pods environment Variable](https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/) stored in a configmap. See [Enterprise-Edition Configuration](https://doc.octoperf.com/enterprise-edition/configuration/#environment-variables) for more settings. | `JAVA_OPTS: "-Xms256m -Xmx256m"`<br>`server.hostname: "enterprise-edition.local"`<br>`server.public.port: 80`<br>`elasticsearch.hostname: elasticsearch-master-headless`<br>`clustering.driver: hazelcast`<br>`clustering.quorum: "1"` |
| `backend.readinessProbe`         | Backend pods [readinessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)  | `tcpSocket http-port`<br>`initialDelaySeconds: 30`<br>`failureThreshold: 3`<br>`periodSeconds: 5`<br>`successThreshold: 1`<br>`timeoutSeconds: 5` |
| `backend.livenessProbe`         | Backend pods [livenessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)  | `tcpSocket http-port`<br>`initialDelaySeconds: 30`<br>`failureThreshold: 3`<br>`periodSeconds: 5`<br>`successThreshold: 1`<br>`timeoutSeconds: 5` |
| `backend.schedulerName`            | Name of the [alternate scheduler](https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/#specify-schedulers-for-pods)  | `nil` |
| `backend.priorityClassName`        | The [name of the PriorityClass](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/#priorityclass). No default is supplied as the PriorityClass must be created first. | `nil` |
| `backend.secretMounts`             | Allows you easily mount a secret as a file inside the statefulset. Useful for mounting certificates and other secrets. See [values.yaml](./values.yaml) for an example   | `[]` |
| `backend.nodeSelector`             | Configurable [nodeSelector](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector) so that you can target specific nodes.  | `{}` |
| `backend.affinity` | Backend [Affinity](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#node-affinity-beta-feature) | `{}` |
| `backend.podManagementPolicy`      | By default Kubernetes [deploys statefulsets serially](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#pod-management-policies). This deploys them in parallel so that they can discover each other | `Parallel` |
| `backend.updateStrategy` | The [updateStrategy](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/#updating-statefulsets) for the statefulset. By default Kubernetes will wait for the cluster to be green after upgrading each pod. Setting this to `OnDelete` will allow you to manually delete each pod during upgrades | `RollingUpdate` |
| `backend.schedulerName`            | Name of the [alternate scheduler](https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/#specify-schedulers-for-pods) | `nil` |
| `backend.persistentVolume.enabled`            | If true, backend will create/use a Persistent Volume Claim. If false, use emptyDir | `true` |
| `backend.persistentVolume.accessModes`            | Backend data Persistent Volume access modes. Must match those of existing PV or dynamic provisioner. Ref: http://kubernetes.io/docs/user-guide/persistent-volumes/ | `[ReadWriteOnce]` |
| `backend.persistentVolume.accessModes`            | backend data Persistent Volume Claim annotations | `{}` |
| `backend.persistentVolume.mountPath`            | backend data Persistent Volume mount root path inside the pods. | `/home/octoperf/data` |
| `backend.persistentVolume.size`            | backend data Persistent Volume size | `1Gi` |
| `backend.persistentVolume.storageClass`            | backend data Persistent Volume storage class | `nil` |
| `backend.persistentVolume.subPath`            | backend data Persistent Volume Subdirectory of backend data Persistent Volume to mount. Useful if the volume's root directory is not empty | `nil` |
| `backend.resources`            | backend resource requests and limits. Ref: http://kubernetes.io/docs/user-guide/compute-resources/ | `{}` |
| `backend.securityContext`            | Security context to be added to backend pods | `{}` |
| `backend.headless.annotations`            | Backend headless service annotations. | `{}` |
| `backend.headless.labels`            | Backend headless service labels. | `{}` |
| `backend.headless.publishNotReadyAddresses`            | Whenever non-ready backend IPs are exposed through the headless service. | `true` |
| `backend.service.annotations`            | Backend service annotations. | `{}` |
| `backend.service.labels`            | Backend service labels. | `{}` |
| `backend.service.clusterIP`            | Backend service cluster IP. | `nil` |
| `backend.service.externalIPs`            | Backend service external IPs. | `[]` |
| `backend.service.loadBalancerIP`            | Backend service load balancer IP. | `nil` |
| `backend.service.loadBalancerSourceRanges`            | Backend service load balancer source ranges. | `[]` |
| `backend.service.nodePort`            | Custom [nodePort](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport) port that can be set if you are using `service.type: nodePort` | `[]` |

## Local development

This chart is designed to run on production scale Kubernetes clusters with multiple nodes, lots of memory and persistent storage. For that reason it can be a bit tricky to run them against local Kubernetes environments such as [minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/). Below are some examples of how to get this working locally.

### Minikube

This chart also works successfully on [minikube](https://kubernetes.io/docs/setup/minikube/) in addition to typical hosted Kubernetes environments.
An example `values.yaml` file for minikube is provided under `examples/`.

In order to properly support the required persistent volume claims for the Elasticsearch `StatefulSet`, the `default-storageclass` and `storage-provisioner` minikube addons must be enabled.

In order to use the provided `ingress` controller, Ingress addon must be enabled too.

```
minikube addons enable ingress
minikube addons enable default-storageclass
minikube addons enable storage-provisioner
cd examples/minikube
make
```

Note that if `helm` or `kubectl` timeouts occur, you may consider creating a minikube VM with more CPU cores or memory allocated.
