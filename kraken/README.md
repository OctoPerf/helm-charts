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

For more information, see [the Kraken repository](https://github.com/OctoPerf/kraken#run-the-application-from-the-source-code).

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

The Kraken administrator account has a default password and email. After installing the Kraken Helm chart:

* Connect to the administration application (http://your-cluster-hostname/administration) as `kraken-admin`/`kraken`,
* Access your account from the upper rihgt menu > _My Account_,
* Update the email address and password.

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

### License Setup

Contact [sales@octoperf.com](mailto:sales@octoperf.com) to get a multi-hosts license for Kraken Kubernetes.

```yaml
backend:
  licenseFile: |
    eyJraWQiOiJrcm.yourLicenseKeyHere.IiyFgU67Zbg
``` 

You can display logs for the Kraken backend container to check for the license capacity:

```sh
> kubectl logs kraken-backend-94c44fc48-ccr8x -n octoperf
HOME=/home/kraken
JAVA_OPTS=-Xmx256m
[...]
2020-01-23 18:11:42.423  INFO 8 --- [           main] com.kraken.u                             : Your license allows you to run tasks on 10 host(s)
[...]
2020-01-23 18:11:43.574  INFO 8 --- [           main] com.kraken.Application                   : Started Application in 5.137 seconds (JVM running for 5.675)
```

### Node Affinity

TODO

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
