import subprocess
import requests
import re
import hcl2
from pathlib import Path


TFVARS_FILE = "terraform.auto.tfvars"

with open(TFVARS_FILE, "r") as file:
    tfvars = hcl2.load(file)

GRAFANA_URL = tfvars.get("grafana-url").lstrip("https://")
BASIC_AUTH = tfvars.get("grafana-basic-auth-credentials")
# NOTE: not used atm
API_TOKEN = ""


def get_grafana_data(path, auth="basic"):
    match auth:
        case "basic":
            response = requests.get(
                f"https://{BASIC_AUTH}@{GRAFANA_URL}{path}",
                headers={
                    "Content-Type": "application/json",
                    "Accept": "application/json",
                },
            )
        case "token":
            headers = {
                "Authorization": f"Bearer {API_TOKEN}",
                "Content-Type": "application/json",
                "Accept": "application/json",
            }

            response = requests.get(f"https://{GRAFANA_URL}{path}", headers=headers)
        case _:
            raise Exception(f"Unknown auth type '{auth}'!")
    return response.json()


def get_folder_name_from_uid(uid):
    data = get_grafana_data(f"/api/folders/{uid}")
    return data["title"]


def get_org_id():
    data = get_grafana_data("/api/org/")
    return data["id"]


def get_tf_state():
    command = ["terraform", "state", "list"]
    tf_state = subprocess.run(command, capture_output=True, text=True).stdout
    return tf_state


# def is_resource_in_tf_state(resource_str):
#    tf_state = get_tf_state()
#    return resource_str in tf_state


def import_tf_resource(resource_str, import_address):
    command = [
        "terraform",
        "import",
        resource_str,
        import_address,
    ]
    subprocess.run(
        command,
        text=True,
    )


# def import_tf_resource_with_check(resource_str, import_address):
#    if not is_resource_in_tf_state(resource_str):
#        import_tf_resource(resource_str, import_address)


def to_kebab_case(text):
    text = re.sub(r"[^a-zA-Z0-9\s]", "-", text)
    text = text.replace(" ", "-")
    text = text.lower()
    text = re.sub(r"-+", "-", text)
    text = text.strip("-")

    return text


def create_dir(dir_str):
    folder = Path(dir_str)
    folder.mkdir(parents=True, exist_ok=True)
