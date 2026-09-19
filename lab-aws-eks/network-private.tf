resource "aws_eip" "this" {
  for_each = local.private ? local.public_subnets : {}

  domain = "vpc"

  tags = {
    Name = "${local.env}-ip-eks-${each.value.availability_zone}"
  }
}

resource "aws_nat_gateway" "this" {
  depends_on = [aws_internet_gateway.this]

  for_each = local.private ? local.public_subnets : {}

  allocation_id = aws_eip.this[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = {
    Name = "${local.env}-nat-eks-${each.value.availability_zone}"
  }
}

resource "aws_subnet" "private" {
  for_each = local.private ? local.private_subnets : {}

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = {
    Name = "${local.env}-private-eks-${each.value.availability_zone}"
  }
}

resource "aws_route_table" "private" {
  for_each = local.private ? local.private_subnets : {}

  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    # For this private subnet, find the public subnet in the same availability zone, then use the NAT gateway created in that public subnet.
    nat_gateway_id = one([ # Example result: "nat-0123456789"
      for public_key, public_subnet in local.public_subnets :
      aws_nat_gateway.this[public_key].id
      if public_subnet.availability_zone == each.value.availability_zone
    ])
  }

  tags = {
    Name = "${local.env}-private-eks-${each.value.availability_zone}"
  }
}

resource "aws_route_table_association" "private" {
  for_each = local.private ? local.private_subnets : {}

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}
