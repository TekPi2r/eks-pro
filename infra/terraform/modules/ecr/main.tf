locals {
  name = "${var.project}-${var.env}-${var.repository_name}"
  tags = { Project = var.project, Env = var.env }
}

resource "aws_ecr_repository" "this" {
  name                 = local.name
  image_tag_mutability = var.image_tag_immutability
  image_scanning_configuration { scan_on_push = var.scan_on_push }
  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }
  tags = merge(local.tags, { Name = local.name })
}

# Lifecycle: garder les N dernières images, supprimer untagged vieux
resource "aws_ecr_lifecycle_policy" "keep_recent" {
  repository = aws_ecr_repository.this.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last ${var.retain_images} images",
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = var.retain_images
        },
        action = { type = "expire" }
      },
      {
        rulePriority = 2,
        description  = "Expire untagged images older than 14 days",
        selection = {
          tagStatus   = "untagged",
          countType   = "sinceImagePushed",
          countUnit   = "days",
          countNumber = 14
        },
        action = { type = "expire" }
      }
    ]
  })
}
