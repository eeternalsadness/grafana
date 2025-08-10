#!/usr/bin/env python3

import sys
import subprocess

from common import set_current_org
from import_mute_timings import import_mute_timings
from import_notification_policy import import_notification_policy
from import_organization import import_organization
from import_users import import_users
from import_dashboard import import_dashboards
from import_data_sources import import_data_sources
from import_message_templates import import_message_templates
from import_folders import import_folders
from import_rule_groups import import_rule_groups
from import_contact_points import import_contact_points


def main():
    generate_config_files = True
    match sys.argv[1]:
        case "y":
            generate_config_files = True
        case "n":
            generate_config_files = False
        case _:
            raise Exception(
                f"Unrecognized input: '{
                    sys.argv[1]}'. Input must be 'y' (generate config files) or 'n' (don't generate config files)"
            )

    import_resources = True
    match sys.argv[2]:
        case "y":
            import_resources = True
        case "n":
            import_resources = False
        case _:
            raise Exception(
                f"Unrecognized input: '{
                    sys.argv[1]}'. Input must be 'y' (import resources) or 'n' (don't import resources)"
            )

    # get config env
    env = sys.argv[3]
    config_path = f"envs/{env}"

    # run terraform init first
    command = [
        "terraform",
        "init",
        f"-backend-config=envs/{env}/.config/backend.conf",
        "-reconfigure",
    ]
    subprocess.run(
        command,
        text=True,
    )

    set_current_org(env)

    # import_organization(config_path, generate_config_files, import_resources)
    # import_folders(config_path, generate_config_files, import_resources)
    import_rule_groups(config_path, generate_config_files, import_resources)
    # import_contact_points(config_path, generate_config_files, import_resources)
    # import_message_templates(config_path, generate_config_files, import_resources)
    # import_notification_policy(config_path, generate_config_files, import_resources)
    # import_mute_timings(config_path, generate_config_files, import_resources)
    # import_data_sources(config_path, generate_config_files, import_resources)
    # import_users(config_path, generate_config_files)
    import_dashboards(config_path, generate_config_files, import_resources)


if __name__ == "__main__":
    main()
