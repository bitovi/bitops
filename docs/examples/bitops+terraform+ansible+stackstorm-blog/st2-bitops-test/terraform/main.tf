terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 3.0"
   }
 }
 backend "s3" {
   bucket = "st2-bitops-bucket"
   key    = "state"
 }
}
 
data "aws_region" "current" {}
 
resource "aws_vpc" "main" {
 cidr_block = "10.0.0.0/16"
}
 
resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.main.id
}
 
resource "aws_subnet" "main" {
 vpc_id            = aws_vpc.main.id
 cidr_block        = aws_vpc.main.cidr_block
 availability_zone = "${data.aws_region.current.name}b"
}
 
resource "aws_route_table" "rt" {
 vpc_id = aws_vpc.main.id
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gw.id
 }
}
 
resource "aws_route_table_association" "mfi_route_table_association" {
 subnet_id      = aws_subnet.main.id
 route_table_id = aws_route_table.rt.id
}
 
data "aws_ami" "ubuntu" {
 most_recent = true
 filter {
   name   = "name"
   values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
 }
 filter {
   name   = "virtualization-type"
   values = ["hvm"]
 }
 owners = ["099720109477"]
}
 
resource "tls_private_key" "key" {
 algorithm = "RSA"
 rsa_bits  = 4096
}
 
resource "aws_key_pair" "aws_key" {
 key_name   = "st2-bitops-ssh-key"
 public_key = tls_private_key.key.public_key_openssh
}
 
resource "aws_security_group" "allow_http" {
 name        = "allow_http"
 description = "Allow HTTP traffic"
 vpc_id      = aws_vpc.main.id
 ingress {
   description = "HTTP"
   from_port   = 80
   to_port     = 80
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }
 egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}
 
resource "aws_security_group" "allow_https" {
 name        = "allow_https"
 description = "Allow HTTPS traffic"
 vpc_id      = aws_vpc.main.id
 ingress {
   description = "HTTPS"
   from_port   = 443
   to_port     = 443
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }
 egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

resource "aws_security_group" "allow_ssh" {
 name        = "allow_ssh"
 description = "Allow SSH traffic"
 vpc_id      = aws_vpc.main.id
 ingress {
   description = "SSH"
   from_port   = 22
   to_port     = 22
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }
 egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}
 
resource "aws_instance" "server" {
 ami                         = data.aws_ami.ubuntu.id
 instance_type               = "t2.medium"
 key_name                    = aws_key_pair.aws_key.key_name
 associate_public_ip_address = true
 subnet_id                   = aws_subnet.main.id
 vpc_security_group_ids      = [aws_security_group.allow_http.id, aws_security_group.allow_https.id, aws_security_group.allow_ssh.id]
 
 tags = {
   Name = "BitOps - StackStorm test instance"
 }
}
