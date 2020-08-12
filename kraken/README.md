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
| 3.0.1 | 3.0.1-beta |
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

### Node Tags

All nodes with the label `com.octoperf/hostId=some-id` are usable to start pods to execute tasks.
As load tests can put a strain on the server hosting the injectors, you may want to avoid using all the nodes of your cluster as injectors (especially the ones hosting the Kraken servers). 

By default, the Kraken backend tags all nodes of the cluster on startup. You can disable this behavior by setting the following configuration:

```yaml
backend:
  k8s:
    patchHosts: false
```

### Node Affinity

Kraken is not HA ready [yet](https://github.com/OctoPerf/kraken/issues/92).

The backend server can currently only on be deployed on a single node. By default, the node must have the label `com.octoperf/node-name=kraken-1`.

You can either:
 
* Attach a label to a node with the command `kubectl label nodes <node-name> <label-key>=<label-value>`,
* Update the Kraken helm chart configuration to set a different [node affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity):

```yaml
backend:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: kubernetes.io/hostname
                operator: In
                values:
                  - my-node
```

This configuration can be applied to:

* `backend`,
* `frontend.administration`,
* `frontend.gatling`,
* `documentation`,
* `grafana`,
* `influxdb`,
* `postgres`,
* `keycloak`.

### Persistence Configuration

The persistence configuration allows you to set:

* The [access mode](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes),
* The allocated size,
* The [storage class](https://kubernetes.io/docs/concepts/storage/storage-classes/) (Here using [Rancher local path provisioner](https://github.com/rancher/local-path-provisioner)).

```yaml
backend:
  persistence:
    accessMode: ReadWriteOnce
    size: 8Gi
    storageClass: lcoal-path
    # existingClaim: backend-data
```

You can also tell the chart to use an existing persistent volume claim (`existingClaim: backend-data`). 
All other settings are ignored in this case.

This configuration can be applied to:

* `backend`,
* `grafana`,
* `influxdb`,
* `postgres`.

### Ingress Configuration

The global host configuration allows you to specify the hostname opf your kubernetes cluster:

```yaml
host:
  name: mydomain.com
```

The global [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) configuration allows you to:

* Completely disable all Ingress rules (`enabled: false`),
* Set global annotations.

Here is the default configuration:

```yaml
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "12h"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
```

You can also configure annotations for specific containers:

* `backend`,
* `frontend.administration`,
* `frontend.gatling`,
* `documentation`,
* `grafana`,
* `influxdb`,
* `keycloak`.

For example, set the following configuration to redirect `/` to `/doc`:

```yaml
documentation:
  ingress:
    annotations:
      nginx.ingress.kubernetes.io/server-snippet: |
        location = / {
           return 301 https://kraken.octoperf.com/doc/;
        }
```

#### HTTPS

To configure Kraken to use HTTPS, start by setting the following configurations:

```yaml
host:
  scheme: https

ingress:
  annotations:
    nginx.ingress.kubernetes.io/force-ssl-redirect:	"true"
```

These will set the URLs to `https://` and redirect all calls made to `http://` to HTTPS.

Then, specific Ingress configuration must be made for each container open to the outside world:

* `backend`,
* `frontend.administration`,
* `frontend.gatling`,
* `documentation`,
* `grafana`,
* `keycloak`.

For example with the backend container, assuming your cluster is accessible at _mydomain.com_ and you have [configured an SSL certificate issuer](https://cert-manager.io/docs/tutorials/acme/ingress/) named _letsencrypt-prod_:

```yaml
backend:
  ingress:
    annotations:
      kubernetes.io/tls-acme: "true"
      cert-manager.io/cluster-issuer: letsencrypt-prod
    tls:
      - hosts:
          - mydomain.com
        secretName: kraken-backend-tls
```

Note that the `secretName` must be unique to each service. The cert manager will create a secret containing the SSL certificate for each container.

### Keycloak Configuration

#### Client IDs and Secrets

The first you may want to configure with KeyCloak is the OAuth client secrets:

```yaml
keycloak:
    client:
      web:
        secret: ed5974bb-e711-4b8b-9315-xxxxxxxxxxxx
      api:
        secret: c1ab32c0-0ba7-4289-b6c9-xxxxxxxxxxxx
      container:
        secret: 6caa811c-5a41-4a53-aa5d-xxxxxxxxxxxx
```

These secrets are also used by the Kraken backend container to authenticate users. 
Keeping the default values is a security issue.

#### SMTP Settings

In case you want KeyCloak to be able to send mails (for example when a user wants to reset his password), you can activate it in the configuration:

```yaml
keycloak:
  config:
    mail:
      enabled: true
      password: pwd
      starttls: true/false
      auth: true/false
      port: 587
      host: smtp.gamil.com
      replyTo: test@mail.com
      from: test@mail.com
      fromDisplayName: Kraken
      ssl: null
      user: test@mail.com
```

#### Google reCAPTCHA

Finally, you can activate [Google reCAPTCHA](https://www.google.com/recaptcha) with the following configuration: 

```yaml
keycloak:
  config:
    recaptcha:
      enabled: true
      key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      secret: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

You need to create a [reCAPTCHA V2](https://developers.google.com/recaptcha/docs/display) as KeyCloak does not support V3.
