# terraform-volcenginecc-alb

## 1. 概述

基于 `volcenginecc` Provider 管理火山引擎 ALB 资源的 Terraform 模块。调用方负责 Provider 凭据、地域配置，以及通过 ID 传入的外部资源。

## 2. 用法

```hcl
module "alb" {
  source  = "terraform-volcenginecc-modules/alb/volcenginecc"
  version = "~> 1.0"

  # 请设置适用于当前环境的必填模块输入。
}
```

## 3. 示例

- `basic`：可独立运行的 basic 配置。
- `complete`：可独立运行的 complete 配置。

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
| `volcenginecc_alb_load_balancer` | 模块定义的 volcenginecc_alb_load_balancer。 |
| `volcenginecc_alb_server_group` | 模块定义的 volcenginecc_alb_server_group。 |
| `volcenginecc_alb_listener` | 模块定义的 volcenginecc_alb_listener。 |
| `volcenginecc_alb_rule` | 模块定义的 volcenginecc_alb_rule。 |

## 7. 输入

| 名称 | 说明 |
|---|---|
| `load_balancer_name` | 模块定义的 load_balancer_name。 |
| `vpc_id` | 模块定义的 vpc_id。 |
| `zone_mappings` | 模块定义的 zone_mappings。 |
| `type` | 模块定义的 type。 |
| `address_ip_version` | 模块定义的 address_ip_version。 |
| `load_balancer_edition` | 模块定义的 load_balancer_edition。 |
| `load_balancer_billing_type` | 模块定义的 load_balancer_billing_type。 |
| `description` | 模块定义的 description。 |
| `project_name` | 模块定义的 project_name。 |
| `delete_protection` | 模块定义的 delete_protection。 |
| `modification_protection_status` | 模块定义的 modification_protection_status。 |
| `modification_protection_reason` | 模块定义的 modification_protection_reason。 |
| `eip_billing_config` | 模块定义的 eip_billing_config。 |
| `tls_access_log` | 模块定义的 tls_access_log。 |
| `health_log` | 模块定义的 health_log。 |
| `tags` | 模块定义的 tags。 |
| `server_groups` | 模块定义的 server_groups。 |
| `listeners` | 模块定义的 listeners。 |
| `rules` | 模块定义的 rules。 |

## 8. 输出

| 名称 | 说明 |
|---|---|
| `load_balancer_id` | 模块定义的 load_balancer_id。 |
| `dns_name` | 模块定义的 dns_name。 |
| `server_group_ids` | 模块定义的 server_group_ids。 |
| `listener_ids` | 模块定义的 listener_ids。 |
| `rule_ids` | 模块定义的 rule_ids。 |

## 9. 注意事项

- 请通过 Provider 支持的方式配置凭据，不要将访问密钥写入模块文件。
- 执行变更前请审阅替换行为及 Provider 限制。
- apply 后请再次执行 `terraform plan`，并确认第二次 plan 无变更。
