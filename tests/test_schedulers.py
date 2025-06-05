import importlib.util
import os
import sys
from unittest.mock import MagicMock, patch

ROOT = os.path.dirname(os.path.dirname(__file__))
sys.path.insert(0, ROOT)

# Load modules dynamically while patching boto3 clients so that no AWS calls occur
with patch("boto3.client", return_value=MagicMock()):
    _ec2_spec = importlib.util.spec_from_file_location(
        "ec2_main", os.path.join(ROOT, "modules", "ec2_scheduler", "main.py")
    )
    ec2_main = importlib.util.module_from_spec(_ec2_spec)
    _ec2_spec.loader.exec_module(ec2_main)

    _rds_spec = importlib.util.spec_from_file_location(
        "rds_main", os.path.join(ROOT, "modules", "rds_scheduler", "main.py")
    )
    rds_main = importlib.util.module_from_spec(_rds_spec)
    _rds_spec.loader.exec_module(rds_main)


def test_get_list_of_servers_with_tag_stop():
    mock_ec2 = MagicMock()
    mock_ec2.describe_instances.return_value = {
        "Reservations": [
            {"Instances": [{"InstanceId": "i-1"}, {"InstanceId": "i-2"}]}
        ]
    }
    with patch.object(ec2_main.scheduler, "client", mock_ec2):
        result = ec2_main.get_list_of_servers_with_tag("Env", "dev", "STOP")
        assert result == ["i-1", "i-2"]
        mock_ec2.describe_instances.assert_called_with(
            Filters=[
                {"Name": "tag:Env", "Values": ["dev"]},
                {"Name": "instance-state-name", "Values": ["running"]},
            ]
        )


def test_get_list_of_db_instances_with_tag_start():
    mock_rds = MagicMock()
    mock_rds.describe_db_instances.return_value = {
        "DBInstances": [
            {
                "DBInstanceIdentifier": "db-1",
                "DBInstanceStatus": "stopped",
                "DBInstanceArn": "arn:aws:rds:us-east-1:123456789012:db:db-1",
            }
        ]
    }
    mock_rds.list_tags_for_resource.return_value = {
        "TagList": [{"Key": "Env", "Value": "dev"}]
    }
    with patch.object(rds_main.scheduler, "client", mock_rds):
        result = rds_main.get_list_of_db_instances_with_tag("Env", "dev", "START")
        assert result == ["db-1"]
        mock_rds.list_tags_for_resource.assert_called_with(
            ResourceName="arn:aws:rds:us-east-1:123456789012:db:db-1"
        )


def test_ec2_lambda_handler_stop_calls_stop_resources():
    with (
        patch.object(ec2_main.scheduler, "get_resource_ids", return_value=["i-1"]),
        patch.object(ec2_main.scheduler, "stop_resources") as mock_stop,
        patch.object(ec2_main.scheduler, "start_resources") as mock_start,
    ):
        ec2_main.scheduler.action = "STOP"
        ec2_main.scheduler.tag_key = "Env"
        ec2_main.scheduler.tag_value = "dev"
        result = ec2_main.lambda_handler({}, {})
        assert result["statusCode"] == 200
        mock_stop.assert_called_once_with(["i-1"])
        mock_start.assert_not_called()


def test_rds_lambda_handler_start_calls_start_resources():
    with (
        patch.object(rds_main.scheduler, "get_resource_ids", return_value=["db-1"]),
        patch.object(rds_main.scheduler, "start_resources") as mock_start,
        patch.object(rds_main.scheduler, "stop_resources") as mock_stop,
    ):
        rds_main.scheduler.action = "START"
        rds_main.scheduler.tag_key = "Env"
        rds_main.scheduler.tag_value = "dev"
        result = rds_main.lambda_handler({}, {})
        assert result["statusCode"] == 200
        mock_start.assert_called_once_with(["db-1"])
        mock_stop.assert_not_called()
