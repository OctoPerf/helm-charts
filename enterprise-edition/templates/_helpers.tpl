{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Storage class of the backend data volume: backend.persistentVolume.storageClass, else storageClassName,
the key values.yaml documented up to 18.0.0 and installs may still set.
*/}}
{{- define "backend.storageClass" -}}
{{- $volume := .Values.backend.persistentVolume -}}
{{- $volume.storageClass | default $volume.storageClassName | default "" -}}
{{- end -}}

{{/*
Ingress annotations: Traefik router entrypoints and middlewares, merged with .Values.ingress.annotations.
Chart middlewares are referenced as <namespace>-<name>-<middleware>@kubernetescrd, in the given order,
followed by .Values.ingress.traefik.extraMiddlewares. Keys set in .Values.ingress.annotations take precedence.
An optional "priority" sets the Traefik router priority (by default, Traefik prioritizes the longest rule).
Usage: {{ include "ingress.annotations" (dict "context" . "middlewares" (list "compress")) }}
*/}}
{{- define "ingress.annotations" -}}
{{- $ctx := .context -}}
{{- $traefik := $ctx.Values.ingress.traefik | default dict -}}
{{- $middlewares := list -}}
{{- if dig "middlewares" "enabled" false $traefik -}}
{{- range .middlewares -}}
{{- $middlewares = append $middlewares (printf "%s-%s-%s@kubernetescrd" $ctx.Release.Namespace (include "name" $ctx) .) -}}
{{- end -}}
{{- end -}}
{{- $middlewares = concat $middlewares ($traefik.extraMiddlewares | default list) -}}
{{- $annotations := dict -}}
{{- with .priority -}}
{{- $_ := set $annotations "traefik.ingress.kubernetes.io/router.priority" (toString .) -}}
{{- end -}}
{{- with $traefik.entrypoints -}}
{{- $_ := set $annotations "traefik.ingress.kubernetes.io/router.entrypoints" . -}}
{{- end -}}
{{- with $middlewares -}}
{{- $_ := set $annotations "traefik.ingress.kubernetes.io/router.middlewares" (join "," .) -}}
{{- end -}}
{{- $annotations = mergeOverwrite $annotations ($ctx.Values.ingress.annotations | default dict) -}}
{{- with $annotations -}}
annotations:
{{- toYaml . | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Labels of every resource: the Kubernetes recommended labels, then .Values.commonLabels (e.g. env: production).
Never in a selector: changing them must not break an upgrade.
*/}}
{{- define "labels" -}}
app.kubernetes.io/name: {{ include "name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}
