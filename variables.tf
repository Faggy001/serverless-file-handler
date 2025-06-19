variable "region" {
  description = "AWS region where all resources will be deployed"
  type        = string
  default     = "ca-central-1"
}

variable "profile" {
  description = "AWS CLI profile to use for deployment"
  type        = string
  default     = "default"
}

variable "bucket_name" {
  description = "S3 bucket name for uploading files and triggering Lambda"
  type        = string
  default     = "groupb-serverless-app-upload-bucket"
}

variable "bucket_prefix" {
  description = "Prefix/folder in S3 bucket where uploads land (e.g., 'inbound/')"
  type        = string
  default     = "inbound/"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name to log uploaded file metadata"
  type        = string
  default     = "FileMetadata"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function triggered by S3 uploads"
  type        = string
  default     = "s3-to-dynamodb-lambda"
}

variable "notification_email" {
  description = "Email address to receive SNS notifications when a file is uploaded"
  type        = string
  default     = "faggy29@gmail.com"
}


