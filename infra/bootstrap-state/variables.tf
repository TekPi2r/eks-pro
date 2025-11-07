variable "project" {
  description = "Project name (naming & tagging)."
  type        = string
  default     = "eks-pro"
}

variable "env" {
  description = "Environment name (e.g., dev/prod/stage)."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "eu-west-3"
}

variable "bucket_name" {
  description = "Explicit S3 bucket name for tfstate (must be globally unique). Leave empty to auto-name."
  type        = string
  default     = ""
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for state locking (leave empty to auto-name)."
  type        = string
  default     = ""
}
