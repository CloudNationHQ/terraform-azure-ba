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
    name                = module.naming.batch_account.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    certificates = {
      demo = {
        certificate          = filebase64("${path.module}/batch.cer")
        format               = "Cer"
        thumbprint           = "d82851bc95e585eceea641437c8477eeec88c00c"
        thumbprint_algorithm = "SHA1"
      }
    }
  }

  tags = {
    environment = "demo"
  }
}
