from modules.scheduler_common import BaseScheduler
from modules.logger_config import get_logger

logger = get_logger(__name__)

class RDSScheduler(BaseScheduler):
    def __init__(self):
        super().__init__("rds", "RDSTAG_KEY", "RDSTAG_VALUE", "RDS_ACTION")

    def get_resource_ids(self):
        db_instance_ids = []
        instance_state_values = ["available"] if self.action == "STOP" else ["stopped"] if self.action == "START" else []
        response = self.client.describe_db_instances()
        for instance in response.get('DBInstances', []):
            if instance['DBInstanceStatus'] in instance_state_values:
                arn = instance['DBInstanceArn']
                tags_response = self.client.list_tags_for_resource(ResourceName=arn)
                for tag in tags_response.get('TagList', []):
                    if tag['Key'] == self.tag_key and tag['Value'] == self.tag_value:
                        db_instance_ids.append(instance['DBInstanceIdentifier'])
                        self.logger.info(
                            f"Matched DB instance {instance['DBInstanceIdentifier']} ({arn}) in {self.region}"
                        )
                        break
        return db_instance_ids

    def start_resources(self, ids):
        for db_instance_id in ids:
            self.client.start_db_instance(DBInstanceIdentifier=db_instance_id)

    def stop_resources(self, ids):
        for db_instance_id in ids:
            self.client.stop_db_instance(DBInstanceIdentifier=db_instance_id)

scheduler = RDSScheduler()

def get_list_of_db_instances_with_tag(tag_key, tag_value, action):
    scheduler.tag_key = tag_key
    scheduler.tag_value = tag_value
    scheduler.action = action
    return scheduler.get_resource_ids()

def lambda_handler(event, context):
    return scheduler.lambda_handler(event, context)

