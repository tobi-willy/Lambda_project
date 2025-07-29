variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-2"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  default     = "todos"
}