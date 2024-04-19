variable "public_subnets" {
  default = {
    "public_subnet_nat"     = 1
    "public_subnet_elb"     = 2
    "public_subnet_auth_db" = 3
  }
}

variable "private_subnets" {
  default = {
    "private_subnet_instance_1" = 1
    "private_subnet_instance_2" = 2
    "private_subnet_app_db"     = 3
  }
}

variable "public_backup_subnets" {
  default = {
    "public_backup_subnet_1" = 1
  }

}

variable "security_groups" {
  default = {
    "app-db-sg"  = "security group for the database subnet"
    "auth-db-sg" = "security group for the auth db subnet"
    "backend-sg" = "security group for the backend subnets"
    "lb-sg"      = "security group for the lb subnet"
  }
}

variable "ingress_rules_between_sg" {
  type = list(object({
    name                      = string
    description               = string
    security_group            = string
    protocol                  = string
    from_port                 = number
    to_port                   = number
    referenced_security_group = string
  }))
  default = [
    {
      name                      = "app db sg <- backend sg"
      description               = "Rule to accept traffic from the backend sg into app db sg"
      security_group            = "app-db-sg"
      protocol                  = "tcp"
      from_port                 = 5432
      to_port                   = 5432
      referenced_security_group = "backend-sg"
    },
    {
      name                      = "backend sg <- lb"
      description               = "Rule to accept traffic from the lb into the backend sg"
      security_group            = "backend-sg"
      protocol                  = "tcp"
      from_port                 = 0
      to_port                   = 65535
      referenced_security_group = "lb-sg"
    },
    {
      name                      = "backend sg <- app db sg"
      description               = "Rule to accept traffic from the app db sg into the backend sg"
      security_group            = "backend-sg"
      protocol                  = "tcp"
      from_port                 = 5432
      to_port                   = 5432
      referenced_security_group = "app-db-sg"
    }
  ]
}

variable "egress_rules_between_sg" {
  type = list(object({
    name                      = string
    description               = string
    security_group            = string
    protocol                  = string
    from_port                 = number
    to_port                   = number
    referenced_security_group = string
  }))
  default = [
    {
      name                      = "app db sg -> backend sg"
      description               = "Rule to send traffic from the app db sg to the backend sg"
      security_group            = "app-db-sg"
      protocol                  = "tcp"
      from_port                 = 5432
      to_port                   = 5432
      referenced_security_group = "backend-sg"
    },
    {
      name                      = "backend sg -> app db sg"
      description               = "Rule to send traffic from the backend sg to the app db sg"
      security_group            = "backend-sg"
      protocol                  = "tcp"
      from_port                 = 5432
      to_port                   = 5432
      referenced_security_group = "app-db-sg"
    }
  ]
}

variable "ingress_rules_between_sg_and_igw" {
  type = list(object({
    name           = string
    description    = string
    security_group = string
    protocol       = string
    from_port      = number
    to_port        = number
  }))
  default = [
    {
      name           = "auth db sg <- internet"
      description    = "Rule to accept traffic from the internet to the auth db sg"
      security_group = "auth-db-sg"
      protocol       = "tcp"
      from_port      = 5432
      to_port        = 5432
    }
  ]
}

variable "egress_rules_between_sg_and_igw" {
  type = list(object({
    name           = string
    description    = string
    security_group = string
    protocol       = string
    from_port      = number
    to_port        = number
  }))
  default = [
    {
      name           = "auth db sg -> internet"
      description    = "Rule to send traffic from the auth db sg to the internet"
      security_group = "auth-db-sg"
      protocol       = "tcp"
      from_port      = 5432
      to_port        = 5432
    }
  ]
}

variable "AUTH_DB_USERNAME" {
  description = "username for auth db"
  type        = string
  nullable    = false
}

variable "AUTH_DB_PASSWORD" {
  description = "password for auth db"
  type        = string
  sensitive   = true
  nullable    = false
}
