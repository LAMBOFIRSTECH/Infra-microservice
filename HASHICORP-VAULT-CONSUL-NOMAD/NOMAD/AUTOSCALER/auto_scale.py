import requests
import subprocess
import os
from scale_modulus import get_container_stats
from scale_modulus import get_container_name


CERT_PATH = "Certs/vault-ca.crt"
CLIENT_CERT = "Certs/client.crt"
CLIENT_KEY = "Certs/client.key"

JOB_NAME = "rp-apache"
TASK_GROUP = "web_server"

NOMAD_JOBS_URL = "https://localhost:4646/v1/jobs"
NOMAD_JOB_URL = f"https://localhost:4646/v1/job/{JOB_NAME}"

CPU_THRESHOLD_UP = 70
MEM_THRESHOLD_UP = 80
CPU_THRESHOLD_DOWN = 30
MEM_THRESHOLD_DOWN = 20


def update_job_replicas(delta):
    try:
        response = requests.get(
            NOMAD_JOB_URL,
            verify=CERT_PATH,
            cert=(CLIENT_CERT, CLIENT_KEY),
        )
        response.raise_for_status()
        job_json = response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching job definition: {e}")
        return

    job_modify_index = job_json.get("ModifyIndex", 0)

    readonly_fields = [
        "CreateIndex",
        "JobSummary",
        "StatusSummary",
        "Version",
        "Status",
        "SubmitTime",
    ]
    for field in readonly_fields:
        job_json.pop(field, None)

    for tg in job_json.get("TaskGroups", []):
        if tg["Name"] == TASK_GROUP:
            tg["Count"] = max(1, tg["Count"] + delta)
            new_count = tg["Count"]
            break

    payload = {"Job": job_json, "JobModifyIndex": job_modify_index}

    try:
        response = requests.post(
            NOMAD_JOB_URL,
            json=payload,
            verify=CERT_PATH,
            cert=(CLIENT_CERT, CLIENT_KEY),
        )
        response.raise_for_status()
        print(f"Successfully updated replicas to {new_count}.")
    except requests.exceptions.RequestException as e:
        print(f"Error updating job replicas: {e}")


def scale_job():
    cpu = get_container_stats()[0]
    mem = get_container_stats()[1]
    if cpu is None or mem is None:
        print("Unable to retrieve container stats.")
        return

    print(f"CPU Usage: {cpu}% | Memory Usage: {mem}%")

    if cpu > CPU_THRESHOLD_UP or mem > MEM_THRESHOLD_UP:
        print("High load detected, scaling up!")
        update_job_replicas(1)
        cmd = 'sleep 10'
        os.system(cmd)
        subprocess.run(
            [
                "docker",
                "rm",
                "-f",
                get_container_name(),
            ],
            stdout=subprocess.PIPE,
            text=True,
        )
    elif cpu < CPU_THRESHOLD_DOWN and mem < MEM_THRESHOLD_DOWN:
        print("Low load detected, scaling down!")
        update_job_replicas(-1)
    else:
        print("Load within thresholds, no scaling needed.")


# ---------------- Main ----------------
if __name__ == "__main__":
    scale_job()
