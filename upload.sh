#!/bin/bash

# ========= Configuration =========
BUCKET_NAME="groupb-serverless-app-upload-bucket"  
FILE_PREFIX="testfile"
EXT="txt"
REGION="ca-central-1"

# ========= Generate Unique File =========
RANDOM_NUM=$((1 + RANDOM % 10000))
DATE=$(date +%Y-%m-%dT%H-%M-%S)
FILENAME="${FILE_PREFIX}-${RANDOM_NUM}-${DATE}.${EXT}"

echo "Generating test file: $FILENAME"
echo "Test file created at $DATE" > "$FILENAME"

# ========= Upload to S3 =========
echo "Uploading $FILENAME to S3 bucket: $BUCKET_NAME"
aws s3 cp "$FILENAME" "s3://$BUCKET_NAME/" --region "$REGION"

# ========= Clean Up Local File =========
rm "$FILENAME"

echo "✅ Upload complete. Check your email for SNS notification."
