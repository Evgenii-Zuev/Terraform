#----------------------------------------------------------
# Terraform
# Output different wariables (for training)
#----------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
provider "aws" {
  region = "eu-central-1"
}
# Data ***********************************
data "aws_availability_zones" "available" {}
data "aws_vpcs" "allow-vpcs" {}
data "aws_subnets" "allow-subnets" {
  filter {
    name   = "vpc-id"
    values = data.aws_vpcs.allow-vpcs.ids
  }
}
data "aws_security_groups" "allow-sg" {
  filter {
    name   = "vpc-id"
    values = data.aws_vpcs.allow-vpcs.ids
  }
}
# Outputs ********************************
output "available_AZs_names" {
  value = data.aws_availability_zones.available.names[*]
}
output "available_AZs_ids" {
  value = data.aws_availability_zones.available.zone_ids[*]
}
output "allow-vpcs" {
  value = data.aws_vpcs.allow-vpcs.ids
}
output "allow-subnets" {
  value = data.aws_subnets.allow-subnets.ids
}
output "allow-sg" {
  value = data.aws_security_groups.allow-sg
}
