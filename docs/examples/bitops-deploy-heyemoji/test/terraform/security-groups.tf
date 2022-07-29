/* local vars */
locals {
  aws_tags = {
    RepoName = " mmcdole/heyemoji"
    OpsRepoEnvironment = "blog-test"
    OpsRepoApp = "heyemoji-blog"
  }
}


resource "aws_security_group" "allow_traffic" {
  name        = "allow_traffic"
  description = "Allow traffic"
  vpc_id      = aws_vpc.main.id
  ingress = [{
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = null
    prefix_list_ids = null
    security_groups = null
    self = null

  },{
    description = "WEBSOCKET"
    from_port   = 3334
    to_port     = 3334
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = null
    prefix_list_ids = null
    security_groups = null
    self = null
  }]
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.aws_tags,{
    Name = "heyemoji-blog-sg"
  })
}