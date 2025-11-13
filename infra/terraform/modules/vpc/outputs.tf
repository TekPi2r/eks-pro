output "vpc_id" { value = aws_vpc.this.id }
output "public_subnet_ids" { value = [for s in aws_subnet.public : s.id] }
output "private_subnet_ids" { value = [for s in aws_subnet.private : s.id] }
output "public_subnet_azs" { value = [for s in aws_subnet.public : s.availability_zone] }
output "private_subnet_azs" { value = [for s in aws_subnet.private : s.availability_zone] }
output "nat_gateway_id" { value = try(aws_nat_gateway.nat[0].id, null) }
