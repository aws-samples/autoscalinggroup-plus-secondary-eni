variable "project" {
  description = "The name of the project"
}

variable "environment" {
  description = "The deployment environment"

}

variable "region" {
  description = "The region where the project is deployed"
}

variable "vpc_cidr" {
  description = "Cidr range for the custom vpc"
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





