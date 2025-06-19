#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Define the S3 bucket name and target prefix
S3_BUCKET="groupb-serverless-app-upload-bucket"
S3_PREFIX="inbound"
NUM_FILES=10

echo "Uploading $NUM_FILES test files to s3://$S3_BUCKET/$S3_PREFIX/"

# Loop to create and upload files
for i in $(seq 1 $NUM_FILES); do
    RANDOM_NUMBER=$((1 + RANDOM % 1000))
    DATE_TAG=$(date +%Y-%m-%d)
    FILENAME="filename-$RANDOM_NUMBER-$DATE_TAG.txt"

    # Create test file
    echo "This is test file number $i with random ID $RANDOM_NUMBER" > "$FILENAME"

    # Upload to S3
    echo "Uploading $FILENAME to s3://$S3_BUCKET/$S3_PREFIX/"
    aws s3 cp "$FILENAME" "s3://$S3_BUCKET/$S3_PREFIX/"

    # Clean up local file
    rm -f "$FILENAME"
done

echo "✅ Upload complete!"

