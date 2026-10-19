variable "load_balancer_name" {
  type        = string
  description = "Name of the managed ALB instance."

  validation {
    condition     = length(trimspace(var.load_balancer_name)) >= 1 && length(var.load_balancer_name) <= 128
    error_message = "load_balancer_name must contain between 1 and 128 characters."
  }
}

variable "vpc_id" {
  type        = string
  description = "Existing VPC ID. Changing it replaces the ALB instance and every managed server group."

  validation {
    condition     = length(trimspace(var.vpc_id)) > 0
    error_message = "vpc_id must not be empty."
  }
}

variable "zone_mappings" {
  type = set(object({
    zone_id   = string
    subnet_id = string
  }))
  description = "Existing subnets keyed by their availability zones. Every mapping is create-only."

  validation {
    condition     = length(var.zone_mappings) > 0
    error_message = "At least one zone mapping is required."
  }
}

variable "type" {
  type        = string
  description = "ALB network type: public or private. Public ALBs expose an internet entry point."
  default     = "private"

  validation {
    condition     = contains(["public", "private"], var.type)
    error_message = "type must be public or private."
  }
}

variable "address_ip_version" {
  type        = string
  description = "ALB IP address version."
  default     = "IPv4"

  validation {
    condition     = contains(["IPv4", "DualStack"], var.address_ip_version)
    error_message = "address_ip_version must be IPv4 or DualStack."
  }
}

variable "load_balancer_edition" {
  type        = string
  description = "ALB edition. Standard is required for condition-based routing and multiple rule actions."
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.load_balancer_edition)
    error_message = "load_balancer_edition must be Basic or Standard."
  }
}

variable "load_balancer_billing_type" {
  type        = number
  description = "ALB billing type. The Provider currently supports only pay-as-you-go value 1."
  default     = 1

  validation {
    condition     = var.load_balancer_billing_type == 1
    error_message = "load_balancer_billing_type must be 1."
  }
}

variable "description" {
  type        = string
  description = "ALB instance description."
  default     = ""
}

variable "project_name" {
  type        = string
  description = "Project name for the ALB. Changing it replaces the ALB instance."
  default     = "default"
}

variable "delete_protection" {
  type        = string
  description = "Delete protection switch."
  default     = "off"

  validation {
    condition     = contains(["on", "off"], var.delete_protection)
    error_message = "delete_protection must be on or off."
  }
}

variable "modification_protection_status" {
  type        = string
  description = "Console modification protection status."
  default     = "NonProtection"

  validation {
    condition     = contains(["NonProtection", "ConsoleProtection"], var.modification_protection_status)
    error_message = "modification_protection_status must be NonProtection or ConsoleProtection."
  }
}

variable "modification_protection_reason" {
  type        = string
  description = "Reason for console modification protection."
  default     = null
  nullable    = true
}

variable "eip_billing_config" {
  type = object({
    isp                             = optional(string)
    billing_type                    = optional(number)
    bandwidth                       = optional(number)
    security_protection_types       = optional(string)
    security_protection_instance_id = optional(number)
  })
  description = "Optional public IPv4 EIP billing configuration. Use only for public ALBs."
  default     = null
  nullable    = true
}

variable "tls_access_log" {
  type = object({
    enabled    = bool
    project_id = optional(string)
    topic_id   = optional(string)
  })
  description = "Optional TLS access-log destination. The caller owns the TLS project and topic."
  default     = null
  nullable    = true
}

variable "health_log" {
  type = object({
    enabled    = bool
    project_id = optional(string)
    topic_id   = optional(string)
  })
  description = "Optional TLS health-check-log destination. The caller owns the TLS project and topic."
  default     = null
  nullable    = true
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the ALB, server groups, and listeners."
  default     = {}
}

