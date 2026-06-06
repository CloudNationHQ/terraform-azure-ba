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
    name                = module.naming.batch_account.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    pools = {
      pool1 = {
        display_name      = "autoscale pool"
        vm_size           = "Standard_A1_v2"
        node_agent_sku_id = "batch.node.ubuntu 22.04"

        storage_image_reference = {
          publisher = "canonical"
          offer     = "0001-com-ubuntu-server-jammy"
          sku       = "22_04-lts"
          version   = "latest"
        }

        auto_scale = {
          evaluation_interval = "PT15M"
          formula             = <<-EOF
            startingNumberOfVMs = 1;
            maxNumberofVMs = 4;
            $TargetDedicatedNodes = min(maxNumberofVMs, startingNumberOfVMs);
          EOF
        }
      }
    }
  }

  tags = {
    environment = "demo"
  }
}
