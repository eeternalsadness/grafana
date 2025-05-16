#!/bin/bash

set -e

echo "WARNING: make sure to export the following envs: GRAFANA_ADDR, GRAFANA_BASIC_AUTH"
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

# get config env
read -rp "Enter env to use [minikube]: " env
case "$env" in
"minikube") ;;
*)
  echo "Unrecognized input: '${env}'. Input must be 'minikube'."
  exit 1
  ;;
esac

export GRAFANA_AUTH="$(vault kv get -mount=kvv2 -field=username grafana):$(vault kv get -mount=kvv2 -field=password grafana)"

python3 scripts/main.py "$generate_config_files" "$env"
