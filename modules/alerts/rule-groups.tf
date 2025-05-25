locals {
  rule-groups = merge(
    [
      for file_path in fileset(path.module, "../../${var.rule-groups-config-dir}/**/*.yaml") : try({
        "${basename(dirname(file_path))}/${trimsuffix(basename(file_path), ".yaml")}" = yamldecode(file("${path.module}/${file_path}")).groups[0]
      }, {})
    ]...
  )

  conversion_to_seconds = {
    "w" = 604800
    "d" = 86400
    "h" = 3600
    "m" = 60
    "s" = 1
  }
}

resource "grafana_rule_group" "rule-group" {
  for_each = local.rule-groups

  # required
  name       = each.value.name
  folder_uid = var.folder-uids[each.value.folder]
  # NOTE: take the number part & multiply by the value in seconds of the unit
  interval_seconds = tonumber(substr(each.value.interval, 0, length(each.value.interval) - 1)) * local.conversion_to_seconds[substr(each.value.interval, -1, 1)]

  # optional
  org_id             = var.org-id
  disable_provenance = false

  # required
  dynamic "rule" {
    for_each = each.value.rules

    content {
      # required
      name      = rule.value.title
      condition = rule.value.condition

      # optional
      annotations    = try(rule.value.annotations, null)
      exec_err_state = try(rule.value.execErrState, null)
      for            = try(rule.value.for, null)
      is_paused      = try(rule.value.isPaused, null)
      labels         = try(rule.value.labels, null)
      no_data_state  = try(rule.value.noDataState, null)

      # required
      dynamic "data" {
        for_each = rule.value.data

        content {
          # required
          model          = jsonencode(data.value.model)
          datasource_uid = data.value.datasourceUid
          ref_id         = data.value.refId
          relative_time_range {
            from = try(data.value.relativeTimeRange.from, 0)
            to   = try(data.value.relativeTimeRange.to, 0)
          }

          # optional
          query_type = try(data.value.queryType, null)
        }
      }
    }
  }
}
