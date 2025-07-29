output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "jenkins_master_ip" {
  value = module.server.jenkins_master_ip
}

output "jenkins_slave_ip" {
  value = module.server.jenkins_slave_ip
}