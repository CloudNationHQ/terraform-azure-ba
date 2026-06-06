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

    applications = {
      app1 = {
        display_name  = "demo application one"
        allow_updates = true
      }
      app2 = {
        display_name  = "demo application two"
        allow_updates = false
      }
    }
  }

  tags = {
    environment = "demo"
  }
}
