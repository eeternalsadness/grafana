#!/bin/bash

set -e

echo "WARNING: make sure to export the following envs: GRAFANA_URL, GRAFANA_AUTH, VAULT_ADDR, VAULT_TOKEN"
echo "WARNING: make sure to comment out unnecessary imports in 'scripts/main.py' before running this script!"

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

# get config env
read -rp "Enter env to use [minikube, homelab]: " env
case "$env" in
"minikube") ;;
"homelab") ;;
*)
  echo "Unrecognized input: '${env}'. Input must be 'minikube'."
  exit 1
  ;;
esac

python3 scripts/main.py "$generate_config_files" "$import_resources" "$env"
