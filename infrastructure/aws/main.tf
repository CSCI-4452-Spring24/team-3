provider "aws" {
  shared_config_files = ["./../.aws/config.txt"]
  profile             = "dev"
}

# get current region and az
data "aws_region" "current" {}
data "aws_availability_zones" "az" {
  state = "available"
}

# create vpc
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name      = "vpc-backstage"
    Terraform = true
  }
}

# create internet gateway
resource "aws_internet_gateway" "int-gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name      = "int-gw for ${aws_vpc.vpc.tags.Name}"
    Terraform = true
  }
}

#create public subnets 
resource "aws_subnet" "public_subnets" {
  for_each = var.public_subnets
  # every subnet will be provided in the second availability zone
  availability_zone       = tolist(data.aws_availability_zones.az.names)[1]
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, each.value)
  map_public_ip_on_launch = true
  tags = {
    Name              = each.key
    Availability_zone = tolist(data.aws_availability_zones.az.names)[1]
    Terraform         = true
  }
}

# create private subnets
resource "aws_subnet" "private_subnets" {
  for_each = var.private_subnets
  # every subnet will be provided in the first availability zone
  availability_zone = tolist(data.aws_availability_zones.az.names)[0]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, each.value + 100)
  tags = {
    Name              = each.key
    Availability_zone = tolist(data.aws_availability_zones.az.names)[0]
    Terraform         = true
  }
}

resource "aws_subnet" "public_backup_subnets" {
  for_each = var.public_backup_subnets
  # every subnet will be provided in the third availability zone
  availability_zone       = tolist(data.aws_availability_zones.az.names)[2]
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, each.value + 50)
  map_public_ip_on_launch = true
  tags = {
    Name              = each.key
    Availability_zone = tolist(data.aws_availability_zones.az.names)[2]
    Terrafom          = true
  }
}

# create a nat gateway
resource "aws_nat_gateway" "nat_gtw" {
  subnet_id         = aws_subnet.public_subnets["public_subnet_nat"].id
  connectivity_type = "private"
  tags = {
    Name      = "nat_gtw"
    Terraform = true
  }
}

# create security groups
resource "aws_security_group" "sg" {
  for_each    = var.security_groups
  vpc_id      = aws_vpc.vpc.id
  name        = each.key
  description = each.value
  tags = {
    Name     = each.key
    Terrafom = true
  }
}

# create and attach ingress rules between security groups 
resource "aws_vpc_security_group_ingress_rule" "ingress_rules_between_sg" {
  count                        = length(var.ingress_rules_between_sg)
  description                  = var.ingress_rules_between_sg[count.index].description
  security_group_id            = aws_security_group.sg["${var.ingress_rules_between_sg[count.index].security_group}"].id
  ip_protocol                  = var.ingress_rules_between_sg[count.index].protocol
  from_port                    = var.ingress_rules_between_sg[count.index].from_port
  to_port                      = var.ingress_rules_between_sg[count.index].to_port
  referenced_security_group_id = aws_security_group.sg["${var.ingress_rules_between_sg[count.index].referenced_security_group}"].id
  tags = {
    Name      = var.ingress_rules_between_sg[count.index].name
    Terraform = true
  }
}

# create and attach egress rules between security groups
resource "aws_vpc_security_group_egress_rule" "egress_rules_between_sg" {
  count                        = length(var.egress_rules_between_sg)
  description                  = var.egress_rules_between_sg[count.index].description
  security_group_id            = aws_security_group.sg["${var.egress_rules_between_sg[count.index].security_group}"].id
  ip_protocol                  = var.egress_rules_between_sg[count.index].protocol
  from_port                    = var.egress_rules_between_sg[count.index].from_port
  to_port                      = var.egress_rules_between_sg[count.index].to_port
  referenced_security_group_id = aws_security_group.sg["${var.egress_rules_between_sg[count.index].referenced_security_group}"].id
  tags = {
    Name      = var.egress_rules_between_sg[count.index].name
    Terraform = true
  }
}

# create and attach ingress rules between security groups and igw
resource "aws_vpc_security_group_ingress_rule" "ingress_rules_between_sg_and_igw" {
  count             = length(var.ingress_rules_between_sg_and_igw)
  description       = var.ingress_rules_between_sg_and_igw[count.index].description
  security_group_id = aws_security_group.sg["${var.ingress_rules_between_sg_and_igw[count.index].security_group}"].id
  ip_protocol       = var.ingress_rules_between_sg_and_igw[count.index].protocol
  from_port         = var.ingress_rules_between_sg_and_igw[count.index].from_port
  to_port           = var.ingress_rules_between_sg_and_igw[count.index].to_port
  cidr_ipv4         = aws_vpc.vpc.cidr_block
  tags = {
    Name     = var.egress_rules_between_sg_and_igw[count.index].name
    Terrafom = true
  }
}

# create and attach ingress rules between security groups and igw
resource "aws_vpc_security_group_egress_rule" "egress_rules_between_sg_and_igw" {
  count             = length(var.egress_rules_between_sg_and_igw)
  description       = var.egress_rules_between_sg_and_igw[count.index].description
  security_group_id = aws_security_group.sg["${var.egress_rules_between_sg_and_igw[count.index].security_group}"].id
  ip_protocol       = var.egress_rules_between_sg_and_igw[count.index].protocol
  from_port         = var.egress_rules_between_sg_and_igw[count.index].from_port
  to_port           = var.egress_rules_between_sg_and_igw[count.index].to_port
  cidr_ipv4         = aws_vpc.vpc.cidr_block
  tags = {
    Name     = var.egress_rules_between_sg_and_igw[count.index].name
    Terrafom = true
  }
}

# special case
# an egress rule for the backend to the nat gateway subnet
resource "aws_vpc_security_group_egress_rule" "from_backend_sg_to_nat" {
  security_group_id = aws_security_group.sg["backend-sg"].id
  description       = "Rule to send traffic from the backend sg to the nat subnet"
  ip_protocol       = "tcp"
  from_port         = 1024
  to_port           = 65535
  cidr_ipv4         = aws_subnet.public_subnets["public_subnet_nat"].cidr_block
  tags = {
    Name      = "backend sg -> nat subnet"
    Terraform = true
  }
}

# group subnets for auth db 
resource "aws_db_subnet_group" "auth_db_subnet_group" {
  name        = "auth db subnet group"
  description = "subnet group for the auth db"
  subnet_ids  = [aws_subnet.public_subnets["public_subnet_auth_db"].id, aws_subnet.public_backup_subnets["public_backup_subnet_1"].id]
  tags = {
    Name     = "auth db subnet group"
    Terrafom = true
  }
}

# auth db
resource "aws_db_instance" "auth_db" {
  depends_on             = [aws_internet_gateway.int-gw]
  db_name                = "auth_db"
  identifier             = "team3-backstage-auth-db"
  db_subnet_group_name   = aws_db_subnet_group.auth_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.sg["auth-db-sg"].id]
  allocated_storage      = 20
  engine                 = "postgres"
  port                   = 5432
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  username               = var.AUTH_DB_USERNAME
  password               = var.AUTH_DB_PASSWORD
  multi_az               = false
  publicly_accessible    = true
  apply_immediately      = true
  skip_final_snapshot    = true
  tags = {
    Name = "auth_db"
  }
}