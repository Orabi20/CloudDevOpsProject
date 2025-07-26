resource "aws_key_pair" "eks_key" {
  key_name   = "eks-keypair"
  public_key = file("~/.ssh/eks-keypair.pub")
}
