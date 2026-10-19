# BASIC ALB Example

## 1. Overview

Runnable basic configuration for the ALB module. It configures the provider from input variables and calls the published Registry module.

## 2. Usage

```shell
terraform init
terraform plan
terraform apply
terraform plan
terraform destroy
```

## 3. Examples

This directory is the basic example.

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
| `terraform-volcenginecc-modules/alb/volcenginecc` | Published ALB module. |

## 7. Inputs

| Name | Description |
|---|---|
| `vpc_id` | Module-defined vpc_id. |
| `zone_id` | Module-defined zone_id. |
| `subnet_id` | Module-defined subnet_id. |
| `backend_instance_id` | Module-defined backend_instance_id. |
| `backend_private_ip` | Module-defined backend_private_ip. |

## 8. Outputs

| Name | Description |
|---|---|
| `load_balancer_id` | Module-defined load_balancer_id. |
| `dns_name` | Module-defined dns_name. |

## 9. Notes

- Supply credentials through supported provider configuration, never in source files.
- The final plan after apply must report no changes before the configuration is accepted.
