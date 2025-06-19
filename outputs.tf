output "s3_bucket_name" {
  value = aws_s3_bucket.upload_bucket.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.file_table.name
}

output "lambda_function_name" {
  value = aws_lambda_function.s3_event_lambda.function_name
}

output "sns_topic_arn" {
  value = aws_sns_topic.file_upload_topic.arn
}

