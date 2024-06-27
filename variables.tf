variable "project" {
  description = "The name of the project"
}

variable "environment" {
  description = "The deployment environment"
  default     = "dev"
}

variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  description = "CIDR blocks of public subnets"
}

variable "private_subnets_cidr" {
  description = "CIDR block of private subnets "
}

variable "management_subnets_cidr" {
  description = "CIDR block og management subnet"
}


variable "instance_size" {
  description = "The size of the instance"
  type        = string


}

variable "instance_id" {
  description = "The ID of the AMI to be used in the launch configuration"
  type        = string


}

variable "min_asg_size" {
  description = "min size"
}
variable "desired_asg_size" {
  description = "desired size"
}
variable "max_asg_size" {
  description = "max size"
}