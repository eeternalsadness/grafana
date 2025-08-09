locals {
  mute-timings = merge(
    [
      for file_path in fileset(path.module, "../../${var.mute-timings-config-dir}/*.yaml") :
      try(yamldecode(file("${path.module}/${file_path}")), {})
    ]...
  )
}

resource "grafana_mute_timing" "mute-timing" {
  for_each = local.mute-timings

  # required
  name = each.value.name

  # optional
  org_id             = var.org-id
  disable_provenance = true

  dynamic "intervals" {
    for_each = try(each.value.intervals, null) == null ? [] : each.value.intervals

    content {
      # optional
      weekdays      = try(intervals.value.weekdays, [])
      days_of_month = try(intervals.value.days_of_month, [])
      months        = try(intervals.value.months, [])
      years         = try(intervals.value.years, [])
      location      = try(intervals.value.location, "Asia/Bangkok")

      dynamic "times" {
        for_each = try(intervals.value.times, null) == null ? [] : intervals.value.times

        content {
          # required
          start = times.value.start
          end   = times.value.end
        }
      }
    }
  }
}

