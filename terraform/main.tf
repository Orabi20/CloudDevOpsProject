provider "aws" {
  region = var.region
}
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and Jenkins UI"
  vpc_id      = aws_vpc.eks_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins Web UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "jenkins_master" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.public_subnets[0].id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  key_name                    = aws_key_pair.eks_key.key_name
  associate_public_ip_address = true
  monitoring                  = true

  tags = {
    Name = "jenkins-master"
  }
}

resource "aws_instance" "jenkins_slave" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.public_subnets[1].id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  key_name                    = aws_key_pair.eks_key.key_name
  associate_public_ip_address = true
  monitoring                  = true

  tags = {
    Name = "jenkins-slave"
  }
}
