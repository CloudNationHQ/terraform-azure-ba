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

    certificates = {
      # a self signed public (Cer) certificate; replace with your own value
      public = {
        format               = "Cer"
        thumbprint_algorithm = "SHA1"
        thumbprint           = "1e30622264900b576e2b17b44ea096f0d61565a6"
        certificate          = "MIIDCzCCAfOgAwIBAgIUJrOL15IMHsWz4Rx9PqCci+/AMJYwDQYJKoZIhvcNAQELBQAwFTETMBEGA1UEAwwKYmF0Y2gtZGVtbzAeFw0yNjA2MDYxMzMyMzNaFw0zNjA2MDMxMzMyMzNaMBUxEzARBgNVBAMMCmJhdGNoLWRlbW8wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCh5mk0hvRwPk6w24Cw3Wtq+/9yn6FfA9onqja5UJJVfW2iTrEZvQ8rqSsy+RUKd2mOQ+YSLkLOqKFapMnBgis3IdC67Lmcikg+WmZlbkEv8U8Qhr3Ll1SsezK7m2wZDnyCAHtjraHdUbGefyjmj54JEKoezmqTB7qk3Zz2SZsGYnL4Ugr8XStHdMGfi/hkgoJ+wM/+nCoCS0tEDymNQeXg0y6zVTq6GrGAicmkaDyjNrfo5OLafjruB5b3yPmffQmwSO/mV3CZT3q1D9z1eynQn/oOLSYApoHZcmMG9FIs420fZ03m4Ijk8H6qcHmN4HkYJbJV9l+0RzDeAZztDJRrAgMBAAGjUzBRMB0GA1UdDgQWBBS/FV8QEUzzLstNxMxNA1wr25tbizAfBgNVHSMEGDAWgBS/FV8QEUzzLstNxMxNA1wr25tbizAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQA0un06dNPZkkjbJ0FVc6icJ/sk4tOj3BU6wYm9JNKd3TI7QqNYbX+VzrEfrEs3FI5EfbNplVWa9Q0tbV+vdfoFbn+jOdAGCarLljEnVbAAfssXT0vHj+MuTqkF2oU3y00vV5va0M1FsL40jTFfuHWygDcD6oMhsQEZk5c4PQQTJ9uQa7Drpn6XNSH4noDMffNTkGCAhqiIU7fmV7EcsLneFs8ZzNc6pIn1rI1NCpNtvXP0ziDkIR6uS70+5DhD0+Xtso9SCtRPWKdGT6IfXu7Oo79RzAYs5h8lqi+z+NxZSIKXSmXPwQOzpDybkJYbOnE/HejB5YwXdYlOHTJJ1Rm+"
      }
    }
  }

  tags = {
    environment = "demo"
  }
}
