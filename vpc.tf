resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = var.instance_tenancy
  enable_dns_hostnames  = var.enable_dns_hostnames 

  tags = merge (
    var.common_tags,
    var.vpc_tags,
    {
      Name = local.resource_name
    }
  )
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.common_tags,
    var.igw_tags,
    {
      Name = "${local.resource_name}-igw"
    }
  )
}

## public subnet ##

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  count = length(var.public_subnet_cidrs)
  cidr_block = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone = local.azs_names[count.index]


  tags = merge (
    var.common_tags,
    var.public_subnet_cidrs_tags,
    {
      Name = "${var.project_name}-public-${local.azs_names[count.index]}"
    }
  )
}

## private subnet ##

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = local.azs_names[count.index]

  tags =  merge (
    var.common_tags,
    var.private_subnet_cidrs_tags,
    {
      Name = "${var.project_name}-private-${local.azs_names[count.index]}"
    }
  )
}

## database subnet ##

resource "aws_subnet" "database_subnet" {
  count = length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  availability_zone = local.azs_names[count.index]

  tags = merge (
    var.common_tags,
    var.database_subnet_cidrs_tags,
    {
      Name = "${var.project_name}-database-${local.azs_names[count.index]}"
    }
  )
}

## database subnet group ##

resource "aws_db_subnet_group" "default" {
  name       = "${local.resource_name}"
  subnet_ids = aws_subnet.database_subnet[*].id

  tags = merge (
    var.common_tags,
    var.database_subnet_cidrs_tags,
    {
      Name = "${var.project_name}-database-subnet-group"
    }
  )
}

## eip ##

resource "aws_eip" "nat" {
  domain   = "vpc"

  tags = merge (
    var.common_tags,
    var.elastic_ip_tags,
    {
    Name = "${var.project_name}-elastic_ip"
  }
  )
} 

## nat gateway ##

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = merge (
    var.common_tags,
    var.nat_gateway_tags,
    {
      Name = "${var.project_name}-nat-gateway"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}



## public route-table  ##

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.common_tags,
    var.public_route_table_tags,
    {
      Name = "${var.project_name}-public-route-table"
    }
  )
}


## private route-table  ##

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.common_tags,
    var.private_route_table_tags,
    {
      Name = "${var.project_name}-private-route-table"
    }
  )
}

## database route-table ##

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.common_tags,
    var.database_route_table_tags,
    {
      Name = "${var.project_name}-database-route-table"
    }
  )
}

## public route ##

resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

## private route ##

resource "aws_route" "private_route" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

## database route ##

resource "aws_route" "database_route" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

## public route table association

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

## private route table association

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}

## database route table association

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = element(aws_subnet.database_subnet[*].id, count.index)
  route_table_id = aws_route_table.database.id
}