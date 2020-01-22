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

## Versions

| Helm Chart Version | Kraken Version |
| ------ | ------ |
| 1.0.0 | 2.0.0 |

## Configuration

The configuration is splitted in `4` big sections defined by the prefix being used:

- **No prefix**: global configuration settings such as Docker registry,
- **rbac.** prefix: [RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) configuration settings,
- **documentation.** prefix: documentation configuration settings.
- **backend.** prefix: backends configuration settings,
- **frontend.** prefix: frontends configuration settings

| Parameter | Description | Default |
| ----------|-------------|---------|
| TODO | TODO | TODO |

## Local development

### Kind

TODO