locals {
  tags = [
    for key, value in var.tags : {
      key   = key
      value = value
    }
  ]
}

resource "volcenginecc_alb_load_balancer" "this" {
  type                           = var.type
  address_ip_version             = var.address_ip_version
  load_balancer_name             = var.load_balancer_name
  description                    = var.description
  vpc_id                         = var.vpc_id
  load_balancer_billing_type     = var.load_balancer_billing_type
  load_balancer_edition          = var.load_balancer_edition
  delete_protection              = var.delete_protection
  project_name                   = var.project_name
  modification_protection_status = var.modification_protection_status
  modification_protection_reason = var.modification_protection_reason
  zone_mappings                  = var.zone_mappings
  eip_billing_config             = var.eip_billing_config
  tls_access_log                 = var.tls_access_log
  health_log                     = var.health_log
  tags                           = local.tags
}

resource "volcenginecc_alb_server_group" "this" {
  for_each = var.server_groups

  vpc_id                = var.vpc_id
  server_group_name     = each.value.name
  server_group_type     = each.value.type
  protocol              = each.value.protocol
  scheduler             = each.value.scheduler
  cross_zone_enabled    = each.value.cross_zone_enabled
  description           = each.value.description
  health_check          = each.value.health_check
  sticky_session_config = each.value.sticky_session_config
  servers = [
    for server in values(each.value.servers) : {
      instance_id    = server.instance_id
      ip             = server.private_ip
      port           = server.port
      type           = server.type
      weight         = server.weight
      description    = server.description
      remote_enabled = server.remote_enabled
    }
  ]
  tags = local.tags
}

resource "volcenginecc_alb_listener" "this" {
  for_each = var.listeners

  load_balancer_id                             = volcenginecc_alb_load_balancer.this.load_balancer_id
  listener_name                                = each.value.name
  protocol                                     = each.value.protocol
  port                                         = each.value.port
  enabled                                      = each.value.enabled
  description                                  = each.value.description
  server_group_id                              = volcenginecc_alb_server_group.this[each.value.default_server_group_key].server_group_id
  certificate_source                           = each.value.certificate_source
  certificate_id                               = each.value.certificate_id
  cert_center_certificate_id                   = each.value.cert_center_certificate_id
  pca_leaf_certificate_id                      = each.value.pca_leaf_certificate_id
  enable_http_2                                = each.value.enable_http_2
  enable_quic                                  = each.value.enable_quic
  access_log_record_customized_headers_enabled = each.value.access_log_record_customized_headers_enabled
  tags                                         = local.tags

  lifecycle {
    precondition {
      condition     = contains(keys(var.server_groups), each.value.default_server_group_key)
      error_message = "Every listener default_server_group_key must reference a key in server_groups."
    }
  }
}

resource "volcenginecc_alb_rule" "this" {
  for_each = var.rules

  listener_id     = volcenginecc_alb_listener.this[each.value.listener_key].listener_id
  priority        = each.value.priority
  description     = each.value.description
  rule_conditions = each.value.conditions
  rule_actions = [
    for action in each.value.actions : merge(
      { type = action.type },
      action.forward_server_groups == null ? {} : {
        forward_group_config = {
          server_group_tuples = [
            for target in action.forward_server_groups : {
              server_group_id = volcenginecc_alb_server_group.this[target.server_group_key].server_group_id
              weight          = target.weight
            }
          ]
        }
      },
      action.redirect == null ? {} : { redirect_config = action.redirect },
      action.rewrite_path == null ? {} : { rewrite_config = { path = action.rewrite_path } },
      action.traffic_limit_qps == null ? {} : { traffic_limit_config = { qps = action.traffic_limit_qps } }
    )
  ]

  lifecycle {
    precondition {
      condition     = contains(keys(var.listeners), each.value.listener_key)
      error_message = "Every rule listener_key must reference a key in listeners."
    }

    precondition {
      condition = alltrue(flatten([
        for action in each.value.actions : [
          action.type == "ForwardGroup" ? (
            action.forward_server_groups != null ? alltrue([
              for target in action.forward_server_groups :
              contains(keys(var.server_groups), target.server_group_key)
            ]) : false
          ) : true
        ]
      ]))
      error_message = "Every ForwardGroup target must reference a key in server_groups."
    }
  }
}
