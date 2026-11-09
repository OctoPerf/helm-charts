{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Name of the resources: the release name, so that each agent gets its own release.
*/}}
{{- define "fullname" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Name of the ServiceAccount used by the agent.
*/}}
{{- define "serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
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
