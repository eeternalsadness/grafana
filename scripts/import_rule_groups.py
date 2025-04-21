import yaml
from common import (
    get_grafana_data,
    get_org_id,
    get_tf_state,
    import_tf_resource,
    to_kebab_case,
    get_folder_name_from_uid,
    create_dir,
)

base_path = "alerts/rule-groups"
terraform_base_resource = "module.alerts.grafana_rule_group.rule-group"
org_id = get_org_id()


def import_rule_groups(config_path, generate_config_files=True):
    print("Importing Grafana rule groups")

    rule_groups = get_rule_groups()
    tf_state = get_tf_state()
    for rule_group in rule_groups:
        folder_uid = rule_groups[rule_group]["folder_uid"]
        rule_group_name = rule_groups[rule_group]["name"]
        data = get_grafana_data(
            f"/api/v1/provisioning/folder/{folder_uid}/rule-groups/{rule_group_name}/export?format=json"
        )

        title = to_kebab_case(rule_group_name)
        folder_name = get_folder_name_from_uid(folder_uid)

        if generate_config_files:
            write_to_config_files(config_path, folder_name, title, data)

        # import to terraform
        tf_rule_group_resource = f'{terraform_base_resource}["{folder_name}/{title}"]'
        if tf_rule_group_resource not in tf_state:
            import_tf_resource(
                tf_rule_group_resource, f"{org_id}:{folder_uid}:{rule_group_name}"
            )


def get_rule_groups():
    rule_groups = {}
    data = get_grafana_data("/api/v1/provisioning/alert-rules")
    for alert_data in data:
        name = alert_data["ruleGroup"]
        folder_uid = alert_data["folderUID"]
        rule_groups[f"{folder_uid}/{name}"] = {
            "name": name,
            "folder_uid": folder_uid,
        }
    # with open("alert-rules.yaml", "w") as file:
    #    yaml.dump(rule_groups, file)

    return rule_groups


def write_to_config_files(config_path, folder_name, title, data):
    # create folder if not exists
    create_dir(f"{config_path}/{base_path}/{folder_name}")

    # create file
    file_path = f"{config_path}/{base_path}/{folder_name}/{title}.yaml"
    print(f"Writing to '{file_path}'")
    with open(file_path, "w") as file:
        yaml.dump(data, file, sort_keys=False, width=float("inf"), allow_unicode=True)
