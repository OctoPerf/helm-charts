# OctoPerf Kubernetes Agent

This functionality is in beta status and may be changed or removed completely in a future release. OctoPerf will take a best effort approach to fix any issues, but beta features are not subject to the support SLA of official GA features.

## Overview

This chart launches the [Kubernetes On-Premise Agent](https://hub.docker.com/r/octoperf/kubernetes-agent).

## Compatibility


This chart is tested with the latest supported versions. The currently tested versions are:

| 18.x.x|
| ------|
| 18.0.0|

Older versions are:

| 17.x.x|
| ------|
| 17.0.0|

| 16.x.x|
| ------|
| 16.2.3|
| 16.2.2|
| 16.2.1|
| 16.1.2|
| 16.1.1|
| 16.1.0|
| 16.0.0|

Our Saas platform requires a Kubernetes Agent >= 17.0.0.

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
| `image.tag`                | Image tag (immutable tags are recommended)                                                                                         | `18.0.0` | no |
| `image.digest`             | Image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag                                    | `""`                   | no |
| `image.pullPolicy`         | Image pull policy                                                                                                                  | `Always`         | no |
| `image.pullSecrets`        | Specify docker-registry secret names as an array                                                                                   | `[]`                   | no |
| `image.debug`              | Specify if debug logs should be enabled                                                                                            | `false`                | no |
| `namespace` | The Kubernetes Namespace in which pods are created | `octoperf` | no |

For more advanced settings, see `values.yaml`.

## Agent Configuration (`application.yml`)

The agent is a Spring Boot application. The `config` block of `values.yaml` is its `application.yml`: what you write there is what the agent reads.

### How it works

1. The chart renders `config` verbatim into a ConfigMap named `kubernetes-agent-config` (`<nameOverride>-config` when `nameOverride` is set), under the key `application.yml`.
2. The ConfigMap is mounted in the agent container at `/home/octoperf/config/application.yml`. Spring Boot loads `./config/application.yml` from the agent's working directory (`/home/octoperf`) at startup.
3. That file is merged key by key over the configuration built into the agent: a key you leave out keeps its built-in default.
4. The pod template carries a `checksum/config` annotation, so changing `config` and running `helm upgrade` restarts the agent with the new file.

A few things to know:

- **These settings apply to the pods the agent creates** (the JMeter load generators), not to the agent's own pod. The agent pod is configured by the other values of this chart (`securityContext`, `containerSecurityContext`, `tolerations`, `resources`…).
- **Keys can be written in kebab-case or camelCase**: `allow-privilege-escalation` and `allowPrivilegeEscalation` are the same key, so a snippet copied from a Kubernetes manifest works as is.
- **Environment variables win over the file.** The chart sets `OCTOPERF_KUBERNETES_NAMESPACE` to the release namespace, so `octoperf.kubernetes.namespace` cannot be changed through `config`. The same goes for any variable you add through `extraEnvVars`.
- **Helm merges maps but replaces lists.** In your own values file, give only the keys you change; a list (`tolerations`, `image-pull-secrets`, `capabilities.drop`…) must be given in full.

### Available settings

| Key under `config` | Default | Description |
| --- | --- | --- |
| `octoperf.container.resources.requests.memory-factor` | `2.5` | Memory request of a load generator container: the memory OctoPerf reserves for it (`MEMORY_REQUEST_MB`) times this factor. |
| `octoperf.container.resources.requests.cpu` | `""` | CPU request of a load generator container (e.g. `"1"`, `"500m"`). Empty means none. |
| `octoperf.container.resources.limits.memory-factor` | `2.5` | Memory limit of a load generator container: `MEMORY_REQUEST_MB` times this factor. |
| `octoperf.container.resources.limits.cpu` | `""` | CPU limit of a load generator container (e.g. `"2"`). Empty means none. When only the limit is set, Kubernetes uses it as the request too. |
| `octoperf.container.tolerations` | `[]` | Tolerations of the load generator pods. Each entry takes `key`, `operator`, `value`, `effect` and `seconds` (`tolerationSeconds`). |
| `octoperf.container.security-context` | `{}` | Container-level security context of the load generator containers. See below. |
| `octoperf.pod.spec.image-pull-secrets` | `[]` | Secrets used to pull the load generator images, e.g. `- name: my-registry-secret`. The secrets must exist in the namespace. |
| `octoperf.pod.spec.security-context` | `{}` | Pod-level security context of the load generator pods. See below. |

### Upgrading to 18.0.0

Starting with Kubernetes Agent **18.0.0**, the resources of the load generator containers moved from `octoperf.kubernetes.pod.resources` to `octoperf.container.resources`, next to `tolerations` and `security-context`, and the requests take a `cpu` too:

| Up to 17.x | From 18.0.0 |
| --- | --- |
| `octoperf.kubernetes.pod.resources.requests.memory-factor` | `octoperf.container.resources.requests.memory-factor` |
| — | `octoperf.container.resources.requests.cpu` |
| `octoperf.kubernetes.pod.resources.limits.memory-factor` | `octoperf.container.resources.limits.memory-factor` |
| `octoperf.kubernetes.pod.resources.limits.cpu` | `octoperf.container.resources.limits.cpu` |

When upgrading the agent to 18.0.0:

- Move any `octoperf.kubernetes.pod.resources.*` setting to `octoperf.container.resources`, including one set as an environment variable through `extraEnvVars` (such as `OCTOPERF_KUBERNETES_POD_RESOURCES_LIMITS_CPU`, now `OCTOPERF_CONTAINER_RESOURCES_LIMITS_CPU`): the agent ignores the old keys.
- The old `limits.cpu` set both the CPU request and the CPU limit; the new `limits.cpu` sets the limit only. With no `requests.cpu`, Kubernetes uses the limit as the request, so the load generators get the same CPU as before.
- The default memory factors go from `2` to `2.5`: with no setting, a load generator reserves 25% more memory, e.g. `400Mi` instead of `320Mi` for `MEMORY_REQUEST_MB=160`. To keep the previous sizing, set `memory-factor: 2` under `octoperf.container.resources.requests` and `octoperf.container.resources.limits`.

An agent older than 18.0.0 runs with this chart, but:

- it reads the load generator resources from `octoperf.kubernetes.pod.resources.*` only, and ignores `octoperf.container.resources`, including the `2.5` memory factors the chart's default `config` sets: it keeps its own default factor of `2` (and no CPU). To customize them on such an agent, write the old keys in `config`;
- it ignores both security contexts (`octoperf.container.security-context` and `octoperf.pod.spec.security-context`);
- it ignores the `effect` of the tolerations.

### Security context of the load generator pods

Both security contexts are **disabled by default**: left empty (`{}`), the pods are created exactly as before. `values.yaml` lists every available option in comments under each of them.

- `octoperf.container.security-context` is the [container `securityContext`](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#security-context-1), set on the load generator container.
- `octoperf.pod.spec.security-context` is the [pod `securityContext`](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#security-context), set on the load generator pod.

Both accept the full Kubernetes schema: what you would write under `securityContext` in a pod manifest can be written here.

The option lists in `values.yaml` are a reference, not a block to uncomment as a whole: give only the fields you need. The agent sends every field you write to Kubernetes, and the API server refuses a pod carrying some of them empty or out of context: `localhost-profile` with a `type` other than `Localhost`, `windows-options` on Linux nodes, or empty `se-linux-options`. The load generator pod is then never created.

#### Example: cluster refusing privilege escalation

A cluster enforcing a policy such as the Gatekeeper constraint `K8sPSPAllowPrivilegeEscalationContainer` refuses the load generator pods, and the agent logs:

```
psp-allow-privilege-escalation-container: Privilege escalation container is not allowed
```

Such a policy requires every container to declare `allowPrivilegeEscalation: false`:

```yaml
config:
  octoperf:
    container:
      security-context:
        allow-privilege-escalation: false
```

#### Example: restricted Pod Security Standard

A namespace labelled `pod-security.kubernetes.io/enforce: restricted` asks for more: no privilege escalation, every capability dropped, a non-root user and the `RuntimeDefault` seccomp profile. This configuration was checked against a running load test:

```yaml
config:
  octoperf:
    pod:
      spec:
        security-context:
          seccomp-profile:
            type: RuntimeDefault
    container:
      security-context:
        allow-privilege-escalation: false
        run-as-non-root: true
        run-as-user: 9001
        capabilities:
          drop:
            - ALL
```

**`run-as-user: 9001` is required as soon as the capabilities are dropped.** The load generator images start as `root` and switch to their `octoperf` user (uid and gid `9001`) with `gosu`, which needs the `SETUID` and `SETGID` capabilities. With `drop: [ALL]` and no `run-as-user`, the switch fails (`failed switching to "octoperf": operation not permitted`) and the load generator stops as soon as it starts. Run directly as `9001`, the image skips the switch. For the same reason, `run-as-non-root: true` alone is refused: the image's default user is `root`.

Keep `9001` for `run-as-user`, `run-as-group` and `fs-group`: the files of the load generator images belong to that user. Another uid, or `read-only-root-filesystem: true`, makes the load generator fail at startup.

To check what the agent sends to Kubernetes, look at a load generator pod while a test runs:

```
kubectl get pod <pod name> -n <namespace> -o jsonpath='{.spec.securityContext}{"\n"}{.spec.containers[0].securityContext}'
```

### Security context of the agent pod

A policy enforced on the agent's namespace applies to the agent pod as well. The agent pod is configured outside `config`, with two values written as a plain Kubernetes manifest (camelCase):

- `securityContext`: pod-level `fsGroup` and `runAsUser`, rendered when `securityContext.enabled` is `true`.
- `containerSecurityContext`: the [container `securityContext`](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#security-context-1) of the agent container, rendered verbatim when not empty. `values.yaml` lists its options in comments.

The agent image runs as the `octoperf` user (uid and gid `9001`), but declares it by name: with `runAsNonRoot: true`, Kubernetes cannot tell that user is not root and refuses to start the container unless `runAsUser` gives the uid.

For the Gatekeeper constraint above, or a `restricted` namespace, on both the agent and its load generators:

```yaml
containerSecurityContext:
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  runAsUser: 9001
  capabilities:
    drop:
      - ALL
  seccompProfile:
    type: RuntimeDefault

config:
  octoperf:
    pod:
      spec:
        security-context:
          seccomp-profile:
            type: RuntimeDefault
    container:
      security-context:
        allow-privilege-escalation: false
        run-as-non-root: true
        run-as-user: 9001
        capabilities:
          drop:
            - ALL
```
| 15.1.1|
| 15.1.0|
