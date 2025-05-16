terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "3.14.1"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "4.7.0"
    }
  }
}

provider "grafana" {
}

provider "vault" {
  max_lease_ttl_seconds = var.vault-max-lease-ttl-seconds
}
