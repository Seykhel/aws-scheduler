import boto3
import os

RDSTAG_KEY    = os.getenv("RDSTAG_KEY")
RDSTAG_VALUE  = os.getenv("RDSTAG_VALUE")
RDS_ACTION    = os.getenv("RDS_ACTION")

rds = boto3.client('rds')

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

    paginator = rds.get_paginator('describe_db_instances')
    for page in paginator.paginate():
        for instance in page['DBInstances']:
            if instance['DBInstanceStatus'] in instance_state_values:
                arn = instance['DBInstanceArn']
                tags_response = rds.list_tags_for_resource(ResourceName=arn)
                for tag in tags_response.get('TagList', []):
                    if tag['Key'] == RDSTAG_KEY and tag['Value'] == RDSTAG_VALUE:
                        db_instance_ids.append(instance['DBInstanceIdentifier'])
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
            print(f"DB instances to {RDS_ACTION}: {db_instance_ids}")
            return {
                'statusCode': 200,
                'body': f'No instances to {RDS_ACTION} with tag {RDSTAG_KEY}:{RDSTAG_VALUE}'
            }

        for db_instance_id in db_instance_ids:
            if RDS_ACTION == "STOP":
                rds.stop_db_instance(DBInstanceIdentifier=db_instance_id)
            elif RDS_ACTION == "START":
                rds.start_db_instance(DBInstanceIdentifier=db_instance_id)
            else:
                print("Invalid RDS_ACTION value. Please set RDS_ACTION to STOP or START.")
                return {
                    'statusCode': 400,
                    'body': 'Invalid RDS_ACTION value. Please set RDS_ACTION to STOP or START.'
                }

    except Exception as error:
        print(f"Error occurred! Error Message: {error}")
        return {
            'statusCode': 500,
            'body': f'Error occurred! Error Message: {error}'
        }

    return {
        'statusCode': 200,
        'body': f'{RDS_ACTION} action performed on RDS instances with tag {RDSTAG_KEY}:{RDSTAG_VALUE}'
    }