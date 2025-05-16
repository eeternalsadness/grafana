import yaml
from common import (
    get_grafana_data,
    create_dir,
    get_tf_state,
    import_tf_resource,
)

base_path = "organization"
terraform_base_resource = "grafana_organization.organization"


def import_organization(config_path, generate_config_files=True):
    print("Importing Grafana organization")

    # create config folder if not exist
    create_dir(f"{config_path}/{base_path}")

    # populate data
    organization_dict = get_organization()

    # delete id from output
    name = list(organization_dict.keys())[0]
    id = organization_dict["id"]
    del organization_dict["id"]

    if generate_config_files:
        write_to_config_files(config_path, organization_dict)

    # import to terraform
    tf_state = get_tf_state()
    tf_organization_resource = f"{terraform_base_resource}"
    if tf_organization_resource not in tf_state:
        import_tf_resource(tf_organization_resource, str(id))


def get_organization():
    organization_dict = {}
    data = get_grafana_data("/api/org/")
    name = data["name"]
    organization_dict = {"name": name, "id": data["id"]}

    return organization_dict


def write_to_config_files(config_path, organization_dict):
    # write to config file
    file_path = f"{config_path}/{base_path}/organization.yaml"
    with open(file_path, "w") as file:
        print(f"Writing to '{file_path}'")
        yaml.dump(organization_dict, file, width=float("inf"))
