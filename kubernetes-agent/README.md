# OctoPerf Kubernetes Agent

This functionality is in beta status and may be changed or removed completely in a future release. OctoPerf will take a best effort approach to fix any issues, but beta features are not subject to the support SLA of official GA features.

## Overview

This chart launches the [Kubernetes On-Premise Agent](https://hub.docker.com/r/octoperf/kubernetes-agent).

## Prerequisites

This agent is compatible with OctoPerf Enterprise-Edition `>= 12.11.0`.

The agent requires access to the following Kubernetes APIs:
- pods/log,
- pods/exec,
- pods (get, watch, list, create, delete).

Run an agent on every node you would like to use for running JMeter pods. An agent will only schedule JMeter pods on the same node as where it's running.

## Installation

* Add the octoperf helm charts repo:

  ```
  helm repo add octoperf https://helm.octoperf.com
  ```
 
* Install it:

  ```
  helm install --name kubernetes-agent octoperf/kubernetes-agent
  ```

## Image Parameters

| Name                       | Description                                                                                                                                                                         | Value                  | Mandatory |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------- | ------ |
| `token` | encrypted authentication token provided by the OctoPerf server to authenticate the agent. | From [Generated Agent Command-Line](https://api.octoperf.com/doc/on-premise-agent/provider-type/on-premise/#start-an-agent) | **yes** |
| `serverUrl` | OctoPerf Server Url (Example: https://api.octoperf.com when using our saas platform)                                                              | `https://api.octoperf.com` | no (unless using enterprise-edition) |
| `image.registry`           | Image registry                                                                                                                     | `docker.io`            | no |
| `image.repository`         | Image repository                                                                                                                   | `octoperf/kubernetes-agent` | no |
| `image.tag`                | Image tag (immutable tags are recommended)                                                                                         | `14.5.2` | no |
| `image.digest`             | Image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag                                    | `""`                   | no |
| `image.pullPolicy`         | Image pull policy                                                                                                                  | `Always`         | no |
| `image.pullSecrets`        | Specify docker-registry secret names as an array                                                                                   | `[]`                   | no |
| `image.debug`              | Specify if debug logs should be enabled                                                                                            | `false`                | no |
| `namespace` | The Kubernetes Namespace in which pods are created | `octoperf` | no |

For more advanced settings, see `values.yaml`.

## Compatibility

This chart is tested with the latest supported versions. The currently tested versions are:

| 14.x.x|
| ------|
| 14.5.2|
| 14.5.1|
| 14.5.0|
| 14.4.1|
| 14.4.0|
| 14.1.1|
| 14.1.0|
| 14.0.0|

`14.4.x` or higher is only compatible with OctoPerf Enterprise Edition `14.4.0` or higher.

| 13.x.x|
| ------|
| 13.2.0|
| 13.1.0|
| 13.0.1|
| 13.0.0|

| 12.x.x|
| ------|
| 12.12.0|
