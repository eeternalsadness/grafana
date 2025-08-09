#!/bin/bash

set -eo pipefail

source "$(dirname $0)/common.sh"

terraform_role="terraform-grafana"
vault_grafana_auth_secret_path="grafana/users/admin"

vault_login "$terraform_role"
grafana_auth "$vault_grafana_auth_secret_path"

terraform init -backend-config="$(dirname $0)/../envs/${env}/.config/backend.conf" -reconfigure
terraform apply -var-file="$(dirname $0)/../envs/${env}/.config/terraform.tfvars" "$@"
