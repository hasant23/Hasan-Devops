terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "jenkins-project-backend-hasan"
    key    = "backend/tf-backend-jenkins.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "tags" {
  default = ["postgresql", "nodejs", "react"]
}

resource "aws_iam_role" "aws_access2" {
  name = "awsrole2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"]

}

resource "aws_iam_instance_profile" "ec2-profile2" {
  name = "jenkins-project-profile2"
  role = aws_iam_role.aws_access2.name
}

resource "aws_instance" "managed_nodes" {
  ami                    = "ami-0f095f89ae15be883"
  count                  = 3
  instance_type          = "t2.micro"
  key_name               = "hasan"
  vpc_security_group_ids = [aws_security_group.tf-sec-gr.id]
  iam_instance_profile   = "jenkins-project-profile2"
  tags = {
    Name        = "ansible_${element(var.tags, count.index)}"
    stack       = "ansible_project"
    environment = "development"
  }
}

variable "sg-ports" {
  default = [22, 5000, 3000, 5432]
}

resource "aws_security_group" "tf-sec-gr" {
  name = "project208-sec-gr"
  tags = {
    Name = "project208-sec-gr"
  }
  dynamic "ingress" {
    for_each = var.sg-ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "react_ip" {
  value = "http://${aws_instance.managed_nodes[2].public_ip}:3000"
}

output "node_public_ip" {
  value = aws_instance.managed_nodes[1].public_ip
}

output "postgre_private_ip" {
  value = aws_instance.managed_nodes[0].private_ip
}




















