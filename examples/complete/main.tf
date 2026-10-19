data "volcenginecc_vpc_subnet" "target" {
  id = var.subnet_id
}

data "volcenginecc_ecs_instance" "backend" {
  id = var.backend_instance_id
}

resource "volcenginecc_tls_project" "qa" {
  project_name     = "tf-alb-qa-${var.name_suffix}"
  description      = "Disposable ALB QA logs"
  iam_project_name = "default"

  tags = [
    {
      key   = "purpose"
      value = "terraform-alb-qa"
    },
    {
      key   = "temporary"
      value = "true"
    }
  ]
}

resource "volcenginecc_tls_topic" "access" {
  project_id  = volcenginecc_tls_project.qa.project_id
  topic_name  = "alb-access"
  description = "Disposable ALB QA access logs"
  shard_count = 1
  ttl         = 1

  tags = [
    {
      key   = "purpose"
      value = "terraform-alb-qa"
    },
    {
      key   = "temporary"
      value = "true"
    }
  ]
}

resource "volcenginecc_tls_topic" "health" {
  project_id  = volcenginecc_tls_project.qa.project_id
  topic_name  = "alb-health"
  description = "Disposable ALB QA health-check logs"
  shard_count = 1
  ttl         = 1

  tags = [
    {
      key   = "purpose"
      value = "terraform-alb-qa"
    },
    {
      key   = "temporary"
      value = "true"
    }
  ]
}

module "alb" {
  source  = "terraform-volcenginecc-modules/alb/volcenginecc"
  version = "~> 1.0"

  load_balancer_name    = "tf-alb-qa-${var.name_suffix}"
  type                  = "public"
  address_ip_version    = "IPv4"
  load_balancer_edition = "Standard"
  description           = "Disposable Terraform ALB QA instance"
  vpc_id                = data.volcenginecc_vpc_subnet.target.vpc_id
  eip_billing_config = {
    isp          = "BGP"
    billing_type = 3
    bandwidth    = 1
  }
  zone_mappings = [{
    zone_id   = data.volcenginecc_vpc_subnet.target.zone_id
    subnet_id = var.subnet_id
  }]
  delete_protection = "off"
  tls_access_log = {
    enabled    = true
    project_id = volcenginecc_tls_project.qa.project_id
    topic_id   = volcenginecc_tls_topic.access.topic_id
  }
  health_log = {
    enabled    = true
    project_id = volcenginecc_tls_project.qa.project_id
    topic_id   = volcenginecc_tls_topic.health.topic_id
  }

  server_groups = {
    web = {
      name = "tf-alb-web-${var.name_suffix}"
      health_check = {
        uri       = "/healthz"
        http_code = "http_2xx"
      }
      servers = {
        backend = {
          instance_id = var.backend_instance_id
          private_ip  = data.volcenginecc_ecs_instance.backend.primary_network_interface.primary_ip_address
          port        = 8080
        }
      }
    }
    canary = {
      name = "tf-alb-canary-${var.name_suffix}"
      health_check = {
        uri       = "/healthz"
        http_code = "http_2xx"
      }
      servers = {
        backend = {
          instance_id = var.backend_instance_id
          private_ip  = data.volcenginecc_ecs_instance.backend.primary_network_interface.primary_ip_address
          port        = 8080
        }
      }
    }
    api = {
      name = "tf-alb-api-${var.name_suffix}"
      health_check = {
        uri       = "/healthz"
        http_code = "http_2xx"
      }
      servers = {
        backend = {
          instance_id = var.backend_instance_id
          private_ip  = data.volcenginecc_ecs_instance.backend.primary_network_interface.primary_ip_address
          port        = 8080
        }
      }
    }
  }

  listeners = {
    http = {
      name                     = "tf-alb-http-${var.name_suffix}"
      protocol                 = "HTTP"
      port                     = 80
      default_server_group_key = "web"
    }
    https = {
      name                       = "tf-alb-https-${var.name_suffix}"
      protocol                   = "HTTPS"
      port                       = 443
      default_server_group_key   = "web"
      certificate_source         = "cert_center"
      cert_center_certificate_id = var.cert_center_certificate_id
      enable_http_2              = "off"
    }
  }

  rules = {
    http_redirect = {
      listener_key = "http"
      priority     = 1
      conditions = [{
        type = "Path"
        path_config = {
          values = ["/*"]
        }
      }]
      actions = [{
        type = "Redirect"
        redirect = {
          protocol  = "HTTPS"
          port      = "443"
          http_code = "301"
        }
      }]
    }
    web_host_path_canary = {
      listener_key = "https"
      priority     = 1
      conditions = [
        {
          type = "Host"
          host_config = {
            values = [var.test_domain]
          }
        },
        {
          type = "Path"
          path_config = {
            values = ["/"]
          }
        }
      ]
      actions = [{
        type = "ForwardGroup"
        forward_server_groups = [
          {
            server_group_key = "web"
            weight           = 90
          },
          {
            server_group_key = "canary"
            weight           = 10
          }
        ]
      }]
    }
    api_header = {
      listener_key = "https"
      priority     = 2
      conditions = [
        {
          type = "Host"
          host_config = {
            values = [var.test_domain]
          }
        },
        {
          type = "Path"
          path_config = {
            values = ["/api"]
          }
        },
        {
          type = "Header"
          header_config = {
            key    = "X-Route"
            values = ["v2"]
          }
        }
      ]
      actions = [{
        type = "ForwardGroup"
        forward_server_groups = [{
          server_group_key = "api"
          weight           = 100
        }]
      }]
    }
  }

  tags = {
    purpose   = "terraform-alb-qa"
    temporary = "true"
  }
}
