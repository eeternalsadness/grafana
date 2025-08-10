import yaml
from common import (
    get_grafana_data,
    create_dir,
)

base_path = "organization/users"


def import_users(config_path, generate_config_files=True):
    print("Importing Grafana users")

    if generate_config_files:
        write_to_config_files(config_path)

    # NOTE: the terraform resource for users requires the password to be passed in so users must be imported through data instead


def get_users():
    user_dict = {}
    data = get_grafana_data("/api/org/users")
    for user_data in data:
        user_dict[user_data["login"]] = {
            "email": user_data["email"],
            "role": user_data["role"],
        }

    return user_dict


def write_to_config_files(config_path):
    # create config folder if not exist
    create_dir(f"{config_path}/{base_path}")

    # populate data
    user_dict = get_users()

    # write user data to config file
    file_path = f"{config_path}/{base_path}/users.yaml"
    with open(file_path, "w") as file:
        print(f"Writing to '{file_path}'")
        yaml.dump(user_dict, file, sort_keys=False, width=float("inf"))
