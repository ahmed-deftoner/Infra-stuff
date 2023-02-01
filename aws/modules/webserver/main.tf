resource "aws_default_security_group" "default-sg" {
  vpc_id = var.vpc_id

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
    values = [var.ami]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest_amazon_linux_ami.id
  instance_type = var.instance_type

  availability_zone = var.avail_zone
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  subnet_id = var.subnet_id

  associate_public_ip_address = true
  key_name = var.key_name

  user_data = file("entry.sh")

  tags = {
    Name = "${var.env_prefix}-server"
  }
}