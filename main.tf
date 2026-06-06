# batch account
resource "azurerm_batch_account" "this" {
  name                                = var.batch.name
  resource_group_name                 = coalesce(var.batch.resource_group_name, var.resource_group_name)
  location                            = coalesce(var.batch.location, var.location)
  tags                                = coalesce(var.batch.tags, var.tags)
  pool_allocation_mode                = coalesce(var.batch.pool_allocation_mode, "BatchService")
  public_network_access_enabled       = var.batch.public_network_access_enabled
  storage_account_id                  = var.batch.storage_account_id
  storage_account_authentication_mode = var.batch.storage_account_authentication_mode
  storage_account_node_identity       = var.batch.storage_account_node_identity
  allowed_authentication_modes        = var.batch.allowed_authentication_modes

  dynamic "identity" {
    for_each = var.batch.managed_identities != null ? { "this" = var.batch.managed_identities } : {}

    content {
      type = (
        coalesce(identity.value.system_assigned, false) && length(coalesce(identity.value.user_assigned_resource_ids, [])) > 0 ? "SystemAssigned, UserAssigned" :
        length(coalesce(identity.value.user_assigned_resource_ids, [])) > 0 ? "UserAssigned" :
        "SystemAssigned"
      )
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }

  dynamic "encryption" {
    for_each = var.batch.customer_managed_key != null ? { "this" = var.batch.customer_managed_key } : {}

    content {
      key_vault_key_id = encryption.value.key_vault_key_id
    }
  }

  dynamic "key_vault_reference" {
    for_each = var.batch.key_vault_reference != null ? { "this" = var.batch.key_vault_reference } : {}

    content {
      id  = key_vault_reference.value.id
      url = key_vault_reference.value.url
    }
  }

  dynamic "network_profile" {
    for_each = var.batch.network_profile != null ? { "this" = var.batch.network_profile } : {}

    content {
      dynamic "account_access" {
        for_each = network_profile.value.account_access != null ? { "this" = network_profile.value.account_access } : {}

        content {
          default_action = coalesce(account_access.value.default_action, "Deny")

          dynamic "ip_rule" {
            for_each = account_access.value.ip_rules != null ? account_access.value.ip_rules : {}

            content {
              ip_range = ip_rule.value.ip_range
              action   = coalesce(ip_rule.value.action, "Allow")
            }
          }
        }
      }

      dynamic "node_management_access" {
        for_each = network_profile.value.node_management_access != null ? { "this" = network_profile.value.node_management_access } : {}

        content {
          default_action = coalesce(node_management_access.value.default_action, "Deny")

          dynamic "ip_rule" {
            for_each = node_management_access.value.ip_rules != null ? node_management_access.value.ip_rules : {}

            content {
              ip_range = ip_rule.value.ip_range
              action   = coalesce(ip_rule.value.action, "Allow")
            }
          }
        }
      }
    }
  }
}

# role assignments
resource "azurerm_role_assignment" "this" {
  for_each = var.batch.role_assignments

  scope                            = azurerm_batch_account.this.id
  principal_id                     = each.value.principal_id
  role_definition_id               = startswith(each.value.role_definition_id_or_name, "/") ? each.value.role_definition_id_or_name : null
  role_definition_name             = startswith(each.value.role_definition_id_or_name, "/") ? null : each.value.role_definition_id_or_name
  description                      = each.value.description
  skip_service_principal_aad_check = each.value.skip_service_principal_aad_check
  condition                        = each.value.condition
  condition_version                = each.value.condition_version
  principal_type                   = each.value.principal_type
}

# private endpoints
resource "azurerm_private_endpoint" "this" {
  for_each = var.batch.private_endpoints

  name                          = coalesce(each.value.name, each.key)
  resource_group_name           = coalesce(var.batch.resource_group_name, var.resource_group_name)
  location                      = coalesce(var.batch.location, var.location)
  subnet_id                     = each.value.subnet_resource_id
  custom_network_interface_name = each.value.custom_network_interface_name
  tags                          = coalesce(each.value.tags, var.tags)

  private_service_connection {
    name                           = coalesce(each.value.private_service_connection_name, "${each.key}-connection")
    is_manual_connection           = coalesce(each.value.is_manual_connection, false)
    private_connection_resource_id = azurerm_batch_account.this.id
    subresource_names              = each.value.subresource_name != null ? [each.value.subresource_name] : ["batchAccount"]
    request_message                = each.value.request_message
  }

  dynamic "private_dns_zone_group" {
    for_each = each.value.private_dns_zone_resource_ids != null ? { "this" = each.value.private_dns_zone_resource_ids } : {}

    content {
      name                 = "default"
      private_dns_zone_ids = private_dns_zone_group.value
    }
  }

  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations != null ? each.value.ip_configurations : {}

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      member_name        = ip_configuration.value.member_name
      subresource_name   = ip_configuration.value.subresource_name
    }
  }
}

