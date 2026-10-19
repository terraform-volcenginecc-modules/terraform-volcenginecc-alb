variable "subnet_id" {
  type        = string
  description = "Existing subnet for the disposable public ALB."
}

variable "backend_instance_id" {
  type        = string
  description = "Existing ECS instance serving root, healthz, and api responses."
}

variable "cert_center_certificate_id" {
  type        = string
  description = "Existing active Certificate Center server certificate covering test_domain."
}

variable "test_domain" {
  type        = string
  description = "Certificate-covered domain used for Host and SNI validation."
}

variable "name_suffix" {
  type        = string
  description = "Unique suffix for all disposable QA resources."
  default     = "example"
}
