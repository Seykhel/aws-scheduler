import os
import boto3
from modules.logger_config import get_logger

class BaseScheduler:
    """Base scheduler implementing shared start/stop logic."""

    def __init__(self, service_name: str, tag_key_var: str, tag_value_var: str, action_var: str):
        self.client = boto3.client(service_name)
        self.tag_key_var = tag_key_var
        self.tag_value_var = tag_value_var
        self.action_var = action_var
        self.tag_key = os.getenv(tag_key_var)
        self.tag_value = os.getenv(tag_value_var)
        self.action = os.getenv(action_var)
        self.region = self.client.meta.region_name
        self.logger = get_logger(__name__)

    def get_resource_ids(self):
        """Return a list of resource identifiers to operate on."""
        raise NotImplementedError

    def start_resources(self, ids):
        """Start resources identified by *ids*."""
        raise NotImplementedError

    def stop_resources(self, ids):
        """Stop resources identified by *ids*."""
        raise NotImplementedError

    def lambda_handler(self, event, context):
        """Common Lambda handler performing the desired action."""
        try:
            ids = self.get_resource_ids()
            if not ids:
                self.logger.info(f"No resources to {self.action} in {self.region}")
                return {
                    'statusCode': 200,
                    'body': f'No instances to {self.action} with tag {self.tag_key}:{self.tag_value}'
                }

            if self.action == "STOP":
                self.stop_resources(ids)
                self.logger.info(f"Stopping {ids} in {self.region}")
            elif self.action == "START":
                self.start_resources(ids)
                self.logger.info(f"Starting {ids} in {self.region}")
            else:
                self.logger.error(
                    f"Invalid {self.action_var} value. Please set {self.action_var} to STOP or START."
                )
                return {
                    'statusCode': 400,
                    'body': f'Invalid {self.action_var} value. Please set {self.action_var} to STOP or START.'
                }
        except Exception as error:  # pragma: no cover - defensive
            self.logger.exception(f"Error occurred in region {self.region}: {error}")
            return {
                'statusCode': 500,
                'body': f'Error occurred! Error Message: {error}'
            }

        return {
            'statusCode': 200,
            'body': f'{self.action} action performed on resources with tag {self.tag_key}:{self.tag_value}'
        }
