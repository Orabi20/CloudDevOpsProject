variable "cluster_name" {}
variable "subnet_ids" {
  type = list(string)
}
variable "eks_cluster_role_arn" {}
variable "eks_node_role_arn" {}
variable "node_instance_type" {}