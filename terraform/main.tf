terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "your-s3-bucket-name"  # Specify your S3 bucket name
    key    = "aws/ec2-deploy/terraform.tfstate"
    region = "us-west-2"  # Specify your AWS region
  }
}

provider "aws" {
  region = var.region
}

resource "aws_key_pair" "deploy" {
  key_name   = var.key_name
  public_key = var.public_key
}

resource "aws_security_group" "maingroup" {
  name        = "maingroup"
  description = "Security group that allows all inbound and outbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "server" {
  ami                    = "ami-01e444924a2233b07"
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2profile.name  # Corrected reference
  key_name               = aws_key_pair.deploy.key_name
  vpc_security_group_ids = [aws_security_group.maingroup.id]

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = var.private_key
    timeout     = "4m"
  }

  tags = {
    Name = "DeployVM"
  }
}

resource "aws_iam_instance_profile" "ec2profile" {  # Corrected resource name
  name = "EC2-Profile"
  role = "EC2-ECR-ROLE"
}

output "instance_public_ip" {
  value     = aws_instance.server.public_ip
  sensitive = true
}
