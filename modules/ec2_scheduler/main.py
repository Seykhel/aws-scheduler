import boto3
import os

EC2TAG_KEY   = os.getenv("EC2TAG_KEY")
EC2TAG_VALUE = os.getenv("EC2TAG_VALUE")
EC2_ACTION   = os.getenv("EC2_ACTION")

ec2 = boto3.client('ec2')

def get_list_of_servers_with_tag(EC2TAG_KEY, EC2TAG_VALUE, EC2_ACTION):
    """
    Retrieves a list of EC2 server IDs that have a specific tag and meet the specified instance state criteria.

    Args:
        EC2TAG_KEY (str): The key of the tag to filter the EC2 instances.
        EC2TAG_VALUE (str): The value of the tag to filter the EC2 instances.
        EC2_ACTION (str): The action to perform on the EC2 instances. Valid values are "START" or "STOP".

    Returns:
        list: A list of EC2 server IDs that match the tag and instance state criteria.
    """
    instance_state_values = ["running"] if EC2_ACTION == "STOP" else ["stopped"] if EC2_ACTION == "START" else []

    response = ec2.describe_instances(
        Filters=[
            {
                'Name': "tag:" + EC2TAG_KEY,
                'Values': [EC2TAG_VALUE]
            },
            {
                'Name': "instance-state-name",
                'Values': instance_state_values
            }
        ]
    )

    server_ids = [server['InstanceId'] for reservation in response['Reservations'] for server in reservation['Instances']]
    return server_ids

def lambda_handler(event, context):
    """
    Lambda function handler that performs the specified action on EC2 instances with a specific tag.

    Args:
        event (dict): The event data passed to the Lambda function.
        context (object): The runtime information of the Lambda function.

    Returns:
        dict: The response object containing the status code and body of the Lambda function execution.
    """
    try:
        server_ids = get_list_of_servers_with_tag(EC2TAG_KEY, EC2TAG_VALUE, EC2_ACTION)
        if not server_ids:
            print(f"No Servers to {EC2_ACTION}")
            return {
                'statusCode': 200,
                'body': f'No instances to {EC2_ACTION} with tag {EC2TAG_KEY}:{EC2TAG_VALUE}'
            }

        print(f"Servers to {EC2_ACTION}: {server_ids}")

        if EC2_ACTION == "STOP":
            ec2.stop_instances(InstanceIds=server_ids)
        elif EC2_ACTION == "START":
            ec2.start_instances(InstanceIds=server_ids)
        else:
            print("Invalid EC2_ACTION value. Please set EC2_ACTION to STOP or START.")
            return {
                'statusCode': 400,
                'body': 'Invalid EC2_ACTION value. Please set EC2_ACTION to STOP or START.'
            }

    except Exception as error:
        print(f"Error occurred! Error Message: {error}")
        return {
            'statusCode': 500,
            'body': f'Error occurred! Error Message: {error}'
        }

    return {
        'statusCode': 200,
        'body': f'{EC2_ACTION} action performed on EC2 instances with tag {EC2TAG_KEY}:{EC2TAG_VALUE}'
    }