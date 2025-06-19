# S3 Bucket for Uploads
resource "aws_s3_bucket" "upload_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

# DynamoDB Table for Metadata
resource "aws_dynamodb_table" "file_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "filename"

  attribute {
    name = "filename"
    type = "S"
  }
}

# SNS Topic and Email Subscription
resource "aws_sns_topic" "file_upload_topic" {
  name = "file-upload-notifications"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.file_upload_topic.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# IAM Role and Policies for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role_gropub"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy_attachment" "lambda_basic_logs" {
  name       = "lambda-logs"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy_attachment" "lambda_dynamodb_access" {
  name       = "lambda-dynamodb"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_policy_attachment" "lambda_sns_access" {
  name       = "lambda-sns"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

# Package Lambda Function Code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "lambda"
  output_path = "lambda-archive/lambda_function_payload.zip"
}

resource "aws_lambda_function" "s3_event_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  timeout          = 10
  memory_size      = 128

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.file_table.name
      SNS_TOPIC_ARN  = aws_sns_topic.file_upload_topic.arn
    }
  }
}

# Trigger Lambda from S3 Upload
resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = aws_s3_bucket.upload_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_event_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_event_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.upload_bucket.arn
}

