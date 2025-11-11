variable "project" { type = string }
variable "env" { type = string }
variable "repo_full_name" { type = string }
variable "name_prefix" {
  type    = string
  default = null
}

# Remote state resources from PoC 1A
variable "tfstate_bucket_arn" { type = string }
variable "tf_lock_table_arn" { type = string }
variable "tfstate_kms_arn" { type = string }

# Override optionnel si tu veux un autre nom de rôle
variable "role_name" {
  type    = string
  default = null
}
