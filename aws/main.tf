provider "aws" {
    region = "ap-south-1"
}

variable "avail_zone" {}
variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "env_prefix" {}
variable "instance_type" {}

resource "aws_vpc" "my-app-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "my-app-subnet-1" {
  vpc_id = aws_vpc.my-app-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet"
  }
}

resource "aws_internet_gateway" "my-app-igw" {
  vpc_id = aws_vpc.my-app-vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.my-app-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-app-igw.id
  }

  tags = {
    Name = "${var.env_prefix}-main-rbt"
  }
}

resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.my-app-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.env_prefix}-default-sg"
  }
}

data "aws_ami" "latest_amazon_linux_ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

output "aws_ami_id" {
  value = data.aws_ami.latest_amazon_linux_ami.id
}

resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest_amazon_linux_ami.id
  instance_type = var.instance_type

  availability_zone = var.avail_zone
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  subnet_id = aws_subnet.my-app-subnet-1.id

  associate_public_ip_address = true
  key_name = "haha"

  tags = {
    Name = "${var.env_prefix}-server"
  }
}

