output "gha_tf_plan_role_arn" {
  value       = aws_iam_role.gha_tf_plan.arn
  description = "IAM role assumed by GitHub Actions for terraform plan."
}

output "oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.github.arn
  description = "GitHub OIDC provider ARN."
}
