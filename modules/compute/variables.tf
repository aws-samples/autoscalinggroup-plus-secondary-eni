variable "project" {
  description = "The name of the project"
}

variable "environment" {
  description = "The deployment environment"
  
}

variable "region" {
  description = "The region where the project is deployed"
}

variable "instance_size" {
  description = "The size of the instance"


}

variable "instance_id" {
  description = "The ID of the AMI to be used in the launch configuration"


}


variable "public_subnets" {
  description = "Public Subnets created by networking module"
}

variable "private_subnets" {
  description = "private Subnets created by networking module"
}

variable "vpc_id" {
  description = "custom vpc id"
}

variable "sg_default" {
  description = "Default SG"
}
variable "management_sg" {
  description = "management SG"
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
