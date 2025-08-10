import yaml
from common import (
    get_grafana_data,
    get_org_id,
    create_dir,
    get_tf_state,
    import_tf_resource,
    to_kebab_case,
)

base_path = "folders"
terraform_base_folder_resource = "grafana_folder.folder"
terraform_base_folder_perm_resource = "grafana_folder_permission.folder-permission"
org_id = get_org_id()


def import_folders(config_path, generate_config_files=True, import_resources=True):
    print("Importing Grafana folders")

    # Extract env from config_path (format: envs/{env})
    env = config_path.split("/")[1]

    # create config folder if not exist
    create_dir(f"{config_path}/{base_path}")

    # populate data
    folder_dict = get_folders()

    if generate_config_files:
        write_to_config_files(config_path, folder_dict)

    if import_resources:
        tf_state = get_tf_state()
        for folder_title in folder_dict:
            uid = folder_dict[folder_title]["uid"]

            # import folders to terraform
            tf_folder_resource = f'{
                terraform_base_folder_resource}["{folder_title}"]'
            if tf_folder_resource not in tf_state:
                import_tf_resource(tf_folder_resource, f"{org_id}:{uid}", env)

            # import folder perms to terraform
            tf_folder_perm_resource = (
                f'{terraform_base_folder_perm_resource}["{folder_title}"]'
            )
            if tf_folder_perm_resource not in tf_state:
                import_tf_resource(tf_folder_perm_resource,
                                   f"{org_id}:{uid}", env)


def get_folders():
    folder_dict = {}
    data = get_grafana_data("/api/folders")
    for folder_data in data:
        title = folder_data["title"]
        uid = folder_data["uid"]
        folder_dict[to_kebab_case(title)] = {
            "title": title,
            "uid": uid,
            "permissions": get_folder_permissions(uid),
        }

    return folder_dict


def get_folder_permissions(uid):
    folder_perms = []
    data = get_grafana_data(f"/api/folders/{uid}/permissions")
    for perm in data:
        perm_dict = {"permission": perm["permissionName"]}
        user = perm["userLogin"]
        if user:
            perm_dict["user"] = user
        else:
            perm_dict["role"] = perm["role"]
        folder_perms.append(perm_dict)

    return folder_perms


def write_to_config_files(config_path, folder_dict):
    file_path = f"{config_path}/{base_path}/folders.yaml"
    with open(file_path, "w") as file:
        # write to config file
        print(f"Writing to '{file_path}'")
        yaml.dump(
            folder_dict,
            file,
            sort_keys=False,
            width=float("inf"),
        )
