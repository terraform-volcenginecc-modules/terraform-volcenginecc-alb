output "load_balancer_id" {
  description = "ID of the managed ALB instance."
  value       = volcenginecc_alb_load_balancer.this.load_balancer_id
}

output "dns_name" {
  description = "Provider-assigned ALB DNS name for DNS record targets."
  value       = volcenginecc_alb_load_balancer.this.dns_name
}

output "server_group_ids" {
  description = "Server group IDs keyed by the input logical keys."
  value = {
    for key, group in volcenginecc_alb_server_group.this : key => group.server_group_id
  }
}

output "listener_ids" {
  description = "Listener IDs keyed by the input logical keys."
  value = {
    for key, listener in volcenginecc_alb_listener.this : key => listener.listener_id
  }
}

output "rule_ids" {
  description = "Forwarding rule IDs keyed by the input logical keys."
  value = {
    for key, rule in volcenginecc_alb_rule.this : key => rule.rule_id
  }
}
