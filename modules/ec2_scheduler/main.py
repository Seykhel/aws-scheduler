from scheduler_common import BaseScheduler
from logger_config import get_logger

logger = get_logger(__name__)

class EC2Scheduler(BaseScheduler):
    def __init__(self):
        super().__init__("ec2", "EC2TAG_KEY", "EC2TAG_VALUE", "EC2_ACTION")

    def get_resource_ids(self):
        instance_state_values = ["running"] if self.action == "STOP" else ["stopped"] if self.action == "START" else []
        response = self.client.describe_instances(
            Filters=[
                {"Name": "tag:" + self.tag_key, "Values": [self.tag_value]},
                {"Name": "instance-state-name", "Values": instance_state_values},
            ]
        )
        server_ids = [server["InstanceId"] for reservation in response["Reservations"] for server in reservation["Instances"]]
        self.logger.info(f"Servers to {self.action} in {self.region}: {server_ids}")
        return server_ids

    def start_resources(self, ids):
        self.client.start_instances(InstanceIds=ids)

    def stop_resources(self, ids):
        self.client.stop_instances(InstanceIds=ids)


scheduler = EC2Scheduler()

def get_list_of_servers_with_tag(tag_key, tag_value, action):
    scheduler.tag_key = tag_key
    scheduler.tag_value = tag_value
    scheduler.action = action
    return scheduler.get_resource_ids()


def lambda_handler(event, context):
    return scheduler.lambda_handler(event, context)
