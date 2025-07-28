data "aws_iam_role" "eks_cluster_role" {
  name = "c165670a4268463l10958353t1w289222-LabEksClusterRole-eaUNkuhnJ3fw"
}

data "aws_iam_role" "eks_node_role" {
  name = "c165670a4268463l10958353t1w289222951-LabEksNodeRole-nJPNg6WDXeUU"
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids = aws_subnet.public_subnets[*].id
  }

  depends_on = []
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = aws_subnet.public_subnets[*].id

  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 2
  }

  instance_types = [var.node_instance_type]

  depends_on = []
}