# diagnostic settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.batch.diagnostic_settings

  name                           = coalesce(each.value.name, each.key)
  target_resource_id             = azurerm_batch_account.this.id
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  storage_account_id             = each.value.storage_account_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name
  log_analytics_destination_type = each.value.log_analytics_destination_type

  dynamic "enabled_log" {
    for_each = each.value.log_categories != null ? each.value.log_categories : []

    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_log" {
    for_each = each.value.log_category_groups != null ? each.value.log_category_groups : []

    content {
      category_group = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = each.value.metric_categories != null ? each.value.metric_categories : []

    content {
      category = enabled_metric.value
    }
  }
}

# batch applications
resource "azurerm_batch_application" "this" {
  for_each = var.batch.applications

  name                = coalesce(each.value.name, each.key)
  resource_group_name = coalesce(var.batch.resource_group_name, var.resource_group_name)
  account_name        = azurerm_batch_account.this.name
  display_name        = each.value.display_name
  allow_updates       = each.value.allow_updates
  default_version     = each.value.default_version
}

# batch certificates
resource "azurerm_batch_certificate" "this" {
  for_each = var.batch.certificates

  resource_group_name  = coalesce(var.batch.resource_group_name, var.resource_group_name)
  account_name         = azurerm_batch_account.this.name
  certificate          = each.value.certificate
  format               = each.value.format
  thumbprint           = each.value.thumbprint
  thumbprint_algorithm = each.value.thumbprint_algorithm
  password             = each.value.password
}

