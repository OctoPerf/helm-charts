# Kraken Helm Chart

## Overview

This chart launches the whole **Kraken** stack inside your Kubernetes Cluster. It includes the following components:

- **InfluxDB**: the timeseries database used to store the test results data,
- **Backends**: the backend servers which serve Kraken REST API,
- **Frontends**: the Web UIs which consumes the REST API exposed by the backends,
- **Documentation**: static web documentation served by a NGinx server.

For a more comprehensive understanding, see [the Kraken repository](https://github.com/OctoPerf/kraken#run-the-application-from-the-source-code).

## Dependencies

Kraken helm chart depends on:
 
 * [InfluxDb](https://github.com/elastic/helm-charts/tree/master/influxdb) helm chart,
 * [Grafana](https://github.com/elastic/helm-charts/tree/master/grafana) helm chart.
 
To configure InfluxDB through your own `values.yaml`, prefix the configuration with `influxdb.`; To configure Grafana through your own `values.yaml`, prefix the configuration with `grafana.`. 

## Installation

* Add the octoperf helm charts repo:

  ```
  helm repo add octoperf https://helm.octoperf.com
  ```
 
* Install it:

  ```
  helm install --namespace octoperf --name kraken octoperf/kraken --version 1.0.0
  ```

Please refer to [Kraken's documentation for a complete installation guide](http://kraken.octoperf.com/install/kubernetes/).

## Versions

| Helm Chart Version | Kraken Version |
| ------ | ------ |
| 1.0.0 -> 1.0.3 | 2.0.0-rc1 |

## Configuration

[The configuration](https://github.com/OctoPerf/helm-charts/blob/master/kraken/values.yaml) is split in several big sections defined by the prefix being used:

- **No prefix**: global configuration settings such as Docker registry,
- **rbac.** prefix: [RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) configuration settings,
- **ingres.** prefix: [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) configuration settings,
- **documentation.** prefix: documentation configuration settings.
- **backend.** prefix: backends configuration settings,
- **frontend.** prefix: frontends configuration settings

| Parameter | Description | Default |
| ----------|-------------|---------|
| `rabc.create` | Create RBAC roles and role bindings | `true` |
| `ingress.create` | Create Ingress rules | `true` |
| `ingress.annotations` | Custom Ingress annotations | `{}}` |
| `documentation.image.repository` | Documentation image repository | `octoperf/kraken-documentation` |
| `documentation.image.tag` | Documentation image tag | Depends on the [Kraken helm chart version](#versions) |
| `documentation.image.pullPolicy` | Documentation image pull policy | `IfNotPresent` |
| `documentation.port` | Kubernetes port where Documentation service is exposed | `80` |
| `backend.licenseFile` | Kraken license file | `nil` The unlicensed version of Kraken allows you to execute tasks on only one Kubernetes Node |
| `backend.storage.image.repository` | Storage backend image repository | `octoperf/kraken-storage` |
| `backend.storage.image.tag` | Storage backend image tag | Depends on the [Kraken helm chart version](#versions) |
| `backend.storage.image.pullPolicy` | Storage backend image pull policy | `IfNotPresent` |
| `backend.storage.port` | Kubernetes port where Storage service is exposed | `8080` |
| `backend.storage.persistence.accessMode` | Storage backend data Persistent Volume access mode | `ReadWriteOnce` |
| `backend.storage.persistence.size` | Storage backend data Persistent Volume size | `8Gi` |
| `backend.storage.persistence.storageClass` | Storage backend data Persistent Volume Storage Class | `nil` |
| `backend.static.image.repository` | Static backend image repository | `octoperf/kraken-static` |
| `backend.static.image.tag` | Static backend image tag | Depends on the [Kraken helm chart version](#versions) |
| `backend.static.image.pullPolicy` | Static backend image pull policy | `IfNotPresent` |
| `backend.static.port` | Kubernetes port where Static service is exposed | `80` |
| `backend.analysis.image.repository` | Analysis backend image repository | `octoperf/kraken-analysis` |
| `backend.analysis.image.tag` | Analysis backend image tag | Depends on the [Kraken helm chart version](#versions) |
| `backend.analysis.image.pullPolicy` | Analysis backend image pull policy | `IfNotPresent` |
| `backend.analysis.port` | Kubernetes port where Analysis service is exposed | `8081` |
| `backend.runtime.image.repository` | Runtime backend image repository | `octoperf/kraken-ee-runtime-kubernetes` |
| `backend.runtime.image.tag` | Runtime backend image tag | Depends on the [Kraken helm chart version](#versions) |
| `backend.runtime.image.pullPolicy` | Runtime backend image pull policy | `IfNotPresent` |
| `backend.runtime.port` | Kubernetes port where Runtime service is exposed | `8082` |
| `backend.runtime.k8s.patchHosts` | Patch Kubernetes Nodes on startup to add the `com.kraken/hostId` label, making them [available to execute tasks](http://kraken.octoperf.com/administration/hosts-table/) | `true` |
| `frontend.administration.image.repository` | Administration frontend image repository | `octoperf/kraken-administration-ui` |
| `frontend.administration.image.tag` | Administration frontend image tag | Depends on the [Kraken helm chart version](#versions) |
| `frontend.administration.image.pullPolicy` | Administration frontend image pull policy | `IfNotPresent` |
| `frontend.administration.port` | Kubernetes port where Administration service is exposed | `80` |
| `frontend.gatling.image.repository` | Gatling frontend image repository | `octoperf/kraken-gatling-ui` |
| `frontend.gatling.image.tag` | Gatling frontend image tag | Depends on the [Kraken helm chart version](#versions) |
| `frontend.gatling.image.pullPolicy` | Gatling frontend image pull policy | `IfNotPresent` |
| `frontend.gatling.port` | Kubernetes port where Gatling service is exposed | `80` |
