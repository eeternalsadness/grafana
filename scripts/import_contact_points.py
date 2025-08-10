import yaml
from common import (
    create_dir,
    get_grafana_data,
    get_org_id,
    get_tf_state,
    import_tf_resource,
)

base_path = "alerts/contact-points"
terraform_base_resource = "module.alerts.grafana_contact_point.contact-point"
org_id = get_org_id()


def import_contact_points(
    config_path, generate_config_files=True, import_resources=True
):
    print("Importing Grafana contact points")

    # Extract env from config_path (format: envs/{env})
    env = config_path.split("/")[1]

    contact_point_dict = get_contact_points()

    if generate_config_files:
        write_to_config_files(config_path, contact_point_dict)

    # check if contact point is already in state file
    if import_resources:
        tf_state = get_tf_state()
        for contact_point in contact_point_dict:
            tf_contact_point_resource = f'{
                terraform_base_resource}["{contact_point}"]'
            if tf_contact_point_resource not in tf_state:
                import_tf_resource(
                    tf_contact_point_resource, f"{org_id}:{contact_point}", env
                )


def get_contact_points():
    contact_points = {}
    data = get_grafana_data(
        "/api/v1/provisioning/contact-points/export?decrypt=true&format=json"
    )
    for contact_point_data in data["contactPoints"]:
        name = contact_point_data["name"]
        contact_points[name] = {
            "name": name,
            "contact_points": {},
        }
        for contact_point_receiver in contact_point_data["receivers"]:
            contact_point_type = contact_point_receiver["type"]
            contact_points[name]["contact_points"][contact_point_type] = {}

            match contact_point_type:
                case "googlechat":
                    # non-sensitive data
                    contact_points[name]["contact_points"][contact_point_type][
                        "title"
                    ] = contact_point_receiver["settings"]["title"]
                    contact_points[name]["contact_points"][contact_point_type][
                        "message"
                    ] = contact_point_receiver["settings"]["message"]

                    # sensitive data
                    contact_points[name]["contact_points"][contact_point_type][
                        "sensitive"
                    ] = {"url": contact_point_receiver["settings"]["url"]}
                case "slack":
                    # non-sensitive data
                    contact_points[name]["contact_points"][contact_point_type][
                        "title"
                    ] = contact_point_receiver["settings"]["title"]
                    contact_points[name]["contact_points"][contact_point_type][
                        "text"
                    ] = contact_point_receiver["settings"]["text"]

                    # sensitive data
                    contact_points[name]["contact_points"][contact_point_type][
                        "sensitive"
                    ] = {"url": contact_point_receiver["settings"]["url"]}
                case "telegram":
                    # non-sensitive data
                    contact_points[name]["contact_points"][contact_point_type][
                        "message"
                    ] = contact_point_receiver["settings"]["message"]
                    contact_points[name]["contact_points"][contact_point_type][
                        "chat_id"
                    ] = contact_point_receiver["settings"]["chatid"]

                    # sensitive data
                    contact_points[name]["contact_points"][contact_point_type][
                        "sensitive"
                    ] = {"token": contact_point_receiver["settings"]["bottoken"]}
                case _:
                    raise Exception(
                        f"Contact point type '{
                            contact_point_type
                        }' not recognized! Please modify the script to handle this contact point type."
                    )

    return contact_points


def write_to_config_files(config_path, contact_point_dict):
    # create config folder if not exist
    create_dir(f"{config_path}/{base_path}")

    # write non-sensitive data to yaml files
    file_path = f"{config_path}/{base_path}/contact-points.yaml"
    print(f"Writing to '{file_path}'")
    with open(file_path, "w") as file:
        yaml.dump(contact_point_dict, file,
                  sort_keys=False, width=float("inf"))
