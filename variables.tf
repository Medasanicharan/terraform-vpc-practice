## Project ##

variable project_name {
    type = string
}

variable environment {
    type = string
}

variable common_tags {
    type = map
}

variable cidr_block {
    type = string
    default = "10.0.0.0/16"
}

## VPC ##

variable instance_tenancy {
    type = string
    default = "default"
}

variable enable_dns_hostnames {
    type = bool
    default = "true"
}

variable vpc_tags {
    type = map
    default = {}
}

## IGW ##

variable igw_tags {
    type = map
    default = {}
}

## public subnet ##

variable public_subnet_cidrs {
    type = list 
    validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "please provide 2 valid public subnet CIDR"
  }
}

variable public_subnet_cidrs_tags {
    type = map
    default = {}
}

## private subnet ##

variable private_subnet_cidrs {
    type = list 
    validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "please provide 2 valid private subnet CIDR"
  }
}

variable private_subnet_cidrs_tags {
    type = map
    default = {}
}

## database subnet ##

variable database_subnet_cidrs {
    type = list 
    validation {
    condition     = length(var.database_subnet_cidrs) == 2
    error_message = "please provide 2 valid database subnet CIDR"
  }
}

variable database_subnet_cidrs_tags {
    type = map
    default = {}
}

## nat gateway ##

variable nat_gateway_tags {
    type = map
    default = {}
}


## eip ##

variable elastic_ip_tags {
    type = map
    default = {}
}

## public route table ##

variable public_route_table_tags {
    type = map
    default = {}
}

## private route table ##

variable private_route_table_tags {
    type = map
    default = {}
}

## database route table ##

variable database_route_table_tags {
    type = map
    default = {}
}

## peering ##

variable is_peering_required {
    type = bool
    default = "false"
}

variable acceptor_vpc_id {
    type = string
    default = ""
}
