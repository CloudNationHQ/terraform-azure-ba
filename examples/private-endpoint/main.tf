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

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 9.0"

  naming = local.naming

  vnet = {
    name                = module.naming.virtual_network.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    address_space       = ["10.19.0.0/16"]

    subnets = {
      sn1 = {
        address_prefixes = ["10.19.1.0/24"]
      }
    }
  }
}

module "batch" {
  source = "../../"

  batch = {
    name                          = replace(module.naming.batch_account.name_unique, "-", "")
    location                      = module.rg.groups.demo.location
    resource_group_name           = module.rg.groups.demo.name
    public_network_access_enabled = false

    private_endpoints = {
      account = {
        subnet_resource_id = module.network.subnets.sn1.id
        subresource_name   = "batchAccount"
      }
    }
  }

  tags = {
    environment = "demo"
  }
}
