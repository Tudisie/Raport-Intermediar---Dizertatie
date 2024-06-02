terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
  token = ""
}

module "networking" {
    source = "./networking"
    ec2_instance_id = module.ec2.instance_id
}

module "ec2" {
    source = "./ec2"
    nic_id = module.networking.backend_nic_id
}

module "s3" {
    source = "./s3"
}
