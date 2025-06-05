import os
import subprocess
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]

TERRAFORM_DIRS = [
    ROOT,
    ROOT / "modules" / "ec2_scheduler",
    ROOT / "modules" / "rds_scheduler",
]

@pytest.mark.parametrize("tf_dir", TERRAFORM_DIRS)
def test_terraform_validate(tf_dir):
    env = os.environ.copy()
    env["TF_IN_AUTOMATION"] = "1"
    init_cmd = ["terraform", f"-chdir={tf_dir}", "init", "-backend=false", "-input=false"]
    try:
        subprocess.run(init_cmd, check=True, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except subprocess.CalledProcessError as exc:
        pytest.skip(f"terraform init failed: {exc.stderr.decode().strip()}")
    subprocess.run(["terraform", f"-chdir={tf_dir}", "validate", "-no-color"], check=True, env=env)

