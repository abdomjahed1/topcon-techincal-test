terraform {
  required_version = ">= 1.5.0"
}

module "vpc" {
  source = "./modules/networks"
}

module "eks" {
  source = "./modules/eks"

  aws_region         = var.aws_region
  cluster_name       = var.cluster_name

  private_subnet_ids = module.vpc.private_subnets

  eks_aws_iam_role        = "prueba-it-eks-cluster-role"
  node_group_aws_iam_role = "prueba-it-eks-node-role"
  node_group_name         = "prueba-it-eks-ng"

  ebs_role_name = "prueba-it-ebs-csi-role"
}

module "rds" {
  source = "./modules/rds"

  private_subnet_ids = module.vpc.private_subnets
  vpc_id             = module.vpc.vpc_id
  eks_node_sg_id     = module.eks.node_sg_id

  db_username = var.db_username
  db_name     = var.db_name
}

module "route53" {
  source      = "./modules/route53"
  domain_name = var.domain_name
}

module "ecr" {
  source = "./modules/ecr"
  name   = var.ecr_name
}

module "monitoring" {
  source = "./modules/monitoring"

  alert_email    = var.alert_email
  cluster_name   = var.cluster_name
  rds_identifier = "prueba-it-rds"
  aws_region     = var.aws_region
}

output "eks_cluster_name" {
  value = var.cluster_name
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "rds_secret_arn" {
  value = module.rds.secret_arn
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "rds_secret_name" {
  value = module.rds.secret_name
}
