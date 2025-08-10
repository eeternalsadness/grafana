import yaml
from common import (
    get_grafana_data,
    create_dir,
    get_org_id,
    get_tf_state,
    import_tf_resource,
)

base_path = "alerts/mute-timings"
terraform_base_resource = "module.alerts.grafana_mute_timing.mute-timing"
org_id = get_org_id()


def import_mute_timings(config_path, generate_config_files=True, import_resources=True):
    print("Importing Grafana mute timings")

    # Extract env from config_path (format: envs/{env})
    env = config_path.split("/")[1]

    # create config folder if not exist
    create_dir(f"{config_path}/{base_path}")

    # populate data
    mute_timings_dict = get_mute_timings()

    for mute_timing in mute_timings_dict:
        name = mute_timings_dict[mute_timing]["name"]

        if generate_config_files:
            write_to_config_files(
                config_path, name, mute_timings_dict[mute_timing])

        # import to terraform
        if import_resources:
            tf_state = get_tf_state()
            tf_mute_timings_resource = f'{terraform_base_resource}["{name}"]'
            if tf_mute_timings_resource not in tf_state:
                import_tf_resource(tf_mute_timings_resource,
                                   f"{org_id}:{name}", env)


def get_mute_timings():
    mute_timings_dict = {}

    data = get_grafana_data("/api/v1/provisioning/mute-timings/export")
    if "muteTimes" in data:
        for mute_timing in data["muteTimes"]:
            name = mute_timing["name"]
            mute_timings_dict[name] = {
                "name": name,
                "intervals": [],
            }

            for interval in mute_timing["time_intervals"]:
                interval_dict = {
                    "times": [],
                    "weekdays": interval["weekdays"],
                }
                for time in interval["times"]:
                    interval_dict["times"].append(
                        {
                            "start": time["start_time"],
                            "end": time["end_time"],
                        }
                    )
                mute_timings_dict[name]["intervals"].append(interval_dict)

    return mute_timings_dict


def write_to_config_files(config_path, mute_timing_name, mute_timing):
    # write to config file
    file_path = f"{config_path}/{base_path}/{mute_timing_name}.yaml"
    with open(file_path, "w") as file:
        print(f"Writing to '{file_path}'")
        yaml.dump(
            {mute_timing_name: mute_timing},
            file,
            sort_keys=False,
            width=float("inf"),
        )
