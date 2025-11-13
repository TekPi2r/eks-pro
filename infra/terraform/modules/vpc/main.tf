data "aws_availability_zones" "this" {
  state = "available"
  filter {
    name   = "region-name"
    values = [var.region]
  }
}

locals {
  name = "${var.project}-${var.env}"
  # On prend les az_count premières AZ
  azs = slice(data.aws_availability_zones.this.names, 0, var.az_count)

  public_cidrs  = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_cidrs = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i + 100)]
  tags_base     = { Project = var.project, Env = var.env }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.tags_base, { Name = "${local.name}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.tags_base, { Name = "${local.name}-igw" })
}

# Public subnets + RTs
resource "aws_subnet" "public" {
  for_each                = { for idx, az in local.azs : idx => az }
  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.value
  cidr_block              = local.public_cidrs[tonumber(each.key)]
  map_public_ip_on_launch = true
  tags = merge(local.tags_base, {
    Name = "${local.name}-public-${each.value}"
    Tier = "public"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.tags_base, { Name = "${local.name}-rt-public" })
}

resource "aws_route" "public_inet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private subnets + RT + NAT (1 NAT GW partagé)
resource "aws_subnet" "private" {
  for_each          = { for idx, az in local.azs : idx => az }
  vpc_id            = aws_vpc.this.id
  availability_zone = each.value
  cidr_block        = local.private_cidrs[tonumber(each.key)]
  tags = merge(local.tags_base, {
    Name = "${local.name}-private-${each.value}"
    Tier = "private"
  })
}

resource "aws_eip" "nat" {
  count  = var.enable_nat ? 1 : 0
  domain = "vpc"
  tags   = merge(local.tags_base, { Name = "${local.name}-nat-eip" })
}

resource "aws_nat_gateway" "nat" {
  count         = var.enable_nat ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = values(aws_subnet.public)[0].id
  tags          = merge(local.tags_base, { Name = "${local.name}-nat" })
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.tags_base, { Name = "${local.name}-rt-private" })
}

resource "aws_route" "private_nat" {
  count                  = var.enable_nat ? 1 : 0
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[0].id
}

resource "aws_route_table_association" "private_assoc" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

#tfsec:ignore:AVD-AWS-0017
resource "aws_cloudwatch_log_group" "flow_logs" {
  name = "/aws/vpc/${local.name}-flow-logs"
  # In this PoC we rely on the AWS-managed KMS key for CloudWatch Logs.
  # In a production platform, I would introduce a dedicated CMK for logs
  # with a stricter key policy and possibly centralization.
  retention_in_days = 30

  tags = merge(local.tags_base, {
    Name = "${local.name}-vpc-flow-logs"
  })
}

resource "aws_iam_role" "flow_logs" {
  name = "${local.name}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "vpc-flow-logs.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(local.tags_base, {
    Name = "${local.name}-vpc-flow-logs-role"
  })
}

resource "aws_iam_role_policy" "flow_logs" {
  name = "${local.name}-vpc-flow-logs-policy"
  role = aws_iam_role.flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_flow_log" "this" {
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.flow_logs.arn
  iam_role_arn         = aws_iam_role.flow_logs.arn

  traffic_type = "ALL"
  vpc_id       = aws_vpc.this.id

  tags = merge(local.tags_base, {
    Name = "${local.name}-vpc-flow-logs"
  })
}
