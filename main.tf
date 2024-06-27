terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.2.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = var.region
}

provider "archive" {}

module "networking" {
  source                  = "./modules/networking"
  project                 = var.project
  environment             = var.environment
  region                  = var.region
  vpc_cidr                = var.vpc_cidr
  public_subnets_cidr     = var.public_subnets_cidr
  private_subnets_cidr    = var.private_subnets_cidr
  management_subnets_cidr = var.management_subnets_cidr
}

module "compute" {
  source           = "./modules/compute"
  project          = var.project
  environment      = var.environment
  region           = var.region
  instance_id      = var.instance_id
  instance_size    = var.instance_size
  min_asg_size     = var.min_asg_size
  desired_asg_size = var.desired_asg_size
  max_asg_size     = var.max_asg_size
  public_subnets   = module.networking.public_subnets
  private_subnets  = module.networking.private_subnets
  vpc_id           = module.networking.vpc_id
  sg_default       = module.networking.sg_default
  management_sg    = module.networking.management_sg

  depends_on = [
    module.networking.public_subnets,
    module.networking.igw
  ]
}


module "lambda" {
  source = "./modules/lambda"

  project     = var.project
  environment = var.environment
  region_used = var.region
  asg         = module.compute.asg

  depends_on = [
    module.compute.asg
  ]
}

