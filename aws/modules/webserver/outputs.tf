output "aws_ami_id" {
  value = data.aws_ami.latest_amazon_linux_ami.id
}

output "instance_public_ip" {
  value = aws_instance.myapp-server.public_ip
}