terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket = "tfstate-global-ahmed"
    key = "myapp/state.tfstate"
    region = "ap-south-1"
  }
}

provider "aws" {
    region = "ap-south-1"
}


resource "aws_vpc" "my-app-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

module "myapp-subnet" {
  source = "./modules/subnets"
  avail_zone = var.avail_zone
  subnet_cidr_block = var.subnet_cidr_block
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.my-app-vpc.id
  default_route_table_id = aws_vpc.my-app-vpc.default_route_table_id
}

module "myapp-webserver" {
  source = "./modules/webserver"
  vpc_id = aws_vpc.my-app-vpc.id
  env_prefix = var.env_prefix
  instance_type = var.instance_type
  ami = var.ami
  avail_zone = var.avail_zone
  subnet_id = module.myapp-subnet.subnet.id
  key_name = var.key_name
}


