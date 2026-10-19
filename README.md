# terraform-volcenginecc-alb

## 1. Overview

Terraform module for managing Volcengine ALB resources with the `volcenginecc` provider. The caller owns provider authentication, region configuration, and external resources passed by ID.

## 2. Usage

```hcl
module "alb" {
  source  = "terraform-volcenginecc-modules/alb/volcenginecc"
  version = "~> 1.0"

  # Set the required module inputs for your environment.
}
```

## 3. Examples

- `basic`: independently runnable basic configuration.
- `complete`: independently runnable complete configuration.

## 4. Requirements

| Name | Version |
|---|---|
| Terraform | `>= 1.5.7` |
| OpenTofu | `>= 1.11.8` |

## 5. Providers

| Name | Source |
|---|---|
| `volcenginecc` | `volcengine/volcenginecc` |

## 6. Resources

| Name | Description |
|---|---|
| `volcenginecc_alb_load_balancer` | Module-defined volcenginecc_alb_load_balancer. |
| `volcenginecc_alb_server_group` | Module-defined volcenginecc_alb_server_group. |
| `volcenginecc_alb_listener` | Module-defined volcenginecc_alb_listener. |
| `volcenginecc_alb_rule` | Module-defined volcenginecc_alb_rule. |

## 7. Inputs

| Name | Description |
|---|---|
| `load_balancer_name` | Module-defined load_balancer_name. |
| `vpc_id` | Module-defined vpc_id. |
| `zone_mappings` | Module-defined zone_mappings. |
| `type` | Module-defined type. |
| `address_ip_version` | Module-defined address_ip_version. |
| `load_balancer_edition` | Module-defined load_balancer_edition. |
| `load_balancer_billing_type` | Module-defined load_balancer_billing_type. |
| `description` | Module-defined description. |
| `project_name` | Module-defined project_name. |
| `delete_protection` | Module-defined delete_protection. |
| `modification_protection_status` | Module-defined modification_protection_status. |
| `modification_protection_reason` | Module-defined modification_protection_reason. |
| `eip_billing_config` | Module-defined eip_billing_config. |
| `tls_access_log` | Module-defined tls_access_log. |
| `health_log` | Module-defined health_log. |
| `tags` | Module-defined tags. |
| `server_groups` | Module-defined server_groups. |
| `listeners` | Module-defined listeners. |
| `rules` | Module-defined rules. |

## 8. Outputs

| Name | Description |
|---|---|
| `load_balancer_id` | Module-defined load_balancer_id. |
| `dns_name` | Module-defined dns_name. |
| `server_group_ids` | Module-defined server_group_ids. |
| `listener_ids` | Module-defined listener_ids. |
| `rule_ids` | Module-defined rule_ids. |

## 9. Notes

- Configure credentials using supported provider mechanisms; do not put access keys in module files.
- Review replacement behavior and provider constraints before applying changes.
- Run `terraform plan` after apply and confirm that the second plan has no changes.
