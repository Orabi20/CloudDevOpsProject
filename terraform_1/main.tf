provider "aws" {
  region = var.region
}

module "network" {
  source              = "./modules/network"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
}

module "eks" {
  source                = "./modules/eks"
  cluster_name          = var.cluster_name
  subnet_ids            = module.network.public_subnet_ids
  eks_cluster_role_arn  = var.eks_cluster_role_arn
  eks_node_role_arn     = var.eks_node_role_arn
  node_instance_type    = var.node_instance_type
}

module "server" {
  source          = "./modules/server"
  vpc_id          = module.network.vpc_id
  subnet_ids      = module.network.public_subnet_ids
  public_key_path = var.public_key_path
}