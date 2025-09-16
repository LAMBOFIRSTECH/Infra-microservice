import requests
import subprocess

NOMAD_ALLOC_URL = "https://localhost:4646/v1/allocations"
CERT_PATH = "Certs/vault-ca.crt"
CLIENT_CERT = "Certs/client.crt"
CLIENT_KEY = "Certs/client.key"

JOB_NAME = "rp-apache"
TASK_GROUP = "web_server"


def get_job_alloc():
    try:
        response = requests.get(
            NOMAD_ALLOC_URL, verify=CERT_PATH, cert=(CLIENT_CERT, CLIENT_KEY)
        )
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching job allocations: {e}")
        return None


def get_container_name():
    job_allocs = get_job_alloc()
    if not job_allocs:
        return

    running_alloc = next(
        (
            alloc
            for alloc in job_allocs
            if any(
                task.get("State") == "running"
                for task in alloc.get("TaskStates", {}).values()
            )
        ),
        None,
    )

    if TASK_GROUP != running_alloc["TaskGroup"]:
        print(
            f"The following argument {TASK_GROUP} doesn't match for any task group on Nomad"
        )
        return
    return f"{running_alloc['JobID']}-{running_alloc['ID']}"


def get_container_stats():
    container_name = get_container_name()
    command = subprocess.run(
        [
            "docker",
            "stats",
            "--no-stream",
            "--format",
            "{{.CPUPerc}}\t{{.MemPerc}}",
            container_name,
        ],
        stdout=subprocess.PIPE,
        text=True,
    )

    output = command.stdout.strip()
    if not output:
        return None, None

    cpu_str, mem_str = output.split("\t")
    try:
        cpu = float(cpu_str.replace("%", ""))
        mem = float(mem_str.replace("%", ""))
        return cpu, mem
    except ValueError:
        return None, None
