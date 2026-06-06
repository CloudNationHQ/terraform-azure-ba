variable "batch" {
  description = "describes batch account related configuration"
  type = object({
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
    encryption = optional(object({
      key_vault_key_id = optional(string)
    }))
    identity = optional(object({
      type         = string
      identity_ids = optional(set(string))
    }))
    key_vault_reference = optional(object({
      id  = string
      url = string
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

    applications = optional(map(object({
      name            = optional(string)
      allow_updates   = optional(bool)
      default_version = optional(string)
      display_name    = optional(string)
    })), {})

    certificates = optional(map(object({
      certificate          = string
      format               = string
      thumbprint           = string
      thumbprint_algorithm = string
      password             = optional(string)
    })), {})

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

      storage_image_reference = object({
        id        = optional(string)
        publisher = optional(string)
        offer     = optional(string)
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
        formula             = string
        evaluation_interval = optional(string)
      }))

      identity = optional(object({
        type         = string
        identity_ids = set(string)
      }))

      container_configuration = optional(object({
        type                  = optional(string)
        container_image_names = optional(set(string))
        container_registries = optional(map(object({
          registry_server           = string
          user_name                 = optional(string)
          password                  = optional(string)
          user_assigned_identity_id = optional(string)
        })))
      }))

      network_configuration = optional(object({
        accelerated_networking_enabled   = optional(bool)
        dynamic_vnet_assignment_scope    = optional(string)
        public_address_provisioning_type = optional(string)
        public_ips                       = optional(set(string))
        subnet_id                        = optional(string)
        endpoint_configuration = optional(map(object({
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
        resource_file = optional(map(object({
          auto_storage_container_name = optional(string)
          blob_prefix                 = optional(string)
          file_mode                   = optional(string)
          file_path                   = optional(string)
          http_url                    = optional(string)
          storage_container_url       = optional(string)
          user_assigned_identity_id   = optional(string)
        })))
        user_identity = optional(object({
          user_name = optional(string)
          auto_user = optional(object({
            elevation_level = optional(string)
            scope           = optional(string)
          }))
        }))
      }))

      security_profile = optional(object({
        host_encryption_enabled = optional(bool)
        secure_boot_enabled     = optional(bool)
        security_type           = optional(string)
        vtpm_enabled            = optional(bool)
      }))

      node_placement = optional(object({
        policy = optional(string)
      }))

      task_scheduling_policy = optional(object({
        node_fill_type = optional(string)
      }))

      windows = optional(object({
        enable_automatic_updates = optional(bool)
      }))

      disk_encryption = optional(map(object({
        disk_encryption_target = string
      })))

      data_disks = optional(map(object({
        lun                  = number
        disk_size_gb         = number
        caching              = optional(string)
        storage_account_type = optional(string)
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

      user_accounts = optional(map(object({
        name            = string
        password        = string
        elevation_level = string
        linux_user_configuration = optional(object({
          gid             = optional(number)
          uid             = optional(number)
          ssh_private_key = optional(string)
        }))
        windows_user_configuration = optional(object({
          login_mode = string
        }))
      })))

      mount = optional(object({
        azure_blob_file_system = optional(map(object({
          account_name        = string
          container_name      = string
          relative_mount_path = string
          account_key         = optional(string)
          sas_key             = optional(string)
          blobfuse_options    = optional(string)
          identity_id         = optional(string)
        })))
        azure_file_share = optional(map(object({
          account_name        = string
          account_key         = string
          azure_file_url      = string
          relative_mount_path = string
          mount_options       = optional(string)
        })))
        cifs_mount = optional(map(object({
          user_name           = string
          password            = string
          source              = string
          relative_mount_path = string
          mount_options       = optional(string)
        })))
        nfs_mount = optional(map(object({
          source              = string
          relative_mount_path = string
          mount_options       = optional(string)
        })))
      }))

      jobs = optional(map(object({
        name                          = optional(string)
        display_name                  = optional(string)
        priority                      = optional(number)
        task_retry_maximum            = optional(number)
        common_environment_properties = optional(map(string))
      })), {})
    })), {})
  })

  validation {
    condition     = var.batch.location != null || var.location != null
    error_message = "location must be set on var.batch.location or on the module-level var.location."
  }

  validation {
    condition     = var.batch.resource_group_name != null || var.resource_group_name != null
    error_message = "resource_group_name must be set on var.batch.resource_group_name or on the module-level var.resource_group_name."
  }

  validation {
    condition     = var.batch.pool_allocation_mode == null || contains(["BatchService", "UserSubscription"], coalesce(var.batch.pool_allocation_mode, "BatchService"))
    error_message = "pool_allocation_mode must be one of: BatchService, UserSubscription."
  }

  validation {
    condition     = var.batch.storage_account_authentication_mode == null || contains(["StorageKeys", "BatchAccountManagedIdentity"], coalesce(var.batch.storage_account_authentication_mode, "StorageKeys"))
    error_message = "storage_account_authentication_mode must be one of: StorageKeys, BatchAccountManagedIdentity."
  }
}

variable "location" {
  description = "default azure region to be used."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}
