import yaml
from common import (
    create_dir,
    get_grafana_data,
    get_org_id,
    get_tf_state,
    import_tf_resource,
)

base_path = "alerts/message-templates"
terraform_base_resource = "module.alerts.grafana_message_template.message-template"
org_id = get_org_id()


def import_message_templates(
    config_path, generate_config_files=True, import_resources=True
):
    print("Importing Grafana message templates")

    # Extract env from config_path (format: envs/{env})
    env = config_path.split("/")[1]

    # create config folder if not exist
    create_dir(f"{config_path}/{base_path}")

    # populate data
    message_template_dict = get_message_templates()

    if generate_config_files:
        write_to_config_files(config_path, message_template_dict)

    # import to terraform
    if import_resources:
        tf_state = get_tf_state()
        for message_template in message_template_dict:
            tf_message_template_resource = (
                f'{terraform_base_resource}["{message_template}"]'
            )
            if tf_message_template_resource not in tf_state:
                import_tf_resource(
                    tf_message_template_resource, f"{
                        org_id}:{message_template}", env
                )


def get_message_templates():
    message_templates = {}
    data = get_grafana_data("/api/v1/provisioning/templates")
    for template_data in data:
        name = template_data["name"]
        message_templates[name] = template_data
        if "provenance" in message_templates[name]:
            del message_templates[name]["provenance"]

    return message_templates


def write_to_config_files(config_path, message_template_dict):
    # write to config file
    file_path = f"{config_path}/{base_path}/message-templates.yaml"
    with open(file_path, "w") as file:
        print(f"Writing to '{file_path}'")
        yaml.dump(
            message_template_dict,
            file,
            default_flow_style=False,
            allow_unicode=True,
            width=float("inf"),
        )
