module "alb" {
  source  = "terraform-volcenginecc-modules/alb/volcenginecc"
  version = "~> 1.0"

  load_balancer_name = "basic-http-entry"
  type               = "private"
  vpc_id             = var.vpc_id
  zone_mappings = [{
    zone_id   = var.zone_id
    subnet_id = var.subnet_id
  }]

  server_groups = {
    web = {
      name = "basic-web"
      servers = {
        app = {
          instance_id = var.backend_instance_id
          private_ip  = var.backend_private_ip
          port        = 8080
        }
      }
    }
  }

  listeners = {
    http = {
      name                     = "http"
      protocol                 = "HTTP"
      port                     = 80
      default_server_group_key = "web"
    }
  }

  tags = {
    purpose   = "terraform-alb-basic-example"
    temporary = "true"
  }
}
