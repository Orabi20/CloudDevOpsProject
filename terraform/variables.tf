variable "region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "my-eks-cluster"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "node_instance_type" {
  default = "t3.medium"
}
variable "eks_cluster_role_arn" {
  description = "Existing IAM role ARN for EKS Cluster"
  type        = string
}

variable "eks_node_role_arn" {
  description = "Existing IAM role ARN for Node Group"
  type        = string
}