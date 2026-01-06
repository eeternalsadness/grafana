{{ if gt (len .Alerts.Firing) 0 }}
  :fire: {{ len .Alerts.Firing }} alert(s) firing
{{ end }}
{{ if gt (len .Alerts.Resolved) 0 }}
  :white_check_mark: {{ len .Alerts.Resolved }} alert(s) resolved
{{ end }}
