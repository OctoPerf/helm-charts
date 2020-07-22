# Kraken Helm Chart

## Overview

This chart launches the whole **Kraken** stack inside your Kubernetes Cluster. It includes the following components:

- **Backend**: the backend server which serve Kraken REST API,
- **Frontends**: the Web UIs which consumes the REST API exposed by the backends,
- **Documentation**: static web documentation served by a NGinx server,
- **Grafana**: the analytics platform that display load testing dashboards,
- **InfluxDB**: the timeseries database that stores the test result data,
- **KeyCloak**: the identity and access management solution that handles Kraken users,
- **Postgres**: the database used by both Grafana and KeyCloak.

For a more comprehensive understanding, see [the Kraken repository](https://github.com/OctoPerf/kraken#run-the-application-from-the-source-code).

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

### Post Installation Steps

TODO update kraken-admin pwd

## Versions

| Helm Chart Version | Kraken Version |
| ------ | ------ |
| 3.0.0-beta | 3.0.0-beta |
| 3.0.0-rc1 | 3.0.0-rc1 |
| 1.1.1 | 2.1.1-beta |
| 1.1.0 | 2.1.0-beta |
| 1.0.0 -> 1.0.2 | 2.0.0-rc1 |

## Configuration

The default [configuration file](https://github.com/OctoPerf/helm-charts/blob/master/kraken/values.yaml) is commented. Check it out to see what configuration can be overridden.  

### Persistence Configuration

TODO

### Ingress Configuration

TODO

### Keycloak Configuration

TODO

#### Client IDs and Secrets

TODO

#### SMTP Settings

TODO

#### Google Recaptcha

TODO
