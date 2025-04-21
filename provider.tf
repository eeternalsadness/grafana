terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "3.14.1"
    }
  }
}

provider "grafana" {
  url  = var.grafana-url
  auth = var.grafana-basic-auth-credentials
}
