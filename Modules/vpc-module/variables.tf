variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, prod, sandbox)"
  type        = string
}

variable "Owner" {
  description = "The owner of the VPC"
  type        = string
}
