import yaml
from common import (
    get_grafana_data,
    create_dir,
    get_org_id,
    get_tf_state,
    import_tf_resource,
)

base_path = "alerts/notification-policy"
terraform_base_resource = (
    "module.alerts.grafana_notification_policy.notification-policy"
)
org_id = get_org_id()


def import_notification_policy(
    config_path, env, generate_config_files=True, import_to_terraform=True
):
    print("Importing Grafana notification policy")

    if generate_config_files:
        write_to_config_files(config_path)

    # import to terraform
    if import_to_terraform:
        tf_state = get_tf_state()
        tf_notification_policy_resource = f'{terraform_base_resource}["default"]'
        if tf_notification_policy_resource not in tf_state:
            import_tf_resource(
                tf_notification_policy_resource, f"{org_id}:default", env
            )


def get_notification_policy():
    notification_policy_dict = {}
    data = get_grafana_data("/api/v1/provisioning/policies/export")["policies"][0]
    notification_policy_dict["default"] = {
        "contact_point": data["receiver"],
        "group_by": data["group_by"],
        "group_wait": data["group_wait"] if "group_wait" in data else "",
        "group_interval": data["group_interval"] if "group_interval" in data else "",
        "repeat_interval": data["repeat_interval"] if "repeat_interval" in data else "",
        "policies": [],
    }

    for route in data["routes"]:
        policy_dict = {
            "contact_point": route["receiver"],
            "object_matchers": [],
        }

        if "continue" in route:
            policy_dict["continue"] = route["continue"]
        if "group_by" in route:
            policy_dict["group_by"] = route["group_by"]
        if "group_wait" in route:
            policy_dict["group_wait"] = route["group_wait"]
        if "group_interval" in route:
            policy_dict["group_interval"] = route["group_interval"]
        if "repeat_interval" in route:
            policy_dict["repeat_interval"] = route["repeat_interval"]

        for object_matcher in route["object_matchers"]:
            policy_dict["object_matchers"].append(
                {
                    "label": object_matcher[0],
                    "match": object_matcher[1],
                    "value": object_matcher[2],
                }
            )
        notification_policy_dict["default"]["policies"].append(policy_dict)

    return notification_policy_dict


def write_to_config_files(config_path):
    # create config folder if not exist
    create_dir(f"{config_path}/{base_path}")

    # populate data
    notification_policy_dict = get_notification_policy()

    # write to config file
    file_path = f"{config_path}/{base_path}/default.yaml"
    with open(file_path, "w") as file:
        print(f"Writing to '{file_path}'")
        yaml.dump(notification_policy_dict, file, sort_keys=False, width=float("inf"))
