resource "aws_subnet" "pub_subnet" {
  count                   = length(var.pub_sub_cidr)
  vpc_id                  = var.vpc_id
  availability_zone       = element(var.azs, count.index)
  cidr_block              = element(var.pub_sub_cidr, count.index)
  map_public_ip_on_launch = true
  tags = merge(local.common_tags, {
    Name = "pub-subnet-${count.index}"
  })
}

resource "aws_subnet" "priv_subnet" {
  count                   = length(var.priv_sub_cidr)
  vpc_id                  = var.vpc_id
  availability_zone       = element(var.azs, count.index)
  cidr_block              = element(var.priv_sub_cidr, count.index)
  map_public_ip_on_launch = false
  tags = merge(local.common_tags, {
    Name = "priv-subnet-${count.index}"
  })
}

resource "aws_route_table" "pub_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "pub_rt_association" {
  count          = length(var.pub_sub_cidr)
  subnet_id      = aws_subnet.pub_subnet[count.index].id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "priv_rt_association" {
  count          = length(var.priv_sub_cidr)
  subnet_id      = aws_subnet.priv_subnet[count.index].id
  route_table_id = aws_route_table.pub_rt.id
}


resource "aws_route_table" "priv_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name = "private-rt"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pub_subnet[0].id

  tags = {
    Name = "gw NAT"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "eip" {
  domain = "vpc"
}


resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "IGW-${var.environment}"
  }
}