# COMPLETE ALB 示例

## 1. 概述

ALB 模块的可运行 complete 配置。它从输入变量设置 Provider，并调用已发布的 Registry 模块。

## 2. 用法

```shell
terraform init
terraform plan
terraform apply
terraform plan
terraform destroy
```

## 3. 示例

本目录即为 complete 示例。

## 4. 版本要求

| 名称 | 版本 |
|---|---|
| Terraform | `>= 1.5.7` |
| OpenTofu | `>= 1.11.8` |

## 5. Provider

| 名称 | 来源 |
|---|---|
| `volcenginecc` | `volcengine/volcenginecc` |

## 6. 资源

| 名称 | 说明 |
|---|---|
| `terraform-volcenginecc-modules/alb/volcenginecc` | 已发布的 ALB 模块。 |

## 7. 输入

| 名称 | 说明 |
|---|---|
| `subnet_id` | 模块定义的 subnet_id。 |
| `backend_instance_id` | 模块定义的 backend_instance_id。 |
| `cert_center_certificate_id` | 模块定义的 cert_center_certificate_id。 |
| `test_domain` | 模块定义的 test_domain。 |
| `name_suffix` | 模块定义的 name_suffix。 |

## 8. 输出

| 名称 | 说明 |
|---|---|
| `load_balancer_id` | 模块定义的 load_balancer_id。 |
| `dns_name` | 模块定义的 dns_name。 |

## 9. 注意事项

- 请通过 Provider 支持的配置提供凭据，绝不应写入源文件。
- apply 后的最终 plan 必须报告无变更，才能接受该配置。
