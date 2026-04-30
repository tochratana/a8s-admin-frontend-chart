{{/*
Expand the name of the chart.
*/}}
{{- define "a8s-admin-frontend-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "a8s-admin-frontend-chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "a8s-admin-frontend-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "a8s-admin-frontend-chart.labels" -}}
helm.sh/chart: {{ include "a8s-admin-frontend-chart.chart" . }}
{{ include "a8s-admin-frontend-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "a8s-admin-frontend-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "a8s-admin-frontend-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "a8s-admin-frontend-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "a8s-admin-frontend-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Docker registry pull secret used by the pod.
*/}}
{{- define "a8s-admin-frontend-chart.registrySecretName" -}}
{{- default "registry-secret" .Values.registrySecret.name -}}
{{- end }}

{{/*
Generate dockerconfigjson data for a Harbor image pull secret.
*/}}
{{- define "a8s-admin-frontend-chart.registryDockerConfigJson" -}}
{{- if .Values.registrySecret.dockerconfigjson -}}
{{- .Values.registrySecret.dockerconfigjson | b64enc -}}
{{- else -}}
{{- $server := required "registrySecret.server is required when registrySecret.create=true" .Values.registrySecret.server -}}
{{- $username := required "registrySecret.username is required when registrySecret.create=true" .Values.registrySecret.username -}}
{{- $password := required "registrySecret.password is required when registrySecret.create=true" .Values.registrySecret.password -}}
{{- $email := default "" .Values.registrySecret.email -}}
{{- $auth := printf "%s:%s" $username $password | b64enc -}}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}}" $server $username $password $email $auth | b64enc -}}
{{- end -}}
{{- end }}
