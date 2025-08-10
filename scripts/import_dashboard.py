import json
import yaml
from common import (
    get_grafana_data,
    get_org_id,
    create_dir,
    get_tf_state,
    import_tf_resource,
    to_kebab_case,
)

base_path = "dashboards"
terraform_base_dashboard_resource = "grafana_dashboard.dashboard"
terraform_base_dashboard_perm_resource = (
    "grafana_dashboard_permission.dashboard-permission"
)
org_id = get_org_id()


def import_dashboards(config_path, generate_config_files=True, import_resources=True):
    print("Importing Grafana dashboards")

    # Extract env from config_path (format: envs/{env})
    env = config_path.split("/")[1]

    # create config folder if not exist
    # create_dir(f"{config_path}/{base_path}")

    # populate data
    dashboard_dict = get_dashboards()

    tf_state = get_tf_state()
    for dashboard in dashboard_dict:
        uid = dashboard_dict[dashboard]["dashboard"]["uid"]

        if generate_config_files:
            write_to_config_files(config_path, dashboard, dashboard_dict)

        if import_resources:
            # import dashboards to terraform
            tf_dashboard_resource = (
                f'{terraform_base_dashboard_resource}["{dashboard}"]'
            )
            if tf_dashboard_resource not in tf_state:
                import_tf_resource(tf_dashboard_resource,
                                   f"{org_id}:{uid}", env)

            # import dashboard permissions to terraform
            tf_dashboard_perm_resource = (
                f'{terraform_base_dashboard_perm_resource}["{dashboard}"]'
            )
            if tf_dashboard_perm_resource not in tf_state:
                import_tf_resource(tf_dashboard_perm_resource, f"{
                                   org_id}:{uid}", env)


def get_dashboards():
    dashboard_dict = {}
    data = get_grafana_data("/api/search?type=dash-db")
    for dashboard_metadata in data:
        title = to_kebab_case(dashboard_metadata["title"])
        uid = dashboard_metadata["uid"]
        dashboard_data = get_grafana_data(f"/api/dashboards/uid/{uid}")
        folder_title = dashboard_data["meta"]["folderTitle"]
        dashboard_dict[f"{folder_title}/{title}"] = {
            "meta": {
                "title": title,
                "folder": folder_title,
                "permissions": get_dashboard_permissions(uid),
            },
            "dashboard": dashboard_data["dashboard"],
        }

    return dashboard_dict


def get_dashboard_permissions(uid):
    dashboard_perms = []
    data = get_grafana_data(f"/api/dashboards/uid/{uid}/permissions")
    for perm in data:
        perm_dict = {"permission": perm["permissionName"]}
        user = perm["userLogin"]
        if user:
            perm_dict["user"] = user
        else:
            perm_dict["role"] = perm["role"]
        dashboard_perms.append(perm_dict)

    return dashboard_perms


def write_to_config_files(config_path, dashboard_name, dashboard_dict):
    # create folder if not exists
    folder_name = dashboard_dict[dashboard_name]["meta"]["folder"]
    # del dashboard_dict[dashboard_name]["meta"]["folder"]
    create_dir(f"{config_path}/{base_path}/{folder_name}")

    # write metadata to yaml file
    dashboard_title = dashboard_dict[dashboard_name]["meta"]["title"]
    yaml_file_path = f"{
        config_path}/{base_path}/{folder_name}/{dashboard_title}.yaml"
    with open(yaml_file_path, "w") as file:
        print(f"Writing to '{yaml_file_path}'")
        yaml.dump(
            {
                dashboard_title: {
                    "permissions": dashboard_dict[dashboard_name]["meta"]["permissions"]
                }
            },
            file,
            sort_keys=False,
            width=float("inf"),
        )

    # write dashboard config to json file
    json_base_path = f"{config_path}/{base_path}/{folder_name}/json"
    create_dir(json_base_path)
    json_file_path = f"{json_base_path}/{dashboard_title}.json"
    with open(json_file_path, "w") as file:
        print(f"Writing to '{json_file_path}'")
        json.dump(
            dashboard_dict[dashboard_name]["dashboard"],
            file,
            sort_keys=False,
            indent=2,
        )
