# OctoPerf Enterprise-Edition Helm Chart

This functionality is in beta status and may be changed or removed completely in a future release. OctoPerf will take a best effort approach to fix any issues, but beta features are not subject to the support SLA of official GA features.

## Overview

This chart launches the whole **OctoPerf Enterprise-Edition** stack inside your Kubernetes Cluster. It includes the following components:

- **Elasticsearch**: the main database used to store most of the data,
- **Backend**: the backend server which serves OctoPerf REST API,
- **Frontend**: the Web UI which consumes the REST API exposed by the backend. It's made of static web html/js/css files served by a NGinx server on `/app`,
- **Frontend Beta**: the Beta Web UI which consumes the REST API exposed by the backend. It's made of static web html/js/css files served by a NGinx server on `/ui`,
- **Documentation**: static web documentation served by a NGinx server.

For a more comprehensive understanding, see How the [Enterprise-Edition](https://api.octoperf.com/doc/on-premise-infra/) works.

## Dependencies

OctoPerf Enterprise-Edition helm chart depends on:

- [Elasticsearch](https://github.com/elastic/helm-charts/tree/master/elasticsearch/).

## Prerequisites

When `ingress.enabled` is `true`, the cluster must run [Traefik v3](https://doc.traefik.io/traefik/) as ingress controller, with both providers enabled:

- `kubernetesIngress`: serves the chart `Ingress` resources (ingress class `traefik` by default, see `ingress.className`),
- `kubernetesCRD`: serves the chart `Middleware` resources (`traefik.io/v1alpha1`). The `traefik.io` CRDs must be installed.

Both are enabled by default on [k3s](https://docs.k3s.io/networking/networking-services#traefik-ingress-controller) and with the official [Traefik Helm chart](https://github.com/traefik/traefik-helm-chart). On [RKE2](https://docs.rke2.io/networking/networking_services), Traefik must be selected as ingress controller and the `kubernetesCRD` provider enabled.

> **Important: request read timeout.** Traefik v3 stops reading requests after `60s` by default, which breaks large uploads (e.g. JMeter projects, CSV files).
> Raise it in the Traefik chart values, for every entrypoint used:
>
> ```yaml
> ports:
>   web:
>     transport:
>       respondingTimeouts:
>         readTimeout: 3600s
>   websecure:
>     transport:
>       respondingTimeouts:
>         readTimeout: 3600s
> ```
>
> On a RKE2 cluster managed by Rancher, set these values in the cluster `chartValues` (Rancher cluster configuration) rather than in a `HelmChartConfig`, otherwise Rancher overwrites them.

> **Prefix matching.** By default (`providers.kubernetesIngress.strictPrefixMatching: false`), Traefik matches `pathType: Prefix` character by character: a `Prefix /doc` path would also catch backend paths such as `/docker/rendezvous/...` or `/docker-engine-api.json`.
> This chart is not affected: it declares `Exact /doc` + `Prefix /doc/` paths (same for `/ui`, `/mcp` and `/utilities`), and gives the backend `/` catch-all the lowest router priority (`traefik.ingress.kubernetes.io/router.priority: "1"`) so that shorter rules such as `Path(/doc)` still win. Enabling strict matching, as defined by the Kubernetes Ingress specification, is still recommended for other ingresses of the cluster:
>
> ```yaml
> providers:
>   kubernetesIngress:
>     strictPrefixMatching: true
> ```

The chart creates the following Traefik middlewares (when `ingress.traefik.middlewares.enabled` is `true`), prefixed by the chart name:

| Ingress | Path | Middlewares (in order) |
| --------|------|------------------------|
| Backend | `/` | `compress` |
| Frontend | `/ui`, `/ui/` | `compress`, `strip-ui` |
| Documentation | `/doc`, `/doc/` | `compress`, `doc-trailing-slash` (redirects `/doc` and `/doc/guide` to `/doc/` and `/doc/guide/`), `strip-doc` |
| Utility server | `/utilities`, `/utilities/` | `compress` |
| MCP server | `/mcp`, `/mcp/` | none: compression would buffer the Streamable HTTP (SSE) responses |

`ingress.traefik.extraMiddlewares` are appended to every ingress, after the chart ones.

## Installation

* Add the octoperf helm charts repo:

  ```
  helm repo add octoperf https://helm.octoperf.com
  ```
 
* Install it:

  ```
  helm install --name octoperf-ee octoperf/enterprise-edition
  ```

## Compatibility

This chart is tested with the latest supported versions. The currently tested versions are:

| 17.x.x|
| ------|
| 17.0.1|

| 16.x.x|
| ------|
| 16.2.3|
| 16.2.2|
| 16.2.1|
| 16.1.2|
| 16.1.1|
| 16.1.0|
| 16.0.0|

| 15.x.x|
| ------|
| 15.4.1|
| 15.4.0|
| 15.3.0|
| 15.2.2|
| 15.2.1|
| 15.2.0|
| 15.1.0|
| 15.0.0|

Examples of installing older major versions can be found in the [examples](./examples) directory.

## Getting Started

* This repo includes a number of [example](./examples) configurations which can be used as a reference,
* The default storage class for GKE is `standard` which by default will give you `pd-ssd` type persistent volumes. This is network attached storage and will not perform as well as local storage. If you are using Kubernetes version 1.10 or greater you can use [Local PersistentVolumes](https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/local-ssd) for increased performance.
* It is important to verify that the JVM heap size in `elasticsearch.esJavaOpts` and `backend.config.JAVA_OPTS` and to set the CPU/Memory `resources` to something suitable for your cluster.

## Configuration

The configuration is split in `4` big sections defined by the prefix being used:

- **No prefix**: global configuration settings such as Docker registry,
- **ingress.** prefix: ingress configuration settings,
- **backend.** prefix: backend configuration settings,
- **frontend.** prefix: frontend configuration settings,
- **doc.** prefix: documentation configuration settings.

**An example of configuration values can be found [here](./examples/minikube/values.yaml).**

| Parameter | Description | Default |
| ----------|-------------|---------|
| `registry` | Docker images registry to use | `registry.hub.docker.com` |
| `imagePullPolicy` | Kubernetes [Image Pull Policy](https://kubernetes.io/docs/concepts/containers/images/#updating-images) | `IfNotPresent` |
| `imagePullSecrets`         | Configuration for [imagePullSecrets](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-pod-that-uses-your-secret) so that you can use a private registry for your image | `[]` |
| `ingress.enabled`         | Enable / Disable Ingress Controller | `false` |
| `ingress.className`         | Ingress class name (`spec.ingressClassName`) of the Traefik ingress controller | `traefik` |
| `ingress.traefik.middlewares.enabled`         | Create the chart Traefik `Middleware` resources and attach them to the ingresses (see [Prerequisites](#prerequisites)) | `true` |
| `ingress.traefik.entrypoints`         | Traefik entrypoints of the ingress routers (annotation `traefik.ingress.kubernetes.io/router.entrypoints`), e.g. `websecure`. All entrypoints when empty | `""` |
| `ingress.traefik.extraMiddlewares`         | Additional Traefik middlewares appended to every ingress router, e.g. security headers. Format: `<namespace>-<name>@kubernetescrd` | `[]` |
| `ingress.annotations`         | Configurable [annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) applied to all ingresses. Keys defined here override the ones generated from `ingress.traefik.*`  | `{}` |
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

Ingresses are served by Traefik, installed with the official [Traefik Helm chart](https://github.com/traefik/traefik-helm-chart) using [traefik-values.yaml](./examples/minikube/traefik-values.yaml) (default ingress class, `3600s` read timeout, strict prefix matching, `hostPort` 80). The minikube `ingress` addon (ingress-nginx) must be disabled.

```
minikube addons disable ingress
cd examples/minikube
make install
minikube tunnel
```

`make install` first runs the `configure` target, which enables the storage addons and installs Traefik:

```
helm repo add traefik https://traefik.github.io/charts --force-update
helm upgrade --install traefik traefik/traefik -n traefik --create-namespace -f traefik-values.yaml --wait
```

The UI is then available on http://127.0.0.1.sslip.io/ui.

Note that if `helm` or `kubectl` timeouts occur, you may consider creating a minikube VM with more CPU cores or memory allocated.
