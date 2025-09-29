# backend.tf

# 1. Create an SQS queue to receive messages about new files
resource "aws_sqs_queue" "processing_queue" {
  name = "project-guardian-processing-queue"
}

# 2. Create a DynamoDB table to store the analysis results
resource "aws_dynamodb_table" "results_table" {
  name         = "project-guardian-results"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "FileID"

  attribute {
    name = "FileID"
    type = "S"
  }
}