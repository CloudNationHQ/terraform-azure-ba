# Batch

This terraform module simplifies the creation and management of azure batch
resources, providing customizable options for the account, applications,
certificates, pools and jobs, all managed through code.

## Features

Manages a batch account as the primary resource.

Supports applications, certificates, pools and jobs in a single complex object.

Embeds the AVM interfaces for managed identities, customer managed keys, role
assignments, diagnostic settings and private endpoints.

Utilization of terratest for robust validation.

## Private Endpoint

This module embeds private endpoint support directly (`batch.private_endpoints`).
Embedding is the right choice when the batch account is managed in the same
terraform apply with public network access disabled.

When the private endpoint belongs to a different state file or team, use our
standalone [terraform-azure-pe](https://github.com/CloudNationHQ/terraform-azure-pe)
module instead and keep the account publicly accessible. Both patterns are
supported and the choice belongs to the caller.

## Usage

```hcl
module "batch" {
  source = "cloudnationhq/ba/azure"

  batch = {
    name                = "demobatchaccount"
    location            = "westeurope"
    resource_group_name = "demo-rg"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (4.76.0)

## Resources

The following resources are used by this module:

- [azurerm_batch_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/batch_account) (resource)
- [azurerm_batch_application.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/batch_application) (resource)
- [azurerm_batch_certificate.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/batch_certificate) (resource)
- [azurerm_batch_job.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/batch_job) (resource)
- [azurerm_batch_pool.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/batch_pool) (resource)
- [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
- [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_batch"></a> [batch](#input\_batch)

Description: Batch account configuration object, including its applications, certificates, pools and jobs.

Type:

```hcl
object({
    name                                = string
    location                            = optional(string)
    resource_group_name                 = optional(string)
    tags                                = optional(map(string))
    pool_allocation_mode                = optional(string)
    public_network_access_enabled       = optional(bool)
    storage_account_id                  = optional(string)
    storage_account_authentication_mode = optional(string)
    storage_account_node_identity       = optional(string)
    allowed_authentication_modes        = optional(set(string))

    key_vault_reference = optional(object({
      id  = string
      url = string
    }))

    network_profile = optional(object({
      account_access = optional(object({
        default_action = optional(string)
        ip_rule = optional(list(object({
          ip_range = string
          action   = optional(string)
        })))
      }))
      node_management_access = optional(object({
        default_action = optional(string)
        ip_rule = optional(list(object({
          ip_range = string
          action   = optional(string)
        })))
      }))
    }))

    # avm embedded interface: managed identities (external user assigned ids only, never created here)
    managed_identities = optional(object({
      system_assigned            = optional(bool)
      user_assigned_resource_ids = optional(set(string))
    }))

    # avm embedded interface: customer managed key
    customer_managed_key = optional(object({
      key_vault_key_id = string
    }))

    # avm embedded interface: role assignments scoped to the batch account
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string)
      skip_service_principal_aad_check       = optional(bool)
      condition                              = optional(string)
      condition_version                      = optional(string)
      delegated_managed_identity_resource_id = optional(string)
      principal_type                         = optional(string)
    })))

    # avm embedded interface: diagnostic settings
    diagnostic_settings = optional(map(object({
      name                                     = optional(string)
      log_categories                           = optional(set(string))
      log_groups                               = optional(set(string))
      metric_categories                        = optional(set(string))
      log_analytics_destination_type           = optional(string)
      workspace_resource_id                    = optional(string)
      storage_account_resource_id              = optional(string)
      event_hub_authorization_rule_resource_id = optional(string)
      event_hub_name                           = optional(string)
      marketplace_partner_resource_id          = optional(string)
    })))

    # avm embedded interface: private endpoints
    private_endpoints = optional(map(object({
      name                            = optional(string)
      subnet_resource_id              = string
      subresource_name                = optional(string)
      private_dns_zone_resource_ids   = optional(list(string))
      custom_network_interface_name   = optional(string)
      tags                            = optional(map(string))
      private_service_connection_name = optional(string)
      is_manual_connection            = optional(bool)
      request_message                 = optional(string)
      ip_configurations = optional(map(object({
        name               = optional(string)
        private_ip_address = optional(string)
        member_name        = optional(string)
        subresource_name   = optional(string)
      })))
    })))

    # 1:n child of the account
    applications = optional(map(object({
      name            = optional(string)
      allow_updates   = optional(bool)
      default_version = optional(string)
      display_name    = optional(string)
    })))

    # 1:n child of the account
    certificates = optional(map(object({
      certificate          = string
      format               = string
      thumbprint           = string
      thumbprint_algorithm = string
      password             = optional(string)
    })))

    # 1:n child of the account
    pools = optional(map(object({
      name                           = optional(string)
      display_name                   = optional(string)
      vm_size                        = string
      node_agent_sku_id              = string
      max_tasks_per_node             = optional(number)
      inter_node_communication       = optional(string)
      license_type                   = optional(string)
      os_disk_placement              = optional(string)
      metadata                       = optional(map(string))
      stop_pending_resize_operation  = optional(bool)
      target_node_communication_mode = optional(string)

      storage_image_reference = object({
        id        = optional(string)
        offer     = optional(string)
        publisher = optional(string)
        sku       = optional(string)
        version   = optional(string)
      })

      fixed_scale = optional(object({
        node_deallocation_method  = optional(string)
        resize_timeout            = optional(string)
        target_dedicated_nodes    = optional(number)
        target_low_priority_nodes = optional(number)
      }))

      auto_scale = optional(object({
        evaluation_interval = optional(string)
        formula             = string
      }))

      identity = optional(object({
        type         = string
        identity_ids = set(string)
      }))

      container_configuration = optional(object({
        type                  = optional(string)
        container_image_names = optional(set(string))
        container_registries = optional(list(object({
          registry_server           = string
          user_name                 = optional(string)
          password                  = optional(string)
          user_assigned_identity_id = optional(string)
        })))
      }))

      data_disks = optional(list(object({
        disk_size_gb         = number
        lun                  = number
        caching              = optional(string)
        storage_account_type = optional(string)
      })))

      disk_encryption = optional(list(object({
        disk_encryption_target = string
      })))

      extensions = optional(list(object({
        name                       = string
        publisher                  = string
        type                       = string
        type_handler_version       = optional(string)
        auto_upgrade_minor_version = optional(bool)
        automatic_upgrade_enabled  = optional(bool)
        settings_json              = optional(string)
        protected_settings         = optional(string)
        provision_after_extensions = optional(set(string))
      })))

      mount = optional(list(object({
        azure_blob_file_system = optional(object({
          account_name        = string
          container_name      = string
          relative_mount_path = string
          account_key         = optional(string)
          sas_key             = optional(string)
          identity_id         = optional(string)
          blobfuse_options    = optional(string)
        }))
        azure_file_share = optional(object({
          account_name        = string
          account_key         = string
          azure_file_url      = string
          relative_mount_path = string
          mount_options       = optional(string)
        }))
        cifs_mount = optional(object({
          user_name           = string
          source              = string
          relative_mount_path = string
          password            = string
          mount_options       = optional(string)
        }))
        nfs_mount = optional(object({
          source              = string
          relative_mount_path = string
          mount_options       = optional(string)
        }))
      })))

      network_configuration = optional(object({
        subnet_id                        = optional(string)
        dynamic_vnet_assignment_scope    = optional(string)
        accelerated_networking_enabled   = optional(bool)
        public_address_provisioning_type = optional(string)
        public_ips                       = optional(set(string))
        endpoint_configuration = optional(list(object({
          name                = string
          backend_port        = number
          protocol            = string
          frontend_port_range = string
          network_security_group_rules = optional(list(object({
            access                = string
            priority              = number
            source_address_prefix = string
            source_port_ranges    = optional(list(string))
          })))
        })))
      }))

      node_placement = optional(list(object({
        policy = optional(string)
      })))

      security_profile = optional(object({
        host_encryption_enabled = optional(bool)
        secure_boot_enabled     = optional(bool)
        security_type           = optional(string)
        vtpm_enabled            = optional(bool)
      }))

      start_task = optional(object({
        command_line                  = string
        common_environment_properties = optional(map(string))
        task_retry_maximum            = optional(number)
        wait_for_success              = optional(bool)
        container = optional(object({
          image_name        = string
          run_options       = optional(string)
          working_directory = optional(string)
          registry = optional(object({
            registry_server           = string
            user_name                 = optional(string)
            password                  = optional(string)
            user_assigned_identity_id = optional(string)
          }))
        }))
        user_identity = optional(object({
          user_name = optional(string)
          auto_user = optional(object({
            elevation_level = optional(string)
            scope           = optional(string)
          }))
        }))
        resource_file = optional(list(object({
          auto_storage_container_name = optional(string)
          blob_prefix                 = optional(string)
          file_mode                   = optional(string)
          file_path                   = optional(string)
          http_url                    = optional(string)
          storage_container_url       = optional(string)
          user_assigned_identity_id   = optional(string)
        })))
      }))

      task_scheduling_policy = optional(list(object({
        node_fill_type = optional(string)
      })))

      user_accounts = optional(list(object({
        name            = string
        password        = string
        elevation_level = string
        linux_user_configuration = optional(object({
          uid             = optional(number)
          gid             = optional(number)
          ssh_private_key = optional(string)
        }))
        windows_user_configuration = optional(object({
          login_mode = string
        }))
      })))

      windows = optional(list(object({
        enable_automatic_updates = optional(bool)
      })))

      # 1:n child of the pool
      jobs = optional(map(object({
        name                          = optional(string)
        display_name                  = optional(string)
        priority                      = optional(number)
        task_retry_maximum            = optional(number)
        common_environment_properties = optional(map(string))
      })))
    })))
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: Default location used when not set on the batch object.

Type: `string`

Default: `null`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: Default resource group name used when not set on the batch object.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Tags applied to resources when not overridden on the object.

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_applications"></a> [applications](#output\_applications)

Description: Map of batch applications keyed by their configuration key.

### <a name="output_batch"></a> [batch](#output\_batch)

Description: The full batch account resource, including the (sensitive) primary and secondary access keys.

### <a name="output_certificates"></a> [certificates](#output\_certificates)

Description: Map of batch certificates keyed by their configuration key (contains sensitive certificate data).

### <a name="output_jobs"></a> [jobs](#output\_jobs)

Description: Map of batch jobs keyed by '<pool>.<job>'.

### <a name="output_pools"></a> [pools](#output\_pools)

Description: Map of batch pools keyed by their configuration key (may contain sensitive credentials).
<!-- END_TF_DOCS -->

## License

MIT Licensed. See [LICENSE](./LICENSE) for full details.
