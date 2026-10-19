variable "vpc_id" {
  type        = string
  description = "Existing VPC ID."
}

variable "zone_id" {
  type        = string
  description = "Availability zone ID for the ALB subnet."
}

variable "subnet_id" {
  type        = string
  description = "Existing subnet ID for the ALB."
}

variable "backend_instance_id" {
  type        = string
  description = "Existing ECS instance ID."
}

variable "backend_private_ip" {
  type        = string
  description = "Private IPv4 address of the backend instance."
}
