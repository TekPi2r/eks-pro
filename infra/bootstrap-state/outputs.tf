output "tfstate_bucket_name" {
  value       = aws_s3_bucket.tfstate.bucket
  description = "S3 bucket name for Terraform state."
}

output "tfstate_bucket_arn" {
  value       = aws_s3_bucket.tfstate.arn
  description = "S3 bucket ARN for Terraform state."
}

output "lock_table_name" {
  value       = aws_dynamodb_table.tf_lock.name
  description = "DynamoDB table name for state locking."
}

output "tfstate_rw_policy_arn" {
  value       = aws_iam_policy.tfstate_rw.arn
  description = "IAM policy ARN granting minimal RW on tfstate and lock."
}
