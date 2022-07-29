resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "aws_key" {
  key_name   = "heyemoji-blog-ssh-key"
  public_key = tls_private_key.key.public_key_openssh
}

resource "aws_instance" "server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.aws_key.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.allow_traffic.id]
  monitoring                  = true

  tags = {
    Name = "HeyEmoji-blog"
  }
}