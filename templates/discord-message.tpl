{{- range .Alerts }}
=======================
{{- if eq (.Status | toUpper) "RESOLVED" }}
:green_circle: **RESOLVED: {{ .Annotations.summary }}**
{{- else if eq .Labels.severity "critical" }}
:red_circle: **{{ .Annotations.summary }}**
{{- else if eq .Labels.severity "warning" }}
:yellow_circle: **{{ .Annotations.summary }}**
{{- end }}
{{ .Annotations.description }}
{{- end }}
