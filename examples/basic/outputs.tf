output "load_balancer_id" {
  description = "Managed ALB ID."
  value       = module.alb.load_balancer_id
}

output "dns_name" {
  description = "ALB DNS name."
  value       = module.alb.dns_name
}
