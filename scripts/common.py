import subprocess
import requests
import re
import os
import base64
from pathlib import Path

GRAFANA_URL = os.getenv("GRAFANA_URL")
GRAFANA_BASIC_AUTH = os.getenv("GRAFANA_AUTH", "")
# NOTE: not used atm
GRAFANA_API_TOKEN = os.getenv("GRAFANA_AUTH", "")


def get_grafana_data(path, auth="basic"):
    match auth:
        case "basic":
            response = requests.get(
                f"{GRAFANA_URL}{path}",
                headers={
                    "Content-Type": "application/json",
                    "Accept": "application/json",
                    "Authorization": f"Basic {base64.b64encode(GRAFANA_BASIC_AUTH.encode('utf-8')).decode('utf-8')}",
                },
                verify="/Users/bach/certs/minikube.io/ca.crt",
            )
        case "token":
            headers = {
                "Authorization": f"Bearer {GRAFANA_API_TOKEN}",
                "Content-Type": "application/json",
                "Accept": "application/json",
            }

            response = requests.get(
                f"{GRAFANA_URL}{path}",
                headers=headers,
                verify="/Users/bach/certs/minikube.io/ca.crt",
            )
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
