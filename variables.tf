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
    allowed_authentication_modes        = optional(list(string))

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))

    encryption = optional(object({
      key_vault_key_id = optional(string)
    }))

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

    applications = optional(map(object({
      name            = optional(string)
      allow_updates   = optional(bool)
      default_version = optional(string)
      display_name    = optional(string)
    })), {})

    certificates = optional(map(object({
      name                 = optional(string)
      certificate          = string
      format               = string
      thumbprint           = string
      thumbprint_algorithm = string
      password             = optional(string)
    })), {})

    pools = optional(map(object({
      name                           = optional(string)
      vm_size                        = string
      node_agent_sku_id              = string
      display_name                   = optional(string)
      inter_node_communication       = optional(string)
      license_type                   = optional(string)
      max_tasks_per_node             = optional(number)
      metadata                       = optional(map(string))
      os_disk_placement              = optional(string)
      stop_pending_resize_operation  = optional(bool)
      target_node_communication_mode = optional(string)

      fixed_scale = optional(object({
        target_dedicated_nodes    = optional(number)
        target_low_priority_nodes = optional(number)
        resize_timeout            = optional(string)
        node_deallocation_method  = optional(string)
      }))

      auto_scale = optional(object({
        formula             = string
        evaluation_interval = optional(string)
      }))

      storage_image_reference = optional(object({
        id        = optional(string)
        publisher = optional(string)
        offer     = optional(string)
        sku       = optional(string)
        version   = optional(string)
      }))

      identity = optional(object({
        type         = string
        identity_ids = list(string)
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

      security_profile = optional(object({
        host_encryption_enabled = optional(bool)
        secure_boot_enabled     = optional(bool)
        security_type           = optional(string)
        vtpm_enabled            = optional(bool)
      }))

      container_configuration = optional(object({
        type                  = optional(string)
        container_image_names = optional(list(string))
        container_registries = optional(list(object({
          registry_server           = optional(string)
          user_name                 = optional(string)
          password                  = optional(string)
          user_assigned_identity_id = optional(string)
        })))
      }))

      start_task = optional(object({
        command_line                  = string
        task_retry_maximum            = optional(number)
        wait_for_success              = optional(bool)
        common_environment_properties = optional(map(string))
        container = optional(object({
          image_name        = string
          run_options       = optional(string)
          working_directory = optional(string)
          registry = optional(object({
            registry_server           = optional(string)
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

      network_configuration = optional(object({
        subnet_id                        = optional(string)
        accelerated_networking_enabled   = optional(bool)
        dynamic_vnet_assignment_scope    = optional(string)
        public_address_provisioning_type = optional(string)
        public_ips                       = optional(list(string))
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

      data_disks = optional(list(object({
        lun                  = number
        disk_size_gb         = number
        caching              = optional(string)
        storage_account_type = optional(string)
      })))

      disk_encryption = optional(list(object({
        disk_encryption_target = string
      })))

      certificate = optional(list(object({
        id             = string
        store_location = string
        store_name     = optional(string)
        visibility     = optional(list(string))
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
        provision_after_extensions = optional(list(string))
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
          azure_file_url      = string
          account_key         = string
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
    error_message = "pool_allocation_mode must be one of BatchService or UserSubscription."
  }

  validation {
    condition = alltrue([
      for cert in values(var.batch.certificates) : contains(["Cer", "Pfx"], cert.format)
    ])
    error_message = "certificate format must be one of Cer or Pfx."
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
