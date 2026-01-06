{{- range .Alerts }}
{{- if eq (.Status | toUpper) "RESOLVED" }}
💚 <b>RESOLVED: {{ .Annotations.summary }}</b>
{{- else if eq .Labels.severity "critical" }}
💔 <b>{{ .Annotations.summary }}</b>
{{- else if eq .Labels.severity "warning" }}
⚠️ <b>{{ .Annotations.summary }}</b>
{{- end }}
{{ .Annotations.description }}

{{ if gt (len .SilenceURL) 0 }}<a href="{{ .SilenceURL }}">Silence</a>  |  {{ end }}
{{- if gt (len .DashboardURL) 0 }}<a href="{{ .DashboardURL }}">Dashboard</a>  |  {{ end }}
{{- if gt (len .PanelURL) 0 }}<a href="{{ .PanelURL }}">Panel</a> {{- end -}}
{{- end }}
