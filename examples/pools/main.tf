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
    name                = replace(module.naming.batch_account.name_unique, "-", "")
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    pools = {
      autoscale = {
        display_name       = "autoscale-pool"
        vm_size            = "Standard_A1_v2"
        node_agent_sku_id  = "batch.node.ubuntu 22.04"
        max_tasks_per_node = 2

        storage_image_reference = {
          publisher = "canonical"
          offer     = "0001-com-ubuntu-server-jammy"
          sku       = "22_04-lts"
          version   = "latest"
        }

        auto_scale = {
          evaluation_interval = "PT15M"
          formula             = "$TargetDedicatedNodes = 1;"
        }

        task_scheduling_policy = [
          {
            node_fill_type = "Pack"
          }
        ]
      }

      container = {
        display_name      = "container-pool"
        vm_size           = "Standard_A1_v2"
        node_agent_sku_id = "batch.node.ubuntu 22.04"

        storage_image_reference = {
          publisher = "microsoft-azure-batch"
          offer     = "ubuntu-server-container"
          sku       = "20-04-lts"
          version   = "latest"
        }

        fixed_scale = {
          target_dedicated_nodes = 1
        }

        container_configuration = {
          type                  = "DockerCompatible"
          container_image_names = ["centos7"]
        }
      }
    }
  }

  tags = {
    environment = "demo"
  }
}
