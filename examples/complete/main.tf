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
    name                 = module.naming.batch_account.name_unique
    location             = module.rg.groups.demo.location
    resource_group_name  = module.rg.groups.demo.name
    pool_allocation_mode = "BatchService"

    applications = {
      app1 = {
        display_name  = "demo-application"
        allow_updates = true
      }
    }

    pools = {
      linux = {
        name              = module.naming.batch_pool.name
        vm_size           = "Standard_A1_v2"
        node_agent_sku_id = "batch.node.ubuntu 22.04"

        fixed_scale = {
          target_dedicated_nodes = 1
        }

        storage_image_reference = {
          publisher = "canonical"
          offer     = "0001-com-ubuntu-server-jammy"
          sku       = "22_04-lts"
          version   = "latest"
        }

        start_task = {
          command_line     = "echo 'hello from batch'"
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
            display_name       = "demo-job"
            priority           = 1
            task_retry_maximum = 2
          }
        }
      }
    }
  }

  tags = {
    environment = "demo"
  }
}
