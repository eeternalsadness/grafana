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

{{ if gt (len .SilenceURL) 0 }}[Silence]({{ .SilenceURL }})  |  {{ end }}
{{- if gt (len .DashboardURL) 0 }}[Dashboard]({{ .DashboardURL }})  |  {{ end }}
{{- if gt (len .PanelURL) 0 }}[Panel]({{ .PanelURL }}) {{- end -}}
{{- end }}
