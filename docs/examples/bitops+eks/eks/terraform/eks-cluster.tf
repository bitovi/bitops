locals {
  cluster_name = "bitops-eks"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.17"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  manage_aws_auth = false
  worker_groups = [
    {
      name                          = "worker-group"
      instance_type                 = "t2.small"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_nodes.id]
    },
  ]
  node_groups = {
    test = {
      instance_type = "t3.small"
    }
  }
}
