output "s3_bucket_name" {
  description = "The name of the S3 bucket where files are uploaded"
  value       = aws_s3_bucket.upload_bucket.bucket
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table used for logging metadata"
  value       = aws_dynamodb_table.file_table.name
}

output "lambda_function_name" {
  description = "The name of the deployed Lambda function"
  value       = aws_lambda_function.s3_event_lambda.function_name
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic used for email notifications"
  value       = aws_sns_topic.file_upload_topic.arn
}



