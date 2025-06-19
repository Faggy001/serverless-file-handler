import boto3
import os
import logging
from datetime import datetime

# Initialize logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# AWS clients
s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

# Env variables
bucket_path = os.getenv('BUCKET_PATH')
dynamodb_table_name = os.getenv('DYNAMODB_TABLE')
sns_topic_arn = os.getenv('SNS_TOPIC_ARN')

# DynamoDB Table
table = dynamodb.Table(dynamodb_table_name)

def handler(event, context):
    if not bucket_path:
        logger.error("BUCKET_PATH is not set.")
        return

    try:
        bucket_name = bucket_path.split('/')[0]
        prefix = bucket_path.split(bucket_name + '/')[1]

        logger.info(f"Bucket: {bucket_name}, Prefix: {prefix}")

        response = s3_client.list_objects_v2(Bucket=bucket_name, Prefix=prefix, Delimiter='/')

        if 'Contents' not in response:
            logger.info("No files found in the prefix.")
            return

        for obj in response['Contents']:
            key = obj['Key']

            if key == prefix or not key.endswith('.txt'):
                continue

            try:
                new_filename = key.split(prefix)[1]
                parts = new_filename.replace('.txt', '').split('-')

                if len(parts) < 5:
                    logger.warning(f"Invalid filename format: {new_filename}")
                    continue

                year, month, day = parts[2], parts[3], parts[4]
                new_key = f"{prefix}{year}/{month}/{day}/{new_filename}"

                logger.info(f"Moving {key} → {new_key}")

                # Move the file
                s3_client.copy_object(
                    Bucket=bucket_name,
                    CopySource={'Bucket': bucket_name, 'Key': key},
                    Key=new_key
                )
                s3_client.delete_object(Bucket=bucket_name, Key=key)

                logger.info(f"File moved: {key} → {new_key}")

                # Log metadata to DynamoDB
                timestamp = datetime.utcnow().isoformat()
                table.put_item(Item={
                    'filename': new_key,
                    'uploaded_at': timestamp
                })
                logger.info("Logged to DynamoDB.")

                # Send SNS Notification
                sns.publish(
                    TopicArn=sns_topic_arn,
                    Message=f"New file uploaded and moved: {new_key} at {timestamp}",
                    Subject="S3 Upload Notification"
                )
                logger.info("SNS notification sent.")

            except Exception as single_file_error:
                logger.error(f"Error processing file {key}: {single_file_error}")

    except Exception as e:
        logger.error(f"Error in handler: {e}")
        raise e

if __name__ == '__main__':
    handler("", "")


