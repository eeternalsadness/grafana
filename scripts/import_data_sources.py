import yaml
from common import (
    get_grafana_data,
    create_dir,
    get_org_id,
    get_tf_state,
    import_tf_resource,
    to_kebab_case,
)

base_path = "data-sources"
terraform_base_resource = "grafana_data_source.data-source"
org_id = get_org_id()


def import_data_sources(
    config_path, generate_config_files=True, import_to_terraform=True
):
    print("Importing Grafana data sources")

    # create config folder if not exist
    create_dir(f"{config_path}/{base_path}")

    # populate data
    data_source_dict = get_data_sources()

    tf_state = get_tf_state()
    for data_source in data_source_dict:
        uid = data_source_dict[data_source]["uid"]
        # del data_source_dict[data_source]["uid"]

        if generate_config_files:
            write_to_config_files(config_path, data_source, data_source_dict)

        # import to terraform
        if import_to_terraform:
            tf_data_source_resource = f'{terraform_base_resource}["{data_source}"]'
            if tf_data_source_resource not in tf_state:
                import_tf_resource(tf_data_source_resource, f"{org_id}:{uid}")


def get_data_sources():
    data_source_dict = {}
    data = get_grafana_data("/api/datasources")
    for data_source_data in data:
        data_source = get_grafana_data(
            f"/api/datasources/uid/{data_source_data['uid']}"
        )

        name = to_kebab_case(data_source_data["name"])
        data_source_dict[name] = {
            "name": data_source["name"],
            "type": data_source["type"],
            "access_mode": data_source["access"],
            "basic_auth_enabled": data_source["basicAuth"],
            "is_default": data_source["isDefault"],
            "url": data_source["url"],
            "uid": data_source["uid"],
        }

        if "httpHeaders" in data_source and data_source["httpHeaders"]:
            data_source_dict[name]["http_headers"] = data_source["httpHeaders"]
        if "basicAuthUser" in data_source and data_source["basicAuthUser"]:
            data_source_dict[name]["basic_auth_username"] = data_source["basicAuthUser"]
        if "database" in data_source and data_source["database"]:
            data_source_dict[name]["database_name"] = data_source["database"]
        if "jsonData" in data_source and data_source["jsonData"]:
            data_source_dict[name]["json_data"] = data_source["jsonData"]
        if "user" in data_source and data_source["user"]:
            data_source_dict[name]["username"] = data_source["user"]

    return data_source_dict


def write_to_config_files(config_path, data_source_name, data_source_dict):
    # write to config file
    file_path = f"{config_path}/{base_path}/{data_source_name}.yaml"
    with open(file_path, "w") as file:
        print(f"Writing to '{file_path}'")
        yaml.dump(
            {data_source_name: data_source_dict[data_source_name]},
            file,
            sort_keys=False,
            width=float("inf"),
        )
