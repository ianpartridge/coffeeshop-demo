{{/* vim: set filetype=mustache: */}}

{{/*
Create fully qualified app names.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "coffeeshopService.fullname" -}}
{{- printf "%s-coffeeshop-service" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "baristaHttp.fullname" -}}
{{- printf "%s-barista-http" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "baristaKafka.fullname" -}}
{{- printf "%s-barista-kafka" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "loadBalancer.fullname" -}}
{{- printf "%s-loadbalancer" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "coffeeshopChart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "coffeeshopChart.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
helm.sh/chart: {{ include "coffeeshopChart.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
