# Batch

This terraform module simplifies the creation and management of azure batch
resources, providing customizable options for batch accounts, applications,
certificates, pools and jobs, all managed through code.

## Features

Capability to handle batch accounts, applications, certificates, pools and jobs.

Supports system and user assigned managed identities on the account and pools.

Supports customer managed key encryption and account network profiles.

Integrates seamlessly with private endpoint capabilities for direct and secure connectivity.

Utilization of terratest for robust validation.

## Private Endpoint

This module embeds private endpoint support directly (`batch.private_endpoints`). Embedding is the right choice when the batch account is managed with public network access disabled in the same terraform apply.

When the private endpoint belongs to a different state file or team (e.g. a platform networking team owns connectivity), use our standalone [terraform-azure-pe](https://github.com/CloudNationHQ/terraform-azure-pe) module instead and keep the account publicly accessible or accept a two-phase apply. Both patterns are supported and the choice belongs to the caller.

## Note

The `azurerm_batch_certificate` resource is deprecated upstream because Azure retired the Batch Account Certificates feature on 2024-02-29; it remains in this module per the module contract and will be removed once the provider drops it. Use pool certificate references or key vault instead.

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 4.0)

## Resources

The following resources are used by this module:

- [azurerm_batch_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/batch_account) (resource)
- [azurerm_batch_application.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/batch_application) (resource)
- [azurerm_batch_certificate.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/batch_certificate) (resource)
- [azurerm_batch_job.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/batch_job) (resource)
- [azurerm_batch_pool.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/batch_pool) (resource)
- [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_batch"></a> [batch](#input\_batch)

Description: Contains all batch account configuration

Type:

```hcl
object({
    name                                = string
    location                            = optional(string)
    resource_group_name                 = optional(string)
    tags                                = optional(map(string))
    pool_allocation_mode                = optional(string)
    public_network_access_enabled       = optional(bool)
    allowed_authentication_modes        = optional(set(string))
    storage_account_id                  = optional(string)
    storage_account_authentication_mode = optional(string)
    storage_account_node_identity       = optional(string)
    encryption = optional(object({
      key_vault_key_id = optional(string)
    }))
    key_vault_reference = optional(object({
      id  = string
      url = string
    }))
    identity = optional(object({
      type         = string
      identity_ids = optional(set(string))
    }))
    network_profile = optional(object({
      account_access = optional(object({
        default_action = optional(string)
        ip_rule = optional(map(object({
          ip_range = string
          action   = optional(string)
        })))
      }))
      node_management_access = optional(object({
        default_action = optional(string)
        ip_rule = optional(map(object({
          ip_range = string
          action   = optional(string)
        })))
      }))
    }))
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
    applications = optional(map(object({
      name            = optional(string)
      display_name    = optional(string)
      allow_updates   = optional(bool)
      default_version = optional(string)
    })))
    certificates = optional(map(object({
      certificate          = string
      format               = string
      thumbprint           = string
      thumbprint_algorithm = string
      password             = optional(string)
    })))
    pools = optional(map(object({
      name                           = optional(string)
      display_name                   = optional(string)
      vm_size                        = string
      node_agent_sku_id              = string
      inter_node_communication       = optional(string)
      license_type                   = optional(string)
      max_tasks_per_node             = optional(number)
      metadata                       = optional(map(string))
      os_disk_placement              = optional(string)
      stop_pending_resize_operation  = optional(bool)
      target_node_communication_mode = optional(string)
      fixed_scale = optional(object({
        node_deallocation_method  = optional(string)
        resize_timeout            = optional(string)
        target_dedicated_nodes    = optional(number)
        target_low_priority_nodes = optional(number)
      }))
      auto_scale = optional(object({
        formula             = string
        evaluation_interval = optional(string)
      }))
      storage_image_reference = optional(object({
        id        = optional(string)
        offer     = optional(string)
        publisher = optional(string)
        sku       = optional(string)
        version   = optional(string)
      }))
      container_configuration = optional(object({
        type                  = optional(string)
        container_image_names = optional(set(string))
        container_registries = optional(list(object({
          registry_server           = optional(string)
          user_name                 = optional(string)
          password                  = optional(string)
          user_assigned_identity_id = optional(string)
        })))
      }))
      identity = optional(object({
        type         = string
        identity_ids = set(string)
      }))
      node_placement = optional(map(object({
        policy = optional(string)
      })))
      task_scheduling_policy = optional(map(object({
        node_fill_type = optional(string)
      })))
      security_profile = optional(object({
        host_encryption_enabled = optional(bool)
        secure_boot_enabled     = optional(bool)
        security_type           = optional(string)
        vtpm_enabled            = optional(bool)
      }))
      windows = optional(map(object({
        enable_automatic_updates = optional(bool)
      })))
      data_disks = optional(map(object({
        lun                  = number
        disk_size_gb         = number
        caching              = optional(string)
        storage_account_type = optional(string)
      })))
      disk_encryption = optional(map(object({
        disk_encryption_target = string
      })))
      certificate = optional(map(object({
        id             = string
        store_location = string
        store_name     = optional(string)
        visibility     = optional(set(string))
      })))
      extensions = optional(map(object({
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
      mount = optional(map(object({
        azure_blob_file_system = optional(object({
          account_name        = string
          container_name      = string
          relative_mount_path = string
          account_key         = optional(string)
          sas_key             = optional(string)
          identity_id         = optional(string)
          blobfuse_options    = optional(string)
        }))
        azure_file_share = optional(map(object({
          account_name        = string
          account_key         = string
          azure_file_url      = string
          relative_mount_path = string
          mount_options       = optional(string)
        })))
        cifs_mount = optional(map(object({
          user_name           = string
          source              = string
          relative_mount_path = string
          password            = string
          mount_options       = optional(string)
        })))
        nfs_mount = optional(map(object({
          source              = string
          relative_mount_path = string
          mount_options       = optional(string)
        })))
      })))
      network_configuration = optional(object({
        subnet_id                        = optional(string)
        accelerated_networking_enabled   = optional(bool)
        dynamic_vnet_assignment_scope    = optional(string)
        public_address_provisioning_type = optional(string)
        public_ips                       = optional(set(string))
        endpoint_configuration = optional(map(object({
          name                = string
          backend_port        = number
          frontend_port_range = string
          protocol            = string
          network_security_group_rules = optional(map(object({
            access                = string
            priority              = number
            source_address_prefix = string
            source_port_ranges    = optional(list(string))
          })))
        })))
      }))
      user_accounts = optional(map(object({
        name            = string
        password        = string
        elevation_level = string
        linux_user_configuration = optional(map(object({
          uid             = optional(number)
          gid             = optional(number)
          ssh_private_key = optional(string)
        })))
        windows_user_configuration = optional(map(object({
          login_mode = string
        })))
      })))
      start_task = optional(object({
        command_line                  = string
        task_retry_maximum            = optional(number)
        wait_for_success              = optional(bool)
        common_environment_properties = optional(map(string))
        container = optional(map(object({
          image_name        = string
          run_options       = optional(string)
          working_directory = optional(string)
          registry = optional(map(object({
            registry_server           = string
            user_name                 = optional(string)
            password                  = optional(string)
            user_assigned_identity_id = optional(string)
          })))
        })))
        user_identity = optional(object({
          user_name = optional(string)
          auto_user = optional(object({
            elevation_level = optional(string)
            scope           = optional(string)
          }))
        }))
        resource_file = optional(map(object({
          auto_storage_container_name = optional(string)
          storage_container_url       = optional(string)
          http_url                    = optional(string)
          blob_prefix                 = optional(string)
          file_path                   = optional(string)
          file_mode                   = optional(string)
          user_assigned_identity_id   = optional(string)
        })))
      }))
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

Description: default azure region to use when not set on the batch object

Type: `string`

Default: `null`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: default resource group name to use when not set on the batch object

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: tags to assign to the resources

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_applications"></a> [applications](#output\_applications)

Description: contains all batch applications

### <a name="output_batch"></a> [batch](#output\_batch)

Description: contains all batch account config

### <a name="output_certificates"></a> [certificates](#output\_certificates)

Description: contains all batch certificates

### <a name="output_jobs"></a> [jobs](#output\_jobs)

Description: contains all batch jobs

### <a name="output_pools"></a> [pools](#output\_pools)

Description: contains all batch pools

### <a name="output_private_endpoints"></a> [private\_endpoints](#output\_private\_endpoints)

Description: contains all private endpoints
<!-- END_TF_DOCS -->