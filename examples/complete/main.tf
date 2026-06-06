data "azurerm_client_config" "current" {}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

module "ba" {
  source = "../../"

  batch = {
    name                          = module.naming.batch_account.name_unique
    location                      = module.rg.groups.demo.location
    resource_group_name           = module.rg.groups.demo.name
    pool_allocation_mode          = "BatchService"
    public_network_access_enabled = true

    managed_identities = {
      system_assigned = true
    }

    network_profile = {
      account_access = {
        default_action = "Deny"
        ip_rules = {
          office = {
            ip_range = "10.0.0.0/24"
            action   = "Allow"
          }
        }
      }
    }

    role_assignments = {
      contributor = {
        role_definition_id_or_name = "Reader"
        principal_id               = data.azurerm_client_config.current.object_id
      }
    }

    applications = {
      app1 = {
        display_name  = "demo application"
        allow_updates = true
      }
    }

    pools = {
      pool1 = {
        display_name      = "demo pool"
        vm_size           = "Standard_A1_v2"
        node_agent_sku_id = "batch.node.ubuntu 22.04"

        storage_image_reference = {
          publisher = "canonical"
          offer     = "0001-com-ubuntu-server-jammy"
          sku       = "22_04-lts"
          version   = "latest"
        }

        fixed_scale = {
          target_dedicated_nodes = 1
          resize_timeout         = "PT15M"
        }

        start_task = {
          command_line     = "echo hello"
          wait_for_success = true

          user_identity = {
            auto_user = {
              elevation_level = "NonAdmin"
              scope           = "Pool"
            }
          }
        }

        jobs = {
          job1 = {
            display_name = "demo job"
            priority     = 1
          }
        }
      }
    }
  }

  tags = {
    environment = "demo"
  }
}
