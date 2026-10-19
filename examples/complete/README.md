# COMPLETE ALB Example

## 1. Overview

Runnable complete configuration for the ALB module. It configures the provider from input variables and calls the published Registry module.

## 2. Usage

```shell
terraform init
terraform plan
terraform apply
terraform plan
terraform destroy
```

## 3. Examples

This directory is the complete example.

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
| `subnet_id` | Module-defined subnet_id. |
| `backend_instance_id` | Module-defined backend_instance_id. |
| `cert_center_certificate_id` | Module-defined cert_center_certificate_id. |
| `test_domain` | Module-defined test_domain. |
| `name_suffix` | Module-defined name_suffix. |

## 8. Outputs

| Name | Description |
|---|---|
| `load_balancer_id` | Module-defined load_balancer_id. |
| `dns_name` | Module-defined dns_name. |

## 9. Notes

- Supply credentials through supported provider configuration, never in source files.
- The final plan after apply must report no changes before the configuration is accepted.
