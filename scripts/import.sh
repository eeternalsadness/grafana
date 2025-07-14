#!/bin/bash

set -eo pipefail

source "$(dirname $0)/common.sh"

terraform_role="terraform-grafana"

vault_login "$terraform_role"

read -rp "Generate config files? [y/n]: " generate_config_files
case "$generate_config_files" in
"y") ;;
"n") ;;
*)
  echo "Unrecognized input: '${generate_config_files}'. Input must be 'y' (generate config files) or 'n' (don't generate config files)"
  exit 1
  ;;
esac

read -rp "Import resources into Terraform? [y/n]: " import_resources
case "$import_resources" in
"y") ;;
"n") ;;
*)
  echo "Unrecognized input: '${import_resources}'. Input must be 'y' (generate config files) or 'n' (don't generate config files)"
  exit 1
  ;;
esac

python3 scripts/main.py "$generate_config_files" "$import_resources" "$env"
