#!/usr/bin/env bash

set -e

echo "WARNING: make sure to run this inside the 'grafana' folder"
echo "WARNING: make sure you set up the necessary Terraform variables through .tfvars files before running this script!"
echo "WARNING: make sure the 'tfvars' files are set up in this structure:"
echo """
grafana/
├── ...
└── vars
    ├── dev
    │   └── terraform.auto.tfvars
    └── prod
        └── terraform.auto.tfvars
"""
echo "WARNING: make sure you comment out unnecessary imports in 'scripts/main.py' before running this script!"

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
read -rp "Enter env to use [dev/prod]: " env
case "$env" in
"dev") ;;
"prod") ;;
*)
  echo "Unrecognized input: '${env}'. Input must be 'dev' or 'prod'"
  exit 1
  ;;
esac

# symlink tfvars file
echo "Symlinking tfvars file..."
ln -sf "${PWD}/vars/${env}/terraform.auto.tfvars" "${PWD}/terraform.auto.tfvars"

python3 scripts/main.py "$generate_config_files" "$env"