variable "server_groups" {
  type = map(object({
    name               = string
    type               = optional(string, "instance")
    protocol           = optional(string, "HTTP")
    scheduler          = optional(string, "wrr")
    cross_zone_enabled = optional(string, "on")
    description        = optional(string, "")
    health_check = optional(object({
      enabled             = optional(string, "on")
      port                = optional(number, 0)
      interval            = optional(number, 2)
      timeout             = optional(number, 2)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
      method              = optional(string, "GET")
      http_version        = optional(string, "HTTP1.1")
      uri                 = optional(string, "/")
      http_code           = optional(string, "http_2xx")
    }))
    sticky_session_config = optional(object({
      sticky_session_enabled = optional(string, "off")
      sticky_session_type    = optional(string)
      cookie_timeout         = optional(number)
      cookie                 = optional(string)
    }))
    servers = map(object({
      instance_id    = string
      private_ip     = string
      port           = number
      type           = optional(string, "ecs")
      weight         = optional(number, 100)
      description    = optional(string, "")
      remote_enabled = optional(string, "off")
    }))
  }))
  description = "Server groups keyed by stable logical names. A key change changes the Terraform address."
  default     = {}

  validation {
    condition     = alltrue([for group in values(var.server_groups) : contains(["instance", "ip"], group.type) && contains(["HTTP", "HTTPS"], group.protocol) && contains(["wrr", "wlc", "sh"], group.scheduler)])
    error_message = "Server group type, protocol, and scheduler must use supported ALB values."
  }

  validation {
    condition = alltrue(flatten([
      for group in values(var.server_groups) : [
        for server in values(group.servers) : length(trimspace(server.instance_id)) > 0 && can(cidrhost("${server.private_ip}/32", 0)) && server.port >= 1 && server.port <= 65535 && contains(["ecs", "eni", "ip"], server.type) && server.weight >= 0 && server.weight <= 100
      ]
    ]))
    error_message = "Every server needs an ID, IPv4 private IP, valid port, supported type, and weight between 0 and 100."
  }
}

variable "listeners" {
  type = map(object({
    name                                         = string
    protocol                                     = string
    port                                         = number
    default_server_group_key                     = string
    enabled                                      = optional(string, "on")
    description                                  = optional(string, "")
    certificate_source                           = optional(string)
    certificate_id                               = optional(string)
    cert_center_certificate_id                   = optional(string)
    pca_leaf_certificate_id                      = optional(string)
    enable_http_2                                = optional(string)
    enable_quic                                  = optional(string)
    access_log_record_customized_headers_enabled = optional(string)
  }))
  description = "HTTP or HTTPS listeners keyed by stable logical names. Certificates are caller-owned IDs."
  default     = {}

  validation {
    condition     = alltrue([for listener in values(var.listeners) : contains(["HTTP", "HTTPS"], listener.protocol) && listener.port >= 1 && listener.port <= 65535])
    error_message = "Listeners must use HTTP or HTTPS and a valid port."
  }

  validation {
    condition = alltrue([
      for listener in values(var.listeners) : listener.protocol != "HTTPS" || (
        listener.certificate_source != null && (
          listener.certificate_source == "alb" && listener.certificate_id != null ||
          listener.certificate_source == "cert_center" && listener.cert_center_certificate_id != null ||
          listener.certificate_source == "pca_leaf" && listener.pca_leaf_certificate_id != null
        )
      )
    ])
    error_message = "HTTPS listeners require a certificate_source and its matching certificate ID."
  }
}

variable "rules" {
  type = map(object({
    listener_key = string
    priority     = number
    description  = optional(string, "")
    conditions = set(object({
      type = string
      host_config = optional(object({
        values = set(string)
      }))
      path_config = optional(object({
        values = set(string)
      }))
      header_config = optional(object({
        key    = string
        values = set(string)
      }))
      method_config = optional(object({
        values = set(string)
      }))
    }))
    actions = list(object({
      type = string
      forward_server_groups = optional(set(object({
        server_group_key = string
        weight           = number
      })))
      redirect = optional(object({
        protocol  = optional(string)
        host      = optional(string)
        port      = optional(string)
        path      = optional(string)
        http_code = optional(string)
      }))
      rewrite_path      = optional(string)
      traffic_limit_qps = optional(number)
    }))
  }))
  description = "Standard ALB rules keyed by stable logical names. Conditions support Host, Path, Header, and Method; actions support ForwardGroup, Redirect, Rewrite, and TrafficLimit."
  default     = {}

  validation {
    condition     = alltrue([for rule in values(var.rules) : length(rule.conditions) > 0 && length(rule.actions) > 0])
    error_message = "Every rule must include conditions and actions."
  }

  validation {
    condition = alltrue([
      for listener_key in distinct([for rule in values(var.rules) : rule.listener_key]) :
      length([
        for rule in values(var.rules) : rule.priority
        if rule.listener_key == listener_key
        ]) == length(toset([
          for rule in values(var.rules) : rule.priority
          if rule.listener_key == listener_key
      ]))
    ])
    error_message = "Rule priorities must be unique within each listener."
  }

  validation {
    condition = alltrue(flatten([
      for rule in values(var.rules) : [
        for action in rule.actions : (
          action.type == "ForwardGroup" ? (
            action.forward_server_groups != null ? alltrue([
              for target in action.forward_server_groups : target.weight >= 0 && target.weight <= 100
            ]) : false
            ) : (
            action.type == "Redirect" && action.redirect != null ||
            action.type == "Rewrite" && action.rewrite_path != null ||
            action.type == "TrafficLimit" && action.traffic_limit_qps != null
          )
        )
      ]
    ]))
    error_message = "Each rule action must have a matching configuration and forward target weights must be between 0 and 100."
  }
}
