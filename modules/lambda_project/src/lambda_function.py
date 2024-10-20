import os

import boto3


def lambda_handler(event: dict, context: object) -> None:
    """Handles Lambda events to start or stop RDS instances based on a switch value,
    gracefully handling potential errors."""

    try:
        region = os.environ.get("AWS_REGION")

        rds_client = boto3.client("rds", region_name=region)

        db_instances = rds_client.describe_db_instances()["DBInstances"]
        db_instance_names = [instance["DBInstanceIdentifier"] for instance in db_instances]

        action = "stop" if event["switch"] == 0 else "start"

        for db_instance_name in db_instance_names:
            try:
                getattr(rds_client, f"{action}_db_instance")(DBInstanceIdentifier=db_instance_name)
            except rds_client.exceptions.DBInstanceNotFoundFault as e:
                print(e.response["Error"]["Message"])
            except rds_client.exceptions.InvalidDBInstanceStateFault as e:
                print(e.response["Error"]["Message"])
            except Exception as e:
                print(f"Unexpected error occurred for DB instance '{db_instance_name}': {e}")

    except Exception as e:
        print(f"Error occurred: {e}")