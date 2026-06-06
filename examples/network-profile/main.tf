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
    name                          = module.naming.batch_account.name_unique
    location                      = module.rg.groups.demo.location
    resource_group_name           = module.rg.groups.demo.name
    public_network_access_enabled = true

    identity = {
      type = "SystemAssigned"
    }

    network_profile = {
      account_access = {
        default_action = "Deny"
        ip_rule = [
          {
            ip_range = "10.0.0.0/24"
            action   = "Allow"
          }
        ]
      }
      node_management_access = {
        default_action = "Deny"
        ip_rule = [
          {
            ip_range = "10.0.1.0/24"
            action   = "Allow"
          }
        ]
      }
    }
  }

  tags = {
    environment = "demo"
  }
}
