data "azurerm_client_config" "current" {}

module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.25"

  suffix = ["demo", "dev"]
}

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

module "batch" {
  source = "../../"

  batch = {
    name                          = replace(module.naming.batch_account.name_unique, "-", "")
    location                      = module.rg.groups.demo.location
    resource_group_name           = module.rg.groups.demo.name
    pool_allocation_mode          = "BatchService"
    public_network_access_enabled = true

    managed_identities = {
      system_assigned = true
    }

    role_assignments = {
      contributor = {
        role_definition_id_or_name = "Reader"
        principal_id               = data.azurerm_client_config.current.object_id
      }
    }

    applications = {
      app1 = {
        display_name = "demo-application"
      }
    }

    pools = {
      pool1 = {
        display_name      = "demo-pool"
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
        }

        start_task = {
          command_line     = "echo hello"
          wait_for_success = true

          user_identity = {
            auto_user = {
              elevation_level = "NonAdmin"
              scope           = "Task"
            }
          }
        }

        jobs = {
          job1 = {
            display_name = "demo-job"
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
