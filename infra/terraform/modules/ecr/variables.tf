variable "project" { type = string }
variable "env" { type = string }

variable "repository_name" {
  type    = string
  default = "app"
}

variable "image_tag_immutability" {
  type    = string
  default = "IMMUTABLE"
} # ROI-safe

variable "scan_on_push" {
  type    = bool
  default = true
}

variable "retain_images" {
  type    = number
  default = 10
} # last N images

variable "kms_key_arn" {
  type = string
}
