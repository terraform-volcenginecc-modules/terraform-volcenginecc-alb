output "load_balancer_id" {
  description = "Managed ALB ID."
  value       = module.alb.load_balancer_id
}

output "dns_name" {
  description = "Create a DNS record outside this module with this target."
  value       = module.alb.dns_name
}
