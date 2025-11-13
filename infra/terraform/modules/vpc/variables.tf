variable "project" { type = string }
variable "env" { type = string }
variable "region" { type = string }

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "az_count" {
  type    = number
  default = 3
}
variable "enable_nat" {
  type    = bool
  default = true
} # 1 NAT GW (cost-optimized)
variable "kms_key_arn" {
  type = string
}
