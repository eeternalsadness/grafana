#!/bin/bash

set -eo pipefail

source "$(dirname $0)/common.sh"

terraform_role="terraform-grafana"
vault_grafana_auth_secret_path="grafana/users/admin"
pg_role="terraform_grafana"

vault_login "$terraform_role"
grafana_auth "$vault_grafana_auth_secret_path"
get_pg_creds "$pg_role"

terraform init -backend-config="$(dirname $0)/../envs/${env}/.config/backend.conf" -reconfigure
terraform apply -var-file="$(dirname $0)/../envs/${env}/.config/terraform.tfvars" "$@"
