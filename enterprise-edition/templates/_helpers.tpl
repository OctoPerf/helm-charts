{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
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
