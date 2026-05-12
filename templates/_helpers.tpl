{{/*
Expand the name of the chart.
*/}}
{{- define "openclaw-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Resolve the namespace for the Agent CR.
Prefers top-level .Values.namespace, then legacy .Values.agent.namespace,
and finally falls back to the Helm release namespace.
*/}}
{{- define "openclaw-agent.namespace" -}}
{{- $ns := "" -}}
{{- if .Values.namespace -}}
{{- $ns = .Values.namespace -}}
{{- else if and .Values.agent .Values.agent.namespace -}}
{{- $ns = .Values.agent.namespace -}}
{{- else -}}
{{- $ns = .Release.Namespace -}}
{{- end -}}
{{- $ns -}}
{{- end }}

{{/*
Resolve the Agent CR name.
When .Values.agent.name is empty, defaults to 'openclaw-<namespace>'.
*/}}
{{- define "openclaw-agent.agentName" -}}
{{- if and .Values.agent .Values.agent.name -}}
{{- .Values.agent.name -}}
{{- else -}}
{{- printf "openclaw-%s" (include "openclaw-agent.namespace" .) -}}
{{- end -}}
{{- end }}

{{/*
Common labels
*/}}
{{- define "openclaw-agent.labels" -}}
app.kubernetes.io/name: {{ include "openclaw-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end }}
