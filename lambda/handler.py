import boto3
import os
import logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])
sns_topic_arn = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    try:
        logger.info("Received event: %s", event)

        for record in event['Records']:
            s3_info = record['s3']
            filename = s3_info['object']['key']
            timestamp = datetime.utcnow().isoformat()

            item = {
                'filename': filename,
                'uploaded_at': timestamp
            }

            table.put_item(Item=item)
            logger.info("Saved to DynamoDB: %s", item)

            sns.publish(
                TopicArn=sns_topic_arn,
                Message=f"New file uploaded: {filename} at {timestamp}",
                Subject="File Upload Notification"
            )
            logger.info("SNS notification sent.")

        return {"statusCode": 200, "body": "Success"}

    except Exception as e:
        logger.error("Error occurred: %s", str(e))
        raise e

