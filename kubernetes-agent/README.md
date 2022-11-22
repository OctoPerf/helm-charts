# OctoPerf Kubernetes Agent

This functionality is in beta status and may be changed or removed completely in a future release. OctoPerf will take a best effort approach to fix any issues, but beta features are not subject to the support SLA of official GA features.

## Overview

This chart launches the [Kubernetes On-Premise Agent](https://hub.docker.com/r/octoperf/kubernetes-agent).

## Installation

* Add the octoperf helm charts repo:

  ```
  helm repo add octoperf https://helm.octoperf.com
  ```
 
* Install it:

  ```
  helm install --name octoperf-ee octoperf/kubernetes-agent
  ```

## Compatibility

This chart is tested with the latest supported versions. The currently tested versions are:

| 12.x.x|
| ------|
| 12.12.0|

### Image Parameters

| Name                       | Description                                                                                                                                                                         | Value                  |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------- |
| `image.registry`           | Image registry                                                                                                                                                                | `docker.io`            |
| `image.repository`         | Image repository                                                                                                                                                              | `octoperf/kubernetes-agent`        |
| `image.tag`                | Image tag (immutable tags are recommended)                                                                                                                                    | `12.12.0` |
| `image.digest`             | Image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag                                                                               | `""`                   |
| `image.pullPolicy`         | Image pull policy                                                                                                                                                             | `Always`         |
| `image.pullSecrets`        | Specify docker-registry secret names as an array                                                                                                                                    | `[]`                   |
| `image.debug`              | Specify if debug logs should be enabled                                                                                                                                             | `false`                |
| `serverUrl` | OctoPerf Server Url (Example: https://api.octoperf.com when using our saas platform) | `https://api.octoperf.com` |
| `token` | encrypted authentication token provided by the OctoPerf server to authenticate the agent. | |
| `namespace` | The Kubernetes Namespace in which pods are created | `octoperf` |

For more advanced settings, see `values.yaml`.