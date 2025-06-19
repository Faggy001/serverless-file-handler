variable "region" {
  description = "AWS region to deploy resources"
  default     = "ca-central-1"
}

variable "profile" {
  description = "AWS CLI profile name"
  default     = "default"
}

variable "bucket_name" {
  description = "S3 bucket name"
  default     = "groupb-serverless-app-upload-bucket"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name"
  default     = "FileMetadata"
}

variable "lambda_function_name" {
  description = "Lambda function name"
  default     = "s3-to-dynamodb-lambda"
}

variable "notification_email" {
  description = "Email address to receive SNS notifications"
  default     = "faggy29@gmail.com"
}

