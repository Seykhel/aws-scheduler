import boto3
import os
from modules.logger_config import get_logger

RDSTAG_KEY    = os.getenv("RDSTAG_KEY")
RDSTAG_VALUE  = os.getenv("RDSTAG_VALUE")
RDS_ACTION    = os.getenv("RDS_ACTION")

rds = boto3.client("rds")
logger = get_logger(__name__)
REGION = rds.meta.region_name

def get_list_of_db_instances_with_tag(RDSTAG_KEY, RDSTAG_VALUE, RDS_ACTION):
    """
    Retrieves a list of RDS DB instances with a specific tag and matching
    instance state. Tags are fetched for each instance using
    ``list_tags_for_resource``.

    Args:
        RDSTAG_KEY (str): The key of the tag to match.
        RDSTAG_VALUE (str): The value of the tag to match.
        RDS_ACTION (str): The action to perform on the matched instances. Valid values are "START" or "STOP".

    Returns:
        list: A list of DB instance identifiers matching the specified tag and instance state.
    """
    db_instance_ids = []
    instance_state_values = ["available"] if RDS_ACTION == "STOP" else ["stopped"] if RDS_ACTION == "START" else []

    response = rds.describe_db_instances()
    for instance in response.get('DBInstances', []):
        if instance['DBInstanceStatus'] in instance_state_values:
            arn = instance['DBInstanceArn']
            tags_response = rds.list_tags_for_resource(ResourceName=arn)
            for tag in tags_response.get('TagList', []):
                if tag['Key'] == RDSTAG_KEY and tag['Value'] == RDSTAG_VALUE:
                    db_instance_ids.append(instance['DBInstanceIdentifier'])
                    logger.info(
                        f"Matched DB instance {instance['DBInstanceIdentifier']} ({arn}) in {REGION}"
                    )
                    break


    return db_instance_ids

def lambda_handler(event, context):
    """
    Lambda function handler that performs the specified action on RDS instances with a specific tag.

    Args:
        event (dict): The event data passed to the Lambda function.
        context (object): The runtime information of the Lambda function.

    Returns:
        dict: The response object containing the status code and body message.
    """
    try:
        db_instance_ids = get_list_of_db_instances_with_tag(RDSTAG_KEY, RDSTAG_VALUE, RDS_ACTION)
        if not db_instance_ids:
            logger.info(f"No DB instances to {RDS_ACTION} in {REGION}")
            return {
                'statusCode': 200,
                'body': f'No instances to {RDS_ACTION} with tag {RDSTAG_KEY}:{RDSTAG_VALUE}'
            }

        for db_instance_id in db_instance_ids:
            if RDS_ACTION == "STOP":
                rds.stop_db_instance(DBInstanceIdentifier=db_instance_id)
                logger.info(f"Stopping DB {db_instance_id} in {REGION}")
            elif RDS_ACTION == "START":
                rds.start_db_instance(DBInstanceIdentifier=db_instance_id)
                logger.info(f"Starting DB {db_instance_id} in {REGION}")
            else:
                logger.error("Invalid RDS_ACTION value. Please set RDS_ACTION to STOP or START.")
                return {
                    'statusCode': 400,
                    'body': 'Invalid RDS_ACTION value. Please set RDS_ACTION to STOP or START.'
                }

    except Exception as error:
        logger.exception(f"Error occurred in region {REGION}: {error}")
        return {
            'statusCode': 500,
            'body': f'Error occurred! Error Message: {error}'
        }

    return {
        'statusCode': 200,
        'body': f'{RDS_ACTION} action performed on RDS instances with tag {RDSTAG_KEY}:{RDSTAG_VALUE}'
    }
