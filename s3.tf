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