# batch pools
resource "azurerm_batch_pool" "this" {
  for_each = var.batch.pools

  name                           = coalesce(each.value.name, each.key)
  resource_group_name            = coalesce(var.batch.resource_group_name, var.resource_group_name)
  account_name                   = azurerm_batch_account.this.name
  display_name                   = each.value.display_name
  vm_size                        = each.value.vm_size
  node_agent_sku_id              = each.value.node_agent_sku_id
  max_tasks_per_node             = each.value.max_tasks_per_node
  inter_node_communication       = each.value.inter_node_communication
  license_type                   = each.value.license_type
  os_disk_placement              = each.value.os_disk_placement
  metadata                       = each.value.metadata
  stop_pending_resize_operation  = each.value.stop_pending_resize_operation
  target_node_communication_mode = each.value.target_node_communication_mode

  dynamic "storage_image_reference" {
    for_each = each.value.storage_image_reference != null ? { "this" = each.value.storage_image_reference } : {}

    content {
      id        = storage_image_reference.value.id
      publisher = storage_image_reference.value.publisher
      offer     = storage_image_reference.value.offer
      sku       = storage_image_reference.value.sku
      version   = storage_image_reference.value.version
    }
  }

  dynamic "identity" {
    for_each = each.value.identity != null ? { "this" = each.value.identity } : {}

    content {
      type         = coalesce(identity.value.type, "UserAssigned")
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "fixed_scale" {
    for_each = each.value.fixed_scale != null ? { "this" = each.value.fixed_scale } : {}

    content {
      node_deallocation_method  = fixed_scale.value.node_deallocation_method
      resize_timeout            = fixed_scale.value.resize_timeout
      target_dedicated_nodes    = fixed_scale.value.target_dedicated_nodes
      target_low_priority_nodes = fixed_scale.value.target_low_priority_nodes
    }
  }

  dynamic "auto_scale" {
    for_each = each.value.auto_scale != null ? { "this" = each.value.auto_scale } : {}

    content {
      formula             = auto_scale.value.formula
      evaluation_interval = auto_scale.value.evaluation_interval
    }
  }

  dynamic "node_placement" {
    for_each = each.value.node_placement != null ? { "this" = each.value.node_placement } : {}

    content {
      policy = node_placement.value.policy
    }
  }

  dynamic "task_scheduling_policy" {
    for_each = each.value.task_scheduling_policy != null ? { "this" = each.value.task_scheduling_policy } : {}

    content {
      node_fill_type = task_scheduling_policy.value.node_fill_type
    }
  }

  dynamic "security_profile" {
    for_each = each.value.security_profile != null ? { "this" = each.value.security_profile } : {}

    content {
      host_encryption_enabled = security_profile.value.host_encryption_enabled
      secure_boot_enabled     = security_profile.value.secure_boot_enabled
      vtpm_enabled            = security_profile.value.vtpm_enabled
      security_type           = security_profile.value.security_type
    }
  }

  dynamic "windows" {
    for_each = each.value.windows != null ? { "this" = each.value.windows } : {}

    content {
      enable_automatic_updates = windows.value.enable_automatic_updates
    }
  }

  dynamic "container_configuration" {
    for_each = each.value.container_configuration != null ? { "this" = each.value.container_configuration } : {}

    content {
      type                  = container_configuration.value.type
      container_image_names = container_configuration.value.container_image_names
      container_registries = container_configuration.value.container_registries != null ? [
        for registry in values(container_configuration.value.container_registries) : {
          registry_server           = registry.registry_server
          user_name                 = registry.user_name
          password                  = registry.password
          user_assigned_identity_id = registry.user_assigned_identity_id
        }
      ] : null
    }
  }

  dynamic "start_task" {
    for_each = each.value.start_task != null ? { "this" = each.value.start_task } : {}

    content {
      command_line                  = start_task.value.command_line
      task_retry_maximum            = start_task.value.task_retry_maximum
      wait_for_success              = start_task.value.wait_for_success
      common_environment_properties = start_task.value.common_environment_properties

      dynamic "container" {
        for_each = start_task.value.container != null ? { "this" = start_task.value.container } : {}

        content {
          image_name        = container.value.image_name
          run_options       = container.value.run_options
          working_directory = container.value.working_directory
        }
      }

      dynamic "user_identity" {
        for_each = start_task.value.user_identity != null ? { "this" = start_task.value.user_identity } : {}

        content {
          user_name = user_identity.value.user_name

          dynamic "auto_user" {
            for_each = user_identity.value.auto_user != null ? { "this" = user_identity.value.auto_user } : {}

            content {
              elevation_level = auto_user.value.elevation_level
              scope           = auto_user.value.scope
            }
          }
        }
      }

      dynamic "resource_file" {
        for_each = start_task.value.resource_file != null ? start_task.value.resource_file : {}

        content {
          auto_storage_container_name = resource_file.value.auto_storage_container_name
          blob_prefix                 = resource_file.value.blob_prefix
          file_mode                   = resource_file.value.file_mode
          file_path                   = resource_file.value.file_path
          http_url                    = resource_file.value.http_url
          storage_container_url       = resource_file.value.storage_container_url
          user_assigned_identity_id   = resource_file.value.user_assigned_identity_id
        }
      }
    }
  }

  dynamic "network_configuration" {
    for_each = each.value.network_configuration != null ? { "this" = each.value.network_configuration } : {}

    content {
      subnet_id                        = network_configuration.value.subnet_id
      accelerated_networking_enabled   = network_configuration.value.accelerated_networking_enabled
      dynamic_vnet_assignment_scope    = network_configuration.value.dynamic_vnet_assignment_scope
      public_address_provisioning_type = network_configuration.value.public_address_provisioning_type
      public_ips                       = network_configuration.value.public_ips

      dynamic "endpoint_configuration" {
        for_each = network_configuration.value.endpoint_configuration != null ? network_configuration.value.endpoint_configuration : {}

        content {
          name                = endpoint_configuration.key
          backend_port        = endpoint_configuration.value.backend_port
          frontend_port_range = endpoint_configuration.value.frontend_port_range
          protocol            = endpoint_configuration.value.protocol

          dynamic "network_security_group_rules" {
            for_each = endpoint_configuration.value.network_security_group_rules != null ? endpoint_configuration.value.network_security_group_rules : {}

            content {
              access                = network_security_group_rules.value.access
              priority              = network_security_group_rules.value.priority
              source_address_prefix = network_security_group_rules.value.source_address_prefix
              source_port_ranges    = network_security_group_rules.value.source_port_ranges
            }
          }
        }
      }
    }
  }

  dynamic "data_disks" {
    for_each = each.value.data_disks != null ? each.value.data_disks : {}

    content {
      lun                  = data_disks.value.lun
      disk_size_gb         = data_disks.value.disk_size_gb
      caching              = data_disks.value.caching
      storage_account_type = data_disks.value.storage_account_type
    }
  }

  dynamic "disk_encryption" {
    for_each = each.value.disk_encryption != null ? each.value.disk_encryption : {}

    content {
      disk_encryption_target = disk_encryption.value.disk_encryption_target
    }
  }

  dynamic "extensions" {
    for_each = each.value.extensions != null ? each.value.extensions : {}

    content {
      name                       = extensions.value.name
      publisher                  = extensions.value.publisher
      type                       = extensions.value.type
      type_handler_version       = extensions.value.type_handler_version
      auto_upgrade_minor_version = extensions.value.auto_upgrade_minor_version
      automatic_upgrade_enabled  = extensions.value.automatic_upgrade_enabled
      settings_json              = extensions.value.settings_json
      protected_settings         = extensions.value.protected_settings
      provision_after_extensions = extensions.value.provision_after_extensions
    }
  }

  dynamic "mount" {
    for_each = each.value.mount != null ? { "this" = each.value.mount } : {}

    content {
      dynamic "azure_blob_file_system" {
        for_each = mount.value.azure_blob_file_system != null ? mount.value.azure_blob_file_system : {}

        content {
          account_name        = azure_blob_file_system.value.account_name
          container_name      = azure_blob_file_system.value.container_name
          relative_mount_path = azure_blob_file_system.value.relative_mount_path
          account_key         = azure_blob_file_system.value.account_key
          sas_key             = azure_blob_file_system.value.sas_key
          identity_id         = azure_blob_file_system.value.identity_id
          blobfuse_options    = azure_blob_file_system.value.blobfuse_options
        }
      }

      dynamic "azure_file_share" {
        for_each = mount.value.azure_file_share != null ? mount.value.azure_file_share : {}

        content {
          account_name        = azure_file_share.value.account_name
          account_key         = azure_file_share.value.account_key
          azure_file_url      = azure_file_share.value.azure_file_url
          relative_mount_path = azure_file_share.value.relative_mount_path
          mount_options       = azure_file_share.value.mount_options
        }
      }

      dynamic "cifs_mount" {
        for_each = mount.value.cifs_mount != null ? mount.value.cifs_mount : {}

        content {
          user_name           = cifs_mount.value.user_name
          source              = cifs_mount.value.source
          relative_mount_path = cifs_mount.value.relative_mount_path
          password            = cifs_mount.value.password
          mount_options       = cifs_mount.value.mount_options
        }
      }

      dynamic "nfs_mount" {
        for_each = mount.value.nfs_mount != null ? mount.value.nfs_mount : {}

        content {
          source              = nfs_mount.value.source
          relative_mount_path = nfs_mount.value.relative_mount_path
          mount_options       = nfs_mount.value.mount_options
        }
      }
    }
  }

  dynamic "user_accounts" {
    for_each = each.value.user_accounts != null ? each.value.user_accounts : {}

    content {
      name            = user_accounts.value.name
      password        = user_accounts.value.password
      elevation_level = user_accounts.value.elevation_level

      dynamic "linux_user_configuration" {
        for_each = user_accounts.value.linux_user_configuration != null ? { "this" = user_accounts.value.linux_user_configuration } : {}

        content {
          uid             = linux_user_configuration.value.uid
          gid             = linux_user_configuration.value.gid
          ssh_private_key = linux_user_configuration.value.ssh_private_key
        }
      }

      dynamic "windows_user_configuration" {
        for_each = user_accounts.value.windows_user_configuration != null ? { "this" = user_accounts.value.windows_user_configuration } : {}

        content {
          login_mode = windows_user_configuration.value.login_mode
        }
      }
    }
  }
}

# batch jobs
resource "azurerm_batch_job" "this" {
  for_each = local.batch_jobs

  name                          = coalesce(each.value.config.name, each.value.job_key)
  batch_pool_id                 = azurerm_batch_pool.this[each.value.pool_key].id
  display_name                  = each.value.config.display_name
  priority                      = each.value.config.priority
  task_retry_maximum            = each.value.config.task_retry_maximum
  common_environment_properties = each.value.config.common_environment_properties
}

locals {
  batch_jobs = merge([
    for pool_key, pool in var.batch.pools : {
      for job_key, job in pool.jobs : "${pool_key}|${job_key}" => {
        pool_key = pool_key
        job_key  = job_key
        config   = job
      }
    }
  ]...)
}
