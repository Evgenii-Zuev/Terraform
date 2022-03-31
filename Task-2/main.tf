#----------------------------------------------------------
# Terraform
# Build WebServer and RDS
#----------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
    backend "s3" {
      bucket  = "tf-state-project"
      encrypt = true
      key     = "terraform.tfstate"
      region  = "eu-central-1"
    }
  required_version = "~>1.0"
}
provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Writer = "Eugene Zuev"
    }
  }
}
// VPC fnd SG for build EC2
data "aws_vpcs" "allow-vpcs" {}
data "aws_subnets" "allow-subnets" {
  filter {
    name   = "vpc-id"
    values = data.aws_vpcs.allow-vpcs.ids
  }
}
// Build EC2
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  #subnet_id              = data.aws_subnets.allow-subnets.ids[0]
  user_data = templatefile("user_data.sh.tpl", {})

  tags = {
    Name = "Web Server"
  }
  volume_tags = {
    "Owner" = "Eugene Zuev"
  }
}
data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
  owners = ["amazon"]
}
resource "aws_security_group" "web_server_sg" {
  name        = "WebServer Security Group"
  description = "My First SecurityGroup"
  dynamic "ingress" {
    for_each = ["80", "443", "3306"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "Web Server SG"
    Owner = "Eugene Zuev"
  }
}
module "rds" {
  source        = "./modules/rds"
  allow-subnets = data.aws_subnets.allow-subnets.ids
  allow-sg      = [aws_security_group.web_server_sg.id]

}
//**** variables.tf
variable "instance_type" {
  default     = "t3.micro"
  type        = string
  description = "EC2 Instance type"
}
// Output *********************
#**** outputs.tf
output "subnet_ec2_id" {
  value = data.aws_subnets.allow-subnets.ids[0]
}
output "security_group_ec2_id" {
  value = [aws_security_group.web_server_sg.id]
}
